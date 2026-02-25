package com.zimbite.subscription.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class PingController {
  @GetMapping("/internal/ping")
  public String ping() {
    return "subscription-service:ok";
  }
}
