# Deployment Guide

This guide covers deploying the Dwarf Fortress container on various platforms.

## Proxmox LXC Container

### Prerequisites

1. LXC container with Docker installed
2. Sufficient resources (recommended: 4GB RAM, 2 CPUs)
3. Network access for downloading packages

### Deployment Steps

```bash
# 1. Clone the repository
git clone https://github.com/username/dwarf-fortress-container.git
cd dwarf-fortress-container

# 2. Make sure Docker is running
sudo systemctl start docker
sudo systemctl enable docker

# 3. Add user to docker group (if not already done)
sudo usermod -aG docker $USER
# Log out and back in, or run: newgrp docker

# 4. Deploy with make
make quick-start

# Or deploy in background
make quick-start-detached
```

### Proxmox-Specific Configuration

```bash
# Enable nesting for Docker in LXC (run on Proxmox host)
pct set CONTAINER_ID -features nesting=1

# Increase container limits if needed
pct set CONTAINER_ID -memory 4096 -cores 2

# For VNC access, ensure port 5900 is accessible
# Add to LXC config or use port forwarding
```

## Docker Swarm / Kubernetes

### Docker Swarm

```yaml
# docker-stack.yml
version: '3.8'

services:
  dwarf-fortress:
    image: username/dwarf-fortress-ai:latest
    ports:
      - "5900:5900"
    volumes:
      - df_saves:/opt/dwarf-fortress/df/data/save
      - df_output:/opt/dwarf-fortress/output
    deploy:
      replicas: 1
      resources:
        limits:
          cpus: '2.0'
          memory: 4G
        reservations:
          cpus: '1.0'
          memory: 2G

volumes:
  df_saves:
  df_output:
```

Deploy with:
```bash
docker stack deploy -c docker-stack.yml dwarf-fortress
```

### Kubernetes

```yaml
# k8s-deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dwarf-fortress
spec:
  replicas: 1
  selector:
    matchLabels:
      app: dwarf-fortress
  template:
    metadata:
      labels:
        app: dwarf-fortress
    spec:
      containers:
      - name: dwarf-fortress
        image: username/dwarf-fortress-ai:latest
        ports:
        - containerPort: 5900
        resources:
          limits:
            cpu: "2"
            memory: "4Gi"
          requests:
            cpu: "1"
            memory: "2Gi"
        volumeMounts:
        - name: saves
          mountPath: /opt/dwarf-fortress/df/data/save
        - name: output
          mountPath: /opt/dwarf-fortress/output
      volumes:
      - name: saves
        persistentVolumeClaim:
          claimName: df-saves-pvc
      - name: output
        persistentVolumeClaim:
          claimName: df-output-pvc

---
apiVersion: v1
kind: Service
metadata:
  name: dwarf-fortress-service
spec:
  selector:
    app: dwarf-fortress
  ports:
  - port: 5900
    targetPort: 5900
  type: LoadBalancer
```

## Cloud Deployment

### AWS ECS

```json
{
  "family": "dwarf-fortress",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "2048",
  "memory": "4096",
  "executionRoleArn": "arn:aws:iam::ACCOUNT:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "dwarf-fortress",
      "image": "username/dwarf-fortress-ai:latest",
      "portMappings": [
        {
          "containerPort": 5900,
          "protocol": "tcp"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/dwarf-fortress",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

### Digital Ocean

```bash
# Using Docker Machine
docker-machine create \
  --driver digitalocean \
  --digitalocean-access-token $DIGITALOCEAN_TOKEN \
  --digitalocean-size s-2vcpu-4gb \
  dwarf-fortress-vm

# Set Docker environment
eval $(docker-machine env dwarf-fortress-vm)

# Deploy
git clone https://github.com/username/dwarf-fortress-container.git
cd dwarf-fortress-container
make quick-start-detached
```

## Monitoring and Logging

### Prometheus Monitoring

```yaml
# Add to docker-compose.yml
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
```

### Log Aggregation

```bash
# Using Filebeat to ship logs
docker run -d \
  --name filebeat \
  --user root \
  --volume="$(pwd)/filebeat.yml:/usr/share/filebeat/filebeat.yml:ro" \
  --volume="/var/lib/docker/containers:/var/lib/docker/containers:ro" \
  --volume="/var/run/docker.sock:/var/run/docker.sock:ro" \
  docker.elastic.co/beats/filebeat:7.15.0
```

## Security Considerations

### Network Security

```bash
# Run with restricted network access
docker run --network none dwarf-fortress-ai

# Or use custom network
docker network create --internal dwarf-fortress-net
docker run --network dwarf-fortress-net dwarf-fortress-ai
```

### User Security

```bash
# Run with non-root user (already configured in Dockerfile)
# Additional security: use read-only filesystem
docker run --read-only dwarf-fortress-ai
```

### Secrets Management

```bash
# Use Docker secrets for sensitive data
echo "sensitive_config" | docker secret create df_config -
docker service create --secret df_config dwarf-fortress-ai
```

## Backup and Recovery

### Data Backup

```bash
# Backup volumes
docker run --rm -v dwarf-fortress_saves:/data -v $(pwd):/backup ubuntu tar czf /backup/saves_backup.tar.gz /data

# Restore volumes  
docker run --rm -v dwarf-fortress_saves:/data -v $(pwd):/backup ubuntu tar xzf /backup/saves_backup.tar.gz -C /
```

### Automated Backups

```bash
# Cron job for daily backups
0 2 * * * /path/to/backup_script.sh
```

## Troubleshooting

### Common Issues

1. **Container won't start**: Check Docker daemon and resource limits
2. **VNC connection refused**: Verify port 5900 is exposed and accessible
3. **Game crashes**: Increase memory limits and check logs
4. **Performance issues**: Adjust CPU/memory allocation

### Debugging

```bash
# Check container logs
make logs

# Access container for debugging
make shell

# Monitor resource usage
docker stats dwarf-fortress-container
```
