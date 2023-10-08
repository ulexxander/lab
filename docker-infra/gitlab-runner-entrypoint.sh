#!/bin/sh

set -e

if [ -z "$GITLAB_RUNNER_ID" ]; then echo "Variable GITLAB_RUNNER_ID not set"; exit 1; fi
if [ -z "$GITLAB_RUNNER_TOKEN" ]; then echo "Variable GITLAB_RUNNER_TOKEN not set"; exit 1; fi

sed \
  -e "s/\$GITLAB_RUNNER_ID/$GITLAB_RUNNER_ID/" \
  -e "s/\$GITLAB_RUNNER_TOKEN/$GITLAB_RUNNER_TOKEN/" \
  /etc/gitlab-runner/config-template.toml > /etc/gitlab-runner/config.toml

exec /usr/bin/dumb-init /entrypoint $@
