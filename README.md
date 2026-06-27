# Docker Container Starter Project

A complete Docker Compose setup for a modern development environment with multiple data storage and management tools. This project provides both a **Storage Stack** with databases and message brokers, and a **UI Stack** with administrative interfaces for managing the services.

## 📋 Overview

This starter project includes:

- **Databases**: PostgreSQL, MongoDB
- **Caching**: Redis
- **Object Storage**: MinIO (S3-compatible)
- **Message Queue**: Kafka with Zookeeper
- **Management UIs**: PgAdmin, Mongo Express, RedisInsight, Kafka UI

All services are containerized and managed via Docker Compose with persistent volumes and a shared network.

## 🗂️ Project Structure

```
.
├── README.md                      # This file
├── config.sh                      # Helper script for volume and network management
├── run.sh                         # Main script to start/stop services
├── docker-compose.storage.yml     # Storage services configuration
├── docker-compose.ui.yml          # Management UI services configuration
├── kubernete/                     # Kubernetes deployment files
│   ├── headlamp-admin.yaml
│   ├── headlamp-ingress.yaml
│   ├── ingress.yaml
│   ├── installl.md
│   └── note.txt
└── .env                           # Environment variables (create this file)
```

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose installed
- Bash shell
- Unix-like system (Linux, macOS, or WSL2 on Windows)

### 1. Configure Environment File

Update `.env` file in the project root with your configuration:


### 2. Initialize Volumes and Network

The project requires Docker volumes and a network to be pre-created:

```bash
bash config.sh
```

This script will create:
- Docker volumes: `postgres-data`, `mongo-data`, `redis-data`, `minio-data`, `kafka-data`
- Docker network: `app-net`

### 3. Start Services

#### Start Storage Stack Only
```bash
./run.sh up storage
```

#### Start UI Stack Only
```bash
./run.sh up ui
```

#### Start Everything
```bash
./run.sh up all
```

#### Stop Services
```bash
./run.sh down storage
./run.sh down ui
./run.sh down all
```

## 📊 Services & Access

### Storage Services

| Service | Container | Port | Purpose |
|---------|-----------|------|---------|
| PostgreSQL | `postgres` | `5432` | Relational database |
| MongoDB | `mongo` | `27017` | NoSQL document database |
| Redis | `redis` | `6379` | In-memory data store |
| MinIO | `minio` | `9000` / `9001` | S3-compatible object storage |
| Kafka | `kafka` | `9092` / `29092` | Message broker |
| Zookeeper | `zookeeper` | `2181` | Kafka coordination |

### UI Services

| Service | Container | Port | Access |
|---------|-----------|------|--------|
| PgAdmin | `pgadmin` | `8081` | http://localhost:8081 |
| Mongo Express | `mongo-express` | `8081` | http://localhost:8081 |
| RedisInsight | `redisinsight` | `5540` | http://localhost:5540 |
| Kafka UI | `kafka-ui` | `8083` | http://localhost:8083 |

### MinIO Console

Access MinIO console at: **http://localhost:9001**
- Username: `MINIO_ROOT_USER` from `.env`
- Password: `MINIO_ROOT_PASSWORD` from `.env`

## 📝 Usage Examples

### Connect to PostgreSQL

```bash
# Using psql
psql -h localhost -p 5432 -U postgres -d appdb

# Using PgAdmin
# Visit http://localhost:8081
# Username: admin@example.com
# Password: your_pgadmin_password
```

### Connect to MongoDB

```bash
# Using Mongo Express
# Visit http://localhost:8081
# Username: admin
# Password: your_mongo_express_password

# Using mongo shell (if installed)
mongo mongodb://mongoadmin:password@localhost:27017/
```

### Access Redis

```bash
# Using RedisInsight
# Visit http://localhost:5540

# Using redis-cli (if installed)
redis-cli -h localhost -p 6379 -a your_redis_password
```

### Upload to MinIO

```bash
# Using MinIO Console
# Visit http://localhost:9001

# Using AWS CLI
aws s3 --endpoint-url http://localhost:9000 ls s3://
```

### View Kafka Topics

```bash
# Using Kafka UI
# Visit http://localhost:8083
```

## 🔧 Helper Scripts

### config.sh

Manages Docker volumes and networks:

```bash
# Load environment variables
bash config.sh load_env

# Create all volumes
bash config.sh ensure_all_volumes

# Remove all volumes
bash config.sh remove_all_volumes

# Create network
bash config.sh ensure_network

# Remove network
bash config.sh remove_network
```

### run.sh

Manages service stacks:

```bash
# Start storage services
./run.sh up storage

# Stop storage services
./run.sh down storage

# Start UI services
./run.sh up ui

# Stop UI services
./run.sh down ui

# Start all services
./run.sh up all

# Stop all services
./run.sh down all
```

## 📦 Docker Compose Files

### docker-compose.storage.yml

Contains database, cache, object storage, and message broker services:
- PostgreSQL
- MongoDB
- Redis
- MinIO
- Kafka
- Zookeeper

### docker-compose.ui.yml

Contains management and administrative UI services:
- PgAdmin
- Mongo Express
- RedisInsight
- Kafka UI

## 🐳 Docker Compose Projects

Services are organized into two Docker Compose projects:

- **storage**: All data storage and messaging services
- **ui**: All management and UI services

This allows independent management of storage and UI components.

## 📂 Data Persistence

All services use Docker volumes for data persistence. Volumes are defined in the compose files and must be created before starting services:

```bash
docker volume create postgres-data
docker volume create mongo-data
docker volume create redis-data
docker volume create minio-data
docker volume create kafka-data
```

These volumes survive container restarts and removal, preserving your data.

## 🌐 Network

All services are connected via a Docker bridge network called `app-net`. This allows services to communicate with each other using container names as hostnames.

Create the network with:

```bash
docker network create app-net
```

## 🛑 Stopping and Cleanup

### Stop All Services

```bash
./run.sh down all
```

### Remove Volumes (⚠️ Warning: Data Loss)

```bash
bash config.sh remove_all_volumes
```

### Remove Network

```bash
docker network rm app-net
```

### Full Cleanup

```bash
./run.sh down all
bash config.sh remove_all_volumes
docker network rm app-net
```

## 🚀 Kubernetes Deployment

The `kubernete/` directory contains Kubernetes configuration files for deploying this stack to Kubernetes:

- `headlamp-admin.yaml`: Headlamp (Kubernetes dashboard)
- `headlamp-ingress.yaml`: Ingress for Headlamp
- `ingress.yaml`: General ingress configuration
- `installl.md`: Kubernetes installation guide

### Quick Kubernetes Setup

```bash
# Install kubectl and k3d (see kubernete/installl.md)
# Then deploy with kubectl
kubectl apply -f kubernete/
```

## 🔐 Security Notes

⚠️ **Important**: This is a starter/development setup. For production use:

1. Change all default passwords in `.env`
2. Use strong, unique passwords for each service
3. Implement proper network security and firewall rules
4. Enable authentication for all services
5. Use secrets management (e.g., HashiCorp Vault, AWS Secrets Manager)
6. Implement SSL/TLS for external connections
7. Set up proper backup and disaster recovery procedures
8. Use Docker secrets instead of environment variables for sensitive data

## 🐛 Troubleshooting

### Services Won't Start

```bash
# Check logs
docker logs <container-name>

# Verify network exists
docker network ls

# Verify volumes exist
docker volume ls

# Recreate network and volumes
bash config.sh ensure_all_volumes
bash config.sh ensure_network
```

### Port Already in Use

Modify the port mappings in `.env` or the compose files:

```bash
# Check which process is using the port
lsof -i :<port_number>

# Kill the process or change the port in .env
```

### Database Connection Issues

1. Ensure services are running: `docker ps`
2. Check network connectivity: `docker network inspect app-net`
3. Verify credentials in `.env`
4. Check service logs: `docker logs <service-name>`

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [MongoDB Documentation](https://docs.mongodb.com/)
- [Redis Documentation](https://redis.io/documentation)
- [MinIO Documentation](https://docs.min.io/)
- [Kafka Documentation](https://kafka.apache.org/documentation/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## 📄 License

This project is provided as-is for development purposes.

## 🤝 Contributing

Feel free to modify and extend this starter project for your needs.

---

**Happy coding!** 🚀
