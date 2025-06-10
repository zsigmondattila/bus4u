import { createRouter, createWebHistory } from "vue-router";
import HomeView from "../views/HomeView.vue";
import UserView from "../views/UserView.vue";
import ScheduleView from "../views/ScheduleView.vue";
import CheckoutView from "../views/CheckoutView.vue";
import StationsView from "../views/StationsView.vue";
import LiveMapView from "../views/LiveMapView.vue";
import TicketsView from "../views/TicketsView.vue";
import AboutView from "../views/AboutView.vue";

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: "/",
      name: "home",
      component: HomeView,
      alias: "/home",
      props: (route) => ({ session: route.query.session_id }),
    },
    {
      path: "/login",
      name: "login",
      component: UserView,
      props: { isLogin: true },
    },
    {
      path: "/register",
      name: "register",
      component: UserView,
      props: { isLogin: false },
    },
    {
      path: "/checkout",
      name: "checkout",
      component: CheckoutView,
      props: (route) => ({ client: route.query.client }),
    },
    {
      path: "/schedule",
      name: "schedule",
      component: ScheduleView,
    },
    {
      path: "/stations",
      name: "stations",
      component: StationsView,
    },
    {
      path: "/live",
      name: "live",
      component: LiveMapView,
    },
    {
      path: "/about",
      name: "about",
      component: AboutView,
    },
    {
      path: "/tickets",
      name: "tickets",
      component: TicketsView,
    },
    {
      path: "/:notFound(.*)",
      name: "notFound",
      component: HomeView,
    },
  ],
});

export default router;
