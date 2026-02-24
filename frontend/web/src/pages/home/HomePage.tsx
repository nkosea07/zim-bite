import { Link } from 'react-router-dom';
import { useAuthStore } from '../../app/store/authStore';

export function HomePage() {
  const { userId, clearSession } = useAuthStore();

  return (
    <section className="hero">
      <p className="eyebrow">Morning Delivery Platform</p>
      <h1>Breakfast logistics designed for Zimbabwe peak hours.</h1>
      <p>
        Browse nearby vendors, compose custom meals, place orders, and track fulfillment through a single low-bandwidth optimized flow.
      </p>
      <div className="hero-actions">
        <Link to="/vendors" className="btn-primary">Start Ordering</Link>
        <Link to="/meal-builder" className="btn-secondary">Open Meal Builder</Link>
      </div>
      <div className="panel">
        <p><strong>Session:</strong> {userId ?? 'not signed in'}</p>
        <div className="hero-actions">
          <Link to="/auth/login" className="btn-secondary">Sign In</Link>
          <button className="btn-secondary" onClick={clearSession}>Clear Session</button>
        </div>
      </div>
    </section>
  );
}
