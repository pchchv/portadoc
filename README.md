<p align="center">
  portadoc
</p>

PDF viewer for terminals uses the Kitty image protocol.

# Features

* Page navigation (zoom, prev, next, etc.)
* Colorize mode (dark-mode)
* Filewatch (hot-reload)
* Custom keymappings
* Modal interface
* Runtime config
* Commands
* Status bar

# Installation

## Requirements

- Minimum Zig version — ***0.15.2***
- Terminal emulator with the *Kitty image protocol* (e.g. Kitty, Ghostty, WezTerm, etc.)

## Build

### 1. Fetch submodules:
```sh
git submodule update --init --recursive
```

### 2. Build the project:

```sh
zig build --release=small
```

***If the build fails with the error `LLVM ERROR: Do not know how to expand the result of this operator!` at step 7/10, try the following command instead:***

```sh
zig build -Dcpu="skylake" --release=small
```

### 3. Install (add to your PATH):

#### Linux
```sh
mv zig-out/bin/portadoc ~/.local/bin/
```

#### macOS
```sh
mv zig-out/bin/portadoc /usr/local/bin/
```

## Run

```sh
zig build run -- <path-to-pdf> <optional-page-number>
```

# Usage

```sh
portadoc <path-to-pdf> <optional-page-number>
```

# Configuration

portadoc can be configured through a JSON configuration file located in one of several locations (primary `$XDG_CONFIG_HOME/portadoc/config.json`, fallback `$HOME/.config/portadoc/config.json`, legacy `$HOME/.portadoc`).  
An empty configuration file is automatically created in the primary or fallback location on the first run.

An example [`config.json`](/docs/config.json) and [documentation](/docs/config.md) can be found in the [docs](/docs/) folder.