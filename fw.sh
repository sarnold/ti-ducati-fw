#!/bin/bash

TCGARMVERSION=5.2.7

GCC=no # GCC not supported yet, still issues with memory regions while linking

ZIP=`zip -v 2> /dev/null`
WGET=`wget --version 2> /dev/null`

if [ "$ZIP" == "" ]; then
    echo "Error: Missing zip tool!"
    exit 0
fi

if [ "$WGET" == "" ]; then
    echo "Error: Missing wget tool!"
    exit 0
fi

BASE_ROOT=`pwd`
BUILD_DIR=${BASE_ROOT}/sources

mkdir -f ${BUILD_DIR} 2> /dev/null

if [ ! -e ${BUILD_DIR}/bios ]; then
	git clone git://github.com/mobiaqua/ti-sysbios.git ${BUILD_DIR}/bios
	cd ${BUILD_DIR}/bios
else
	cd ${BUILD_DIR}/bios
	git pull
fi

if [ ! -e ${BUILD_DIR}/ce ]; then
	git clone git://github.com/mobiaqua/ti-ce.git ${BUILD_DIR}/ce
	cd ${BUILD_DIR}/ce
else
	cd ${BUILD_DIR}/ce
	git pull
fi

if [ ! -e ${BUILD_DIR}/fc ]; then
	git clone git://github.com/mobiaqua/ti-fc.git ${BUILD_DIR}/fc
	cd ${BUILD_DIR}/fc
else
	cd ${BUILD_DIR}/fc
	git pull
fi

if [ ! -e ${BUILD_DIR}/ipc ]; then
	git clone git://github.com/mobiaqua/ti-ipc1.git ${BUILD_DIR}/ipc
	cd ${BUILD_DIR}/ipc
else
	cd ${BUILD_DIR}/ipc
	git pull
fi

if [ ! -e ${BUILD_DIR}/osal ]; then
	git clone git://github.com/mobiaqua/ti-osal.git ${BUILD_DIR}/osal
	cd ${BUILD_DIR}/osal
else
	cd ${BUILD_DIR}/osal
	git pull
fi

if [ ! -e ${BUILD_DIR}/xdais ]; then
	git clone git://github.com/mobiaqua/ti-xdais.git ${BUILD_DIR}/xdais
	cd ${BUILD_DIR}/xdais
else
	cd ${BUILD_DIR}/xdais
	git pull
fi

if [ ! -e ${BUILD_DIR}/rpmsg ]; then
	git clone git://github.com/mobiaqua/ti-rpmsg.git ${BUILD_DIR}/rpmsg
	cd ${BUILD_DIR}/rpmsg
else
	cd ${BUILD_DIR}/rpmsg
	git pull
fi

if [ ! -e ${BUILD_DIR}/ipumm ]; then
	git clone git://github.com/mobiaqua/ti-ipumm-omap4.git ${BUILD_DIR}/ipumm
	cd ${BUILD_DIR}/ipumm
else
	cd ${BUILD_DIR}/ipumm
	git pull
fi

if [ ! -e ${BUILD_DIR}/codecs ]; then
	git clone git://github.com/mobiaqua/ti-codecs.git ${BUILD_DIR}/codecs
	cd ${BUILD_DIR}/codecs
else
	cd ${BUILD_DIR}/codecs
	git pull
fi

cd ${BUILD_DIR}

if [ ! -e ${BUILD_DIR}/xdc ]; then
	case `uname -s` in
	Darwin)
		wget http://software-dl.ti.com/dsps/dsps_public_sw/sdo_sb/targetcontent/rtsc/3_32_00_06/exports/xdccore/xdctools_3_32_00_06_core_macos.zip
		;;
	Linux)
		wget http://software-dl.ti.com/dsps/dsps_public_sw/sdo_sb/targetcontent/rtsc/3_32_00_06/exports/xdccore/xdctools_3_32_00_06_core_linux.zip
		;;
	esac
	unzip xdctools_*_core_*.zip
	rm -f *.zip
	mv xdctools_*_core xdc
fi

if [ ! -e ${BUILD_DIR}/armt ]; then
	case $GCC in
	yes)
		# TODO: original toolchain from site does not have needed libc lock changes.
		# it need to bo patched and rebuilded
		case `uname -s` in
		Darwin)
			wget https://launchpad.net/gcc-arm-embedded/4.8/4.8-2014-q3-update/+download/gcc-arm-none-eabi-4_8-2014q3-20140805-mac.tar.bz2
#			wget https://launchpad.net/gcc-arm-embedded/4.7/4.7-2013-q3-update/+download/gcc-arm-none-eabi-4_7-2013q3-20130916-mac.tar.bz2
			;;
		Linux)
			wget https://launchpad.net/gcc-arm-embedded/4.8/4.8-2014-q3-update/+download/gcc-arm-none-eabi-4_8-2014q3-20140805-linux.tar.bz2
#			wget https://launchpad.net/gcc-arm-embedded/4.7/4.7-2013-q3-update/+download/gcc-arm-none-eabi-4_7-2013q3-20130916-linux.tar.bz2
			;;
		esac
		tar xjvf gcc-arm-none-eabi-4*.tar.bz2
		rm -f *.bz2
		mv gcc-arm-none-eabi-4_* armt
		;;
	*)
		case `uname -s` in
		Darwin)
			wget http://software-dl.ti.com/dsps/dsps_public_sw/sdo_ccstudio/codegen/Updates/p2mac/binary/com.ti.cgt.tms470.5.2.mac_root_${TCGARMVERSION} -O ti_cgt_tms470_${TCGARMVERSION}_osx_installer.zip
			unzip ti_cgt_tms470*.zip
			chmod +x downloads/ti_cgt_tms470_*_osx_installer.app/Contents/MacOS/osx-intel
			downloads/ti_cgt_tms470_*_osx_installer.app/Contents/MacOS/osx-intel --mode unattended
			rm -rf downloads
			mv ti-cgt-arm_* armt
			rm -f *.zip
			;;
		Linux)
			wget http://software-dl.ti.com/dsps/dsps_public_sw/sdo_ccstudio/codegen/Updates/p2linux/binary/com.ti.cgt.tms470.5.2.linux_root_${TCGARMVERSION} -O ti_cgt_tms470_${TCGARMVERSION}_linux_installer_x86.zip
			unzip ti_cgt_tms470*.zip
			chmod +x downloads/*.bin
			downloads/ti_cgt_tms470_*_linux_installer_x86.bin --mode unattended
			rm -rf downloads
			mv ti-cgt-arm_* armt
			rm -f *.zip
			;;
		esac
		;;
	esac
fi

cd ${BASE_ROOT}

case $GCC in
	yes)
		TARGET=gnu.targets.arm.M3
		;;
	*)
		TARGET=ti.targets.arm.elf.M3
		;;
esac

make TARGET=${TARGET} all
