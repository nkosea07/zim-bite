import { FormEvent, useRef, useState, KeyboardEvent } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuthStore } from '../../app/store/authStore';
import { zimbiteApi } from '../../services/zimbiteApi';
import { toast } from '../../app/store/toastStore';

type Step = 'phone' | 'otp';

export function LoginPage() {
  const navigate = useNavigate();
  const { setSession } = useAuthStore();

  const [step, setStep]               = useState<Step>('phone');
  const [phone, setPhone]             = useState('');
  const [challengeId, setChallengeId] = useState('');
  const [maskedPhone, setMaskedPhone] = useState('');
  const [otp, setOtp]                 = useState(['', '', '', '', '', '']);
  const [submitting, setSubmitting]   = useState(false);
  const [error, setError]             = useState<string | null>(null);

  const otpRefs = useRef<(HTMLInputElement | null)[]>([]);

  // ── Step 1: send OTP ──────────────────────────────────────────
  async function onPhoneSubmit(e: FormEvent) {
    e.preventDefault();
    setError(null);
    setSubmitting(true);
    try {
      const res = await zimbiteApi.sendOtp(phone);
      setChallengeId(res.challengeId);
      setMaskedPhone(res.maskedPhone ?? phone);
      setStep('otp');
      toast.success('OTP sent', `Check your SMS on ${res.maskedPhone ?? phone}`);
    } catch {
      setError('Could not send OTP. Check the number and try again.');
    } finally {
      setSubmitting(false);
    }
  }

  // ── Step 2: verify OTP ────────────────────────────────────────
  async function onOtpSubmit(e: FormEvent) {
    e.preventDefault();
    const code = otp.join('');
    if (code.length < 6) { setError('Enter all 6 digits.'); return; }
    setError(null);
    setSubmitting(true);
    try {
      const session = await zimbiteApi.verifyOtp({ challengeId, otp: code });
      setSession({
        userId:       session.userId,
        token:        session.accessToken,
        refreshToken: session.refreshToken,
        role:         session.role
      });
      toast.success('Welcome back! 🎉', 'You are now signed in.');
      navigate('/account', { replace: true });
    } catch {
      setError('Incorrect OTP. Please try again.');
      setOtp(['', '', '', '', '', '']);
      otpRefs.current[0]?.focus();
    } finally {
      setSubmitting(false);
    }
  }

  // ── OTP input helpers ─────────────────────────────────────────
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

  return (
    <div className="auth-wrap" style={{ paddingTop: 0 }}>
      <div className="auth-card">
        <div className="auth-logo">Z</div>

        {step === 'phone' ? (
          <>
            <h1 className="auth-title">Sign In</h1>
            <p className="auth-subtitle">
              Enter your Zimbabwe phone number.<br />We'll send a one-time code.
            </p>

            <form onSubmit={onPhoneSubmit} className="stacked-form">
              <div className="form-field">
                <label className="form-label" htmlFor="phone">Phone number</label>
                <input
                  id="phone"
                  className={`form-input${error ? ' error' : ''}`}
                  type="tel"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  placeholder="+263 77 123 4567"
                  required
                  autoFocus
                  autoComplete="tel"
                />
                <span className="form-hint">Format: +263 7X XXX XXXX</span>
              </div>

              {error && <p className="form-error">⚠ {error}</p>}

              <button className="btn-primary" type="submit" disabled={submitting} style={{ width: '100%', justifyContent: 'center' }}>
                {submitting ? (
                  <span style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-2)' }}>
                    <span style={{ width: 16, height: 16, border: '2px solid rgba(255,255,255,0.3)', borderTopColor: '#fff', borderRadius: '50%', animation: 'spin 0.7s linear infinite', display: 'inline-block' }} />
                    Sending…
                  </span>
                ) : 'Send OTP →'}
              </button>
            </form>

            <hr className="divider" />
            <p className="text-sm text-muted" style={{ textAlign: 'center' }}>
              Don't have an account?{' '}
              <Link to="/auth/register" className="text-brand fw-semibold">Register</Link>
            </p>
          </>
        ) : (
          <>
            <h1 className="auth-title">Enter OTP</h1>
            <p className="auth-subtitle">
              We sent a 6-digit code to<br />
              <strong style={{ color: 'var(--text)' }}>{maskedPhone}</strong>
            </p>

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
                  />
                ))}
              </div>

              {error && <p className="form-error" style={{ textAlign: 'center', marginBottom: 'var(--space-4)' }}>⚠ {error}</p>}

              <button
                className="btn-primary"
                type="submit"
                disabled={submitting || otp.join('').length < 6}
                style={{ width: '100%', justifyContent: 'center' }}
              >
                {submitting ? (
                  <span style={{ display: 'flex', alignItems: 'center', gap: 'var(--space-2)' }}>
                    <span style={{ width: 16, height: 16, border: '2px solid rgba(255,255,255,0.3)', borderTopColor: '#fff', borderRadius: '50%', animation: 'spin 0.7s linear infinite', display: 'inline-block' }} />
                    Verifying…
                  </span>
                ) : 'Verify & Sign In →'}
              </button>
            </form>

            <hr className="divider" />
            <p className="text-sm text-muted" style={{ textAlign: 'center' }}>
              Wrong number?{' '}
              <button
                className="btn-ghost"
                style={{ fontSize: '0.875rem', padding: '0 4px' }}
                onClick={() => { setStep('phone'); setError(null); setOtp(['','','','','','']); }}
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
