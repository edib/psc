#!/bin/bash

sudo -S -s eval 'wget --no-check-certificate --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -'
sudo -S -s eval 'wget --no-check-certificate -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -'
sudo -S -s eval 'echo "Acquire::https::artifacts.elastic.co::Verify-Peer "false";" > /etc/apt/apt.conf.d/99psc'

sudo -S apt-get install apt-transport-https

sudo -S -s eval 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
sudo -S -s eval 'echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" > /etc/apt/sources.list.d/elastic-8.x.list'

echo ">>>>>>>>>Apt update"
sudo -S apt-get -q update
