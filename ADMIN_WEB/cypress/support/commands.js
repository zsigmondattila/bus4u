// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//
//
// -- This is a parent command --
// Cypress.Commands.add('login', (email, password) => { ... })
//
//
// -- This is a child command --
// Cypress.Commands.add('drag', { prevSubject: 'element'}, (subject, options) => { ... })
//
//
// -- This is a dual command --
// Cypress.Commands.add('dismiss', { prevSubject: 'optional'}, (subject, options) => { ... })
//
//
// -- This will overwrite an existing command --
// Cypress.Commands.overwrite('visit', (originalFn, url, options) => { ... })

Cypress.Commands.add("login", () => {
  cy.intercept("POST", "/admin/sign_in").as("login");
  cy.intercept("GET", "/admin/validate_token*").as("validation");
  cy.visit("/");
  cy.get('input[name="email"]').type("office@vandortrans.ro");
  cy.get('input[name="password"]').last().type("aaaaaaaa{enter}");
  cy.wait("@login");
  cy.wait("@validation");
});
