#!/bin/sh

URL_BASE="https://bearer-hub-backend-production.s3.eu-west-3.amazonaws.com"
BINARY_NAME="bearer-cli-latest"
blue="\033[34m"
reset="\033[0m"
red="\033[31m"
green="\033[32m"
os="$(uname -s | awk '{print tolower($0)}')"
arch="$(uname -p | awk '{print tolower($0)}')"

warn() { echo -e "$1" >/dev/stderr ;}
alert() { warn "$red$1$reset" ;}
info() { warn "$green$1$reset" ;}
notice() { warn "$blue$1$reset" ;}

if [ $os = 'darwin' ]; then
  case $arch in
  "i386")
    DOWNLOAD_URL="$URL_BASE/$os/386/bin/$BINARY_NAME"
  ;;
  "x86_64")
    DOWNLOAD_URL="$URL_BASE/$os/amd64/bin/$BINARY_NAME"
  ;;
  *)
    notice "Your system ($os => $arch) is not yet supported"
    exit
  ;;
  esac
fi

if [ $os = 'linux' ]; then
  case $arch in
  "i386")
    DOWNLOAD_URL="$URL_BASE/$os/386/bin/$BINARY_NAME"
  ;;
  "x86_64")
    DOWNLOAD_URL="$URL_BASE/$os/amd64/bin/$BINARY_NAME"
  ;;
  "aarch64")
    DOWNLOAD_URL="$URL_BASE/$os/arm64/bin/$BINARY_NAME"
  ;;
  *)
    notice "Your system ($os => $arch) is not yet supported"
    exit
  ;;
  esac
fi


usage() {
  notice "Example :  ./bearer-scanner -d <dir1> <dir2>"
}

downloadBinary() {
  notice "Download the the bearer-cli binary from $DOWNLOAD_URL to ~/.bearer"
  mkdir -p ~/.bearer
  curl $DOWNLOAD_URL --output ~/.bearer/bearer-cli
  chmod u+x  ~/.bearer/bearer-cli
}



if [ $# -lt 1 ];then
   notice "illegal number of parameters"
   notice "Display supported parameters with -h option"
   exit 1
fi

while getopts “:h?d:” opt; do
  case $opt in
    h)
     usage
     exit 0
    ;;
    d)
      shift
      repos=("$@");
    ;;
    * ) usage
        exit 1
  esac
done

if [ -z "$repos" ]
then
   usage
   exit 0
fi

set -e

tmpDir=/tmp/bearer-scanner
rm -rf $tmpDir
mkdir -p $tmpDir

for repo in "${repos[@]}";do
    realPath="$(cd $repo;pwd)"

    outputName="$(echo ${realPath:1} | tr "/" "-" )"
    downloadBinary
    ~/.bearer/bearer-cli $realPath > "$tmpDir/$outputName.json"
    rm -f bearer-cli.zip
    zip -r -j bearer-cli.zip /tmp/bearer-scanner/*
    notice "new report generated on => $(pwd)/bearer-cli.zip"
done
