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

const appColor = colors.orange;

const vuetify = createVuetify({
  defaults: {
    VTextField: {
      density: 'comfortable',
      color: appColor.darken3
    },
    VSelect: {
      density: 'comfortable'
    },
    VAutocomplete: {
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
    themes: {
      light: {
        dark: false,
        colors: {
          primary: appColor.darken3,
          secondary: appColor.lighten3,
          accent: appColor.accent2
        }
      },
      dark: {
        dark: true,
        colors: {
          primary: appColor.darken4,
          secondary: appColor.lighten1,
          accent: appColor.accent3
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
