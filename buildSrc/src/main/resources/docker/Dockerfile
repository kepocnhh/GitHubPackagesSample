FROM kepocnhh/dex-jaguar:0.0.1

COPY . /build
WORKDIR /build

ARG BUILD_TYPES

RUN ./buildSrc/src/main/resources/bash/pipeline/main.sh
