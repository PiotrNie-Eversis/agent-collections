# Accessibility

For user-facing UI:

- Use semantic HTML; prefer native controls.
- Ensure keyboard operability and visible focus.
- Label interactive controls; use ARIA only when semantics are insufficient.
- Respect project design system and contrast requirements.

Align with WCAG targets your project defines in the **consumer project stack** document or `docs/context/`.

Path scoping for UI file types (e.g. component extensions) belongs in **adapters**, not in this core rule.
