FROM alpine:latest

LABEL description="This image provides a minimal env for code validity checks and doxygen with graphviz."

RUN apk add --no-cache git php7 doxygen graphviz bash
