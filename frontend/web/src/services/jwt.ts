export type JwtClaims = {
  sub?: string;
  role?: string;
  [key: string]: unknown;
};

export function parseJwtClaims(token: string): JwtClaims | null {
  try {
    const segments = token.split('.');
    if (segments.length < 2) {
      return null;
    }

    const payload = segments[1]
      .replace(/-/g, '+')
      .replace(/_/g, '/')
      .padEnd(Math.ceil(segments[1].length / 4) * 4, '=');

    const json = atob(payload);
    return JSON.parse(json) as JwtClaims;
  } catch {
    return null;
  }
}
