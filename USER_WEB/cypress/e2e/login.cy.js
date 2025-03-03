describe("Login", () => {
  it("from home with ENTER", () => {
    cy.visit("localhost:5173/");
    cy.get('[title="Login"]').click();
    cy.url().should("include", "/login");
    cy.get("input").first().type("portik.szabolcs.02@gmail.com");
    cy.get("input").last().type("password{enter}");
    cy.url().should("include", "/");
    cy.get(".v-toolbar__content").should("contain", "Szabolcs");
  });
  it("from login with CLICK", () => {
    cy.visit("localhost:5173/login");
    cy.url().should("include", "/login");
    cy.get('input[name="email"]').type("portik.szabolcs.02@gmail.com");
    cy.get('input[name="password"]').last().type("password");
    cy.get('button[type="submit"]').click();
    cy.url().should("include", "/");
    cy.get(".v-toolbar__content").should("contain", "Szabolcs");
  });
  it("with invalid data", () => {
    cy.visit("localhost:5173/login");
    cy.url().should("include", "/login");
    cy.get('input[name="email"]').type("portik.szabolcs@gmail.com");
    cy.get('input[name="password"]').last().type("password");
    cy.get('button[type="submit"]').click();
    cy.get(".text-error").not("be.empty");
  });
  it("with incorrect data", () => {
    cy.visit("localhost:5173/login");
    cy.url().should("include", "/login");
    cy.get('input[name="email"]').type("portik.szabolcs.02gmail.com");
    cy.get('input[name="password"]').last().type("passwd");
    cy.get('button[type="submit"]').click();
    cy.get(".v-messages__message").not("be.empty");
  });
});
