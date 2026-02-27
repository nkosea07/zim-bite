import { useToastStore, type ToastVariant } from '../../app/store/toastStore';

const icons: Record<ToastVariant, string> = {
  default: '💬',
  success: '✅',
  error:   '❌',
  warning: '⚠️'
};

export function ToastContainer() {
  const { toasts, dismiss } = useToastStore();

  return (
    <div className="toast-container" aria-live="polite">
      {toasts.map((t) => (
        <div
          key={t.id}
          className={`toast${t.variant && t.variant !== 'default' ? ` ${t.variant}` : ''}`}
          role="alert"
        >
          <span className="toast-icon">{icons[t.variant ?? 'default']}</span>
          <div className="toast-body">
            <p className="toast-title">{t.title}</p>
            {t.description && <p className="toast-desc">{t.description}</p>}
          </div>
          <button className="toast-close" onClick={() => dismiss(t.id)} aria-label="Dismiss">✕</button>
        </div>
      ))}
    </div>
  );
}
