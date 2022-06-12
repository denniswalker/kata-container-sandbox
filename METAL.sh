#!/usr/bin/env bash

set -ex

echo " ############## METAL ################ "

    zypper refresh
    zypper -n install katacontainers

echo " ############## METAL Runtime Test #################"

if [[ ! $(kata-runtime kata-check) ]]; then
    echo "System does not have hardware virtualization enabled."
    exit 1
else
    echo "Kata containers can run on this machine."
fi