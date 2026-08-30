FROM rust:1.98-bookworm@sha256:82150a52ec202c1b14d7817e14516c392bb7f5cfebd88f1ed531cb37ebd39922 AS builder
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
