#!/bin/bash
set -e

echo "Downloading Dwarf Fortress and DFHack..."

# Create directories
mkdir -p /opt/dwarf-fortress/df
mkdir -p /opt/dwarf-fortress/dfhack

# Get latest Dwarf Fortress release URL
DF_VERSION="52_04"
DF_URL="https://www.bay12games.com/dwarves/df_${DF_VERSION}_linux.tar.bz2"

echo "Downloading Dwarf Fortress v${DF_VERSION}..."
wget -O /tmp/df.tar.bz2 "$DF_URL"

# Extract Dwarf Fortress
cd /opt/dwarf-fortress/df
tar -xjf /tmp/df.tar.bz2 --strip-components=1

# Get latest DFHack release
echo "Downloading latest DFHack..."
DFHACK_URL=$(curl -s https://api.github.com/repos/DFHack/dfhack/releases/latest | grep "browser_download_url.*linux64.*gcc-7.tar.xz" | cut -d '"' -f 4)

if [ -z "$DFHACK_URL" ]; then
    echo "Could not find DFHack download URL. Trying alternative..."
    DFHACK_URL="https://github.com/DFHack/dfhack/releases/download/52.04-r1/dfhack-52.04-r1-Linux-64bit.tar.bz2"
fi

echo "Downloading DFHack from: $DFHACK_URL"
wget -O /tmp/dfhack.tar.xz "$DFHACK_URL"

# Extract DFHack
cd /opt/dwarf-fortress/dfhack
tar -xf /tmp/dfhack.tar.xz --strip-components=1

# Copy DFHack files to DF directory
echo "Installing DFHack into Dwarf Fortress..."
cp -r /opt/dwarf-fortress/dfhack/* /opt/dwarf-fortress/df/

# Make executables executable
chmod +x /opt/dwarf-fortress/df/dfhack
chmod +x /opt/dwarf-fortress/df/dfhack-run

# Clean up downloads
rm -f /tmp/df.tar.bz2 /tmp/dfhack.tar.xz

echo "Download and installation complete!"
echo "Dwarf Fortress installed in: /opt/dwarf-fortress/df"
echo "DFHack integrated successfully"
