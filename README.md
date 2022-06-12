# Kata Container Sandbox

This repo spins of a virtualbox VM with nested virtualization on, installs k8s and kata containers dependencies, deploys an example kata container, and runs some tests.

## Getting Started

1. Download and install Virtualbox and Vagrant.
2. Clone repo.
3. cd into the directory and run `vagrant up`.

## Kata Container Overview
TLDR; K8s -> containerd -> kata -> qemu -> guest VM -> container

Kata container execution overview: https://github.com/kata-containers/kata-containers/tree/main/docs/design/architecture#container-creation

## Install and Configuration

Opensuse RPM install: https://github.com/kata-containers/documentation/blob/master/install/opensuse-installation-guide.md

Containerd configuration: https://github.com/kata-containers/kata-containers/blob/main/docs/how-to/containerd-kata.md#configuration

K8s Runtime Class: https://github.com/kata-containers/kata-containers/blob/main/docs/how-to/how-to-use-k8s-with-cri-containerd-and-kata.md#create-runtime-class-for-kata-containers

## Testing

Test without k8s using ctr: https://github.com/kata-containers/kata-containers/blob/main/docs/how-to/containerd-kata.md#run

Test using crictl: https://github.com/kata-containers/kata-containers/blob/main/docs/how-to/run-kata-with-crictl.md

Test using a k8s pod: https://github.com/kata-containers/kata-containers/blob/main/docs/how-to/how-to-use-k8s-with-cri-containerd-and-kata.md#run-pod-in-kata-containers

## How-to

Build a custom VM image: https://github.com/kata-containers/packaging/tree/master/kernel#build-kata-containers-kernel

Build a custom ARM image: https://github.com/kata-containers/documentation/blob/master/Developer-Guide.md#build-a-custom-qemu-for-aarch64arm64---required

Configure the runtime to use a custom VM image: https://github.com/kata-containers/documentation/blob/master/Developer-Guide.md#configure-runtime-for-custom-debug-image

Passing through GPUs, NICs, or SR-IOV devices: https://github.com/kata-containers/documentation/tree/master/use-cases