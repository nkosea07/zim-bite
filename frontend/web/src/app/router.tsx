import { createBrowserRouter } from 'react-router-dom';
import { AppShell } from '../components/layout/AppShell';
import { AccountPage } from '../pages/account/AccountPage';
import { LoginPage } from '../pages/auth/LoginPage';
import { CartPage } from '../pages/cart/CartPage';
import { CheckoutPage } from '../pages/checkout/CheckoutPage';
import { HomePage } from '../pages/home/HomePage';
import { MealBuilderPage } from '../pages/meal-builder/MealBuilderPage';
import { VendorPage } from '../pages/vendor/VendorPage';

export const router = createBrowserRouter([
  {
    path: '/',
    element: <AppShell />,
    children: [
      { index: true, element: <HomePage /> },
      { path: 'vendors', element: <VendorPage /> },
      { path: 'meal-builder', element: <MealBuilderPage /> },
      { path: 'cart', element: <CartPage /> },
      { path: 'checkout', element: <CheckoutPage /> },
      { path: 'auth/login', element: <LoginPage /> },
      { path: 'account', element: <AccountPage /> }
    ]
  }
]);
