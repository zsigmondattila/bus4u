describe("Tickets page", () => {
  it("Accessing without login", () => {
    cy.visit("/tickets");
    cy.get(".v-container .v-card")
      .should("not.contain", "TIC_")
      .and("contain", "Login");
  });
  it("Accessing with login", () => {
    cy.intercept("/auth/sign_in").as("login");
    cy.intercept("/v1/tickets_of_user*").as("tickets");
    cy.visit("/tickets");
    cy.get(".content").find("a[href='/login']").click();
    cy.url().should("include", "/login");
    cy.get("input").first().type("portik.szabolcs.02@gmail.com");
    cy.get("input").last().type("password{enter}");
    cy.wait("@login");
    cy.url().should("include", "/");
    cy.get(".v-toolbar__content").should("contain", "Szabolcs");
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
    cy.get("input").first().type("portik.szabolcs.02@gmail.com");
    cy.get("input").last().type("password{enter}");
    cy.wait("@login");
    cy.url().should("include", "/");
    cy.get(".v-toolbar__content").should("contain", "Szabolcs");
    cy.get(".v-app-bar-nav-icon").click();
    cy.get("a[href='/tickets']").click();
    cy.wait("@tickets");
    cy.get(".v-container .v-card").should("not.exist");
    cy.get(".v-container > .v-row > div").should("contain", "no tickets");
  });
});
