import { createBrowserRouter } from 'react-router-dom';
import { AppShell } from '../components/layout/AppShell';
import { RequireAuth } from '../components/auth/RequireAuth';
import { AccountPage } from '../pages/account/AccountPage';
import { LoginPage } from '../pages/auth/LoginPage';
import { RegisterPage } from '../pages/auth/RegisterPage';
import { CartPage } from '../pages/cart/CartPage';
import { CheckoutPage } from '../pages/checkout/CheckoutPage';
import { HomePage } from '../pages/home/HomePage';
import { MealBuilderPage } from '../pages/meal-builder/MealBuilderPage';
import { OrdersPage } from '../pages/orders/OrdersPage';
import { DeliveryTrackingPage } from '../pages/tracking/DeliveryTrackingPage';
import { VendorPage } from '../pages/vendor/VendorPage';
import { VendorDashboardPage } from '../pages/vendor-dashboard/VendorDashboardPage';
import { AdminDashboardPage } from '../pages/admin-dashboard/AdminDashboardPage';
import { RiderDashboardPage } from '../pages/rider-dashboard/RiderDashboardPage';

export const router = createBrowserRouter([
  {
    path: '/',
    element: <AppShell />,
    children: [
      { index: true,                element: <HomePage /> },
      { path: 'vendors',            element: <VendorPage /> },
      { path: 'meal-builder',       element: <MealBuilderPage /> },
      { path: 'cart',               element: <CartPage /> },
      { path: 'checkout',           element: <CheckoutPage /> },
      { path: 'orders',             element: <OrdersPage /> },
      { path: 'tracking/:orderId',  element: <DeliveryTrackingPage /> },
      { path: 'auth/login',         element: <LoginPage /> },
      { path: 'auth/register',      element: <RegisterPage /> },
      {
        path: 'account',
        element: (
          <RequireAuth allowedRoles={['CUSTOMER']}>
            <AccountPage />
          </RequireAuth>
        )
      },
      {
        path: 'vendor-dashboard',
        element: (
          <RequireAuth allowedRoles={['VENDOR_ADMIN']}>
            <VendorDashboardPage />
          </RequireAuth>
        )
      },
      {
        path: 'admin-dashboard',
        element: (
          <RequireAuth allowedRoles={['SYSTEM_ADMIN']}>
            <AdminDashboardPage />
          </RequireAuth>
        )
      },
      {
        path: 'rider-dashboard',
        element: (
          <RequireAuth allowedRoles={['RIDER']}>
            <RiderDashboardPage />
          </RequireAuth>
        )
      }
    ]
  }
]);
