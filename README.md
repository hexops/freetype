# freetype packaged for the Zig build system

This is a fork of [freetype](https://github.com/freetype/freetype), packaged for Zig. Unnecessary files have been deleted, and the build system has been replaced with build.zig.

## Updating

To update this repository, we run the following:

```sh
git remote add upstream https://github.com/freetype/freetype || true
git fetch upstream
git merge upstream/master --strategy ours
```

## Verifying repository contents

For supply chain security reasons (e.g. to confirm we made no patches to the code) you can verify the contents of this repository by adding the upstream version as a remote:

```sh
git remote add upstream https://github.com/freetype/freetype || true
git fetch upstream
```

And then comparing using `git diff` with some options to _exclude deleted files_, and exclude `README.md`, `build.zig`, and `.gitignore` from the diff:

```sh
git diff $(git merge-base origin/master upstream/master)..origin/master \
    --diff-filter=d \
    ':(exclude)README.md' \
    ':(exclude)build.zig' \
    ':(exclude)build.zig.zon' \
    ':(exclude).gitignore'
```
