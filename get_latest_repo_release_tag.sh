#! /usr/bin/env sh

# This checks the remote upstream tag refs
git ls-remote --tags https://github.com/trinodb/trino | sed -E 's/.*refs.tags.([0-9]+).*/\1/g' | sed -E '/[A-Za-z\-\_]/d' | sort -u -nr | head -1
