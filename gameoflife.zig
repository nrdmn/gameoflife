export const multiboot_header align(4) linksection(".multiboot") = packed struct {
    magic: u32,
    flags: u32,
    checksum: u32,
} {
    .magic = 0x1badb002,
    .flags = 0,
    .checksum = 0x100000000 - 0x1badb002,
};

const World = packed struct {
    buf: [4000]u8,

    fn init() World {
        return World {
            .buf = ([]u8{0, 15}) ** 2000,
        };
    }

    fn get(self: World, x: i8, y: i8) bool {
        return self.buf[(@intCast(usize, @mod(x, 80)) + @intCast(usize, @mod(y, 25))*80)*2] != 0;
    }

    fn set(self: *World, x: i8, y: i8) void {
        self.buf[(@intCast(usize, @mod(x, 80)) + @intCast(usize, @mod(y, 25))*80)*2] = '#';
    }

    fn neighs(self: World, x: i8, y: i8) u8 {
        var count: u8 = 0;
        for ([][2]i8{
            []i8{x-1, y-1}, []i8{x, y-1}, []i8{x+1, y-1},
            []i8{x-1, y  },               []i8{x+1, y  },
            []i8{x-1, y+1}, []i8{x, y+1}, []i8{x+1, y+1},
        }) |c| {
            if (self.get(c[0], c[1])) {
                count += 1;
            }
        }
        return count;
    }

    fn step(self: *World) void {
        var buf = World.init();

        var row: i8 = 0;
        var col: i8 = 0;
        while (row < 25) {
            while (col < 80) {
                if (self.get(col, row)) {
                    switch (self.neighs(col, row)) {
                        2, 3 => { buf.set(col, row); },
                        else => { },
                    }
                } else {
                    if (self.neighs(col, row) == 3) {
                        buf.set(col, row);
                    }
                }
                col += 1;
            }
            col = 0;
            row += 1;
        }

        @import("std").mem.copy(u8, self.buf[0..4000], buf.buf[0..4000]);
    }
};

extern var vga_buf: World;
var stack: [8192]u8 align(16) linksection(".bss") = undefined;

export nakedcc fn _start() noreturn {
    @newStackCall(stack[0..], gameoflife);
}

fn gameoflife() noreturn {
    asm volatile("out %%ax, %%dx"
        :
        : [_] "{ax}" (@intCast(u16, 0x200a)), [_] "{dx}" (@intCast(u16, 0x3d4))
        : "dx", "ax"
    );

    vga_buf = World.init();

    vga_buf.set(21, 8);
    vga_buf.set(23, 9);
    vga_buf.set(20, 10);
    vga_buf.set(21, 10);
    vga_buf.set(24, 10);
    vga_buf.set(25, 10);
    vga_buf.set(26, 10);

    while (true) {
        var sleep: u32 = 10000000;
        while (sleep > 0) {
            sleep -= 1;
        }

        vga_buf.step();
    }
}
