<script setup lang="ts">
import { ref } from 'vue'
import { useAuthStore } from '@/stores/useAuthStore'
import { useRouter } from 'vue-router'

const router = useRouter()

const auth = useAuthStore()

const username = ref('admin@example.com')
const password = ref('password')
const error = ref('')

const onLoginClick = async () => {
  if (await auth.login(username.value, password.value)) {
    router.replace({ name: 'home' })
  } else {
    error.value = 'Invalid username or password'
  }
}
</script>

<template>
  <div v-if="auth.isAuthenticated">
    <p class="text-gray-700 text-lg mb-4 text-center">
      Logged in as: <strong>{{ auth.user?.email }}</strong>
    </p>
  </div>

  <div class="flex items-center justify-center h-screen bg-gray-100">
    <div class="w-full max-w-md bg-white p-8 rounded-lg shadow-lg">
      <h2 class="text-2xl font-bold text-center mb-6">Login</h2>
      <div class="mb-4">
        <label class="block text-gray-700 text-sm font-bold mb-2" for="email">
          Email
        </label>
        <input
          class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:ring-2 focus:ring-blue-500"
          id="email"
          type="email"
          placeholder="Email"
          v-model="username"
        />
      </div>
      <div class="mb-6">
        <label
          class="block text-gray-700 text-sm font-bold mb-2"
          for="password"
        >
          Password
        </label>
        <input
          class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 mb-3 leading-tight focus:outline-none focus:ring-2 focus:ring-blue-500"
          id="password"
          type="password"
          placeholder="Password"
          v-model="password"
        />
      </div>
      <div v-if="error" class="text-red-500 text-xs italic mb-4">
        {{ error }}
      </div>
      <div class="flex items-center justify-between">
        <button
          class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
          type="button"
          @click="onLoginClick"
        >
          Sign In
        </button>
      </div>
    </div>
  </div>
</template>
