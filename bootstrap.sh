#!/bin/bash
# Bootstrap
# By Jesse Collier <jessecollier@gmail.com>
# November 15th, 2013

# This script assumes the following
# - You are running ubuntu
# - Your base image includes a cronjob 
#   that downloads and executes this bootstrap

if [ ! -a /etc/cron.d/bootstrap ]; then
    logger "[$$] [$0] exiting... already bootstrapped"
fi

logger "[$$] [$0] bootstrapping. Hang on..."

# Upgrade system to latest
logger "[$$] [$0] upgrade system"
apt-get update 
apt-get upgrade -y
logger "[$$] [$0] upgrade system complete"


# Install ruby+chef
logger "[$$] [$0] install ruby+chef"
sudo apt-get install ruby1.9.1 ruby1.9.1-dev \
  rubygems1.9.1 irb1.9.1 ri1.9.1 rdoc1.9.1 \
  build-essential libopenssl-ruby1.9.1 libssl-dev zlib1g-dev

sudo update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby1.9.1 400 \
         --slave   /usr/share/man/man1/ruby.1.gz ruby.1.gz \
                        /usr/share/man/man1/ruby1.9.1.1.gz \
        --slave   /usr/bin/ri ri /usr/bin/ri1.9.1 \
        --slave   /usr/bin/irb irb /usr/bin/irb1.9.1 \
        --slave   /usr/bin/rdoc rdoc /usr/bin/rdoc1.9.1

# choose your interpreter
# changes symlinks for /usr/bin/ruby , /usr/bin/gem
# /usr/bin/irb, /usr/bin/ri and man (1) ruby
sudo update-alternatives --config ruby
sudo update-alternatives --config gem

gem update --no-rdoc --no-ri
logger "[$$] [$0] ruby+chef installed"

# Set up berkshelf
logger "[$$] [$0] install bundler"
gem install bundler
logger "[$$] [$0] bundler installed"

# Install git
logger "[$$] [$0] install git"
apt-get install -y git
logger "[$$] [$0] git installed"

# Set up chef
logger "[$$] [$0] setting up chef"
mkdir /srv
cd /srv && git clone https://github.com/jessecollier/server-config.git
cd /srv/server-config && bundle install
cd /srv/server-config && berks install --path chef/cookbooks
chef-solo -c /srv/server-config/chef/config.rb
logger "[$$] [$0] chef complete"

logger "[$$] [$0] removing bootstrap"
rm /etc/cron.d/bootstrap