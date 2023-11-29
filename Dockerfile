FROM gcr.io/distroless/base-debian12:debug-nonroot

ADD --chmod=755 https://storage.yandexcloud.net/final-homework/bingo /

ENTRYPOINT []