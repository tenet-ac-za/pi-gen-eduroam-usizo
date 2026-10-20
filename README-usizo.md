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
# To build proxyguard
apt install golang
```

Then build the image using:
```sh
./build.sh -c config-usizo
```

## Configuring a device before deployment

Two config files are needed when deploying a usizo device, both located in `/boot` of the booted image
(i.e. the root of the SD card after it is flashed).

### usizo.cfg

This configures the usizo device, and at the very least needs Wi-Fi credentials in `PASSWORD`. This should
correspond to the credentials set on web-cpt-02.eduroam.ac.za in the `/etc/freeradius/users_usizo` file.

Some other options can be set. See [defaults](usizo0/00-configure-usizo/files/defaults) for a full set.

# eduvpn.conf

This is a wireguard+proxyguard configuration file obtained from eduvpn.tenet.ac.za.
It can be generated as follows:

```sh
ubuntu@eduvpn-cpt-01$ sudo /usr/local/bin/vpn-generate-profile -e T0001234 > eduvpn.conf
```
