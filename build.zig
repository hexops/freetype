const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const use_system_zlib = b.option(bool, "use_system_zlib", "Use system zlib") orelse false;
    const enable_brotli = b.option(bool, "enable_brotli", "Build Brotli") orelse true;

    const brotli_dep = b.dependency("brotli", .{ .target = target, .optimize = optimize });

    const lib = b.addStaticLibrary(.{
        .name = "freetype",
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibC();
    lib.addIncludePath(.{ .path = "include" });
    lib.defineCMacro("FT2_BUILD_LIBRARY", "1");

    if (use_system_zlib) {
        lib.defineCMacro("FT_CONFIG_OPTION_SYSTEM_ZLIB", "1");
    }

    if (enable_brotli) {
        lib.defineCMacro("FT_CONFIG_OPTION_USE_BROTLI", "1");
        lib.linkLibrary(brotli_dep.artifact("brotli"));
    }

    lib.defineCMacro("HAVE_UNISTD_H", "1");
    lib.addCSourceFiles(&sources, &.{});
    if (target.toTarget().os.tag == .macos) lib.addCSourceFile(.{
        .file = .{ .path = "src/base/ftmac.c" },
        .flags = &.{},
    });
    lib.installHeadersDirectory("include/freetype", "freetype");
    lib.installHeader("include/ft2build.h", "ft2build.h");
    b.installArtifact(lib);
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
    sdkPath("/src/autofit/autofit.c"),
    sdkPath("/src/base/ftbase.c"),
    sdkPath("/src/base/ftsystem.c"),
    sdkPath("/src/base/ftdebug.c"),
    sdkPath("/src/base/ftbbox.c"),
    sdkPath("/src/base/ftbdf.c"),
    sdkPath("/src/base/ftbitmap.c"),
    sdkPath("/src/base/ftcid.c"),
    sdkPath("/src/base/ftfstype.c"),
    sdkPath("/src/base/ftgasp.c"),
    sdkPath("/src/base/ftglyph.c"),
    sdkPath("/src/base/ftgxval.c"),
    sdkPath("/src/base/ftinit.c"),
    sdkPath("/src/base/ftmm.c"),
    sdkPath("/src/base/ftotval.c"),
    sdkPath("/src/base/ftpatent.c"),
    sdkPath("/src/base/ftpfr.c"),
    sdkPath("/src/base/ftstroke.c"),
    sdkPath("/src/base/ftsynth.c"),
    sdkPath("/src/base/fttype1.c"),
    sdkPath("/src/base/ftwinfnt.c"),
    sdkPath("/src/bdf/bdf.c"),
    sdkPath("/src/bzip2/ftbzip2.c"),
    sdkPath("/src/cache/ftcache.c"),
    sdkPath("/src/cff/cff.c"),
    sdkPath("/src/cid/type1cid.c"),
    sdkPath("/src/gzip/ftgzip.c"),
    sdkPath("/src/lzw/ftlzw.c"),
    sdkPath("/src/pcf/pcf.c"),
    sdkPath("/src/pfr/pfr.c"),
    sdkPath("/src/psaux/psaux.c"),
    sdkPath("/src/pshinter/pshinter.c"),
    sdkPath("/src/psnames/psnames.c"),
    sdkPath("/src/raster/raster.c"),
    sdkPath("/src/sdf/sdf.c"),
    sdkPath("/src/sfnt/sfnt.c"),
    sdkPath("/src/smooth/smooth.c"),
    sdkPath("/src/svg/svg.c"),
    sdkPath("/src/truetype/truetype.c"),
    sdkPath("/src/type1/type1.c"),
    sdkPath("/src/type42/type42.c"),
    sdkPath("/src/winfonts/winfnt.c"),
};
