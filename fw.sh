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
	CURL=`curl --version 2> /dev/null`

	if [ "$CURL" == "" ]; then
		echo "Error: Missing zip tool!"
		exit 1
	fi

	if [ "$CURL" == "" ]; then
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
			curl http://software-dl.ti.com/dsps/dsps_public_sw/sdo_sb/targetcontent/rtsc/${XDCCOREVERSION}/exports/xdccore/xdctools_${XDCCOREVERSION}_core_macos.zip?tracked=1 \
			--output xdctools_${XDCCOREVERSION}_core_macos.zip
			;;
		Linux)
			curl http://software-dl.ti.com/dsps/dsps_public_sw/sdo_sb/targetcontent/rtsc/${XDCCOREVERSION}/exports/xdccore/xdctools_${XDCCOREVERSION}_core_linux.zip?tracked=1 \
			--output xdctools_${XDCCOREVERSION}_core_linux.zip
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
		case `uname -s` in
		Darwin)
			curl http://downloads.ti.com/codegen/esd/cgt_public_sw/TMS470/${TCGARMVERSION}/ti_cgt_tms470_${TCGARMVERSION}_osx_installer.app.zip?tracked=1 \
				--output ti_cgt_tms470_${TCGARMVERSION}_osx_installer.zip
			unzip ti_cgt_tms470*.zip
			ti_cgt_tms470_*/Contents/MacOS/osx-x86_64 --mode unattended --prefix .
			mv ti-cgt-arm* armt
			rm -rf ti_cgt_tms470_*
			rm -f *.zip
			;;
		Linux)
			curl http://downloads.ti.com/codegen/esd/cgt_public_sw/TMS470/${TCGARMVERSION}/ti_cgt_tms470_${TCGARMVERSION}_linux_installer_x86.bin?tracked=1 \
				--output ti_cgt_tms470_${TCGARMVERSION}_linux_installer_x86.bin
			chmod +x *.bin
			ti_cgt_tms470_*_linux_installer_x86.bin --mode unattended --prefix .
			mv ti-cgt-arm* armt
			rm -rf ti_cgt_tms470_*
			;;
		esac
	fi
	cd ${BASE_ROOT}
}

C64T=no
TCGARMVERSION=18.12.4.LTS
TCGARMMAJORVERSION=`echo ${TCGARMVERSION} | cut -c 1-3`
if [ "$C64T" == "yes" ]; then
	XDCCOREVERSION=3_31_03_43
else
	XDCCOREVERSION=3_55_02_22
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
fetch_repo ipc git://github.com/mobiaqua/ti-ipcdev.git
fetch_repo osal git://github.com/mobiaqua/ti-osal.git
fetch_repo xdais git://github.com/mobiaqua/ti-xdais.git
fetch_repo ipumm git://github.com/mobiaqua/ti-ipumm.git
fetch_repo codecs git://github.com/mobiaqua/ti-codecs.git

prepare_xdc_tools
prepare_arm_compiler

TARGET=ti.targets.arm.elf.M3

make -C ${BASE_ROOT} TARGET=${TARGET} all
