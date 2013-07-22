#!/bin/bash
# Author:     Valentin Klinghammer <vk@quelltextfabrik.de>
# Created:    05.06.2013
# ----------------------------------------------------------------------------
#
# Purpose:
# This script is to be run on new dev PCs to ensure that the
# same toolset is available.
#
# Requirements:
# * Up-and-running Ubuntu installation on the dev machine
# * This script on that dev machine
# * Username is set to localpart of QTF mail address
# * Full name is set
#
# ----------------------------------------------------------------------------

# --- Update the system ------------------------------------------------------
# ----------------------------------------------------------------------------
sudo apt-get update
sudo apt-get upgrade -y

# --- Install and configure helpers ------------------------------------------
# --- Install build dependencies and tools
sudo apt-get install -y build-essential git-core cmake curl

# --- Install software -------------------------------------------------------
# ----------------------------------------------------------------------------
# --- Install Ruby and Gems --------------------------------------------------
# --- Fetch and install RVM
# Install Ruby 2.0 with dev headers
# Install latest Rails
\curl -L https://get.rvm.io | bash -s stable --ruby=2.0.0-dev --rails
echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"' >> "$HOME"/.bashrc
source "$HOME"/.bashrc
# TODO otherwise we get errors when installing gems, find out why
rvm get stable

# --- Install Middleman Gem (which includes SASS)
gem install middleman

# --- Install homesick
gem install homesick

# --- Install desktop environment --------------------------------------------
# ----------------------------------------------------------------------------
sudo apt-get -y install xorg-server xorg-utils

# TODO install latest i3
sudo apt-get -y install conky dmenu feh
# TODO install pretty fonts
# TODO install pretty mouse pointers
# TODO install vifm and a lightweight x manager
sudo apt-get install dmz-cursor-theme
sudo apt-get -y install rxvt-unicode-256color
# TODO clipboard tweak with autocutsel
# TODO audioplayer, console or other

# --- Install other dev software ---------------------------------------------
# --- Install latest VIM after compiling from source
sudo apt-get -y install libncurses5-dev libgnome2-dev libgnomeui-dev libgtk2.0-dev libatk1.0-dev libbonoboui2-dev libcairo2-dev libx11-dev libxpm-dev libxt-dev python-dev ruby-dev mercurial
sudo apt-get -y remove vim vim-runtime gvim
sudo apt-get -y remove vim-tiny vim-common vim-gui-common
hg clone https://code.google.com/p/vim/
cd vim
./configure --with-features=huge \
  --enable-rubyinterp \
  --enable-pythoninterp \
  --enable-perlinterp \
  --enable-gui=gtk2 --enable-cscope --prefix=/usr
# TODO is there a way to configure the runetime dir automatically? Got problems with this script when vim changed from 73 to 74a
make VIMRUNTIMEDIR=/usr/share/vim/vim74a
sudo make install
rm -rf vim

# --- Install Google Chrome
curl -LO https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb

# --- Install Dropbox
sudo apt-get install python-gpgme
curl -LO https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_1.6.0_amd64.deb
sudo dpkg -i dropbox_1.6.0_amd64.deb
rm dropbox_1.6.0_amd64.deb

# --- Install LAMP
# This runs interactively and allows the user to specify a mysql root pw
sudo apt-get install -y tasksel
sudo tasksel install lamp-server
sudo a2enmod rewrite
# Configure mass virtual hosts, so we can use project.localhost for development
sudo a2enmod vhost_alias
sudo curl -Lo /etc/apache2/sites-enabled/vhosts-vk https://github.com/Gorgoroth/Ubutuntu-Setup/raw/master/vhosts-vk
sudo apt-get install -y phpmyadmin

# --- Configure dns for QTF
# Install dnsmasq
sudo apt-get install -y dnsmasq
sudo sh -c 'echo "address=/localhost/127.0.0.1" > /etc/dnsmasq.d/localhost'
sudo /etc/init.d/dnsmasq restart

# Set dnsmasq as default DNS
# TODO the config folder is different for Ubuntu (dhcp3) and Linux Mint (dhcp)
# This should ideally be autodected, default to Mint for now
sudo sh -c "echo 'prepend domain-name-servers 127.0.0.1;' >> /etc/dhcp/dhclient.conf"

# TODO Install PostgresQL

# --- Other tools
sudo apt-get install -y htop skype filezilla gimp virtualbox

# --- Configure --------------------------------------------------------------
# --- Dotfile repo
# homesick clone Gorgoroth/dotfiles
# homesick symlink Gorgoroth/dotfiles --force=FORCE
# TODO Homesick needs to be finetuned before its ready, for now only download important files
wget https://raw.github.com/Gorgoroth/dotfiles/master/home/.vimrc

# --- QTF specific -----------------------------------------------------------
# ----------------------------------------------------------------------------
# Generate SSH key and deploy to important servers
ssh-keygen -f id_rsa -t rsa -N ''
sleep 10
ssh-copy-id -i ~/.ssh/id_rsa.pub admin@qtf.selfhost.de
ssh-copy-id -i ~/.ssh/id_rsa.pub root@87.106.53.203

# Prompt to add key to Gitlab
echo 'Add this public key to your Gitlab (and Github) account'
cat ~/.ssh/id_rsa.pub

# TODO Get our middleman templates after SSH key has been added to Gitlab

# TODO Add self-signed certificate to Chrome
sudo apt-get install libnss3-tools
# openssl s_client -connect gitlab.quelltextfabrik.de:1337 -showcerts > gitlab.crt
# certutil -d sql:$HOME/.pki/nssdb -A -t CP,,C -n "gitlab.quelltextfabrik.de" -i gitlab.crt
# rm gitlab.crt

# --- Create our folder structure
mkdir -p "~/Quelltextfabrik/Apps"
mkdir -p "~/Quelltextfabrik/Web"
mkdir -p "~/Quelltextfabrik/tmp"

# --- Restart the machine for good measure
# TODO prompt for reboot
# sudo reboot
