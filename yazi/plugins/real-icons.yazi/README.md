<div align="center">

# real-icons.yazi

**Real image icons for Yazi, powered by the Kitty Graphics Protocol.**

[![Yazi 26.1.22+](https://img.shields.io/badge/Yazi-26.1.22%2B-ffcc66)](https://yazi-rs.github.io/)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/Mirsmog/real-icons.yazi?style=flat&logo=github)](https://github.com/Mirsmog/real-icons.yazi/stargazers)

</div>

<p align="center">
  <img src="media/preview.webp" alt="Real image icons rendered in Yazi with the Flow Deep theme" width="100%">
</p>

<p align="center">
  <sub>Flow Deep icons rendered in Yazi</sub>
</p>

`real-icons.yazi` renders PNG and SVG file icons in Yazi without relying on a
patched font. It can load installed VS Code icon themes, switch packs from an
interactive picker, and fall back to Yazi's native icons when image rendering
is unavailable.

## Highlights

- Original colors and shapes from real image assets
- Automatic discovery of VS Code, VSCodium, Cursor, and Windsurf icon themes
- Interactive pack picker with live switching and persistent selection
- Non-blocking SVG conversion with a persistent PNG cache
- Ghostty, Kitty, and tmux passthrough support
- Native Yazi icon fallback in unsupported terminals

## Requirements

- Yazi 26.1.22 or newer
- Ghostty or Kitty with Kitty Unicode placeholder support
- [`resvg`](https://github.com/linebender/resvg) for SVG conversion, or
  ImageMagick as a fallback
- `find`, available in the standard GNU or BSD userland

When Yazi runs inside tmux, enable graphics passthrough:

```tmux
set -g allow-passthrough on
```

## Installation

Install with the Yazi package manager:

```sh
ya pkg add Mirsmog/real-icons
```

Enable the plugin in `~/.config/yazi/init.lua`:

```lua
require("real-icons"):setup()
```

The bundled icon pack works immediately. No additional theme is required.

For local development, link the repository into the plugin directory:

```sh
ln -s /path/to/real-icons.yazi ~/.config/yazi/plugins/real-icons.yazi
```

## Pack picker

Add a shortcut to `~/.config/yazi/keymap.toml`:

```toml
[[mgr.prepend_keymap]]
on = [ "g", "P" ]
run = "plugin real-icons -- packs"
desc = "Choose icon pack"
```

The picker discovers compatible themes in the standard extension directories,
shows their source and coverage, and applies the selected pack immediately.
The choice is restored the next time Yazi starts.

Picker controls:

| Key | Action |
| --- | --- |
| `j`, `Down` | Next pack |
| `k`, `Up` | Previous pack |
| `g`, `G` | First or last pack |
| `Enter`, `l` | Select pack |
| `q`, `Esc` | Close |

## VS Code themes

The picker finds installed themes automatically. A theme at a custom path can
also be declared explicitly:

```lua
require("real-icons"):setup {
	pack = "flow-deep",
	packs = {
		["flow-deep"] = {
			type = "vscode",
			path = "~/.vscode/extensions/thang-nm.flow-icons-2.0.3",
			theme = "flow-deep",
		},
	},
}
```

The loader supports `iconDefinitions`, `fileNames`, `fileExtensions`,
`folderNames`, and `languageIds` from VS Code icon theme manifests.

## Local icon packs

A simple pack maps files, extensions, and folders directly to local assets:

```lua
require("real-icons"):setup {
	pack = "personal",
	packs = {
		personal = {
			type = "simple",
			path = "~/Pictures/icons",
			file = "file.png",
			folder = "folder.png",
			extensions = {
				lua = "lua.svg",
				rs = "rust.svg",
			},
			files = {
				["README.md"] = "readme.svg",
			},
			folders = {
				src = "folder-src.svg",
			},
		},
	},
}
```

PNG, SVG, JPEG, and WebP assets are supported. Relative paths are resolved
inside the pack directory.

## Configuration

```lua
require("real-icons"):setup {
	pack = "builtin",
	backend = "auto",
	remember = true,
	size = {
		cols = 2,
		rows = 1,
		pixels = 64,
	},
	fallback = true,
	cache_dir = "~/.cache/real-icons/yazi",
	state_file = "~/.local/state/real-icons/yazi-pack.json",
	overrides = {
		files = {},
		extensions = {},
		folders = {},
		definitions = {},
	},
}
```

| Option | Default | Description |
| --- | --- | --- |
| `pack` | `"builtin"` | Initial pack name |
| `packs` | `{}` | Named VS Code or simple pack definitions |
| `backend` | `"auto"` | `auto`, `kitty`, or `disabled` |
| `remember` | `true` | Persist choices made in the pack picker |
| `size.cols` | `2` | Terminal cells reserved for an icon, from 1 to 3 |
| `size.pixels` | `64` | Cached image size, from 16 to 256 pixels |
| `fallback` | `true` | Use Yazi icons when an image is unavailable |
| `discovery_roots` | standard editor paths | Directories scanned by the pack picker |
| `cache_dir` | XDG cache directory | Generated PNG cache |
| `state_file` | XDG state directory | Saved picker selection |

To scan additional extension directories:

```lua
require("real-icons"):setup {
	discovery_roots = {
		"~/.vscode/extensions",
		"~/Applications/my-editor/extensions",
	},
}
```

## Commands

| Command | Purpose |
| --- | --- |
| `plugin real-icons -- packs` | Discover, inspect, and switch icon packs |
| `plugin real-icons -- doctor` | Show pack, terminal, and cache diagnostics |
| `plugin real-icons -- build-cache` | Pre-render every icon in the active pack |
| `plugin real-icons -- clear-cache` | Remove generated icon files |

## Rendering and cache

The file list never waits for image conversion. When an uncached SVG appears,
Yazi keeps its native icon for that frame while conversion runs in a separate
process. The completed PNG is moved into the cache atomically and Yazi redraws
the list. Cached icons require only table lookups and a Kitty placeholder.

Run `build-cache` if every icon should be ready before the first visit.

## Terminal notes

Kitty Unicode placeholders store the image ID in the foreground RGB value.
For that reason, `NO_COLOR` must not be present in Yazi's environment:

```sh
env -u NO_COLOR yazi
```

If the terminal or protocol is unsupported, the plugin leaves Yazi's normal
icons in place.

## Development

Run the syntax checks and unit tests with:

```sh
make test
```

## License

[MIT](LICENSE). External icon themes remain under their upstream licenses.
See [THIRD_PARTY.md](THIRD_PARTY.md) for bundled asset attribution.
