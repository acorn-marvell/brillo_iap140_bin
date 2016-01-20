#!/bin/bash

# Use this script to recovery form your bricked abox_edge device

set -e

LOCAL_DIR=$(pwd)
FLASH_TOOL=swdl_linux
SPARSE_TOOL=sparse_converter

FLASH_CONFIG="IAP140_Trusted_lpddr3_1g_discrete_667Mhz_Brillo.blf"
SPARSE_IMAGES="system.img cache.img userdata.img teesst.img"

# Convert the image to be compatible with the flash tool
mkdir -p ${LOCAL_DIR}/sparse
mv ${SPARSE_IMAGES} ${LOCAL_DIR}/sparse/
for img in ${SPARSE_IMAGES}; do
	./${SPARSE_TOOL} ./sparse/${img} ${img} >/dev/null 2>&1
	if [ $? != 0 ]; then
		echo "Sparse image ${img} convert error..."
		exit 1
	fi
done

# Start flashing all
sudo ./${FLASH_TOOL} -D ${FLASH_CONFIG} -S

if [ $? == 0 ]; then
	echo "Flash success..."
else
	echo "Flash error..."
fi
