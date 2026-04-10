#!/bin/bash
set -xue

TIMEOUT=""
for arg in "$@"; do
    case "$arg" in
        --timeout)
            TIMEOUT="timeout --signal=KILL 5"
            ;;
        *)
            echo "Unknown option: $arg" >&2
            exit 1
            ;;
    esac
done

QEMU=qemu-system-riscv32
CC=clang
CFLAGS="-std=c11 -O2 -g3 -Wall -Wextra --target=riscv32-unknown-elf -fuse-ld=lld -fno-stack-protector -ffreestanding -nostdlib"

${CC} ${CFLAGS} -Wl,-Tkernel.ld -Wl,-Map=kernel.map -o kernel.elf kernel.c

${TIMEOUT} ${QEMU} -machine virt -bios default -nographic -serial mon:stdio --no-reboot -kernel kernel.elf || [ -n "${TIMEOUT}" ]
