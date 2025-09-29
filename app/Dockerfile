# ---- stage build (igual ao seu) ----
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /workspace
COPY pom.xml .
COPY src ./src
RUN mvn -B -e -DskipTests clean package

# ---- stage runtime ----
FROM eclipse-temurin:17-jre

RUN apt-get update && apt-get install -y default-mysql-client && rm -rf /var/lib/apt/lists/*

RUN addgroup --system app && adduser --system --ingroup app --home /home/app app

WORKDIR /app

# jar
COPY --from=build /workspace/target/*.jar /app/app.jar

# entrypoint (agora DENTRO de /app)
COPY docker/entrypoint.sh /app/entrypoint.sh
# normaliza EOL (se vier com CRLF no repo) e dá permissão
RUN sed -i 's/\r$//' /app/entrypoint.sh && chmod 755 /app/entrypoint.sh && chown -R app:app /app

ENV JAVA_OPTS="" \
    APP_PORT=8080

EXPOSE 8080
USER app

ENTRYPOINT ["/app/entrypoint.sh"]
