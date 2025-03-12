// ***********************************************************
// This example support/component.js is processed and
// loaded automatically before your test files.
//
// This is a great place to put global configuration and
// behavior that modifies Cypress.
//
// You can change the location of this file or turn off
// automatically serving support files with the
// 'supportFile' configuration option.
//
// You can read more here:
// https://on.cypress.io/configuration
// ***********************************************************

// Import commands.js using ES2015 syntax:
import "./commands";
import "@mdi/font/css/materialdesignicons.css";

import { mount } from "cypress/vue";
import { createPinia } from "pinia";
import "vuetify/styles";
import { createVuetify } from "vuetify";
import { aliases, mdi } from "vuetify/iconsets/mdi";
import colors from "vuetify/lib/util/colors";

const appColor = colors.orange;

const vuetify = createVuetify({
  defaults: {
    VTextField: {
      density: "comfortable",
      color: appColor.darken3,
    },
    VSelect: {
      density: "comfortable",
    },
    VAutocomplete: {
      density: "comfortable",
    },
    VSnackbar: {
      color: appColor.darken3,
      location: "bottom",
      variant: "elevated",
      timeout: 6000,
    },
    VCheckbox: {
      density: "compact",
    },
  },
  icons: {
    defaultSet: "mdi",
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
          accent: appColor.accent2,
        },
      },
      dark: {
        dark: true,
        colors: {
          primary: appColor.darken4,
          secondary: appColor.lighten1,
          accent: appColor.accent3,
        },
      },
    },
  },
});

Cypress.Commands.add("mount", (component, options = {}) => {
  // Setup options object
  options.global = options.global || {};
  options.global.stubs = options.global.stubs || {};
  options.global.stubs["transition"] = false;
  options.global.components = options.global.components || {};
  options.global.plugins = options.global.plugins || [];

  /* Add any global plugins */
  options.global.plugins.push({
    install(app) {
      app.use(vuetify);
      app.use(createPinia());
    },
  });

  /* Add any global components */
  // options.global.components['Button'] = Button;

  return mount(component, options);
});

before(() => {
  cy.intercept("https://api.mapbox.com/**", { log: false });
  cy.intercept("https://events.mapbox.com/**", { log: false });
});

// Example use:
// cy.mount(MyComponent)
