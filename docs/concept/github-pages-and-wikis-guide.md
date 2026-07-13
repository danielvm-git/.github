---
type: Concept
title: GitHub Pages and Wikis Guide
description: Decision guide for GitHub Pages vs Wikis across danielvm-git portfolio repos.
tags: [github-pages, wiki, documentation, static-site]
timestamp: 2026-07-13
provenance: docs/explanation/github-pages-and-wikis-guide.md
---

# GitHub Pages and Wikis Guide

Synthesized from all 28 GitHub Pages docs articles and all 6 Wiki docs articles. Lives in the reference repo as the canonical answer to "should this project have a Pages site, a Wiki, both, or neither."

## Overview

This guide explains the two documentation hosting options available to every danielvm-git repo — GitHub Pages and Wikis — and provides decision criteria for choosing between them. It also covers setup, publishing sources, custom domains, limits, and recommended layouts.

## Part 1: GitHub Pages

### What it is
Static site hosting from a repo's files (HTML/CSS/JS), with an optional Jekyll build. No server-side languages (PHP, Ruby, Python) at runtime.

### Two types of sites

| Property | User/Organization Site | Project Site |
|----------|----------------------|--------------|
| Repo name | `<user>.github.io` | Any name |
| Limit | 1 per account | 1 per repo |
| URL | `https://<user>.github.io` | `https://<user>.github.io/<repo>` |

### Setup — quickstart
1. Create a repo named `<username>.github.io`
2. Settings → Pages → Source: Deploy from a branch
3. Select `main` + `/` (root)
4. Add `index.html` or `README.md` — live at `https://<username>.github.io`

### Setup — with Jekyll
1. Install Ruby + Bundler + Jekyll locally
2. Create the repo, run `jekyll new --skip-bundle .`
3. In `Gemfile`: comment `gem "jekyll"`, uncomment `gem "github-pages", "~> VERSION"`
4. `bundle install`
5. Edit `_config.yml` (title, description, theme)
6. Commit and push — Actions builds and deploys automatically

### Publishing sources

**Deploy from a branch (simpler):**
- `main` + `/` (root) — dedicated site repos
- `main` + `/docs` — docs alongside source code
- `gh-pages` branch — legacy, still works

**Deploy with a custom Actions workflow (more flexible)**:
```yaml
- uses: actions/configure-pages@v5
- uses: actions/upload-pages-artifact@v4
- uses: actions/deploy-pages@v4
```

### Recommended stack by scenario

| Scenario | Technology | Reason |
|----------|-----------|--------|
| Quick landing page | Plain HTML/CSS/JS | Zero dependencies |
| Project documentation | Jekyll + Markdown | Native Pages integration |
| Blog/content site | Jekyll or Hugo | Mature ecosystem |
| SPA (React/Vue) | Vite + Actions workflow | Build with npm, deploy artifact |
| API docs from Python | MkDocs + Actions | Python-native |
| Modern framework | Next.js/Astro/SvelteKit + Actions | Full power, requires custom workflow |

### Custom domains
- Supports apex (`example.com`), `www.example.com`, and other subdomains
- Always pair a `www` subdomain with the apex for stability
- Apex: A records to `185.199.108.153`, `.109.153`, `.110.153`, `.111.153`
- Subdomain: CNAME to `<user>.github.io`
- **Verify the domain in account settings before configuring it on a repo**
- HTTPS is automatic (Let's Encrypt)

### Limits

| Constraint | Value |
|-----------|-------|
| Source repo size | ~1 GB recommended max |
| Published site size | 1 GB max |
| Build timeout | 10 minutes |
| Bandwidth | ~100 GB/month soft limit |
| Builds/hour | 10 (unlimited with custom Actions workflow) |

## Part 2: Wikis

### What it is
Every repo has a built-in Wiki tab — a separate Git repo (`<repo>.wiki.git`) you can clone and edit locally.

### Features
Image embeds, Markdown or MediaWiki-style `[[PageName|text]]` links, `$$...$$` math, diagrams/maps/3D models, full edit history, and search (public-repo wikis are indexed once they have 500+ stars).

### Limits
5,000 files max. No transclusion, definition lists, indentation, or auto-TOC.

## Part 3: Pages vs. Wikis

| Factor | GitHub Pages | Wikis |
|--------|-------------|-------|
| Purpose | Full website, blog, SPA | Long-form docs, guides |
| URL | Custom domain or `<user>.github.io/<repo>` | Part of repo UI (`/wiki`) |
| Stack | Any SSG + HTML/CSS/JS | Markdown + GitHub Markup |
| Build | Optional (Jekyll or Actions) | None — rendered live |
| Version control | Full Git repo | Separate `.wiki.git` repo |
| Collaboration | Pull requests | Direct edits (or PRs to wiki repo) |
| Search indexing | Yes | Only 500+ starred repos |
| Best for | Marketing sites, SPAs, blogs | README-level docs needing more room |

## References

- GitHub's own [Security hardening for GitHub Actions](https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions)
