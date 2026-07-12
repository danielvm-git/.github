# Semantic Release Unified — Project Specification

> **Status:** Draft
> **Created:** 2026-07-12
> **Epic:** TBD

---

## Problem Statement

We have 35+ repositories across 8 languages (JavaScript, TypeScript, Python, Go, Rust, PHP, Java, Swift, GDScript). Each language has its own release tooling with different workflows, configurations, and behaviors. This creates:

1. **Inconsistency:** Different release workflows per language
2. **Maintenance burden:** Multiple tools to update and configure
3. **Learning curve:** New contributors must learn language-specific tools
4. **Fragmentation:** No unified view of releases across the organization

---

## Solution

Create **big-release** — a unified, multi-language release tool that:

1. **Single binary** — No runtime dependencies
2. **Unified workflow** — Same behavior across all languages
3. **Language detection** — Automatically detect project type
4. **Plugin system** — Extensible for language-specific publishing
5. **Bigpowers native** — Follows all conventions and principles

---

## Language Selection: Go

### Why Go?

| Criterion | Go | Rust | Node.js | Python | Shell |
|-----------|-----|------|---------|--------|-------|
| **Single binary** | ✅ | ✅ | ❌ | ❌ | ❌ |
| **No runtime deps** | ✅ | ✅ | ❌ | ❌ | ✅ |
| **Cross-compilation** | ✅ | ✅ | ❌ | ❌ | ✅ |
| **Fast startup** | ✅ | ✅ | ⚠️ | ⚠️ | ✅ |
| **Already in stack** | ✅ (bigbase) | ✅ (sqz) | ✅ | ✅ | ✅ |
| **GitHub Action ready** | ✅ | ✅ | ✅ | ⚠️ | ⚠️ |
| **Bigpowers alignment** | ✅ | ✅ | ❌ | ❌ | ❌ |

### Bigpowers Principles Alignment

1. **Always Green:**
   - Single binary = no dependency failures
   - No Node.js/Python version conflicts
   - Works in any CI environment

2. **Shift Left:**
   - Fast startup for quick validation
   - Clear error messages
   - Fail-fast behavior

3. **Verification Mandate:**
   - Built-in verification steps
   - Traceable releases
   - Audit trail

4. **Git Attribution:**
   - Controlled commit author
   - No AI co-author footers
   - Clean git history

---

## Architecture

```
big-release/
├── cmd/
│   └── big-release/
│       └── main.go              # CLI entry point
├── internal/
│   ├── algorithm/               # Core algorithm (language-agnostic)
│   │   ├── analyzer.go          # Commit analysis
│   │   ├── calculator.go        # Version calculation
│   │   ├── generator.go         # Notes generation
│   │   └── types.go             # Data structures
│   ├── git/                     # Git operations
│   │   ├── commits.go
│   │   ├── tags.go
│   │   └── auth.go
│   ├── config/                  # Configuration
│   │   ├── loader.go
│   │   └── schema.go
│   ├── plugins/                 # Plugin system
│   │   ├── registry.go
│   │   └── loader.go
│   └── publishers/              # Language-specific publishers
│       ├── npm/
│       ├── pypi/
│       ├── crates/
│       ├── goproxy/
│       ├── packagist/
│       ├── maven/
│       ├── swift/
│       └── godot/
├── pkg/                         # Public API
│   └── release/
│       └── release.go
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── release.yml
├── docs/
│   ├── README.md
│   ├── ALGORITHM.md
│   └── LANGUAGES.md
├── tests/
│   ├── unit/
│   └── integration/
├── go.mod
├── go.sum
└── Makefile
```

---

## Core Algorithm (Ported from semantic-release)

### Phase 1: Initialize
- Detect CI environment
- Load configuration (.big-release.yml, big-release.json, etc.)
- Set defaults

### Phase 2: Analyze Branch
- Classify branch type (release, maintenance, prerelease)
- Validate configuration

### Phase 3: Verify Auth
- Check push permissions
- Verify branch is up-to-date

### Phase 4: Find Last Release
- Get all tags
- Extract versions
- Find highest version

### Phase 5: Get Commits
- Get commits since last release
- Parse commit messages

### Phase 6: Analyze Commits
- Parse Conventional Commits
- Determine release type (patch/minor/major)

### Phase 7: Calculate Version
- Increment based on release type
- Handle prereleases
- Validate against branch range

### Phase 8: Generate Notes
- Group commits by type
- Format changelog
- Hide sensitive data

### Phase 9: Create Tag
- Format tag name
- Create git tag
- Push to remote

### Phase 10: Publish
- Detect package type
- Execute language-specific publish
- Verify publication

### Phase 11: GitHub Release
- Create release via API
- Upload assets

### Phase 12: Notify Success
- Log published versions
- Return results

---

## Configuration Schema

```yaml
# .big-release.yml
branches:
  - main                    # release branch
  - next                    # release branch
  - "N.x"                   # maintenance branch
  - name: beta
    prerelease: true        # prerelease branch

tagFormat: "v${version}"

publishers:
  npm:
    enabled: true
    registry: "https://registry.npmjs.org"
  pypi:
    enabled: true
    registry: "https://pypi.org"
  crates:
    enabled: true
    registry: "https://crates.io"
  godot:
    enabled: true
    exportPresets: "export_presets.cfg"

plugins:
  - changelog
  - exec
  - git
  - github

exec:
  prepareCmd: |
    if [ -f export_presets.cfg ]; then
      sed -i 's/version\\/name=".*"/version\\/name="${nextRelease.version}"/g' export_presets.cfg
    fi
```

---

## Plugin System

### Built-in Plugins

1. **changelog** — Generate CHANGELOG.md
2. **exec** — Execute custom commands
3. **git** — Commit changes back to repo
4. **github** — Create GitHub releases

### Plugin Interface

```go
type Plugin interface {
    Name() string
    VerifyConditions(config *Config) error
    AnalyzeCommits(commits []*Commit) (string, error)
    GenerateNotes(commits []*Commit, lastRelease, nextRelease *Release) (string, error)
    Prepare(version string, config *Config) error
    Publish(version string, config *Config) (*Release, error)
    Success(release *Release) error
    Fail(err error) error
}
```

---

## Language-Specific Publishers

### JavaScript/TypeScript
```go
type NpmPublisher struct {
    Registry string
    Token    string
}

func (p *NpmPublisher) Publish(version string) error {
    // 1. Update package.json version
    // 2. Run npm publish
    // 3. Verify publication
}
```

### Python
```go
type PyPIPublisher struct {
    Registry string
    Token    string
}

func (p *PyPIPublisher) Publish(version string) error {
    // 1. Update pyproject.toml version
    // 2. Build package
    // 3. Upload to PyPI
    // 4. Verify publication
}
```

### Rust
```go
type CratesPublisher struct {
    Registry string
    Token    string
}

func (p *CratesPublisher) Publish(version string) error {
    // 1. Update Cargo.toml version
    // 2. Run cargo publish
    // 3. Verify publication
}
```

### Godot
```go
type GodotPublisher struct {
    ExportPresets string
}

func (p *GodotPublisher) Publish(version string) error {
    // 1. Update export_presets.cfg
    // 2. Update version code (timestamp)
    // 3. Commit changes
}
```

---

## GitHub Action

```yaml
# .github/workflows/release.yml
name: Release
on:
  push:
    branches: [main, next, 'N.x', beta, alpha]

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      issues: write
      pull-requests: write
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          token: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Install big-release
        run: |
          curl -sL https://github.com/danielvm-git/big-release/releases/latest/download/big-release-linux-amd64 -o big-release
          chmod +x big-release
          sudo mv big-release /usr/local/bin/
      
      - name: Run big-release
        run: big-release
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
          PYPI_TOKEN: ${{ secrets.PYPI_TOKEN }}
          CARGO_TOKEN: ${{ secrets.CARGO_TOKEN }}
```

---

## CLI Interface

```bash
# Basic usage
big-release

# Dry run
big-release --dry-run

# Specific branch
big-release --branch main

# Skip plugins
big-release --skip-changelog --skip-publish

# Verbose output
big-release --verbose

# Configuration file
big-release --config .big-release.yml

# List available publishers
big-release publishers

# Validate configuration
big-release validate

# Show current version
big-release version
```

---

## Testing Strategy

### Unit Tests
- Commit parsing
- Version calculation
- Notes generation
- Configuration loading

### Integration Tests
- Git operations
- Plugin execution
- Publisher execution

### End-to-End Tests
- Full release workflow
- Multi-language scenarios
- Edge cases

---

## Bigpowers Compliance

### Conventional Commits
- All commits follow `<type>(<scope>): <description>`
- Version bumps based on commit type

### Git Attribution
- Commits authored by "big-release[bot]"
- No AI co-author footers

### Always Green
- Preflight passes before release
- CI green before merge

### Verification Mandate
- Every release verifiable
- Audit trail maintained

### Traceability
- Every release linked to commits
- CHANGELOG.md updated

### Shift Left
- Validate configuration early
- Fail fast on errors

---

## Migration Plan

### Phase 1: Core (Week 1-2)
1. Implement core algorithm
2. Implement git operations
3. Implement configuration loading

### Phase 2: Publishers (Week 3-4)
1. npm publisher
2. PyPI publisher
3. crates.io publisher

### Phase 3: Plugins (Week 5)
1. changelog plugin
2. exec plugin
3. git plugin
4. github plugin

### Phase 4: Testing (Week 6)
1. Unit tests
2. Integration tests
3. E2E tests

### Phase 5: Documentation (Week 7)
1. README
2. Algorithm documentation
3. Language-specific guides

### Phase 6: Deployment (Week 8)
1. GitHub Action
2. Release workflow
3. Migration of existing repos

---

## Success Metrics

1. **Coverage:** All 35+ repositories migrated
2. **Consistency:** Same workflow across all languages
3. **Reliability:** 99.9% successful releases
4. **Performance:** Release completes in < 30 seconds
5. **Adoption:** All new repos use big-release by default

---

## Open Questions

1. Should we support monorepos?
2. Should we support multiple package managers per language?
3. How to handle language-specific edge cases?
4. Should we create a web UI for release history?

---

*This specification follows bigpowers principles and conventions.*
*All planning output goes in specs/.*
