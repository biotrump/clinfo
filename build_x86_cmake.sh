#!/bin/bash
#Thomas Tsai <thomas@biotrump.com>
#temp for my workspace
#BIOTRUMP_DIR=${BIOTRUMP_DIR:-master}
if [ -z "$BIOTRUMP_DIR" ]; then
	echo "setup.sh to export .config"
	pushd ../..
	. setup.sh
	popd
fi
if [ -z "$BIOTRUMP_OUT" ]; then
	echo "$BIOTRUMP_OUT is still not found!!!"
	exit -1
fi

echo "****$rPPG_DIR"
echo "****$rPPG_OUT"

rPPG_DIR=${rPPG_DIR:-`pwd`}
rPPG_OUT=${rPPG_OUT:-`pwd`}

if [ ! -d ${rPPG_OUT} ]; then
	mkdir -p ${rPPG_OUT}
else
	rm -rf ${rPPG_OUT}/*
fi

pushd ${rPPG_OUT}
export LIBYUV_NAME=yuv-static

cmake -DUSE_OPENCV=2.4.x ${rPPG_DIR}

#-DFFTS_DIR:FILEPATH=${FFTS_DIR} -DFFTS_OUT:FILEPATH=${FFTS_OUT} \
#-DDSPCORE_OUT:FILEPATH=${DSPCORE_OUT} -DDSPCORE_DIR:FILEPATH=${DSPCORE_DIR} \
#-DLIBYUV_DIR:FILEPATH=${LIBYUV_DIR} -DLIBYUV_NAME=${LIBYUV_NAME} \
#-DLIBYUV_OUT:FILEPATH=${LIBYUV_OUT}/libs/${TARGET_ARCH} \
#-DATLAS_SRC:FILEPATH=${ATLAS_SRC} -DATLAS_OUT:FILEPATH=${ATLAS_OUT} \
#-DPICO_DIR=${PICO_DIR} -DPICO_OUT=${PICO_OUT} \
#-DV4L2_LIB_DIR:FILEPATH=${V4L2_LIB_DIR} -DV4L2_LIB_OUT:FILEPATH=${V4L2_LIB_OUT} \
#-DTARGET_ARCH=${TARGET_ARCH} \
# \
#-DLAPACK_SRC:FILEPATH=${LAPACK_SRC} -DLAPACK_BUILD:FILEPATH=${LAPACK_BUILD} \
#-DLAPACK_LIB:FILEPATH=${LAPACK_LIB} -DLAPACKE_SRC:FILEPATH=${LAPACKE_SRC} \
#-DCBLAS_SRC:FILEPATH=${CBLAS_SRC} ..

ret=$?
echo "ret=$ret"
if [ "$ret" != '0' ]; then
echo "$0 make error!!!!"
exit -1
fi

make ${MAKE_FLAGS}

ret=$?
popd
echo "ret=$ret"
if [ "$ret" != '0' ]; then
echo "$0 make error!!!!"
exit -1
fi
