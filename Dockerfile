FROM alpine:latest
MAINTAINER Johannes Mitlmeier <dev.jojomi@yahoo.com>

ENV HUGO_VERSION=0.16
RUN apk add --update wget ca-certificates git && \
  cd /tmp/ && \
  wget https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_linux-64bit.tgz && \
  tar xzf hugo_${HUGO_VERSION}_linux-64bit.tgz && \
  rm -r hugo_${HUGO_VERSION}_linux-64bit.tgz && \
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



# docker build . -t wesleyhales
#docker run -ti -p 1313:1313 -v $(pwd)/output:/output -v $(pwd)/wesleyhales:/src/wesleyhales -e "HUGO_BASEURL=http://localhost:1313" -e "HUGO_THEME=detox" -e "HUGO_WATCH=true" wesleyhales
##docker exec -ti wesleyhales /bin/ash

#__PROD SETTINGS
#docker run -ti -p 1313:1313 -v $(pwd)/output:/output -v $(pwd)/wesleyhales:/src/wesleyhales -e "HUGO_BASEURL=http://wesleyhales.com" -e "HUGO_APPEND_PORT=false" -e "HUGO_THEME=detox" -e "HUGO_WATCH=true" wesleyhales
#"HUGO_BASEURL=www.wesleyhales.com"
#"HUGO_APPEND_PORT=false"