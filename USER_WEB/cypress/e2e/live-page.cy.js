describe("Live map page", () => {
  it("Click on the show without data", () => {
    cy.visit("http://localhost:5173/live");
    cy.get("button[type='submit']").click();
    cy.get(".v-form").find(".v-field--error");
  });
  it("Search for a live bus", () => {
    cy.intercept("GET", "/v1/get_cities").as("getCities");
    cy.intercept("GET", "/v1/get_routes_by_city*").as("getRoutes");
    cy.intercept("GET", "/v1/get_bus_locations_by_route*", {
      statusCode: 200,
      body: [
        {
          license_plate: "MS-01-ABC",
          brand: "Mercedes Benz Citaro",
          capacity: 52,
          longitude: "24.582",
          latitude: "46.536",
        },
      ],
    }).as("getBuses");
    cy.intercept("GET", "/v1/get_stations_of_a_route*").as("getRouteStations");
    cy.visit("http://localhost:5173/live");
    cy.wait("@getCities");
    cy.get("input[name='city']").type("Marosvásárhely{enter}");
    cy.wait("@getRoutes");
    cy.get("input[name='route']").type("26{enter}");
    cy.get("button[type='submit']").click();
    cy.get(".v-form").find(".v-field--error").should("not.exist");
    cy.wait("@getBuses").its("response.body.length").should("gt", 0);
    cy.wait("@getRouteStations")
      .its("response.body.stations.length")
      .should("gt", 0);
  });
});
