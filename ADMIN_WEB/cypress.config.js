import { defineConfig } from "cypress";

export default defineConfig({
  e2e: {
    baseUrl: "http://localhost:5174",
  },

  component: {
    devServer: {
      framework: "vue",
      bundler: "vite",
    },
  },
});
