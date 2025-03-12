import RouteListElement from "./RouteListElement.vue";

const trip = {
  from_station: "Sapientia",
  from_station_uid: "STT_EGAVX",
  to_station: "Dedeman",
  to_station_uid: "STT_6CO3Q",
  company_name: "TRANSPORT LOCAL SA",
  company_uid: "CPY_NIZ21",
  route_name: "26",
  route_uid: "ROU_SOXDN",
  ticket_price: "2.0",
  departure_time: 1741807200,
};

describe("<RouteListElement />", () => {
  it("purchasing failed", () => {
    const onError = cy.spy().as("onErrorSpy");
    const onPurchased = cy.spy().as("onPurchasedSpy");
    cy.intercept("POST", "https://api.bus4u.online/v1/generate_a_ticket", {
      statusCode: 401,
      body: "error",
    }).as("generateTicket");

    cy.mount(RouteListElement, {
      props: {
        trip,
        onPurchased: onPurchased,
        onError: onError,
      },
    });
    cy.get(".v-btn").click();
    cy.wait("@generateTicket");
    cy.get("@onPurchasedSpy").should("not.called");
    cy.get("@onErrorSpy").should("be.called");
  });
  it("purchasing 3 tickets", () => {
    const onError = cy.spy().as("onErrorSpy");
    const onPurchased = cy.spy().as("onPurchasedSpy");
    cy.intercept("POST", "https://api.bus4u.online/v1/generate_a_ticket", {
      statusCode: 200,
      body: "test",
    }).as("generateTicket");

    cy.mount(RouteListElement, {
      props: {
        trip,
        onPurchased: onPurchased,
        onError: onError,
      },
    });
    cy.get("input[type='number']").type("{backspace}3");
    cy.get(".v-btn").click();
    cy.wait("@generateTicket");
    cy.get("@onPurchasedSpy").should("be.called");
    cy.get("@onErrorSpy").should("not.called");
  });
});
