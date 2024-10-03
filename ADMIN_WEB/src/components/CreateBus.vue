<template>
    <SectionTitle v-if="bus">
      Edit bus
      <template #description>
        Update existing bus
      </template>
    </SectionTitle>
  <SectionTitle v-else>
    Add bus
    <template #description>
      Create new bus
    </template>
  </SectionTitle>
  <v-form validate-on="blur" @submit.prevent="onSubmit" class="my-5">
    <v-container>
      <v-row justify="center">
        <v-col cols="12">
          <v-text-field label="Brand" v-model="form.brand" color="primary-light" :rules="name"></v-text-field>
        </v-col>
        <v-col cols="12" sm="6">
          <v-text-field label="License plate" v-model="form.license_plate" color="primary-light" :rules="license"></v-text-field>
        </v-col>
        <v-col cols="12" sm="6">
          <v-text-field label="Capacity" type="number" min="5" max="80" v-model="form.capacity" color="primary-light" :rules="required"></v-text-field>
        </v-col>
        <v-col cols="12" sm="6">
          <v-text-field label="Manufacturing date" type="month" v-model="form.manufacturing_year" color="primary-light" :rules="required"></v-text-field>
        </v-col>
        <v-col cols="12" sm="6">
          <v-text-field label="Road tax valid until" type="date" v-model="form.road_tax" color="primary-light" :rules="required"></v-text-field>
        </v-col>
        <v-col cols="12" sm="6">
          <v-text-field label="Insurance valid until" type="date" v-model="form.insurance" color="primary-light" :rules="required"></v-text-field>
        </v-col>
        <v-col cols="12" sm="6">
          <v-text-field label="Technical exam valid until" type="date" v-model="form.technical_exam" color="primary-light" :rules="required"></v-text-field>
        </v-col>
        <v-col cols="12">
          <p v-if="error" class="text-error text-center mb-2"> {{ error }} </p>
        </v-col>
        <v-col cols="6" sm="3">
          <v-btn v-if="bus" type="submit" size="40" block color="primary" :loading="isLoading"> Save </v-btn>
          <v-btn v-else type="submit" size="40" block color="primary" :loading="isLoading"> Create </v-btn>
        </v-col>
      </v-row>
    </v-container>
  </v-form>
</template>

<script setup>
import axios from 'axios';
import router from '@/router';
import { ref } from 'vue';
import { userStore } from '@/stores/userStore';
import SectionTitle from '@/components/SectionTitle.vue';

const props = defineProps(['bus'])
const user = userStore()
const isLoading = ref(false)
const error = ref('')

const form = ref({
  brand: null,
  license_plate: null,
  capacity: null,
  manufacturing_year: null,
  road_tax: null,
  technical_exam: null,
  insurance: null,
  company_uid: user.company_uid
})

const name = [
  (v) => !!v || 'The field is required',
  (v) => /^[\p{Lu}][-\p{L}\s]+$/u.test(v) || 'The field must be a valid brand'
]

const license = [
  (v) => !!v || 'The field is required',
  (v) => v.length > 6 || 'Too few characters'
]
const required = [
(v) => !!v || 'The field is required'
]

if(props.bus) {
  axios.get('https://api.bus4u.online/v1/admin/get_bus_by_id', { params: { bus_uid: props.bus.toUpperCase() }})
  .then(rsp => {
      form.value = rsp.data
      form.value.manufacturing_year = `${rsp.data.manufacturing_year}-01`
      form.value.road_tax = rsp.data.road_tax.substr(0, 10)
      form.value.insurance = rsp.data.insurance.substr(0, 10)
      form.value.technical_exam = rsp.data.technical_exam.substr(0, 10)
  }).catch(() => error.value = 'Bus not found')
}

async function onSubmit(event) {
  error.value = ''
  let response = await event;
  if(!response.valid) return
  isLoading.value = true
  if(props.bus) {
    let data = { brand: form.value.brand, license_plate: form.value.license_plate, capacity: form.value.capacity, manufacturing_year: form.value.manufacturing_year, road_tax: form.value.road_tax, technical_exam: form.value.technical_exam, insurance: form.value.insurance }
    axios.put('https://api.bus4u.online/v1/admin/update_bus', data, { params: { bus_uid: props.bus.toUpperCase() }})
    .then((rsp) => {
      if(rsp.status === 200) {
        router.replace({ name: 'buses' })
      } else {
        isLoading.value = false
      }
    }).catch((err) => {
      isLoading.value = false
      error.value = err.response.data.errors.full_messages[0]
    });
  } else {
    axios.post('https://api.bus4u.online/v1/admin/create_bus', form.value).then((rsp) => {
      if(rsp.status === 200) {
        router.replace({ name: 'buses' })
      } else {
        isLoading.value = false
      }
    }).catch((err) => {
      isLoading.value = false
      error.value = err.response.data.errors.full_messages[0]
    });
  }
}
</script>

<style scoped>

</style>