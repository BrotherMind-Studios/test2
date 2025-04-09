import type { NextConfig } from "next";
const isCI = process.env.CI === "true";

const nextConfig: NextConfig = {
  /* config options here */
  reactStrictMode: true,
  productionBrowserSourceMaps: true,
};

export default nextConfig;
