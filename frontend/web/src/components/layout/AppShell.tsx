import { Link, NavLink, Outlet } from 'react-router-dom';

export function AppShell() {
  return (
    <div className="app-shell">
      <header className="topbar">
        <Link to="/" className="brand">ZimBite</Link>
        <nav className="nav-links">
          <NavLink to="/vendors">Vendors</NavLink>
          <NavLink to="/meal-builder">Meal Builder</NavLink>
          <NavLink to="/cart">Cart</NavLink>
          <NavLink to="/checkout">Checkout</NavLink>
          <NavLink to="/account">Account</NavLink>
        </nav>
      </header>
      <main className="page-wrap">
        <Outlet />
      </main>
    </div>
  );
}
