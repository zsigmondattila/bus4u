import { createRouter, createWebHistory } from 'vue-router'
import axios from 'axios'
import HomeView from '../views/HomeView.vue'
import LoginView from '../views/LoginView.vue'
import ElementsView from '../views/ElementsView.vue'
import ScheduleView from '../views/ScheduleView.vue'
import StationsView from '../views/StationsView.vue'
import RoutesView from '../views/RoutesView.vue'
import CreateEmployee from '@/components/CreateEmployee.vue'
import EmployeeList from '@/components/EmployeeList.vue'
import CreateBus from '@/components/CreateBus.vue'
import BusList from '@/components/BusList.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/home',
      name: 'home',
      component: HomeView
    },
    {
      path: '/',
      name: 'login',
      component: LoginView
    },
    {
      path: '/schedule',
      name: 'schedule',
      component: ScheduleView
    },
    {
      path: '/routes',
      name: 'routes',
      component: RoutesView
    },
    {
      path: '/stations',
      name: 'stations',
      component: StationsView
    },
    {
      path: '/employees',
      component: ElementsView,
      children: [
        { path: '', name: 'employees', component: EmployeeList },
        { path: ':employee', name: 'edit-employee', component: CreateEmployee, props: true },
        { path: 'create', name: 'create-employee', component: CreateEmployee }
      ]
    },
    {
      path: '/buses',
      component: ElementsView,
      children: [
        { path: '', name: 'buses', component: BusList },
        { path: ':bus', name: 'edit-bus', component: CreateBus, props: true },
        { path: 'create', name: 'create-bus', component: CreateBus }
      ]
    },
    {
      path: '/:notFound(.*)',
      name: 'notFound',
      component: HomeView
    }
  ]
})

router.beforeEach((to) => {
  if(to.name !== 'login') {
    const sessionData = sessionStorage.getItem('auth')
    if(sessionData) {
      const auth = JSON.parse(sessionData)
      return axios.get('https://bus4u.fast-table.com/admin/validate_token', { params: { 'uid': auth.uid, 'client': auth.client, 'access-token': auth.accessToken}})
        .then(rsp => {
          if(rsp.status == 200){
            sessionStorage.setItem('auth', JSON.stringify({ uid: rsp.headers.uid, accessToken: rsp.headers['access-token'], client: rsp.headers.client }))
            sessionStorage.setItem('user', JSON.stringify(rsp.data.data))
            axios.defaults.headers.common['Authorization'] = rsp.headers.authorization;
          }
        }).catch(() => { return { name: 'login' }})
    } else return { name: 'login' }
  }
})

export default router
