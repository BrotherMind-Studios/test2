import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
  reactStrictMode: true,
  productionBrowserSourceMaps: process.env.GENERATE_SOURCEMAPS === "true",
};

export default nextConfig;
