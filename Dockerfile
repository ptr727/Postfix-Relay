# docker run -it --rm --pull always --name Testing alpine:latest /bin/sh

# docker buildx create --name postfix-relay --use
# docker buildx build --platform linux/amd64,linux/arm64.linux/arm/v7 .

# docker buildx build --load --platform linux/amd64 --tag postfix-relay:testing .
# docker run -it --rm --name postfix-relay-test postfix-relay:testing /bin/sh


FROM alpine:latest

RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
        bash \
        gawk \
        cyrus-sasl \
        cyrus-sasl-login \
        cyrus-sasl-crammd5 \
        mailx \
        postfix 

COPY run.sh /
RUN chmod +x /run.sh && \
    newaliases

EXPOSE 25/tcp
VOLUME ["/var/spool/postfix"]
CMD ["/run.sh"]
