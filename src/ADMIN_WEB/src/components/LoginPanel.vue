<template>
  <v-form validate-on="blur" @submit.prevent="onSubmit">
    <div class="inputs">
      <v-text-field label="Email" v-model="form.email" color="primary" :rules="email" :hide-details="false"></v-text-field>
      <v-text-field label="Password" type="password" v-model="form.password" color="primary" :rules="password" :error-messages="errors" :hide-details="false"></v-text-field>
    </div>
    <v-btn type="submit" size="40" block color="primary"> Log In </v-btn>
  </v-form>
</template>

<script setup>
import axios from 'axios';
import router from '@/router';
import { userStore } from '@/stores/userStore';
import { reactive, ref } from 'vue';

const user = userStore()

const errors = ref([])
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
  errors.value = []
  let response = await event;
  if(response.valid) {
    axios.post('https://bus4u.fast-table.com/admin/sign_in', form).then((rsp) => {
      if(rsp.status == 200 && rsp.data.data.uid) {
        sessionStorage.setItem('auth', JSON.stringify({ uid: rsp.headers.uid, accessToken: rsp.headers['access-token'], client: rsp.headers.client, authorization: rsp.headers.authorization }))
        user.signIn(rsp.data.data)
        router.replace({ name: 'home' })
      } else {
        errors.value = ['Login failed'];
      }
    }).catch((e) => {
      if(e.response) errors.value = e.response.data.errors
    });
  }
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