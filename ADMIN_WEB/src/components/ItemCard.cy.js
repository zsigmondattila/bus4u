import BusCard from "./BusCard.vue";
import EmployeeCard from "./EmployeeCard.vue";

describe("<BusCard />", () => {
  const bus = {
    bus_uid: "BUS_A3PT7",
    company_uid: "CPY_7DOFZ",
    license_plate: "HR49VTT",
    brand: "Mercedes Integro",
    manufacturing_year: 2003,
    capacity: 73,
    road_tax: "2023-12-10T00:00:00.000+02:00",
    insurance: "2023-12-22T00:00:00.000+02:00",
    technical_exam: "2023-10-10T00:00:00.000+03:00",
    tracked: null,
    latitude: null,
    longitude: null,
    current_route_uid: null,
    created_at: "2024-10-03T15:57:58.043+03:00",
    updated_at: "2024-10-03T15:57:58.043+03:00",
  };

  it("renders", () => {
    cy.mount(BusCard, {
      props: {
        bus,
      },
    });
    cy.get(".v-card-title").contains("Mercedes Integro");
    cy.get(".v-card-subtitle > :nth-child(1)").contains("HR49VTT");
    cy.get(".v-card-subtitle > :nth-child(2)").contains("73");
    cy.get(".v-card-subtitle > :nth-child(3)").contains("2003");
    cy.get(".v-card-subtitle > :nth-child(4)")
      .should("contain", "2023")
      .and("contain", "12")
      .and("contain", "10");
    cy.get(".v-card-subtitle > :nth-child(5)")
      .should("contain", "2023")
      .and("contain", "12")
      .and("contain", "22");
    cy.get(".v-card-subtitle > :nth-child(6)")
      .should("contain", "2023")
      .and("contain", "10")
      .and("contain", "10");
  });
  it("emits events", () => {
    const onDelete = cy.spy().as("onDeleteSpy");
    const onEdit = cy.spy().as("onEditSpy");
    cy.mount(BusCard, {
      props: {
        bus,
        onDelete,
        onEdit,
      },
    });
    cy.get("button").contains("Delete").click();
    cy.get("@onDeleteSpy").should("have.been.called");
    cy.get("button").contains("Edit").click();
    cy.get("@onEditSpy").should("have.been.called");
  });
});

describe("<EmployeeCard />", () => {
  const employee = {
    provider: "email",
    uid: "csatabela@gmail.com",
    allow_password_change: false,
    email: "csatabela@gmail.com",
    firstname: "Béla",
    lastname: "Csata",
    role: "driver",
    phone_number: "0752358475",
    address: "Mun. Gheorgheni str. Ghindei nr. 1",
    company_uid: "CPY_7DOFZ",
    created_at: "2024-10-03T15:58:01.359+03:00",
    updated_at: "2024-10-03T15:58:01.359+03:00",
  };
  it("renders", () => {
    cy.mount(EmployeeCard, {
      props: {
        employee,
      },
    });
    cy.get(".v-card-title").contains("Béla Csata");
    cy.get(".v-card-subtitle > :nth-child(1)").contains("driver");
    cy.get(".v-card-subtitle > :nth-child(2)").contains("0752358475");
    cy.get(".v-card-subtitle > :nth-child(3)").contains("csatabela@gmail.com");
    cy.get(".v-card-subtitle > :nth-child(4)")
      .should("contain", "2024")
      .and("contain", "10")
      .and("contain", "3");
  });
  it("emits events", () => {
    const onDelete = cy.spy().as("onDeleteSpy");
    const onEdit = cy.spy().as("onEditSpy");
    cy.mount(EmployeeCard, {
      props: {
        employee,
        onDelete,
        onEdit,
      },
    });
    cy.get("button").contains("Delete").click();
    cy.get("@onDeleteSpy").should("have.been.called");
    cy.get("button").contains("Edit").click();
    cy.get("@onEditSpy").should("have.been.called");
  });
});
