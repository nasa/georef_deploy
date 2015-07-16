#!/bin/sh
set -o verbose

# capture git info from host to make it available in guest
egrep '\[user\]|email = |name = |\[push\]|default = simple' $HOME/.gitconfig > etc/gitconfig

vagrant up --no-provision

# the first time we run the setup script, we need to do it from within a
# 'vagrant ssh' session, so there is an interactive pty that allows you
# to type your password during 'git clone' operations. after that,
# 'vagrant provision' can be used.
vagrant ssh -c 'python /vagrant/setup_site.py'

