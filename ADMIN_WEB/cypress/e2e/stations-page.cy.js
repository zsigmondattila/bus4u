describe("template spec", () => {
  it("highlight station", () => {
    cy.login();
    cy.visit("localhost:5173/stations");
    cy.get(".v-list > :nth-child(9)").click();
    cy.get(".mapboxgl-marker").find("path[fill='#bc1251']");
  });
  it("add new station and remove it", () => {
    cy.intercept("GET", "https://api.mapbox.com/map-sessions/v1*").as("map");
    cy.login();
    cy.visit("localhost:5173/stations");
    cy.get(".d-flex > .v-btn").click();
    cy.wait("@map");
    cy.get(".mapboxgl-canvas").click(320, 500);
    cy.get("input[name='name']").type("test station");
    cy.get("button[type='submit']").click();
    cy.get(".v-snackbar__content").contains("Station created");
    cy.get(".v-list > .v-list-item")
      .contains("test station")
      .parent()
      .siblings()
      .find("button")
      .click();
    cy.get(".v-snackbar__content").contains("Station deleted");
    cy.get(".v-list > .v-list-item").should("not.contain", "test station");
  });
});
