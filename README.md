# MotoHub – DevOps Tools & Cloud (FIAP)

Aplicação **Java Spring Boot (Java 17)** para gestão de motos (CRUD via Web MVC/Thymeleaf), implantada na Azure usando **App Service** e **banco PaaS (Azure Database for MySQL)**.

---

## 1) Descrição da solução
Gerencia motos, clientes e intenções com operações de cadastro, listagem, edição e remoção (CRUD). O foco da sprint é mostrar o ciclo DevOps em nuvem (deploy, banco PaaS, CI/CD e observabilidade).

## 2) Benefícios para o negócio
- Centraliza o cadastro de ativos (motos) e clientes.
- Padroniza operações CRUD e reduz retrabalho.
- Base confiável para relatórios e indicadores operacionais.
- Infra PaaS simplifica operação e reduz custo de manutenção.

## 3) Arquitetura (visão geral)
- **Azure App Service (Linux, Java 17)** – hospeda a aplicação.
- **Azure Database for MySQL – Flexible Server** – persistência PaaS.
- **GitHub Actions** – CI/CD (build Maven e deploy automático).
- **Application Insights** – observabilidade (logs/telemetria).

---

## 4) Como rodar localmente (dev)

Pré-requisitos: **JDK 17**, **Maven** (ou Maven Wrapper), **Git**.

Build:
    
    ./mvnw clean verify

Run:

    ./mvnw spring-boot:run

---

## 5) Estrutura de pastas (resumo)
- `src/main/java/...` – código da aplicação.
- `src/main/resources/db/migration` – migrations **Flyway**.
- `scripts/` – **Azure CLI** (será adicionado nas próximas fases).
- `script_bd.sql` – **DDL** consolidada (será adicionado na Fase 2).
- `.github/workflows/` – pipeline **GitHub Actions** (Fase 5).
