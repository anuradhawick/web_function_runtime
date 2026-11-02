import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: "standalone",
  // Markdown is read from disk when a page is requested.
  outputFileTracingIncludes: {
    "/*": ["./content/*.md"],
  },
};

export default nextConfig;
