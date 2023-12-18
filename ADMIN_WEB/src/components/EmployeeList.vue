<template>
  <SectionTitle>
    Manage employees
    <template #description>
      Create or delete employee accounts inside your company
    </template>
  </SectionTitle>
  <v-container>
    <v-row>
      <v-col v-for="employee in employees" :key="employee.uid" cols="12" sm="6" lg="3" xl="2">
        <EmployeeCard :employee="employee" @delete="deleteEmployee(employee)"/>
      </v-col>
      <v-col cols="12" sm="6" lg="3" xl="2">
        <v-card :to="{name: 'create-employee'}" height="100%" class="d-flex flex-column text-center" min-width="200">
          <v-sheet class="text-center" color="adjacent">
            <v-icon size="120" icon="mdi-plus-circle-outline"></v-icon>
          </v-sheet>
          <v-spacer></v-spacer>
          <v-card-title> Add new </v-card-title>
          <v-spacer></v-spacer>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
import { ref } from 'vue';
import axios from 'axios';
import EmployeeCard from '../components/EmployeeCard.vue';
import SectionTitle from './SectionTitle.vue';
import { userStore } from '../stores/userStore';

const user = userStore()

const employees = ref([])

function deleteEmployee(employee) {
  console.log(employee.email);
  axios.delete('https://bus4u.fast-table.com/v1/admin/delete_driver', { params: { company_uid: user.company_uid, driver: employee.uid }}) // ???
  .then(rsp => {
    employees.value = rsp.data
  }).catch(err => console.log(err))
}

axios.get('https://bus4u.fast-table.com/v1/admin/list_of_drivers', { params: { company_uid: user.company_uid }})
  .then(rsp => {
    console.log(rsp.data);
    employees.value = rsp.data
  }).catch(err => console.log(err))
</script>

<style scoped>

</style>