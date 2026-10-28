
# Use fix Node-red docker release
FROM nodered/node-red:5.0

# Switch to root user
USER root

# Set environment variables
ENV DKNR_USERNAME=admin \
      DKNR_PASSWORD=admin \
      DKNR_SECRET=dkzwave \
      DKNR_REPOSITORY=https://github.com/JcDenis/dknr-zwave \
      NODE_RED_ENABLE_PROJECTS=true \
      TZ=Europe/Paris

# Image label
LABEL org.opencontainers.image.authors="Jean-Christian Paul Denis" \
      org.opencontainers.image.source="https://github.com/JcDenis/dknr-zwave" \
      org.opencontainers.image.title="DKNR Z-Wave" \
      org.opencontainers.image.description="Z-Wave JS UI devices to DKNR MQTT with web UI" \
      org.opencontainers.image.licenses="AGPL-3.0"

# Set system timezone
RUN echo "$TZ" > /etc/timezone

# Prepare Node-Red structure
RUN mkdir -p /data/projects/dknr-zwave

# Clone repository
RUN git clone ${DKNR_REPOSITORY} /data/projects/dknr-zwave

# Fix ownership
RUN chown -R node-red:node-red /data

# Switch to node-red user
USER node-red

# Set working diretory for container starting script
WORKDIR /data

# Add container starting script
ADD docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]
