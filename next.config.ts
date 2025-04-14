import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
  reactStrictMode: true,
  output: 'standalone',
  productionBrowserSourceMaps: process.env.GENERATE_SOURCEMAPS === "true",
};

export default nextConfig;
