import { Suspense } from 'react';
import { useRoutes } from 'react-router-dom';
import { ConfigProvider, Spin } from 'antd';
import zhCN from 'antd/locale/zh_CN';
import { routes } from './routes';
import AuthGuard from './components/AuthGuard';
import './styles/global.css';

function App() {
  const element = useRoutes(routes);

  return (
    <ConfigProvider locale={zhCN}>
      <Suspense fallback={<Spin size="large" className="global-spin" />}>
        <AuthGuard>{element}</AuthGuard>
      </Suspense>
    </ConfigProvider>
  );
}

export default App; 