#!/bin/bash

disksize=`fdisk -l | head -n 1 | awk {'print $5'}`
diska=$(($disksize - $ramsize - 262144000))
secdiska=$(($diska / 512))
secdiskroot=$(($secdiska / 2))
ramsize=`free -b | grep Mem: | awk {'print $2'}`
sramsize=$(($ramsize / 512))
secstarts=$(($sramsize + 514048))
secstartt=$(($secstarts + $secdiskroot))

#echo $disksize
#echo $diska
#echo $diskroot
#echo
#echo
#echo $startf
#echo $starts
#echo $startt

echo "label: dos" > my.layout
echo "device: /dev/sda" >> my.layout
echo "unit: sectors" >> my.layout
echo "sector-size: 512" >> my.layout
echo "/dev/sda1 : start= 2048, size= 512000, type=83, bootable" >> my.layout
echo "/dev/sda2 : start= 514048, size= $sramsize, type=82" >> my.layout
echo "/dev/sda3 : start= $secstarts, size= $secdiskroot, type=83" >> my.layout
echo "/dev/sda4 : start= $secstartt, size= $secdiskroot, type=83" >> my.layout
