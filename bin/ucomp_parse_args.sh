if [[ $# -lt 2 ]]; then
  echo "missing configuration file FLAGS"
  exit 1
else
  CONFIG=${PIPE_DIR}/config/ucomp.${1}.cfg
fi

# use today if date not passed to script
if [[ $# -lt 2 ]]; then
  DATE=$(date +"%Y%m%d")
else
  DATE=$2
fi
