## Project title

# projectname

> One-line description of your shell script project.

A CLI tool written in Bash that [does something useful]. Uses `getopts` for flag parsing, structured error handling, and passes ShellCheck with zero warnings.

## Motivation

Shell scripts glue systems together. Most grow from a one-liner into an unmaintainable 500-line mess. This project exists to demonstrate a maintainable Bash script structure: idempotent functions, consistent error handling, and deterministic behaviour — so your ops team can sleep at night.

## Build status

[![ShellCheck](https://img.shields.io/badge/ShellCheck-passing-brightgreen)](https://www.shellcheck.net/)
[![CI](https://github.com/youruser/projectname/actions/workflows/ci.yml/badge.svg)](https://github.com/youruser/projectname/actions)

ShellCheck is run on every push via GitHub Actions. The `master` branch must pass `shellcheck --severity=style` before merge.

## Code style

[![shellcheck](https://img.shields.io/badge/linting-shellcheck-yellowgreen)](https://www.shellcheck.net/)
[![shfmt](https://img.shields.io/badge/formatter-shfmt-blue)](https://github.com/mvdan/sh)

| Tool | Purpose | Config |
|------|---------|--------|
| [ShellCheck](https://www.shellcheck.net/) | Static analysis for bash/sh | `shellcheck --severity=style` |
| [shfmt](https://github.com/mvdan/sh) | Auto-formatter | `shfmt -i 2 -ci -kp` |

Rules:
- Always quote variables (`"$var"`, not `$var`).
- Prefer `[[ ]]` over `[ ]` (fewer surprises).
- Use `local` in every function.
- Only `exit` in `main()` — functions return.

Run both before committing:

```bash
shellcheck --severity=style script.sh
shfmt -i 2 -ci -kp -d script.sh
```

## Screenshots

```
$ projectname --help
Usage: projectname [OPTIONS] <input>

Arguments:
  input      Path to input file (or - for stdin)

Options:
  -o, --output FILE   Write output to FILE (default: stdout)
  -v, --verbose       Enable verbose logging
  -h, --help          Show this help message

$ projectname -o result.txt data.csv
[INFO] Processing data.csv...
[INFO] Wrote 42 records to result.txt
[  OK  ] Done.
```

## Tech/framework used

- **Bash 4.4+** — shebang `#!/usr/bin/env bash`, `set -euo pipefail`
- **POSIX coreutils** — `printf`, `sed`, `awk`, `grep`
- **getopts** — built-in flag parser
- **jq** — JSON processing (optional dependency)
- **bats** — test framework

## Features

- **Safe by default** — `set -euo pipefail` catches errors early.
- **Structured flags** — `getopts` with long-option shims. No silent failures on unknown args.
- **Idempotent helpers** — every function is a pure-ish operation with `local` scope.
- **Colour-coded logging** — `info`, `warn`, `error`, `debug` via a single `log()` function.
- **Temp file cleanup** — `trap` ensures no orphans on exit or SIGINT.
- **ShellCheck-clean** — zero warnings at `--severity=style`.
- **bats-tested** — full coverage with Bash Automated Testing System.

## Code Example

```bash
#!/usr/bin/env bash
set -euo pipefail

PROGRAM="$(basename "$0")"

# --- Logging -----------------------------------------------------------
log() {
  local level="$1" msg="$2"
  case "$level" in
    INFO)  printf "\e[34m[INFO]\e[0m  %s\n" "$msg" ;;
    OK)    printf "\e[32m[ OK ]\e[0m  %s\n" "$msg" ;;
    WARN)  printf "\e[33m[WARN]\e[0m  %s\n" "$msg" >&2 ;;
    ERROR) printf "\e[31m[ERR]\e[0m  %s\n" "$msg" >&2 ;;
  esac
}

# --- Helpers -----------------------------------------------------------
usage() {
  cat <<EOF
Usage: $PROGRAM [OPTIONS] <input>

Process <input> and print or save the result.

Options:
  -o, --output FILE   Write output to FILE (default: stdout)
  -v, --verbose       Enable verbose logging
  -h, --help          Show this help message
EOF
  exit 0
}

cleanup() {
  [[ -n "${tmpdir:-}" ]] && rm -rf "$tmpdir"
}

# --- Core --------------------------------------------------------------
process_file() {
  local input="$1" output="$2"
  [[ -f "$input" ]] || { log ERROR "File not found: $input"; return 1; }

  local count
  count="$(wc -l < "$input")"
  printf "Processed %d lines from %s\n" "$count" "$input" > "$output"
  log OK "Wrote %d lines to %s" "$count" "$output"
}

# --- CLI ---------------------------------------------------------------
main() {
  local input="" output="/dev/stdout" verbose=false

  trap cleanup EXIT
  tmpdir="$(mktemp -d)"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -o|--output) output="$2";  shift 2 ;;
      -v|--verbose) verbose=true; shift   ;;
      -h|--help)    usage                 ;;
      --)           shift; break          ;;
      -*)
        log ERROR "Unknown flag: $1"
        usage
        ;;
      *) input="$1"; shift ;;
    esac
  done

  [[ -n "$input" ]] || { log ERROR "Missing <input> argument."; usage; }
  $verbose && log INFO "Processing: $input"

  process_file "$input" "$output"
}

main "$@"
```

## Installation

**Homebrew** (macOS):
```bash
brew tap youruser/tap
brew install projectname
```

**APT** (Debian/Ubuntu):
```bash
echo "deb https://apt.example.com/ stable main" | sudo tee /etc/apt/sources.list.d/projectname.list
sudo apt update && sudo apt install projectname
```

**Curl pipe** (quick install):
```bash
curl -sSL https://raw.githubusercontent.com/youruser/projectname/main/install.sh | bash
```

**Manual**:
```bash
git clone https://github.com/youruser/projectname.git
cd projectname
cp projectname.sh /usr/local/bin/projectname
chmod +x /usr/local/bin/projectname
```

## API Reference

The public interface is the script's CLI. Every flag is documented in the `usage()` function (run `projectname --help`).

For the Bash language reference:
- [GNU Bash Manual](https://www.gnu.org/software/bash/manual/bash.html)
- [ShellCheck Wiki](https://www.shellcheck.net/wiki/) — every warning code explained

Run `man bash` for the full language spec, or `help` inside a shell for built-in commands.

## Tests

Tests use [bats](https://github.com/bats-core/bats-core) (Bash Automated Testing System).

```bash
# Install bats
npm install -g bats  # or: brew install bats-core

# Run all tests
bats tests/

# Single file
bats tests/process_file.bats
```

Example test file `tests/process_file.bats`:

```bash
setup() {
  load 'helpers.bash'
  PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd)"
  PATH="$PROJECT_ROOT:$PATH"
}

@test "prints usage with --help" {
  run projectname --help
  [[ "$status" -eq 0 ]]
  [[ "$output" =~ "Usage:" ]]
}

@test "processes a file and writes output" {
  echo -e "a\nb\nc" > "$BATS_TEST_TMPDIR/input.txt"
  run projectname -o "$BATS_TEST_TMPDIR/out.txt" "$BATS_TEST_TMPDIR/input.txt"
  [[ "$status" -eq 0 ]]
  [[ -f "$BATS_TEST_TMPDIR/out.txt" ]]
}

@test "exits with error on missing file" {
  run projectname /nonexistent
  [[ "$status" -eq 1 ]]
}
```

## How to use

```bash
# Basic usage
projectname data.csv

# Write to file
projectname -o result.txt data.csv

# Verbose mode
projectname -v -o result.txt data.csv

# Pipe input
cat data.csv | projectname -
```

### Common workflows

**Process multiple files:**
```bash
for f in *.csv; do
  projectname -o "${f%.csv}.out" "$f"
done
```

**JSON output (with jq):**
```bash
projectname data.csv | jq '.'
```

## Contribute

Contributions are welcome. Please follow the existing conventions:

1. Open an issue to discuss the change before writing code.
2. Run ShellCheck and shfmt on your branch.
3. Add bats tests for new functionality.
4. Ensure all tests pass: `bats tests/`

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full guide.

## Credits

This README follows the [Kickass README](https://github.com/akashnimare/kickass-readme) template by Akash Nimare. The shell-specific examples and conventions were inspired by the [Pure Bash Bible](https://github.com/dylanaraps/pure-bash-bible) and Google's [Shell Style Guide](https://google.github.io/styleguide/shellguide.html).

## License

MIT © [Your name](https://github.com/youruser)

See [LICENSE](LICENSE) for the full text.
