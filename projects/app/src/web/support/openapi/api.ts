import { GET, POST, DELETE, PUT } from '@/web/common/api/request';
import type { EditApiKeyProps, GetApiKeyProps } from '@/global/support/openapi/api';
import type { OpenApiSchema } from '@fastgpt/global/support/openapi/type';

/**
 * crete a api key
 */
export const createAOpenApiKey = (data: EditApiKeyProps) =>
  POST<string>('/support/openapi/create', data);

/**
 * update a api key
 */
export const putOpenApiKey = (data: EditApiKeyProps & { _id: string }) =>
  PUT<string>('/support/openapi/update', data);
/**
 * sync a api key
 */
export const syncOpenApiKey = (data: { appId?: string; userId: string }) =>
  POST<string>('/fastgptadmin/api/v1/fastgpt_admin.sync_apikey', data);

/**
 * get api keys
 */
export const getOpenApiKeys = (params?: GetApiKeyProps) =>
  GET<OpenApiSchema[]>('/support/openapi/list', params);

/**
 * delete api by id
 */
export const delOpenApiById = (id: string) => DELETE(`/support/openapi/delete`, { id });
