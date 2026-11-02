import type { Metadata } from "next";
import Image from "next/image";
import { connection } from "next/server";
import Markdown from "react-markdown";
import { getPost } from "@/lib/posts";

type Props = { params: Promise<{ slug: string }> };

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug } = await params;
  const post = await getPost(slug);
  return { title: post.title, description: post.description };
}

export default async function BlogPost({ params }: Props) {
  await connection();
  const { slug } = await params;
  const post = await getPost(slug);
  const renderedAt = new Date().toISOString();

  return (
    <article>
      <h1>{post.title}</h1>
      <p>{post.description}</p>
      <Image
        src={post.image}
        alt={`${post.title} sign above a laptop`}
        width={2816}
        height={1536}
        unoptimized
      />
      <Markdown>{post.content}</Markdown>
      <p>Rendered on the server at <time dateTime={renderedAt}>{renderedAt}</time>.</p>
    </article>
  );
}
