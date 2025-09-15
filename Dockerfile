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

# Install Python packages for API server
RUN pip3 install flask flask-cors

# Create working directory
WORKDIR /opt/dwarf-fortress

# Copy download script, API server, and scripts
COPY download_df.sh /opt/dwarf-fortress/
COPY df_api_server.py /opt/dwarf-fortress/
COPY scripts/ /opt/dwarf-fortress/scripts/
RUN chmod +x /opt/dwarf-fortress/download_df.sh
RUN chmod +x /opt/dwarf-fortress/df_api_server.py

# Download Dwarf Fortress and DFHack
RUN ./download_df.sh

# Create a user for running the application
RUN useradd -m -s /bin/bash dfuser

# Copy startup script before changing ownership
COPY start.sh /opt/dwarf-fortress/
RUN chmod +x /opt/dwarf-fortress/start.sh

# Create output directory with proper permissions
RUN mkdir -p /opt/dwarf-fortress/output && chown -R dfuser:dfuser /opt/dwarf-fortress/output

# Change ownership of only essential files - avoid the huge DF installation
RUN chown dfuser:dfuser /opt/dwarf-fortress/df_api_server.py \
    && chown -R dfuser:dfuser /opt/dwarf-fortress/scripts \
    && chown dfuser:dfuser /opt/dwarf-fortress/start.sh

# Switch to non-root user
USER dfuser

# Set up display for headless operation
ENV DISPLAY=:99

# Expose VNC port for remote access and API server port
EXPOSE 5900
EXPOSE 8080

# Default command
CMD ["/opt/dwarf-fortress/start.sh"]
