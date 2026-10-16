# Copilot instructions

Personal Neovim config (Lua, lazy.nvim), used on Windows with pwsh. CI checks are described in `README.md`.

## Git

- Name branches `simonk/dev/<what-youre-doing>` in kebab-case, e.g. `simonk/dev/add-smoke-assertions`. If a tool manages the local branch name, push with `git push -u origin HEAD:simonk/dev/<what-youre-doing>` and open the PR from that branch.
- Commit and push only as the personal `SimonKimDev` GitHub account, never a work account.
- Merge PRs with a merge commit, not squash or rebase. `.git-blame-ignore-revs` lists commit SHAs that must stay on `main`.

## Checks

- Format Lua with `stylua .`. CI runs `stylua --check .` with StyLua 2.3.0.
- `nvim --headless --cmd "luafile tests/smoke.lua"` must print `smoke: OK`.
