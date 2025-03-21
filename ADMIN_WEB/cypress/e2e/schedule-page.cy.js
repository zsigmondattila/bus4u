describe("Schedule page", () => {
  it("create test route", () => {
    cy.intercept("POST", "/v1/admin/create_route").as("create");
    cy.login();
    cy.visit("/routes");
    cy.get(".v-btn").contains("New Route").click();
    cy.get("input[name='name']").type("Test2 Route");
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

  it("fill the form with data and clear", () => {
    cy.intercept("GET", "/v1/admin/get_routes_of_a_company*").as("routes");
    cy.intercept("GET", "/v1/get_stations_of_a_route*").as("stations");
    cy.intercept("GET", "/v1/get_departure_times*").as("times");
    cy.login();
    cy.visit("http:///schedule");
    cy.wait("@routes");
    cy.get("input[name='route']").type("Test2 Route{enter}");
    cy.wait("@stations");
    cy.get("input[name='start']").type("Sapientia{enter}");
    cy.get("input[name='destination']").invoke("val").should("not.be.empty");
    cy.wait("@times");
    cy.get("input[name='days']").type("Saturday{enter}{esc}");
    cy.get("input[name='fare']").clear().type("4{enter}");
    cy.get("input[name='time']").type("12:00");
    cy.get("button").contains("Add time").click();
    cy.get("button").contains("Clear").click();
    cy.get("input[name='days']").invoke("val").should("be.empty");
    cy.get("input[name='fare']").invoke("val").should("be.empty");
  });

  it("create timetable and cancel editing", () => {
    cy.intercept("GET", "/v1/admin/get_routes_of_a_company*").as("routes");
    cy.intercept("GET", "/v1/get_stations_of_a_route*").as("stations");
    cy.intercept("GET", "/v1/get_departure_times*").as("times");
    cy.login();
    cy.visit("http:///schedule");
    cy.wait("@routes");
    cy.get("input[name='route']").type("Test2 Route{enter}");
    cy.wait("@stations");
    cy.get("input[name='start']").type("Sapientia{enter}");
    cy.get("input[name='destination']").invoke("val").should("not.be.empty");
    cy.wait("@times");
    cy.get("input[name='days']").type("Saturday{enter}{esc}");
    cy.get("input[name='fare']").clear().type("4{enter}");
    cy.get("input[name='time']").type("12:00");
    cy.get("button").contains("Add time").click();
    cy.get("button[type='submit']").click();
    cy.get("button").contains("Cancel editing").click();
    cy.get("input[name='route']").invoke("val").should("be.empty");
    cy.get("input[name='start']").invoke("val").should("be.empty");
  });

  it("trying to create timetable without data", () => {
    cy.intercept("GET", "/v1/admin/get_routes_of_a_company*").as("routes");
    cy.intercept("GET", "/v1/get_stations_of_a_route*").as("stations");
    cy.intercept("GET", "/v1/get_departure_times*").as("times");
    cy.intercept("POST", "/v1/admin/add_timetable_to_route").as("create");
    cy.login();
    cy.visit("http:///schedule");
    cy.wait("@routes");
    cy.get("input[name='route']").type("Test2 Route{enter}");
    cy.wait("@stations");
    cy.get("input[name='start']").type("Sapientia{enter}");
    cy.get("input[name='destination']").invoke("val").should("not.be.empty");
    cy.wait("@times");
    cy.get("button[type='submit']").click();
    cy.get(".v-form").find(".v-input--error").should("have.length.gt", 1);
  });

  it("create timetable", () => {
    cy.intercept("GET", "/v1/admin/get_routes_of_a_company*").as("routes");
    cy.intercept("GET", "/v1/get_stations_of_a_route*").as("stations");
    cy.intercept("GET", "/v1/get_departure_times*").as("times");
    cy.intercept("POST", "/v1/admin/add_timetable_to_route").as("create");
    cy.login();
    cy.visit("http:///schedule");
    cy.wait("@routes");
    cy.get("input[name='route']").type("Test2 Route{enter}");
    cy.wait("@stations");
    cy.get("input[name='start']").type("Sapientia{enter}");
    cy.get("input[name='destination']").invoke("val").should("not.be.empty");
    cy.wait("@times");
    cy.get("input[name='days']").type("Saturday{enter}Sunday{enter}{esc}");
    cy.get("input[name='fare']").clear().type("4{enter}");
    cy.get("input[name='time']").type("12:00");
    cy.get("button").contains("Add time").click();
    cy.get("input[name='time']").type("12:40");
    cy.get("button").contains("Add time").click();
    cy.get("input[name='time']").type("13:20");
    cy.get("button").contains("Add time").click();
    cy.get("input[name='time']").type("14:00");
    cy.get("button").contains("Add time").click();
    cy.get("button[type='submit']").click();
    cy.get("button").contains("Save schedule").click();
    cy.wait("@create");
    cy.get(".v-snackbar__content").should("contain", "Schedule saved");
  });

  it("delete timetable", () => {
    cy.intercept("GET", "/v1/admin/get_routes_of_a_company*").as("routes");
    cy.intercept("GET", "/v1/get_stations_of_a_route*").as("stations");
    cy.intercept("GET", "/v1/get_departure_times*").as("times");
    cy.intercept("DELETE", "/v1/admin/delete_timetables_from_route*").as(
      "delete"
    );
    cy.login();
    cy.visit("http:///schedule");
    cy.wait("@routes");
    cy.get("input[name='route']").type("Test2 Route{enter}");
    cy.wait("@stations");
    cy.get("input[name='start']").type("Sapientia{enter}");
    cy.get("input[name='destination']").invoke("val").should("not.be.empty");
    cy.wait("@times");
    cy.get("button").contains("Delete").first().click();
    cy.get("button").contains("Save schedule").click();
    cy.wait("@delete");
    cy.get(".v-snackbar__content").should("contain", "Schedule saved");
  });

  it("delete test route", () => {
    cy.intercept("GET", "/v1/admin/get_routes*").as("routes");
    cy.intercept("DELETE", "/v1/admin/delete_route*").as("delete");
    cy.login();
    cy.visit("/routes");
    cy.wait("@routes");
    cy.get("input[name='route']").type("Test2 Route{enter}");
    cy.get("button").contains("Delete").click();
    cy.wait("@delete");
    cy.get(".v-snackbar__content").should("contain", "Route deleted");
  });
});
