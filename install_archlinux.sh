#!/bin/bash

#Install ArchLinux
#Changement de langues, timezone...
loadkeys fr-latin1
timedatectl set-ntp true
timedatectl set-timezone Europe/Paris

#Partitionnement du disque
#Notes : Une partition pour /, une partition pour le boot, une partition pour /home et une
#derniere partition pour le SWAP
# /boot --> /dev/sda1 ; SWAP --> /dev/sda2 ; / --> /dev/sda3 ; /home --> /dev/sda4
disksize=`fdisk -l | head -n 1 | awk {'print $5'}`
ramsize=`free -b | grep Mem: | awk {'print $2'}`
secramsize=$(($ramsize / 512))
secdisksize=$(($disksize / 512))
secdiska=$(($secdisksize - $secramsize - 512000))
secdiskroot=$(($secdiska / 2))
secdiskhome=$(($secdiskroot - 2048))
secstarts=$(($secramsize + 514048))
secstartt=$(($secstarts + $secdiskroot))

echo "label: dos" > my.layout
echo "device: /dev/sda" >> my.layout
echo "unit: sectors" >> my.layout
echo "sector-size: 512" >> my.layout
echo "/dev/sda1 : start= 2048, size= 512000, type=83, bootable" >> my.layout
echo "/dev/sda2 : start= 514048, size= $secramsize, type=82" >> my.layout
echo "/dev/sda3 : start= $secstarts, size= $secdiskroot, type=83" >> my.layout
echo "/dev/sda4 : start= $secstartt, size= $secdiskhome, type=83" >> my.layout
sfdisk /dev/sda < my.layout

#Formatage des partitions precedemment creees
mkfs.ext4 /dev/sda1
mkfs.ext4 /dev/sda2
mkfs.ext4 /dev/sda3
mkfs.ext4 /dev/sda4

mkswap /dev/sda2

#Montage de nos partitions

mkdir /mnt/home
mkdir /mnt/boot

mount /dev/sda3 /mnt
mount /dev/sda4 /mnt/home
mount /dev/sda1 /mnt/boot

#Activation de la partition SWAP
swapon /dev/sda2

#Installation des paquets
pacstrap /mnt base linux linux-firmware

#FSTAB
genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt

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
grub-install --target=i386-pc --recheck /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg


#Redemarrage
exit
reboot
