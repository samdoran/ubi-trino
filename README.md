# ubi-presto

Docker Image build from RHEL UBI base image

# Workflow

## Basic workflow

1. Branch from `main`
2. Make changes
3. Commit and Push
4. Create PR merging into `main`
5. Get reviewed and approved

## Build new version of Presto

1. Checkout `main` and pull
2. Execute `check_upstream.sh` If it reports _Up to date with prestosql/presto_ then stop.
3. If it reports a new presto version number, then branch from `main` for that new version.
4. Update `Dockerfile` : `ARG PRESTO_VERSION` setting it to the version reported.
5. Execute `get_presto_version.sh` to make sure that the output matches the new presto version.
6. Run a test build by executing `docker-build-dev.sh`
7. If successful, then commit changes and push branch.
8. Create a PR, this should execute a PR check script.
9. If successful, get approval.

# Utility Scripts

* `check_upstream.sh` : Check the current version of presto set in the Dockerfile against release tags from the `prestosql/presto` repo.
* `get_presto_version.sh` : Get the current presto version from the `Dockerfile`.
* `get_latest_repo_release_tag.sh` : Get the latest release tag from the `prestosql/presto repo`.
* `docker-build-dev.sh` : Executes a local test build of the docker image.

# Integration Scripts

* `pr_check.sh` : PR check script (You should not need to modify this)
* `build_deploy.sh` : Build and deploy to Red Hat cloudservices quay org. (You should not need to modify this script)

