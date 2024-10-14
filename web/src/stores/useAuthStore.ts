import { defineStore } from 'pinia'

import { computed, ref } from 'vue'
import { useLocalStorage } from '@vueuse/core'
import API, { setUnauthorizedHandler } from '@/services/api'
import * as Auth from '@/services/auth'

export type Token = Auth.Token

export interface UserData {
  email: string
}

export interface AuthData {
  token?: Token
}

const REAUTH_TIMEOUT_MS = 60 * 60 * 12 * 1000 // 12 hours in milliseconds

export const useAuthStore = defineStore('auth', () => {
  const auth = useLocalStorage('auth', {} as AuthData)
  const isLoading = ref<boolean>(true)
  const user = ref<UserData | null>(null)
  const renewTimer = ref<number | null>(null)

  /**
   * Schedules a token renewal if necessary.
   */
  const startRenewalTimer = () => {
    if (renewTimer.value) {
      clearTimeout(renewTimer.value)
    }

    renewTimer.value = window.setTimeout(async () => {
      await handleTokenRenewal()
    }, REAUTH_TIMEOUT_MS)
  }

  /**
   * Clears the token and any scheduled renewals.
   */
  const clearSession = () => {
    if (renewTimer.value) clearTimeout(renewTimer.value)
    auth.value.token = undefined
    user.value = null
  }

  /**
   * Tries to renew the token using the refresh token.
   * If successful, restarts the renewal timer.
   */
  const handleTokenRenewal = async (): Promise<boolean> => {
    if (!auth.value.token) return false

    try {
      const newToken = await Auth.refreshToken(auth.value.token)
      auth.value.token = newToken
      startRenewalTimer() // Schedule next renewal
      return true
    } catch (error) {
      clearSession()
      console.error('Failed to renew token:', error)
      return false
    }
  }

  /**
   * Handles login by authenticating with username and password,
   * storing the token and starting the renewal timer.
   */
  const login = async (
    username: string,
    password: string,
  ): Promise<boolean> => {
    try {
      const token = await Auth.login(username, password)
      auth.value.token = token
      await initializeSession() // Initialize user session
      startRenewalTimer() // Start automatic token renewal
      return true
    } catch (error) {
      return false
    }
  }

  /**
   * Handles user logout by revoking the token and clearing the session.
   */
  const logout = async (): Promise<void> => {
    if (!auth.value.token) return

    try {
      await Auth.revokeToken(auth.value.token)
      clearSession()
    } catch (error) {
      console.error('Failed to logout:', error)
    }
  }

  /**
   * Attempts to restore the user session using a valid access token.
   * Optionally tries to renew the token if it is invalid or expired.
   */
  const initializeSession = async (attemptTokenRenewal: boolean = false) => {
    if (!auth.value.token) return

    API.setAuthToken(auth.value.token.accessToken)

    try {
      const response = await API.accounts.showSettings()

      user.value = {
        email: response.data.data!.email,
      }
      isLoading.value = false
    } catch (error) {
      console.warn('Session restoration failed:', error)

      // Try renewing the token if the session could not be restored
      if (attemptTokenRenewal) {
        const tokenRenewed = await handleTokenRenewal()
        if (tokenRenewed) {
          await initializeSession(false) // Retry session initialization
        }
      } else {
        clearSession() // If no renewal is allowed, clear the session
      }
    }
  }

  setUnauthorizedHandler(async () => {
    if (!auth.value.token) return false

    console.warn('Unauthorized request detected, cleaning up session...')
    auth.value.token = undefined
    user.value = null

    return false
  })

  /**
   * Automatically attempts to restore the session on store initialization.
   */
  if (auth.value.token) {
    initializeSession(true) // Attempt session restoration on start, with token renewal
  } else {
    isLoading.value = false
  }

  const waitForLoad = async () => {
    if (isLoading.value) {
      await new Promise(resolve => {
        const interval = setInterval(() => {
          if (!isLoading.value) {
            clearInterval(interval)
            resolve(null)
          }
        }, 100)
      })
    }
  }

  return {
    isLoading: computed(() => isLoading.value),
    isAuthenticated: computed(() => !!auth.value.token && !!user.value),
    waitForLoad,
    login,
    logout,
    user: computed(() => user.value),
  }
})
