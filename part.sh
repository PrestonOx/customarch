#!/bin/bash

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