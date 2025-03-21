import TicketCard from "./TicketCard.vue";

const ticket = {
  ticket_uid: "TIC_ECB5K",
  date_of_purchase: "2024-10-11T17:25:26.981+03:00",
  expiration_date: "2024-11-11T16:25:26.981+02:00",
  from_station_uid: "STT_EV9LM",
  to_station_uid: "STT_PXVPC",
  from_station_name: "Izvor",
  to_station_name: "Grand",
  is_valid: true,
  route_uid: "ROU_SOXDN",
  route_name: "26",
  ticket_price: "200.0",
};

describe("<TicketCard />", () => {
  it("renders valid ticket", () => {
    cy.mount(TicketCard, {
      props: { ticket },
    });
    cy.get("img").should("exist");
    cy.get(".mdi-ticket-confirmation-outline").should("not.exist");
    cy.get(".v-card-text > :nth-child(6)").should(
      "not.contain",
      "already used"
    );
  });
  it("renders invalid ticket", () => {
    ticket.is_valid = false;
    cy.mount(TicketCard, {
      props: { ticket },
    });
    cy.get("img").should("not.exist");
    cy.get(".mdi-ticket-confirmation-outline").should("exist");
    cy.get(".v-card-text > :nth-child(6)").should("contain", "already used");
  });
});
