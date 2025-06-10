describe("Tickets page", () => {
  const tickets = [
    {
      ticket_uid: "TIC_C7QQK",
      date_of_purchase: "2025-03-26T10:32:31.876+02:00",
      expiration_date: "2025-04-26T11:32:31.876+03:00",
      from_station_uid: "STT_IHC2Z",
      to_station_uid: "STT_G43LF",
      from_station_name: "Sapientia",
      to_station_name: "Cocosul de Aur",
      is_valid: true,
      route_uid: "ROU_PG1A4",
      route_name: "26",
      ticket_price: "200.0",
    },
  ];

  it("Accessing without login", () => {
    cy.visit("/tickets");
    cy.get(".v-container .v-card")
      .should("not.contain", "TIC_")
      .and("contain", "Login");
  });
  it("Accessing with login", () => {
    cy.intercept("/auth/sign_in").as("login");
    cy.intercept("/v1/tickets_of_user*", {
      statusCode: 200,
      body: tickets,
    }).as("tickets");
    cy.visit("/tickets");
    cy.get(".content").find("a[href='/login']").click();
    cy.url().should("include", "/login");
    cy.get("input").first().type("teszt@gmail.com");
    cy.get("input").last().type("aaaaaaaa{enter}");
    cy.wait("@login");
    cy.location("pathname").should("eq", "/");
    cy.get(".v-app-bar-nav-icon").click();
    cy.get("a[href='/tickets']").click();
    cy.wait("@tickets");
    cy.get(".v-container > .v-row > div").should("have.length.above", 0);
    cy.get(".v-container > .v-row > div")
      .find(".v-card-title")
      .should("contain.text", "TIC_");
  });
  it("Empty ticket list", () => {
    cy.intercept("/auth/sign_in").as("login");
    cy.intercept("/v1/tickets_of_user*", {
      statusCode: 200,
      body: [],
    }).as("tickets");
    cy.visit("/tickets");
    cy.get(".content").find("a[href='/login']").click();
    cy.url().should("include", "/login");
    cy.get("input").first().type("teszt@gmail.com");
    cy.get("input").last().type("aaaaaaaa{enter}");
    cy.wait("@login");
    cy.location("pathname").should("eq", "/");
    cy.get(".v-app-bar-nav-icon").click();
    cy.get("a[href='/tickets']").click();
    cy.wait("@tickets");
    cy.get(".v-container .v-card").should("not.exist");
    cy.get(".v-container > .v-row > div").should("contain", "no tickets");
  });
});
