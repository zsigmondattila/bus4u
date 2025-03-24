describe("Home Page", () => {
  it("Buying 2 tickets without login", () => {
    cy.intercept("GET", "/v1/get_cities").as("getCities");
    cy.intercept("GET", "/v1/get_stations_by_city*").as("getStations");

    cy.visit("/");
    cy.wait("@getCities");
    cy.get("input[name='startCity']").type("Marosvásárhely{enter}");
    cy.wait("@getStations");
    cy.get("input[name='startStation']").type("Sapientia{enter}");
    cy.get("input[name='destCity']").type("Marosvásárhely{enter}");
    cy.wait("@getStations");
    cy.get("input[name='destStation']").type("Aleea Carpati 2{enter}");
    cy.get("input[name='time']").type("10:00");
    cy.get("button[type='submit'").click();
    cy.get(
      ".v-list-item > .v-list-item__content > .v-list-item-subtitle"
    ).contains("Sapientia");
    cy.get("div.flex-wrap:nth-child(1)")
      .find("input")
      .type("a")
      .not("be.eq", "a")
      .type("{backspace}2");
    cy.intercept("POST", "/v1/generate_a_ticket").as("generateTicket");
    cy.get("div.flex-wrap:nth-child(1)").find("button").click();
    cy.wait("@generateTicket").as("request");
    cy.get("@request").its("request.body.quantity").should("eq", "2");
    cy.get("@request").its("response.statusCode").should("eq", 401);
    cy.location("pathname").should("eq", "/login");
  });

  it("Buying ticket with login (server error)", () => {
    cy.intercept("GET", "/v1/get_cities").as("getCities");
    cy.intercept("GET", "/v1/get_stations_by_city*").as("getStations");

    cy.visit("/");
    cy.get('[title="Login"]').click();
    cy.url().should("include", "/login");
    cy.get("input").first().type("portik.szabolcs.02@gmail.com");
    cy.get("input").last().type("password{enter}");
    cy.location("pathname").should("eq", "/");
    cy.get(".v-toolbar__content").should("contain", "Szabolcs");
    cy.wait("@getCities");
    cy.get("input[name='startCity']").type("Marosvásárhely{enter}");
    cy.wait("@getStations");
    cy.get("input[name='startStation']").type("Sapientia{enter}");
    cy.get("input[name='destCity']").type("Marosvásárhely{enter}");
    cy.wait("@getStations");
    cy.get("input[name='destStation']").type("Aleea Carpati 2{enter}");
    cy.get("input[name='time']").type("10:00");
    cy.get("button[type='submit'").click();
    cy.intercept("POST", "/v1/generate_a_ticket", {
      statusCode: 404,
      body: ["TEST01"],
    }).as("generateTicket");
    cy.get("div.flex-wrap:nth-child(1)").find("button").click();
    cy.get(".v-card-title").should("contain", "failed");
  });

  it("Buying ticket with login (successful)", () => {
    cy.intercept("GET", "/v1/get_cities").as("getCities");
    cy.intercept("GET", "/v1/get_stations_by_city*").as("getStations");

    cy.visit("/");
    cy.get('[title="Login"]').click();
    cy.url().should("include", "/login");
    cy.get("input").first().type("portik.szabolcs.02@gmail.com");
    cy.get("input").last().type("password{enter}");
    cy.location("pathname").should("eq", "/");
    cy.get(".v-toolbar__content").should("contain", "Szabolcs");
    cy.wait("@getCities");
    cy.get("input[name='startCity']").type("Marosvásárhely{enter}");
    cy.wait("@getStations");
    cy.get("input[name='startStation']").type("Sapientia{enter}");
    cy.get("input[name='destCity']").type("Marosvásárhely{enter}");
    cy.wait("@getStations");
    cy.get("input[name='destStation']").type("Aleea Carpati 2{enter}");
    cy.get("input[name='time']").type("10:00");
    cy.get("button[type='submit']").click();
    cy.intercept("POST", "/v1/generate_a_ticket", {
      statusCode: 200,
      body: ["TEST01"],
    }).as("generateTicket");
    cy.get("div.flex-wrap:nth-child(1)").find("button").click();
    cy.get(".v-card-title").should("contain", "successful");
  });
});
