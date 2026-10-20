# Generating an using the usizo image

## Building an image

On any of the Ubuntu dev box, install the packages listed in [README.md](README.md):
```
# depdencies per README.md
apt install coreutils quilt parted qemu-user-binfmt debootstrap zerofree zip \
dosfstools e2fsprogs libcap2-bin grep rsync xz-utils file git curl bc \
gpg pigz xxd arch-test bmap-tools kmod
```

And install the following extra packages
```
# Deal with architecture differences
apt install binfmt-support qemu-user-binfmt qemu-user-static
# Configure APT_PROXY per config file
apt install apt-cacher
```

Then build the image using:
```sh
./build.sh -c config-usizo
```

