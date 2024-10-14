<script setup lang="ts">
import { useAuthStore } from '@/stores/useAuthStore'

import { useRouter } from 'vue-router'

const auth = useAuthStore()

const router = useRouter()

const onLoginClick = async () => {
  router.push({ name: 'login' })
}

const onLogoutClick = async () => {
  await auth.logout()
  router.push({ name: 'home' })
}
</script>

<template>
  <main>
    <div class="flex items-center justify-center h-screen bg-gray-100">
      <div class="w-full max-w-md bg-white p-8 rounded-lg shadow-lg">
        <h2 class="text-2xl font-bold text-center mb-6">Welcome</h2>

        <div v-if="auth.isAuthenticated">
          <p class="text-gray-700 text-lg mb-4 text-center">
            Logged in as: <strong>{{ auth.user?.email }}</strong>
          </p>
          <button
            @click="onLogoutClick"
            class="bg-red-500 hover:bg-red-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline w-full"
          >
            Logout
          </button>
        </div>

        <div v-else>
          <p class="text-gray-700 text-lg mb-4 text-center">
            You are not logged in.
          </p>
          <button
            @click="onLoginClick"
            class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline w-full"
          >
            Login
          </button>
        </div>
      </div>
    </div>
  </main>
</template>
