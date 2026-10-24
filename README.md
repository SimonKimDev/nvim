# Neovim Configuration
This is my Neovim setup largely based and expanded on Josean Martinez's [blog post](https://www.josean.com/posts/how-to-setup-neovim-2024) and the [youtube video](https://www.youtube.com/watch?v=6pAG3BHurdM)

Other than small retouch the setup is virtually identitcal to Josean's setup, checkout his video for more detailed explanation on the setup.

## Requirements

- Neovim 0.12 or later.
- A C compiler on `PATH` (e.g. gcc from MinGW) to build treesitter parsers and telescope-fzf-native. Without MSVC, the config points tree-sitter at gcc by setting `CC`. nvim-treesitter also needs the `tree-sitter` CLI, which Mason installs; on a fresh machine parsers install once Mason has it.
- For Rust, rust-analyzer from your toolchain: `rustup component add rust-analyzer`. rustaceanvim starts it (and Mason's codelldb for debugging); don't install rust-analyzer through Mason.
- For octo.nvim (GitHub issues and PRs, `<leader>o…`), the [GitHub CLI](https://cli.github.com/), logged in with `gh auth login`.
- For C#, the .NET 10 SDK, which the pinned Roslyn needs to install and run. Mason installs Roslyn (the language server VS Code's C# extension uses) when `dotnet` is on `PATH`, and netcoredbg. `<leader>dc` in a C# file offers *Build and debug a project*: pick a runnable project from the solution, and it builds it (build errors go to quickfix) and starts the debugger on its output.

## WSL

The same config runs in WSL (Ubuntu 24.04):

- **Neovim** comes from Homebrew (`brew install neovim`), which `~/.bashrc` puts on `PATH` with `eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"`. Upgrade it with `brew upgrade neovim`; CI tests the release pinned in `.github/actions/setup-nvim/action.yml`.
- **Config**: a clone of this repo in `~/.config/nvim`. Update it with `git -C ~/.config/nvim pull`, then run `:Lazy restore` to check out the plugin commits in `lazy-lock.json`. Mason installs the language servers on the first interactive start (mason-lspconfig skips them in headless runs). Plugins, Mason packages and parsers live in `~/.local/share/nvim`; to reinstall them from scratch, move its `lazy`, `mason` and `site` folders aside and restart.
- **Tools**: `build-essential`, `unzip`, `ripgrep` and `fd-find` from apt (with `fdfind` linked as `~/.local/bin/fd`), Node.js from nvm for Mason's npm packages, Go, rustup with rust-analyzer, lazygit (`brew install lazygit`) and the GitHub CLI (`brew install gh`). Without `dotnet`, Mason skips Roslyn, so C# has no language server.
- **Clipboard**: `unnamedplus` goes through `win32yank.exe` from the Windows Neovim install, which WSL finds on the Windows `PATH`.

## Updates

- **Plugins**: `.github/workflows/plugin-update.yml` runs `:Lazy update` every Monday (or on demand from the Actions tab), commits the new `lazy-lock.json` to `simonk/dev/plugin-update`, and opens or refreshes an *Update plugins* PR that links each plugin's changes. CI runs on that PR, so the smoke test covers the new commits; merge it if it's green. The workflow force-pushes the branch each week, but leaves it alone once it has a commit from anyone else, so you can push a fix to it. It needs **Allow GitHub Actions to create and approve pull requests** turned on in Settings → Actions → General.
- **GitHub Actions**: Dependabot (`.github/dependabot.yml`) opens one grouped PR a month for the actions used in workflows and `.github/actions/`. It skips generated `*.lock.yml` workflows, because `gh aw compile` would overwrite its edits; refresh those with `gh aw upgrade`. Dependabot can't update lazy.nvim plugins, hence the workflow above.

## CI checks

Every pull request (and push to `main`) runs `.github/workflows/ci.yml`:

- **StyLua**: `stylua --check .` using `.stylua.toml`. Fix locally with `stylua .`.
- **Startup smoke test (Windows)**: installs every plugin from `lazy-lock.json` and every treesitter parser into empty directories, opens a Lua and a C# buffer, loads all plugins, and fails on any error. It also checks wiring that wouldn't raise an error: every mason-lspconfig server name resolves to an LSP config, Go/TSX/Lua/Rust buffers get the expected formatter and treesitter highlighting, files without a formatter get trailing whitespace trimmed (patches excepted), and web filetypes use 2-space indents. Mason package download failures are ignored because they depend on the network, not the config; language servers aren't installed in headless runs, so they're never started.

Run the smoke test locally from this directory:

```pwsh
nvim --headless --cmd "luafile tests/smoke.lua"
```

In WSL, run the same command from `~/.config/nvim`.

To hide the bulk reformat commit from `git blame`, run `git config blame.ignoreRevsFile .git-blame-ignore-revs`.

## AI PR review

`pr-review-command.md` in `.github/workflows/` is an AI reviewer written as [GitHub Agentic Workflows](https://github.github.com/gh-aw/). It only runs when you comment `/review` on a PR (drafts included), so it never uses premium requests on its own. It only comments; it never approves or blocks.

- How it works (`shared/pr-review.md`): two reviewers on different models (`claude-reviewer`, `gpt-reviewer`) review the PR independently. A lead agent merges their findings, asks each reviewer to check what only the other found, verifies disputes against the code, and posts the result with a *Review context and counts* table. `Consensus reached: False` or a low confidence score means the round deserves a second look; comment `/review` to retry.
- The review criteria live in `.github/agents/pr-reviewer.agent.md`, which is also available in the repo's Agents tab. The sub-agents' task and output format are in `shared/pr-reviewer-subagent.md`.
- Models are pinned: the lead's in `pr-review-command.md`, the reviewers' in the `## agent:` blocks of `shared/pr-review.md`.
- The agent always uses the instructions on `main`, not the PR's copy, so a PR can't rewrite its own reviewer. A PR that changes the reviewer is still reviewed by the old version; test the change with `/review` after merging.
- Edit the `.md` files, then run `gh aw compile` (needs `gh extension install github/gh-aw`) to regenerate the `.lock.yml` files GitHub actually runs.
- It runs Copilot with the `COPILOT_GITHUB_TOKEN` repository secret: a fine-grained personal access token with the **Copilot Requests** permission. Each run uses Copilot premium requests for three models (the lead and two reviewers). Only users with write access trigger it.
