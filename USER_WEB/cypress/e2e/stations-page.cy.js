describe("Stations page", () => {
  it("Click on the filter without data", () => {
    cy.intercept("GET", "/v1/get_stations").as("getStations");
    cy.visit("http://localhost:5173/stations");
    cy.get("button[type='submit']").click();
    cy.wait("@getStations")
      .its("response.body.stations.length")
      .should("gt", 30);
  });
  it("Filter by city and remove filter", () => {
    cy.intercept("GET", "/v1/get_cities").as("getCities");
    cy.intercept("GET", "/v1/get_stations_by_city*").as("getStations");
    cy.intercept("GET", "/v1/get_stations").as("getAllStations");
    cy.visit("http://localhost:5173/stations");
    cy.wait("@getCities");
    cy.get("input[name='city']").type("Marosvásárhely{enter}");
    cy.get("button[type='submit']").click();
    cy.wait("@getStations")
      .its("response.body.stations.length")
      .should("gt", 0)
      .and("lt", 30);
    cy.get(".v-field__clearable").click();
    cy.get("button[type='submit']").click();
    cy.wait("@getAllStations")
      .its("response.body.stations.length")
      .should("gt", 30);
  });
  it("Filter by route and remove filter", () => {
    cy.intercept("GET", "/v1/get_routes").as("getRoutes");
    cy.intercept("GET", "/v1/get_stations_of_a_route*").as("getStations");
    cy.intercept("GET", "/v1/get_stations").as("getAllStations");
    cy.visit("http://localhost:5173/stations");
    cy.wait("@getRoutes");
    cy.get("input[name='route']").type("26{enter}");
    cy.get("button[type='submit']").click();
    cy.wait("@getStations")
      .its("response.body.stations.length")
      .should("gt", 0)
      .and("lt", 30);
    cy.get(".v-field__clearable").click();
    cy.get("button[type='submit']").click();
    cy.wait("@getAllStations")
      .its("response.body.stations.length")
      .should("gt", 30);
  });
});
