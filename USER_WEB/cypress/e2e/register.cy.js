describe("Register", () => {
  it("With correct data", () => {
    cy.visit("/register");
    cy.get('input[name="firstname"]').type("Cypress");
    cy.get('input[name="lastname"]').type("Test");
    cy.get('input[name="email"]').type("cypress@test.tst");
    cy.get('input[name="password"]').type("password");
    cy.get('input[name="password-confirm"]').type("password");
    cy.get('button[type="submit"]').click();
    cy.contains("verification code");
  });
  it("With incorrect data", () => {
    cy.visit("/");
    cy.get('[title="Register"]').click();
    cy.url().should("include", "/register");
    cy.get('input[name="firstname"]').type("Cypress");
    cy.get('input[name="lastname"]').type("Test");
    cy.get('input[name="email"]').type("cypress@test.tst");
    cy.get('input[name="password"]').type("pwd");
    cy.get('input[name="password-confirm"]').type("password");
    cy.get('button[type="submit"]').click();
    cy.get('input[name="password"]')
      .parentsUntil(".inputs")
      .last()
      .should("have.class", "v-input--error");
  });
  it("With invalid data", () => {
    cy.visit("/");
    cy.get('[title="Register"]').click();
    cy.url().should("include", "/register");
    cy.get('input[name="firstname"]').type("Cypress");
    cy.get('input[name="lastname"]').type("Test");
    cy.get('input[name="email"]').type("portik.szabolcs.02@gmail.com");
    cy.get('input[name="password"]').type("password");
    cy.get('input[name="password-confirm"]').type("password");
    cy.get('button[type="submit"]').click();
    cy.get(".v-messages__message").not("be.empty");
  });
});
