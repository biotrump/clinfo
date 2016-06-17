#!/bin/bash

#export CMAKE_BUILD_TYPE="Debug"
export CMAKE_BUILD_TYPE="Release"

# Make sure you have NDK_ROOT defined in .bashrc or .bash_profile
# Modify INSTALL_DIR to suit your situation
#Lollipop	5.0 - 5.1	API level 21, 22
#KitKat	4.4 - 4.4.4	API level 19
#Jelly Bean	4.3.x	API level 18
#Jelly Bean	4.2.x	API level 17
#Jelly Bean	4.1.x	API level 16
#Ice Cream Sandwich	4.0.3 - 4.0.4	API level 15, NDK 8
#Ice Cream Sandwich	4.0.1 - 4.0.2	API level 14, NDK 7
#Honeycomb	3.2.x	API level 13
#Honeycomb	3.1	API level 12, NDK 6
#Honeycomb	3.0	API level 11
#Gingerbread	2.3.3 - 2.3.7	API level 10
#Gingerbread	2.3 - 2.3.2	API level 9, NDK 5
#Froyo	2.2.x	API level 8, NDK 4


if [ -z "${NDK_ROOT_FORTRAN}"  ]; then
	#export NDK_ROOT=${HOME}/NDK/android-ndk-r10d
export NDK_ROOT=${HOME}/NDK/android-ndk-r10e
else
	export NDK_ROOT=${NDK_ROOT_FORTRAN}
fi
export ANDROID_NDK=${NDK_ROOT}

while [ $# -ge 1 ]; do
	case $1 in
	-ABI|-abi)
		echo "\$1=-abi"
		shift
		APP_ABI=$1
		shift
		;;
	-clean|-c|-C) #
		echo "\$1=-c,-C,-clean"
		clean_build=1
		shift
		;;
	-l|-L)
		echo "\$1=-l,-L"
		local_build=1
		;;
	--help|-h|-H)
		# The main case statement will give a usage message.
		echo "$0 -c|-clean -abi=[armeabi, armeabi-v7a, armv8-64,mips,mips64el, x86,x86_64]"
		exit 1
		break
		;;
	-*)
		echo "$0: unrecognized option $1" >&2
		exit 1
		;;
	*)
		break
		;;
	esac
done
echo APP_ABI=$APP_ABI
export APP_ABI

if [[ ${NDK_ROOT} =~ .*"-r9".* ]]
then
#ANDROID_APIVER=android-8
#ANDROID_APIVER=android-9
#android 4.0.1 ICS and above
ANDROID_APIVER=android-14
#TOOL_VER="4.6"
#gfortran is in r9d V4.8.0
TOOL_VER="4.8.0"
else
	#r10d : android 4.0.1 ICS and above
	if [ "$APP_ABI" = "arm64-v8a" -o \
		"$APP_ABI" = "x86_64" -o \
		"$APP_ABI" = "mips64" ]; then
		ANDROID_APIVER=android-21
	else
#		ANDROID_APIVER=android-14
#kitkat
#		ANDROID_APIVER=android-19
#lolipop
		ANDROID_APIVER=android-21
	fi
	TOOL_VER="4.9"
fi

case $(uname -s) in
  Darwin)
    CONFBUILD=i386-apple-darwin`uname -r`
    HOSTPLAT=darwin-x86
    CORE_COUNT=`sysctl -n hw.ncpu`
  ;;
  Linux)
    CONFBUILD=x86-unknown-linux
    HOSTPLAT=linux-`uname -m`
    CORE_COUNT=`grep processor /proc/cpuinfo | wc -l`
  ;;
CYGWIN*)
	CORE_COUNT=`grep processor /proc/cpuinfo | wc -l`
	;;
  *) echo $0: Unknown platform; exit
esac

#default is arm
#export PATH="$NDK_ROOT/toolchains/${TARGPLAT}-${TOOL_VER}/prebuilt/${HOSTPLAT}/bin/:\
#$NDK_ROOT/toolchains/${TARGPLAT}-${TOOL_VER}/prebuilt/${HOSTPLAT}/${TARGPLAT}/bin/:$PATH"
case $APP_ABI in
  armeabi)
    TARGPLAT=arm-linux-androideabi
    TOOLCHAINS=arm-linux-androideabi
    ARCH=arm
	LIBYUV_NAME=yuv-static
  ;;
  armeabi-v7a)
    TARGPLAT=arm-linux-androideabi
    TOOLCHAINS=arm-linux-androideabi
    ARCH=arm
	LIBYUV_NAME=yuv-static
  ;;
  arm64-v8a)
    TARGPLAT=aarch64-linux-android
    TOOLCHAINS=aarch64-linux-android
    ARCH=arm64
	LIBYUV_NAME=yuv-static
  ;;
  x86)
    TARGPLAT=i686-linux-android
    TOOLCHAINS=x86
    ARCH=x86
	#specify assembler for x86 SSE3, but ffts's sse.s needs 64bit x86.
	#intel atom z2xxx and the old atoms are 32bit
	#http://forum.cvapp.org/viewtopic.php?f=13&t=423&sid=4c47343b1de899f9e1b0d157d04d0af1
	export  CCAS="${TARGPLAT}-as"
	export  CCASFLAGS="--32 -march=i686+sse3"
	LIBYUV_NAME=yuv-static

  ;;
  x86_64)
    TARGPLAT=x86_64-linux-android
    TOOLCHAINS=x86_64
    ARCH=x86_64
    #specify assembler for x86 SSE3, but ffts's sse.s needs 64bit x86.
	#atom-64 or x86-64 devices only.
	#http://forum.cvapp.org/viewtopic.php?f=13&t=423&sid=4c47343b1de899f9e1b0d157d04d0af1
	export  CCAS="${TARGPLAT}-as"
#	export  CCASFLAGS="--64 -march=i686+sse3"
	export  CCASFLAGS="--64"
	LIBYUV_NAME=yuv-static

  ;;
  mips)
	TARGPLAT=mipsel-linux-android
	TOOLCHAINS=mipsel-linux-android
	ARCH=mips
	LIBYUV_NAME=yuv-static

  ;;
  mips64)
	TARGPLAT=mips64el-linux-android
	TOOLCHAINS=mips64el-linux-android
	ARCH=mips64
	LIBYUV_NAME=yuv-static

  ;;
  *) echo $0: Unknown target; exit
esac

export SYS_ROOT="${NDK_ROOT}/platforms/${ANDROID_APIVER}/arch-${APP_ABI}/"
export CC="${TARGPLAT}-gcc --sysroot=$SYS_ROOT"
export LD="${TARGPLAT}-ld"
export AR="${TARGPLAT}-ar"
export ARCH=${AR}
export RANLIB="${TARGPLAT}-ranlib"
export STRIP="${TARGPLAT}-strip"
#export CFLAGS="-Os -fPIE"
export CFLAGS="-Os -fPIE -fPIC --sysroot=$SYS_ROOT"
export CXXFLAGS="-fPIE -fPIC --sysroot=$SYS_ROOT"
export FORTRAN="${TARGPLAT}-gfortran --sysroot=$SYS_ROOT"

#!!! quite importnat for cmake to define the NDK's fortran compiler.!!!
#Don't let cmake decide it.
export FC=${FORTRAN}

#include path :
#platforms/android-21/arch-arm/usr/include/

if [ -z "$rPPG_DIR" ]; then
	export DSP_HOME=${DSP_HOME:-`pwd`/..}
	export rPPG_DIR=${rPPG_DIR:-`pwd`}
fi

if [ -d "$rPPG_OUT/$APP_ABI" ]; then
	if [ -n "$clean_build" ]; then
		rm -rf $rPPG_OUT/$APP_ABI/*
	fi
else
	mkdir -p $rPPG_OUT/$APP_ABI
fi

export LAPACKE_SRC=${LAPACKE_SRC:-${LAPACK_SRC}/LAPACKE}

pushd ${rPPG_OUT}/$APP_ABI

case $APP_ABI in
	armeabi)
		cmake -DCMAKE_TOOLCHAIN_FILE=${rPPG_DIR}/android.toolchain.cmake \
		-DANDROID_NATIVE_API_LEVEL=${ANDROID_APIVER} \
		-DANDROID_NDK=${ANDROID_NDK} -DANDROID_TOOLCHAIN_NAME=${TOOLCHAINS}-${TOOL_VER} \
		-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DANDROID_ABI="armeabi" -DAPP_ABI=$APP_ABI \
		${rPPG_DIR}
	;;
  armeabi-v7a)
		cmake -DCMAKE_TOOLCHAIN_FILE=${rPPG_DIR}/android.toolchain.cmake \
		-DANDROID_NATIVE_API_LEVEL=${ANDROID_APIVER} \
		-DANDROID_NDK=${ANDROID_NDK} -DANDROID_TOOLCHAIN_NAME=${TOOLCHAINS}-${TOOL_VER} \
		-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DANDROID_ABI="armeabi-v7a with VFPV3" -DAPP_ABI=$APP_ABI \
		${rPPG_DIR}
	;;
  arm64-v8a)
		cmake -DCMAKE_TOOLCHAIN_FILE=${rPPG_DIR}/android.toolchain.cmake \
		-DANDROID_NATIVE_API_LEVEL=${ANDROID_APIVER} \
		-DANDROID_NDK=${ANDROID_NDK} -DANDROID_TOOLCHAIN_NAME=${TOOLCHAINS}-${TOOL_VER} \
		-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DANDROID_ABI="arm64-v8a" -DAPP_ABI=$APP_ABI \
		${rPPG_DIR}
	;;
  x86)
		cmake -DCMAKE_TOOLCHAIN_FILE=${rPPG_DIR}/android.toolchain.cmake \
		-DANDROID_NATIVE_API_LEVEL=${ANDROID_APIVER} \
		-DANDROID_NDK=${ANDROID_NDK} -DANDROID_TOOLCHAIN_NAME=${TOOLCHAINS}-${TOOL_VER} \
		-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DANDROID_ABI="x86" -DAPP_ABI=$APP_ABI \
		${rPPG_DIR}
	;;
  x86_64)
		cmake -DCMAKE_TOOLCHAIN_FILE=${rPPG_DIR}/android.toolchain.cmake \
		-DANDROID_NATIVE_API_LEVEL=${ANDROID_APIVER} \
		-DANDROID_NDK=${ANDROID_NDK} -DANDROID_TOOLCHAIN_NAME=${TOOLCHAINS}-${TOOL_VER} \
		-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DANDROID_ABI="x86_64" -DAPP_ABI=$APP_ABI\
		${rPPG_DIR}
	;;
  mips)
		cmake -DCMAKE_TOOLCHAIN_FILE=${rPPG_DIR}/android.toolchain.cmake \
		-DANDROID_NATIVE_API_LEVEL=${ANDROID_APIVER} \
		-DANDROID_NDK=${ANDROID_NDK} -DANDROID_TOOLCHAIN_NAME=${TOOLCHAINS}-${TOOL_VER} \
		-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DANDROID_ABI="mips" -DAPP_ABI=$APP_ABI \
		${rPPG_DIR}
	;;
  mips64)
		cmake -DCMAKE_TOOLCHAIN_FILE=${rPPG_DIR}/android.toolchain.cmake \
		-DANDROID_NATIVE_API_LEVEL=${ANDROID_APIVER} \
		-DANDROID_NDK=${ANDROID_NDK} -DANDROID_TOOLCHAIN_NAME=${TOOLCHAINS}-${TOOL_VER} \
		-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DANDROID_ABI="mips64" -DAPP_ABI=$APP_ABI \
		${rPPG_DIR}
	;;
  *) echo $0: Unknown target; exit
esac

ret=$?
echo "ret=$ret"
if [ "$ret" != '0' ]; then
echo "$0 cmake error!!!!"
exit -1
fi

make -j${CORE_COUNT}
ret=$?
echo "ret=$ret"
if [ "$ret" != '0' ]; then
echo "$0 make error!!!!"
exit -1
fi

popd
pushd ${rPPG_OUT}
mkdir -p libs/$APP_ABI
rm -rf libs/$APP_ABI/*
ln -s ${rPPG_OUT}/$APP_ABI/lib/libv4l2cam_static.d.a libs/$APP_ABI/libv4l2cam_static.d.a
ln -s ${rPPG_OUT}/$APP_ABI/lib/libv4l2cam_static.a libs/$APP_ABI/libv4l2cam_static.a

popd
exit 0
