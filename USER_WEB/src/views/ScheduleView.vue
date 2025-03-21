<template>
  <AppLayout>
    <SectionTitle>
      Schedule
      <template #description>
        Select a station and a bus to view the departure timetable and the route marked on the map
      </template>
    </SectionTitle>
    <v-form @submit.prevent="onSubmit" validate-on="submit" class="my-5">
      <v-row justify="center">
        <v-col cols="12" sm="4">
          <v-autocomplete :items="cities" :item-props="getName" label="City" name="city" :loading="!cities.length"
            v-model="form.city" class="text-field" hide-details="auto" :rules="rules" auto-select-first
            @update:model-value="getStations"></v-autocomplete>
        </v-col>
        <v-col cols="12" sm="4">
          <v-autocomplete :items="stations" :item-props="getName" label="Station" name="station" :disabled="!form.city"
            :loading="!stations.length && !!form.city" v-model="form.station" class="text-field" hide-details="auto"
            auto-select-first :rules="rules" @update:model-value="getRoutes"></v-autocomplete>
        </v-col>
        <v-col cols="12" sm="4">
          <v-autocomplete :items="routes" :item-props="getName" label="Bus" name="route" :disabled="!form.station"
            :loading="!routes.length && !!form.station" v-model="form.route" class="text-field" hide-details="auto"
            auto-select-first :rules="rules"></v-autocomplete>
        </v-col>
        <v-col cols="12" sm="2" style="text-align: center;">
          <v-btn type="submit" color="primary" size="large"> Search </v-btn>
        </v-col>
      </v-row>
    </v-form>
    <div class="border rounded">
      <p v-if="!timetable" class="pa-3 text-subtitle-2 text-medium-emphasis text-center"> There are no departure times
        for
        this station and bus. </p>
      <h3 v-else-if="timetable.length" class="pa-3 text-subtitle-2"> <b>Departure times for station: </b>{{
        displayed.station.name }}<b> and bus: </b>{{ displayed.route.name }}</h3>
      <v-table v-if="timetable" class="border-t rounded-t-0">
        <tbody v-if="timetable.length">
          <tr v-for="day in timetable" :key="day.name">
            <td class="font-weight-medium">{{ day.name }}</td>
            <td v-for="time in day.departure_times" :key="time" :max-width="2">{{ time }}</td>
          </tr>
        </tbody>
        <v-skeleton-loader v-else type="table-row@2" :boilerplate="!isLoadingTable"></v-skeleton-loader>
      </v-table>
    </div>
    <Map ref="map" class="mt-0" v-if="route" :stations="route" :buses="buses" :enableRoute="true" controls="true" />
  </AppLayout>
</template>

<script setup>
import axios from "axios";
import { onMounted, reactive, ref } from "vue";
import AppLayout from "@/components/AppLayout.vue"
import SectionTitle from "@/components/SectionTitle.vue"
import Map from "../components/Map.vue";
import { onBeforeUnmount } from "vue";

const isLoadingTable = ref(false)
let updateInterval = null
const map = ref(null)
const displayed = ref(null)

const cities = ref([]);
const stations = ref([]);
const routes = ref([]);
const buses = ref([]);

const timetable = ref([])
const route = ref([])

const form = reactive({
  city: null,
  station: null,
  route: null
})

const rules = [
  (v) => !!v || 'This field cannot be empty'
]

function getName(item) {
  return { title: item.name };
}

async function getCities() {
  cities.value = (await axios.get('https://api.bus4u.online/v1/get_cities')).data.cities
}

async function getStations(city) {
  form.station = null
  form.route = null
  if (city) stations.value = (await axios.get('https://api.bus4u.online/v1/get_stations_by_city', { params: { city_uid: city.city_uid } })).data.stations
}

async function getRoutes(station) {
  form.route = ''
  if (station) routes.value = (await axios.get('https://api.bus4u.online/v1/get_routes_by_station', { params: { station_uid: station.station_uid } })).data.routes
}

function getBuses(route) {
  axios.get('https://api.bus4u.online/v1/get_bus_locations_by_route', { params: { route_uid: route.route_uid } })
    .then(rsp => {
      if (rsp.status == 200) {
        buses.value = rsp.data
        if (buses.value.length === 0) clearInterval(updateInterval)
      }
    }).catch(() => {
      buses.value = []
      clearInterval(updateInterval)
    })
}

async function onSubmit(e) {
  if (!(await e).valid) return
  clearInterval(updateInterval)
  isLoadingTable.value = true
  displayed.value = { station: form.station, route: form.route }
  try {
    timetable.value = (await axios.get('https://api.bus4u.online/v1/get_departure_times_for_station_in_route', { params: { station_uid: form.station.station_uid, route_uid: form.route.route_uid } })).data
    const days = { 'Monday': 0, 'Tuesday': 1, 'Wednesday': 2, 'Thursday': 3, 'Friday': 4, 'Saturday': 5, 'Sunday': 6 }
    timetable.value.sort((d1, d2) => {
      return days[d1.name] - days[d2.name]
    })
  } catch {
    timetable.value = null
  }
  isLoadingTable.value = false
  route.value = (await axios.get('https://api.bus4u.online/v1/get_stations_of_a_route', { params: { route_uid: form.route.route_uid } })).data.stations
  map.value.panTo([form.station.longitude, form.station.latitude])
  getBuses(form.route)
  updateInterval = setInterval(() => getBuses(form.route), 30000);
}

onMounted(() => {
  getCities();
})
onBeforeUnmount(() => {
  clearInterval(updateInterval);
})
</script>

<style scoped></style>