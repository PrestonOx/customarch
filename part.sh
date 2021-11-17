#!/bin/bash

sectorsize=`fdisk -l | head -n 3 | grep Units: | awk {'print $6'}`
diskname=`fdisk -l | head -n 1 | awk {'print $2'} |sed 's/.$//'`

sizeboot=$((250000000  / $sectorsize))
disksize=`fdisk -l | head -n 1 | awk {'print $5'}`
ramsize=`free -b | grep Mem: | awk {'print $2'}`
firststart='2048'
#framsize=$(($ramsize / $sectorsize))
fstart=$(($sizeboot + $firststart))
secramsize=$(($ramsize / $sectorsize))
secdisksize=$(($disksize / $sectorsize))
secdiska=$(($secdisksize - $secramsize - $sizeboot))
secdiskroot=$(($secdiska / 2))
secdiskhome=$(($secdiskroot - $firststart))
secstarts=$(($secramsize + $fstart))
secstartt=$(($secstarts + $secdiskroot))

echo $ramsize
echo $secramsize
echo $fstart

echo "label: dos" > my.layout
#echo "device: /dev/sda" >> my.layout
echo "device: $diskname" >> my.layout
echo "unit: sectors" >> my.layout
#echo "sector-size: 512" >> my.layout
echo "sector-size: $sectorsize" >> my.layout
echo "/dev/sda1 : start= $firststart, size= $sizeboot, type=83, bootable" >> my.layout
echo "/dev/sda2 : start= $fstart, size= $secramsize, type=82" >> my.layout
echo "/dev/sda3 : start= $secstarts, size= $secdiskroot, type=83" >> my.layout
echo "/dev/sda4 : start= $secstartt, size= $secdiskhome, type=83" >> my.layout
