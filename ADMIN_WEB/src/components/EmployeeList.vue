<template>
  <SectionTitle>
    Manage employees
    <template #description>
      Create or delete employee accounts inside your company
    </template>
  </SectionTitle>
  <v-container>
    <v-row>
      <v-col v-for="employee in employees" :key="employee.uid" cols="12" sm="6" md="4" lg="3" xl="2">
        <EmployeeCard :employee="employee" @delete="deleteEmployee(employee)" @edit="editEmployee(employee)"/>
      </v-col>
      <v-col cols="12" sm="6" md="4" lg="3" xl="2">
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
  <v-snackbar v-model="isDeleted">
    Employee deleted successfully
  </v-snackbar>
  <v-snackbar v-model="error">
    Operation failed
  </v-snackbar>
</template>

<script setup>
import { ref } from 'vue';
import axios from 'axios';
import router from '../router';
import EmployeeCard from '../components/EmployeeCard.vue';
import SectionTitle from './SectionTitle.vue';
import { userStore } from '../stores/userStore';

const user = userStore()
const employees = ref([])
const isDeleted = ref(false)
const error = ref(false)

function deleteEmployee(employee) {
  axios.delete('https://bus4u.fast-table.com/v1/admin/delete_driver', { params: { company_uid: user.company_uid, admin_uid: employee.uid }})
  .then(() => {
    isDeleted.value = true
    axios.get('https://bus4u.fast-table.com/v1/admin/list_of_drivers', { params: { company_uid: user.company_uid }})
      .then(rsp => {
        employees.value = rsp.data
      }).catch(() => employees.value = [])
  }).catch(() => error.value = true)
}

function editEmployee(employee) {
  router.push({ name: 'edit-employee', params: { employee: employee.uid.match(/[^@]+/)[0] }})
}

axios.get('https://bus4u.fast-table.com/v1/admin/list_of_drivers', { params: { company_uid: user.company_uid }})
  .then(rsp => {
    employees.value = rsp.data
  }).catch(() => employees.value = [])
</script>

<style scoped>

</style>