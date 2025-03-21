import Map from "./Map.vue";

describe("<Map />", () => {
  it("renders with controls", () => {
    cy.intercept("GET", "https://api.mapbox.com/map-sessions/**").as("map");
    cy.mount(Map, {
      props: {
        controls: true,
      },
    });
    cy.wait("@map");
    cy.get("input[type='checkbox']").should("have.length", 3);
  });
  it("renders with stations and route", () => {
    cy.intercept("GET", "https://api.mapbox.com/map-sessions/**").as("map");
    cy.mount(Map, {
      props: {
        enableRoute: true,
        stations: [
          {
            station_uid: "STT_EGAVX",
            name: "Sapientia",
            city: "Marosvásárhely",
            address: "Str. Calea Sighisoarei nr. 2",
            longitude: "24.59883",
            latitude: "46.52339",
          },
          {
            station_uid: "STT_6CO3Q",
            name: "Dedeman",
            city: "Marosvásárhely",
            address: "Bul. 1 Decembrie nr. 189",
            longitude: "24.59941",
            latitude: "46.52678",
          },
          {
            station_uid: "STT_HZY5S",
            name: "Regele Ferdinand",
            city: "Marosvásárhely",
            address: "Str. Livezeni nr. 32",
            longitude: "24.59133",
            latitude: "46.53422",
          },
          {
            station_uid: "STT_A6JTY",
            name: "Piata Diamant 1",
            city: "Marosvásárhely",
            address: "Str. Cutezantei nr. 12",
            longitude: "24.59033",
            latitude: "46.53736",
          },
          {
            station_uid: "STT_J6D1B",
            name: "Infratirii",
            city: "Marosvásárhely",
            address: "Str. infratirii nr. 78",
            longitude: "24.58423",
            latitude: "46.53851",
          },
          {
            station_uid: "STT_7ZOUW",
            name: "Fortuna",
            city: "Marosvásárhely",
            address: "Bul. 1 Decembrie nr. 117",
            longitude: "24.58276",
            latitude: "46.5356",
          },
          {
            station_uid: "STT_GCX7G",
            name: "Lalelelor",
            city: "Marosvásárhely",
            address: "Bul. 1 Decembrie nr. 93",
            longitude: "24.57623",
            latitude: "46.53908",
          },
          {
            station_uid: "STT_EV9LM",
            name: "Izvor",
            city: "Marosvásárhely",
            address: "Bul. 1 Decembrie nr. 59",
            longitude: "24.56045",
            latitude: "46.53967",
          },
          {
            station_uid: "STT_PXVPC",
            name: "Grand",
            city: "Marosvásárhely",
            address: "Piata Vitoriei nr. 4",
            longitude: "24.55786",
            latitude: "46.54195",
          },
          {
            station_uid: "STT_AZLUF",
            name: "Piata Trandafirilor",
            city: "Marosvásárhely",
            address: "Piata Trandafirilor nr. 10",
            longitude: "24.56029",
            latitude: "46.54377",
          },
        ],
      },
    });
    cy.wait("@map");
    cy.get(".mapboxgl-marker").should("have.length.gt", 1);
  });
  it("renders with buses", () => {
    cy.intercept("GET", "https://api.mapbox.com/map-sessions/**").as("map");
    cy.mount(Map, {
      props: {
        enableRoute: true,
        hideStations: true,
        buses: [
          {
            license_plate: "MS-01-ABC",
            brand: "Mercedes Benz Citaro",
            capacity: 52,
            longitude: "24.582",
            latitude: "46.536",
          },
        ],
        stations: [
          {
            station_uid: "STT_EGAVX",
            name: "Sapientia",
            city: "Marosvásárhely",
            address: "Str. Calea Sighisoarei nr. 2",
            longitude: "24.59883",
            latitude: "46.52339",
          },
          {
            station_uid: "STT_6CO3Q",
            name: "Dedeman",
            city: "Marosvásárhely",
            address: "Bul. 1 Decembrie nr. 189",
            longitude: "24.59941",
            latitude: "46.52678",
          },
          {
            station_uid: "STT_HZY5S",
            name: "Regele Ferdinand",
            city: "Marosvásárhely",
            address: "Str. Livezeni nr. 32",
            longitude: "24.59133",
            latitude: "46.53422",
          },
          {
            station_uid: "STT_A6JTY",
            name: "Piata Diamant 1",
            city: "Marosvásárhely",
            address: "Str. Cutezantei nr. 12",
            longitude: "24.59033",
            latitude: "46.53736",
          },
          {
            station_uid: "STT_J6D1B",
            name: "Infratirii",
            city: "Marosvásárhely",
            address: "Str. infratirii nr. 78",
            longitude: "24.58423",
            latitude: "46.53851",
          },
          {
            station_uid: "STT_7ZOUW",
            name: "Fortuna",
            city: "Marosvásárhely",
            address: "Bul. 1 Decembrie nr. 117",
            longitude: "24.58276",
            latitude: "46.5356",
          },
          {
            station_uid: "STT_GCX7G",
            name: "Lalelelor",
            city: "Marosvásárhely",
            address: "Bul. 1 Decembrie nr. 93",
            longitude: "24.57623",
            latitude: "46.53908",
          },
          {
            station_uid: "STT_EV9LM",
            name: "Izvor",
            city: "Marosvásárhely",
            address: "Bul. 1 Decembrie nr. 59",
            longitude: "24.56045",
            latitude: "46.53967",
          },
          {
            station_uid: "STT_PXVPC",
            name: "Grand",
            city: "Marosvásárhely",
            address: "Piata Vitoriei nr. 4",
            longitude: "24.55786",
            latitude: "46.54195",
          },
          {
            station_uid: "STT_AZLUF",
            name: "Piata Trandafirilor",
            city: "Marosvásárhely",
            address: "Piata Trandafirilor nr. 10",
            longitude: "24.56029",
            latitude: "46.54377",
          },
        ],
      },
    });
    cy.wait("@map");
    cy.get(".mapboxgl-marker").should("have.length.gt", 1);
  });
});
