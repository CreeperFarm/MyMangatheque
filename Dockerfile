# syntax=docker/dockerfile:1.7

# The Flutter build is platform-independent. Running it on BUILDPLATFORM avoids
# emulating the Flutter SDK when Buildx creates amd64 and arm64 images.
FROM --platform=$BUILDPLATFORM ghcr.io/cirruslabs/flutter:3.38.9 AS build

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
RUN flutter build web --release --wasm

FROM nginx:alpine

COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --quiet --spider http://127.0.0.1/healthz || exit 1
