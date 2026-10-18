# Copilot instructions

Personal Neovim config (Lua, lazy.nvim) for Neovim 0.12+, used on Windows with pwsh for C#/.NET, Go, Rust and Vite/React work. CI checks are described in `README.md`.

## Layout

- `init.lua` loads `lua/simonkdev/`: `options.lua`, `keymaps.lua`, `autocmds.lua`, then `lazy_init.lua`, which bootstraps lazy.nvim.
- Plugin specs live in `lua/simonkdev/lazy/`, with `lsp/` and `debugger/` subfolders. Each file returns a lazy.nvim spec.
- Language servers are installed and enabled by mason-lspconfig (`lazy/lsp/mason.lua`) and configured with `vim.lsp.config` (`lazy/lsp/lspconfig.lua`). The exception is Rust: rustaceanvim (`lazy/rust.lua`) runs the toolchain's rust-analyzer, so never add `rust_analyzer` to mason-lspconfig.
- Per-filetype settings go in `after/ftplugin/<filetype>.lua`.
- `lazy-lock.json` pins every plugin's commit. `tests/smoke.lua` is the headless startup test.
- Treesitter uses nvim-treesitter's `main` branch: it only installs parsers (`lazy/treesitter.lua`), and Neovim's built-in treesitter does highlighting, started per buffer from a FileType autocmd. There is no `nvim-treesitter.configs`.
- `.github/agents/pr-reviewer.agent.md` defines the AI PR reviewer; the workflows that run it are `.github/workflows/pr-review*.md`.

## Git

- Name branches `simonk/dev/<what-youre-doing>` in kebab-case, e.g. `simonk/dev/add-smoke-assertions`. If a tool manages the local branch name, push with `git push -u origin HEAD:simonk/dev/<what-youre-doing>` and open the PR from that branch.
- Commit and push only as the personal `SimonKimDev` GitHub account, never a work account.
- Merge PRs with a merge commit, not squash or rebase. `.git-blame-ignore-revs` lists commit SHAs that must stay on `main`.
- Don't reuse `simonk/dev/plugin-update`; the plugin update workflow owns it.

## Checks

- Format Lua with `stylua .`. CI runs `stylua --check .` with StyLua 2.3.0.
- `nvim --headless --cmd "luafile tests/smoke.lua"` must print `smoke: OK`.
