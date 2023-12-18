<template>
  <SectionTitle>
    Add employee
    <template #description>
      Create new employee account
    </template>
  </SectionTitle>
  <v-form validate-on="blur" @submit.prevent="onSubmit" class="my-5">
    <v-container>
      <v-row justify="center">
        <v-col cols="12" sm="6">
          <v-text-field label="First Name" v-model="form.firstname" color="primary-light" :rules="name"></v-text-field>
        </v-col>
        <v-col cols="12" sm="6">
          <v-text-field label="Last Name" v-model="form.lastname" color="primary-light" :rules="name"></v-text-field>
        </v-col>
        <v-col cols="12" sm="6">
          <v-text-field label="Email" type="email" v-model="form.email" color="primary-light" :rules="email"></v-text-field>
        </v-col>
        <v-col cols="12" sm="6">
          <v-select label="Role" v-model="form.role" color="primary-light" :items="roles" :rules="required"></v-select>
        </v-col>
        <v-col cols="12" sm="6">
          <v-text-field label="Password" type="password" v-model="form.password" color="primary-light" :rules="eightChars"></v-text-field>
        </v-col>
        <v-col cols="12" sm="6">
          <v-text-field label="Password confirmation" type="password" v-model="form.password_confirmation" color="primary-light" :rules="confirmation"></v-text-field>
        </v-col>
        <v-col cols="12">
          <p v-if="error" class="text-error text-center mb-2"> {{ error }} </p>
        </v-col>
        <v-col cols="6" sm="3">
          <v-btn type="submit" size="40" block color="primary" :loading="isLoading"> Create </v-btn>
        </v-col>
      </v-row>
    </v-container>
  </v-form>
</template>

<script setup>
import axios from 'axios';
import router from '@/router';
import { reactive, ref } from 'vue';
import { userStore } from '@/stores/userStore';
import SectionTitle from '../components/SectionTitle.vue';

const user = userStore()
const isLoading = ref(false)
const error = ref('')

const form = reactive({
  firstname: null,
  lastname: null,
  email: null,
  role: null,
  company_uid: user.company_uid,
  password: null,
  password_confirmation: null
})

const roles = ['admin', 'driver']

const eightChars = [
  (v) => !!v || 'The field is required',
  (v) => v.length > 7 || 'The field must be at least 8 characters long',
  (v) => /^\S+$/.test(v) || 'The field cannot contain whitespace characters'
]

const email = [
  (v) => !!v || 'The field is required',
  (v) => /^[\S]+@[\S]+$/.test(v) || 'The field must be a valid email address'
]

const name = [
  (v) => !!v || 'The field is required',
  (v) => /^[\p{Lu}][-\p{L}\s]+$/u.test(v) || 'The field must be a valid name'
]

const confirmation = [
  (v) => !!v || 'The field is required',
  (v) => v == form.password || 'Passwords must be the same'
]
const required = [
(v) => !!v || 'The field is required'
]

async function onSubmit(event) {
  error.value = ''
  let response = await event;
  if(!response.valid) return
  isLoading.value = true
  axios.post('https://bus4u.fast-table.com/admin', form).then((rsp) => {
    if(rsp.status === 200) {
      router.replace({ name: 'employees' })
    } else {
      isLoading.value = false
    }
  }).catch((err) => {
    isLoading.value = false
    error.value = err.response.data.errors[0]
  });
}
</script>

<style scoped>

</style>