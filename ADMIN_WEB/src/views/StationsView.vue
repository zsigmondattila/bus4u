<template>
  <AppLayout>
    <SectionTitle>
      Stations
      <template #description>
        Delete stations from the list or add new station by clicking on the plus icon.
      </template>
    </SectionTitle>
    <v-row class="mt-1">
      <v-col cols="12" md="6">
        <v-list border class="py-0 mb-5" :max-height="formIsOpen ? 320 : 600" @click:select="panMap">
          <v-list-item v-for="station in stations" :key="station.station_uid" :value="station" :title="station.name" prepend-icon="mdi-map-marker-outline" border>
            <template #subtitle>
              {{ station.address }}&nbsp;&nbsp;►&nbsp;&nbsp;{{ station.longitude }} · {{ station.latitude }}
            </template>
            <template #append>
              <v-btn icon="mdi-delete-outline" elevation="0" @click="deleteStation(station)"></v-btn>
            </template>
          </v-list-item>
        </v-list>
        <div v-if="!formIsOpen" class="d-flex mt-n11">
          <v-btn icon="mdi-plus-circle" class="mx-auto" @click="formIsOpen = true" color="primary"></v-btn>
        </div>
        <v-form v-else @submit.prevent="addStation" validate-on="submit" class="my-5 bg-grey-darken-4 pa-4 border-md">
          <p class="text-subtitle-1"> Create new Station </p>
          <v-row justify="center" class="mt-0" dense>
            <v-col cols="12" order="1">
              <v-text-field label="Station name" v-model="newStation.name" :rules="nameRule" hide-details="auto" density="compact"></v-text-field>
            </v-col>
            <v-col cols="12" sm="5" order="2">
              <v-text-field label="City" v-model="newStation.city" hide-details="auto"></v-text-field>
            </v-col>
            <v-col cols="12" sm="5" order="3">
              <v-text-field label="Address" v-model="newStation.address" hide-details="auto"></v-text-field>
            </v-col>
            <v-col cols="12" sm="2" order="7" order-sm="4">
              <v-btn type="reset" color="primary" variant="outlined" class="form-button" block @click="resetForm"> Cancel </v-btn>
            </v-col>
            <v-col cols="12" sm="5" order="5">
              <v-text-field label="Longitude" type="number" v-model="newStation.coordinates[0]" :rules="coordinateRule" hide-details="auto"></v-text-field>
            </v-col>
            <v-col cols="12" sm="5" order="6">
              <v-text-field label="Latitude" type="number" v-model="newStation.coordinates[1]" :rules="coordinateRule" hide-details="auto"></v-text-field>
            </v-col>
            <v-col cols="12" sm="2" order="8">
              <v-btn type="submit" color="primary" class="form-button" block> Save </v-btn>
            </v-col>
          </v-row>
          <p class="text-caption text-disabled pa-1 opacity-5"> Click on the map to fill the coordinates, city and address. </p>
        </v-form>
      </v-col>
      <v-col cols="12" md="6">
        <MapBox ref="mapBox" :stations="stations" v-model:pointer="newStation"/>
      </v-col>
    </v-row>
    <v-snackbar v-model="notification.show">
      {{ notification.message }}
    </v-snackbar>
  </AppLayout>
</template>

<script setup>
import axios from 'axios';
import { reactive, ref } from 'vue';
import AppLayout from '../components/AppLayout.vue';
import SectionTitle from '../components/SectionTitle.vue';
import MapBox from '../components/MapBox.vue';

const mapBox = ref(null)
const stations = ref([])
const formIsOpen = ref(false)
const notification = ref({
  show: false,
  message: null
})
const newStation = reactive({
  name: '',
  coordinates: [],
  city: '',
  address: '',
  postcode: ''
})

const nameRule = [
  (v) => !!v || 'The field is required',
  (v) => /^[\p{L}].+$/u.test(v) || 'The field must be a valid name'
]

const coordinateRule = [
  (v) => !!v || 'Type here the coordinate or click on the map',
  (v) => /^[0-9]+\.?[0-9]*$/.test(v) || 'The field must be a valid coordinate'
]

function panMap(station) {
  if(mapBox.value) {
    mapBox.value.setCustomPointer([station.id.longitude, station.id.latitude])
    newStation.name = ''
    newStation.coordinates = []
    newStation.city = ''
    newStation.address = ''
    newStation.postcode = ''
  }
}

function deleteStation(station){
  axios.delete('https://bus4u.fast-table.com/v1/admin/delete_station', { params: { station_uid: station.station_uid }})
    .then(() => {
      notification.value.message = 'Station deleted successfully'
      notification.value.show = true
      updateStations();
    })
}

function resetForm() {
  newStation.name = ''
  newStation.coordinates = []
  newStation.city = ''
  newStation.address = ''
  newStation.postcode = ''
  formIsOpen.value = false
}

async function addStation(e){
  let rsp = await e;
  if(!rsp.valid) return;

  let createRsp = await axios.post('https://bus4u.fast-table.com/v1/admin/create_station', 
    { name: newStation.name, latitude: newStation.coordinates[1], longitude: newStation.coordinates[0], city: newStation.city, address: newStation.address, zip_code: newStation.postcode })
  if (createRsp.status == 200) {
    notification.value.message = 'Station created successfully';
    notification.value.show = true;
    resetForm();
    updateStations();
  }
}

function updateStations() {
  axios.get('https://bus4u.fast-table.com/v1/get_stations')
  .then(rsp => {
    if (rsp.status == 200) {
      stations.value = rsp.data.stations
    }
  })
}

axios.get('https://bus4u.fast-table.com/v1/get_stations')
  .then(rsp => {
    if (rsp.status == 200) {
      stations.value = rsp.data.stations
    }
  })
</script>

<style scoped>
@media (min-width: 600px) {
  .form-button {
    height: 100%;
  }
}
</style>