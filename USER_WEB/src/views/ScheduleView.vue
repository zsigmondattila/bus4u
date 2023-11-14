<template>
  <AppLayout>
    <SectionTitle>
      Schedule
      <template #description>
        Departure timetable
      </template>
    </SectionTitle>
    <v-form @submit.prevent="onSubmit" validate-on="submit" class="my-5">
      <v-container class="px-0">
        <v-row justify="center">
          <v-col cols="12" sm="4">
            <v-select :items="cities" :item-props="getName" label="City" :loading="!cities.length" v-model="form.city" class="text-field" hide-details="auto" :rules="rules" @update:model-value="getStations"></v-select>
          </v-col>
          <v-col cols="12" sm="4">
            <v-select :items="stations" :item-props="getName" label="Station" :disabled="!form.city" :loading="!stations.length && !!form.city" v-model="form.station" class="text-field" hide-details="auto" :rules="rules" @update:model-value="getBuses"></v-select>
          </v-col>
          <v-col cols="12" sm="4">
            <v-select :items="buses" :item-props="getName" label="Bus" :disabled="!form.station" :loading="!buses.length && !!form.station" v-model="form.bus" class="text-field" hide-details="auto" :rules="rules"></v-select>
          </v-col>
          <v-col cols="12" sm="2" style="text-align: center;">
            <v-btn type="submit" color="primary"> Search </v-btn>
          </v-col>
        </v-row>
      </v-container>
    </v-form>

    <v-table class="border rounded">
      <tbody v-if="timetable">
        <tr v-for="day in timetable" :key="day.name">
          <td>{{ day.name }}</td>
          <td v-for="time in day.departure_times" :key="time">{{ time }}</td>
        </tr>
      </tbody>
      <h3 v-else class="fallback"> Here will appear the timetable </h3>
    </v-table>
    <Map v-if="coordinates" :coordinate-array="coordinates"/>
  </AppLayout>
</template>

<script setup>
import axios from "axios";
import { onMounted, reactive, ref } from "vue";
import AppLayout from "@/components/AppLayout.vue"
import SectionTitle from "@/components/SectionTitle.vue"
import Map from "../components/Map.vue";

const cities = ref([]);
const stations = ref([]);
const buses = ref([]);

const timetable = ref([
    {
      name: 'Weekday',
      departure_times: ['8:00', '9:30', '11:00', '12:00', '14:30', '15:00', '16:00', '17:30']
    },
    {
      name: 'Weekend',
      departure_times: ['8:00', '11:00', '14:30', '16:00', '18:30']
    }
  ])

const coordinates = ref([
    [24.599099264925712, 46.52369326079823],
    [24.601341591579715, 46.5248079350453],
    [24.589255558112836, 46.53304548076141],
    [24.595199333221995, 46.535540118192806],
    [24.584760175828738, 46.539702512465624],
    [24.583354698146348, 46.53514157435465],
    [24.571992860849594, 46.53560654187607],
    [24.571638809235168, 46.53348832419385],
  ])

const form = reactive({
  city: '',
  station: '',
  bus: ''
})

const rules = [
  (v) => !!v || 'This field cannot be empty'
]

function getName(item){
  return { title: item.name };
}

async function getCities() {
  cities.value = (await axios.get('https://bus4u.fast-table.com/v1/get_cities')).data.cities
}

async function getStations(city) {
  stations.value = (await axios.get('https://bus4u.fast-table.com/v1/get_stations_by_city', { params:{ city_uid: city.city_uid }})).data.stations
}

async function getBuses(station) {
  buses.value = (await axios.get('https://bus4u.fast-table.com/v1/get_routes_by_station', { params:{ station_uid: station.station_uid }})).data.routes
}

async function onSubmit() {
  timetable.value = (await axios.get('https://bus4u.fast-table.com/v1/get_departure_times_for_station_in_route', { params:{ station_uid: form.station.station_uid, route_uid: form.bus.route_uid }})).data
}

onMounted(() => {
  getCities();
})
</script>

<style scoped>
.fallback {
  opacity: .5;
  text-align: center;
  margin: 10px;
}
</style>