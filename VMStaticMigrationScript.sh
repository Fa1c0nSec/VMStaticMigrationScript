#!/bin/bash
echo "========================================================"
echo "============ VM Static Domain Migration Script ========="
echo "========================================================"
echo "==== Powered and Maintaince By Fa1c0n(i@fa1c0n.com). ==="
echo "========================================================"
read -p "Please Input Domain Name to Migrate: " -s domainName
echo "========================================================\n"
cd ~/
echo Preparing VMs basic files, please wait...
echo "========================================================\n"
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
echo "VM Files Preparing finished."
echo "====================================================="
read -p "Please Input The Remote Host IP: " -s remotehostIP
echo "====================================================="
read -p "Please Input Remote Host Username: " -s remotehostUsername
echo "====================================================="
echo If needed, you need to input remoteHost user password.
echo "====================================================="
dircreate="sudo mkdir \/usr\/local\/"$domainName
dirpriv="sudo chmod -R 777 \/usr\/local\/"$domainName
softinstall="sudo apt-get install libvirt-bin kvm qemu virtinst virt-manager virt-viewer"
vmregister="sudo virsh define \/usr\/local\/"$domainName"\/"$domainName".xml"
ssh -t -p 22 $remotehostUsername@$remotehostIP $dircreate
ssh -t -p 22 $remotehostUsername@$remotehostIP $dirpriv
scp ~/$domainName/* $remotehostUsername@$remotehostIP:/usr/local/$domainName
echo "====================================================="
echo "===== Register Remote Host VMs... "
echo "====================================================="
ssh -t -p 22 $remotehostUsername@$remotehostIP $softinstall
ssh -t -p 22 $remotehostUsername@$remotehostIP $vmregister
echo "====================================================="
echo "===== VMs Static Migration Finished. Enjoy!"
echo "===== Maintaince: Fa1c0n. +(86)156-7027-2720"
echo "===== License: GPL v2 Free Software"
echo "====================================================="


