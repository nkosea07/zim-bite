import { Navigate } from 'react-router-dom';
import { useAuthStore } from '../../app/store/authStore';

type Props = {
  allowedRoles: string[];
  children: React.ReactNode;
};

function dashboardForRole(role: string | null): string {
  switch (role) {
    case 'VENDOR_ADMIN': return '/vendor-dashboard';
    case 'SYSTEM_ADMIN': return '/admin-dashboard';
    case 'RIDER':        return '/rider-dashboard';
    default:             return '/account';
  }
}

export function RequireAuth({ allowedRoles, children }: Props) {
  const { userId, role } = useAuthStore();

  if (!userId) {
    return <Navigate to="/auth/login" replace />;
  }

  if (!allowedRoles.includes(role ?? 'CUSTOMER')) {
    return <Navigate to={dashboardForRole(role)} replace />;
  }

  return <>{children}</>;
}
