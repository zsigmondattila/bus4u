describe("Login", () => {
  it("from home with ENTER", () => {
    cy.visit("/");
    cy.get('[title="Login"]').click();
    cy.url().should("include", "/login");
    cy.get("input").first().type("teszt@gmail.com");
    cy.get("input").last().type("aaaaaaaa{enter}");
    cy.location("pathname").should("eq", "/");
  });
  it("from login with CLICK", () => {
    cy.visit("/login");
    cy.url().should("include", "/login");
    cy.get('input[name="email"]').type("teszt@gmail.com");
    cy.get('input[name="password"]').last().type("aaaaaaaa");
    cy.get('button[type="submit"]').click();
    cy.location("pathname").should("eq", "/");
  });
  it("with invalid data", () => {
    cy.visit("/login");
    cy.url().should("include", "/login");
    cy.get('input[name="email"]').type("teszt3@gmail.com");
    cy.get('input[name="password"]').last().type("aaaaaaaa");
    cy.get('button[type="submit"]').click();
    cy.get(".text-error").not("be.empty");
  });
  it("with incorrect data", () => {
    cy.visit("/login");
    cy.url().should("include", "/login");
    cy.get('input[name="email"]').type("tesztgmail.com");
    cy.get('input[name="password"]').last().type("passwd");
    cy.get('button[type="submit"]').click();
    cy.get(".v-messages__message").not("be.empty");
  });
});
