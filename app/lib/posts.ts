import { readFile, readdir } from "node:fs/promises";
import path from "node:path";
import { cache } from "react";
import matter from "gray-matter";
import { notFound } from "next/navigation";

const directory = path.join(process.cwd(), "content");

type PostMetadata = {
  title: string;
  description: string;
  image: string;
};

// React cache shares the read between the page and metadata in one request.
export const getPost = cache(async (slug: string) => {
  const files = await readdir(directory);
  if (!/^[a-z0-9-]+$/.test(slug) || !files.includes(`${slug}.md`)) {
    notFound();
  }

  const source = await readFile(path.join(directory, `${slug}.md`), "utf8");
  const { data, content } = matter(source);
  return { ...(data as PostMetadata), slug, content };
});

export async function getPosts() {
  const files = await readdir(directory);
  return Promise.all(
    files.filter((file) => file.endsWith(".md")).sort().map((file) => getPost(file.slice(0, -3))),
  );
}
