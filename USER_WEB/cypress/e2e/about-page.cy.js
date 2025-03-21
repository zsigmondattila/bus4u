describe("Visit about", () => {
  it("from url", () => {
    cy.visit("/about").contains("Bus4U team");
  });
  it("from navbar", () => {
    cy.visit("/");
    cy.get(".v-app-bar-nav-icon").click();
    cy.get(".v-list-item--nav").contains("About").click();
    cy.contains("Bus4U team");
  });
});
