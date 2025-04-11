import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
  output: 'standalone',
  reactStrictMode: true,
  productionBrowserSourceMaps: true,
};

export default nextConfig;
