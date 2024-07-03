#!/bin/bash
pushd "$(dirname "$0")" > /dev/null
echo '/* Generated file, do not commit */' > qemu-riscv64.h
echo 'const unsigned char QEMU_RISCV64[] = {' >> qemu-riscv64.h
xxd -i - < `which qemu-riscv64` >> qemu-riscv64.h
echo '};' >> qemu-riscv64.h
gcc -static qemu-wrapper-embed.c -DQEMU_CPU=\"${QEMU_CPU}\" -O3 -s -o qemu-wrapper-embed
popd > /dev/null
