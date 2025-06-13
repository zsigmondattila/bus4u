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
  it("purchasing 3 tickets", () => {
    const onClicked = cy.spy().as("onClickSpy");
    cy.mount(RouteListElement, {
      props: {
        trip,
        onClicked: onClicked,
      },
    });
    cy.get("input[type='number']").type("{backspace}3");
    cy.get(".v-btn").click();
    cy.get("@onClickSpy").should("have.been.calledWith", trip, "3");
  });
});
