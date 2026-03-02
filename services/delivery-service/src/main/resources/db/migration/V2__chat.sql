CREATE TABLE delivery_mgmt.chat_messages (
    id           UUID        PRIMARY KEY,
    delivery_id  UUID        NOT NULL REFERENCES delivery_mgmt.deliveries(id) ON DELETE CASCADE,
    sender_id    UUID        NOT NULL,
    sender_role  VARCHAR(20) NOT NULL,
    body         TEXT        NOT NULL,
    sent_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_chat_delivery ON delivery_mgmt.chat_messages(delivery_id, sent_at DESC);
