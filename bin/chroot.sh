#!/bin/bash

PACKAGES="
app-admin/metalog
app-admin/superadduser
app-editors/vim
app-misc/neofetch
app-misc/screen
app-misc/uptimed
app-portage/genlop
app-portage/gentoolkit
app-text/sloccount
app-text/wgetpaste
dev-debug/gdb
dev-vcs/git
net-analyzer/nmap
net-misc/ntp
sys-apps/hdparm
sys-apps/ripgrep
sys-devel/clang
sys-process/cronie
sys-process/htop
"

HOSTNAME=bespoke
TIMEZONE=EST5EDT
OPTS="-j50 --load-average 100"

prepare() {
	# Update the portage tree
	emerge-webrsync
	# Set the locale
	echo en_US.UTF-8 UTF-8 >> /etc/locale.gen
	# Set the timezone
	echo ${TIMEZONE} > /etc/timezone
	emerge --config sys-libs/timezone-data
	# Set the hostname
	echo ${HOSTNAME} > /etc/hostname
}

compile() {
	export EMERGE_DEFAULT_OPTS="$OPTS"
	export MAKEOPTS="$OPTS"
	emerge -e ${PACKAGES}
}

post_inst() {
	rc-update add cronie default
	rc-update add metalog default
	rc-update add ntpd default
	rc-update add sshd default
	rc-update add uptimed default
}

prepare
compile
post_inst
