# Simple SSR blog

```bash
pnpm install
pnpm dev
```

- `/`: home page.
- `/blog/blog-1` and `/blog/blog-2`: one dynamic route reading `content/*.md`.
- `lib/posts.ts`: reads Markdown and its title, description, and image frontmatter.
- `app/blog/[slug]/page.tsx`: renders Markdown and generates each post's SEO metadata.

`connection()` makes the pages render on request. Refresh to see the server timestamp
change. View page source (or use curl) to inspect the article, title, and description
without running browser JavaScript. Unknown post URLs return 404.

The CSS only sets readable spacing and responsive images. Markdown files are included
in the standalone build for Lambda deployment.

```bash
pnpm build
pnpm start
```
