#!/bin/sh

docker run --name gitlab_graphs_postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_USER=postgres -p 5432:5432 -d postgres:alpine
