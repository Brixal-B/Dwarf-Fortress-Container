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
    fluxbox \
    netcat \
    openssh-server \
    dbus-x11 \
    xterm \
    && rm -rf /var/lib/apt/lists/*

# Download and install NoMachine server
RUN wget -q https://download.nomachine.com/download/8.11/Linux/nomachine_8.11.3_4_amd64.deb \
    && dpkg -i nomachine_8.11.3_4_amd64.deb \
    && rm nomachine_8.11.3_4_amd64.deb

# Configure NoMachine server
RUN mkdir -p /usr/NX/etc \
    && echo "AcceptedAuthenticationMethods NX-private-key" > /usr/NX/etc/server.cfg \
    && echo "SSHAuthorizedKeys default" >> /usr/NX/etc/server.cfg \
    && echo "DefaultDesktopCommand /usr/bin/fluxbox" >> /usr/NX/etc/server.cfg

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
RUN useradd -m -s /bin/bash dfuser \
    && echo 'dfuser:dfpassword' | chpasswd \
    && mkdir -p /home/dfuser/.ssh \
    && chown dfuser:dfuser /home/dfuser/.ssh

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

# Expose API server port and NoMachine port
EXPOSE 8080
EXPOSE 4000

# Default command
CMD ["/opt/dwarf-fortress/start.sh"]
