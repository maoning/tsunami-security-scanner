# Core engine
FROM ghcr.io/google/tsunami-scanner-core:latest AS core

# Plugins
FROM ghcr.io/google/tsunami-plugins-local-nmap:latest AS plugins-local-nmap
FROM ghcr.io/google/tsunami-plugins-local-ai:latest AS plugins-local-ai

# Release a full version
FROM ubuntu:latest AS release

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates openjdk-21-jre golang nmap \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /usr/share/doc && rm -rf /usr/share/man \
    && apt-get clean \
    && mkdir logs/

COPY --from=core /usr/tsunami/ /usr/tsunami/

COPY --from=plugins-local-nmap /usr/tsunami/plugins/ /usr/tsunami/plugins/
COPY --from=plugins-local-ai /usr/tsunami/plugins/ /usr/tsunami/plugins/

# Create wrapper scripts
WORKDIR /usr/tsunami
RUN echo '#!/bin/bash\njava -cp /usr/tsunami/tsunami.jar:/usr/tsunami/plugins/* -Dtsunami.config.location=/usr/tsunami/tsunami.yaml com.google.tsunami.main.cli.TsunamiCli $*\n' > /usr/bin/tsunami \
    && chmod +x /usr/bin/tsunami