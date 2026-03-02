package com.zimbite.delivery.controller;

import com.zimbite.delivery.model.dto.ChatMessageResponse;
import com.zimbite.delivery.model.dto.ChatSendRequest;
import com.zimbite.delivery.model.dto.LocationBroadcastMessage;
import com.zimbite.delivery.model.dto.UpdateDeliveryLocationRequest;
import com.zimbite.delivery.model.entity.ChatMessageEntity;
import com.zimbite.delivery.repository.ChatMessageRepository;
import com.zimbite.delivery.service.DeliveryService;
import java.time.Instant;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.UUID;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

@Controller
public class RiderWebSocketController {

    private final SimpMessagingTemplate messagingTemplate;
    private final DeliveryService deliveryService;
    private final ChatMessageRepository chatMessageRepository;

    public RiderWebSocketController(
            SimpMessagingTemplate messagingTemplate,
            DeliveryService deliveryService,
            ChatMessageRepository chatMessageRepository) {
        this.messagingTemplate = messagingTemplate;
        this.deliveryService = deliveryService;
        this.chatMessageRepository = chatMessageRepository;
    }

    @MessageMapping("/rider.location")
    public void handleLocationUpdate(@Payload LocationBroadcastMessage msg) {
        UpdateDeliveryLocationRequest locationReq = new UpdateDeliveryLocationRequest(
                msg.lat(),
                msg.lng(),
                OffsetDateTime.ofInstant(
                        Instant.ofEpochMilli(msg.timestamp()),
                        ZoneOffset.UTC));
        try {
            deliveryService.recordLocation(msg.deliveryId(), locationReq);
        } catch (Exception e) {
            // Log and continue — don't break the WS connection on invalid location
        }
        messagingTemplate.convertAndSend(
                "/topic/delivery/" + msg.deliveryId() + "/location", msg);
    }

    @MessageMapping("/chat/{deliveryId}")
    public void handleChatMessage(
            @DestinationVariable String deliveryId,
            @Payload ChatSendRequest req) {
        ChatMessageEntity entity = new ChatMessageEntity();
        entity.setId(UUID.randomUUID());
        entity.setDeliveryId(UUID.fromString(deliveryId));
        entity.setSenderId(req.senderId());
        entity.setSenderRole(req.senderRole());
        entity.setBody(req.body());
        entity.setSentAt(OffsetDateTime.now());
        chatMessageRepository.save(entity);

        ChatMessageResponse response = new ChatMessageResponse(
                entity.getId(), entity.getDeliveryId(), entity.getSenderId(),
                entity.getSenderRole(), entity.getBody(), entity.getSentAt());
        messagingTemplate.convertAndSend("/topic/chat/" + deliveryId, response);
    }
}
