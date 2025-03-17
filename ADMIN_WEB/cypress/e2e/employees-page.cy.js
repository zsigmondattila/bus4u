describe("Employees page", () => {
  it("show list", () => {
    cy.login();
    cy.visit("localhost:5173/employees");
    cy.get(".v-card").should("have.length.greaterThan", 1);
  });

  it("trying to create with invalid data", () => {
    cy.intercept("GET", "/v1/admin/list_of_drivers*").as("employees");
    cy.intercept("POST", "/admin").as("create");
    cy.login();
    cy.visit("localhost:5173/employees");
    cy.wait("@employees");
    cy.get(".v-card").last().contains("Add new").click();
    cy.get("input[name='firstname']").type("invalid");
    cy.get("input[name='lastname']").type("name");
    cy.get("input[name='email']").type("invalid.email");
    cy.get("input[name='phone']").type("invalid phone");
    cy.get("input[name='password']").type("aaa");
    cy.get("input[name='password-confirmation']").type("bbb");
    cy.get("button[type='submit']").click();
    cy.get(".v-form").find(".v-input--error").should("have.length.gt", 1);
  });

  it("create employee", () => {
    cy.intercept("GET", "/v1/admin/list_of_drivers*").as("employees");
    cy.intercept("POST", "/admin").as("create");
    cy.login();
    cy.visit("localhost:5173/employees");
    cy.wait("@employees");
    cy.get(".v-card").last().contains("Add new").click();
    cy.get("input[name='firstname']").type("Test");
    cy.get("input[name='lastname']").type("Employee");
    cy.get("input[name='email']").type("test@employee.com");
    cy.get("input[name='role']").parent().click().type("driver");
    cy.get("input[name='phone']").type("0722222222");
    cy.get("input[name='address']").type("Test address");
    cy.get("input[name='password']").type("aaaaaaaa");
    cy.get("input[name='password-confirmation']").type("aaaaaaaa");
    cy.get("button[type='submit']").click();
    cy.wait("@create");
    cy.get(".v-card").contains("Test Employee");
  });

  it("edit employee", () => {
    cy.intercept("GET", "/v1/admin/list_of_drivers*").as("employees");
    cy.intercept("PUT", "/v1/admin/update_driver*").as("update");
    cy.login();
    cy.visit("localhost:5173/employees");
    cy.wait("@employees");
    cy.get(".v-card")
      .contains("Test Employee")
      .siblings()
      .find("button")
      .contains("Edit")
      .click();
    cy.get("input[name='phone']").clear().type("0733333333");
    cy.get("input[name='password']").type("aaaaaaaa");
    cy.get("input[name='password-confirmation']").type("aaaaaaaa");
    cy.get("button[type='submit']").click();
    cy.wait("@update");
    cy.get(".v-card")
      .contains("Test Employee")
      .siblings()
      .contains("0733333333");
  });

  it("delete employee", () => {
    cy.intercept("GET", "/v1/admin/list_of_drivers*").as("employees");
    cy.intercept("DELETE", "/v1/admin/delete_driver*").as("delete");
    cy.login();
    cy.visit("localhost:5173/employees");
    cy.wait("@employees");
    cy.get(".v-card")
      .contains("Test Employee")
      .siblings()
      .find("button")
      .contains("Delete")
      .click();
    cy.wait("@delete");
    cy.get(".v-snackbar__content").contains("Employee deleted");
  });
});
