#!/bin/bash

diskname=`fdisk -l | head -n 1 | awk {'print $2'} |sed 's/.$//'`

#Installation de quelques paquets essentiels
pacman -S --noconfirm vim nano
pacman -S --noconfirm dhcpcd


ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc

#Localization


echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_EN.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=fr_FR.UTF-8" >> /etc/locale.conf
echo "KEYMAP=fr-latin1" >> /etc/vconsole.conf

#Hostname

echo "generichostname" >> /etc/hostname
mkinitcpio -P

#Definir un mot de passe root
echo -e "testdeploy\ntestdeploy" | passwd

#Install GRUB
pacman -S --noconfirm grub
grub-install --target=i386-pc --recheck $diskname
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable dhcpcd

#Redemarrage
exit
