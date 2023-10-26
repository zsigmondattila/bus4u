<template>
  <AppLayout>
    <SectionTitle>
      Plan your travel
      <!-- <template #description>
        Description
      </template> -->
    </SectionTitle>
    <v-form @submit.prevent="onSubmit">
      <v-container class="px-0">
        <v-row justify="center">
          <v-col cols="12" sm="6">
            <v-select :items="stations" label="From" color="primary" v-model="form.from" class="text-field" hide-details="auto"></v-select>
          </v-col>
          <v-col cols="12" sm="6">
            <v-select :items="stations" label="To" color="primary" v-model="form.to" class="text-field" hide-details="auto"></v-select>
          </v-col>
          <v-col cols="12" sm="6">
            <v-text-field label="Date" type="date" color="primary" v-model="form.date" class="text-field" hide-details="auto"></v-text-field>
          </v-col>
          <v-col cols="12" sm="6">
            <v-text-field label="Time" type="time" color="primary" v-model="form.time" class="text-field" hide-details="auto"></v-text-field>
          </v-col>
          <v-col cols="12" style="text-align: center;">
            <v-btn type="submit" color="primary"> Search </v-btn>
          </v-col>
        </v-row>
      </v-container>
    </v-form>
  </AppLayout>
</template>

<script setup>
import { ref, reactive } from 'vue';
import axios from 'axios';
import AppLayout from '@/components/AppLayout.vue';
import SectionTitle from '@/components/SectionTitle.vue';

const date = new Date();
const stations = ref(['Sapientia', 'Aleea Carpatii', 'Izvorul Rece', 'Combinat']);

const form = reactive({
  from: '',
  to: '',
  date: date.toLocaleDateString().replaceAll('. ', '-').slice(0, 10),
  time: date.toLocaleTimeString().slice(0, 5),
})

function onSubmit() {
  console.log(form);
}

axios.get('/stations').then((rsp) => rsp.json()).then((json) => stations = json.stations)
</script>

<style scoped>

</style>