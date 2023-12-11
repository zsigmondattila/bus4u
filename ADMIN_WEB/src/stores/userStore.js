import { defineStore } from 'pinia'
import router from '../router'
import { ref } from 'vue'
import axios from 'axios'

export const userStore = defineStore('user', () => {
  const firstName = ref('')
  const lastName = ref('')
  const email = ref('')
  const companyUid = ref('')

  const usr = sessionStorage.getItem('user')
  if(usr) signIn(JSON.parse(usr))

  function signIn(user) {
    firstName.value = user.firstname
    lastName.value = user.lastname
    email.value = user.email
    companyUid.value = user.company_uid
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
          companyUid.value = ''
          sessionStorage.removeItem('auth')
          router.replace({name: 'login'})
        })
        .catch((err) => console.error(err))
    } else {
      firstName.value = ''
      lastName.value = ''
      email.value = ''
      companyUid.value = ''
      router.replace({name: 'login'})
    }
  }
  return { firstName, lastName, email, companyUid, signIn, signOut }
  }
)