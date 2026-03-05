const std = @import("std");

pub fn build(b: *std.Build) void {
    const prefix = "./local";
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    var useVendorMupdf = true;
    std.fs.cwd().access("./deps/mupdf/Makefile", .{}) catch |err| {
        if (err == error.FileNotFound) {
            useVendorMupdf = false;
        } else {
            std.debug.print("Error: {s}\n", .{@errorName(err)});
            return;
        }
    };
    const allocator = std.heap.page_allocator;
    var make_args: std.ArrayList([]const u8) = .empty;
    defer make_args.deinit(allocator);

    make_args.append(allocator, "make") catch unreachable;

    // use as many cores as possible by default (like zig) I dont know how to check for j<N> arg
    const cpu_count = std.Thread.getCpuCount() catch 1;
    make_args.append(allocator, b.fmt("-j{d}", .{cpu_count})) catch unreachable;
    make_args.append(allocator, "-C") catch unreachable;
    make_args.append(allocator, "deps/mupdf") catch unreachable;
    if (target.result.os.tag == .linux) {
        make_args.append(allocator, "HAVE_X11=no") catch unreachable;
        make_args.append(allocator, "HAVE_GLUT=no") catch unreachable;
    }

    make_args.append(allocator, "XCFLAGS=-w -DTOFU -DTOFU_CJK -DFZ_ENABLE_PDF=1 " ++
        "-DFZ_ENABLE_XPS=0 -DFZ_ENABLE_SVG=0 -DFZ_ENABLE_CBZ=0 " ++
        "-DFZ_ENABLE_IMG=0 -DFZ_ENABLE_HTML=0 -DFZ_ENABLE_EPUB=0") catch unreachable;
    make_args.append(allocator, "tools=no") catch unreachable;
    make_args.append(allocator, "apps=no") catch unreachable;

    const prefix_arg = b.fmt("prefix={s}", .{prefix});
    make_args.append(allocator, prefix_arg) catch unreachable;
    make_args.append(allocator, "install") catch unreachable;

    const exe = b.addExecutable(.{
        .name = "fancy-cat",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    exe.headerpad_max_install_names = true;
    if (target.result.os.tag == .macos) {
        exe.linkFramework("CoreGraphics");
    }

    exe.root_module.addAnonymousImport("metadata", .{ .root_source_file = b.path("build.zig.zon") });
    exe.addIncludePath(.{ .cwd_relative = "src/mupdf-z" });
    exe.addCSourceFile(.{ .file = .{ .cwd_relative = "src/mupdf-z/fitz-z.c" } });
}
