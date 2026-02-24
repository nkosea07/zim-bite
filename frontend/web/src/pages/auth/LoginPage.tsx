import { FormEvent, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuthStore } from '../../app/store/authStore';
import { zimbiteApi } from '../../services/zimbiteApi';

export function LoginPage() {
  const navigate = useNavigate();
  const { setSession } = useAuthStore();
  const [principal, setPrincipal] = useState('');
  const [password, setPassword] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(null);
    setSubmitting(true);

    try {
      const session = await zimbiteApi.login({ principal, password });
      setSession({
        userId: session.userId,
        token: session.accessToken,
        refreshToken: session.refreshToken,
        role: session.role
      });
      navigate('/account', { replace: true });
    } catch {
      setError('Login failed. Check your credentials and API availability.');
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <section className="panel">
      <h2>Sign In</h2>
      <form onSubmit={onSubmit} className="stacked-form">
        <label>
          Email or phone
          <input
            type="text"
            value={principal}
            onChange={(event) => setPrincipal(event.target.value)}
            placeholder="user@example.com"
            required
          />
        </label>
        <label>
          Password
          <input
            type="password"
            value={password}
            onChange={(event) => setPassword(event.target.value)}
            placeholder="••••••••"
            required
          />
        </label>
        <button className="btn-primary" type="submit" disabled={submitting}>
          {submitting ? 'Signing In...' : 'Sign In'}
        </button>
      </form>
      {error && <p className="error-text">{error}</p>}
      <p>
        Need an account? Use API register endpoint for now, then sign in here.
      </p>
      <Link to="/" className="btn-secondary">Back Home</Link>
    </section>
  );
}
