import { Api as ClientApi, type RequestParams } from './client'

export * from './client'

interface SecurityData {
  refreshToken?: string
}

let unauthorizedHandler: () => Promise<boolean> = async () => false

export const setUnauthorizedHandler = (handler: () => Promise<boolean>) => {
  unauthorizedHandler = handler
}

const customFetch = async (
  ...fetchParams: Parameters<typeof fetch>
): Promise<Response> => {
  try {
    const response = await fetch(...fetchParams)

    // Check if the response status is 401 (Unauthorized)
    if (response.status === 401) {
      const retry = await unauthorizedHandler()

      if (retry) {
        console.warn('Retrying request after authorization error...')
        return fetch(...fetchParams)
      }
    }

    return response // Return the response if no 401
  } catch (error) {
    throw error
  }
}

class ApiService extends ClientApi<SecurityData> {
  constructor() {
    super({
      securityWorker: ApiService.securityHandler,
      customFetch: customFetch,
      baseApiParams: {
        headers: {},
        format: 'json',
      },
    })
  }

  private static async securityHandler(
    securityData?: SecurityData | null,
  ): Promise<RequestParams> {
    const headers: Record<string, string> = {}

    if (securityData?.refreshToken) {
      headers['Authorization'] = `Bearer ${securityData.refreshToken}`
    }

    return { headers }
  }

  public setAuthToken(refreshToken: string) {
    this.setSecurityData({ refreshToken })
  }

  public clearAuthToken() {
    this.setSecurityData({})
  }
}

const apiService = new ApiService()

export default apiService
