<template>
  <AppLayout>
    <SectionTitle>
      Routes
      <template #description>
        Select a route from the list below or create a new one
      </template>
    </SectionTitle>
    <br>
    <v-form validate-on="submit">
      <v-container>
        <v-row justify="center">
          <v-col cols="12" :sm="route ? 9 : 10">
            <v-autocomplete label="Route" :items="routes" :item-props="getProps" :disabled="routeCreation" v-model="route" :rules="rules" @update:modelValue="getStations"></v-autocomplete>
          </v-col>
          <v-col cols="6" sm="3">
              <v-btn class="form-button" color="primary" @click="createRoute"> New Route </v-btn>
          </v-col>
        </v-row>
      </v-container>
    </v-form>
    <div v-if="route">
      <v-divider class="my-5"></v-divider>
      <h3 class="text-subtitle-1"> Edit route </h3>
      <v-form @submit.prevent="saveRoute">
        <v-container>
          <v-row dense>
            <v-col cols="12" md="9">
              <v-text-field label="Name" v-model="route.name" :rules="nameRules"></v-text-field>
            </v-col>
            <v-col cols="12" md="3">
              <v-text-field label="Basic fare" v-model="route.basic_fare" suffix="Lei"></v-text-field>
            </v-col>
          </v-row>
          <v-list border class="py-0 my-3">
            <v-list-subheader class="border"> Stations ({{ stations.length }}) </v-list-subheader>
            <v-list-item v-for="(station, index) in stations" :key="index" :title="station.name" prepend-icon="mdi-map-marker-outline" border>
              <template #subtitle>
                {{ station.address }}&nbsp;&nbsp;►&nbsp;&nbsp;{{ station.longitude }} · {{ station.latitude }}
              </template>
              <template #append>
                <v-btn icon="mdi-delete-outline" elevation="0" @click="deleteStation(index)"></v-btn>
              </template>
            </v-list-item>
          </v-list>
          <v-form class="my-2" validate-on="submit" @submit.prevent="addStation">
            <v-row dense>
              <v-col cols="9">
                <v-autocomplete label="Add station" :items="allStations" :item-props="getProps" v-model="newStation" :rules="rules"></v-autocomplete>
              </v-col>
              <v-col cols="3">
                <v-btn type="submit" class="form-button"> Add </v-btn>
              </v-col>
            </v-row>
          </v-form>
          <v-row justify="center" justify-lg="end" class="mt-8" dense>
            <v-col cols="6" lg="3">
              <v-btn class="form-button" @click="deleteRoute" color="red" variant="outlined"> Delete route </v-btn>
            </v-col>
            <v-col cols="6" lg="3">
              <v-btn type="submit" class="form-button" color="primary"> Save route </v-btn>
            </v-col>
          </v-row>
        </v-container>
      </v-form>
    </div>
    <v-snackbar v-model="notification">
      {{ notification }}
    </v-snackbar>
  </AppLayout>
</template>

<script setup>
import { ref } from 'vue';
import axios from 'axios';
import { userStore } from '@/stores/userStore';
import AppLayout from '../components/AppLayout.vue';
import SectionTitle from '../components/SectionTitle.vue';

const user = userStore()
const notification = ref(null)

const route = ref(null)
const routes = ref([])
const stations = ref([])
const newStation = ref(null)
const allStations = ref([])
const routeCreation = ref(false)

const rules = [
  (v) => !!v || 'Select an option first!'
]
const nameRules = [
  (v) => !!v || 'This can\'t be empty!'
]

function getProps(route){
  return { title: route.name, value: route }
}

function createRoute(){
  routeCreation.value = true
  route.value = {
    name: null,
    basic_fare: 0
  }
  stations.value = []
}

function deleteStation(station){
  axios.delete('https://bus4u.fast-table.com/v1/admin/delete_station_from_route', { params: { route_uid: route.value.route_uid, station_uid: stations.value[station].station_uid }})
  stations.value.splice(station, 1)
}

function addStation(e){
  e.then(rsp => {
    if(rsp.valid) {
      stations.value.push(newStation.value)
      newStation.value = ''
    }
  }).catch()
}

async function saveRoute(e) {
  let rsp = await e;
  if(rsp.valid) {
    axios.delete('https://bus4u.fast-table.com/v1/admin/delete_route', { params: { bus_uid: route.value.route_uid }})
      .then(() => {
        axios.post('https://bus4u.fast-table.com/v1/admin/create_route', Object.assign(route.value, { company_uid: user.companyUid }))
        .then(async () => {
          for(let i=0; i<stations.value.length; i++) {
            await axios.post('https://bus4u.fast-table.com/v1/admin/add_station_to_route', { route_uid: route.value.route_uid, station_uid: stations.value[i].station_uid, sequence: i+1 })
          }
          axios.get('https://bus4u.fast-table.com/v1/get_routes')
            .then(rsp => {
              if(rsp.status == 200) routes.value = rsp.data.routes
          }).catch(() => routes.value = [])
          notification.value = 'Route saved successfully'
          route.value = null
          routeCreation.value = false
        })
      })
  }
  else console.warn('Not valid');
}

function deleteRoute() {
  axios.delete('https://bus4u.fast-table.com/v1/admin/delete_route', { params: { bus_uid: route.value.route_uid }})
  .then(() => {
    notification.value = 'Route deleted successfully'
    route.value = ''
    routeCreation.value = false
    axios.get('https://bus4u.fast-table.com/v1/get_routes')
      .then(rsp => {
        if(rsp.status == 200) routes.value = rsp.data.routes
      }).catch(() => routes.value = [])
  }).catch(() => console.error('Cannot delete route'))
}

function getStations(route){
  axios.get('https://bus4u.fast-table.com/v1/get_stations_of_a_route', { params: { route_uid: route.route_uid }})
    .then(rsp => {
      if(rsp.status == 200) stations.value = rsp.data.stations
    }).catch(() => stations.value = [])
}

axios.get('https://bus4u.fast-table.com/v1/admin/get_routes_of_a_company', { params: { company_uid: user.companyUid }})
  .then(rsp => {
    if(rsp.status == 200) routes.value = rsp.data.routes
  }).catch(() => routes.value = [])
axios.get('https://bus4u.fast-table.com/v1/get_stations')
  .then(rsp => {
    if(rsp.status == 200) allStations.value = rsp.data.stations
  }).catch(() => allStations.value = [])
</script>

<style scoped>
.form-button {
  width: 100%;
  height: 50px;
  font-size: medium;
}
</style>