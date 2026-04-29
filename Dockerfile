ARG  BASE_IMAGE=ruby:3.4-alpine
FROM ${BASE_IMAGE} AS builder

RUN apk add --no-cache build-base glib-dev exiftool libexif-dev expat-dev tiff-dev jpeg-dev libpng libgsf-dev vips git perl &&\
    rm -rf /var/cache/apk/*

WORKDIR /photo-stream

COPY Gemfile Gemfile.lock ./

RUN ruby -v && gem install bundler -v 2.6.2 &&\
    bundle config set --local build.sassc --disable-march-tune-native &&\
    bundle install

COPY ./ /photo-stream

FROM ${BASE_IMAGE}

RUN apk add --no-cache exiftool vips perl &&\
    addgroup -S -g 1000 photo-stream &&\
    adduser -S -D -u 1000 -G photo-stream -h /home/photo-stream photo-stream &&\
    rm -rf /var/cache/apk/*

COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder --chown=photo-stream:photo-stream /photo-stream /photo-stream
RUN chmod +x /photo-stream/bin/photo-stream-*

WORKDIR /photo-stream

USER photo-stream

EXPOSE 4000 4001

ENTRYPOINT ["/photo-stream/bin/photo-stream-entrypoint"]
