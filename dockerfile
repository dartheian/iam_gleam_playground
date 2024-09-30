FROM ghcr.io/gleam-lang/gleam:v1.5.1-erlang-alpine

RUN addgroup -g 1000 app
RUN adduser -u 1000 -G app -D app

USER app

WORKDIR /home/app

ENTRYPOINT [ "gleam" ]
CMD ["run"]
