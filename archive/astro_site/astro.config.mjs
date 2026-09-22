import { defineConfig } from "astro/config";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  site: "https://funapp.world",
  vite: {
    plugins: [tailwindcss()],
  },
});
