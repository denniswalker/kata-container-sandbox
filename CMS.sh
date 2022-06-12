#!/usr/bin/env bash

set -ex

# TODO: 
# 1. Customize the base qemu image to reflect a valid build OS, e.g. COS.
# 2. Update the qemu configuration in /etc/kata-containers/configuration.toml to reflect the right kernel, initrd, memory, cores, etc.
# 3. Update the helmchart to parameterize the IMS podspec to include a runtimeclass: kata if specified.
# 4. Test deploying IMS in kata containers.
# 5. Integrate build functionality.
