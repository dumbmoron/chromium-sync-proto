#!/bin/bash
set -euxo pipefail

sudo rm -rf /usr/local/lib/android \
            /usr/local/.ghcup \
            /usr/lib/jvm \
            /usr/lib/google-cloud-sdk \
            /usr/lib/dotnet \
            /usr/lib/firefox \
            /opt/az \
            /opt/ghc \
            /opt/google \
            /opt/hostedtoolcache \
            /opt/microsoft \
            /usr/share

sudo apt-get -y install git-filter-repo
git config --local user.email "41898282+github-actions[bot]@users.noreply.github.com"
git config --local user.name "github-actions[bot]"

./update.sh

git push
