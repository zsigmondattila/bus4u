<template>
  <AppLayout>
    <SectionTitle>
      Schedule
      <template #description>
        Select a route and a start station to add/edit timetables
      </template>
    </SectionTitle>
    <v-form class="my-5">
      <v-container>
        <v-row justify="center">
          <v-col cols="12" lg="4">
            <v-autocomplete :items="routes" :item-props="getProps" label="Route" name="route" v-model="mainForm.route"
              class="text-field" hide-details="auto" :error-messages="noStationError" @update:modelValue="getStations"
              auto-select-first></v-autocomplete>
          </v-col>
          <v-col cols="12" sm="6" lg="4">
            <v-autocomplete :items="stations" :item-props="getProps" label="From station" name="start"
              :disabled="!mainForm.route" v-model="mainForm.station" class="text-field" hide-details="auto"
              :error-messages="noStationError" @update:modelValue="getTimetable" auto-select-first></v-autocomplete>
          </v-col>
          <v-col cols="12" sm="6" lg="4">
            <v-text-field label="To station" name="destination" :disabled="!mainForm.route" readonly v-model="toStation"
              class="text-field" hide-details="auto"></v-text-field>
          </v-col>
        </v-row>
      </v-container>
    </v-form>
    <div v-for="(elem, index) in timetable" :key="index">
      <v-form class="my-3" disabled>
        <v-container class="border">
          <v-row justify="center" dense>
            <v-col cols="12">
              <v-combobox :items="days" label="Day(s)" v-model="elem.names" multiple hide-details="auto"
                density="comfortable" auto-select-firts></v-combobox>
            </v-col>
            <v-col cols="12" sm="6">
              <v-text-field label="Fare" type="number" v-model="elem.fare" suffix="Lei"></v-text-field>
            </v-col>
            <v-col cols="12" sm="6">
              <v-text-field label="Time" type="time">
                <template #append>
                  <v-btn disabled class="h-100"> Add </v-btn>
                </template>
              </v-text-field>
            </v-col>
            <v-col cols="12" md="9" xl="10">
              <v-chip v-for="(time, index) in elem.departure_times" :key="index" class="mr-2 mb-2">{{ time }}</v-chip>
            </v-col>
            <v-col cols="6" md="3" xl="2">
              <v-btn color="red-darken-4" block @click="deleteTimetable(index)" class="del-btn"> Delete </v-btn>
            </v-col>
          </v-row>
        </v-container>
      </v-form>
    </div>
    <v-form v-if="remainingDays.length" :disabled="!mainForm.station" class="my-3" @submit.prevent="saveTimetable"
      validate-on="submit" @reset="resetTimetable">
      <v-container class="border bg-grey-darken-4">
        <v-row justify="center">
          <v-col cols="12" lg="10" order="0">
            <v-combobox :items="remainingDays" label="Day(s)" name="days" v-model="tempForm.names" multiple
              hide-details="auto" density="comfortable" :rules="dayRules" hint="Departure days"></v-combobox>
          </v-col>
          <v-col cols="12" sm="6" lg="5" order="1" order-lg="3">
            <v-text-field label="Fare" name="fare" type="number" min="0" v-model="tempForm.fare" suffix="Lei"
              :rules="positive" :hint="fareHint"></v-text-field>
          </v-col>
          <v-col cols="12" sm="6" lg="5" order="2" order-lg="4">
            <v-text-field ref="timeInput" label="Time" name="time" v-model="tempTime" type="time"
              @keydown.enter.prevent="addTimeToArray" :error-messages="noTimesError" :hint="timeHint">
              <template #append>
                <v-btn @click="addTimeToArray" class="h-100"> Add time </v-btn>
              </template>
            </v-text-field>
          </v-col>
          <v-col cols="12" order="3" order-lg="6">
            <v-chip v-for="(time, index) in tempForm.departure_times" :key="time" closable
              @click:close="deleteTimeFromArray(index)" class="mr-2 mb-2">{{ time }}</v-chip>
          </v-col>
          <v-col cols="6" md="3" lg="2" order="4" order-lg="2">
            <v-btn type="reset" color="red" variant="outlined" block> Clear </v-btn>
          </v-col>
          <v-col cols="6" md="3" lg="2" order="5" order-lg="5">
            <v-btn type="submit" color="primary" block> Save day(s) </v-btn>
          </v-col>
        </v-row>
      </v-container>
    </v-form>
    <v-container>
      <v-row justify="center" justify-md="end">
        <v-col cols="12" sm="6" md=3 xl="2">
          <v-btn @click="deleteSchedule" block> Cancel editing </v-btn>
        </v-col>
        <v-col cols="12" sm="6" md="3" xl=2>
          <v-btn @click="sendSchedule" color="primary" block :disabled="tempForm.names.length > 0"> Save schedule
          </v-btn>
        </v-col>
      </v-row>
    </v-container>
    <v-snackbar v-model="notification.show">
      {{ notification.message }}
    </v-snackbar>
  </AppLayout>
</template>

<script setup>
import { computed, reactive, ref } from 'vue';
import axios from 'axios';
import { userStore } from '../stores/userStore';
import AppLayout from '../components/AppLayout.vue';
import SectionTitle from '../components/SectionTitle.vue';

const user = userStore()
const notification = ref({
  show: false,
  message: ''
})
const timeInput = ref(null)
const noTimesError = ref(null)
const noStationError = ref(null)

const routes = ref([])
const stations = ref([])
const timetable = ref([])
const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']

const remainingDays = computed(() => {
  let arr = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
  timetable.value.forEach(elem => {
    elem.names.forEach(name => {
      let i = arr.indexOf(name)
      if (i > -1) arr.splice(i, 1)
    })
  })
  return arr
})
const toStation = computed(() => {
  if (!mainForm.station) return null
  for (let i = 0; i < stations.value.length; i++) {
    if (mainForm.station.station_uid == stations.value[i].station_uid) {
      if (i + 1 == stations.value.length) return stations.value[0].name
      else return stations.value[i + 1].name
    }
  }
  return null
})
const fareHint = computed(() => {
  return mainForm.station ? `Price between ${mainForm.station.name} - ${toStation.value}` : 'Price'
})
const timeHint = computed(() => {
  return mainForm.station ? `Departure times from ${mainForm.station.name}` : ''
})

const tempForm = ref({
  names: [],
  fare: '0',
  departure_times: []
})
const tempTime = ref('')

const dayRules = [
  (v) => !!v.length || 'Please select at least one day!'
]
const positive = [
  (v) => /[0-9]+/.test(v) || 'This field must be a number!',
  (v) => v >= 0 || 'This field must be positive!'
]

const mainForm = reactive({
  route: null,
  station: null
})

function addTimeToArray() {
  if (!tempTime.value) return
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
  if (!tempForm.value.departure_times.length) {
    noTimesError.value = 'Please add at least one departure time.'
    return
  }
  timetable.value.push(tempForm.value)
  tempForm.value = {
    names: [],
    fare: '0',
    departure_times: []
  }
}

function resetTimetable() {
  tempForm.value.departure_times = []
  noTimesError.value = []
}

function deleteTimetable(index) {
  timetable.value.splice(index, 1)
}

function deleteSchedule() {
  noStationError.value = []
  timetable.value = []
  tempForm.value = {
    names: [],
    fare: '0',
    departure_times: []
  }
  mainForm.route = null
  mainForm.station = null
}

function sendSchedule() {
  noStationError.value = []
  if (!mainForm.station) {
    noStationError.value = ['Please select an option.']
    return
  }
  axios.delete('/v1/admin/delete_timetables_from_route', { params: { route_uid: mainForm.route.route_uid, station_uid: mainForm.station.station_uid } })
    .then(() => {
      timetable.value.forEach(async (schedule) => {
        let data = Object.assign(schedule, { route_uid: mainForm.route.route_uid }, { station_uid: mainForm.station.station_uid });
        await axios.post('/v1/admin/add_timetable_to_route', data)
        mainForm.route = null
        mainForm.station = null
      })
      notification.value.message = 'Schedule saved successfully'
      notification.value.show = true
      deleteSchedule();
    })
    .catch(() => {
      notification.value.message = 'Something went wrong'
      notification.value.show = true
    })
}

function getProps(route) {
  return { title: route.name, value: route }
}

function getStations(v) {
  mainForm.station = null
  axios.get('/v1/get_stations_of_a_route', { params: { route_uid: v.route_uid } })
    .then(rsp => {
      if (rsp.status == 200) stations.value = rsp.data.stations
    }).catch(() => stations.value = [])
}

function getTimetable() {
  axios.get('/v1/get_departure_times_for_station_in_route', { params: { route_uid: mainForm.route.route_uid, station_uid: mainForm.station.station_uid } })
    .then(rsp => {
      if (rsp.status == 200) {
        timetable.value = []
        rsp.data.forEach(elem => {
          timetable.value.push({ names: [elem.name], fare: elem.fare, departure_times: elem.departure_times })
        })
      }
    }).catch(() => timetable.value = [])
}

axios.get('/v1/admin/get_routes_of_a_company', { params: { company_uid: user.company_uid } })
  .then(rsp => {
    if (rsp.status == 200) routes.value = rsp.data.routes
  }).catch(() => routes.value = [])
</script>

<style scoped>
.v-btn:not(.del-btn) {
  height: 50px;
}
</style>