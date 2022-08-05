# Build Jackett for Alpine
FROM mcr.microsoft.com/dotnet/sdk:6.0-alpine AS dotnet

ARG JACKETT_VER=0.20.1463

WORKDIR /tmp
RUN wget -O- https://github.com/Jackett/Jackett/archive/v${JACKETT_VER}.tar.gz | tar xz --strip-components=1 \
    && cd src \
    && echo '{"configProperties":{"System.Globalization.Invariant":true,"System.Globalization.PredefinedCulturesOnly":false}}' > Jackett.Server/runtimeconfig.template.json \
    && dotnet publish Jackett.Server --self-contained -f net6.0 -c Release -r linux-musl-x64 /p:TrimUnusedDependencies=true /p:PublishTrimmed=true -o /out \
    && apk --no-cache add binutils \
    && cd /out \
    && rm -f *.pdb \
    && chmod +x jackett \
    && strip -s /out/*.so



FROM alpine:3

# Install Bash
RUN apk add bash

# Install Jackett
COPY --from=dotnet /out /usr/bin/jackett
RUN apk add libgcc libstdc++


# Environment variables
ENV TRANSMISSION_WEB_HOME=/opt/transmission-web-control \
    TRANSMISSION_HOME=/etc/transmission \
    XDG_CONFIG_HOME=/etc \
    PUID=99 \
    PGID=100 


# Add volumes for persistent data
VOLUME [ "/etc/Jackett" ]


COPY /start.sh /

CMD /start.sh