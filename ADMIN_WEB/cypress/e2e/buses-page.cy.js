describe("Buses page", () => {
  it("show list", () => {
    cy.login();
    cy.visit("localhost:5173/buses");
    cy.get(".v-card").should("have.length.greaterThan", 1);
  });

  it("trying to create with invalid data", () => {
    cy.intercept("GET", "/v1/admin/get_buses_of_a_company*").as("buses");
    cy.intercept("POST", "/v1/admin/create_bus").as("create");
    cy.login();
    cy.visit("localhost:5173/buses");
    cy.wait("@buses");
    cy.get(".v-card").last().contains("Add new").click();
    cy.get("input[name='brand']").type("invalid.brand");
    cy.get("input[name='license-plate']").type("short");
    cy.get("input[name='capacity']").type("-50");
    cy.get("button[type='submit']").click();
    cy.get(".v-form").find(".v-input--error").should("have.length.gt", 1);
  });

  it("create bus", () => {
    cy.intercept("GET", "/v1/admin/get_buses_of_a_company*").as("buses");
    cy.intercept("POST", "/v1/admin/create_bus").as("create");
    cy.login();
    cy.visit("localhost:5173/buses");
    cy.wait("@buses");
    cy.get(".v-card").last().contains("Add new").click();
    cy.get("input[name='brand']").type("Test Bus");
    cy.get("input[name='license-plate']").type("test plate");
    cy.get("input[name='capacity']").type("50");
    cy.get("input[name='manufactured']").type("2021-10");
    cy.get("input[name='road-tax']").type("2025-10-10");
    cy.get("input[name='insurance']").type("2025-10-10");
    cy.get("input[name='technical-exam']").type("2025-10-10");
    cy.get("button[type='submit']").click();
    cy.wait("@create");
    cy.get(".v-card").contains("Test Bus");
  });

  it("edit bus", () => {
    cy.intercept("GET", "/v1/admin/get_buses_of_a_company*").as("buses");
    cy.intercept("PUT", "/v1/admin/update_bus*").as("update");
    cy.login();
    cy.visit("localhost:5173/buses");
    cy.wait("@buses");
    cy.get(".v-card")
      .contains("Test Bus")
      .siblings()
      .find("button")
      .contains("Edit")
      .click();
    cy.get("input[name='capacity']").clear().type("62");
    cy.get("button[type='submit']").click();
    cy.wait("@update");
    cy.get(".v-card").contains("Test Bus").siblings().contains("62");
  });

  it("delete bus", () => {
    cy.intercept("GET", "/v1/admin/get_buses_of_a_company*").as("buses");
    cy.intercept("DELETE", "/v1/admin/delete_bus*").as("delete");
    cy.login();
    cy.visit("localhost:5173/buses");
    cy.wait("@buses");
    cy.get(".v-card")
      .contains("Test Bus")
      .siblings()
      .find("button")
      .contains("Delete")
      .click();
    cy.wait("@delete");
    cy.get(".v-snackbar__content").contains("Bus deleted");
  });
});
