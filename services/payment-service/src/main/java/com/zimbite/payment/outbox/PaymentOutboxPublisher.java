package com.zimbite.payment.outbox;

import com.zimbite.payment.model.entity.PaymentOutboxEventEntity;
import com.zimbite.payment.repository.PaymentOutboxEventRepository;
import jakarta.transaction.Transactional;
import java.util.List;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.PageRequest;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

@Service
public class PaymentOutboxPublisher {

  private final PaymentOutboxEventRepository outboxEventRepository;
  private final KafkaTemplate<String, String> kafkaTemplate;
  private final boolean enabled;
  private final int batchSize;

  public PaymentOutboxPublisher(
      PaymentOutboxEventRepository outboxEventRepository,
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

    List<PaymentOutboxEventEntity> batch = outboxEventRepository.findByPublishedFalseOrderByCreatedAtAsc(
        PageRequest.of(0, batchSize)
    );

    for (PaymentOutboxEventEntity event : batch) {
      kafkaTemplate.send(event.getEventType(), event.getAggregateId().toString(), event.getPayload()).join();
      event.setPublished(true);
    }
  }
}
