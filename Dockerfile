FROM ghcr.io/gleam-lang/gleam:v1.6.2-erlang-alpine

COPY . /build/

RUN cd /build \
  && gleam export erlang-shipment \
  && mv build/erlang-shipment /app \
  && rm -r /build

ENV DATABASE_URL="my_value"
EXPOSE 2626
WORKDIR /app

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run"]