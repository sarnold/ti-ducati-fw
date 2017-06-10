#!/bin/bash

fetch_repo() # directory, repo-url
{
	directory="${BUILD_DIR}/$1"
	url="$2"
	if [ "$1" != "" ] || [ "$2" != "" ]; then
		if [ ! -e ${directory} ]; then
			git clone ${url} ${directory}
			cd ${directory}
		else
			cd ${directory}
			git pull
		fi
		cd ${BASE_ROOT}
	else
		echo "fetch_repo(): Error: wrong arguments!"
		exit 1
	fi
}

check_tools()
{
	ZIP=`zip -v 2> /dev/null`
	WGET=`wget --version 2> /dev/null`

	if [ "$ZIP" == "" ]; then
		echo "Error: Missing zip tool!"
		exit 1
	fi

	if [ "$WGET" == "" ]; then
		echo "Error: Missing wget tool!"
		exit 1
	fi
}

prepare_xdc_tools()
{
	cd ${BUILD_DIR}
	if [ ! -e ${BUILD_DIR}/xdc ]; then
		case `uname -s` in
		Darwin)
			wget http://software-dl.ti.com/dsps/dsps_public_sw/sdo_sb/targetcontent/rtsc/${XDCCOREVERSION}/exports/xdccore/xdctools_${XDCCOREVERSION}_core_macos.zip
			;;
		Linux)
			wget http://software-dl.ti.com/dsps/dsps_public_sw/sdo_sb/targetcontent/rtsc/${XDCCOREVERSION}/exports/xdccore/xdctools_${XDCCOREVERSION}_core_linux.zip
		;;
		esac
		unzip xdctools_*_core_*.zip
		rm -f *.zip
		mv xdctools_*_core xdc
	fi
	cd ${BASE_ROOT}
}

prepare_arm_compiler()
{
	cd ${BUILD_DIR}
	if [ ! -e ${BUILD_DIR}/armt ]; then
		case $GCC in
		yes)
			# TODO: original toolchain from site does not have needed libc lock changes.
			# it need to bo patched and rebuilded
			case `uname -s` in
			Darwin)
				wget https://launchpad.net/gcc-arm-embedded/4.8/4.8-2014-q3-update/+download/gcc-arm-none-eabi-4_8-2014q3-20140805-mac.tar.bz2
				#wget https://launchpad.net/gcc-arm-embedded/4.7/4.7-2013-q3-update/+download/gcc-arm-none-eabi-4_7-2013q3-20130916-mac.tar.bz2
				;;
			Linux)
				wget https://launchpad.net/gcc-arm-embedded/4.8/4.8-2014-q3-update/+download/gcc-arm-none-eabi-4_8-2014q3-20140805-linux.tar.bz2
				#wget https://launchpad.net/gcc-arm-embedded/4.7/4.7-2013-q3-update/+download/gcc-arm-none-eabi-4_7-2013q3-20130916-linux.tar.bz2
				;;
			esac
			tar xjvf gcc-arm-none-eabi-4*.tar.bz2
			rm -f *.bz2
			mv gcc-arm-none-eabi-4_* armt
			;;
		*)
			case `uname -s` in
			Darwin)
				wget http://software-dl.ti.com/dsps/dsps_public_sw/sdo_ccstudio/codegen/Updates/p2mac/binary/com.ti.cgt.tms470.${TCGARMMAJORVERSION}.mac_root_${TCGARMVERSION} -O ti_cgt_tms470_${TCGARMVERSION}_osx_installer.zip
				unzip ti_cgt_tms470*.zip
				chmod +x downloads/ti_cgt_tms470_*_osx_installer.app/Contents/MacOS/osx-intel
				downloads/ti_cgt_tms470_*_osx_installer.app/Contents/MacOS/osx-intel --mode unattended
				;;
			Linux)
				wget http://software-dl.ti.com/dsps/dsps_public_sw/sdo_ccstudio/codegen/Updates/p2linux/binary/com.ti.cgt.tms470.${TCGARMMAJORVERSION}.linux_root_${TCGARMVERSION} -O ti_cgt_tms470_${TCGARMVERSION}_linux_installer_x86.zip
				unzip ti_cgt_tms470*.zip
				chmod +x downloads/*.bin
				downloads/ti_cgt_tms470_*_linux_installer_x86.bin --mode unattended
				;;
			esac
			mv *arm_* armt
			rm -rf downloads
			rm -f *.zip
			;;
		esac
	fi
	cd ${BASE_ROOT}
}

GCC=no # GCC not supported yet, still issues with memory regions while linking
C64T=yes
TCGARMVERSION=5.2.9
TCGARMMAJORVERSION=`echo ${TCGARMVERSION} | cut -c 1-3`
if [ "$C64T" == "yes" ]; then
	XDCCOREVERSION=3_31_03_43
else
	XDCCOREVERSION=3_32_01_22
fi

check_tools

BASE_ROOT=`pwd`
BUILD_DIR=${BASE_ROOT}/sources
mkdir -f ${BUILD_DIR} 2> /dev/null

if [ "$C64T" == "yes" ]; then
	fetch_repo bios git://github.com/mobiaqua/ti-sysbios-c64t.git
else
	fetch_repo bios git://github.com/mobiaqua/ti-sysbios.git
fi
fetch_repo ce git://github.com/mobiaqua/ti-ce.git
fetch_repo fc git://github.com/mobiaqua/ti-fc.git
fetch_repo ipc git://github.com/mobiaqua/ti-ipc1.git
fetch_repo osal git://github.com/mobiaqua/ti-osal.git
fetch_repo xdais git://github.com/mobiaqua/ti-xdais.git
fetch_repo rpmsg git://github.com/mobiaqua/ti-rpmsg.git
fetch_repo ipumm git://github.com/mobiaqua/ti-ipumm-omap4.git
fetch_repo codecs git://github.com/mobiaqua/ti-codecs.git

prepare_xdc_tools
prepare_arm_compiler

if [ "$GCC" == "yes" ]; then
	TARGET=gnu.targets.arm.M3
else
	TARGET=ti.targets.arm.elf.M3
fi

make -C ${BASE_ROOT} TARGET=${TARGET} all
