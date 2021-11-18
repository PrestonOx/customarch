#!/bin/bash

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
secdiskav=$(($secdisksize - $sizeboot))

#Redirection vers le fichier my.layout

echo "label: dos" > my.layout
echo "device: $diskname" >> my.layout
echo "unit: sectors" >> my.layout
echo "sector-size: $sectorsize" >> my.layout
echo ""$diskname"1 : start= $firststart, size= $sizeboot, type=83, bootable" >> my.layout
echo ""$diskname"2 : start= $fstart, size= $secdiskav, type=8e" >> my.layout

sfdisk $diskname < my.layout

#Z'est barti pour le LVM

pvcreate ""$diskname"2"

vgcreate VolGroup1 ""$diskname"2"

lvcreate -L "$ramsize"B VolGroup1 -n lvswap
lvcreate -l 50%FREE VolGroup1 -n lvolroot
lvcreate -l 50%FREE VolGroup1 -n lvolhome

#Optionnel ???
#modprobe dm_mod
#vgscan
#vgchange -ay

#Formatage de nos volumes logiques (ainsi que de la partition primaire "boot")

mkfs.ext4 /dev/"$diskname"1
mkfs.ext4 /dev/VolGroup1/lvswap
mkfs.ext4 /dev/VolGroup1/lvolroot
mkfs.ext4 /dev/VolGroup1/lvolhome

mkswap /dev/VolGroup1/lvswap

mount /dev/VolGroup1/lvolroot /mnt
mkdir /mnt/home
mkdir /mnt/boot

mount /dev/"$diskname"1 /mnt/boot
mount /dev/VolGroup1/lvolhome

swapon /dev/VolGroup1/lvswap




