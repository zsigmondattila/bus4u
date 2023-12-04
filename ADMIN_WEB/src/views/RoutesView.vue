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
        <v-row>
          <v-col cols="9">
            <v-autocomplete label="Route" :items="routes" :item-props="getProps" :disabled="routeCreation" v-model="route" :rules="rules" @update:modelValue="getStations"></v-autocomplete>
          </v-col>
          <v-col cols="3">
            <v-btn class="form-button h-100" @click="createRoute"> New Route </v-btn>
          </v-col>
        </v-row>
      </v-container>
    </v-form>
    <div v-if="route">
      <v-divider class="my-5"></v-divider>
      <h3 class="text-subtitle-1"> Edit route </h3>
      <v-form @submit.prevent="editRoute">
        <v-container>
          <v-row>
            <v-col cols="12" md="9">
              <v-text-field label="Name" v-model="route.name" :rules="nameRules"></v-text-field>
            </v-col>
            <v-col cols="12" md="3">
              <v-text-field label="Basic fare" v-model="route.basic_fare" suffix="Lei"></v-text-field>
            </v-col>
          </v-row>
          <v-list border class="py-0 my-5">
            <v-list-subheader class="border"> Stations ({{ stations.length }}) </v-list-subheader>
            <v-list-item v-for="(station, index) in stations" :key="station.station_uid" :value="station" :title="station.name" prepend-icon="mdi-map-marker-outline" border>
              <template #subtitle>
                {{ station.address }}&nbsp;&nbsp;►&nbsp;&nbsp;{{ station.longitude }} · {{ station.latitude }}
              </template>
              <template #append>
                <v-btn icon="mdi-delete-outline" elevation="0" @click="deleteStation(index)"></v-btn>
              </template>
            </v-list-item>
          </v-list>
          <v-form class="my-5" validate-on="submit" @submit.prevent="addStation">
            <v-row>
              <v-col cols="10">
                <v-autocomplete label="Add station" :items="allStations" :item-props="getProps" v-model="newStation" :rules="rules"></v-autocomplete>
              </v-col>
              <v-col cols="2">
                <v-btn type="submit" class="form-button h-100"> Add </v-btn>
              </v-col>
            </v-row>
          </v-form>
          <v-row justify="end">
            <v-col cols="6" lg="3">
              <v-btn class="form-button" @click="deleteRoute"> Delete route </v-btn>
            </v-col>
            <v-col cols="6" lg="3">
              <v-btn type="submit" class="form-button"> Save route </v-btn>
            </v-col>
          </v-row>
        </v-container>
      </v-form>
    </div>
  </AppLayout>
</template>

<script setup>
import { ref } from 'vue';
import axios from 'axios';
import AppLayout from '../components/AppLayout.vue';
import SectionTitle from '../components/SectionTitle.vue';

const route = ref(null)
const routes = ref([])
const stations = ref([])
const newStation = ref(null)
const allStations = ref([])
const routeCreation = ref(false)

const rules = [
  (v) => !!v || 'Select a route first!'
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
  stations.value.splice(station, 1)
  console.log('Update:', stations.value);
}

function addStation(e){
  e.then(rsp => {
    if(rsp.valid) {
      stations.value.push(newStation.value)
      newStation.value = ''
    }
  }).catch()
}

async function editRoute(e) {
  let rsp = await e;
  if(rsp.valid) {
    // axios delete route
    // axios create route from route and stations
    routes.value.push(route.value) // TODO: replace with update from API
    route.value = null
    routeCreation.value = false
  }
  else console.warn('Not valid');
}

function deleteRoute() {
  // axios deletes the route
  route.value = ''
  axios.get('https://bus4u.fast-table.com/v1/get_routes')
  .then(rsp => {
    console.log(rsp);
    if(rsp.status == 200) routes.value = rsp.data.routes
  }).catch(() => routes.value = [])
}

function getStations(route){
  axios.get('https://bus4u.fast-table.com/v1/get_stations_of_a_route', { params: { route_uid: route.route_uid }})
    .then(rsp => {
      if(rsp.status == 200) stations.value = rsp.data.stations
    }).catch(() => stations.value = [])
}

axios.get('https://bus4u.fast-table.com/v1/get_routes')
  .then(rsp => {
    console.log(rsp);
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