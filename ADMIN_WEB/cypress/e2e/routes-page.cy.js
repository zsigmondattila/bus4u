describe("Routes page", () => {
  it("create route", () => {
    cy.intercept("POST", "/v1/admin/create_route").as("create");
    cy.login();
    cy.visit("localhost:5173/routes");
    cy.get(".v-btn").contains("New Route").click();
    cy.get("input[name='name']").type("Test Route");
    cy.get("input[name='fare']").clear().type("5");
    cy.get("input[name='station']").type("Sapientia{enter}");
    cy.get(".v-btn").contains("Add station").click();
    cy.wait(500);
    cy.get("input[name='station']").type("Parajd{enter}");
    cy.get(".v-btn").contains("Add station").click();
    cy.wait(500);
    cy.get("input[name='station']").type("Gyergyó{enter}");
    cy.get(".v-btn").contains("Add station").click();
    cy.get(".v-list-subheader__text").should("contain", "(3)");
    cy.get("button[type='submit']").click();
    cy.wait("@create");
    cy.get(".v-snackbar__content").should("contain", "Route saved");
  });
  it("edit route", () => {
    cy.intercept("GET", "/v1/admin/get_routes*").as("routes");
    cy.intercept("DELETE", "/v1/admin/delete_route*").as("delete");
    cy.intercept("POST", "/v1/admin/create_route*").as("create");
    cy.login();
    cy.visit("localhost:5173/routes");
    cy.wait("@routes");
    cy.get("input[name='route']").type("Test Route{enter}");
    cy.get("input[name='fare']").clear().type("10");
    cy.get(".v-list-item")
      .contains("Gyergyó")
      .parent()
      .siblings()
      .find("button")
      .click();
    cy.get("input[name='station']").type("Csomafalva{enter}");
    cy.get(".v-btn").contains("Add station").click();
    cy.get(".v-list-subheader__text").should("contain", "(3)");
    cy.get("button[type='submit']").click();
    cy.wait("@delete");
    cy.wait("@create");
    cy.get(".v-snackbar__content").should("contain", "Route saved");
  });
  it("delete route", () => {
    cy.intercept("GET", "/v1/admin/get_routes*").as("routes");
    cy.intercept("DELETE", "/v1/admin/delete_route*").as("delete");
    cy.login();
    cy.visit("localhost:5173/routes");
    cy.wait("@routes");
    cy.get("input[name='route']").type("Test Route{enter}");
    cy.get("button").contains("Delete").click();
    cy.wait("@delete");
    cy.get(".v-snackbar__content").should("contain", "Route deleted");
  });
});
