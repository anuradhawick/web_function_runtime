import type { Metadata } from "next";
import Link from "next/link";
import "./globals.css";

export const metadata: Metadata = {
  title: {
    default: "Home | Simple Blog",
    template: "%s | Simple Blog",
  },
  description: "A small Markdown blog demonstrating server-side rendering and SEO.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <nav aria-label="Main navigation">
          <Link href="/" prefetch={false}>Home</Link>
          <Link href="/blog/blog-1" prefetch={false}>Blog 1</Link>
          <Link href="/blog/blog-2" prefetch={false}>Blog 2</Link>
        </nav>
        <main>{children}</main>
      </body>
    </html>
  );
}
