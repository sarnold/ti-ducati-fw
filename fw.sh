#!/bin/bash

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
	wget http://software-dl.ti.com/dsps/dsps_public_sw/sdo_sb/targetcontent/rtsc/3_31_02_38/exports/xdccore/xdctools_3_31_02_38_core_linux.zip
	unzip xdctools_*_core_linux.zip
	mv xdctools_*_core xdc
fi

if [ ! -e ${BUILD_DIR}/cgt ]; then
	wget http://software-dl.ti.com/dsps/dsps_public_sw/sdo_ccstudio/codegen/Updates/p2linux/binary/com.ti.cgt.tms470.5.2.linux_root_5.2.6 -O ti_cgt_tms470_5.2.6_linux_installer_x86.zip
	unzip ti_cgt_tms470*.zip
	chmod +x downloads/*.bin
	downloads/ti_cgt_tms470_5.2.6_linux_installer_x86.bin --mode unattended --prefix .
	mv ti-cgt-arm_5.2.6 cgt
fi

rm -rf downloads
rm *.zip

cd ${BASE_ROOT}

make all
