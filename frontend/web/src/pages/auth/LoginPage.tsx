import { FormEvent, useRef, useState, useEffect, useCallback, KeyboardEvent } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuthStore } from '../../app/store/authStore';
import { zimbiteApi } from '../../services/zimbiteApi';
import { ApiError } from '../../services/apiClient';
import { toast } from '../../app/store/toastStore';

type Step = 'credentials' | 'otp';

function loginErrorMessage(err: unknown): string {
  if (err instanceof ApiError) {
    if (err.status === 401) return 'Invalid email/phone or password.';
    if (err.status === 429) return 'Too many attempts. Please wait and try again.';
    if (err.status === 409) return 'Account is locked. Please contact support.';
    return err.message;
  }
  return 'Network error. Check your connection and try again.';
}

function otpErrorMessage(err: unknown): string {
  if (err instanceof ApiError) {
    if (err.status === 401) return 'Incorrect OTP. Please try again.';
    if (err.status === 429) return 'Too many attempts. Request a new code.';
    return err.message;
  }
  return 'Network error. Check your connection and try again.';
}

export function LoginPage() {
  const navigate = useNavigate();
  const { setSession } = useAuthStore();

  const [step, setStep]             = useState<Step>('credentials');
  const [principal, setPrincipal]   = useState('');
  const [password, setPassword]     = useState('');
  const [otpPrincipal, setOtpPrincipal] = useState('');
  const [otp, setOtp]               = useState(['', '', '', '', '', '']);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError]           = useState<string | null>(null);

  // OTP expiry
  const [expiresAt, setExpiresAt]   = useState<Date | null>(null);
  const [secondsLeft, setSecondsLeft] = useState(0);
  const [resendCooldown, setResendCooldown] = useState(false);

  const otpRefs = useRef<(HTMLInputElement | null)[]>([]);

  // Countdown timer
  useEffect(() => {
    if (!expiresAt) return;
    const tick = () => {
      const diff = Math.max(0, Math.floor((expiresAt.getTime() - Date.now()) / 1000));
      setSecondsLeft(diff);
    };
    tick();
    const id = setInterval(tick, 1000);
    return () => clearInterval(id);
  }, [expiresAt]);

  const expired = expiresAt !== null && secondsLeft <= 0;

  // ── Step 1: login with credentials ──────────────────────────────
  const doLogin = useCallback(async () => {
    setError(null);
    setSubmitting(true);
    try {
      const res = await zimbiteApi.login(principal.trim(), password);
      setOtpPrincipal(res.principal);
      setExpiresAt(new Date(res.expiresAt));
      setStep('otp');
      setResendCooldown(true);
      setTimeout(() => setResendCooldown(false), 30_000);
      toast.success('OTP sent', 'Check your email or SMS for the verification code.');
    } catch (err) {
      setError(loginErrorMessage(err));
    } finally {
      setSubmitting(false);
    }
  }, [principal, password]);

  async function onLoginSubmit(e: FormEvent) {
    e.preventDefault();
    if (!principal.trim() || !password) {
      setError('Enter your email/phone and password.');
      return;
    }
    await doLogin();
  }

  // ── Resend OTP ─────────────────────────────────────────────────
  async function onResend() {
    setOtp(['', '', '', '', '', '']);
    setError(null);
    await doLogin();
    otpRefs.current[0]?.focus();
  }

  // ── Step 2: verify OTP ──────────────────────────────────────────
  async function onOtpSubmit(e: FormEvent) {
    e.preventDefault();
    const code = otp.join('');
    if (code.length < 6) { setError('Enter all 6 digits.'); return; }
    setError(null);
    setSubmitting(true);
    try {
      const session = await zimbiteApi.verifyOtp({ principal: otpPrincipal, otp: code });

      let vendorId: string | null = null;
      // For vendor admins, fetch their vendor (API should filter by owner via token)
      if (session.role === 'VENDOR_ADMIN') {
        try {
          const vendors = await zimbiteApi.listVendors();
          if (vendors.length > 0) vendorId = vendors[0].id;
        } catch { /* vendor not created yet — will redirect to setup */ }
      }

      setSession({
        userId:       session.userId,
        token:        session.accessToken,
        refreshToken: session.refreshToken,
        role:         session.role,
        vendorId
      });
      toast.success('Welcome back!', 'You are now signed in.');

      // Role-based redirect
      switch (session.role) {
        case 'VENDOR_ADMIN':  navigate('/vendor-dashboard', { replace: true }); break;
        case 'SYSTEM_ADMIN':  navigate('/admin-dashboard', { replace: true }); break;
        case 'RIDER':         navigate('/rider-dashboard', { replace: true }); break;
        default:              navigate('/account', { replace: true }); break;
      }
    } catch (err) {
      setError(otpErrorMessage(err));
      setOtp(['', '', '', '', '', '']);
      otpRefs.current[0]?.focus();
    } finally {
      setSubmitting(false);
    }
  }

  // ── OTP input helpers ───────────────────────────────────────────
  function handleOtpChange(index: number, value: string) {
    const digit = value.replace(/\D/g, '').slice(-1);
    const next = [...otp];
    next[index] = digit;
    setOtp(next);
    if (digit && index < 5) otpRefs.current[index + 1]?.focus();
  }

  function handleOtpKeyDown(index: number, e: KeyboardEvent<HTMLInputElement>) {
    if (e.key === 'Backspace' && !otp[index] && index > 0) {
      otpRefs.current[index - 1]?.focus();
    }
    if (e.key === 'ArrowLeft' && index > 0) otpRefs.current[index - 1]?.focus();
    if (e.key === 'ArrowRight' && index < 5) otpRefs.current[index + 1]?.focus();
  }

  function handleOtpPaste(e: React.ClipboardEvent) {
    const text = e.clipboardData.getData('text').replace(/\D/g, '').slice(0, 6);
    if (text.length === 6) {
      setOtp(text.split(''));
      otpRefs.current[5]?.focus();
      e.preventDefault();
    }
  }

  function goBack() {
    setStep('credentials');
    setError(null);
    setOtp(['', '', '', '', '', '']);
    setPassword('');
    setExpiresAt(null);
  }

  const formatTime = (s: number) => `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`;

  return (
    <div className="auth-wrap" style={{ paddingTop: 0 }}>
      <div className="auth-card">
        <div className="auth-logo">Z</div>

        {step === 'credentials' ? (
          <>
            <h1 className="auth-title">Sign In</h1>
            <p className="auth-subtitle">
              Enter your email or phone number and password.
            </p>

            <form onSubmit={onLoginSubmit} className="stacked-form">
              <div className="form-field">
                <label className="form-label" htmlFor="principal">Email or phone</label>
                <input
                  id="principal"
                  className={`form-input${error ? ' error' : ''}`}
                  type="text"
                  value={principal}
                  onChange={(e) => { setError(null); setPrincipal(e.target.value); }}
                  placeholder="you@example.com or +263771234567"
                  autoFocus
                  autoComplete="username"
                />
              </div>

              <div className="form-field">
                <label className="form-label" htmlFor="password">Password</label>
                <input
                  id="password"
                  className={`form-input${error ? ' error' : ''}`}
                  type="password"
                  value={password}
                  onChange={(e) => { setError(null); setPassword(e.target.value); }}
                  placeholder="Your password"
                  autoComplete="current-password"
                />
              </div>

              {error && <p className="form-error">⚠ {error}</p>}

              <button className="btn-primary" type="submit" disabled={submitting || !principal.trim() || !password} style={{ width: '100%', justifyContent: 'center' }}>
                {submitting ? (
                  <span style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-2)' }}>
                    <span className="btn-spinner" />
                    Signing in…
                  </span>
                ) : 'Sign In →'}
              </button>
            </form>

            <hr className="divider" />
            <p className="text-sm text-muted" style={{ textAlign: 'center' }}>
              Don't have an account?{' '}
              <Link to="/auth/register" className="text-sm" style={{ color: 'var(--primary)' }}>Register</Link>
            </p>
          </>
        ) : (
          <>
            <h1 className="auth-title">Enter OTP</h1>
            <p className="auth-subtitle">
              We sent a 6-digit code to<br />
              <strong style={{ color: 'var(--text)' }}>{otpPrincipal}</strong>
            </p>

            {!expired && secondsLeft > 0 && (
              <p className="text-sm text-muted" style={{ textAlign: 'center', marginBottom: 'var(--space-4)' }}>
                Code expires in <strong>{formatTime(secondsLeft)}</strong>
              </p>
            )}
            {expired && (
              <p className="text-sm" style={{ textAlign: 'center', marginBottom: 'var(--space-4)', color: 'var(--danger)' }}>
                Code expired.{' '}
                <button
                  className="btn-ghost"
                  style={{ fontSize: '0.875rem', padding: '0 4px', color: 'var(--primary)' }}
                  onClick={onResend}
                  disabled={submitting}
                >
                  Resend code
                </button>
              </p>
            )}

            <form onSubmit={onOtpSubmit}>
              <div
                className="otp-row"
                onPaste={handleOtpPaste}
                style={{ marginBottom: 'var(--space-6)' }}
              >
                {otp.map((digit, i) => (
                  <input
                    key={i}
                    ref={(el) => { otpRefs.current[i] = el; }}
                    className={`otp-input${digit ? ' filled' : ''}`}
                    type="text"
                    inputMode="numeric"
                    maxLength={1}
                    value={digit}
                    onChange={(e) => handleOtpChange(i, e.target.value)}
                    onKeyDown={(e) => handleOtpKeyDown(i, e)}
                    autoFocus={i === 0}
                    disabled={expired}
                  />
                ))}
              </div>

              {error && <p className="form-error" style={{ textAlign: 'center', marginBottom: 'var(--space-4)' }}>⚠ {error}</p>}

              <button
                className="btn-primary"
                type="submit"
                disabled={submitting || otp.join('').length < 6 || expired}
                style={{ width: '100%', justifyContent: 'center' }}
              >
                {submitting ? (
                  <span style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-2)' }}>
                    <span className="btn-spinner" />
                    Verifying…
                  </span>
                ) : 'Verify & Sign In →'}
              </button>
            </form>

            <hr className="divider" />
            <p className="text-sm text-muted" style={{ textAlign: 'center' }}>
              {!expired && !resendCooldown && (
                <>
                  Didn't get a code?{' '}
                  <button
                    className="btn-ghost"
                    style={{ fontSize: '0.875rem', padding: '0 4px' }}
                    onClick={onResend}
                    disabled={submitting}
                  >
                    Resend
                  </button>
                  {' · '}
                </>
              )}
              Wrong account?{' '}
              <button
                className="btn-ghost"
                style={{ fontSize: '0.875rem', padding: '0 4px' }}
                onClick={goBack}
              >
                Go back
              </button>
            </p>
          </>
        )}

        <div style={{ textAlign: 'center', marginTop: 'var(--space-5)' }}>
          <Link to="/" className="text-sm text-muted">← Back to home</Link>
        </div>
      </div>
    </div>
  );
}
