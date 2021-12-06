#!/bin/bash
#Dernière ligne droite

ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc

#Localization


#echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen
#echo "en_EN.UTF-8 UTF-8" >> /etc/locale.gen
sed -i 's/#fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/#en_EN.UTF-8 UTF-8/en_EN.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo "LANG=fr_FR.UTF-8" >> /etc/locale.conf
echo "KEYMAP=fr" >> /etc/vconsole.conf

#Hostname

echo "generichostname" >> /etc/hostname

#mkinitcpio (rajouter les hooks essentiels)

sed -ire 's/block/block lvm2/g' /etc/mkinitcpio.conf
sed -ire 's/keyboard/keyboard keymap/g' /etc/mkinitcpio.conf

mkinitcpio -P

#Definir un mot de passe root
echo -e "testdeploy\ntestdeploy" | passwd

#Install GRUB
pacman -S --noconfirm grub
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable dhcpcd
systemctl enable sshd
systemctl enable docker

#Redemarrage
exit
