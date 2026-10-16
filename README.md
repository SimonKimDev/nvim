# Neovim Configuration
This is my Neovim setup largely based and expanded on Josean Martinez's [blog post](https://www.josean.com/posts/how-to-setup-neovim-2024) and the [youtube video](https://www.youtube.com/watch?v=6pAG3BHurdM)

Other than small retouch the setup is virtually identitcal to Josean's setup, checkout his video for more detailed explanation on the setup.

## CI checks

Every pull request (and push to `main`) runs `.github/workflows/ci.yml`:

- **StyLua**: `stylua --check .` using `.stylua.toml`. Fix locally with `stylua .`.
- **Startup smoke test (Windows)**: installs every plugin from `lazy-lock.json` into empty directories, opens a Lua and a C# buffer, loads all plugins, and fails on any error. It also checks wiring that wouldn't raise an error: every mason-lspconfig server name resolves to an LSP config, Go/TSX/Lua buffers get the expected formatter, and web filetypes use 2-space indents. Mason package download failures are ignored because they depend on the network, not the config; language servers aren't installed in headless runs, so they're never started.

Run the smoke test locally from this directory:

```pwsh
nvim --headless --cmd "luafile tests/smoke.lua"
```

To hide the bulk reformat commit from `git blame`, run `git config blame.ignoreRevsFile .git-blame-ignore-revs`.
