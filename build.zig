const Builder = @import("std").build.Builder;
const builtin = @import("builtin");

pub fn build(b: *Builder) void {
    var gol = b.addExecutable("gameoflife", "gameoflife.zig");
    gol.setTarget(builtin.Arch.i386, builtin.Os.freestanding, builtin.Abi.gnu);
    gol.setLinkerScriptPath("linker.ld");
    gol.setOutputDir(".");
    b.default_step.dependOn(&gol.step);
}
