<template>
  <div>
    <Login v-if="isLogin"/>
    <Register v-else />
  </div>
</template>

<script setup>
import Login from '@/components/Login.vue';
import Register from '@/components/Register.vue';

const props = defineProps(['isLogin'])
</script>

<style scoped>

</style>