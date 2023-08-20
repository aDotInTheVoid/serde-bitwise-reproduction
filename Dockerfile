FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    git \
    gcc \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Bodged from https://github.com/rust-lang/docker-rust/blob/2bb79cb08932ba4ccab9d48f9e07159095146eb7/1.71.1/buster/Dockerfile

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=nightly-2023-08-07 

RUN set -eux; \
    dpkgArch="$(dpkg --print-architecture)"; \
    case "${dpkgArch##*-}" in \
        amd64) rustArch='x86_64-unknown-linux-gnu'; rustupSha256='0b2f6c8f85a3d02fde2efc0ced4657869d73fccfce59defb4e8d29233116e6db' ;; \
        armhf) rustArch='armv7-unknown-linux-gnueabihf'; rustupSha256='f21c44b01678c645d8fbba1e55e4180a01ac5af2d38bcbd14aa665e0d96ed69a' ;; \
        arm64) rustArch='aarch64-unknown-linux-gnu'; rustupSha256='673e336c81c65e6b16dcdede33f4cc9ed0f08bde1dbe7a935f113605292dc800' ;; \
        i386) rustArch='i686-unknown-linux-gnu'; rustupSha256='e7b0f47557c1afcd86939b118cbcf7fb95a5d1d917bdd355157b63ca00fc4333' ;; \
        *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;; \
    esac; \
    url="https://static.rust-lang.org/rustup/archive/1.26.0/${rustArch}/rustup-init"; \
    curl -O "$url"; \
    echo "${rustupSha256} *rustup-init" | sha256sum -c -; \
    chmod +x rustup-init; \
    ./rustup-init -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION --default-host ${rustArch}; \
    rm rustup-init; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \
    rustup --version; \
    cargo --version; \
    rustc --version;


RUN curl -L# https://crates.io/api/v1/crates/serde_derive/1.0.183/download | tar xz
RUN git clone --depth 1 --branch v1.0.183 https://github.com/serde-rs/serde/

# Yes, this is off by one, see https://github.com/rust-lang/rustup/issues/3455
RUN rustup target add x86_64-unknown-linux-musl 
RUN rustup component add rust-src --toolchain ${RUST_VERSION}-x86_64-unknown-linux-gnu

RUN sed -i 's/cargo .nightly/cargo +nightly-2023-08-07/' /serde/precompiled/build.sh
RUN /serde/precompiled/build.sh