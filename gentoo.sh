#!/bin/bash

CHROOTDIR=chroot
BOS_ARCH="rv64_lp64d"
BOS_COMMON_FLAGS="-O3 -march=rv64gcv_zvl256b -pipe"
BOS_QEMU_CPU="rv64,v=true,vlen=256,vext_spec=v1.0"

clean() {
	umount ${CHROOTDIR}/dev/shm
	umount ${CHROOTDIR}/dev/pts
	umount ${CHROOTDIR}/dev
	umount ${CHROOTDIR}/sys
	umount ${CHROOTDIR}/proc
	rm -rf ${CHROOTDIR}
	rm -rf stage3-*
}

fetch() {
	BOS_STAGE3_IMAGE="https://distfiles.gentoo.org/releases/riscv/autobuilds/current-stage3-${BOS_ARCH}-openrc/latest-stage3-${BOS_ARCH}-openrc.txt"
	STAGE3_FILE=$(curl ${BOS_STAGE3_IMAGE} -s -f | grep -B1 'BEGIN PGP SIGNATURE' | head -n 1 | cut -d\  -f 1)
	STAGE3_URL="https://distfiles.gentoo.org/releases/riscv/autobuilds/current-stage3-${BOS_ARCH}-openrc/${STAGE3_FILE}"
	wget ${STAGE3_URL}
}

unpack() {
	mkdir ${CHROOTDIR}
	cd ${CHROOTDIR}
	tar xpvf ../stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
	cd ..
}

prepare() {
	sed -i -e "s:COMMON_FLAGS=.*:COMMON_FLAGS=\"${BOS_COMMON_FLAGS}\":" ${CHROOTDIR}/etc/portage/make.conf
	QEMU_CPU=${BOS_QEMU_CPU} src/mk.sh
	mv src/qemu-wrapper-embed ${CHROOTDIR}/usr/bin/qemu-riscv64
	cp /etc/resolv.conf ${CHROOTDIR}/etc
	mount --bind /proc ${CHROOTDIR}/proc
	mount --bind /sys ${CHROOTDIR}/sys
	mount --bind /dev ${CHROOTDIR}/dev
	mount --bind /dev/pts ${CHROOTDIR}/dev/pts
	mount --bind /dev/shm ${CHROOTDIR}/dev/shm
	cp bin/chroot.sh ${CHROOTDIR}/tmp
	rsync -a etc/portage/ ${CHROOTDIR}/etc/portage/
}

compile() {
	chroot ${CHROOTDIR} /tmp/chroot.sh
}

post_inst() {
	umount ${CHROOTDIR}/dev/shm
	umount ${CHROOTDIR}/dev/pts
	umount ${CHROOTDIR}/dev
	umount ${CHROOTDIR}/sys
	umount ${CHROOTDIR}/proc
}

clean
fetch
unpack
prepare
compile
post_inst
