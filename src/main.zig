const std = @import("std");
const can = @import("can");
const Io = std.Io;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const arena = init.arena.allocator();
    const args = try init.minimal.args.toSlice(arena);
    if (args.len != 2) {
        std.debug.print("usage: zcandump <interface>\n", .{});
        return;
    }

    const interface_name = args[1];

    var can_sock = try can.Socket.open(io, interface_name);
    defer can_sock.deinit();

    var frame: can.Frame = undefined;
    while (true) {
        _ = try can_sock.readFrame(&frame);

        std.debug.print("  {s}  {X:03}   [{d}]  ", .{
            interface_name, frame.can_id, frame.len,
        });

        for (frame.data[0..frame.len]) |char| {
            std.debug.print("{X} ", .{char});
        }

        std.debug.print("\n", .{});
    }
}
