type SkeletonProps = {
  width?: string | number;
  height?: string | number;
  borderRadius?: string;
  className?: string;
  style?: React.CSSProperties;
};

export function Skeleton({ width, height = 16, borderRadius, className = '', style }: SkeletonProps) {
  return (
    <span
      className={`skeleton ${className}`}
      style={{
        display: 'block',
        width: width ?? '100%',
        height,
        borderRadius: borderRadius ?? 'var(--radius-sm)',
        ...style
      }}
    />
  );
}

export function VendorCardSkeleton() {
  return (
    <div className="card" style={{ overflow: 'hidden' }}>
      <Skeleton height={140} borderRadius="0" />
      <div className="card-body" style={{ display: 'grid', gap: 'var(--space-2)' }}>
        <Skeleton height={20} width="70%" />
        <Skeleton height={14} width="50%" />
        <Skeleton height={32} style={{ marginTop: 'var(--space-3)' }} />
      </div>
    </div>
  );
}

export function MenuItemSkeleton() {
  return (
    <div className="menu-item-card">
      <Skeleton width={70} height={70} borderRadius="var(--radius-md)" />
      <div style={{ flex: 1, display: 'grid', gap: 'var(--space-2)' }}>
        <Skeleton height={16} width="60%" />
        <Skeleton height={12} width="40%" />
      </div>
      <Skeleton width={60} height={32} borderRadius="var(--radius-sm)" />
    </div>
  );
}
