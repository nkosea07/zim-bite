import { useQuery } from '@tanstack/react-query';
import { Link, useParams } from 'react-router-dom';
import { MapContainer, TileLayer, Marker } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import './DeliveryTrackingPage.css';

import markerIconPng from 'leaflet/dist/images/marker-icon.png';
import markerIconRetina from 'leaflet/dist/images/marker-icon-2x.png';
import markerShadowPng from 'leaflet/dist/images/marker-shadow.png';

import { zimbiteApi, type DeliveryTracking } from '../../services/zimbiteApi';

// Fix Leaflet default icon paths
delete (L.Icon.Default.prototype as unknown as Record<string, unknown>)['_getIconUrl'];
L.Icon.Default.mergeOptions({
  iconUrl: markerIconPng,
  iconRetinaUrl: markerIconRetina,
  shadowUrl: markerShadowPng
});

const HARARE: [number, number] = [-17.8292, 31.0522];

const driverIcon = new L.Icon({
  iconUrl: markerIconPng,
  iconRetinaUrl: markerIconRetina,
  shadowUrl: markerShadowPng,
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  className: 'driver-marker'
});

const destinationIcon = new L.Icon({
  iconUrl: markerIconPng,
  iconRetinaUrl: markerIconRetina,
  shadowUrl: markerShadowPng,
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  className: 'destination-marker'
});

function statusColor(status: string): string {
  switch (status.toUpperCase()) {
    case 'DELIVERED': return 'var(--success, #22c55e)';
    case 'OUT_FOR_DELIVERY': return 'var(--info, #3b82f6)';
    case 'PICKED_UP':
    case 'ASSIGNED':
    case 'EN_ROUTE': return 'var(--brand)';
    default: return 'var(--muted)';
  }
}

function statusLabel(status: string): string {
  return status.replace(/_/g, ' ').toUpperCase();
}

function formatEta(eta: string | null | undefined): { time: string; mins: string | null } {
  if (!eta) return { time: 'Calculating...', mins: null };
  const d = new Date(eta);
  const time = d.toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' });
  const diff = Math.round((d.getTime() - Date.now()) / 60000);
  const mins = diff > 0 ? `${diff} min away` : null;
  return { time, mins };
}

export function DeliveryTrackingPage() {
  const { orderId } = useParams<{ orderId: string }>();

  const { data: tracking, isLoading, isError } = useQuery<DeliveryTracking>({
    queryKey: ['delivery-tracking', orderId],
    queryFn: () => zimbiteApi.getDeliveryTracking(orderId!),
    enabled: !!orderId,
    refetchInterval: 15_000
  });

  if (!orderId) {
    return (
      <div className="tracking-error">
        <p style={{ fontSize: '2rem' }}>🗺️</p>
        <p className="section-title">No order specified</p>
        <Link to="/orders" className="btn-primary">Back to Orders</Link>
      </div>
    );
  }

  if (isLoading) {
    return (
      <div className="tracking-error">
        <div className="skeleton" style={{ width: 48, height: 48, borderRadius: '50%' }} />
        <p style={{ fontWeight: 600 }}>Finding your rider...</p>
      </div>
    );
  }

  if (isError || !tracking) {
    return (
      <div className="tracking-error">
        <p style={{ fontSize: '2rem' }}>⚠️</p>
        <p className="section-title">Couldn't load tracking</p>
        <p className="text-muted">The delivery may not have started yet.</p>
        <Link to="/orders" className="btn-primary">Back to Orders</Link>
      </div>
    );
  }

  const driverPos: [number, number] =
    tracking.currentLatitude != null && tracking.currentLongitude != null
      ? [tracking.currentLatitude, tracking.currentLongitude]
      : HARARE;

  const destPos: [number, number] =
    tracking.deliveryLatitude != null && tracking.deliveryLongitude != null
      ? [tracking.deliveryLatitude, tracking.deliveryLongitude]
      : HARARE;

  const color = statusColor(tracking.status);
  const { time: etaTime, mins: etaMins } = formatEta(tracking.estimatedArrival);

  return (
    <div className="tracking-page">
      <div className="tracking-map">
        <MapContainer center={driverPos} zoom={14} style={{ height: '100%', width: '100%' }}>
          <TileLayer
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
            attribution='&copy; <a href="https://openstreetmap.org/copyright">OpenStreetMap</a>'
          />
          <Marker position={driverPos} icon={driverIcon} />
          <Marker position={destPos} icon={destinationIcon} />
        </MapContainer>
      </div>

      <div className="tracking-panel">
        <div className="tracking-panel-handle" />

        {/* Status */}
        <div style={{ textAlign: 'center', marginBottom: 'var(--space-4)' }}>
          <span
            className="tracking-status-chip"
            style={{ color, background: `color-mix(in srgb, ${color} 10%, transparent)`, border: `1px solid color-mix(in srgb, ${color} 30%, transparent)` }}
          >
            <span className="dot" />
            {statusLabel(tracking.status)}
          </span>
        </div>

        {/* ETA */}
        <div className="tracking-eta">
          <div className="tracking-eta-icon">🕐</div>
          <div>
            <p className="tracking-eta-label">Estimated Arrival</p>
            <p className="tracking-eta-time">{etaTime}</p>
            {etaMins && <p className="tracking-eta-mins">{etaMins}</p>}
          </div>
        </div>

        {/* Driver info */}
        <div className="tracking-driver">
          <div className="tracking-driver-avatar">🧑</div>
          <div className="tracking-driver-info">
            <p className="tracking-driver-name">{tracking.driverName ?? 'Assigning rider...'}</p>
            {tracking.driverPhone && (
              <p className="tracking-driver-phone">{tracking.driverPhone}</p>
            )}
          </div>
          {tracking.driverPhone && (
            <a
              href={`tel:${tracking.driverPhone}`}
              className="tracking-call-btn"
              aria-label="Call driver"
            >
              📞
            </a>
          )}
        </div>

        {/* Back link */}
        <div style={{ marginTop: 'var(--space-5)', textAlign: 'center' }}>
          <Link to="/orders" className="btn-ghost" style={{ fontSize: '0.85rem' }}>
            ← Back to Orders
          </Link>
        </div>
      </div>
    </div>
  );
}
