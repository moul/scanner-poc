#!/bin/sh

blue="\033[34m"
reset="\033[0m"
red="\033[31m"
green="\033[32m"

warn() {
  echo -e "$1" >/dev/stderr
}

alert() {
  warn "$red$1$reset"
}

info() {
  warn "$green$1$reset"
}

notice() {
  warn "$blue$1$reset"
}

usage() {
  notice "Example :  ./bearer-scanner -d <dir1> <dir2>"
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
    * ) echo "Example :  ./bearer-scanner <dir1> <dir2>"
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

    outputName="$(echo $repo | tr "/" "-" )"
    # TODO replace later with a call to the binary
    go run ./cli.go $realPath > "$tmpDir/$outputName.json"
    rm -f bearer-cli.zip
    zip -r -j bearer-cli.zip /tmp/bearer-scanner/*
    notice "new report generated on => $(pwd)/bearer-cli.zip"
done
