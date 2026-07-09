## Project title

<!-- Replace: Your SvelteKit project name -->

A full-stack SvelteKit application built with Svelte 5, TypeScript, and file-based routing. Renders server-side (SSR), hydrates on the client, and deploys via your preferred adapter.

## Motivation

SvelteKit is the official application framework for Svelte. It provides a unified development model for server-rendered pages, API endpoints, and form mutations — all with minimal boilerplate and maximal performance. Use this template to bootstrap projects with zero-config Vite, file-based routing, and first-class TypeScript support.

## Build status

```yaml
# .github/workflows/ci.yml
name: CI
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'pnpm'
      - run: pnpm install
      - run: pnpm lint
      - run: pnpm check
      - run: pnpm test
      - run: pnpm build
```

## Code style

```json
{
  "extends": [
    "eslint:recommended",
    "plugin:svelte/recommended",
    "plugin:svelte/prettier"
  ],
  "parser": "@typescript-eslint/parser",
  "plugins": ["@typescript-eslint"],
  "parserOptions": {
    "project": "./tsconfig.json",
    "extraFileExtensions": [".svelte"]
  }
}
```

Formatting is enforced via Prettier with the `prettier-plugin-svelte` plugin. Run `pnpm lint` to check and `pnpm format` to auto-fix.

## Screenshots

<!-- Replace with actual screenshots -->
| Home | Dashboard | Mobile |
|------|-----------|--------|
| ![Home](screenshots/home.png) | ![Dashboard](screenshots/dashboard.png) | ![Mobile](screenshots/mobile.png) |

## Tech/framework used

**Built with**

- [SvelteKit](https://kit.svelte.dev) — full-stack framework
- [Svelte 5](https://svelte.dev) — runes, snippets, event handlers
- [TypeScript](https://www.typescriptlang.org) — type-safe code
- [Vite](https://vitejs.dev) — dev server and bundler
- [adapter-vercel](https://kit.svelte.dev/docs/adapter-vercel) | [adapter-netlify](https://kit.svelte.dev/docs/adapter-netlify) | [adapter-cloudflare](https://kit.svelte.dev/docs/adapter-cloudflare) — deployment targets
- [Vitest](https://vitest.dev) — unit and integration tests
- [ESLint](https://eslint.org) + [Prettier](https://prettier.io) — linting and formatting

## Features

- **File-based routing** — `+page.svelte`, `+layout.svelte`, `+server.ts` define routes without config
- **Server-side rendering (SSR)** — pages render on the server by default for fast TTFB
- **Load functions** — `load` in `+page.server.ts` fetches data before the page renders
- **Form actions** — `actions` in `+page.server.ts` handle POST/PUT/DELETE with validation
- **Adapters** — deploy to Vercel, Netlify, Cloudflare, Node, or Docker with one config change
- **Type safety** — auto-generated types for route params, load data, and form errors
- **Svelte 5 runes** — `$state`, `$derived`, `$effect` for reactive declarations
- **Snippets** — reuse markup via `{#snippet}` blocks instead of component slots

## Code Example

### Route: `src/routes/todos/+page.svelte`

```svelte
<script lang="ts">
  import { enhance } from '$app/forms';
  import type { PageData } from './$types';

  let { data } = $props<{ data: PageData }>();

  let newTodo = $state('');
</script>

<h1>Todos</h1>

<form method="POST" use:enhance>
  <input
    name="title"
    bind:value={newTodo}
    placeholder="What needs to be done?"
  />
  <button type="submit">Add</button>
</form>

<ul>
  {#each data.todos as todo}
    <li>
      <form method="POST" action="?/toggle">
        <input type="hidden" name="id" value={todo.id} />
        <input
          type="checkbox"
          checked={todo.completed}
          onchange={() => this.form?.requestSubmit()}
        />
      </form>
      {todo.title}
    </li>
  {/each}
</ul>
```

### Route: `src/routes/todos/+page.server.ts`

```ts
import type { PageServerLoad, Actions } from './$types';
import { fail } from '@sveltejs/kit';

interface Todo {
  id: string;
  title: string;
  completed: boolean;
}

let todos: Todo[] = [];

export const load: PageServerLoad = async () => {
  return { todos };
};

export const actions: Actions = {
  default: async ({ request }) => {
    const data = await request.formData();
    const title = data.get('title')?.toString().trim();

    if (!title) {
      return fail(400, { error: 'Title is required' });
    }

    const todo: Todo = {
      id: crypto.randomUUID(),
      title,
      completed: false,
    };

    todos.push(todo);

    return { success: true };
  },

  toggle: async ({ request }) => {
    const data = await request.formData();
    const id = data.get('id')?.toString();
    const todo = todos.find((t) => t.id === id);

    if (todo) {
      todo.completed = !todo.completed;
    }

    return { success: true };
  },
};
```

## Installation

```bash
# Create a new SvelteKit project
npx sv create my-app --template minimal
cd my-app

# Install dependencies
pnpm install

# Start dev server
pnpm dev
```

Add an adapter for your deployment target:

```bash
# Vercel
pnpm add -D @sveltejs/adapter-vercel

# Netlify
pnpm add -D @sveltejs/adapter-netlify

# Cloudflare
pnpm add -D @sveltejs/adapter-cloudflare
```

## API Reference

See the official [SvelteKit documentation](https://kit.svelte.dev/docs) for full API coverage:

- [Routing](https://kit.svelte.dev/docs/routing)
- [Load functions](https://kit.svelte.dev/docs/load)
- [Form actions](https://kit.svelte.dev/docs/form-actions)
- [Adapters](https://kit.svelte.dev/docs/adapters)
- [Configuration](https://kit.svelte.dev/docs/configuration)

## Tests

Tests use [Vitest](https://vitest.dev) with `@sveltejs/vite-plugin-svelte` for component rendering.

```bash
pnpm add -D vitest @sveltejs/vite-plugin-svelte
```

```ts
// vite.config.ts
import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vitest/config';

export default defineConfig({
  plugins: [sveltekit()],
  test: {
    include: ['src/**/*.{test,spec}.{js,ts}'],
  },
});
```

```ts
// src/routes/todos/+page.server.test.ts
import { describe, it, expect } from 'vitest';
import { actions } from './+page.server.js';

describe('todo actions', () => {
  it('rejects empty title', async () => {
    const form = new FormData();
    form.set('title', '  ');
    const result = await actions.default({ request: new Request('http://localhost', { method: 'POST', body: form }) } as any);
    expect(result.status).toBe(400);
  });
});
```

```bash
pnpm vitest run
```

## How to use

1. **Scaffold** — run `npx sv create my-app` with your preferred template
2. **Develop** — `pnpm dev` starts the Vite dev server at `http://localhost:5173`
3. **Structure** — add routes under `src/routes/` using `+page.svelte` files
4. **Data** — fetch in `+page.server.ts` load functions; mutate via form actions
5. **Build** — `pnpm build` produces an optimized production bundle
6. **Deploy** — set your adapter in `svelte.config.js` and push to your provider

## Contribute

Contributions are welcome. Please open an issue first to discuss changes. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

1. Fork the repository
2. Create a feature branch (`git checkout -b feat/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feat/amazing-feature`)
5. Open a Pull Request

## Credits

This guide is based on the [Kickass README](https://github.com/akashnimare/readme-template) template by Akash Nimare.

## License

MIT © [Your Name]

<!--
This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
-->
