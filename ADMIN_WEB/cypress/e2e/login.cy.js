describe("Login", () => {
  it("with correct data", () => {
    cy.visit("localhost:5173/");
    cy.get('input[name="email"]').type("office@vandortrans.ro");
    cy.get('input[name="password"]').last().type("aaaaaaaa{enter}");
    cy.url().should("include", "/home");
    cy.get(".v-toolbar__content").should("contain", "Kecskeméti");
  });
  it("with invalid data", () => {
    cy.visit("localhost:5173/");
    cy.get('input[name="email"]').type("office@vandortrans.ro");
    cy.get('input[name="password"]').last().type("bbbbbbbb");
    cy.get('button[type="submit"]').click();
    cy.get(".text-error").not("be.empty");
  });
  it("with incorrect data", () => {
    cy.visit("localhost:5173/");
    cy.get('input[name="email"]').type("office.vandortrans.ro");
    cy.get('input[name="password"]').last().type("aaaaaaaa");
    cy.get('button[type="submit"]').click();
    cy.get(".v-messages__message").not("be.empty");
  });
  it("authguard", () => {
    cy.visit("localhost:5173/stations");
    cy.location("pathname").should("eq", "/");
  });
});
