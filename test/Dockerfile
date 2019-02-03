from elixir:1.8.1-slim

run apt-get update && apt-get -y install wget unzip make && \
    wget -q https://github.com/protocolbuffers/protobuf/releases/download/v3.7.0rc1/protoc-3.7.0-rc1-linux-x86_64.zip && \
    unzip protoc-3.7.0-rc1-linux-x86_64.zip && \
    mv bin/protoc /usr/local/bin && \
    mv include/google/ /usr/local/include/google/ && \
    mix local.hex --force && \
    yes | mix escript.install hex protobuf || true && \
    mv /root/.mix/escripts/protoc-gen-elixir /usr/local/bin/

entrypoint bash
