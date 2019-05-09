# Bootable Game of Life in Zig

![demo](gameoflife.gif)

This is a bootable Game of Life written in [Zig](https://github.com/ziglang/zig) using the [GNU Multiboot](https://www.gnu.org/software/grub/manual/multiboot/multiboot.html) standard.

Build with `zig build`, run with `qemu-system-x86_64 -curses -kernel gameoflife`.
