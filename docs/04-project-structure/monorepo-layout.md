# Monorepo Layout

```
zimbite/
  pom.xml                                    # Parent POM — dependency management, module list
  docker-compose.yml                         # Local dev: PostgreSQL, Redis, Kafka, Zookeeper
  docker-compose.services.yml                # All 11 services for local integration testing
  Makefile                                   # Convenience: make build, make test, make up, make down
  .gitignore
  .editorconfig

  services/
    api-gateway/
      pom.xml
      Dockerfile
      src/main/java/com/zimbite/gateway/
        GatewayApplication.java
        config/
          RouteConfig.java                   # Route definitions to downstream services
          RateLimitConfig.java
          CorsConfig.java
          SecurityConfig.java                # JWT validation filter
        filter/
          JwtAuthFilter.java
          RequestLoggingFilter.java
      src/main/resources/
        application.yml
        application-dev.yml
        application-prod.yml

    auth-service/
      pom.xml
      Dockerfile
      src/main/java/com/zimbite/auth/
        AuthServiceApplication.java
        config/
          SecurityConfig.java
          JwtConfig.java
        controller/
          AuthController.java
        service/
          AuthService.java
          TokenService.java
          OtpService.java
        repository/
          RefreshTokenRepository.java
        model/
          entity/
            RefreshToken.java
          dto/
            RegisterRequest.java
            LoginRequest.java
            LoginResponse.java
            TokenRefreshRequest.java
        exception/
          InvalidCredentialsException.java
          TokenExpiredException.java
      src/main/resources/
        application.yml
      src/test/java/com/zimbite/auth/
        controller/
          AuthControllerTest.java
        service/
          AuthServiceTest.java
          TokenServiceTest.java

    user-service/
      pom.xml
      Dockerfile
      src/main/java/com/zimbite/user/
        UserServiceApplication.java
        config/
        controller/
          UserController.java
          AddressController.java
          FavoriteController.java
        service/
          UserService.java
          AddressService.java
        repository/
          UserRepository.java
          UserAddressRepository.java
          UserFavoriteRepository.java
        model/
          entity/
            User.java
            Corporate.java
            UserAddress.java
            UserFavorite.java
          dto/
            UserProfileResponse.java
            UpdateProfileRequest.java
            AddressRequest.java
        mapper/
          UserMapper.java                    # MapStruct mapper
        exception/
      src/main/resources/
        application.yml
      src/test/

    vendor-service/
      pom.xml
      Dockerfile
      src/main/java/com/zimbite/vendor/
        VendorServiceApplication.java
        controller/
          VendorController.java
        service/
          VendorService.java
          VendorSearchService.java           # PostGIS geo queries
        repository/
          VendorRepository.java
          VendorOperatingDayRepository.java
        model/
          entity/
            Vendor.java
            VendorOperatingDay.java
          dto/
            VendorListResponse.java          # Lite version for list views
            VendorDetailResponse.java
            CreateVendorRequest.java
            VendorStatsResponse.java
        mapper/
        exception/
      src/main/resources/
      src/test/

    menu-service/
      pom.xml
      Dockerfile
      src/main/java/com/zimbite/menu/
        MenuServiceApplication.java
        controller/
          MenuItemController.java
          CategoryController.java
        service/
          MenuItemService.java
          CategoryService.java
          InventoryService.java
        repository/
          MenuItemRepository.java
          MenuCategoryRepository.java
          MenuItemComponentRepository.java
          InventoryRepository.java
        model/
          entity/
            MenuItem.java
            MenuCategory.java
            MenuItemComponent.java
            Inventory.java
          dto/
            MenuItemListResponse.java        # Lite: id, name, price, thumbnail
            MenuItemDetailResponse.java      # Full: components, nutrition, allergens
            CreateMenuItemRequest.java
        mapper/
        exception/
      src/main/resources/
      src/test/

    meal-builder-service/
      pom.xml
      Dockerfile
      src/main/java/com/zimbite/mealbuilder/
        MealBuilderApplication.java
        controller/
          MealBuilderController.java
          PresetController.java
        service/
          PriceCalculationService.java
          AvailabilityValidationService.java
          NutritionCalculationService.java
          RecommendationService.java
          PresetService.java
        client/
          MenuServiceClient.java             # Feign client to Menu Service
        model/
          dto/
            CalculateRequest.java
            CalculateResponse.java
            ValidateRequest.java
            ValidateResponse.java
            PresetResponse.java
        repository/
          SavedMealPresetRepository.java
      src/main/resources/
      src/test/

    order-service/
      pom.xml
      Dockerfile
      src/main/java/com/zimbite/order/
        OrderServiceApplication.java
        controller/
          OrderController.java
          CorporateOrderController.java
        service/
          OrderService.java
          OrderNumberGenerator.java          # ZB-YYYYMMDD-NNNN format
          OrderStatusService.java
        repository/
          OrderRepository.java
          OrderItemRepository.java
          OrderStatusHistoryRepository.java
        model/
          entity/
            Order.java
            OrderItem.java
            OrderStatusHistory.java
          dto/
            PlaceOrderRequest.java
            OrderResponse.java
            OrderStatusResponse.java
            CorporateOrderRequest.java
        event/
          producer/
            OrderEventProducer.java          # Publishes to Kafka
          consumer/
            PaymentEventConsumer.java
            DeliveryEventConsumer.java
        client/
          MenuServiceClient.java
          PaymentServiceClient.java
        mapper/
        exception/
      src/main/resources/
      src/test/

    payment-service/
      pom.xml
      Dockerfile
      src/main/java/com/zimbite/payment/
        PaymentServiceApplication.java
        controller/
          PaymentController.java
          PaymentCallbackController.java     # Webhook endpoints
          PaymentMethodController.java
        service/
          PaymentService.java
          RefundService.java
          EcoCashService.java
          OneMoneyService.java
          StripeService.java
        repository/
          PaymentRepository.java
          PaymentMethodSavedRepository.java
        model/
          entity/
            Payment.java
            PaymentMethodSaved.java
          dto/
            InitiatePaymentRequest.java
            PaymentStatusResponse.java
            EcoCashCallbackPayload.java
            OneMoneyCallbackPayload.java
        event/
          producer/
            PaymentEventProducer.java
        exception/
          PaymentFailedException.java
          DuplicatePaymentException.java
      src/main/resources/
      src/test/

    delivery-service/
      pom.xml
      Dockerfile
      src/main/java/com/zimbite/delivery/
        DeliveryServiceApplication.java
        controller/
          DeliveryController.java
          RiderController.java
        service/
          DeliveryService.java
          RiderAssignmentService.java        # Nearest available rider (PostGIS)
          RouteOptimizationService.java
          EtaCalculationService.java
        repository/
          DeliveryRepository.java
          RiderRepository.java
          DeliveryTrackingRepository.java
        model/
          entity/
            Delivery.java
            Rider.java
            DeliveryTracking.java
          dto/
            DeliveryResponse.java
            RiderLocationUpdate.java
            TrackingPointResponse.java
        event/
          producer/
            DeliveryEventProducer.java
          consumer/
            OrderEventConsumer.java
        exception/
      src/main/resources/
      src/test/

    notification-service/
      pom.xml
      Dockerfile
      src/main/java/com/zimbite/notification/
        NotificationServiceApplication.java
        controller/
          NotificationController.java
        service/
          NotificationService.java
          PushNotificationService.java       # Firebase Cloud Messaging
          SmsService.java                    # SMS via Twilio or local provider
          EmailService.java                  # SMTP / SendGrid
        repository/
          NotificationRepository.java
          NotificationPreferenceRepository.java
        model/
          entity/
            Notification.java
            NotificationPreference.java
          dto/
        event/
          consumer/
            OrderEventConsumer.java
            PaymentEventConsumer.java
            DeliveryEventConsumer.java
      src/main/resources/
      src/test/

    analytics-service/
      pom.xml
      Dockerfile
      src/main/java/com/zimbite/analytics/
        AnalyticsServiceApplication.java
        controller/
          VendorAnalyticsController.java
          AdminAnalyticsController.java
        service/
          VendorAnalyticsService.java
          PlatformAnalyticsService.java
          RevenueService.java
        repository/
          AnalyticsEventRepository.java
        model/
          entity/
            AnalyticsEvent.java
          dto/
            VendorDashboardResponse.java
            AdminOverviewResponse.java
            RevenueReportResponse.java
        event/
          consumer/
            AnalyticsEventConsumer.java      # Consumes all domain events
      src/main/resources/
      src/test/

  shared/
    common-dto/
      pom.xml
      src/main/java/com/zimbite/common/dto/
        ApiResponse.java                     # Standard wrapper: {data, error, meta}
        ApiError.java                        # {code, message, details[], traceId}
        PageRequest.java                     # Cursor-based pagination params
        PageResponse.java                    # {items[], nextCursor, hasMore}
        FieldSelector.java                   # Sparse fieldset parser

    common-utils/
      pom.xml
      src/main/java/com/zimbite/common/utils/
        DateUtils.java                       # Zimbabwe timezone (CAT, UTC+2) helpers
        SlugGenerator.java
        PhoneNumberValidator.java            # Zimbabwe phone format (+263...)
        CoordinateUtils.java                 # Distance calculation helpers

    common-security/
      pom.xml
      src/main/java/com/zimbite/common/security/
        JwtTokenProvider.java
        JwtAuthenticationFilter.java
        SecurityConstants.java
        CurrentUserProvider.java             # Extract user from SecurityContext
        RoleConstants.java                   # CUSTOMER, VENDOR_ADMIN, etc.

    common-messaging/
      pom.xml
      src/main/java/com/zimbite/common/messaging/
        BaseEvent.java                       # eventId, eventType, timestamp, source
        OrderCreatedEvent.java
        OrderStatusChangedEvent.java
        PaymentCompletedEvent.java
        PaymentFailedEvent.java
        DeliveryAssignedEvent.java
        DeliveryStatusChangedEvent.java
        KafkaTopics.java                     # Topic name constants
        KafkaProducerConfig.java
        KafkaConsumerConfig.java

  frontend/
    web/
      package.json
      vite.config.ts
      tsconfig.json
      index.html
      public/
        favicon.ico
        manifest.json
      src/
        main.tsx
        App.tsx
        router.tsx                           # React Router configuration
        routes/
          customer/
            Home.tsx
            VendorList.tsx
            VendorDetail.tsx
            MealBuilder.tsx
            Cart.tsx
            Checkout.tsx
            OrderTracking.tsx
            OrderHistory.tsx
            Profile.tsx
            Subscriptions.tsx
          vendor/
            Dashboard.tsx
            MenuManagement.tsx
            OrderQueue.tsx
            Analytics.tsx
            Settings.tsx
          rider/
            ActiveDeliveries.tsx
            DeliveryDetail.tsx
            History.tsx
          admin/
            Overview.tsx
            VendorManagement.tsx
            Revenue.tsx
        components/
          meal-builder/
            MealBuilderCanvas.tsx            # @dnd-kit drop zone
            DraggableItem.tsx
            ItemCard.tsx
            PriceSummary.tsx
            NutritionPanel.tsx
          map/
            DeliveryMap.tsx                   # Leaflet or Mapbox
            RiderMarker.tsx
          ui/
            Button.tsx
            Input.tsx
            Card.tsx
            Modal.tsx
            Skeleton.tsx                     # Loading skeleton screens
            Badge.tsx
          layout/
            AppShell.tsx
            Sidebar.tsx
            BottomNav.tsx                    # Mobile navigation
            Header.tsx
        lib/
          api/
            client.ts                        # Axios instance with interceptors
            auth.ts
            users.ts
            vendors.ts
            menus.ts
            orders.ts
            payments.ts
            deliveries.ts
          hooks/
            useAuth.ts
            useVendors.ts
            useMenu.ts
            useOrders.ts
            useGeolocation.ts
          store/
            authStore.ts                     # Zustand
            cartStore.ts
            mealBuilderStore.ts
          utils/
            currency.ts                      # Format USD/ZWL
            date.ts                          # Zimbabwe timezone
            offline.ts                       # Service worker helpers
        types/
          user.ts
          vendor.ts
          menu.ts
          order.ts
          payment.ts
          delivery.ts
        styles/
          globals.css
          tailwind.config.ts
        sw.ts                                # Service worker for offline support

  infrastructure/
    k8s/
      base/
        namespace.yaml
        api-gateway.yaml
        auth-service.yaml
        user-service.yaml
        vendor-service.yaml
        menu-service.yaml
        meal-builder-service.yaml
        order-service.yaml
        payment-service.yaml
        delivery-service.yaml
        notification-service.yaml
        analytics-service.yaml
        ingress.yaml
        configmap.yaml
        secrets.yaml
      overlays/
        dev/
          kustomization.yaml
        staging/
          kustomization.yaml
        production/
          kustomization.yaml
    helm/
      zimbite/
        Chart.yaml
        values.yaml
        values-staging.yaml
        values-production.yaml
        templates/
    terraform/
      main.tf
      variables.tf
      outputs.tf
      modules/
        kubernetes/
        database/
        redis/
        kafka/
    monitoring/
      prometheus/
        prometheus.yml
        alert-rules.yml
      grafana/
        dashboards/
          platform-overview.json
          service-health.json
          order-metrics.json
        datasources.yml
      alertmanager/
        config.yml

  docs/                                      # Architecture documentation (this directory)

  scripts/
    db-migrate.sh                            # Run SQL migrations in order
    seed-data.sh                             # Load seed data
    health-check.sh                          # Check all service health endpoints
    generate-order-number.sh                 # Test order number generation

  .github/
    workflows/
      ci.yml                                 # Lint, compile, test, scan on PR
      cd-staging.yml                         # Deploy to staging on merge to main
      cd-production.yml                      # Deploy to prod with manual approval
    CODEOWNERS
    pull_request_template.md
```

## Module Dependencies

```
common-dto          (no deps)
common-utils        (no deps)
common-security     -> common-dto
common-messaging    -> common-dto
each service        -> common-dto, common-utils, common-security, common-messaging
api-gateway         -> common-security (JWT validation only)
```

## Parent POM Structure

The parent `pom.xml` manages:
- Spring Boot version (3.2.x)
- Java 21
- Shared dependency versions (PostgreSQL driver, Redis, Kafka, MapStruct, Lombok, etc.)
- Plugin management (Spring Boot Maven Plugin, Dockerfile Maven Plugin)
- Module list for all services and shared libraries

## Build Commands

| Command | Description |
|---------|-------------|
| `mvn clean install` | Build all modules |
| `mvn clean install -pl services/order-service -am` | Build single service with dependencies |
| `mvn test` | Run all unit tests |
| `mvn verify` | Run unit + integration tests |
| `docker-compose up -d` | Start infrastructure (PostgreSQL, Redis, Kafka) |
| `docker-compose -f docker-compose.services.yml up` | Start all services |
