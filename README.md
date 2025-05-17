# Postfix Relay

Simple [Postfix][postfixLink] SMTP TLS relay, docker image based on [alpine linux][alpineLinuxLink], no local authentication, run in a secure LAN.

## Fork of `juanluisbaptiste/docker-postfix`

This project is a fork of the [juanluisbaptiste/docker-postfix][juanluisbaptisteLink] project.\
The upstream has over 10 million pulls on [docker hub][juanluisbaptisteDockerLink] but has not been updated in over 3 years.

Summary of changes from upstream:

- Weekly builds using `alpine:latest` as upstream.
- Removed `i386` and `arm/v6` build targets.
- Removed versioned tags, only building using `latest` for `main` branch and `develop` for `develop` branch.
- Simplified [Dockerfile](./Dockerfile) and [github actions](./.github/workflows/buildpush.yml) to support minimal requirements.
- Added `dependabot` and auto merging of github actions updates.

The majority of this project is vanilla github actions and docker hub boilerplate, the interesting code is in [`run.sh`](./run.sh) that converts the environment variables into postfix settings.

## Build status

[![Docker Status][docker-status-shield]][actions-link]\
[![Last Commit][last-commit-shield]][commit-link]

## Usage

Docker images are published on [Docker Hub](https://hub.docker.com/r/ptr727/postfix-relay) as `ptr727/postfix-relay`.\
E.g. `docker pull ptr727/postfix-relay:latest`.

Tags:

- `latest` : Latest build from `main` branch.
- `develop` : Latest build from `develop` branch.

Platforms:

- `linux/amd64`
- `linux/arm64`
- `linux/arm/v7`

### Environment variables

- `SMTP_SERVER` : (Required) Address of the SMTP server to use.
- `SMTP_PORT` : Port of the SMTP server to use, default is 587.
- `SMTP_USERNAME` : Username to authenticate with.
- `SMTP_PASSWORD` : (Required if `SMTP_USERNAME` is set) Password of the SMTP user. If `SMTP_PASSWORD_FILE` is set, not needed.
- `SERVER_HOSTNAME` : Server hostname for the Postfix container. Emails will appear to come from the hostname's domain.
- `SMTP_HEADER_TAG` : This will add a header for tracking messages upstream. Helpful for spam filters. Will appear as `RelayTag: ${SMTP_HEADER_TAG}` in the email headers.
- `SMTP_NETWORKS` : Setting this will allow you to add additional, comma seperated, subnets allowed to use the relay. E.g. `SMTP_NETWORKS='10.0.0.0/8,172.16.0.0/12,192.168.0.0/16'`.
- `SMTP_PASSWORD_FILE` : Use a docker secrets file containing the password, see compose example.
- `SMTP_USERNAME_FILE` : Use a docker secrets file containing the username, see compose example.
- `ALWAYS_ADD_MISSING_HEADERS` : This is related to the [always\_add\_missing\_headers][alwaysAddMissingHeadersLink] Postfix option (default: `no`). If set to `yes`, Postfix will always add missing headers among `From:`, `To:`, `Date:` or `Message-ID:`.
- `OVERWRITE_FROM` : This will rewrite the from address overwriting it with the specified address for all email being relayed. E.g. `OVERWRITE_FROM=email@company.com`, `OVERWRITE_FROM="Your Name" <email@company.com>`.
- `DESTINATION` : This will define a list of domains from which incoming messages will be accepted.
- `LOG_SUBJECT` : This will output the subject line of messages in the log.
- `SMTPUTF8_ENABLE` : This will enable (default) or disable support for `SMTPUTF8`. Valid values are `no` to disable and `yes` to enable. Not setting this variable will use the postfix default, which is `yes`.
- `MESSAGE_SIZE_LIMIT` : This will change the default limit of 10240000 bytes (10MB).
- `DEBUG` : Set `DEBUG=yes` for more verbose output.

### Volumes

- `/var/spool/postfix` : (Optional) Mail queue directory, make sure running docker `user` has write permissions.

### Network

- `25/tcp` : SMTP relay port.

### Docker compose

```yaml
networks:

  public_network:
    name: ${PUBLIC_NETWORK_NAME}
    external: true

  local_network:
    name: ${LOCAL_NETWORK_NAME}
    external: true

secrets:

   external_smtp_password:
     file: ${SECRETS_DIR}/external_smtp_password.txt

services:

  postfix:
    image: docker.io/ptr727/postfix-relay:latest
    container_name: postfix
    hostname: smtp
    domainname: ${DOMAIN_NAME}
    restart: unless-stopped
    user: ${USER_NONROOT_ID}:${USERS_GROUP_ID}
    environment:
      - TZ=${TZ}
      - SERVER_HOSTNAME=smtp.${DOMAIN_NAME}
      - SMTP_SERVER=${EXTERNAL_SMTP_SERVER}
      - SMTP_PORT=${EXTERNAL_SMTP_PORT}
      - SMTP_USERNAME=${EXTERNAL_SMTP_USERNAME}
      - SMTP_PASSWORD_FILE=/run/secrets/external_smtp_password
    volumes:
      - ${APPDATA_DIR}/postfix/spool:/var/spool/postfix
    networks:
      public_network:
        ipv4_address: ${SMTP_IP}
        mac_address: ${SMTP_MAC}
      local_network:
    secrets:
      - external_smtp_password
```

### Docker run

```console
docker run -d --name postfix -p "25:25" \
    -e SMTP_SERVER=smtp.bar.com \
    -e SMTP_USERNAME=foo@bar.com \
    -e SMTP_PASSWORD=XXXXXXXX \
    -e SERVER_HOSTNAME=smtp.foo.com \
    ptr727/postfix-relay
```

[docker-status-shield]: https://img.shields.io/github/actions/workflow/status/ptr727/postfix-relay/release.yml?logo=github&label=Docker%20Build
[last-commit-shield]: https://img.shields.io/github/last-commit/ptr727/postfix-relay?logo=github&label=Last%20Commit
[commit-link]: https://github.com/ptr727/postfix-relay/commits/main
[actions-link]: https://github.com/ptr727/postfix-relay/actions
[alwaysAddMissingHeadersLink]: http://www.postfix.org/postconf.5.html#always_add_missing_headers
[postfixLink]: https://www.postfix.org
[alpineLinuxLink]: https://alpinelinux.org/
[juanluisbaptisteLink]: https://github.com/juanluisbaptiste/docker-postfix
[juanluisbaptisteDockerLink]: https://hub.docker.com/r/juanluisbaptiste/postfix
