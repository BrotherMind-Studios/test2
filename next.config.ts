import type { NextConfig } from "next";
const isCI = process.env.CI === "true";

const nextConfig: NextConfig = {
  /* config options here */
  reactStrictMode: true,
  productionBrowserSourceMaps: process.env.GENERATE_SOURCEMAPS === "true",
};

export default nextConfig;
