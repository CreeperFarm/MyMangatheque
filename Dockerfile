# syntax=docker/dockerfile:1.7

# The Flutter build is platform-independent. Running it on BUILDPLATFORM avoids
# emulating the Flutter SDK when Buildx creates amd64 and arm64 images.
FROM --platform=$BUILDPLATFORM ghcr.io/cirruslabs/flutter:3.44.0 AS build

WORKDIR /app

# pubspec.lock is committed for reproducible application builds. The wildcard
# still lets Docker calculate the context if a branch temporarily lacks it.
COPY pubspec.* ./
RUN flutter pub get

COPY . .
ARG FIREBASE_WEB_VAPID_KEY=""
RUN flutter build web --release --wasm \
  --dart-define=FIREBASE_WEB_VAPID_KEY=${FIREBASE_WEB_VAPID_KEY}

FROM nginx:alpine

COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --quiet --spider http://127.0.0.1/healthz || exit 1
