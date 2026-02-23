package com.zimbite.shared.utils;

import java.time.OffsetDateTime;

public final class TimeUtils {
  private TimeUtils() {
  }

  public static OffsetDateTime nowUtc() {
    return OffsetDateTime.now();
  }
}
