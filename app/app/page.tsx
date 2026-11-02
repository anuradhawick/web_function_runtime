import Image from "next/image";
import Link from "next/link";
import { connection } from "next/server";
import { getPosts } from "@/lib/posts";

export default async function Home() {
  await connection();
  const posts = await getPosts();
  const renderedAt = new Date().toISOString();

  return (
    <>
      <h1>Hello world</h1>
      <p>A simple blog about server-side rendering and SEO.</p>
      <Image
        src="/hello%20world.jpeg"
        alt="A hello world sign above a laptop"
        width={2816}
        height={1536}
        unoptimized
      />
      <h2>Blog posts</h2>
      <ul>
        {posts.map((post) => (
          <li key={post.slug}>
            <Link href={`/blog/${post.slug}`} prefetch={false}>{post.title}</Link>
            <p>{post.description}</p>
          </li>
        ))}
      </ul>
      <p>Rendered on the server at <time dateTime={renderedAt}>{renderedAt}</time>.</p>
    </>
  );
}
