#!/bin/sh

# Simple routine to get the short name of the host, i.e., the hostname without
# ucar.edu

hostname | sed -e 's/\..*$//'
