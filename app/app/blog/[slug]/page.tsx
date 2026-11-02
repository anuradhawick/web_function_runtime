import type { Metadata } from "next";
import Image from "next/image";
import { connection } from "next/server";
import Markdown from "react-markdown";
import { getPost } from "@/lib/posts";

type Props = { params: Promise<{ slug: string }> };

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug } = await params;
  const post = await getPost(slug);
  return {
    title: post.title,
    description: post.description,
    openGraph: {
      type: "article",
      title: post.title,
      description: post.description,
      url: `/blog/${slug}`,
      images: [{ url: post.image, width: 1200, height: 655, alt: post.title }],
    },
    twitter: {
      card: "summary_large_image",
      title: post.title,
      description: post.description,
      images: [post.image],
    },
  };
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
        width={1200}
        height={655}
        unoptimized
      />
      <Markdown>{post.content}</Markdown>
      <p>Rendered on the server at <time dateTime={renderedAt}>{renderedAt}</time>.</p>
    </article>
  );
}
