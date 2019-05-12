const MultibootHeader = packed struct {
    magic: u32,
    flags: u32,
    checksum: u32,
};

export const multiboot_header align(4) linksection(".multiboot") = MultibootHeader {
    .magic = 0x1badb002,
    .flags = 1,
    .checksum = 0x100000000 - (0x1badb002 + 1),
};

export var stack: [256]u8 align(16) linksection(".bss") = undefined;

export fn _start() noreturn {
    @newStackCall(stack[0..], gameoflife);
}

const mem = @import("std").mem;
extern var vga_buf: [4000]u8;
extern var buf: [4000]u8;

fn gameoflife() noreturn {
    var i: u16 = 0;
    while (i < 4000) {
        buf[i] = 0;
        i += 1;
        buf[i] = 15;
        i += 1;
    }
    for (vga_buf[0..4000]) |*b| b.* = 0;
    vga_buf[1322] = '#';
    vga_buf[1486] = '#';
    vga_buf[1640] = '#';
    vga_buf[1642] = '#';
    vga_buf[1648] = '#';
    vga_buf[1650] = '#';
    vga_buf[1652] = '#';
    while (true) {
        var sleep: u32 = 10000000;
        while (sleep > 0) {
            sleep = sleep -1;
        }
        var row: i16 = 0;
        var col: i16 = 0;
        while (row < 25) {
            while (col < 80) {
                if (vga_buf[@intCast(usize, col*2 + row*160)] == 0) {
                    if (neighs(row, col) == 3) {
                        buf[@intCast(usize, col*2 + row*160)] = '#';
                    }
                } else {
                    switch (neighs(row, col)) {
                        2, 3 => { buf[@intCast(usize, col*2 + row*160)] = '#';},
                        else => { buf[@intCast(usize, col*2 + row*160)] = 0;},
                    }
                }
                col = col + 1;
            }
            col = 0;
            row = row + 1;
        }
        mem.copy(u8, vga_buf[0..4000], buf[0..4000]);
    }
}

fn neighs(row: i16, col: i16) u8 {
    return @intCast(u8, @boolToInt(vga_buf[@intCast(usize, @mod(col-1,80)*2 + @mod(row-1,25)*160)] != 0)) +
           @intCast(u8, @boolToInt(vga_buf[@intCast(usize, col*2            + @mod(row-1,25)*160)] != 0)) +
           @intCast(u8, @boolToInt(vga_buf[@intCast(usize, @mod(col+1,80)*2 + @mod(row-1,25)*160)] != 0)) +
           @intCast(u8, @boolToInt(vga_buf[@intCast(usize, @mod(col-1,80)*2 + row*160           )] != 0)) +
           @intCast(u8, @boolToInt(vga_buf[@intCast(usize, @mod(col+1,80)*2 + row*160           )] != 0)) +
           @intCast(u8, @boolToInt(vga_buf[@intCast(usize, @mod(col-1,80)*2 + @mod(row+1,25)*160)] != 0)) +
           @intCast(u8, @boolToInt(vga_buf[@intCast(usize, col*2            + @mod(row+1,25)*160)] != 0)) +
           @intCast(u8, @boolToInt(vga_buf[@intCast(usize, @mod(col+1,80)*2 + @mod(row+1,25)*160)] != 0));
}
