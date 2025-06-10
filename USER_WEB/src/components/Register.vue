<template>
  <v-form validate-on="blur" @submit.prevent="onSubmit">
    <div v-if="hideOTP" class="inputs">
      <v-text-field label="First Name" name="firstname" v-model="form.firstname" color="primary"
        :rules="name"></v-text-field>
      <v-text-field label="Last Name" name="lastname" v-model="form.lastname" color="primary"
        :rules="name"></v-text-field>
      <v-text-field label="Email" name="email" type="email" v-model="form.email" color="primary"
        :rules="email"></v-text-field>
      <v-text-field label="Password" name="password" type="password" v-model="form.password" color="primary"
        :rules="eightChars"></v-text-field>
      <v-text-field label="Password confirmation" name="password-confirm" type="password"
        v-model="form.password_confirmation" color="primary" :rules="confirmation"></v-text-field>
      <p v-if="error" class="text-error text-center mb-2"> {{ error }} </p>
    </div>
    <div v-else class="text-center">
      <div class="my-5">
        <h2> We sent a verification code to: </h2>
        <h4 class="text-primary"> {{ form.email }} </h4>
        <br>
      </div>
      <p> Type here the code from the email: </p>
      <v-otp-input length="4" v-model="code" :error="!!error" @keydown.enter="checkCode"></v-otp-input>
      <p v-if="error" class="text-error text-center mb-2"> {{ error }} </p>
    </div>
    <RouterLink :to="{ name: 'login' }" class="link"> Already registered? </RouterLink>
    <v-btn v-if="hideOTP" type="submit" size="40" :loading="isLoading" block color="primary"> Register </v-btn>
    <v-btn v-else size="40" :loading="isLoading" block color="primary" @click="checkCode"> Send </v-btn>
    <v-btn type="reset" size="40" block color="primary" variant="outlined" :to="{ name: 'home' }"> Cancel </v-btn>
  </v-form>
</template>

<script setup>
import axios from 'axios';
import router from '@/router';
import { reactive, ref } from 'vue';
import { RouterLink } from 'vue-router';
import { userStore } from '@/stores/userStore';

const user = userStore()
const isLoading = ref(false)
const hideOTP = ref(true)
const error = ref('')

const code = ref('')
const form = reactive({
  firstname: '',
  lastname: '',
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
  (v) => /^[\p{Lu}][-\p{L}\s]+$/u.test(v) || 'The field must be a valid name'
]

const confirmation = [
  (v) => !!v || 'The field is required',
  (v) => v == form.password || 'Passwords must be the same'
]

async function onSubmit(event) {
  error.value = ''
  let response = await event;
  if (response.valid) {
    isLoading.value = true
    axios.post('/v1/send_verification_email', { user_email: form.email })
      .then(rsp => {
        if (rsp.status == 200) {
          hideOTP.value = false
          isLoading.value = false
        }
      }).catch(e => {
        if (e.response) error.value = e.response.data.error;
        else error.value = e.message;
        isLoading.value = false
      });
  }
}

async function checkCode() {
  error.value = ''
  isLoading.value = true;
  axios.get('/v1/verify_code_email', { params: { user_email: form.email, verification_code: code.value } })
    .then(rsp => {
      if (rsp.status == 200) sendForm();
      else {
        isLoading.value = false;
      }
    }).catch(e => {
      if (e.response) error.value = e.response.data.error;
      else error.value = e.message;
      isLoading.value = false;
    });
}

async function sendForm() {
  axios.post('/auth', form).then((rsp) => {
    if (rsp.data.data.uid) {
      router.replace({ name: 'home' })
      user.signIn(rsp.data.data, rsp.headers)
    } else {
      isLoading.value = false;
    }
  }).catch((e) => {
    if (e.response) error.value = e.response.data.error;
    isLoading.value = false;
  });
}
</script>

<style scoped>
button {
  margin: 12px 0;
}

.link {
  display: block;
  text-align: center;
  color: revert;
}

.inputs {
  margin: 15px 0;
}
</style>