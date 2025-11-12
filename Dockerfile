# Build stage
FROM rust:1.82 AS builder
RUN rustup toolchain install nightly && rustup default nightly

# Install build dependencies
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy Cargo files
COPY Cargo.toml Cargo.lock ./

# Copy source code
COPY src ./src

# Build the application in release mode
RUN cargo build --release

# Runtime stage
FROM ubuntu:22.04

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create app user
RUN useradd -r -s /bin/false appuser

WORKDIR /app

# Copy the binary from builder stage
COPY --from=builder /app/target/release/russh-ratatui .

# Change ownership to app user
RUN chown appuser:appuser /app/russh-ratatui

# Switch to non-root user
USER appuser

# Expose SSH port
EXPOSE 2222

# Run the application
CMD ["./russh-ratatui"]
