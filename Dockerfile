# syntax=docker/dockerfile:1

FROM debian:bookworm-slim as base
RUN apt update

FROM base as build

RUN mkdir /app

RUN apt -y install unzip curl

RUN echo '#!/bin/bash\n\nsupervisord --nodaemon --configuration /app/airconnect.conf' > /tmp/run.sh
RUN chmod +x /tmp/run.sh

RUN curl -s https://api.github.com/repos/philippe44/AirConnect/releases/latest | grep browser_download_url | cut -d '"' -f 4 | xargs curl -L -o airconnect.zip \
&& unzip airconnect.zip aircast-linux-x86_64 -d /tmp/ \
&& unzip airconnect.zip airupnp-linux-x86_64 -d /tmp/ \
&& chmod +x /tmp/aircast-linux-x86_64 \
&& chmod +x /tmp/airupnp-linux-x86_64

FROM base as final

ADD . /app/

RUN apt -y install libssl3 libssl-dev supervisor

COPY --from=build /tmp/run.sh /app/
COPY --from=build /tmp/aircast-linux-x86_64 /app/
COPY --from=build /tmp/airupnp-linux-x86_64 /app/

ENTRYPOINT [ "/app/run.sh" ]

