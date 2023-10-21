<template>
  <v-form validate-on="blur" @submit.prevent="onSubmit">
    <div class="inputs">
      <v-text-field label="Email" v-model="form.email" color="primary" :rules="email"></v-text-field>
      <v-text-field label="Password" type="password" v-model="form.password" color="primary" :rules="password"></v-text-field>
    </div>
    <RouterLink :to="{ name: 'register' }" class="link"> Not yet registered? </RouterLink>
    <v-btn type="submit" size="50" block color="primary"> Log In </v-btn>
  </v-form>
</template>

<script setup>
import axios from 'axios';
import router from '@/router';
import { userStore } from '@/stores/userStore';
import { reactive } from 'vue';
import { RouterLink } from 'vue-router';

const user = userStore()

const form = reactive({
  email: '',
  password: ''
})

const password = [
  (v) => !!v || 'The field is required',
  (v) => v.length > 7 || 'The field must be at least 8 characters long'
]
const email = [
  (v) => !!v || 'The field is required',
  (v) => /^[\S]+@[\S]+$/.test(v) || 'The field must be a valid email address'
]

async function onSubmit(event) {
  let response = await event;
  if(response.valid) {
    console.log(response);
    axios.post('/auth', form).then((rsp) => console.log(rsp.headers)).catch((e) => console.log(e.message));
    // axios.post('/auth', form).then((rsp) => {
    //   user.signIn(rsp.json(), rsp.headers)
    //   router.replace({ name: 'home'})
    // }).catch((e) => console.log(e.message));
  } else console.log('Validation failed');
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