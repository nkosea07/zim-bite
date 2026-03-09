import { useState } from 'react';
import { Link, NavLink, Outlet, useNavigate } from 'react-router-dom';
import { useCartStore } from '../../app/store/cartStore';
import { useAuthStore } from '../../app/store/authStore';
import { ToastContainer } from '../ui/Toast';

function dashboardPath(role: string | null): string {
  switch (role) {
    case 'VENDOR_ADMIN': return '/vendor-dashboard';
    case 'SYSTEM_ADMIN': return '/admin-dashboard';
    case 'RIDER':        return '/rider-dashboard';
    default:             return '/account';
  }
}

function dashboardLabel(role: string | null): string {
  switch (role) {
    case 'VENDOR_ADMIN': return 'Dashboard';
    case 'SYSTEM_ADMIN': return 'Dashboard';
    case 'RIDER':        return 'Dashboard';
    default:             return 'Account';
  }
}

export function AppShell() {
  const [menuOpen, setMenuOpen] = useState(false);
  const itemCount = useCartStore((s) => s.items.reduce((n, i) => n + i.quantity, 0));
  const { userId, role, clearSession } = useAuthStore();
  const navigate = useNavigate();

  const isCustomer = !role || role === 'CUSTOMER';
  const showCart = isCustomer;

  function handleSignOut() {
    clearSession();
    navigate('/auth/login');
  }

  return (
    <div className="app-shell">
      <header className="topbar">
        <Link to="/" className="topbar-brand">
          <div className="topbar-logo">Z</div>
          <span className="topbar-name">ZimBite</span>
        </Link>

        <nav className="topbar-nav">
          {isCustomer && (
            <>
              <NavLink to="/vendors">Vendors</NavLink>
              <NavLink to="/meal-builder">Meal Builder</NavLink>
              <NavLink to="/orders">Orders</NavLink>
            </>
          )}
          {userId ? (
            <NavLink to={dashboardPath(role)}>{dashboardLabel(role)}</NavLink>
          ) : (
            <NavLink to="/auth/login">Sign In</NavLink>
          )}
        </nav>

        <div className="topbar-actions">
          {showCart && (
            <Link to="/cart" className="cart-btn">
              <span>🛒</span>
              {itemCount > 0 && (
                <span className="cart-badge">{itemCount}</span>
              )}
            </Link>
          )}
          <button
            className={`hamburger-btn${menuOpen ? ' open' : ''}`}
            onClick={() => setMenuOpen((o) => !o)}
            aria-label="Toggle menu"
          >
            <span />
            <span />
            <span />
          </button>
        </div>
      </header>

      <nav className={`mobile-nav${menuOpen ? ' open' : ''}`} onClick={() => setMenuOpen(false)}>
        {isCustomer && (
          <>
            <NavLink to="/vendors">🏪 Vendors</NavLink>
            <NavLink to="/meal-builder">🍳 Meal Builder</NavLink>
            <NavLink to="/cart">🛒 Cart {itemCount > 0 ? `(${itemCount})` : ''}</NavLink>
            <NavLink to="/orders">📋 Orders</NavLink>
          </>
        )}
        {userId ? (
          <>
            <NavLink to={dashboardPath(role)}>
              {role === 'VENDOR_ADMIN' ? '🏪' : role === 'RIDER' ? '🚴' : role === 'SYSTEM_ADMIN' ? '🔧' : '👤'} {dashboardLabel(role)}
            </NavLink>
            <button
              className="btn-ghost"
              style={{ textAlign: 'left', paddingLeft: 'var(--space-4)' }}
              onClick={handleSignOut}
            >
              🚪 Sign Out
            </button>
          </>
        ) : (
          <NavLink to="/auth/login">🔑 Sign In</NavLink>
        )}
      </nav>

      <main className="page-wrap">
        <Outlet />
      </main>

      <ToastContainer />
    </div>
  );
}
