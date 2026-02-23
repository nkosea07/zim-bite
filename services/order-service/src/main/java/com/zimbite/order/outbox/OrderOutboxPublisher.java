package com.zimbite.order.outbox;

import com.zimbite.order.model.entity.OrderOutboxEventEntity;
import com.zimbite.order.repository.OrderOutboxEventRepository;
import jakarta.transaction.Transactional;
import java.util.List;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.PageRequest;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

@Service
public class OrderOutboxPublisher {

  private final OrderOutboxEventRepository outboxEventRepository;
  private final KafkaTemplate<String, String> kafkaTemplate;
  private final boolean enabled;
  private final int batchSize;

  public OrderOutboxPublisher(
      OrderOutboxEventRepository outboxEventRepository,
      KafkaTemplate<String, String> kafkaTemplate,
      @Value("${outbox.publisher.enabled:false}") boolean enabled,
      @Value("${outbox.publisher.batch-size:50}") int batchSize
  ) {
    this.outboxEventRepository = outboxEventRepository;
    this.kafkaTemplate = kafkaTemplate;
    this.enabled = enabled;
    this.batchSize = batchSize;
  }

  @Scheduled(fixedDelayString = "${outbox.publisher.fixed-delay-ms:5000}")
  @Transactional
  public void publishPending() {
    if (!enabled) {
      return;
    }

    List<OrderOutboxEventEntity> batch = outboxEventRepository.findByPublishedFalseOrderByCreatedAtAsc(
        PageRequest.of(0, batchSize)
    );

    for (OrderOutboxEventEntity event : batch) {
      kafkaTemplate.send(event.getEventType(), event.getAggregateId().toString(), event.getPayload()).join();
      event.setPublished(true);
    }
  }
}
