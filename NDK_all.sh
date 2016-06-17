#!/bin/bash
if [ $TARGET_ARCH == "all" ]; then

	echo "=============================="
	echo "armeabi"
	echo "=============================="

	./build_NDK_cmake.sh -abi armeabi -c
	if [ "$?" != "0" ]; then
		exit -1
	fi

	echo "=============================="
	echo "armeabi-v7a"
	echo "=============================="
	./build_NDK_cmake.sh -abi armeabi-v7a -c
	if [ "$?" != "0" ]; then
		exit -1
	fi

	#./build_NDK.sh -abi arm64-v8a -c
	echo "=============================="
	echo "arm64-v8a"
	echo "=============================="
	./build_NDK_cmake.sh -abi arm64-v8a -c
	if [ "$?" != "0" ]; then
		exit -1
	fi

	#./build_NDK.sh -abi x86 -c
	echo "=============================="
	echo "x86"
	echo "=============================="
	./build_NDK_cmake.sh -abi x86 -c
	if [ "$?" != "0" ]; then
		exit -1
	fi

	#./build_NDK.sh -abi x86_64 -c
	echo "=============================="
	echo "x86_64"
	echo "=============================="
	./build_NDK_cmake.sh -abi x86_64 -c
	if [ "$?" != "0" ]; then
		exit -1
	fi

	#./build_NDK.sh -abi mips -c
	echo "=============================="
	echo "mips"
	echo "=============================="
	./build_NDK_cmake.sh -abi mips -c
	if [ "$?" != "0" ]; then
		exit -1
	fi

	#./build_NDK.sh -abi mips64 -c
	echo "=============================="
	echo "mips64"
	echo "=============================="
	./build_NDK_cmake.sh -abi mips64 -c
	if [ "$?" != "0" ]; then
		exit -1
	fi
else
	./build_NDK_cmake.sh -abi $TARGET_ARCH -c
	if [ "$?" != "0" ]; then
		exit -1
	fi
fi
exit 0
