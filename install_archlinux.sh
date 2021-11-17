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

cp install_archlinux_part2.sh /mnt/install_archlinux_part2.sh
arch-chroot /mnt ./install_archlinux_part2.sh
reboot
