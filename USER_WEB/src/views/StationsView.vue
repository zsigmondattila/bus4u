<template>
  <AppLayout>
    <SectionTitle>
      Stations
      <template #description>
        Browse stations on the map
      </template>
    </SectionTitle>
    <v-form @submit.prevent="onSubmit" validate-on="submit" class="my-5">
      <v-container class="px-0">
        <v-row justify="center">
          <v-col cols="12" sm="5">
            <v-autocomplete :items="cities" :item-props="getName" label="City" :disabled="!!form.bus" :loading="!cities.length" v-model="form.city" class="text-field" hide-details="auto" @update:modelValue="getBuses"></v-autocomplete>
          </v-col>
          <v-col cols="12" sm="5">
            <v-autocomplete :items="buses" :item-props="getName" label="Bus" :disabled="!!form.city" :loading="!buses.length && !!form.city" v-model="form.bus" class="text-field" hide-details="auto"></v-autocomplete>
          </v-col>
          <v-col cols="12" sm="2" style="text-align: center;">
            <v-btn type="submit" color="primary"> Filter </v-btn>
          </v-col>
        </v-row>
      </v-container>
    </v-form>

    <Map ref="mapBox" :stations="stations" :toggle-pan="autoPan"/>
  </AppLayout>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue';
import axios from 'axios';
import AppLayout from '../components/AppLayout.vue';
import SectionTitle from '../components/SectionTitle.vue';
import Map from '../components/Map.vue';

const form = reactive({
  city: '',
  bus: '',
})

const autoPan = ref(false)
const cities = ref([])
const buses = ref([])
const stations = ref([])

function getName(item){
  return { title: item.name };
}

function onSubmit() {
  if(form.city && !form.bus) {
    axios.get('https://bus4u.fast-table.com/v1/get_stations_by_city', {params: { city_uid: form.city.city_uid }})
    .then(rsp => {
      if(rsp.status == 200) {
        stations.value = rsp.data.stations
        autoPan.value = true
      }
    }).catch(e => console.error(e))
  } else if(form.bus) {
    axios.get('https://bus4u.fast-table.com/v1/get_stations_of_a_route', {params: { route_uid: form.bus.route_uid }})
    .then(rsp => {
      if(rsp.status == 200) {
        stations.value = rsp.data.stations
        autoPan.value = true
      }
    }).catch(e => console.error(e))
  }
}

async function getBuses() {
  axios.get('https://bus4u.fast-table.com/v1/get_routes')
    .then(rsp => {
      if(rsp.status == 200) buses.value = rsp.data.routes
    }).catch(e => console.error(e))
}

onMounted(() => {
  axios.get('https://bus4u.fast-table.com/v1/get_stations')
  .then(rsp => {
      if(rsp.status == 200) stations.value = rsp.data.stations
    }).catch(e => console.error(e))

  axios.get('https://bus4u.fast-table.com/v1/get_cities')
    .then(rsp => {
      if(rsp.status == 200) cities.value = rsp.data.cities
    }).catch(e => console.error(e))
  axios.get('https://bus4u.fast-table.com/v1/get_routes')
    .then(rsp => {
      if(rsp.status == 200) buses.value = rsp.data.routes
    }).catch(e => console.error(e))
})
</script>

<style scoped>
@media (min-width: 600px){
  .v-btn{
    height: 100%;
    width: 100%;
    font-size: medium;
  }
}
</style>