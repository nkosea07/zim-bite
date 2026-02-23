import React from 'react';
import ReactDOM from 'react-dom/client';
import { createBrowserRouter, RouterProvider } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

const queryClient = new QueryClient();

function HomePage() {
  return (
    <main style={{ fontFamily: 'system-ui', padding: '2rem' }}>
      <h1>ZimBite</h1>
      <p>Breakfast ordering platform bootstrap.</p>
    </main>
  );
}

const router = createBrowserRouter([{ path: '/', element: <HomePage /> }]);

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <QueryClientProvider client={queryClient}>
      <RouterProvider router={router} />
    </QueryClientProvider>
  </React.StrictMode>
);
