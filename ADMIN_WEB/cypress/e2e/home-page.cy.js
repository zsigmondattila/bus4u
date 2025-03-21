describe("Home page", () => {
  it("load statistics and notifications", () => {
    cy.intercept("GET", "/v1/admin/statistics*").as("statistics");
    cy.intercept("GET", "/v1/admin/document_validity_checker*").as(
      "notifications"
    );
    cy.login();
    cy.wait("@statistics");
    cy.get(".v-sheet h2").contains(/[1-9]/);
    cy.wait("@notifications");
    cy.get(".v-snackbar__content").contains("Document validity");
  });
});
