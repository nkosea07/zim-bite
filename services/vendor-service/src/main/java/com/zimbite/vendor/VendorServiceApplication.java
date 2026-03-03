package com.zimbite.vendor;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;

@EnableCaching
@SpringBootApplication
public class VendorServiceApplication {
  public static void main(String[] args) {
    SpringApplication.run(VendorServiceApplication.class, args);
  }
}
