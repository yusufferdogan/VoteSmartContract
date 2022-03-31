module.exports = {
  root: true,

  env: {
    es2021: true,
  },

  extends: ['eslint:recommended', 'plugin:json/recommended', 'prettier'],

  plugins: ['json', 'prettier'],

  rules: {
    'prettier/prettier': 'warn',
    'no-undef': 'off',
  },
};
