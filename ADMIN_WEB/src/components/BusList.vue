<template>
  <SectionTitle>
    Manage buses
    <template #description>
      Create or delete buses for your company
    </template>
  </SectionTitle>
  <v-container>
    <v-row>
      <v-col v-for="bus in buses" :key="bus.bus_uid" cols="12" sm="6" md="4" lg="3" xl="2">
        <BusCard :bus="bus" @delete="deleteBus(bus)"/>
      </v-col>
      <v-col cols="12" sm="6" md="4" lg="3" xl="2">
        <v-card :to="{name: 'create-bus'}" height="100%" class="d-flex flex-column text-center" min-width="200">
          <v-sheet class="text-center" color="adjacent">
            <v-icon size="120" icon="mdi-plus-circle-outline"></v-icon>
          </v-sheet>
          <v-spacer></v-spacer>
          <v-card-title> Add new </v-card-title>
          <v-spacer></v-spacer>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
  <v-snackbar v-model="isDeleted">
    Bus deleted successfully
  </v-snackbar>
  <v-snackbar v-model="error">
    Operation failed
  </v-snackbar>
</template>

<script setup>
import { ref } from 'vue';
import axios from 'axios';
import BusCard from '../components/BusCard.vue';
import SectionTitle from './SectionTitle.vue';
import { userStore } from '../stores/userStore';

const user = userStore()
const buses = ref([])
const isDeleted = ref(false)
const error = ref(false)

function deleteBus(bus) {
  axios.delete('https://bus4u.fast-table.com/v1/admin/delete_bus', { params: { company_uid: user.company_uid, bus_uid: bus.bus_uid }})
  .then(() => {
    isDeleted.value = true
    axios.get('https://bus4u.fast-table.com/v1/admin/get_buses_of_a_company', { params: { company_uid: user.company_uid }})
      .then(rsp => {
        buses.value = rsp.data
      }).catch(() => buses.value = [])
  }).catch(() => error.value = true)
}

axios.get('https://bus4u.fast-table.com/v1/admin/get_buses_of_a_company', { params: { company_uid: user.company_uid }})
  .then(rsp => {
    buses.value = rsp.data
  }).catch(() => buses.value = [])
</script>

<style scoped>

</style>