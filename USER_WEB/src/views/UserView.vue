<template>
  <div class="container">
    <v-sheet class="sheet">
      <div class="logo">
        <h1> Bus4U </h1>
      </div>
      <Login v-if="isLogin"/>
      <Register v-else />
    </v-sheet>
  </div>
</template>

<script setup>
import Login from '@/components/Login.vue';
import Register from '@/components/Register.vue';

const props = defineProps(['isLogin'])
</script>

<style scoped>
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
    border-radius: 12px;
    min-width: 500px;
    box-shadow: 0px 3px 10px 2px darkgray;
  }
}
</style>