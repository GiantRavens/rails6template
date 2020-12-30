// tailwind.config.js
const colors = require('tailwindcss/colors')

module.exports = {
  theme: {
    colors: {
      blue: colors.blue,
      currentcolor: 'currentColor',
      cyan: colors.cyan,
      green: colors.green,
      red: colors.red,
      cyan: colors.cyan,
      transparent: 'transparent',
      truegray: colors.trueGray,
      warmgray: colors.warmGray,
      gray: colors.gray
    },
  },
  corePlugins: {},
  plugins: [require('@tailwindcss/forms')],
}