import { defineStore } from 'pinia'
import { ref } from 'vue'
import axios from 'axios';

export const userStore = defineStore('user', () => {
  const firstName = ref('')
  const lastName = ref('')
  const email = ref('')
  const authorization = ref('')
  const uid = ref('')
  const client = ref('')
  const accessToken = ref('')

  function signIn(user, headers) {
    firstName.value = user.firstName
    lastName.value = user.lastName
    email.value = user.email
    authorization.value = headers.authorization
    uid.value = headers.uid
    client.value = headers.client
    accessToken.value = headers['access-token']
  }
  function signOut() {
    axios.delete('https://bus4u.fast-table.com/auth/sign_out', { params: { 'uid': uid.value, 'client': client.value, 'access-token': accessToken.value}})
      .then((rsp) => {
        console.log(rsp)
        firstName.value = ''
        lastName.value = ''
        email.value = ''
        authorization.value = ''
        uid.value = ''
        client.value = ''
        accessToken.value = ''
      })
      .catch((err) => console.error(err))
  }
  return { firstName, lastName, email, authorization, uid, client, accessToken, signIn, signOut }
})