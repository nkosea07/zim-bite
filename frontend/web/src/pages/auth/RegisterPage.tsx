import { FormEvent, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { zimbiteApi } from '../../services/zimbiteApi';
import { ApiError } from '../../services/apiClient';
import { toast } from '../../app/store/toastStore';

type RoleOption = 'CUSTOMER' | 'VENDOR_ADMIN' | 'RIDER';

const ROLES: { value: RoleOption; icon: string; label: string; desc: string }[] = [
  { value: 'CUSTOMER',     icon: '🍳', label: 'Customer',  desc: 'Order breakfast' },
  { value: 'VENDOR_ADMIN', icon: '🏪', label: 'Vendor',    desc: 'Sell on ZimBite' },
  { value: 'RIDER',        icon: '🚴', label: 'Rider',     desc: 'Deliver orders' }
];

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const ZIM_PHONE_RE = /^\+?263\d{9}$/;

function isValidEmail(v: string) { return EMAIL_RE.test(v.trim()); }
function isValidPhone(v: string) {
  const d = v.trim().replace(/[\s-]/g, '');
  return ZIM_PHONE_RE.test(d);
}

function registerErrorMessage(err: unknown): string {
  if (err instanceof ApiError) {
    if (err.status === 409) return err.message;
    if (err.status === 400) return err.message;
    return err.message;
  }
  return 'Network error. Check your connection and try again.';
}

export function RegisterPage() {
  const navigate = useNavigate();

  const [role, setRole]               = useState<RoleOption>('CUSTOMER');
  const [firstName, setFirstName]     = useState('');
  const [lastName, setLastName]       = useState('');
  const [email, setEmail]             = useState('');
  const [phoneNumber, setPhoneNumber] = useState('');
  const [password, setPassword]       = useState('');
  const [confirm, setConfirm]         = useState('');
  const [submitting, setSubmitting]   = useState(false);
  const [error, setError]             = useState<string | null>(null);

  // Vendor-specific fields
  const [bizName, setBizName]         = useState('');
  const [bizDesc, setBizDesc]         = useState('');
  const [bizCity, setBizCity]         = useState('');

  const passwordsMatch = password === confirm;
  const emailValid = email.trim() === '' || isValidEmail(email);
  const phoneValid = phoneNumber.trim() === '' || isValidPhone(phoneNumber);

  const baseReady =
    firstName.trim() &&
    lastName.trim() &&
    isValidEmail(email) &&
    isValidPhone(phoneNumber) &&
    password.length >= 8 &&
    passwordsMatch;

  const vendorFieldsReady = role !== 'VENDOR_ADMIN' || (bizName.trim() && bizCity.trim());
  const formReady = baseReady && vendorFieldsReady;

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    if (!formReady) return;
    setError(null);
    setSubmitting(true);
    try {
      const normalizedPhone = phoneNumber.trim().replace(/[\s-]/g, '');
      await zimbiteApi.register({
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        email: email.trim(),
        phoneNumber: normalizedPhone.startsWith('+') ? normalizedPhone : `+${normalizedPhone}`,
        password,
        role: role === 'CUSTOMER' ? undefined : role
      });

      const roleLabel = role === 'VENDOR_ADMIN' ? 'Vendor' : role === 'RIDER' ? 'Rider' : 'Customer';
      toast.success('Account created!', `${roleLabel} account ready. Sign in to continue.`);
      navigate('/auth/login', { replace: true });
    } catch (err: unknown) {
      setError(registerErrorMessage(err));
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="auth-wrap" style={{ paddingTop: 0 }}>
      <div className="auth-card" style={{ maxWidth: 480 }}>
        <div className="auth-logo">Z</div>
        <h1 className="auth-title">Create Account</h1>
        <p className="auth-subtitle">Join ZimBite for fresh breakfast delivery.</p>

        {/* ── Role selector ──────────────────────────────────── */}
        <div className="payment-options" style={{ marginBottom: 'var(--space-6)' }}>
          {ROLES.map((r) => (
            <button
              key={r.value}
              type="button"
              className={`payment-card${role === r.value ? ' selected' : ''}`}
              onClick={() => { setRole(r.value); setError(null); }}
            >
              <div className="payment-card-icon">{r.icon}</div>
              <div className="payment-card-label">{r.label}</div>
              <div style={{ fontSize: '0.7rem', color: 'var(--muted)', marginTop: 2 }}>{r.desc}</div>
            </button>
          ))}
        </div>

        <form onSubmit={onSubmit} className="stacked-form">
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 'var(--space-3)' }}>
            <div className="form-field">
              <label className="form-label" htmlFor="firstName">First name</label>
              <input
                id="firstName"
                className="form-input"
                type="text"
                value={firstName}
                onChange={(e) => { setError(null); setFirstName(e.target.value); }}
                placeholder="Tino"
                autoFocus
                autoComplete="given-name"
              />
            </div>
            <div className="form-field">
              <label className="form-label" htmlFor="lastName">Last name</label>
              <input
                id="lastName"
                className="form-input"
                type="text"
                value={lastName}
                onChange={(e) => { setError(null); setLastName(e.target.value); }}
                placeholder="Moyo"
                autoComplete="family-name"
              />
            </div>
          </div>

          <div className="form-field">
            <label className="form-label" htmlFor="regEmail">Email</label>
            <input
              id="regEmail"
              className={`form-input${!emailValid ? ' error' : ''}`}
              type="email"
              value={email}
              onChange={(e) => { setError(null); setEmail(e.target.value); }}
              placeholder="you@example.com"
              autoComplete="email"
            />
            {!emailValid && (
              <span className="form-hint" style={{ color: 'var(--danger)' }}>
                Enter a valid email address
              </span>
            )}
          </div>

          <div className="form-field">
            <label className="form-label" htmlFor="regPhone">Phone number</label>
            <input
              id="regPhone"
              className={`form-input${!phoneValid ? ' error' : ''}`}
              type="tel"
              value={phoneNumber}
              onChange={(e) => { setError(null); setPhoneNumber(e.target.value); }}
              placeholder="+263771234567"
              autoComplete="tel"
            />
            {!phoneValid && (
              <span className="form-hint" style={{ color: 'var(--danger)' }}>
                Enter a valid Zimbabwe number (e.g. +263771234567)
              </span>
            )}
          </div>

          {/* ── Vendor-specific fields ───────────────────────── */}
          {role === 'VENDOR_ADMIN' && (
            <>
              <hr className="divider" />
              <p className="form-label" style={{ fontSize: '0.9rem', fontWeight: 700 }}>Business Details</p>
              <div className="form-field">
                <label className="form-label" htmlFor="bizName">Business name</label>
                <input
                  id="bizName"
                  className="form-input"
                  type="text"
                  value={bizName}
                  onChange={(e) => { setError(null); setBizName(e.target.value); }}
                  placeholder="e.g. Tino's Kitchen"
                />
              </div>
              <div className="form-field">
                <label className="form-label" htmlFor="bizDesc">Description (optional)</label>
                <textarea
                  id="bizDesc"
                  className="form-textarea"
                  value={bizDesc}
                  onChange={(e) => setBizDesc(e.target.value)}
                  placeholder="What makes your breakfast special?"
                  rows={2}
                />
              </div>
              <div className="form-field">
                <label className="form-label" htmlFor="bizCity">City</label>
                <input
                  id="bizCity"
                  className="form-input"
                  type="text"
                  value={bizCity}
                  onChange={(e) => { setError(null); setBizCity(e.target.value); }}
                  placeholder="e.g. Harare"
                />
              </div>
              <p className="form-hint">
                You'll complete your vendor setup (location, menu) after signing in.
              </p>
            </>
          )}

          <div className="form-field">
            <label className="form-label" htmlFor="regPassword">Password</label>
            <input
              id="regPassword"
              className="form-input"
              type="password"
              value={password}
              onChange={(e) => { setError(null); setPassword(e.target.value); }}
              placeholder="Min 8 characters"
              autoComplete="new-password"
            />
            {password.length > 0 && password.length < 8 && (
              <span className="form-hint" style={{ color: 'var(--danger)' }}>
                Must be at least 8 characters
              </span>
            )}
          </div>

          <div className="form-field">
            <label className="form-label" htmlFor="regConfirm">Confirm password</label>
            <input
              id="regConfirm"
              className="form-input"
              type="password"
              value={confirm}
              onChange={(e) => { setError(null); setConfirm(e.target.value); }}
              placeholder="Repeat your password"
              autoComplete="new-password"
            />
            {confirm.length > 0 && !passwordsMatch && (
              <span className="form-hint" style={{ color: 'var(--danger)' }}>
                Passwords do not match
              </span>
            )}
          </div>

          {error && <p className="form-error">⚠ {error}</p>}

          <button
            className="btn-primary"
            type="submit"
            disabled={submitting || !formReady}
            style={{ width: '100%', justifyContent: 'center' }}
          >
            {submitting ? (
              <span style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-2)' }}>
                <span className="btn-spinner" />
                Creating account…
              </span>
            ) : `Create ${role === 'VENDOR_ADMIN' ? 'Vendor' : role === 'RIDER' ? 'Rider' : ''} Account →`}
          </button>
        </form>

        <hr className="divider" />
        <p className="text-sm text-muted" style={{ textAlign: 'center' }}>
          Already have an account?{' '}
          <Link to="/auth/login" className="text-sm" style={{ color: 'var(--brand)' }}>Sign in</Link>
        </p>

        <div style={{ textAlign: 'center', marginTop: 'var(--space-5)' }}>
          <Link to="/" className="text-sm text-muted">← Back to home</Link>
        </div>
      </div>
    </div>
  );
}
