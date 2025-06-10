<template>
  <AppLayout>
    <div id="checkout">
      <!-- Checkout will insert the payment form here -->
    </div>
  </AppLayout>
</template>

<script setup>

import { loadStripe } from '@stripe/stripe-js';
import AppLayout from '../components/AppLayout.vue';
import { onMounted } from 'vue';
import { onBeforeUnmount } from 'vue';

const props = defineProps({
  client: {
    type: String,
    required: true
  }
});

let stripe = null;
let checkout = null;

async function initialize() {
  const fetchClientSecret = async () => props.client;
  checkout = await stripe.initEmbeddedCheckout({
    fetchClientSecret,
  });
  checkout.mount('#checkout');
}

onMounted(async () => {
  stripe = await loadStripe(import.meta.env.VITE_STRIPE_KEY);
  // Ensure the Stripe script is loaded before initializing
  if (window.Stripe && props.client) {
    initialize();
  } else {
    console.error('Stripe script not loaded');
  }
});

onBeforeUnmount(() => {
  if (checkout) checkout.destroy();
});
</script>

<style scoped></style>