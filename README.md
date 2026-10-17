# Neovim Configuration
This is my Neovim setup largely based and expanded on Josean Martinez's [blog post](https://www.josean.com/posts/how-to-setup-neovim-2024) and the [youtube video](https://www.youtube.com/watch?v=6pAG3BHurdM)

Other than small retouch the setup is virtually identitcal to Josean's setup, checkout his video for more detailed explanation on the setup.

## Updates

- **Plugins**: `.github/workflows/plugin-update.yml` runs `:Lazy update` every Monday (or on demand from the Actions tab), commits the new `lazy-lock.json` to `simonk/dev/plugin-update`, and opens or refreshes an *Update plugins* PR that links each plugin's changes. CI runs on that PR, so the smoke test covers the new commits; merge it if it's green. The workflow force-pushes the branch each week, but leaves it alone once it has a commit from anyone else, so you can push a fix to it. It needs **Allow GitHub Actions to create and approve pull requests** turned on in Settings → Actions → General.
- **GitHub Actions**: Dependabot (`.github/dependabot.yml`) opens one grouped PR a month for the actions used in workflows and `.github/actions/`. It skips generated `*.lock.yml` workflows, because `gh aw compile` would overwrite its edits; refresh those with `gh aw upgrade`. Dependabot can't update lazy.nvim plugins, hence the workflow above.

## CI checks

Every pull request (and push to `main`) runs `.github/workflows/ci.yml`:

- **StyLua**: `stylua --check .` using `.stylua.toml`. Fix locally with `stylua .`.
- **Startup smoke test (Windows)**: installs every plugin from `lazy-lock.json` into empty directories, opens a Lua and a C# buffer, loads all plugins, and fails on any error. It also checks wiring that wouldn't raise an error: every mason-lspconfig server name resolves to an LSP config, Go/TSX/Lua buffers get the expected formatter, and web filetypes use 2-space indents. Mason package download failures are ignored because they depend on the network, not the config; language servers aren't installed in headless runs, so they're never started.

Run the smoke test locally from this directory:

```pwsh
nvim --headless --cmd "luafile tests/smoke.lua"
```

To hide the bulk reformat commit from `git blame`, run `git config blame.ignoreRevsFile .git-blame-ignore-revs`.

## AI PR review

`pr-review.md` and `pr-review-command.md` in `.github/workflows/` are an AI reviewer written as [GitHub Agentic Workflows](https://github.github.com/gh-aw/). It reviews each PR when it's opened or marked ready for review, and commenting `/review` on a PR runs it again, including on drafts. It only comments; it never approves or blocks.

- How it works (`shared/pr-review.md`): two reviewers on different models (`claude-reviewer`, `gpt-reviewer`) review the PR independently. A lead agent merges their findings, asks each reviewer to check what only the other found, verifies disputes against the code, and posts the result with a *Review context and counts* table. `Consensus reached: False` or a low confidence score means the round deserves a second look; comment `/review` to retry.
- The review criteria live in `.github/agents/pr-reviewer.agent.md`, which is also available in the repo's Agents tab. The sub-agents' task and output format are in `shared/pr-reviewer-subagent.md`.
- Models are pinned: the lead's in `pr-review.md` and `pr-review-command.md`, the reviewers' in the `## agent:` blocks of `shared/pr-review.md`.
- The agent always uses the instructions on `main`, not the PR's copy, so a PR can't rewrite its own reviewer. A PR that changes the reviewer is still reviewed by the old version; test the change with `/review` after merging.
- Edit the `.md` files, then run `gh aw compile` (needs `gh extension install github/gh-aw`) to regenerate the `.lock.yml` files GitHub actually runs.
- It runs Copilot with the `COPILOT_GITHUB_TOKEN` repository secret: a fine-grained personal access token with the **Copilot Requests** permission. Each run uses Copilot premium requests for three models (the lead and two reviewers). Only users with write access trigger it.
