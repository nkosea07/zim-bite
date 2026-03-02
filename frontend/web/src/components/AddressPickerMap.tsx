import { useCallback, useEffect, useRef, useState } from 'react';
import { MapContainer, TileLayer, Marker, useMapEvents } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import './AddressPickerMap.css';

// Fix Leaflet's default icon broken paths in Vite/Webpack builds
import markerIconPng from 'leaflet/dist/images/marker-icon.png';
import markerIconRetina from 'leaflet/dist/images/marker-icon-2x.png';
import markerShadowPng from 'leaflet/dist/images/marker-shadow.png';

delete (L.Icon.Default.prototype as unknown as Record<string, unknown>)['_getIconUrl'];
L.Icon.Default.mergeOptions({
  iconUrl: markerIconPng,
  iconRetinaUrl: markerIconRetina,
  shadowUrl: markerShadowPng
});

const HARARE: [number, number] = [-17.8292, 31.0522];
const NOMINATIM = 'https://nominatim.openstreetmap.org/reverse';

export type AddressResult = {
  label: string;
  line1: string;
  city: string;
  area: string;
  latitude: number;
  longitude: number;
};

type Props = {
  onSave: (address: AddressResult) => void;
  onClose: () => void;
};

/** Inner component so we can use useMapEvents inside MapContainer */
function ClickHandler({ onMove }: { onMove: (lat: number, lng: number) => void }) {
  useMapEvents({
    click(e) {
      onMove(e.latlng.lat, e.latlng.lng);
    }
  });
  return null;
}

export function AddressPickerMap({ onSave, onClose }: Props) {
  const [markerPos, setMarkerPos]     = useState<[number, number] | null>(null);
  const [addressText, setAddressText] = useState('');
  const [label, setLabel]             = useState('Home');
  const [geocoding, setGeocoding]     = useState(false);
  const [gpsLoading, setGpsLoading]   = useState(false);
  const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  const reverseGeocode = useCallback(async (lat: number, lng: number) => {
    setGeocoding(true);
    try {
      const res = await fetch(`${NOMINATIM}?format=json&lat=${lat}&lon=${lng}&addressdetails=1`);
      const data = await res.json() as {
        display_name?: string;
        address?: {
          house_number?: string;
          road?: string;
          pedestrian?: string;
          footway?: string;
          suburb?: string;
          neighbourhood?: string;
          quarter?: string;
          city_district?: string;
          city?: string;
          town?: string;
          village?: string;
        };
      };
      if (data?.address) {
        const a = data.address;
        const houseNum = a.house_number ?? '';
        const road     = a.road ?? a.pedestrian ?? a.footway ?? '';
        const suburb   = a.suburb ?? a.neighbourhood ?? a.quarter ?? a.city_district ?? '';
        const city     = a.city ?? a.town ?? a.village ?? 'Harare';
        const street   = [houseNum, road].filter(Boolean).join(' ')
                        || data.display_name?.split(',')[0]
                        || '';
        // Compose in Zimbabwe platform format: Street, Suburb, City
        const parts = [street, suburb, city].filter(Boolean);
        setAddressText(parts.join(', '));
      }
    } catch {
      // Nominatim unavailable — leave addressText for manual edit
    } finally {
      setGeocoding(false);
    }
  }, []);

  function handleMove(lat: number, lng: number) {
    setMarkerPos([lat, lng]);
    if (debounceRef.current) clearTimeout(debounceRef.current);
    debounceRef.current = setTimeout(() => reverseGeocode(lat, lng), 600);
  }

  useEffect(() => () => {
    if (debounceRef.current) clearTimeout(debounceRef.current);
  }, []);

  function handleGps() {
    if (!navigator.geolocation) return;
    setGpsLoading(true);
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        handleMove(pos.coords.latitude, pos.coords.longitude);
        setGpsLoading(false);
      },
      () => setGpsLoading(false),
      { timeout: 8000 }
    );
  }

  function handleSave() {
    if (!markerPos || !addressText.includes(',')) return;
    const parts = addressText.split(',').map((s) => s.trim());
    const line1 = parts[0] ?? '';
    const area  = parts[1] ?? '';
    const city  = parts[2] ?? 'Harare';
    onSave({ label, line1, city, area, latitude: markerPos[0], longitude: markerPos[1] });
  }

  const isValid = markerPos !== null && addressText.includes(',') && label.trim().length > 0;

  return (
    <div
      className="address-picker-overlay"
      onMouseDown={(e) => { if (e.target === e.currentTarget) onClose(); }}
    >
      <div className="address-picker-modal">
        {/* Header */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <p style={{ fontFamily: 'var(--font-display)', fontWeight: 700, fontSize: '1.1rem' }}>
            📍 Add Delivery Address
          </p>
          <button
            onClick={onClose}
            style={{
              background: 'none', border: 'none', cursor: 'pointer',
              fontSize: '1.3rem', color: 'var(--muted)', lineHeight: 1
            }}
            aria-label="Close"
          >
            ✕
          </button>
        </div>

        <p className="text-sm text-muted">
          Click anywhere on the map to pin your delivery location, or tap the GPS button.
        </p>

        {/* Map */}
        <div className="address-picker-map-wrap">
          <MapContainer center={HARARE} zoom={13} style={{ height: 320, width: '100%' }}>
            <TileLayer
              url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
              attribution='&copy; <a href="https://openstreetmap.org/copyright">OpenStreetMap</a>'
            />
            <ClickHandler onMove={handleMove} />
            {markerPos && <Marker position={markerPos} />}
          </MapContainer>
        </div>

        {/* GPS button */}
        <button
          className="btn-secondary"
          onClick={handleGps}
          disabled={gpsLoading}
          style={{ fontSize: '0.875rem' }}
        >
          {gpsLoading ? '⏳ Getting location…' : '🎯 Use my current location'}
        </button>

        {/* Label selector */}
        <div className="form-field">
          <label className="form-label">Address label</label>
          <div style={{ display: 'flex', gap: 'var(--space-2)', flexWrap: 'wrap' }}>
            {['Home', 'Work', 'School', 'Other'].map((lbl) => (
              <button
                key={lbl}
                onClick={() => setLabel(lbl)}
                className={label === lbl ? 'btn-primary' : 'btn-ghost'}
                style={{ fontSize: '0.8rem', padding: '4px 14px', minWidth: 0 }}
              >
                {lbl}
              </button>
            ))}
          </div>
        </div>

        {/* Address text */}
        <div className="form-field">
          <label className="form-label">
            Address{' '}
            {geocoding && (
              <span className="text-muted" style={{ fontSize: '0.75rem', fontWeight: 400 }}>
                ⏳ auto-filling…
              </span>
            )}
          </label>
          <input
            className="form-input"
            type="text"
            value={addressText}
            onChange={(e) => setAddressText(e.target.value)}
            placeholder="12 Samora Machel Ave, Avondale, Harare"
          />
          <span className="form-hint">
            Format: <strong>House/Stand No. Street, Suburb, City</strong>
            {' '}— e.g. <em>Stand 4567, Crowhill Estate, Harare</em>
          </span>
        </div>

        {/* Coordinates chip */}
        {markerPos && (
          <p style={{
            fontSize: '0.75rem', fontFamily: 'monospace', color: 'var(--muted)',
            background: 'var(--surface-3)', borderRadius: 'var(--radius-sm)',
            padding: '4px 8px', display: 'inline-block'
          }}>
            📌 {markerPos[0].toFixed(5)}, {markerPos[1].toFixed(5)}
          </p>
        )}

        {/* Actions */}
        <div style={{ display: 'flex', gap: 'var(--space-3)' }}>
          <button className="btn-secondary" onClick={onClose} style={{ flex: 1 }}>
            Cancel
          </button>
          <button
            className="btn-primary"
            onClick={handleSave}
            disabled={!isValid}
            style={{ flex: 2, justifyContent: 'center' }}
          >
            Save Address
          </button>
        </div>
      </div>
    </div>
  );
}
