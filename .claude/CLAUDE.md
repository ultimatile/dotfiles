# CLAUDE.md

This document outlines the coding standards and practices.

## Tools

- Use rg for grepping
- Use fd for finding files
- Use fzf for fuzzy finder
- Use hyperfine for benchmarking
- Use sd for text substitution locally (local `sed` is BSD sed); use gsed only when sed-specific features are needed. Over ssh / `crewster exec`, plain `sed` (GNU) is fine
