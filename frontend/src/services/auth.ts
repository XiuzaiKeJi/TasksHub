import request from '@/utils/request';

export interface LoginParams {
  username: string;
  password: string;
}

export interface LoginResult {
  user: {
    id: string;
    username: string;
    name: string;
    role: string;
  };
  token: string;
}

export const login = (params: LoginParams) => {
  return request.post<LoginResult>('/auth/login', params);
};

export const logout = () => {
  return request.post('/auth/logout');
};

export const getCurrentUser = () => {
  return request.get<LoginResult['user']>('/auth/current-user');
}; 