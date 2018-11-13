FROM alpine:latest
MAINTAINER Johannes Mitlmeier <dev.jojomi@yahoo.com>

ENV HUGO_VERSION=0.51
RUN apk add --update wget ca-certificates git && \
  cd /tmp/ && \
  wget https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz && \
  tar xvzf hugo_${HUGO_VERSION}_Linux-64bit.tar.gz && \
  rm -r hugo_${HUGO_VERSION}_Linux-64bit.tar.gz && \
  mv hugo /usr/bin/hugo && \
  apk del wget ca-certificates && \
  rm /var/cache/apk/*

COPY ./run.sh /run.sh


VOLUME /src
VOLUME /output

WORKDIR /src
USER root
CMD ["/run.sh"]

EXPOSE 1313

#CMD ["ash", "--login"]