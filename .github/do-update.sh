#!/bin/bash
set -euxo pipefail

sudo cp -r . /mnt/repo
cd /mnt/repo
sudo chown -R $(id -u):$(id -g) .

sudo apt-get -y install git-filter-repo

git config --local user.email "41898282+github-actions[bot]@users.noreply.github.com"
git config --local user.name "github-actions[bot]"

./update.sh

git push || :
