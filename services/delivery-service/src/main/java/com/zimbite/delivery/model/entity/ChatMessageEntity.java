package com.zimbite.delivery.model.entity;

import jakarta.persistence.*;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "chat_messages", schema = "delivery_mgmt")
public class ChatMessageEntity {

    @Id
    private UUID id;

    @Column(name = "delivery_id", nullable = false)
    private UUID deliveryId;

    @Column(name = "sender_id", nullable = false)
    private UUID senderId;

    @Column(name = "sender_role", nullable = false)
    private String senderRole;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String body;

    @Column(name = "sent_at", nullable = false)
    private OffsetDateTime sentAt;

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UUID getDeliveryId() { return deliveryId; }
    public void setDeliveryId(UUID deliveryId) { this.deliveryId = deliveryId; }

    public UUID getSenderId() { return senderId; }
    public void setSenderId(UUID senderId) { this.senderId = senderId; }

    public String getSenderRole() { return senderRole; }
    public void setSenderRole(String senderRole) { this.senderRole = senderRole; }

    public String getBody() { return body; }
    public void setBody(String body) { this.body = body; }

    public OffsetDateTime getSentAt() { return sentAt; }
    public void setSentAt(OffsetDateTime sentAt) { this.sentAt = sentAt; }
}
