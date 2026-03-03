-- Performance indexes for notification-service
-- Composite (user_id, type): supports fetching notifications for a user filtered by type
CREATE INDEX IF NOT EXISTS idx_notifications_user_type
    ON notification_mgmt.notifications(user_id, type);
