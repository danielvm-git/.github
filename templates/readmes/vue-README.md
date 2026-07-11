## Project title

MyVueApp — A high-performance Vue 3 application scaffolded with Vite, written in TypeScript, powered by Pinia and Vue Router.

## Motivation

Vue 3's Composition API unlocks scalable logic reuse without mixin collisions. Combined with Vite's instant HMR and TypeScript's type safety, this stack ships fast, stays maintainable, and scales from prototype to production.

---

## Build status

```markdown
[![Vue CI](https://github.com/YOUR_ORG/YOUR_REPO/actions/workflows/ci.yml/badge.svg)](https://github.com/YOUR_ORG/YOUR_REPO/actions/workflows/ci.yml)
```

GitHub Actions runs `pnpm typecheck`, `pnpm lint`, and `pnpm test` on every push.

---

## Code style

- **ESLint** with `@vue/eslint-config-typescript` and `eslint-plugin-vue`
- **Prettier** with `@vue/prettier` plugin
- Hooks enforce style on commit via `lint-staged`

```jsonc
// .eslintrc.cjs
module.exports = {
  extends: [
    'plugin:vue/vue3-recommended',
    '@vue/eslint-config-typescript',
    '@vue/prettier',
  ],
  rules: {
    'vue/multi-word-component-names': 'error',
    'vue/no-mutating-props': 'error',
  },
}
```

---

## Screenshots

> _Include screenshots of key views: dashboard, data tables, modals, mobile responsive states._

---

## Tech/framework used

| Tool | Purpose |
|------|---------|
| **Vue 3** | Reactive UI framework (Composition API) |
| **Vite** | Dev server, HMR, build bundler |
| **TypeScript** | Type-safe codebase |
| **Pinia** | State management |
| **Vue Router** | Client-side routing |
| **Vitest** | Unit & integration testing |
| **Vue Test Utils** | Component mounting & assertions |

---

## Features

- **Composition API** — logic extracted into reusable composables (`useAuth`, `usePagination`)
- **Typed store modules** — Pinia stores with full TypeScript inference
- **Route guards** — Navigation guards for auth-protected pages
- **Auto-imports** — `unplugin-auto-import` for Vue APIs (`ref`, `computed`, `watch`)
- **Lazy routes** — Route-level code splitting with dynamic `import()`
- **Environment variables** — `import.meta.env` for typed env config
- **Scoped styles** — `<style scoped>` with CSS variables per component

---

## Code Example

```vue
<script setup lang="ts">
import { ref, computed } from 'vue'
import { useUserStore } from '@/stores/user'

interface Props {
  initialCount?: number
}

const props = withDefaults(defineProps<Props>(), {
  initialCount: 0,
})

const emit = defineEmits<{
  update: [value: number]
}>()

const userStore = useUserStore()
const count = ref(props.initialCount)
const doubled = computed(() => count.value * 2)

function increment(): void {
  count.value++
  emit('update', count.value)
}
</script>

<template>
  <div class="counter">
    <p>{{ userStore.name }} — Count: {{ count }}</p>
    <p>Doubled: {{ doubled }}</p>
    <button @click="increment">+1</button>
  </div>
</template>

<style scoped>
.counter {
  display: flex;
  gap: 1rem;
  align-items: center;
  font-family: var(--font-mono);
}
</style>
```

---

## Installation

```bash
# Scaffold a new project
npm create vue@latest my-project -- --typescript

# Or use pnpm (recommended)
pnpm create vue@latest my-project --typescript

cd my-project

# Install dependencies
pnpm install

# Start dev server
pnpm dev
```

---

## API Reference

- [Vue 3 Docs](https://vuejs.org/guide/introduction.html)
- [Vite Docs](https://vitejs.dev/guide/)
- [Pinia Docs](https://pinia.vuejs.org/)
- [Vue Router Docs](https://router.vuejs.org/)
- [Vitest Docs](https://vitest.dev/)
- [Vue Test Utils](https://test-utils.vuejs.org/)

---

## Tests

Tests use **Vitest** + **Vue Test Utils** with component mounting.

```ts
// src/components/__tests__/Counter.spec.ts
import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Counter from '../Counter.vue'

describe('Counter', () => {
  it('renders initial count', () => {
    const wrapper = mount(Counter, {
      props: { initialCount: 5 },
    })
    expect(wrapper.text()).toContain('Count: 5')
  })

  it('emits update on click', async () => {
    const wrapper = mount(Counter)
    await wrapper.find('button').trigger('click')
    expect(wrapper.emitted('update')?.[0]).toEqual([1])
  })
})
```

```bash
pnpm test          # single run
pnpm test:watch    # watch mode
pnpm test:coverage # with coverage report
```

---

## How to use

1. **Clone** the repo: `git clone <repo-url>`
2. **Install**: `pnpm install`
3. **Copy env**: `cp .env.example .env` and fill required vars
4. **Dev**: `pnpm dev` — opens `http://localhost:5173`
5. **Typecheck**: `pnpm typecheck`
6. **Lint**: `pnpm lint`
7. **Test**: `pnpm test`
8. **Build**: `pnpm build` — outputs to `dist/`
9. **Deploy**: Push to `main` — CI deploys to BigBase via `ci-cd-static.yml`

---

## Contribute

1. Fork the repo
2. Create a feature branch: `git checkout -b feat/my-feature`
3. Commit using [Conventional Commits](https://www.conventionalcommits.org/)
4. Push and open a Pull Request

All contributions must pass typecheck, lint, and tests.

---

## Credits

Based on the [Kickass README](https://github.com/akashnimare/readme-template) template by Akash Nimare.

---

## License

MIT — see [LICENSE](./LICENSE) for details.
