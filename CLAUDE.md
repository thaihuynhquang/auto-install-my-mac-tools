# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

A single Bash script (`list_installed_software.sh`) that inventories all software installed on a macOS machine and writes the results to `installed_software.md`.

## Running the Script

```bash
bash list_installed_software.sh
```

Output is always written to `installed_software.md` in the current directory (hardcoded path). The script requires `jq` for parsing Homebrew JSON output.

## What the Script Covers

Sections generated (in order):
1. **Homebrew formulae** — version via `brew info --json=v1`, description via `get_description()` then `brew info` fallback
2. **Homebrew casks** — version via `brew info --json=v2`
3. **RVM** — version manager + installed Ruby versions
4. **NVM** — version manager + installed Node.js versions
5. **/Applications** — version read from `Info.plist` via `PlistBuddy`
6. **~/Applications** — same as above

## Key Design Decision

`get_description()` has two layers:
- **Predefined hardcoded descriptions** for known packages (brew formulae only)
- **Live `brew info` fallback** for unknown packages (both formulae and casks)

Cask descriptions always go through the live fallback path — there is no predefined map for casks except for a few hardcoded `case` entries.

## Dependencies

| Tool | Required for |
|------|-------------|
| `brew` | Homebrew sections |
| `jq` | Parsing `brew info --json` output |
| `rvm` | RVM section |
| `nvm` | NVM section (sourced from `~/.nvm/nvm.sh` if not in PATH) |
| `/usr/libexec/PlistBuddy` | Reading app versions from `.app` bundles |
