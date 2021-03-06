################################################################################
#      This file is part of OpenELEC - http://www.openelec.tv
#      Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
#
#  This Program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2, or (at your option)
#  any later version.
#
#  This Program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with OpenELEC.tv; see the file COPYING.  If not, write to
#  the Free Software Foundation, 51 Franklin Street, Suite 500, Boston, MA 02110, USA.
#  http://www.gnu.org/copyleft/gpl.html
################################################################################

PKG_NAME="media_build_experimental"
PKG_VERSION="6b80c0903403"
MEDIA_BUILD_VERSION="2014-06-09"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="http://linuxtv.org/hg/~endriss/media_build_experimental"
#PKG_URL="$DISTRO_SRC/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_URL="192.168.178.2/media_build_experimental.tar.xz"
PKG_DEPENDS_TARGET=""
PKG_BUILD_DEPENDS_TARGET="toolchain linux"
PKG_PRIORITY="optional"
PKG_SECTION="driver"
PKG_SHORTDESC="Build system to use the latest experimental drivers/patches without needing to replace the entire Kernel"
PKG_LONGDESC="Build system to use the latest experimental drivers/patches without needing to replace the entire Kernel"
PKG_IS_ADDON="no"
PKG_AUTORECONF="no"

pre_make_target() {
  export KERNEL_VER=$(get_module_dir)
  # dont use our LDFLAGS, use the KERNEL LDFLAGS
  export LDFLAGS=""
}

make_target() {
  wget http://www.linuxtv.org/downloads/firmware/dvb-firmwares.tar.bz2 -O dvb-firmwares.tar.bz2.tmp
  cd v4l/firmware/; tar xvfj ../../dvb-firmwares.tar.bz2.tmp
  cd ../..
  #$SED -i  -e "/^LATEST_TAR/s/-LATEST/-$MEDIA_BUILD_VERSION/g" linux/Makefile

read -s -n 1 -p "going to SED... Press any key to continue..."

#sed -i "/.scripts\/rmmod.pl check/s/^\(.*\)/#\1/" v4l/Makefile

read -s -n 1 -p "check Makefile... Press any key to continue..."

cat >v4l/.config << EOF
CONFIG_DVB_CORE=m
CONFIG_DVB_CXD2099=m
CONFIG_DVB_DRXK=m
CONFIG_DVB_TDA18271C2DD=m
CONFIG_DVB_DDBRIDGE=m

EOF

#cat >v4l/.version << EOF
#VERSION=3
#PATCHLEVEL:=15
#SUBLEVEL:=1
#KERNELRELEASE:=3.15.1
#EOF

read -s -n 1 -p "going to make 1... Press any key to continue..."

  make  VER=$KERNEL_VER SRCDIR=$(kernel_path) -C linux/ download 
  make VER=$KERNEL_VER SRCDIR=$(kernel_path) -C linux/ untar 
  #make VER=$KERNEL_VER SRCDIR=$(kernel_path) allyesconfig
read -s -n 1 -p "going to make... Press any key to continue..."

  make VER=$KERNEL_VER SRCDIR=$(kernel_path) >$HOME/make.txt
}

makeinstall_target() {
  mkdir -p $INSTALL/lib/modules/$KERNEL_VER/updates/media_build

read -s -n 1 -p "going to strip modules... Press any key to continue..."

  find $ROOT/$PKG_BUILD/v4l/ -name \*.ko -exec strip --strip-debug {} \;
  find $ROOT/$PKG_BUILD/v4l/ -name \*.ko -exec cp {} $INSTALL/lib/modules/$KERNEL_VER/updates/media_build_experimental \;

  mkdir -p $INSTALL/lib/firmware/
  cp $ROOT/$PKG_BUILD/v4l/firmware/*.fw $INSTALL/lib/firmware/
}
