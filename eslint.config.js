const { FlatCompat } = require("@eslint/eslintrc");
const js = require("@eslint/js");
const tsParser = require("@typescript-eslint/parser");
const eslintPluginImport = require("eslint-plugin-import");
const eslintPluginPrettier = require("eslint-plugin-prettier");

const compat = new FlatCompat({
  baseDirectory: __dirname,
  recommendedConfig: js.configs.recommended,
});

module.exports = [
  {
    plugins: {
      import: eslintPluginImport,
      prettier: eslintPluginPrettier,
    },
  },
  {
    files: ["src/**/*.{js,ts,mjs,mts}"],
    ignores: ["src/**/*.d.ts"],
    languageOptions: {
      parser: tsParser,
    },
    rules: {
      "import/first": "error",
      "import/newline-after-import": "error",
      "import/no-cycle": "error",
      "import/no-relative-parent-imports": "error",
      "import/no-self-import": "error",
      "import/order": [
        "error",
        {
          groups: [["builtin", "external", "internal"], ["sibling", "parent"], ["index"]],
          "newlines-between": "always",
          alphabetize: {
            order: "asc",
            caseInsensitive: true,
          },
        },
      ],
      "no-unused-vars": ["error", { vars: "all", args: "none" }],
      "prettier/prettier": "error",
    },
  },
  ...compat.config({}).map((config) => ({
    ...config,
    files: ["**/*.js"],
    rules: {},
  })),
  ...compat.config({}).map((config) => ({
    ...config,
    files: ["**/*.ts"],
    rules: {},
  })),
  ...compat.config({}).map((config) => ({
    ...config,
    files: ["**/*.mjs"],
    rules: {},
  })),
  ...compat.config({}).map((config) => ({
    ...config,
    files: ["**/*.mts"],
    rules: {},
  })),
];
