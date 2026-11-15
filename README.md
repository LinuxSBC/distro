# Anna's Personal Distro

This is a customized Fedora Atomic Desktop image based on the scripts from [ublue](https://github.com/ublue-os/image-template). It is intended for personal use, not public, and I have made no considerations for people other than me using it. 

## Switch to the image from a running Fedora Atomic system

I generally use the rpm-ostree commands:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/linuxsbc/distro:latest
systemctl reboot
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/linuxsbc/distro:latest
systemctl reboot
```

If you want to use bootc, this command should work, though I haven't really tested it:
```bash
sudo bootc switch ghcr.io/linuxsbc/distro
systemctl reboot
```

# Repository Contents

## Containerfile

The [Containerfile](./Containerfile) defines the operations used to customize the selected image.This file is the entrypoint for your image build, and works exactly like a regular podman Containerfile. For reference, please see the [Podman Documentation](https://docs.podman.io/en/latest/Introduction.html).

## build.sh

The [build.sh](./build_files/build.sh) file is called from your Containerfile. It is the best place to install new packages or make any other customization to your system. There are customization examples contained within it for your perusal.

## build.yml

The [build.yml](./.github/workflows/build.yml) Github Actions workflow creates your custom OCI image and publishes it to the Github Container Registry (GHCR). By default, the image name will match the Github repository name.

# Building Disk Images

This template provides an out of the box workflow for creating disk images (ISO, qcow, raw) for your custom OCI image which can be used to directly install onto your machines.

This template provides a way to upload the disk images that is generated from the workflow to a S3 bucket. The disk images will also be available as an artifact from the job, if you wish to use an alternate provider. To upload to S3 we use [rclone](https://rclone.org/) which is able to use [many S3 providers](https://rclone.org/s3/).

# Justfile Documentation

The `Justfile` contains various commands and configurations for building and managing container images and virtual machine images using Podman and other utilities. It is also used inside Github Actions.

## Required Utilities

Container build:
- [just](https://just.systems/man/en/introduction.html)
- [podman](https://docs.podman.io/en/latest)
- [jq](https://jqlang.org)

These are usually preinstalled on Universal Blue's Bootc Images.

Linting:
- shfmt
- shellcheck

## Environment Variables

These are all sourced from the `image-template.env` file.

- `image_name`: The name of the image (default: "image-template").
- `default_tag`: The default tag for the image (default: "latest").
- `bib_image`: The Bootc Image Builder (BIB) image (default: "quay.io/centos-bootc/bootc-image-builder:latest").

## Building The Image

All these recipes will work (with default values) without supplying any arguments to them, e.g. `just build`

### `just build`

Builds a container image using Podman.

```bash
just build $target_image $tag
```

Arguments:
- `$target_image`: The tag you want to apply to the image (default: `$image_name`).
- `$tag`: The tag for the image (default: `$default_tag`).

### Rechunking
We can flatten the layers of container images to make sure there isn't a single huge layer when your image gets published.
This does not make your image faster to download, just provides better resumability.

#### `just ostree-rechunk`
Rechunks the existing Image with [rpm-ostree](https://coreos.github.io/rpm-ostree/build-chunked-oci/)

```bash
just ostree-rechunk $target_image $tag
```

#### `just rechunk`
Rechunks the existing Image with [chunkah](https://github.com/coreos/chunkah), this is probably gonna be the default here at some point, try it out, it's cool.

```bash
just rechunk $target_image $tag
```

### Switching to the locally built image for testing

The image has to be in the containers-storage owned by root, to be able to rebase to it, see the `_rootful_load_image` recipe.

`sudo just build` and `sudo just ostree-rechunk` builds directly as root and allows you to skip the transfer to the root containers-storage.

You can rebase to all the images that are in your containers-storage:

```
sudo podman image list --filter=label=containers.bootc=1
```

See [man bootc switch](https://bootc.dev/bootc/man/bootc-switch.8.html) for more info.

```
sudo bootc switch --transport containers-storage localhost/myimage:latest
```

and reboot your system!

## Building and Running Virtual Machines and ISOs

The below commands all build QCOW2 images. To produce or use a different type of image, substitute in the command with that type in the place of `qcow2`. The available types are `qcow2`, `iso`, and `raw`.

### `just build-qcow2`

Builds a QCOW2 virtual machine image.

```bash
just build-qcow2 $target_image $tag
```

### `just rebuild-qcow2`

Rebuilds a QCOW2 virtual machine image.

```bash
just rebuild-vm $target_image $tag
```

### `just run-vm-qcow2`

Runs a virtual machine from a QCOW2 image.

```bash
just run-vm-qcow2 $target_image $tag
```

### `just spawn-vm`

Runs a virtual machine using systemd-vmspawn.

```bash
just spawn-vm rebuild="0" type="qcow2" ram="6G"
```

## File Management

### `just check`

Checks the syntax of all `.just` files and the `Justfile`.

### `just fix`

Fixes the syntax of all `.just` files and the `Justfile`.

### `just clean`

Cleans the repository by removing build artifacts.

### `just lint`

Runs shell check on all Bash scripts.

### `just format`

Runs shfmt on all Bash scripts.te provides a way to upload the disk images that is generated from the workflow to a S3 bucket. The disk images will also be available as an artifact from the job, if you wish to use an alternate provider. To upload to S3 we use [rclone](https://rclone.org/) which is able to use [many S3 providers](https://rclone.org/s3/).
