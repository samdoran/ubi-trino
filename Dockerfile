FROM registry.access.redhat.com/ubi8/ubi

USER root

ARG PRESTO_VERSION=348
ARG PROMETHEUS_JMX_EXPORTER_VER=0.14.0
ARG FAQ_VERSION=0.0.6
ARG TINI_VERSION=v0.19.0

ENV HOME /opt/presto
ENV PRESTO_HOME /opt/presto/presto-server
ENV PRESTO_CLI /opt/presto/presto-cli
ENV PROMETHEUS_JMX_EXPORTER /opt/jmx_exporter/jmx_exporter.jar
ENV TERM linux
ENV JAVA_HOME=/etc/alternatives/jre_11_openjdk

RUN set -x; \
    INSTALL_PKGS="java-11-openjdk java-11-openjdk-devel openssl less curl rsync diffutils python3" \
    && yum clean all \
    && rm -rf /var/cache/yum/* \
    && yum install --setopt=skip_missing_names_on_install=False -y $INSTALL_PKGS \
    && yum clean all \
    && rm -rf /var/cache/yum \
    && alternatives --set python /usr/bin/python3

# go get faq via static Linux binary approach
RUN curl -sLo /usr/local/bin/faq \
         https://github.com/jzelinskie/faq/releases/download/$FAQ_VERSION/faq-linux-amd64 \
     && chmod +x /usr/local/bin/faq

# Get tini
RUN curl -sLo /usr/bin/tini \
         https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini \
    && chmod +x /usr/bin/tini

# Presto dirs
RUN mkdir -p $HOME \
    && chmod -R 775 /opt/presto

# Install presto server
RUN curl -sLo ${HOME}/presto_server.tar.gz \
         https://repo1.maven.org/maven2/io/prestosql/presto-server/${PRESTO_VERSION}/presto-server-${PRESTO_VERSION}.tar.gz \
    && tar -C ${HOME} -zxf ${HOME}/presto_server.tar.gz \
    && mv ${HOME}/presto-server-${PRESTO_VERSION} ${PRESTO_HOME} \
    && rm ${HOME}/presto_server.tar.gz

# Install presto CLI
RUN curl -sLo ${PRESTO_CLI} \
         https://repo1.maven.org/maven2/io/prestosql/presto-cli/347/presto-cli-347-executable.jar \
    && chmod 755 ${PRESTO_CLI} \
    && ln $PRESTO_CLI /usr/local/bin/presto-cli \
    && chmod 755 /usr/local/bin/presto-cli

# Install prometheus-jmx agent
RUN yum install -y maven \
    && mvn -B dependency:get \
           -Dartifact=io.prometheus.jmx:jmx_prometheus_javaagent:${PROMETHEUS_JMX_EXPORTER_VER}:jar \
           -Ddest=${PROMETHEUS_JMX_EXPORTER} \
    && yum remove -y maven \
    && yum clean all \
    && rm -rf /var/cache/yum

# Java security config
RUN touch $JAVA_HOME/lib/security/java.security \
    && sed -i -e '/networkaddress.cache.ttl/d' \
           -e '/networkaddress.cache.negative.ttl/d' \
           $JAVA_HOME/lib/security/java.security \
    && printf 'networkaddress.cache.ttl=0\nnetworkaddress.cache.negative.ttl=0\n' >> $JAVA_HOME/lib/security/java.security \
    && chmod -R g+rwx $(readlink -f ${JAVA_HOME}) \
             $(readlink -f ${JAVA_HOME}/lib/security) \
             $(readlink -f ${JAVA_HOME}/lib/security/cacerts)


USER 1003
EXPOSE 8080
WORKDIR $PRESTO_HOME

CMD ["tini", "--", "bin/launcher", "run"]

LABEL io.k8s.display-name="OpenShift Presto" \
      io.k8s.description="This is an image used by Cost Management to install and run Presto." \
      summary="This is an image used by Cost Management to install and run Presto." \
      io.openshift.tags="openshift" \
      maintainer="<cost-mgmt@redhat.com>"
