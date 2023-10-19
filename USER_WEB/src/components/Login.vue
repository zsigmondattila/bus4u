<template>
  <div class="container">
    <v-sheet class="sheet">
      <div class="logo">
        <h1> Bus4U </h1>
      </div>
      <v-form validate-on="blur" @submit.prevent="onSubmit">
        <div class="inputs">
          <v-text-field label="Username" v-model="form.username" color="primary" :rules="validation"></v-text-field>
          <v-text-field label="Password" type="password" v-model="form.password" color="primary" :rules="validation"></v-text-field>
        </div>
        <RouterLink :to="{ name: 'register' }" class="link"> Not yet registered? </RouterLink>
        <v-btn type="submit" size="50" block color="primary"> Log In </v-btn>
        <v-btn type="reset" size="50" block color="primary" variant="outlined" :to="{ name: 'home' }"> Cancel </v-btn>
      </v-form>
    </v-sheet>
  </div>
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
  color: revert;
}
.inputs {
  margin: 20px 0;
}
.container {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  height: 100vh;
}
.sheet {
  padding: 25px;
  height: fit-content;
  min-width: 100%;
}
.logo {
  display: flex;
  justify-content: center;
  padding: 25px;
}

@media screen and (min-width: 640px) {
  .sheet {
    padding: 40px;
    border-radius: 12px;
    min-width: 500px;
    box-shadow: 0px 3px 10px 2px darkgray;
  }
}
</style>