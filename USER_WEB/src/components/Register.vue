<template>
  <v-form validate-on="blur" @submit.prevent="onSubmit">
    <div class="inputs">
      <v-text-field label="First Name" v-model="form.firstname" color="primary" :rules="name"></v-text-field>
      <v-text-field label="Last Name" v-model="form.lastname" color="primary" :rules="name"></v-text-field>
      <v-text-field label="Username" type="username" v-model="form.username" color="primary" :rules="eightChars"></v-text-field>
      <v-text-field label="Email" type="email" v-model="form.email" color="primary" :rules="email"></v-text-field>
      <v-text-field label="Password" type="password" v-model="form.password" color="primary" :rules="eightChars"></v-text-field>
      <v-text-field label="Password confirmation" type="password" v-model="form.password_confirmation" color="primary" :rules="confirmation"></v-text-field>
    </div>
    <RouterLink :to="{ name: 'login' }" class="link"> Already registered? </RouterLink>
    <v-btn type="submit" size="50" block color="primary"> Register </v-btn>
    <v-btn type="reset" size="50" block color="primary" variant="outlined" :to="{ name: 'home' }"> Cancel </v-btn>
  </v-form>
</template>

<script setup>
import { reactive } from 'vue';
import { RouterLink } from 'vue-router';

const form = reactive({
  firstname: '',
  lastname: '',
  username: '',
  email: '',
  password: '',
  password_confirmation: ''
})

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
  (v) => /^[A-Z][-a-zA-Z\s]+$/.test(v) || 'The field must be a valid name'
]

const confirmation = [
  (v) => !!v || 'The field is required',
  (v) => v == form.password || 'Passwords must be the same'
]

async function onSubmit(event) {
  let response = await event;
  if(response.valid) console.log(form);
}
</script>

<style scoped>
button {
  margin: 12px 0;
}
.link{
  display: block;
  text-align: center;
  color: revert;
}
.inputs {
  margin: 20px 0;
}
</style>