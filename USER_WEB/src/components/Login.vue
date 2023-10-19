<template>
  <v-form validate-on="blur" @submit.prevent="onSubmit">
    <div class="inputs">
      <v-text-field label="Username" v-model="form.username" color="primary" :rules="validation"></v-text-field>
      <v-text-field label="Password" type="password" v-model="form.password" color="primary" :rules="validation"></v-text-field>
    </div>
    <RouterLink :to="{ name: 'register' }" class="link"> Not yet registered? </RouterLink>
    <v-btn type="submit" size="50" block color="primary"> Log In </v-btn>
    <v-btn type="reset" size="50" block color="primary" variant="outlined" :to="{ name: 'home' }"> Cancel </v-btn>
  </v-form>
</template>

<script setup>
import { reactive } from 'vue';
import { RouterLink } from 'vue-router';

const form = reactive({
  username: '',
  password: ''
})

const validation = [
  (v) => !!v || 'The field is required',
  (v) => v.length > 7 || 'The field must be at least 8 characters long'
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