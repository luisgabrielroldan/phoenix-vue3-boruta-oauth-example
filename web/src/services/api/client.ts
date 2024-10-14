/* eslint-disable */
/* tslint:disable */
/*
 * ---------------------------------------------------------------
 * ## THIS FILE WAS GENERATED VIA SWAGGER-TYPESCRIPT-API        ##
 * ##                                                           ##
 * ## AUTHOR: acacode                                           ##
 * ## SOURCE: https://github.com/acacode/swagger-typescript-api ##
 * ---------------------------------------------------------------
 */

/** ConfirmPasswordResetRequest */
export interface ConfirmPasswordResetRequest {
  password: string
}

/** GenericErrorResponse */
export interface GenericErrorResponse {
  message: string
  success: boolean
}

/** ResendConfirmationEmailRequest */
export interface ResendConfirmationEmailRequest {
  email: string
}

/** ResetPasswordRequest */
export interface ResetPasswordRequest {
  user: {
    /** @format email */
    email: string
  }
}

/** SchemaErrorResponse */
export interface SchemaErrorResponse {
  errors: SchemaErrors
  success: boolean
}

/** SchemaErrors */
export type SchemaErrors = {
  /** @example "null value where string expected" */
  detail: string
  source: {
    /** @example "/data/attributes/petName" */
    pointer: string
  }
  /** @example "Invalid value" */
  title: string
}[]

/** SuccessResponse */
export interface SuccessResponse {
  success: boolean
}

/** UserRegistrationRequest */
export interface UserRegistrationRequest {
  user: {
    /** @format email */
    email: string
    password: string
  }
}

/** UserSettingsResponse */
export interface UserSettingsResponse {
  /** UserSettingsResponse */
  data?: {
    /** @format email */
    email: string
  }
  success: boolean
}

/** UserSettingsUpdateRequest */
export interface UserSettingsUpdateRequest {
  action: 'update_email' | 'update_password'
  current_password?: string
  user?: {
    /** @format email */
    email?: string
    password?: string
    password_confirmation?: string
  }
}

export type QueryParamsType = Record<string | number, any>
export type ResponseFormat = keyof Omit<Body, 'body' | 'bodyUsed'>

export interface FullRequestParams extends Omit<RequestInit, 'body'> {
  /** set parameter to `true` for call `securityWorker` for this request */
  secure?: boolean
  /** request path */
  path: string
  /** content type of request body */
  type?: ContentType
  /** query params */
  query?: QueryParamsType
  /** format of response (i.e. response.json() -> format: "json") */
  format?: ResponseFormat
  /** request body */
  body?: unknown
  /** base url */
  baseUrl?: string
  /** request cancellation token */
  cancelToken?: CancelToken
}

export type RequestParams = Omit<
  FullRequestParams,
  'body' | 'method' | 'query' | 'path'
>

export interface ApiConfig<SecurityDataType = unknown> {
  baseUrl?: string
  baseApiParams?: Omit<RequestParams, 'baseUrl' | 'cancelToken' | 'signal'>
  securityWorker?: (
    securityData: SecurityDataType | null,
  ) => Promise<RequestParams | void> | RequestParams | void
  customFetch?: typeof fetch
}

export interface HttpResponse<D extends unknown, E extends unknown = unknown>
  extends Response {
  data: D
  error: E
}

type CancelToken = Symbol | string | number

export enum ContentType {
  Json = 'application/json',
  FormData = 'multipart/form-data',
  UrlEncoded = 'application/x-www-form-urlencoded',
  Text = 'text/plain',
}

export class HttpClient<SecurityDataType = unknown> {
  public baseUrl: string = 'http://localhost:4000'
  private securityData: SecurityDataType | null = null
  private securityWorker?: ApiConfig<SecurityDataType>['securityWorker']
  private abortControllers = new Map<CancelToken, AbortController>()
  private customFetch = (...fetchParams: Parameters<typeof fetch>) =>
    fetch(...fetchParams)

  private baseApiParams: RequestParams = {
    credentials: 'same-origin',
    headers: {},
    redirect: 'follow',
    referrerPolicy: 'no-referrer',
  }

  constructor(apiConfig: ApiConfig<SecurityDataType> = {}) {
    Object.assign(this, apiConfig)
  }

  public setSecurityData = (data: SecurityDataType | null) => {
    this.securityData = data
  }

  protected encodeQueryParam(key: string, value: any) {
    const encodedKey = encodeURIComponent(key)
    return `${encodedKey}=${encodeURIComponent(typeof value === 'number' ? value : `${value}`)}`
  }

  protected addQueryParam(query: QueryParamsType, key: string) {
    return this.encodeQueryParam(key, query[key])
  }

  protected addArrayQueryParam(query: QueryParamsType, key: string) {
    const value = query[key]
    return value.map((v: any) => this.encodeQueryParam(key, v)).join('&')
  }

  protected toQueryString(rawQuery?: QueryParamsType): string {
    const query = rawQuery || {}
    const keys = Object.keys(query).filter(
      key => 'undefined' !== typeof query[key],
    )
    return keys
      .map(key =>
        Array.isArray(query[key])
          ? this.addArrayQueryParam(query, key)
          : this.addQueryParam(query, key),
      )
      .join('&')
  }

  protected addQueryParams(rawQuery?: QueryParamsType): string {
    const queryString = this.toQueryString(rawQuery)
    return queryString ? `?${queryString}` : ''
  }

  private contentFormatters: Record<ContentType, (input: any) => any> = {
    [ContentType.Json]: (input: any) =>
      input !== null && (typeof input === 'object' || typeof input === 'string')
        ? JSON.stringify(input)
        : input,
    [ContentType.Text]: (input: any) =>
      input !== null && typeof input !== 'string'
        ? JSON.stringify(input)
        : input,
    [ContentType.FormData]: (input: any) =>
      Object.keys(input || {}).reduce((formData, key) => {
        const property = input[key]
        formData.append(
          key,
          property instanceof Blob
            ? property
            : typeof property === 'object' && property !== null
              ? JSON.stringify(property)
              : `${property}`,
        )
        return formData
      }, new FormData()),
    [ContentType.UrlEncoded]: (input: any) => this.toQueryString(input),
  }

  protected mergeRequestParams(
    params1: RequestParams,
    params2?: RequestParams,
  ): RequestParams {
    return {
      ...this.baseApiParams,
      ...params1,
      ...(params2 || {}),
      headers: {
        ...(this.baseApiParams.headers || {}),
        ...(params1.headers || {}),
        ...((params2 && params2.headers) || {}),
      },
    }
  }

  protected createAbortSignal = (
    cancelToken: CancelToken,
  ): AbortSignal | undefined => {
    if (this.abortControllers.has(cancelToken)) {
      const abortController = this.abortControllers.get(cancelToken)
      if (abortController) {
        return abortController.signal
      }
      return void 0
    }

    const abortController = new AbortController()
    this.abortControllers.set(cancelToken, abortController)
    return abortController.signal
  }

  public abortRequest = (cancelToken: CancelToken) => {
    const abortController = this.abortControllers.get(cancelToken)

    if (abortController) {
      abortController.abort()
      this.abortControllers.delete(cancelToken)
    }
  }

  public request = async <T = any, E = any>({
    body,
    secure,
    path,
    type,
    query,
    format,
    baseUrl,
    cancelToken,
    ...params
  }: FullRequestParams): Promise<HttpResponse<T, E>> => {
    const secureParams =
      ((typeof secure === 'boolean' ? secure : this.baseApiParams.secure) &&
        this.securityWorker &&
        (await this.securityWorker(this.securityData))) ||
      {}
    const requestParams = this.mergeRequestParams(params, secureParams)
    const queryString = query && this.toQueryString(query)
    const payloadFormatter = this.contentFormatters[type || ContentType.Json]
    const responseFormat = format || requestParams.format

    return this.customFetch(
      `${baseUrl || this.baseUrl || ''}${path}${queryString ? `?${queryString}` : ''}`,
      {
        ...requestParams,
        headers: {
          ...(requestParams.headers || {}),
          ...(type && type !== ContentType.FormData
            ? { 'Content-Type': type }
            : {}),
        },
        signal:
          (cancelToken
            ? this.createAbortSignal(cancelToken)
            : requestParams.signal) || null,
        body:
          typeof body === 'undefined' || body === null
            ? null
            : payloadFormatter(body),
      },
    ).then(async response => {
      const r = response.clone() as HttpResponse<T, E>
      r.data = null as unknown as T
      r.error = null as unknown as E

      const data = !responseFormat
        ? r
        : await response[responseFormat]()
            .then(data => {
              if (r.ok) {
                r.data = data
              } else {
                r.error = data
              }
              return r
            })
            .catch(e => {
              r.error = e
              return r
            })

      if (cancelToken) {
        this.abortControllers.delete(cancelToken)
      }

      if (!response.ok) throw data
      return data
    })
  }
}

/**
 * @title My App
 * @version 0.1.0
 * @baseUrl http://localhost:4000
 */
export class Api<
  SecurityDataType extends unknown,
> extends HttpClient<SecurityDataType> {
  auth = {
    /**
     * No description
     *
     * @tags auth
     * @name ResendConfirmationEmail
     * @summary Resend user confirmation email
     * @request POST:/api/users/confirm
     * @secure
     */
    resendConfirmationEmail: (
      data: ResendConfirmationEmailRequest,
      params: RequestParams = {},
    ) =>
      this.request<SuccessResponse, SchemaErrorResponse>({
        path: `/api/users/confirm`,
        method: 'POST',
        body: data,
        secure: true,
        type: ContentType.Json,
        format: 'json',
        ...params,
      }),

    /**
     * No description
     *
     * @tags auth
     * @name ConfirmUser
     * @summary Confirm user account
     * @request POST:/api/users/confirm/{token}
     * @secure
     */
    confirmUser: (token: string, params: RequestParams = {}) =>
      this.request<SuccessResponse, GenericErrorResponse | SchemaErrorResponse>(
        {
          path: `/api/users/confirm/${token}`,
          method: 'POST',
          secure: true,
          format: 'json',
          ...params,
        },
      ),

    /**
     * No description
     *
     * @tags auth
     * @name AppWebAuthUserRegistrationControllerCreate
     * @summary Register a new user
     * @request POST:/api/users/register
     * @secure
     */
    appWebAuthUserRegistrationControllerCreate: (
      data: UserRegistrationRequest,
      params: RequestParams = {},
    ) =>
      this.request<SuccessResponse, SchemaErrorResponse>({
        path: `/api/users/register`,
        method: 'POST',
        body: data,
        secure: true,
        type: ContentType.Json,
        format: 'json',
        ...params,
      }),

    /**
     * No description
     *
     * @tags auth
     * @name ResetPassword
     * @summary Reset user password
     * @request POST:/api/users/reset_password
     * @secure
     */
    resetPassword: (data: ResetPasswordRequest, params: RequestParams = {}) =>
      this.request<SuccessResponse, SchemaErrorResponse>({
        path: `/api/users/reset_password`,
        method: 'POST',
        body: data,
        secure: true,
        type: ContentType.Json,
        format: 'json',
        ...params,
      }),

    /**
     * No description
     *
     * @tags auth
     * @name ConfirmPasswordReset
     * @summary Confirm user password
     * @request PUT:/api/users/reset_password/{token}
     * @secure
     */
    confirmPasswordReset: (
      token: string,
      data: ConfirmPasswordResetRequest,
      params: RequestParams = {},
    ) =>
      this.request<SuccessResponse, SchemaErrorResponse | GenericErrorResponse>(
        {
          path: `/api/users/reset_password/${token}`,
          method: 'PUT',
          body: data,
          secure: true,
          type: ContentType.Json,
          format: 'json',
          ...params,
        },
      ),
  }
  accounts = {
    /**
     * No description
     *
     * @tags accounts
     * @name ShowSettings
     * @summary Show user settings
     * @request GET:/api/users/settings
     * @secure
     */
    showSettings: (params: RequestParams = {}) =>
      this.request<UserSettingsResponse, any>({
        path: `/api/users/settings`,
        method: 'GET',
        secure: true,
        format: 'json',
        ...params,
      }),

    /**
     * No description
     *
     * @tags accounts
     * @name UpdateSettings
     * @summary Update user email or password
     * @request PUT:/api/users/settings
     * @secure
     */
    updateSettings: (
      data: UserSettingsUpdateRequest,
      params: RequestParams = {},
    ) =>
      this.request<SuccessResponse, SchemaErrorResponse>({
        path: `/api/users/settings`,
        method: 'PUT',
        body: data,
        secure: true,
        type: ContentType.Json,
        format: 'json',
        ...params,
      }),

    /**
     * No description
     *
     * @tags accounts
     * @name ConfirmEmail
     * @summary Confirm user email
     * @request POST:/api/users/settings/confirm_email/{token}
     * @secure
     */
    confirmEmail: (token: string, params: RequestParams = {}) =>
      this.request<SuccessResponse, GenericErrorResponse | SchemaErrorResponse>(
        {
          path: `/api/users/settings/confirm_email/${token}`,
          method: 'POST',
          secure: true,
          format: 'json',
          ...params,
        },
      ),
  }
}
