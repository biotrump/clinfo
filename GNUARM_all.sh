#!/bin/bash
if [ $TARGET_ARCH == "gnuarm-all" ]; then

	echo "=============================="
	echo "armeabi"
	echo "=============================="
	./build_arm_gnueabi_cmake.sh -abi armeabi -c
	if [ "$?" != "0" ]; then
		exit -1
	fi

	echo "=============================="
	echo "armeabi-v7a"
	echo "=============================="
	./build_arm_gnueabi_cmake.sh -abi armeabi-v7a -c
	if [ "$?" != "0" ]; then
		exit -1
	fi

	#./build_NDK.sh -abi arm64-v8a -c
#	echo "=============================="
#	echo "arm64-v8a"
#	echo "=============================="
#	./build_arm_gnueabi_cmake.sh -abi arm64-v8a -c
#	if [ "$?" != "0" ]; then
#		exit -1
#	fi

else
	echo "=============================="
	echo "armeabi-v7a"
	echo "=============================="
	./build_arm_gnueabi_cmake.sh -abi $TARGET_ARCH -c
	if [ "$?" != "0" ]; then
		exit -1
	fi
fi
exit 0
