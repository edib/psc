#!/bin/bash


echo ">>>>>>>>>Adding repos to sources.list"
sudo -S -s eval 'echo "deb http://yansi.hmb.gov.tr/ubuntu/ focal main restricted universe multiverse" > /etc/apt/sources.list'
sudo -S -s eval 'echo "deb http://yansi.hmb.gov.tr/ubuntu/ focal-updates main restricted universe multiverse" >> /etc/apt/sources.list'
sudo -S -s eval 'echo "deb http://yansi.hmb.gov.tr/ubuntu/ focal-security main restricted universe multiverse" >> /etc/apt/sources.list'
sudo -S -s eval 'echo "deb http://yansi.hmb.gov.tr/ubuntu/ focal-backports main restricted universe multiverse" >> /etc/apt/sources.list'
echo ">>>>>>>>>Apt update"
sudo -S apt-get -q update
echo ">>>>>>>>>Installing gnupg2"
sudo -S apt-get -q install gnupg2
echo ">>>>>>>>>Adding apt-key"
sudo -S -s eval 'wget -O - http://yansi.hmb.gov.tr/repo/ACCC4CF8.asc | apt-key add -'
echo ">>>>>>>>>Adding pgdg to sources.list"
sudo -S -s eval 'echo "deb http://yansi.hmb.gov.tr/pgdg/pub/repos/apt focal-pgdg main" >> /etc/apt/sources.list'
