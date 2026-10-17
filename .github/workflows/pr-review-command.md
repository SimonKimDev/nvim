---
description: Reviews a pull request with two reviewers on different models when someone comments /review on it.

on:
  slash_command:
    name: review
    events: [pull_request_comment]

permissions:
  contents: read
  pull-requests: read

engine:
  id: copilot
  # The lead merges and verifies; the reviewers' models are set in shared/pr-review.md.
  model: claude-sonnet-5.5

imports:
  - shared/pr-review.md

timeout-minutes: 40
---

# PR review

Review pull request #${{ github.event.issue.number }} in ${{ github.repository }}, following the steps below. If it was reviewed before, it has probably changed since: focus on what's new, and don't repeat earlier comments that were already addressed.
