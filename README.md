# Motohub – DevOps (ACR + ACI)

Este repositório contém a entrega da disciplina **DevOps Tools & Cloud Computing** (ACR + ACI) usando **Java (Spring Boot)** e **MySQL PaaS**.

## 🧭 Como executar (resumo)
1. Copie `infra/.env.example` para `infra/.env` e preencha variáveis.
2. Crie grupo de recursos: `infra/01_rg.sh`
3. Crie MySQL: `infra/02_mysql_create.sh`
4. Crie ACR: `infra/03_acr_create.sh`
5. Faça build/push da imagem: `infra/04_build_push.sh`
6. Faça deploy no ACI: `infra/05_aci_deploy.sh`
7. Libere firewall do MySQL (se necessário): `infra/06_mysql_firewall_allow.sh`
8. Teste CRUD: `tests/curl-moto.sh`

> **A aplicação** (código Java) fica em `app/`.
> **O banco** é MySQL PaaS.

## 🧪 Testes
Veja `tests/curl-moto.sh` para exemplos (ajuste os endpoints conforme seu app).

## 🗃️ DDL
Veja `script_bd.sql` (DDL comentada).
