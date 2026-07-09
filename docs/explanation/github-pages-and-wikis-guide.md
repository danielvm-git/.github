# GitHub Pages + Wikis — Complete Guide

Synthesized from all 28 GitHub Pages docs articles and all 6 Wiki docs articles. Lives in the reference repo as the canonical answer to "should this project have a Pages site, a Wiki, both, or neither."

## Part 1: GitHub Pages

### What it is
Static site hosting from a repo's files (HTML/CSS/JS), with an optional Jekyll build. No server-side languages (PHP, Ruby, Python) at runtime.

### Two types of sites

| Property | User/Organization Site | Project Site |
|---|---|---|
| Repo name | `<user>.github.io` | Any name |
| Limit | 1 per account | 1 per repo |
| URL | `https://<user>.github.io` | `https://<user>.github.io/<repo>` |

### Setup — quickstart
1. Create a repo named `<username>.github.io`
2. Settings → Pages → Source: Deploy from a branch
3. Select `main` + `/` (root)
4. Add `index.html` or `README.md` — live at `https://<username>.github.io`

### Setup — with Jekyll (recommended for blogs/docs)
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

**Deploy with a custom Actions workflow (more flexible)** — use when you want a build process other than Jekyll (Vite, Next.js, Hugo, MkDocs), don't want a dedicated branch for compiled output, or need custom build steps. Three official actions:
```yaml
- uses: actions/configure-pages@v5      # gather metadata
- uses: actions/upload-pages-artifact@v4 # upload build output
- uses: actions/deploy-pages@v4          # deploy to Pages
```

**GitHub's current recommendation: Actions over the `github-pages` gem.** The gem still works for some workflows but Actions is the supported path going forward.

### Recommended stack by scenario

| Scenario | Technology | Reason |
|---|---|---|
| Quick landing page | Plain HTML/CSS/JS | Zero dependencies |
| Project documentation | Jekyll + Markdown | Native Pages integration |
| Blog/content site | Jekyll or Hugo | Mature ecosystem |
| SPA (React/Vue) | Vite + Actions workflow | Build with npm, deploy artifact; add `.nojekyll` |
| API docs from Python | MkDocs + Actions | Python-native |
| Modern framework | Next.js/Astro/SvelteKit + Actions | Full power, requires custom workflow |

Non-Jekyll SSGs need an empty `.nojekyll` file at the root of the publishing source to disable the Jekyll build step.

### Custom domains
- Supports apex (`example.com`), `www.example.com`, and other subdomains
- Always pair a `www` subdomain with the apex for stability
- Apex: A records to `185.199.108.153`, `.109.153`, `.110.153`, `.111.153`
- Subdomain: CNAME to `<user>.github.io`
- **Verify the domain in account settings before configuring it on a repo** — prevents domain takeover
- HTTPS is automatic (Let's Encrypt) — enable "Enforce HTTPS"

### Limits

| Constraint | Value |
|---|---|
| Source repo size | ~1 GB recommended max |
| Published site size | 1 GB max |
| Build timeout | 10 minutes |
| Bandwidth | ~100 GB/month soft limit |
| Builds/hour | 10 (unlimited with a custom Actions workflow) |
| Propagation | up to 10 minutes |

### Do / don't
- Use Actions for deploys, not the gem
- Verify custom domains before use (takeover prevention)
- Enforce HTTPS
- `.gitignore` out `Gemfile.lock`, `node_modules`, `vendor`
- Don't use Pages for e-commerce, SaaS, or anything handling payments/passwords
- Don't use unsupported Jekyll plugins — build locally and push static output instead
- Don't use symlinks — use an Actions workflow instead
- Don't exceed the 1 GB soft limit

### Jekyll site layout
```
repo/
├── _config.yml
├── _posts/              # YYYY-MM-DD-title.md
├── _layouts/
├── _data/
├── assets/css/style.scss
├── about.md
├── index.md
├── Gemfile
├── .nojekyll            # only if using a non-Jekyll SSG
└── README.md
```

## Part 2: Wikis

### What it is
Every repo has a built-in Wiki tab — a separate Git repo (`<repo>.wiki.git`) you can clone and edit locally, for long-form docs.

### Setup
1. Repo → Wiki tab → "Create the first page"
2. Write in Markdown (or Textile/AsciiDoc/RST via GitHub's [markup library](https://github.com/github/markup))
3. Save

Clone locally: `git clone https://github.com/YOUR-USER/YOUR-REPO.wiki.git`

### Structure
```
YOUR-REPO.wiki/
├── Home.md              # required landing page
├── Getting-Started.md
├── API-Reference.md
├── _Sidebar.md          # appears on every page
├── _Footer.md           # appears on every page
└── .gitignore
```
Filenames avoid `\ / : * ? " < > |`; the extension picks the renderer (`.md` = Markdown); the filename becomes the page title.

### Features
Image embeds (PNG/JPEG/GIF), Markdown or MediaWiki-style `[[PageName|text]]` links, `$$...$$` math, diagrams/maps/3D models, full edit history (every save = a commit, diffable/revertable), and search (public-repo wikis are only indexed by search engines once they have 500+ stars and public editing disabled).

### Access
Default: only collaborators with write access can edit. Repo → Settings → Features → uncheck "Restrict editing to collaborators only" to allow any GitHub user to contribute (public repos only).

### Limits
5,000 files max. No transclusion, definition lists, indentation, or auto-TOC. `---` (horizontal rule) and HTML entities always render regardless of markup language chosen.

## Part 3: Pages vs. Wikis

| Factor | GitHub Pages | Wikis |
|---|---|---|
| Purpose | Full website, blog, SPA | Long-form docs, guides |
| URL | Custom domain or `<user>.github.io/<repo>` | Part of repo UI (`/wiki`) |
| Stack | Any SSG + HTML/CSS/JS | Markdown + GitHub Markup |
| Build | Optional (Jekyll or Actions) | None — rendered live |
| Version control | Full Git repo | Separate `.wiki.git` repo |
| Collaboration | Pull requests | Direct edits (or PRs to wiki repo) |
| Search indexing | Yes | Only 500+ starred repos |
| Best for | Marketing sites, SPAs, blogs, public landing pages | README-level docs needing more room |

**GitHub's own recommendation: if you need search-engine indexing, use Pages on a public repo.**

## Part 4: Recommended layout when you want both

```
your-repo/
├── .github/workflows/
│   └── deploy-pages.yml       # Actions workflow for Pages
├── docs/                      # Pages publishing source
│   ├── index.md
│   ├── _config.yml
│   ├── _posts/                # optional
│   ├── assets/css/style.scss
│   ├── Gemfile
│   └── .nojekyll              # only for non-Jekyll SSGs
├── src/                       # actual project source
├── tests/
├── README.md                  # links to both Pages + Wiki
└── (Wiki lives in its own .wiki.git repo, via the Wiki tab)
```
`Settings → Pages → Source: main branch, /docs folder` keeps docs next to code instead of on a dangling `gh-pages` branch. The Pages site serves curated, styled documentation; the Wiki serves living, editable documentation.

## Part 5: Decision flowchart

- Need a full website with a custom domain? → **GitHub Pages**
  - Simple static → plain HTML/CSS/JS or Jekyll
  - Modern framework → Vite/Next.js/Astro + Actions workflow
  - Just project docs → Jekyll (or MkDocs) from `/docs`
- Just project documentation, no site?
  - Shorter than a README → put it in the README
  - Medium, a handful of pages → Wiki
  - Long, deeply structured → Pages from `/docs`
  - Needs to be searchable on Google → must be Pages (public repo)

## How this maps onto what you already have

`grimoire`'s `docs.yaml` is already the textbook version of this: MkDocs building from `docs/user/`, deployed via `actions/upload-pages-artifact` + `actions/deploy-pages`, least-privilege `pages: write, id-token: write` permissions, `concurrency` group named `pages`. That workflow can be lifted almost as-is into the reference repo's `workflow-templates/deploy-pages.yml`.

`bigbase/ci.yml`'s `report` job deploys an Allure test-report dashboard to `gh-pages` via `peaceiris/actions-gh-pages` — a different, older pattern (branch-based, third-party action) than the modern `actions/deploy-pages` approach. Fine to leave as-is since it's a test-report artifact rather than a public docs site, but not the pattern to copy for new projects.

Pages and bigbase.click aren't competing — they serve different things. Pages is the right tool specifically for a repo's public docs/marketing site (free, custom domain, Google-indexed, zero server to run). bigbase.click is the deploy target for the actual applications. A project can reasonably use both: Pages for `docs.<project>.com`, bigbase for the live app at `<project>.bigbase.click`.
