#!/bin/bash

# Use this script to recovery form your bricked abox_edge device

set -e

GETOPT=$(which getopt)
UNZIP=$(which unzip)

FLASH_CONFIG="IAP140_Trusted_lpddr3_1g_discrete_667Mhz_Brillo.blf"
SPARSE_IMAGES="system.img cache.img userdata.img teesst.img"
SPARSE_TOOL="sparse_converter"
FLASH_TOOL="swdl_linux"

LOCAL_DIR=$(pwd)

function print_help()
{
	cat << EOF

Usage: ${0##*/} [options]
  -h, --help  display this help
  -f, --file <filename>  zip file for flashing
EOF

	exit 1
}

function do_flashing()
{
	local zip_file="$1"
	local img=""
	local blf_file="${LOCAL_DIR}/${FLASH_CONFIG}"
	local sparse_tool="${LOCAL_DIR}/${SPARSE_TOOL}"
	local flash_tool="${LOCAL_DIR}/${FLASH_TOOL}"

	if [ ! -e "$blf_file" ]; then
		echo "BLF file ${blf_file} not exist..."
		exit 1
	fi

	local tmp_dir=$(mktemp -dt "abox.XXXXXX")
	${UNZIP} -o -q -d ${tmp_dir} ${zip_file}
	if [ $? -ne 0 ]; then
		rm -rf ${tmp_dir}
		echo "unzip ${zip_file} error..."
	fi
	cp -ab "${blf_file}" ${tmp_dir}
	cp -ab "${sparse_tool}" ${tmp_dir}
	cp -ab "${flash_tool}" ${tmp_dir}
	cd ${tmp_dir}

	# Convert the image to be compatible with the flash tool
	mkdir -p sparse
	mv ${SPARSE_IMAGES} sparse/
	for img in ${SPARSE_IMAGES}; do
		./${SPARSE_TOOL} ./sparse/${img} ${img} > /dev/null 2>&1
		if [ $? -ne 0 ]; then
			echo "Sparse image ${img} convert error..."
			rm -rf {tmp_dir}
			exit 1	
		fi
	done

	# Start flashing
	sudo ./${FLASH_TOOL} -D ${FLASH_CONFIG} -S
	if [ $? -ne 0 ]; then
		echo "Flash error, refer to ${tmp_dir} for error logs..."	
	else
		echo "Flash success..."
		rm -rf ${tmp_dir}
	fi
}

if [ $# -lt 1 ]; then
	print_help
fi

case "$1" in
-h|--help)
	print_help
	;;
-f|--file)
	if [ $# -lt 2 ]; then
		print_help
	fi
		
	do_flashing "$2"
	;;
*)
	print_help
	;;
esac

exit 0
