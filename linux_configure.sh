#!/bin/sh

FLAGS=$1

if [[ ! -z "$FLAGS" ]]; then
  FLAGS=.${FLAGS}
fi

rm -rf build
mkdir build
cd build

cmake \
  -DCMAKE_INSTALL_PREFIX:PATH=~/software/ucomp-pipeline${FLAGS} \
  -DIDL_ROOT_DIR:PATH=/opt/share/idl8.6/idl86 \
  ..
