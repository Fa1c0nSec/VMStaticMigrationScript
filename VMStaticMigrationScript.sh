#!/bin/bash
# - License: GPL v3.
read -p "Please Input Domain Name to Migrate: " -s domainName
cd ~/
echo Preparing VMs basic files, please wait...
mkdir $domainName > /dev/null
virsh dumpxml $domainName >  ~/$domainName/$domainName.xml

qcow2=$(virsh dumpxml $domainName | grep qcow2 | grep file | sed "s/'/#/g" | sed "s/'/#/g" | sed -r 's/.*#(.*)#.*/\1/')

if [ $qcow2=='' ]
then
     img=$(virsh dumpxml $domainName | grep img | grep file | sed "s/'/#/g" | sed "s/'/#/g" | sed -r 's/.*#(.*)#.*/\1/')
fi

if [ $qcow2=='' ]
then
     raw=$(virsh dumpxml $domainName | grep raw | grep file | sed "s/'/#/g" | sed "s/'/#/g" | sed -r 's/.*#(.*)#.*/\1/')
fi

if [ -n "$qcow2" ]
then
        cp $qcow2 ~/$domainName/
elif [ -n "$img" ]
then
        cp $img ~/$domainName/
elif [ -n "$raw" ]
then
        cp $raw ~/$domainName/
else
        echo $domainName is not exist. Please check again.
fi
echo VM Files Preparing finished.
read -p "Please Input The Remote Host IP: " -s remotehostIP
read -p "Please Input Remote Host Username: " -s remotehostUsername
echo If needed, you need to input remoteHost user password.
dircreate="mkdir ~\/"$domainName
softinstall="sudo apt-get install libvirt-bin kvm qemu virtinst virt-manager virt-viewer"
vmregister="virsh define ~\/"$domainName"\/"$domainName".xml"
ssh -t -p 22 $remotehostUsername@$remotehostIP $dircreate
scp ~/$domainName/* $remotehostUsername@$remotehostIP:~/$domainName
echo Register Remote Host VMs...
ssh -t -p 22 $remotehostUsername@$remotehostIP $softinstall
ssh -t -p 22 $remotehostUsername@$remotehostIP $vmregister
echo VMs Static Migration Finished.

