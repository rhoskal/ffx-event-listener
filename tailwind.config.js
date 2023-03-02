const defaultTheme = require("tailwindcss/defaultTheme");

/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["index.html", "./src/**/*.{elm,js,ts}"],
  theme: {
    extend: {
      fontFamily: {
        mono: [...defaultTheme.fontFamily.mono],
        sans: ["Roboto", ...defaultTheme.fontFamily.sans],
        serif: ["Josefin Sans", ...defaultTheme.fontFamily.serif],
      },
    },
  },
  plugins: [require("@tailwindcss/forms"), require("@tailwindcss/typography")],
};
