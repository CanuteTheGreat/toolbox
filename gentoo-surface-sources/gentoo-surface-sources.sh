#!/bin/bash

# This script will get the latest kernel sources (git) from upstream, the linux surface sources patch set, and the gentoo sources patchset, and apply all the patches to create a gentoo-surface-sources source tree

current_kernel_version=`curl -s https://kernel.org/ | grep -C1 latest_link | grep http | sed 's/<a href="//' | sed 's/.*">//' | sed 's/<\/a>//'`
#current_kernel_version=5.16.11

current_kernel_version_major=`echo $current_kernel_version | sed 's/.*">//' | sed 's/<\/a>//' | rev | sed '/\..*\./s/^[^.]*\.//' | rev`

gentoo_patch_url=dev.gentoo.org/~mpagano/genpatches/trunk

echo "Getting Gentoo patches"
wget -q -t0 -c --mirror --level=1 https://$gentoo_patch_url/$current_kernel_version_major/
echo "Getting kernel"
git clone --depth 1 --branch v$current_kernel_version git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
echo "Getting surface sources (patches)"
git clone https://github.com/linux-surface/linux-surface.git 
mv linux gentoo-surface-sources-$current_kernel_version
echo "Getting ready to patch"
cd gentoo-surface-sources-$current_kernel_version
echo "Patching"
for patch in `ls -1 ../linux-surface/patches/$current_kernel_version_major/` 
do
	git am ../linux-surface/patches/$current_kernel_version_major/$patch
done
echo "Applying Gentoo patches"
for patch in `ls -1 ../$gentoo_patch_url/$current_kernel_version_major/*.patch|grep -v linux-$current_kernel_version_major`
do
	patch -p1 < $patch
done
echo "Cleaning up"
cd ..
rm -rf linux-surface
rm -rf dev.gentoo.org
echo "done!"

