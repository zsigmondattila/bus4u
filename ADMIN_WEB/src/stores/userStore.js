import { defineStore } from 'pinia'
import router from '../router'
import { ref } from 'vue'
import axios from 'axios'

export const userStore = defineStore('user', () => {
  const firstName = ref('')
  const lastName = ref('')
  const email = ref('')
  const company_uid = ref('')
  const documents = ref(null)

  const usr = sessionStorage.getItem('user')
  if(usr) signIn(JSON.parse(usr))

  function signIn(user) {
    firstName.value = user.firstname
    lastName.value = user.lastname
    email.value = user.email
    company_uid.value = user.company_uid
  }
  function signOut() {
    sessionStorage.removeItem('user')
    const auth = sessionStorage.getItem('auth')
    if(auth) {
      let data = JSON.parse(auth)
      axios.delete('https://bus4u.fast-table.com/admin/sign_out', { params: { 'uid': data.uid, 'client': data.client, 'access-token': data.accessToken}})
        .then(() => {
          firstName.value = ''
          lastName.value = ''
          email.value = ''
          company_uid.value = ''
          documents.value = null
          sessionStorage.removeItem('auth')
          router.replace({name: 'login'})
        })
        .catch((err) => console.error(err))
    } else {
      firstName.value = ''
      lastName.value = ''
      email.value = ''
      company_uid.value = ''
      documents.value = null
      router.replace({name: 'login'})
    }
  }
  function checkDocuments(company) {
    axios.get('https://bus4u.fast-table.com/v1/admin/document_validity_checker', { params: { company_uid: company }})
    .then(rsp => {
      documents.value = Object.assign(rsp.data, { show: {
        road_taxes: !!rsp.data.road_taxes,
        insurances: !!rsp.data.insurances,
        technical_exams: !!rsp.data.technical_exams
      }})
    }).catch(() => {
      documents.value = null
    })
  }
  return { firstName, lastName, email, company_uid, documents, signIn, signOut, checkDocuments }
  }
)