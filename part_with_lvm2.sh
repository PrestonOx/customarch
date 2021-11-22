#!/bin/bash

sectorsize=`fdisk -l | head -n 3 | grep Units: | awk {'print $6'}`
diskname=`fdisk -l | head -n 1 | awk {'print $2'} |sed 's/.$//'`

#sizeboot=$((250000000  / $sectorsize))
sizeboot=$((512000000  / $sectorsize))
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
secdiskavailable=$(($secdiskav - $firststart))
#Redirection vers le fichier my.layout

lastsector=`fdisk -l | head -n 1 | awk {'print $7'}`
sizefor2=$(($lastsector - $fstart - 34))
last_lba=$(($lastsector - 34))

echo "label: gpt" > my.layout
echo "device: $diskname" >> my.layout
echo "unit: sectors" >> my.layout
echo "first-lba: 2048" >> my.layout
echo "last-lba: $last_lba" >> my.layout
echo "sector-size: $sectorsize" >> my.layout
echo ""$diskname"1 : start= $firststart, size= $sizeboot, type= C12A7328-F81F-11D2-BA4B-00A0C93EC93B" >> my.layout
echo ""$diskname"2 : start= $fstart, size= $sizefor2, type= 0FC63DAF-8483-4772-8E79-3D69D8477DE4" >> my.layout

sfdisk $diskname < my.layout

#Z'est barti pour le LVM

pvcreate ""$diskname"2"

vgcreate VolGroup1 ""$diskname"2"

lvcreate -L "$ramsize"B VolGroup1 -n lvswap
lvcreate -l 50%FREE VolGroup1 -n lvolroot
lvcreate -l 50%FREE VolGroup1 -n lvolhome

#Formatage de nos volumes logiques (ainsi que de la partition primaire "boot")

mkfs.fat -F32 /dev/""$diskname"1"
mkfs.ext4 /dev/VolGroup1/lvswap
mkfs.ext4 /dev/VolGroup1/lvolroot
mkfs.ext4 /dev/VolGroup1/lvolhome

mkswap /dev/VolGroup1/lvswap
swapon /dev/VolGroup1/lvswap

mount /dev/VolGroup1/lvolroot /mnt
mkdir /mnt/home
mount /dev/VolGroup1/lvolhome /mnt/home
mkdir /mnt/boot
mount /dev/"$diskname"1 /mnt/boot

#Installation des paquets
pacstrap /mnt base base-devel linux linux-firmware efibootmgr vim nano dhcpcd man-db
