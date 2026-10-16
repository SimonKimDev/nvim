# Copilot instructions

Personal Neovim config (Lua, lazy.nvim), used on Windows with pwsh for C#/.NET, Go and Vite/React work. CI checks are described in `README.md`.

## Layout

- `init.lua` loads `lua/simonkdev/`: `options.lua`, `keymaps.lua`, `autocmds.lua`, then `lazy_init.lua`, which bootstraps lazy.nvim.
- Plugin specs live in `lua/simonkdev/lazy/`, with `lsp/` and `debugger/` subfolders. Each file returns a lazy.nvim spec.
- Language servers are installed and enabled by mason-lspconfig (`lazy/lsp/mason.lua`) and configured with `vim.lsp.config` (`lazy/lsp/lspconfig.lua`).
- Per-filetype settings go in `after/ftplugin/<filetype>.lua`.
- `lazy-lock.json` pins every plugin's commit. `tests/smoke.lua` is the headless startup test.
- `.github/agents/pr-reviewer.agent.md` defines the AI PR reviewer; the workflows that run it are `.github/workflows/pr-review*.md`.

## Git

- Name branches `simonk/dev/<what-youre-doing>` in kebab-case, e.g. `simonk/dev/add-smoke-assertions`. If a tool manages the local branch name, push with `git push -u origin HEAD:simonk/dev/<what-youre-doing>` and open the PR from that branch.
- Commit and push only as the personal `SimonKimDev` GitHub account, never a work account.
- Merge PRs with a merge commit, not squash or rebase. `.git-blame-ignore-revs` lists commit SHAs that must stay on `main`.

## Checks

- Format Lua with `stylua .`. CI runs `stylua --check .` with StyLua 2.3.0.
- `nvim --headless --cmd "luafile tests/smoke.lua"` must print `smoke: OK`.
