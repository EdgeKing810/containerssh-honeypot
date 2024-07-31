# ContainerSSH HoneyPot

This is a project that aims to deploy a honeypot that makes use of ContainerSSH. It also includes
Prometheus for fetching metrics and Grafana to visualize them.

## Requirements

2 Ubuntu 22.04 machines are needed (gateway and sacrificial).

## Ports to open

- On the sacrificial host, ports `2376` and `9100` should be accessible **FROM** the gateway host.
- On the gateway host, ports `22` and `3000` need to be open publicly.

## Usage

1. Connect to the 2 Ubuntu machines.
2. Perform an `apt update && apt upgrade -y`.
3. Change the default ssh port on the gateway host: `sudo nano /etc/ssh/sshd_config && sudo systemctl restart sshd`.
4. Clone the git repository: `git clone https://github.com/EdgeKing810/containerssh-honeypot && cd containerssh-honeypot/`.
5. Install docker on **both** hosts: `chmod +x ./install-docker.sh && ./install-docker.sh`.

6. Configure authentication for docker on the sacrificial host.

```bash
cd sacrificial/
ip r

# Modify the HOST variable if needed and set the value of IP_ADDR variable (should be reachable from the gateway)
nano docker-authentication.sh
chmod +x ./docker-authentication.sh
./docker-authentication.sh
```

7. Generate the ContainerSSH config file on the sacrificial host.

```bash
# Modify the HOST variable if needed and set the value of IP_ADDR variable (should be reachable from the gateway)
nano build-containerssh-config.sh
chmod +x build-containerssh-config.sh
./build-containerssh-config.sh
```

8. Modify the `/tmp/config.yaml` to fix the identation for the values of the `cert`, `key` and `cacert` fields in the `docker -> connection` block.
9. Copy the `/tmp/config.yaml` file from the sacrificial host to `<path_where_the_repo_was_cloned>/gateway/containerssh-config/config.yaml` on the gateway host.
10. Pull the `containerssh-guest-image` docker image on the sacrificial host: `docker pull containerssh/containerssh-guest-image:latest`.
11. Start the Node Exporter container on the sacrificial host: `docker compose up -d`.
12. On the gateway host, go to the `gatway/containerssh-config/` directory and run the `generate-key.sh` script.

```bash
cd gatway/containerssh-config/
chmod +x generate-key.sh
./generate-key.sh
```

13. On the gateway host, modify the `gateway/prometheus-config/prometheus.yml` file and add the correct IP for the sacrificial host (line 16).
14. On the gateway host, go to the `gateway/` directory and start all the containers: `docker compose up -d`.
15. Test if it is working by running a `ssh -o HostKeyAlgorithms=+ssh-rsa ubuntu@<gateway-host-ip>`.
