## Project title

# Astro Starter

A production-ready Astro 5 site using content collections, server islands, and framework-agnostic components. Zero JS by default — hydrate only what you need.

## Motivation

Astro delivers the fastest possible frontend by shipping zero client JavaScript by default. This project exists to demonstrate an architecture that combines static generation with on-demand server islands, structured content management via collections, and deploy-on-any-adapter flexibility (Vercel, Netlify, Node). Every decision — from `.astro` components to MDX integration — prioritises runtime performance and developer experience.

## Build status

```yaml
# .github/workflows/deploy.yml
name: Deploy
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
      - run: npm ci
      - run: npm run build
      - run: npm run astro check
```

[![CI](https://github.com/user/repo/actions/workflows/deploy.yml/badge.svg)](https://github.com/user/repo/actions/workflows/deploy.yml)

## Code style

- [Prettier](https://prettier.io) with `prettier-plugin-astro`
- ESLint with `eslint-plugin-astro`
- TypeScript strict mode

```json
// .prettierrc
{
  "plugins": ["prettier-plugin-astro"],
  "semi": false,
  "singleQuote": true,
  "trailingComma": "all"
}
```

[![code style: prettier](https://img.shields.io/badge/code_style-prettier-ff69b4.svg)](https://github.com/prettier/prettier)

## Screenshots

> Replace with a screenshot of your running Astro site, the Content Collection admin view, or a Lighthouse performance report (100/100).

## Tech/framework used

<b>Built with</b>

- [Astro 5](https://astro.build) — web framework for content-driven sites
- [Content Collections](https://docs.astro.build/en/guides/content-collections/) — type-safe Markdown / MDX content layer
- [MDX](https://mdxjs.com) — embedded components in Markdown
- [Adapter: Vercel](https://docs.astro.build/en/guides/deploy/vercel/) — edge / serverless deployment
- [Adapter: Netlify](https://docs.astro.build/en/guides/deploy/netlify/) — Netlify Functions + SSR
- [Adapter: Node](https://docs.astro.build/en/guides/deploy/node/) — standalone Node.js server

## Features

- **Zero JS by default** — static HTML is the default output; JavaScript is only loaded for interactive islands.
- **Server islands** — `server:defer` islands that stream in after the initial page load, perfect for personalised or dynamic content.
- **Content Collections** — define a schema with Zod, then query posts, docs, or products with full TypeScript inference.
- **View Transitions** — SPA-like navigation with the browser's native View Transition API.
- **Multi-adapter SSR** — switch between Vercel, Netlify, or Node with a single config change.
- **Image optimisation** — `@astrojs/image` with automatic AVIF/WebP and lazy loading.
- **`astro:assets`** — built-in asset pipeline for hashed filenames and cache busting.

## Code Example

```astro
---
// src/pages/blog/\[slug\].astro
import { getCollection, type CollectionEntry } from 'astro:content'
import Layout from '../../layouts/BlogLayout.astro'

export async function getStaticPaths() {
  const posts = await getCollection('blog')
  return posts.map((post) => ({
    params: { slug: post.slug },
    props: { post },
  }))
}

type Props = { post: CollectionEntry<'blog'> }
const { post } = Astro.props
const { Content } = await post.render()
---

<Layout title={post.data.title} description={post.data.description}>
  <article>
    <h1>{post.data.title}</h1>
    <p class="meta">{post.data.pubDate.toLocaleDateString()}</p>
    <Content />
  </article>

  <LikeButton server:defer />
</Layout>
```

The `LikeButton` above is a server island — it renders on the server and streams in as a lightweight interactive widget, without blocking the static article content.

## Installation

```bash
npm create astro@latest -- --template minimal
cd my-project
npm install @astrojs/mdx @astrojs/vercel
```

Update `astro.config.mjs` with your chosen adapter:

```js
// astro.config.mjs
import { defineConfig } from 'astro/config'
import mdx from '@astrojs/mdx'
import vercel from '@astrojs/vercel/serverless'

export default defineConfig({
  integrations: [mdx()],
  output: 'hybrid',
  adapter: vercel(),
})
```

## API Reference

Full API reference at [docs.astro.build](https://docs.astro.build).

| Module | Purpose |
|--------|---------|
| `astro:content` | `getCollection()`, `getEntry()`, `render()` |
| `astro:assets` | `Image`, `Picture`, `getImage()` |
| `Astro` global | `Astro.props`, `Astro.url`, `Astro.request` |
| `Astro.locals` | Runtime request-scoped data (middleware) |

## Tests

```bash
# Type-check all .astro files
npx astro check

# Unit and integration tests with Vitest
npx vitest run

# Example: test a content collection query
```

```ts
// src/content/config.ts
import { defineCollection, z } from 'astro:content'

export const collections = {
  blog: defineCollection({
    type: 'content',
    schema: z.object({
      title: z.string(),
      pubDate: z.date(),
      description: z.string().optional(),
    }),
  }),
}
```

```ts
// src/pages/blog/\[slug\].astro — types inferred from schema
const posts = await getCollection('blog')
//    ^ CollectionEntry<'blog'>[]
```

```bash
# Validate collection schema at build time
npm run build
```

## How to use

```bash
# Development
npm run dev              # localhost:4321

# Build for production
npm run build            # output in dist/

# Preview the build
npm run preview

# Deploy
# Set ADAPTER=vercel in CI or switch astro.config.mjs
npm run build
npx vercel --prod
```

Point your domain and you're live.

## Contribute

Contributions are welcome. Please open an issue first to discuss your proposal.

1. Fork the repository
2. Create a feature branch (`git checkout -b feat/amazing`)
3. Commit changes (`git commit -m 'feat: add amazing thing'`)
4. Push (`git push origin feat/amazing`)
5. Open a Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full guideline.

## Credits

This guide is based on the [Kickass README](https://github.com/akashnimare/kickass-readme) template by Akash Nimare.

## License

MIT © [Your Name](https://github.com/yourname)
