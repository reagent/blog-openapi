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

export interface Error {
  message: string;
}

/** @format int32 */
export type ID = number;

export interface Post {
  id: ID;
  title: string;
  body: string;
  /** @format date-time */
  published_at: string | null;
}

export interface PostCreate {
  title: string;
  body: string;
}

export interface PostUpdate {
  title?: string;
  body?: string;
}

export interface Posts {
  /** @format int32 */
  total: number;
  posts: Post[];
}

import type {
  AxiosInstance,
  AxiosRequestConfig,
  AxiosResponse,
  HeadersDefaults,
  ResponseType,
} from 'axios';
import axios from 'axios';

export type QueryParamsType = Record<string | number, any>;

export interface FullRequestParams
  extends Omit<AxiosRequestConfig, 'data' | 'params' | 'url' | 'responseType'> {
  /** set parameter to `true` for call `securityWorker` for this request */
  secure?: boolean;
  /** request path */
  path: string;
  /** content type of request body */
  type?: ContentType;
  /** query params */
  query?: QueryParamsType;
  /** format of response (i.e. response.json() -> format: "json") */
  format?: ResponseType;
  /** request body */
  body?: unknown;
}

export type RequestParams = Omit<
  FullRequestParams,
  'body' | 'method' | 'query' | 'path'
>;

export interface ApiConfig<SecurityDataType = unknown>
  extends Omit<AxiosRequestConfig, 'data' | 'cancelToken'> {
  securityWorker?: (
    securityData: SecurityDataType | null,
  ) => Promise<AxiosRequestConfig | void> | AxiosRequestConfig | void;
  secure?: boolean;
  format?: ResponseType;
}

export enum ContentType {
  Json = 'application/json',
  FormData = 'multipart/form-data',
  UrlEncoded = 'application/x-www-form-urlencoded',
  Text = 'text/plain',
}

export class HttpClient<SecurityDataType = unknown> {
  public instance: AxiosInstance;
  private securityData: SecurityDataType | null = null;
  private securityWorker?: ApiConfig<SecurityDataType>['securityWorker'];
  private secure?: boolean;
  private format?: ResponseType;

  constructor({
    securityWorker,
    secure,
    format,
    ...axiosConfig
  }: ApiConfig<SecurityDataType> = {}) {
    this.instance = axios.create({
      ...axiosConfig,
      baseURL: axiosConfig.baseURL || 'http://localhost:3000',
    });
    this.secure = secure;
    this.format = format;
    this.securityWorker = securityWorker;
  }

  public setSecurityData = (data: SecurityDataType | null) => {
    this.securityData = data;
  };

  protected mergeRequestParams(
    params1: AxiosRequestConfig,
    params2?: AxiosRequestConfig,
  ): AxiosRequestConfig {
    const method = params1.method || (params2 && params2.method);

    return {
      ...this.instance.defaults,
      ...params1,
      ...(params2 || {}),
      headers: {
        ...((method &&
          this.instance.defaults.headers[
            method.toLowerCase() as keyof HeadersDefaults
          ]) ||
          {}),
        ...(params1.headers || {}),
        ...((params2 && params2.headers) || {}),
      },
    };
  }

  protected stringifyFormItem(formItem: unknown) {
    if (typeof formItem === 'object' && formItem !== null) {
      return JSON.stringify(formItem);
    } else {
      return `${formItem}`;
    }
  }

  protected createFormData(input: Record<string, unknown>): FormData {
    return Object.keys(input || {}).reduce((formData, key) => {
      const property = input[key];
      const propertyContent: any[] =
        property instanceof Array ? property : [property];

      for (const formItem of propertyContent) {
        const isFileType = formItem instanceof Blob || formItem instanceof File;
        formData.append(
          key,
          isFileType ? formItem : this.stringifyFormItem(formItem),
        );
      }

      return formData;
    }, new FormData());
  }

  public request = async <T = any, _E = any>({
    secure,
    path,
    type,
    query,
    format,
    body,
    ...params
  }: FullRequestParams): Promise<AxiosResponse<T>> => {
    const secureParams =
      ((typeof secure === 'boolean' ? secure : this.secure) &&
        this.securityWorker &&
        (await this.securityWorker(this.securityData))) ||
      {};
    const requestParams = this.mergeRequestParams(params, secureParams);
    const responseFormat = format || this.format || undefined;

    if (
      type === ContentType.FormData &&
      body &&
      body !== null &&
      typeof body === 'object'
    ) {
      body = this.createFormData(body as Record<string, unknown>);
    }

    if (
      type === ContentType.Text &&
      body &&
      body !== null &&
      typeof body !== 'string'
    ) {
      body = JSON.stringify(body);
    }

    return this.instance.request({
      ...requestParams,
      headers: {
        ...(requestParams.headers || {}),
        ...(type && type !== ContentType.FormData
          ? { 'Content-Type': type }
          : {}),
      },
      params: query,
      responseType: responseFormat,
      data: body,
      url: path,
    });
  };
}

/**
 * @title Blog API
 * @version Wed Feb 21 2024 17:00:00 GMT-0700 (Mountain Standard Time)
 * @baseUrl http://localhost:3000
 * @contact <user@host.example>
 *
 * API service to manage blog posts
 */
export class Api<
  SecurityDataType extends unknown,
> extends HttpClient<SecurityDataType> {
  posts = {
    /**
     * @description List all posts available
     *
     * @tags post
     * @name PostList
     * @request GET:/posts
     * @secure
     */
    postList: (params: RequestParams = {}) =>
      this.request<Posts, Error>({
        path: `/posts`,
        method: 'GET',
        secure: true,
        format: 'json',
        ...params,
      }),

    /**
     * @description Create a new post
     *
     * @tags post
     * @name PostCreate
     * @request POST:/posts
     * @secure
     */
    postCreate: (
      data: {
        post: PostCreate;
      },
      params: RequestParams = {},
    ) =>
      this.request<Post, Error>({
        path: `/posts`,
        method: 'POST',
        body: data,
        secure: true,
        type: ContentType.Json,
        format: 'json',
        ...params,
      }),

    /**
     * @description Fetch a single post
     *
     * @tags post
     * @name PostFetch
     * @request GET:/posts/{id}
     * @secure
     */
    postFetch: (id: ID, params: RequestParams = {}) =>
      this.request<Post, Error>({
        path: `/posts/${id}`,
        method: 'GET',
        secure: true,
        format: 'json',
        ...params,
      }),

    /**
     * @description Update existing post
     *
     * @tags post
     * @name PostUpdate
     * @request PATCH:/posts/{id}
     * @secure
     */
    postUpdate: (
      id: ID,
      data: {
        post?: PostUpdate;
      },
      params: RequestParams = {},
    ) =>
      this.request<Post, Error>({
        path: `/posts/${id}`,
        method: 'PATCH',
        body: data,
        secure: true,
        type: ContentType.Json,
        format: 'json',
        ...params,
      }),

    /**
     * @description Destroy existing post
     *
     * @tags post
     * @name PostDestroy
     * @request DELETE:/posts/{id}
     * @secure
     */
    postDestroy: (id: ID, params: RequestParams = {}) =>
      this.request<Post, Error>({
        path: `/posts/${id}`,
        method: 'DELETE',
        secure: true,
        format: 'json',
        ...params,
      }),

    /**
     * @description Set publish date of post to now
     *
     * @tags post
     * @name PostPublish
     * @request PATCH:/posts/{id}/publish
     * @secure
     */
    postPublish: (id: ID, params: RequestParams = {}) =>
      this.request<Post, Error>({
        path: `/posts/${id}/publish`,
        method: 'PATCH',
        secure: true,
        format: 'json',
        ...params,
      }),

    /**
     * @description Unset publish date of post
     *
     * @tags post
     * @name PostUnpublish
     * @request PATCH:/posts/{id}/unpublish
     * @secure
     */
    postUnpublish: (id: ID, params: RequestParams = {}) =>
      this.request<Post, Error>({
        path: `/posts/${id}/unpublish`,
        method: 'PATCH',
        secure: true,
        format: 'json',
        ...params,
      }),
  };
}
