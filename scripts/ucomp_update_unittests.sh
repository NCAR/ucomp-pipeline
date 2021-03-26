#!/bin/sh

# generate script of creating unit tests
./ucomp_update_unittests.py > update.sh

# run it
chmod +x update.sh
./update.sh

# remove script
rm -f update.sh
