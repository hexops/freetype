const std = @import("std");

pub var brotli_import_path: []const u8 = "brotli";

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const use_system_zlib = b.option(bool, "use_system_zlib", "Use system zlib") orelse false;
    const enable_brotli = b.option(bool, "enable_brotli", "Build Brotli") orelse true;

    // TODO: we cannot call b.dependency() inside of `pub fn build`
    // if we want users of the package to be able to make use of it.
    // See hexops/mach#902
    _ = target;
    _ = optimize;
    _ = use_system_zlib;
    _ = enable_brotli;

    // const brotli_dep = b.dependency("brotli", .{ .target = target, .optimize = optimize });

    // const lib = b.addStaticLibrary(.{
    //     .name = "freetype",
    //     .target = target,
    //     .optimize = optimize,
    // });
    // lib.linkLibC();
    // lib.addIncludePath(.{ .path = "include" });
    // lib.defineCMacro("FT2_BUILD_LIBRARY", "1");

    // if (use_system_zlib) {
    //     lib.defineCMacro("FT_CONFIG_OPTION_SYSTEM_ZLIB", "1");
    // }

    // if (enable_brotli) {
    //     lib.defineCMacro("FT_CONFIG_OPTION_USE_BROTLI", "1");
    //     lib.linkLibrary(brotli_dep.artifact("brotli"));
    // }

    // lib.defineCMacro("HAVE_UNISTD_H", "1");
    // lib.addCSourceFiles(&sources, &.{});
    // if (target.toTarget().os.tag == .macos) lib.addCSourceFile(.{
    //     .file = .{ .path = "src/base/ftmac.c" },
    //     .flags = &.{},
    // });
    // lib.installHeadersDirectory("include/freetype", "freetype");
    // lib.installHeader("include/ft2build.h", "ft2build.h");
    // b.installArtifact(lib);
}

// TODO: remove this once hexops/mach#902 is fixed.
pub fn lib(
    b: *std.Build,
    optimize: std.builtin.OptimizeMode,
    target: std.zig.CrossTarget,
) *std.Build.Step.Compile {
    const enable_brotli = true;
    const use_system_zlib = false;
    const brotli_dep = b.dependency(brotli_import_path, .{ .target = target, .optimize = optimize });

    const l = b.addStaticLibrary(.{
        .name = "freetype",
        .target = target,
        .optimize = optimize,
    });
    l.linkLibC();
    l.addIncludePath(.{ .path = "include" });
    l.defineCMacro("FT2_BUILD_LIBRARY", "1");

    if (use_system_zlib) {
        l.defineCMacro("FT_CONFIG_OPTION_SYSTEM_ZLIB", "1");
    }

    if (enable_brotli) {
        l.defineCMacro("FT_CONFIG_OPTION_USE_BROTLI", "1");
        l.linkLibrary(brotli_dep.artifact("brotli"));
    }

    l.defineCMacro("HAVE_UNISTD_H", "1");
    l.addCSourceFiles(&sources, &.{});
    if (target.toTarget().os.tag == .macos) l.addCSourceFile(.{
        .file = .{ .path = "src/base/ftmac.c" },
        .flags = &.{},
    });
    return l;
}

pub fn addPaths(step: *std.build.CompileStep) void {
    step.addIncludePath(.{ .path = sdkPath("/include/freetype") });
    step.addIncludePath(.{ .path = sdkPath("/include") });
}

fn sdkPath(comptime suffix: []const u8) []const u8 {
    if (suffix[0] != '/') @compileError("suffix must be an absolute path");
    return comptime blk: {
        const root_dir = std.fs.path.dirname(@src().file) orelse ".";
        break :blk root_dir ++ suffix;
    };
}

const sources = [_][]const u8{
    "src/autofit/autofit.c",
    "src/base/ftbase.c",
    "src/base/ftsystem.c",
    "src/base/ftdebug.c",
    "src/base/ftbbox.c",
    "src/base/ftbdf.c",
    "src/base/ftbitmap.c",
    "src/base/ftcid.c",
    "src/base/ftfstype.c",
    "src/base/ftgasp.c",
    "src/base/ftglyph.c",
    "src/base/ftgxval.c",
    "src/base/ftinit.c",
    "src/base/ftmm.c",
    "src/base/ftotval.c",
    "src/base/ftpatent.c",
    "src/base/ftpfr.c",
    "src/base/ftstroke.c",
    "src/base/ftsynth.c",
    "src/base/fttype1.c",
    "src/base/ftwinfnt.c",
    "src/bdf/bdf.c",
    "src/bzip2/ftbzip2.c",
    "src/cache/ftcache.c",
    "src/cff/cff.c",
    "src/cid/type1cid.c",
    "src/gzip/ftgzip.c",
    "src/lzw/ftlzw.c",
    "src/pcf/pcf.c",
    "src/pfr/pfr.c",
    "src/psaux/psaux.c",
    "src/pshinter/pshinter.c",
    "src/psnames/psnames.c",
    "src/raster/raster.c",
    "src/sdf/sdf.c",
    "src/sfnt/sfnt.c",
    "src/smooth/smooth.c",
    "src/svg/svg.c",
    "src/truetype/truetype.c",
    "src/type1/type1.c",
    "src/type42/type42.c",
    "src/winfonts/winfnt.c",
};
