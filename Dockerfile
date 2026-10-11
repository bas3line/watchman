FROM rust:1.99-bookworm@sha256:114c7a4425406451c2866b6aafe69fe29b1b298832db1277d411ac73c82d04d6 AS builder
WORKDIR /source
COPY Cargo.toml Cargo.lock ./
COPY src ./src
RUN cargo build --locked --release

FROM debian:bookworm-slim@sha256:7b140f374b289a7c2befc338f42ebe6441b7ea838a042bbd5acbfca6ec875818
# HTTPS probes use reqwest's compiled-in rustls/webpki roots, so the runtime
# stage has no network-dependent package installation.
COPY --from=builder /source/target/release/gpu-watchman /usr/local/bin/gpu-watchman
USER 65532:65532
EXPOSE 9400
ENTRYPOINT ["/usr/local/bin/gpu-watchman"]
CMD ["serve", "--interval", "5s", "--listen", "0.0.0.0:9400", "--allow-remote-listen", "--require-source", "processes", "--no-xid"]
