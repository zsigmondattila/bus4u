<template>
  <AppLayout>
    <SectionTitle>
      Schedule
      <template #description>
        Edit timetable
      </template>
    </SectionTitle>
    <v-form validate-on="submit" class="my-5">
      <v-container>
        <v-row justify="center">
          <v-col cols="12" sm="6">
            <v-autocomplete :items="routes" :item-props="getProps" label="Route" v-model="toEdit.route" class="text-field" hide-details="auto"  @update:modelValue="getStations"></v-autocomplete>
          </v-col>
          <v-col cols="12" sm="6">
            <v-autocomplete :items="stations" :item-props="getProps" label="Station" :disabled="!toEdit.route" v-model="toEdit.station" class="text-field" hide-details="auto" :rules="required"></v-autocomplete>
          </v-col>
        </v-row>
      </v-container>
    </v-form>
    <div v-for="(elem, index) in timetable" :key="index">
      <v-form class="my-3" disabled>
        <v-container class="border">
          <v-row justify="center">
            <v-col cols="12">
              <v-combobox :items="days" label="Day(s)" v-model="elem.name" multiple hide-details="auto" density="comfortable"></v-combobox>
            </v-col>
            <v-col cols="12" sm="6">
              <v-text-field label="Fare" type="number" v-model="elem.fare" suffix="Lei"></v-text-field>
            </v-col>
            <v-col cols="12" sm="6">
              <v-text-field ref="timeInput" label="Time" type="time">
                <template #append>
                  <v-btn @click="addTimeToArray" class="h-100"> Add </v-btn>
                </template>
              </v-text-field>
            </v-col>
            <v-col cols="12" md="9">
              <v-chip v-for="(time, index) in elem.departure_times" :key="index" class="mr-2 mb-2">{{ time }}</v-chip>
            </v-col>
            <v-col cols="6" md="3">
              <v-btn color="red" variant="tonal" block @click="deleteTimetable(index)"> Delete </v-btn>
            </v-col>
          </v-row>
        </v-container>
      </v-form>
    </div>
    <v-form v-if="remainingDays.length" class="my-3" @submit.prevent="saveTimetable" validate-on="submit" @reset="tempForm.departure_times = []">
      <v-container class="border">
        <v-row justify="center">
          <v-col cols="12">
            <v-combobox :items="remainingDays" label="Day(s)" v-model="tempForm.name" multiple hide-details="auto" density="comfortable" :rules="dayRules"></v-combobox>
          </v-col>
          <v-col cols="12" sm="6">
            <v-text-field label="Fare" type="number" v-model="tempForm.fare" suffix="Lei"></v-text-field>
          </v-col>
          <v-col cols="12" sm="6">
            <v-text-field ref="timeInput" label="Time" v-model="tempTime" type="time" @keydown.enter.prevent="addTimeToArray" :error-messages="noTimesError">
              <template #append>
                <v-btn @click="addTimeToArray" class="h-100"> Add </v-btn>
              </template>
            </v-text-field>
          </v-col>
          <v-col cols="12">
            <v-chip v-for="(time, index) in tempForm.departure_times" :key="index" closable @click:close="deleteTimeFromArray(index)" class="mr-2 mb-2">{{ time }}</v-chip>
          </v-col>
        </v-row>
        <v-row justify="center" justify-md="end">
          <v-col cols="6" md="3">
            <v-btn type="reset" color="red" variant="outlined" block> Clear </v-btn>
          </v-col>
          <v-col cols="6" md="3">
            <v-btn type="submit" color="primary" block> Save </v-btn>
          </v-col>
        </v-row>
      </v-container>
    </v-form>
  </AppLayout>
</template>

<script setup>
import { reactive, ref } from 'vue';
import axios from 'axios';
import { userStore } from '../stores/userStore';
import AppLayout from '../components/AppLayout.vue';
import SectionTitle from '../components/SectionTitle.vue';

const user = userStore()
const timeInput = ref(null)
const noTimesError = ref(null)

const routes = ref([])
const stations = ref([])
const timetable = ref([])
const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
let remainingDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']

const tempForm = ref({
  name: null,
  fare: 0,
  departure_times: []
})
const tempTime = ref([])

const dayRules = [
  (v) => !!v || 'Please select at least one day!'
]
const required = [
  (v) => !!v || 'Please select a station!'
]

const toEdit = reactive({
  route: null,
  station: null
})

function addTimeToArray() {
  if(!tempTime.value) return
  noTimesError.value = null
  tempForm.value.departure_times.push(tempTime.value)
  tempForm.value.departure_times.sort()
  tempTime.value = ''
  timeInput.value.blur()
  timeInput.value.focus()
}

function deleteTimeFromArray(index) {
  tempForm.value.departure_times.splice(index, 1)
}

function saveTimetable() {
  if(!tempForm.value.departure_times.length){
    noTimesError.value = 'Please add at least one departure time.'
    return
  }
  timetable.value.push(tempForm.value)
  remainingDays = remainingDays.filter((v) => !tempForm.value.name.includes(v))
  tempForm.value = {
    name: null,
    fare: 0,
    departure_times: []
  }
}

function deleteTimetable(index) {
  console.log(timetable.value[index].name)
  remainingDays.push(...timetable.value[index].name)
  timetable.value.splice(index, 1)
}

function getProps(route){
  return { title: route.name, value: route }
}

function getStations(v) {
  console.log(v.route_uid);
  axios.get('https://bus4u.fast-table.com/v1/get_stations_of_a_route', { params: { route_uid: v.route_uid }})
  .then(rsp => {
    if(rsp.status == 200) stations.value = rsp.data.stations
  }).catch(() => stations.value = [])
}

axios.get('https://bus4u.fast-table.com/v1/get_routes')
// axios.get('https://bus4u.fast-table.com/v1/admin/get_routes_of_a_company', { params: {company_uid: user.companyUid }})
  .then(rsp => {
    if(rsp.status == 200) routes.value = rsp.data.routes
  }).catch(() => routes.value = [])
</script>

<style scoped>

</style>