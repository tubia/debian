#!/bin/bash -x
### Build a docker image for debian i386.

### settings
arch=i386
suite=wheezy
chroot_dir='/var/chroot/wheezy'
apt_mirror='http://http.debian.net/debian'
docker_image='tubia/debian:wheezy'

### make sure that the required tools are installed
apt-get install -y docker.io debootstrap dchroot

### install a minbase system with debootstrap
export DEBIAN_FRONTEND=noninteractive
debootstrap --arch $arch $suite $chroot_dir $apt_mirror

### update the list of package sources
cat <<EOF > $chroot_dir/etc/apt/sources.list
deb $apt_mirror wheezy main contrib non-free
deb $apt_mirror wheezy-updates main contrib non-free
deb http://security.debian.org/ wheezy/updates main contrib non-free
EOF

### cleanup
chroot $chroot_dir apt-get autoclean
chroot $chroot_dir apt-get clean
chroot $chroot_dir apt-get autoremove

### create a tar archive from the chroot directory
tar cfz debian.tgz -C $chroot_dir .

### import this tar archive into a docker image:
cat debian.tgz | docker import - $docker_image

# ### push image to Docker Hub
# docker push $docker_image

# ### cleanup
# rm debian.tgz
# rm -rf $chroot_dir
