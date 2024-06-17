#! /bin/bash

HOST=localhost
IP_ADDR=10.104.0.2

CA_CERT=$(cat $HOME/docker-certs/ca.pem)
KEY=$(cat $HOME/docker-certs/key.pem)
CERT=$(cat $HOME/docker-certs/cert.pem)

cat <<EOF > "/tmp/config.yml"
log:
  level: warning
ssh:
  banner: |
    ********************************************************************
                               Warning!
    ********************************************************************

    This is a honeypot. All information, including IP address, username,
    password, any commands you type, or files you upload will be visible
    to the honeypot.

    If you do not agree disconnect now.

    ********************************************************************

  hostkeys:
    - /etc/containerssh/ssh_host_rsa_key
backend: docker
docker:
  connection:
    host: tcp://${IP_ADDR}:2376
    cert: |
${CERT}
    key: |
${KEY}
    cacert: |
${CA_CERT}
  execution:
    imagePullPolicy: Never
    container:
      image: containerssh/test-guest
      hostname: bitcoin
      # Disable network in the container
      networkdisabled: true
      # Force running as user 1000
      user: 1000
      # Optionally set working directory
      workingdir: /home/ubuntu
    host:
      # Don't let the attacker write to the root FS.
      readonlyrootfs: true
      resources:
        # 10% of CPU
        cpuperiod: 10000
        cpuquota: 1000
        # 50 MB of memory with swap
        memoryswap: 52428800
        memoryswappiness: 50
        # 25 MB of memory
        memory: 26214400
        # Reserve 20 MB of memory
        memoryreservation: 20000000
        # Max 1000 processes to prevent fork bombs
        pidslimit: 1000
      tmpfs:
        # Create writable directories in memory
        /tmp: rw,noexec,nosuid,size=65536k,uid=1000,gid=1000
        /run: rw,noexec,nosuid,size=65536k,uid=1000,gid=1000
        /home/ubuntu: rw,noexec,nosuid,size=65536k,uid=1000,gid=1000
metrics:
  enable: true
  listen: "0.0.0.0:9101"
  path: "/metrics"
audit:
  enable: true
  format: binary
  storage: s3
  intercept:
    stdin: true
    stdout: true
    stderr: true
    passwords: true
  s3:
    # Local directory to store the audit log temporarily.
    local: /var/log/containerssh/audit/
    accessKey: YOUR-S3-ACCESS-KEY-HERE
    secretKey: YOUR-S3-SECRET-KEY-HERE
    region: YOUR-S3-REGION
    bucket: YOUR-S3-BUCKET-NAME
    # Optional: set your S3 endpoint
    endpoint: https://YOUR-S3-ENDPOINT
    # Optional: use path-style access for buckets
    pathStyleAccess: true
    metadata:
      # Which metadata fields to set in the object storage.
      username: true
      ip: false
auth:
  url: "http://127.0.0.1:8080"
configserver:
  url: "http://127.0.0.1:8080/config"
EOF
