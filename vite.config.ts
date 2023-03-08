import { defineConfig } from "vite";
import basicSsl from "@vitejs/plugin-basic-ssl";
import elmPlugin from "vite-plugin-elm";

export default defineConfig({
  plugins: [basicSsl(), elmPlugin()],
});
