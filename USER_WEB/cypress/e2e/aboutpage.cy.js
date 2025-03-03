describe("Visit about", () => {
  it("from url", () => {
    cy.visit("localhost:5173/about").contains("Bus4U team");
  });
  it("from navbar", () => {
    cy.visit("localhost:5173/");
    cy.get(".v-app-bar-nav-icon").click();
    cy.get(".v-list-item--nav").contains("About").click();
    cy.contains("Bus4U team");
  });
});
