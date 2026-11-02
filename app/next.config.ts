import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: "standalone",
  // This demo serves original images, so it needs no native image processor.
  images: { unoptimized: true },
  outputFileTracingExcludes: {
    "*": ["**/sharp/**", "**/@img/**"],
  },
  // Markdown is read from disk when a page is requested.
  outputFileTracingIncludes: {
    "/*": ["./content/*.md"],
  },
};

export default nextConfig;
