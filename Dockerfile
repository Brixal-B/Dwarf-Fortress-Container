FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    unzip \
    git \
    build-essential \
    cmake \
    zlib1g-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    python3 \
    python3-pip \
    xvfb \
    x11vnc \
    fluxbox \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /opt/dwarf-fortress

# Copy download script
COPY download_df.sh /opt/dwarf-fortress/
RUN chmod +x /opt/dwarf-fortress/download_df.sh

# Download Dwarf Fortress and DFHack
RUN ./download_df.sh

# Create a user for running the application
RUN useradd -m -s /bin/bash dfuser
RUN chown -R dfuser:dfuser /opt/dwarf-fortress

# Switch to non-root user
USER dfuser

# Set up display for headless operation
ENV DISPLAY=:99

# Create startup script
COPY --chown=dfuser:dfuser start.sh /opt/dwarf-fortress/
RUN chmod +x /opt/dwarf-fortress/start.sh

# Expose VNC port for remote access (optional)
EXPOSE 5900

# Default command
CMD ["/opt/dwarf-fortress/start.sh"]
