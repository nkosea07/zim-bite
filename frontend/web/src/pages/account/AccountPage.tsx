import { useAuthStore } from '../../app/store/authStore';

export function AccountPage() {
  const { userId, role, token } = useAuthStore();

  return (
    <section className="panel">
      <h2>Account</h2>
      <p><strong>User ID:</strong> {userId ?? 'none'}</p>
      <p><strong>Role:</strong> {role ?? 'none'}</p>
      <p><strong>Token:</strong> {token ? `${token.slice(0, 16)}...` : 'none'}</p>
    </section>
  );
}
