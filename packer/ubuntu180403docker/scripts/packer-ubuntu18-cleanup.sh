#!/bin/bash -eu

# Original source: https://github.com/heizo/packer-ubuntu-18.04/blob/master/script/update.sh

echo "==> Disabling apt.daily.service & apt-daily-upgrade.service"
sudo systemctl stop apt-daily.timer apt-daily-upgrade.timer
sudo systemctl mask apt-daily.timer apt-daily-upgrade.timer
sudo systemctl stop apt-daily.service apt-daily-upgrade.service
sudo systemctl mask apt-daily.service apt-daily-upgrade.service
sudo systemctl daemon-reload

# Disable the release upgrader
#echo "==> Disabling the release upgrader"
#sed -i 's/^Prompt=.*$/Prompt=never/' /etc/update-manager/release-upgrades
echo "==> Removing the release upgrader"
sudo apt-get -y purge ubuntu-release-upgrader-core
sudo rm -rf /var/lib/ubuntu-release-upgrader
sudo rm -rf /var/lib/update-manager

# Clean up the apt cache
sudo apt-get -y autoremove --purge
sudo apt-get -y clean

# Remove grub timeout and splash screen
sudo sed -i -e '/^GRUB_TIMEOUT=/aGRUB_RECORDFAIL_TIMEOUT=0' \
    -e 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet nosplash"/' \
    /etc/default/grub
sudo update-grub
