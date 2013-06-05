
#!/bin/bash
# Author:     Valentin Klinghammer <vk@quelltextfabrik.de>
# Created:    05.06.2013
# ------------------------------------------------------------
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
# ------------------------------------------------------------

# --- Update the system -------------------------------------------------------
# -----------------------------------------------------------------------------
sudo apt-get update
sudo apt-get upgrade -y

# --- Install and configure helpers -------------------------------------------
# --- Install build dependencies
sudo apt-get install -y build-essential git-core cmake

# --- Install Curl
sudo apt-get install -y curl

# --- Install software --------------------------------------------------------
# -----------------------------------------------------------------------------
# --- Install Ruby and Gems ---------------------------------------------------
# --- Fetch and install RVM
# Install Ruby 2.0 with dev headers
# Install latest Rails
\curl -L https://get.rvm.io | bash -s stable --ruby=2.0.0-dev --rails
echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"' >> "$HOME"/.bashrc
source "$HOME"/.bashrc
# TODO otherwise we get errors when installing gems
rvm get stable

# --- Install Middleman Gem (which includes SASS)
gem install middleman
# TODO get our middleman templates

# --- Install homesick
gem install homesick

# --- Install other dev software ---------------------------------------------
# --- Install TMUX
sudo apt-get install tmux

# --- Install Guake
sudo apt-get install guake
# TODO add to auto start
# TODO config

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
make VIMRUNTIMEDIR=/usr/share/vim/vim73
sudo make install

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
# TODO mod rewrite
# TODO mod vhost alias
# TODO mass vhost config
sudo apt-get install -y phpmyadmin

# --- Configure dns for QTF
# Install dnsmasq
sudo apt-get install -y dnsmasq
sudo echo "address=/localhost/127.0.0.1" > /etc/dnsmasq.d/localhost
sudo /etc/init.d/dnsmasq restart

# Set dnsmasq as default DNS
# TODO the config folder is different for Ubuntu (dhcp3) and Linux Mint (dhcp)
# This should ideally be autodected, default to Mint for now
sudo echo "prepend domain-name-servers 127.0.0.1;" >> /etc/dhcp/dhclient.conf

# --- Other tools
sudo apt-get install -y htop skype filezilla gimp

# --- Configure --------------------------------------------------------------
# --- Dotfile repo
homesick clone Gorgoroth/dotfiles
homesick symlink -f Gorgoroth/dotfiles

# --- QTF specific ------------------------------------------------------------
# -----------------------------------------------------------------------------
# --- Create our folder structure
mkdir -p "~/Quelltextfabrik/Apps"
mkdir -p "~/Quelltextfabrik/Web"
mkdir -p "~/Quelltextfabrik/tmp"
