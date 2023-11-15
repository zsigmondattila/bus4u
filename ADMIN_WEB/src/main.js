import './assets/main.css'
import '@mdi/font/css/materialdesignicons.css'

import { createApp } from 'vue'
import { createPinia } from 'pinia'

import App from './App.vue'
import router from './router'
import 'vuetify/styles'
import { createVuetify } from 'vuetify'
import { aliases, mdi } from 'vuetify/iconsets/mdi'
import colors from 'vuetify/lib/util/colors'

const vuetify = createVuetify({
  defaults: {
    VTextField: {
      density: 'comfortable'
    }
  },
  icons: {
    defaultSet: 'mdi',
    aliases,
    sets: {
      mdi,
    },
  },
  theme: {
    defaultTheme: 'dark',
    themes: {
      light: {
        dark: false,
        colors: {
          primary: colors.deepOrange.darken3,
          secondary: colors.deepOrange.lighten3,
          accent: colors.deepOrange.accent2,
          adjacent: '#bc1251'
        }
      },
      dark: {
        dark: true,
        colors: {
          adjacent: colors.deepOrange.darken3,
          secondary: colors.deepOrange.lighten1,
          accent: colors.deepOrange.accent3,
          primary: '#bc1251',
          'primary-light': '#ce3870'
        }
      },
    },
  },
})
const app = createApp(App)

app.use(createPinia())
app.use(router)
app.use(vuetify)

app.mount('#app')
