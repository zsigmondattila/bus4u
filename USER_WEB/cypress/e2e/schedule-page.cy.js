describe("Schedule page", () => {
  it("Click on the search without data", () => {
    cy.intercept("GET", "/v1/get_cities").as("getCities");
    cy.visit("http://localhost:5173/schedule");
    cy.get("button[type='submit']").click();
    cy.get("tr").should("not.exist");
    cy.get(".v-skeleton-loader").should("exist");
    cy.get(".v-form").find(".v-field--error");
  });
  it("Search for a schedule", () => {
    cy.intercept("GET", "/v1/get_cities").as("getCities");
    cy.intercept("GET", "/v1/get_stations_by_city*").as("getStations");
    cy.intercept("GET", "/v1/get_routes_by_station*").as("getRoutes");
    cy.intercept("GET", "/v1/get_departure_times_for_station*").as("getTimes");
    cy.intercept("GET", "/v1/get_stations_of_a_route*").as("getRouteStations");
    cy.visit("http://localhost:5173/schedule");
    cy.wait("@getCities");
    cy.get("input[name='city']").type("Marosvásárhely{enter}");
    cy.wait("@getStations");
    cy.get("input[name='station']").type("Sapientia{enter}");
    cy.wait("@getRoutes");
    cy.get("input[name='route']").type("26{enter}");
    cy.get("button[type='submit']").click();
    cy.get(".v-form").find(".v-field--error").should("not.exist");
    cy.wait("@getTimes");
    cy.get("tr").should("contain", "Monday");
    cy.wait("@getRouteStations")
      .its("response.body.stations.length")
      .should("gt", 0);
  });
});
