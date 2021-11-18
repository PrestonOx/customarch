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

sectorsize=`fdisk -l | head -n 3 | grep Units: | awk {'print $6'}`
diskname=`fdisk -l | head -n 1 | awk {'print $2'} |sed 's/.$//'`

sizeboot=$((250000000  / $sectorsize))
disksize=`fdisk -l | head -n 1 | awk {'print $5'}`
ramsize=`free -b | grep Mem: | awk {'print $2'}`
firststart='2048'
fstart=$(($sizeboot + $firststart))
secramsize=$(($ramsize / $sectorsize))
secdisksize=$(($disksize / $sectorsize))
secdiska=$(($secdisksize - $secramsize - $sizeboot))
secdiskroot=$(($secdiska / 2))
secdiskhome=$(($secdiskroot - $firststart))
secstarts=$(($secramsize + $fstart))
secstartt=$(($secstarts + $secdiskroot))

#Redirection vers le fichier my.layout

echo "label: dos" > my.layout
echo "device: $diskname" >> my.layout
echo "unit: sectors" >> my.layout
echo "sector-size: $sectorsize" >> my.layout
echo ""$diskname"1 : start= $firststart, size= $sizeboot, type=83, bootable" >> my.layout
echo ""$diskname"2 : start= $fstart, size= $secramsize, type=82" >> my.layout
echo ""$diskname"3 : start= $secstarts, size= $secdiskroot, type=83" >> my.layout
echo ""$diskname"4 : start= $secstartt, size= $secdiskhome, type=83" >> my.layout

sfdisk $diskname < my.layout

#Formatage des partitions precedemment creees

mkfs.ext4 "$diskname"1
mkfs.ext4 "$diskname"2
mkfs.ext4 "$diskname"3
mkfs.ext4 "$diskname"4

mkswap "$diskname"2

#Montage de nos partitions

mount "$diskname"3 /mnt

mkdir /mnt/home
mkdir /mnt/boot


mount "$diskname"4 /mnt/home
mount "$diskname"1 /mnt/boot

#Activation de la partition SWAP
swapon "$diskname"2

#Installation des paquets
pacstrap /mnt base linux linux-firmware

#FSTAB
genfstab -U /mnt >> /mnt/etc/fstab

cp install_archlinux_part2.sh /mnt/install_archlinux_part2.sh
arch-chroot /mnt ./install_archlinux_part2.sh
reboot
