---
sidebar_position: 30
title: Frontend Review
---

# Frontend Review

**Folder:** `.cursor/skills/eversis-reviewing-frontend/`  
**Used by:** Code Reviewer

Provides frontend-specific code review criteria covering component anti-patterns, hooks quality, rendering correctness, accessibility and performance spot-checks, and module organization issues.

## Key Areas

| Area                    | Coverage                                                         |
| ----------------------- | ---------------------------------------------------------------- |
| **Component Quality**   | Anti-patterns, composition issues, prop drilling, god components |
| **Hooks Correctness**   | Dependency arrays, cleanup, rules of hooks violations            |
| **Rendering**           | Unnecessary re-renders, unstable references, missing memoization |
| **Accessibility**       | Missing ARIA, keyboard traps, contrast violations                |
| **Performance**         | Bundle impact, large dependencies, unoptimized assets            |
| **Module Organization** | Barrel files, circular dependencies, colocation issues           |

## When to Use

- Reviewing frontend pull requests.
- Auditing component quality.
- Identifying UI-specific code smells beyond general code review.

## Reference Files

- `references/react-patterns.md` — React-specific review checklist items.

## Connected Skills

- `eversis-code-reviewing` — General code review process (this skill extends it for frontend).
- `eversis-implementing-frontend` — The patterns this skill reviews against.
- `eversis-ensuring-accessibility` — Detailed a11y criteria for deeper checks.
- `eversis-optimizing-frontend` — Performance criteria for deeper checks.
