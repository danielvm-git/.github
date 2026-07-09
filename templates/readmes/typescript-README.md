## Project title

my-typescript-service — A production-ready Node.js service built with TypeScript, with static typing from API to database.

## Motivation

TypeScript brings static typing to Node.js, catching entire classes of bugs at compile time rather than runtime. This project exists to [solve specific problem] — because in production, `undefined is not a function` is not an acceptable error message.

## Build status

```markdown
[![CI](https://github.com/OWNER/REPO/workflows/CI/badge.svg)](https://github.com/OWNER/REPO/actions)
```

Runs `tsc --noEmit` for type checking, `vitest run` for tests, and `eslint src/` for lint on every push and PR.

## Code style

- **ESLint** with `@typescript-eslint` ruleset — strict type-aware linting
- **Prettier** — automatic formatting (single quotes, trailing commas, 100 print width)
- **Husky + lint-staged** — format and lint on every commit

```jsonc
// .eslintrc.cjs
module.exports = {
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/strict-type-checked',
    'prettier',
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: { project: './tsconfig.json' },
  rules: {
    '@typescript-eslint/no-unused-vars': 'error',
    '@typescript-eslint/explicit-function-return-type': 'warn',
  },
};
```

## Screenshots

<!-- TODO: Add terminal screenshots of the running service -->

## Tech/framework used

| Layer | Choice |
|-------|--------|
| Language | TypeScript 5.x |
| Runtime | Node.js 22 LTS |
| Package manager | pnpm (or npm) |
| Framework | Hono (or Express) |
| Testing | vitest |
| Linting | ESLint + Prettier |
| Compilation | `tsc` (emit via `tsup` / `tsc --outDir dist`) |

## Features

- **Strict mode** — `strict: true` in `tsconfig.json`; no `any` escapes
- **Runtime type safety** — Zod or Valibot for input validation at service boundaries
- **Tree-shakeable builds** — ESM-first output via `tsup`
- **Path aliases** — `@/` mapped to `src/` via `paths` in `tsconfig.json`
- **Source maps** — emitted for production debugging
- **Graceful shutdown** — `SIGTERM` / `SIGINT` handlers with `http-server.close()`

## Code Example

```typescript
import { Hono } from 'hono';
import { z } from 'zod';

const app = new Hono();

const CreateUserSchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
});

app.post('/users', async (c) => {
  const body = CreateUserSchema.safeParse(await c.req.json());
  if (!body.success) {
    return c.json({ error: body.error.flatten() }, 400);
  }
  const user = await db.insertInto('users').values(body.data).returningAll().executeTakeFirst();
  return c.json(user, 201);
});

export default app;
```

## Installation

```bash
pnpm create      # or: npm init
pnpm add hono zod
pnpm add -D typescript @types/node vitest eslint prettier
pnpm dlx tsc --init
```

Configure TypeScript:

```jsonc
// tsconfig.json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": true,
    "outDir": "dist",
    "rootDir": "src",
    "paths": { "@/*": ["./src/*"] }
  },
  "include": ["src"]
}
```

## API Reference

- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html)
- [Node.js API docs](https://nodejs.org/docs/latest/api/)
- [Hono docs](https://hono.dev/)
- [Zod docs](https://zod.dev/)

## Tests

All tests live in `src/__tests__/` and mirror the source tree. Written with **vitest**.

```typescript
import { describe, it, expect } from 'vitest';
import { parseUserPayload } from '../user.js';

describe('parseUserPayload', () => {
  it('rejects missing email', () => {
    const result = parseUserPayload({ name: 'Alice' });
    expect(result.success).toBe(false);
  });

  it('parses a valid payload', () => {
    const result = parseUserPayload({ name: 'Alice', email: 'alice@example.com' });
    expect(result.success).toBe(true);
  });
});
```

```bash
pnpm vitest run     # CI mode
pnpm vitest         # watch mode
pnpm vitest --ui    # Vitest UI dashboard
```

## How to use

```bash
# 1. Clone
git clone https://github.com/OWNER/REPO.git
cd REPO

# 2. Install
pnpm install

# 3. Set environment variables
cp .env.example .env

# 4. Type-check
pnpm tsc --noEmit

# 5. Run tests
pnpm vitest run

# 6. Start dev server
pnpm dev

# 7. Build for production
pnpm build   # outputs to dist/
```

## Contribute

1. Fork the repo
2. Create a feature branch (`git checkout -b feat/amazing`)
3. Write code; ensure `pnpm tsc --noEmit` and `pnpm vitest run` pass
4. Commit with Conventional Commits (`feat:`, `fix:`, `chore:`)
5. Open a pull request

All contributions must pass type-checking, linting, and tests. No PR will be merged with red CI.

## Credits

This README follows the **Kickass README** template by [Akash Nimare](https://github.com/akashnimare). Original inspiration from [Billie Thompson's README template](https://gist.github.com/PurpleBooth/109311bb0361f32d87a2).

## License

MIT © [YOUR NAME]
