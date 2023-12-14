<template>
  <v-app>
    <v-app-bar>
      <v-app-bar-nav-icon @click.stop="isNavOpen = !isNavOpen"></v-app-bar-nav-icon>
      <v-app-bar-title>
        <RouterLink :to="{ name: 'home' }">
          <LogoWide :fill="$vuetify.theme.current.colors.primary" :adjacent="$vuetify.theme.current.colors.adjacent" class="logo"/>
        </RouterLink>
      </v-app-bar-title>
      <template #append>
        <span>{{ user.lastName }}</span>
        <v-btn :title="user.email" icon="mdi-account-circle-outline" @click="router.push({ name: 'settings' })"></v-btn>
        <v-btn title="Logout" icon="mdi-logout" @click="signOut"></v-btn>
      </template>
    </v-app-bar>

    <v-navigation-drawer v-model="isNavOpen">
      <v-list color="primary-light" class="h-100 d-flex flex-column">
        <v-list-item prepend-icon="mdi-home" title="Home" value="home" :to="{ name: 'home' }"></v-list-item>
        <v-list-item prepend-icon="mdi-map-marker-outline" title="Stations" value="stations" :to="{ name: 'stations' }"></v-list-item>
        <v-list-item prepend-icon="mdi-bus" title="Routes" value="routes" :to="{ name: 'routes' }"></v-list-item>
        <v-list-item prepend-icon="mdi-timetable" title="Schedule" value="schedule" :to="{ name: 'schedule' }"></v-list-item>
        <v-list-item prepend-icon="mdi-account-group" title="Employees" value="employees" :to="{ name: 'employees' }"></v-list-item>
        <v-spacer></v-spacer>
        <v-list-item prepend-icon="mdi-cog-outline" title="Settings" value="settings" :to="{ name: 'settings' }"></v-list-item>
      </v-list>
    </v-navigation-drawer>

    <v-main>
      <div class="content">
        <slot></slot>
      </div>
      <div v-if="user.documents">
        <v-snackbar v-model="user.documents.show.road_taxes" timeout="-1" :close-on-content-click="true">
          <h3 class="font-weight-bold"> Document validity warning </h3>
          <p> The road tax will expire in the next two weeks for bus(es): </p>
          <p>{{ user.documents.road_taxes.join(', ') }}</p>
          <template v-slot:actions>
            <v-btn @click="() => {user.documents.show.road_taxes = false;}">
              Close
            </v-btn>
          </template>
        </v-snackbar>
        <v-snackbar v-model="user.documents.show.insurances" timeout="-1" :close-on-content-click="true">
          <h3 class="font-weight-bold"> Document validity warning </h3>
          <p> The insurance will expire in the next two weeks for bus(es): </p>
          <p>{{ user.documents.insurances.join(', ') }}</p>
          <template v-slot:actions>
            <v-btn @click="() => {user.documents.show.insurances = false;}">
              Close
            </v-btn>
          </template>
        </v-snackbar>
        <v-snackbar v-model="user.documents.show.technical_exams" timeout="-1" :close-on-content-click="true">
          <h3 class="font-weight-bold"> Document validity warning </h3>
          <p> The technical exam will expire in the next two weeks for bus(es): </p>
          <p class="text-center">{{ user.documents.technical_exams.join(', ') }}</p>
          <template v-slot:actions>
            <v-btn @click="() => {user.documents.show.technical_exams = false;}">
              Close
            </v-btn>
          </template>
        </v-snackbar>
      </div>
    </v-main>
  </v-app>
</template>

<script setup>
import { ref } from 'vue';
import { RouterLink } from 'vue-router';
import { userStore } from '@/stores/userStore';
import LogoWide from './LogoWide.vue';
import router from '../router';

const user = userStore()
const isNavOpen = ref(document.body.offsetWidth >= 1280)

function signOut() {
  user.signOut();
  router.replace({ name: 'login'});
}
</script>

<style scoped>
.content {
  padding: 15px;
}
.logo {
  height: 42px;
  vertical-align: middle;
}
.reset-bg{
  background: transparent;
}
@media (min-width: 640px) {
  .content {
    padding: 25px;
  }
}
</style>