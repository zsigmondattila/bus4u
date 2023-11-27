<template>
  <div class="container">
    <v-sheet class="sheet">
      <div class="logo-container">
        <LogoWide :fill="$vuetify.theme.current.colors.primary" :adjacent="$vuetify.theme.current.colors.adjacent" class="logo"/>
      </div>
      <LoginPanel v-if="isLogin"/>
      <RegisterPanel v-else />
    </v-sheet>
  </div>
</template>

<script setup>
import LoginPanel from '@/components/LoginPanel.vue';
import RegisterPanel from '@/components/RegisterPanel.vue';
import LogoWide from '../components/LogoWide.vue';

defineProps(['isLogin'])
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
.logo-container {
  display: flex;
  justify-content: center;
  padding: 25px;
}
.logo {
  width: 300px;
}

@media screen and (min-width: 640px) {
  .sheet {

    min-width: 450px;
  }
}
</style>