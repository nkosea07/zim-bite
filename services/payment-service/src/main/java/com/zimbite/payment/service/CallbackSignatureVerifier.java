package com.zimbite.payment.service;

import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.util.HexFormat;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class CallbackSignatureVerifier {

  private final boolean enabled;
  private final Map<String, String> secretsByProvider;

  public CallbackSignatureVerifier(
      @Value("${payment.callbacks.signature-enabled:false}") boolean enabled,
      @Value("${payment.callbacks.ecocash-secret:}") String ecocashSecret,
      @Value("${payment.callbacks.onemoney-secret:}") String onemoneySecret,
      @Value("${payment.callbacks.card-secret:}") String cardSecret
  ) {
    this.enabled = enabled;
    this.secretsByProvider = Map.of(
        "ECOCASH", ecocashSecret == null ? "" : ecocashSecret.trim(),
        "ONEMONEY", onemoneySecret == null ? "" : onemoneySecret.trim(),
        "CARD", cardSecret == null ? "" : cardSecret.trim()
    );
  }

  public boolean verify(String provider, UUID paymentId, String outcome, String signature) {
    if (!enabled) {
      return true;
    }
    if (signature == null || signature.isBlank()) {
      return false;
    }

    String providerKey = provider.trim().toUpperCase(Locale.ROOT);
    String secret = secretsByProvider.getOrDefault(providerKey, "");
    if (secret.isBlank()) {
      return false;
    }

    String payload = providerKey + ":" + paymentId + ":" + outcome.trim().toUpperCase(Locale.ROOT);
    String expected = hmacSha256(secret, payload);
    return MessageDigest.isEqual(
        expected.getBytes(StandardCharsets.UTF_8),
        signature.trim().toLowerCase(Locale.ROOT).getBytes(StandardCharsets.UTF_8)
    );
  }

  private String hmacSha256(String secret, String payload) {
    try {
      Mac mac = Mac.getInstance("HmacSHA256");
      mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
      return HexFormat.of().formatHex(mac.doFinal(payload.getBytes(StandardCharsets.UTF_8)));
    } catch (GeneralSecurityException e) {
      throw new IllegalStateException("Failed to compute callback signature", e);
    }
  }
}
