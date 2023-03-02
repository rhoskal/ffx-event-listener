module.exports = {
  env: {
    es6: true,
    node: true,
  },
  extends: [],
  parser: "@typescript-eslint/parser",
  parserOptions: {
    sourceType: "module",
  },
  plugins: ["prettier", "@typescript-eslint", "import"],
  rules: {
    "@typescript-eslint/no-unused-vars": [
      "warn",
      {
        args: "after-used",
        argsIgnorePattern: "^_",
      },
    ],
    "import/newline-after-import": "error",
    "import/no-cycle": "error",
    "import/no-relative-parent-imports": "error",
    "prettier/prettier": "error",
  },
};
