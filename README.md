# Docker Compose Files

Ready-to-run Docker Compose setups for the services a developer needs on a laptop: databases, brokers,
identity, mocks and tools. Every folder is one setup.

## Start a service

```bash
cd postgres
cp .env.example .env      # only once; change the passwords in .env if you like
docker compose up         # Ctrl+C stops it
```

Or pick from a list: `selectAndStart.bat` (Windows) or `sh selectAndStart.sh` (Linux, macOS). Both copy
`.env.example` to `.env` when it is missing.

Passwords are not written in the compose files any more; they come from the `.env` file of the folder
(which git ignores). Compose stops with "copy .env.example to .env" when it is missing.

## What is inside

| Folder | Image | Host ports | Notes |
|---|---|---|---|
| activemq | apache/activemq-classic:6.2.0 | 61616, 8161 (console), 5673 (AMQP), 61613, 1883 | |
| artemis | apache/activemq-artemis:2.44.0-alpine | 61616, 8161 (console) | alternative to activemq |
| httpd | httpd:2.4.71-alpine | 8088 | |
| httpwithsftp | openssh-server + httpd | 2223 (SFTP), 8089 (HTTP) | files uploaded over SFTP are served over HTTP |
| kafkanativewithui | apache/kafka-native:4.4.0, kafbat/kafka-ui:v1.5.0 | 9092, 8085 (UI, local only) | one KRaft node |
| kafkawithoutzookeper | apache/kafka:4.4.0, kafbat/kafka-ui:v1.5.0 | 9092, 9094, 8085 (UI, local only) | two KRaft nodes; alternative to kafkanativewithui |
| keycloak | quay.io/keycloak/keycloak:26.8, postgres | 8180 | |
| liquibase | liquibase/liquibase:4.33, postgres | 5433 (PostgreSQL) | see below |
| mongodb | mongodb-community-server:8.0, mongo-express | 27017, 8081 (UI, local only) | |
| mysql | mysql:8.4 | 3306 | |
| portainer | portainer/portainer-ce:2.45.3-alpine | 9443 (HTTPS) | |
| postgres | postgres:18-alpine | 5432 | |
| rabbitmq | rabbitmq:4.4-management-alpine | 5672, 15672 (UI) | |
| redis | redis:8.8-alpine | 6379 | |
| sftp | openssh-server | 2222 | |
| sonarqube | sonarqube community build, postgres:17 | 9000 | |
| wiremock | wiremock/wiremock:3.13.2-alpine | 8091 | stubs in `mappings/`, try `/hello` |
| zipkin | openzipkin/zipkin:3.6 | 9411 | |

Folders that are alternatives of each other (activemq/artemis, the two Kafka folders) use the same ports;
all others can run at the same time. UIs without a login listen on `127.0.0.1` only.

### Liquibase

The `liquibase` folder holds what used to be the `poc-liquibase-docker` repository.

```bash
cd liquibase && cp .env.example .env
docker compose up                        # PostgreSQL + "update": runs every changelog in changelog/scripts
docker compose run --rm generate         # writes the schema to generate/changelog-generate.xml
docker compose run --rm liquibase status # change sets that have not run yet
```

Liquibase stays on 4.33, the last version of the community edition under the Apache License.

## Changes in this version

- Every image has a fixed version; nothing uses `latest` any more.
- `bitnami/kafka` and `bitnami/rabbitmq` were replaced by the official `apache/kafka` and `rabbitmq` images.
  Bitnami stopped publishing these images for free in 2025.
- Host ports no longer collide. Castle Mock, WireMock, Kafka UI and Keycloak all used 8080; Portainer and
  SonarQube both used 9000. The new ports are in the table above.
- `castlemock` was removed: Castle Mock was archived in 2025 and its Docker images were deleted.
  Use `wiremock` instead.
- PostgreSQL 18 cannot open a data volume made by PostgreSQL 17. To keep an existing volume, set
  `POSTGRES_VERSION=17` in `.env`, or move the data with `pg_dump` and `pg_restore`.

## Useful commands

```bash
docker compose down                     # stop and remove the containers
docker compose down -v                  # ... and the volumes (deletes the data)
docker compose up --force-recreate      # recreate the containers
docker compose pull                     # get newer images of the pinned versions
```

`sh scripts/check.sh` validates every compose file and checks that no two folders publish the same port;
`sh scripts/check.sh --images` also checks that every image tag exists. CI runs both.

## License

Copyright 2025 Mehmet ERGULCU. Licensed under the [Apache License 2.0](LICENSE).
