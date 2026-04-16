# Moltbook-Pioneer: Containerized Feed Scanner & Monitoring Station
# Part of the Lobster-TrApp perimeter — processes untrusted Moltbook
# content inside the container, never on the host.
#
# Build:  podman build -t vault-pioneer -f Containerfile .
# Or:     docker build -t vault-pioneer -f Containerfile .
#
# Run:    podman run --rm vault-pioneer make scan
#         podman run --rm vault-pioneer make census

FROM python:3.10-slim

LABEL maintainer="Moltbook-Pioneer" \
      description="Feed injection scanner — filters untrusted social content inside the perimeter"

# Install system dependencies
# curl: fetch posts from Moltbook API
# jq: JSON formatting for API responses
# grep/sed: text processing for pattern matching
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    jq \
    make \
    grep \
    sed \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# PyYAML is the only external Python dependency — used by export-patterns.py
RUN pip install --no-cache-dir PyYAML

# Non-root user — pioneer doesn't need root for anything
RUN groupadd -g 1000 pioneer \
    && useradd -u 1000 -g pioneer -m -s /bin/bash pioneer

WORKDIR /app

# Copy project files
COPY --chown=pioneer:pioneer . /app

# Ensure scripts are executable
RUN chmod +x tools/*.sh scripts/*.sh 2>/dev/null; \
    chmod +x scripts/*.py 2>/dev/null; \
    true

# Create data directory for census snapshots and scan results
RUN mkdir -p data \
    && chown -R pioneer:pioneer data

# Copy .env template if no .env exists (setup step)
RUN cp -n config/.env.example config/.env 2>/dev/null; true

# Run as non-root
USER pioneer

# Default: interactive bash (compose overrides with specific commands)
CMD ["bash"]
