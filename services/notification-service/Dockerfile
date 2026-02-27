FROM maven:3.9-eclipse-temurin-21-jammy AS build
WORKDIR /app
COPY pom.xml .
COPY shared ./shared
COPY services ./services
RUN mvn -pl services/notification-service -am clean package -DskipTests

FROM eclipse-temurin:21-jre
WORKDIR /opt/app
RUN useradd -m zimbite
USER zimbite
COPY --from=build /app/services/notification-service/target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
