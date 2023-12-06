<template>
  <AppLayout>
    <SectionTitle>
      Schedule
      <template #description>
        Edit timetable
      </template>
    </SectionTitle>
    <v-form v-model="mainForm.isValid" validate-on="submit" class="my-5">
      <v-container>
        <v-row justify="center">
          <v-col cols="12" sm="6">
            <v-autocomplete :items="routes" :item-props="getProps" label="Route" v-model="mainForm.route" class="text-field" hide-details="auto"  @update:modelValue="getStations"></v-autocomplete>
          </v-col>
          <v-col cols="12" sm="6">
            <v-autocomplete :items="stations" :item-props="getProps" label="Station" :disabled="!mainForm.route" v-model="mainForm.station" class="text-field" hide-details="auto" :error-messages="noStationError" :rules="required"></v-autocomplete>
          </v-col>
        </v-row>
      </v-container>
    </v-form>
    <div v-for="(elem, index) in timetable" :key="index">
      <v-form class="my-3" readonly>
        <v-container class="border">
          <v-row justify="center">
            <v-col cols="12">
              <v-combobox :items="days" label="Day(s)" v-model="elem.names" multiple hide-details="auto" density="comfortable"></v-combobox>
            </v-col>
            <v-col cols="12" sm="6">
              <v-text-field label="Fare" type="number" v-model="elem.fare" suffix="Lei"></v-text-field>toEdit
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
            <v-combobox :items="remainingDays" label="Day(s)" v-model="tempForm.names" multiple hide-details="auto" density="comfortable" :rules="dayRules"></v-combobox>
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
            <v-btn type="submit" color="primary" block> Add </v-btn>
          </v-col>
        </v-row>
      </v-container>
    </v-form>
    <v-container v-if="timetable.length">
      <v-row justify="center" justify-md="end">
        <v-col cols="12" md="3">
          <v-btn @click="deleteSchedule" block> Cancel editing </v-btn>
        </v-col>
        <v-col cols="12" md="3">
          <v-btn @click="sendSchedule" color="primary" block> Save schedule </v-btn>
        </v-col>
      </v-row>
    </v-container>
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
const noStationError = ref(null)

const routes = ref([])
const stations = ref([])
const timetable = ref([])
const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
let remainingDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']

const tempForm = ref({
  names: null,
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

const mainForm = reactive({
  route: null,
  station: null,
  isValid: null
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
  remainingDays = remainingDays.filter((v) => !tempForm.value.names.includes(v))
  tempForm.value = {
    names: null,
    fare: 0,
    departure_times: []
  }
}

function deleteTimetable(index) {
  console.log(timetable.value[index].names)
  remainingDays.push(...timetable.value[index].names)
  timetable.value.splice(index, 1)
}

function deleteSchedule() {
  noStationError.value = null
  timetable.value = []
  tempForm.value = {
    names: null,
    fare: 0,
    departure_times: []
  }
  remainingDays = days
  mainForm.value = {
    route: null,
    station: null,
    isValid: null
  }
}

function sendSchedule(){
  noStationError.value = null
  // if(!mainForm.isValid) {
  //   noStationError.value = ['Please select an option.']
  //   return
  // }
  timetable.value.forEach(schedule => {
    console.log(Object.assign(schedule, { route_uid: mainForm.route.route_uid }, { station_uid: mainForm.station.station_uid }));
  })
  deleteSchedule();
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