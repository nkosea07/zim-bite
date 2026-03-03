import { createBrowserRouter, Navigate } from 'react-router-dom';
import { AppShell } from '../components/layout/AppShell';
import { AccountPage } from '../pages/account/AccountPage';
import { LoginPage } from '../pages/auth/LoginPage';
import { CartPage } from '../pages/cart/CartPage';
import { CheckoutPage } from '../pages/checkout/CheckoutPage';
import { HomePage } from '../pages/home/HomePage';
import { MealBuilderPage } from '../pages/meal-builder/MealBuilderPage';
import { OrdersPage } from '../pages/orders/OrdersPage';
import { DeliveryTrackingPage } from '../pages/tracking/DeliveryTrackingPage';
import { VendorPage } from '../pages/vendor/VendorPage';

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
      { path: 'account',            element: <AccountPage /> },
      /* Legacy redirect */
      { path: 'auth/register',      element: <Navigate to="/auth/login" replace /> }
    ]
  }
]);
