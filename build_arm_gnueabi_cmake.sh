#!/bin/bash
GCC_COMPILER_VERSION="4.8"

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

export ARM_ABI=${APP_ABI}

case $APP_ABI in
  armeabi)
    TARGPLAT=arm-linux-gnueabi
    TOOLCHAINS=arm-linux-gnueabi
    ARCH=arm

	FFTS_LIB_NAME=ffts
	PICORT_LIB_NAME=picort
	FFTE_LIB_NAME=ffte
	NUFFT_LIB_NAME=nufft
	COLORSPACE_LIB_NAME=colorspace
	LIBYUV_NAME=yuv-static
	FFTPACK_LIB_NAME=fftbase
	#libpico-NDK-arm.a
	#enable VFP only
    export FLOAT_ABI_SUFFIX="hf"
	export CFLAGS="-Os -pthread -mthumb -fdata-sections -Wa,--noexecstack -fsigned-char -Wno-psabi --sysroot=$SYS_ROOT"
	export CXXFLAGS="-pthread -mthumb -fdata-sections -Wa,--noexecstack -fsigned-char -Wno-psabi --sysroot=$SYS_ROOT"

  ;;
  armeabi-v7a*)
	APP_ABI="armeabi-v7a"
    TARGPLAT=arm-linux-gnueabi
    TOOLCHAINS=arm-linux-gnueabi
    ARCH=arm
	#enable NEON
	FFTS_LIB_NAME=ffts
	#FFTE_LIB_NAME=ffte_vec
	PICORT_LIB_NAME=picort
	FFTE_LIB_NAME=ffte
	NUFFT_LIB_NAME=nufft
	COLORSPACE_LIB_NAME=colorspace
	LIBYUV_NAME=yuv-static
	FFTPACK_LIB_NAME=fftbase

    export FLOAT_ABI_SUFFIX="hf"
	export CFLAGS="-Os -pthread -mthumb -fdata-sections -Wa,--noexecstack -fsigned-char -Wno-psabi --sysroot=$SYS_ROOT"
	export CXXFLAGS="-pthread -mthumb -fdata-sections -Wa,--noexecstack -fsigned-char -Wno-psabi --sysroot=$SYS_ROOT"

  ;;
  arm64-v8a)
    TARGPLAT=aarch64-linux-gnu
    TOOLCHAINS=aarch64-linux-gnu
    ARCH=arm64
	FFTS_LIB_NAME=ffts
	#FFTE_LIB_NAME=ffte_vec
	PICORT_LIB_NAME=picort
	FFTE_LIB_NAME=ffte
	NUFFT_LIB_NAME=nufft
	COLORSPACE_LIB_NAME=colorspace
	LIBYUV_NAME=yuv-static
	FFTPACK_LIB_NAME=fftbase
	export CFLAGS="-Os -pthread -fdata-sections -Wa,--noexecstack -fsigned-char -Wno-psabi --sysroot=$SYS_ROOT"
	export CXXFLAGS="-pthread -fdata-sections -Wa,--noexecstack -fsigned-char -Wno-psabi --sysroot=$SYS_ROOT"

  ;;
  *) echo $0: Unknown target; exit
esac

#don't add sys_root in makefile. This generates the following error!!!
#/usr/lib/gcc-cross/arm-linux-gnueabihf/4.8/../../../../arm-linux-gnueabihf/bin/ld: cannot find /usr/arm-linux-gnueabihf/lib/libc.so.6 inside /usr/arm-linux-gnueabihf/
#/usr/lib/gcc-cross/arm-linux-gnueabihf/4.8/../../../../arm-linux-gnueabihf/bin/ld: cannot find /usr/arm-linux-gnueabihf/lib/libc_nonshared.a inside /usr/arm-linux-gnueabihf/
#/usr/lib/gcc-cross/arm-linux-gnueabihf/4.8/../../../../arm-linux-gnueabihf/bin/ld: cannot find /usr/arm-linux-gnueabihf/lib/ld-linux-armhf.so.3 inside /usr/arm-linux-gnueabihf/
#collect2: error: ld returned 1 exit status

export SYS_ROOT="/usr/${TOOLCHAINS}${FLOAT_ABI_SUFFIX}/"
#export CC="/usr/bin/${TOOLCHAINS}${FLOAT_ABI_SUFFIX}-gcc-${GCC_COMPILER_VERSION} --sysroot=$SYS_ROOT"
#export CXX="/usr/bin/${TOOLCHAINS}${FLOAT_ABI_SUFFIX}-g++-${GCC_COMPILER_VERSION} --sysroot=$SYS_ROOT"
export CC="/usr/bin/${TOOLCHAINS}${FLOAT_ABI_SUFFIX}-gcc-${GCC_COMPILER_VERSION}"
export CXX="/usr/bin/${TOOLCHAINS}${FLOAT_ABI_SUFFIX}-g++-${GCC_COMPILER_VERSION}"
#export LD="/usr/bin/${TOOLCHAINS}${FLOAT_ABI_SUFFIX}-ld"
#export LD="/usr/bin/${TOOLCHAINS}${FLOAT_ABI_SUFFIX}-g++"
export LD="/usr/bin/${TOOLCHAINS}${FLOAT_ABI_SUFFIX}-g++-${GCC_COMPILER_VERSION}"
export AR="/usr/bin/${TOOLCHAINS}${FLOAT_ABI_SUFFIX}-ar "
#!!!blis special, need ARCH to "archive"
#export ARCH=${AR}
export RANLIB="/usr/bin/${TOOLCHAINS}${FLOAT_ABI_SUFFIX}-ranlib"
export STRIP="/usr/bin/${TOOLCHAINS}${FLOAT_ABI_SUFFIX}-strip"
#export FORTRAN="/usr/bin/${TOOLCHAINS}${FLOAT_ABI_SUFFIX}-gfortran --sysroot=$SYS_ROOT"
export FORTRAN="/usr/bin/${TOOLCHAINS}${FLOAT_ABI_SUFFIX}-gfortran"

#cmake:FC
export FC=${FORTRAN}
#http://www.na-mic.org/svn/Slicer3-lib-mirrors/trunk/CMake/Modules/CMakeFortranInformation.cmake
#SET (CMAKE_Fortran_FLAGS "$ENV{FFLAGS}" CACHE STRING
#     "Flags for Fortran compiler.")
#IF (CMAKE_Fortran_FLAGS_INIT)
#    SET (CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} ${CMAKE_Fortran_FLAGS_INIT}")
#ENDIF (CMAKE_Fortran_FLAGS_INIT)
export FFLAGS="-fPIC -pthread"

echo "****${rPPG_DIR}"
echo "****${rPPG_OUT}"
#ls -lR $rPPG_OUT

if [ -d ${rPPG_OUT}/$APP_ABI ]; then
	if [ -n "$clean_build" ]; then
		echo "clean build"
		rm -rf ${rPPG_OUT}/$APP_ABI/*
	fi
else
	echo "mkdir -p"
	mkdir -p ${rPPG_OUT}/$APP_ABI
fi
#ls -lR $rPPG_OUT
#read
pushd ${rPPG_OUT}/$APP_ABI
export LIBYUV_NAME=yuv-static
#pwd
#read
case $APP_ABI in
	armeabi)
		cmake -DCMAKE_TOOLCHAIN_FILE=${rPPG_DIR}/arm-gnueabi.toolchain.cmake \
		-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DAPP_ABI=$APP_ABI -DARM_ABI:STRING="${ARM_ABI}" \
		-DLIBYUV_DIR:FILEPATH=${LIBYUV_DIR} -DLIBYUV_NAME=${LIBYUV_NAME} \
		-DLIBYUV_OUT:FILEPATH=${LIBYUV_OUT}/libs/${APP_ABI} \
		-DDSPCORE_OUT:FILEPATH=${DSPCORE_OUT} -DDSPCORE_DIR:FILEPATH=${DSPCORE_DIR} \
		${rPPG_DIR}
	;;
	armeabi-v7a*)
		cmake -DCMAKE_TOOLCHAIN_FILE=${rPPG_DIR}/arm-gnueabi.toolchain.cmake \
		-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DAPP_ABI=$APP_ABI -DARM_ABI:STRING="${ARM_ABI}" \
		-DLIBYUV_DIR:FILEPATH=${LIBYUV_DIR} -DLIBYUV_NAME=${LIBYUV_NAME} \
		-DLIBYUV_OUT:FILEPATH=${LIBYUV_OUT}/libs/${APP_ABI} \
		-DDSPCORE_OUT:FILEPATH=${DSPCORE_OUT} -DDSPCORE_DIR:FILEPATH=${DSPCORE_DIR} \
		${rPPG_DIR}
	;;
	arm64-v8a)
		cmake -DCMAKE_TOOLCHAIN_FILE=${rPPG_DIR}/arm-gnueabi.toolchain.cmake \
		-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DAPP_ABI=$APP_ABI -DARM_ABI:STRING="${ARM_ABI}" \
		-DLIBYUV_DIR:FILEPATH=${LIBYUV_DIR} -DLIBYUV_NAME=${LIBYUV_NAME} \
		-DLIBYUV_OUT:FILEPATH=${LIBYUV_OUT}/libs/${APP_ABI} \
		-DDSPCORE_OUT:FILEPATH=${DSPCORE_OUT} -DDSPCORE_DIR:FILEPATH=${DSPCORE_DIR} \
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
#pwd
#read
make -j${CORE_COUNT}
ret=$?
echo "ret=$ret"
if [ "$ret" != '0' ]; then
echo "$0 make error!!!!"
exit -1
fi

popd
#pwd
#read