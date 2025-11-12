# Login Node + React (Dockerized)

This repository contains a minimal login application:
- backend: Node.js + Express + PostgreSQL (JWT auth)
- frontend: React (Vite) built and served by nginx

Everything is designed to run with Docker / Docker Compose. CI builds push images to Docker Hub.

Quick start (requires Docker):

1. Copy environment example for backend (optional):

   # edit values if needed
   cp backend/.env.example backend/.env

2. Start with docker-compose:

   docker compose up --build

This will:
- start Postgres on port 5432 (internal)
- start backend on port 4000
- start frontend served on port 3000

CI: The GitHub Actions workflow at `.github/workflows/ci.yml` builds and pushes two images to Docker Hub. Set the following repository secrets:
- DOCKERHUB_USERNAME
- DOCKERHUB_TOKEN
