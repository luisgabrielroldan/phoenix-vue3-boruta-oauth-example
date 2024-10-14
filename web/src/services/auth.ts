import {
  OAuth2Client,
  type OAuth2Token,
  OAuth2HttpError,
} from '@badgateway/oauth2-client'

export class AuthError extends Error {
  innerError: Error

  constructor(message: string, innerError: Error) {
    super(message)
    this.innerError = innerError
  }
}

export type Token = OAuth2Token

const OAUTH_CONFIG = {
  server: import.meta.env.VITE_API_BASE_URL,
  clientId: 'deadb33f-0000-0000-0000-123456789abc',
  tokenEndpoint: '/oauth/token',
  revocationEndpoint: '/oauth/revoke',
  introspectionEndpoint: '/oauth/introspect',
}

const oauthClient = new OAuth2Client(OAUTH_CONFIG)

export const login = async (
  username: string,
  password: string,
): Promise<Token> => {
  try {
    return await oauthClient.password({ username, password })
  } catch (error) {
    if (error instanceof OAuth2HttpError && error.httpCode === 401) {
      throw new AuthError(
        'Invalid email or password.',
        error as OAuth2HttpError,
      )
    }

    throw new AuthError('Login failed.', error as OAuth2HttpError)
  }
}

export const refreshToken = async (token: Token): Promise<Token> => {
  try {
    return await oauthClient.refreshToken(token)
  } catch (error) {
    throw new AuthError(
      'Failed refreshing the token.',
      error as OAuth2HttpError,
    )
  }
}

export const revokeToken = async (token: Token): Promise<void> => {
  try {
    await oauthClient.revoke(token)
  } catch (error) {
    console.error(error)
  }
}
