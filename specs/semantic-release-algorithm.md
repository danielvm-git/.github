# Semantic Release Algorithm — Natural Language Specification

> **CS101 Exercise:** Extract the algorithm from semantic-release in plain English before implementation.

## Overview

**Purpose:** Automatically determine the next software version, generate release notes, and publish packages based on commit message conventions.

**Input:** Git repository with conventional commits
**Output:** New version tag, changelog, published package

---

## Phase 0: Initialization

```
ALGORITHM Initialize:
    1. DETECT if running in CI environment
       - IF not CI AND not dry-run mode:
         - SET dry-run = true
         - WARN "Not in CI, running in dry-run mode"
    
    2. IF running in CI:
       - SET git author = "semantic-release-bot"
       - SET git committer = "semantic-release-bot"
       - DISABLE git prompts (GIT_TERMINAL_PROMPT=0)
    
    3. IF triggered by Pull Request:
       - LOG "PR trigger detected, skipping release"
       - STOP
    
    4. LOAD configuration from:
       - .releaserc.json
       - .releaserc.yml
       - release.config.js
       - package.json (release key)
    
    5. SET defaults:
       - branches = ["main", "next", "next-major", "beta", "alpha"]
       - tagFormat = "v${version}"
       - plugins = [commit-analyzer, release-notes-generator, npm, github]
```

---

## Phase 1: Branch Analysis

```
ALGORITHM AnalyzeBranch:
    1. GET current branch name from CI environment
       - IF Pull Request: use PR branch
       - ELSE: use trigger branch
    
    2. CLASSIFY branch type:
       - IF branch matches pattern "N.x" or "N.x.x":
         → TYPE = maintenance
         → RANGE = extracted version range
       - ELSE IF branch has prerelease config (e.g., "beta"):
         → TYPE = prerelease
         → PRERELEASE = branch name or config value
       - ELSE:
         → TYPE = release
    
    3. VALIDATE branch configuration:
       - MAX 3 release branches allowed
       - Maintenance branches must have valid range
       - Prerelease branches must have valid prerelease identifier
    
    4. IF current branch NOT in configured branches:
       - LOG "Branch {branch} not configured for release"
       - STOP
    
    5. RETURN branch metadata:
       - name, type, range, channel, prerelease, tags
```

---

## Phase 2: Authentication & Permissions

```
ALGORITHM VerifyAuth:
    1. GET repository URL (from config or git remote)
    
    2. VERIFY push permission:
       - RUN: git push --dry-run --no-verify {url} HEAD:{branch}
       - IF fails:
         - CHECK if branch is up-to-date with remote
         - IF behind remote:
           - LOG "Branch behind remote, skipping release"
           - STOP
         - ELSE:
           - THROW EGITNOPERMISSION error
    
    3. RETURN authenticated repository URL
```

---

## Phase 3: Release Discovery

```
ALGORITHM FindLastRelease:
    1. GET all tags for current branch:
       - RUN: git tag --merged {branch}
    
    2. FILTER tags:
       - KEEP only tags matching tagFormat pattern
       - EXTRACT version number from each tag
       - VALIDATE version is valid semver
    
    3. GET tag notes (channel information):
       - RUN: git log --tags --format="%d%x09%N"
       - PARSE JSON notes for each tag
    
    4. SORT versions:
       - DESCENDING by semver precedence
    
    5. SELECT highest version as lastRelease:
       - RETURN { version, gitTag, gitHead, channels }
       - IF no tags found:
         - RETURN empty object
```

---

## Phase 4: Commit Retrieval

```
ALGORITHM GetCommits:
    1. DETERMINE commit range:
       - IF lastRelease exists:
         - FROM = lastRelease.gitHead
       - ELSE:
         - FROM = null (all commits)
       - TO = HEAD
    
    2. RETRIEVE commits:
       - RUN: git log {from}..{to} --pretty=format:"%H|%s|%an|%ae|%ai"
    
    3. PARSE each commit:
       - EXTRACT: hash, message, author, email, date
    
    4. FILTER commits:
       - EXCLUDE commits with [skip release] or [release skip]
    
    5. RETURN sorted commit list (newest first)
```

---

## Phase 5: Commit Analysis (The Heart)

```
ALGORITHM AnalyzeCommits:
    1. INITIALIZE releaseType = null
    
    2. FOR EACH commit in commits:
       a. PARSE commit message using Conventional Commits:
       
          PATTERN: ^(feat|fix|perf|docs|chore|style|refactor|test|build|ci|revert)(\(.+\))?(!)?: (.+)
          
          EXAMPLES:
          - "feat(auth): add OAuth2 support" → type=feat, scope=auth
          - "fix!: remove deprecated API" → type=fix, breaking=true
          - "perf: optimize database queries" → type=perf
       
       b. DETERMINE bump type:
          - IF type = "feat":
            → bump = "minor"
          - ELSE IF type = "fix" OR type = "perf":
            → bump = "patch"
          - ELSE IF breaking = true OR commit contains "BREAKING CHANGE:":
            → bump = "major"
          - ELSE:
            → bump = null (no release)
       
       c. UPDATE releaseType:
          - IF bump = "major":
            → releaseType = "major" (highest priority)
          - ELSE IF bump = "minor" AND releaseType != "major":
            → releaseType = "minor"
          - ELSE IF bump = "patch" AND releaseType = null:
            → releaseType = "patch"
    
    3. RETURN releaseType (or null if no releasable commits)
```

---

## Phase 6: Version Calculation

```
ALGORITHM CalculateNextVersion:
    INPUT: lastRelease.version, releaseType, branch
    
    1. IF no lastRelease:
       - IF branch.type = "prerelease":
         → version = "1.0.0-{prerelease}.1"
       - ELSE:
         → version = "1.0.0"
    
    2. IF lastRelease exists:
       PARSE lastRelease.version into (major, minor, patch)
       
       a. IF branch.type = "prerelease":
          - IF current version has prerelease AND same channel:
            → version = increment(prerelease)
          - ELSE:
            → version = increment(releaseType) + "-{prerelease}.1"
       
       b. ELSE (normal release):
          → version = increment(releaseType)
    
    3. INCREMENT rules:
       - major: X.y.z → (X+1).0.0
       - minor: x.Y.z → x.(Y+1).0
       - patch: x.y.Z → x.y.(Z+1)
       - prerelease: x.y.z-pre.N → x.y.z-pre.(N+1)
    
    4. VALIDATE version is within branch range:
       - IF branch.type != "prerelease":
         - IF version NOT in branch.range:
           → THROW EINVALIDNEXTVERSION
    
    5. RETURN version
```

---

## Phase 7: Release Notes Generation

```
ALGORITHM GenerateNotes:
    INPUT: commits, lastRelease, nextRelease
    
    1. INITIALIZE notes = []
    
    2. GROUP commits by type:
       - BREAKING CHANGES
       - Features (feat)
       - Bug Fixes (fix)
       - Performance (perf)
       - Other (docs, chore, etc.)
    
    3. FOR EACH group:
       - IF group has commits:
         - ADD group header (e.g., "### Features")
         - FOR EACH commit in group:
           - FORMAT: "- {scope}: {description} ({short-hash})"
         - ADD to notes
    
    4. IF lastRelease:
       - ADD comparison link:
         "https://github.com/{owner}/{repo}/compare/{lastTag}...{newTag}"
    
    5. JOIN notes with double newline
    
    6. HIDE sensitive values:
       - REPLACE tokens, passwords, secrets with "[secure]"
    
    7. RETURN formatted notes string
```

---

## Phase 8: Tag Creation

```
ALGORITHM CreateTag:
    INPUT: version, gitHead, tagFormat
    
    1. FORMAT tag name:
       - tag = tagFormat.replace("${version}", version)
       - EXAMPLE: "v1.2.3"
    
    2. VALIDATE tag name:
       - RUN: git check-ref-format refs/tags/{tag}
       - IF invalid:
         → THROW EINVALIDTAGFORMAT
    
    3. CREATE tag:
       - RUN: git tag {tag} {gitHead}
    
    4. ADD tag notes:
       - RUN: git notes --ref "semantic-release-{tag}" add -f -m '{"channels":[null]}' {tag}
    
    5. PUSH tag:
       - RUN: git push --tags {remote}
    
    6. PUSH notes:
       - RUN: git push {remote} refs/notes/semantic-release-{tag}
    
    7. LOG "Created tag {tag}"
```

---

## Phase 9: Publishing

```
ALGORITHM Publish:
    INPUT: version, packageType, registry
    
    1. DETERMINE package type:
       - IF package.json exists:
         → TYPE = npm
       - IF pyproject.toml or setup.py exists:
         → TYPE = pypi
       - IF Cargo.toml exists:
         → TYPE = crates
       - IF go.mod exists:
         → TYPE = goproxy
       - IF composer.json exists:
         → TYPE = packagist
       - IF pom.xml exists:
         → TYPE = maven
    
    2. EXECUTE language-specific publish:
    
       CASE npm:
         - RUN: npm publish
         - OPTIONAL: --tag {channel} for prereleases
         - OPTIONAL: --provenance for supply chain security
       
       CASE pypi:
         - RUN: twine upload dist/*
         - OR: python -m build && twine upload dist/*
       
       CASE crates:
         - RUN: cargo publish
       
       CASE goproxy:
         - CREATE git tag with module path
         - RUN: go mod download
       
       CASE packagist:
         - UPDATE composer.json version
         - TRIGGER Packagist webhook
       
       CASE maven:
         - RUN: mvn release:perform
    
    3. VERIFY publication:
       - CHECK registry API for new version
       - IF fails:
         → THROW EPUBLISHERROR
    
    4. RETURN release info:
       - { version, channel, registryUrl, gitTag }
```

---

## Phase 10: GitHub/GitLab Release

```
ALGORITHM CreateGitHubRelease:
    INPUT: version, notes, assets
    
    1. CREATE release via API:
       - POST /repos/{owner}/{repo}/releases
       - BODY: {
           tag_name: tag,
           name: tag,
           body: notes,
           prerelease: isPrerelease
         }
    
    2. UPLOAD assets (optional):
       - FOR EACH asset in assets:
         - POST /repos/{owner}/{repo}/releases/{id}/assets
         - UPLOAD binary file
    
    3. RETURN release URL
```

---

## Phase 11: Success Notification

```
ALGORITHM NotifySuccess:
    INPUT: releases
    
    1. FOR EACH release:
       - LOG "Published {version} on {channel} channel"
    
    2. IF dry-run:
       - OUTPUT release notes to stdout
    
    3. RETURN { releases }
```

---

## Phase 12: Error Handling

```
ALGORITHM HandleError:
    INPUT: error
    
    1. CLASSIFY error:
       - EGITNOPERMISSION: "Cannot push to Git repository"
       - EINVALIDTAGFORMAT: "Invalid tag format"
       - EINVALIDNEXTVERSION: "Version out of range"
       - EPLUGIN: "Plugin configuration error"
       - EPUBLISH: "Publishing failed"
    
    2. IF error.semanticRelease = true:
       - LOG error.code and error.message
       - LOG error.details (if any)
    
    3. ELSE:
       - LOG "Unexpected error: {error}"
    
    4. CALL fail plugin (if configured)
    
    5. EXIT with code 1
```

---

## Complete Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         START                                    │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Phase 0: Initialize                           │
│  - Detect CI environment                                        │
│  - Load configuration                                           │
│  - Set defaults                                                 │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Phase 1: Analyze Branch                       │
│  - Classify branch type                                         │
│  - Validate configuration                                       │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Phase 2: Verify Auth                          │
│  - Check push permissions                                       │
│  - Verify branch is up-to-date                                  │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Phase 3: Find Last Release                    │
│  - Get all tags                                                 │
│  - Extract versions                                             │
│  - Find highest version                                         │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Phase 4: Get Commits                          │
│  - Get commits since last release                               │
│  - Parse commit messages                                        │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Phase 5: Analyze Commits                      │
│  - Parse Conventional Commits                                   │
│  - Determine release type (patch/minor/major)                   │
└─────────────────────────────────────────────────────────────────┘
                                │
                    ┌───────────┴───────────┐
                    │                       │
                    ▼                       ▼
            ┌──────────────┐       ┌──────────────┐
            │ No Release   │       │ Release      │
            │ (type=null)  │       │ (type=*)     │
            └──────────────┘       └──────────────┘
                    │                       │
                    ▼                       │
            ┌──────────────┐               │
            │ STOP         │               │
            └──────────────┘               │
                                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Phase 6: Calculate Version                    │
│  - Increment based on release type                              │
│  - Handle prereleases                                           │
│  - Validate against branch range                                │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Phase 7: Generate Notes                       │
│  - Group commits by type                                        │
│  - Format changelog                                             │
│  - Hide sensitive data                                          │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Phase 8: Create Tag                           │
│  - Format tag name                                              │
│  - Create git tag                                               │
│  - Push to remote                                               │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Phase 9: Publish                              │
│  - Detect package type                                          │
│  - Execute language-specific publish                            │
│  - Verify publication                                           │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Phase 10: GitHub Release                      │
│  - Create release via API                                       │
│  - Upload assets                                                │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Phase 11: Notify Success                      │
│  - Log published versions                                       │
│  - Return results                                               │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                         END                                      │
└─────────────────────────────────────────────────────────────────┘
```

---

## Data Structures

### Configuration
```yaml
branches:
  - main                    # release branch
  - next                    # release branch
  - "N.x"                   # maintenance branch
  - name: beta
    prerelease: true        # prerelease branch

tagFormat: "v${version}"

plugins:
  - @semantic-release/commit-analyzer
  - @semantic-release/release-notes-generator
  - @semantic-release/npm
  - @semantic-release/github
```

### Commit
```typescript
interface Commit {
  hash: string;           // git commit hash
  message: string;        // full commit message
  type: string;           // feat, fix, perf, etc.
  scope: string | null;   // optional scope
  subject: string;        // description
  breaking: boolean;      // has BREAKING CHANGE
  author: string;         // author name
  email: string;          // author email
  date: Date;             // commit date
}
```

### Release
```typescript
interface Release {
  version: string;        // semver version
  gitTag: string;         // git tag name
  gitHead: string;        // commit hash
  channel: string | null; // distribution channel
  notes: string;          // release notes
  assets: Asset[];        // published files
}
```

### Branch
```typescript
interface Branch {
  name: string;           // branch name
  type: 'release' | 'maintenance' | 'prerelease';
  range: string;          // version range (e.g., ">=1.0.0 <2.0.0")
  channel: string | null; // distribution channel
  prerelease: string;     // prerelease identifier
  tags: Tag[];            // tags on this branch
}
```

---

## Edge Cases

1. **First Release:** No previous tags → version starts at 1.0.0
2. **No Releasable Commits:** Only docs/chore commits → no release
3. **Breaking Change on Maintenance Branch:** Must cherry-pick to release branch
4. **Multiple Channels:** Same version on different channels (e.g., latest, beta)
5. **Dry Run:** Skip all write operations, just log what would happen
6. **CI Not Detected:** Force dry-run mode
7. **Behind Remote:** Skip release to avoid conflicts
8. **Invalid Tag Format:** Throw error with clear message

---

## Language-Specific Considerations

### JavaScript/TypeScript
- Package manager: npm, yarn, pnpm
- Registry: npmjs.com
- Config: package.json or .releaserc

### Python
- Package manager: pip, poetry, uv
- Registry: pypi.org
- Config: pyproject.toml or setup.cfg

### Rust
- Package manager: cargo
- Registry: crates.io
- Config: Cargo.toml

### Go
- Package manager: go mod
- Registry: proxy.golang.org
- Config: go.mod

### PHP
- Package manager: composer
- Registry: packagist.org
- Config: composer.json

### Java
- Package manager: maven, gradle
- Registry: maven central
- Config: pom.xml or build.gradle

### Swift
- Package manager: swift package manager
- Registry: swiftpackageindex.com
- Config: Package.swift

### Godot/GDScript
- Package manager: none (binary distribution)
- Registry: GitHub Releases, Godot Asset Library
- Config: export_presets.cfg

---

## Bigpowers Principles Alignment

1. **Always Green:** Preflight must pass before release
2. **Conventional Commits:** Strict adherence to commit format
3. **Git Attribution:** No AI co-author footers
4. **Verification Mandate:** Every release must be verifiable
5. **Traceability:** Every release linked to commits
6. **Shift Left:** Validate early, fail fast

---

*This algorithm is language-agnostic and can be implemented in any language.*
*The only language-specific part is Phase 9: Publishing.*
