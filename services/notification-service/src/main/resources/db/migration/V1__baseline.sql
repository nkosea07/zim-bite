CREATE SCHEMA IF NOT EXISTS notification_mgmt;

CREATE TABLE IF NOT EXISTS notification_mgmt.notifications (
    id          UUID PRIMARY KEY,
    user_id     UUID         NOT NULL,
    type        VARCHAR(60)  NOT NULL,
    message     TEXT         NOT NULL,
    is_read     BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notification_mgmt.notifications(user_id, created_at DESC);
CREATE INDEX idx_notifications_unread ON notification_mgmt.notifications(user_id) WHERE is_read = FALSE;

CREATE TABLE IF NOT EXISTS notification_mgmt.notification_preferences (
    id              UUID PRIMARY KEY,
    user_id         UUID    NOT NULL UNIQUE,
    push_enabled    BOOLEAN NOT NULL DEFAULT TRUE,
    sms_enabled     BOOLEAN NOT NULL DEFAULT TRUE,
    email_enabled   BOOLEAN NOT NULL DEFAULT FALSE,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
