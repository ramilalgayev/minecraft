#!/bin/bash

# Check if Java is installed
if ! command -v java &> /dev/null; then
    echo "Java not found. Installing OpenJDK..."
    pacman -Sy --noconfirm jdk-openjdk
fi

# Check if screen is installed
if ! command -v screen &> /dev/null; then
    echo "Screen not found. Installing screen..."
    pacman -Sy --noconfirm screen
fi

# Create the Minecraft directory
MC_DIR="/root/mc"
if [ ! -d "$MC_DIR" ]; then
    echo "Creating Minecraft directory at $MC_DIR..."
    mkdir -p "$MC_DIR"
fi

# Download the server JAR file
JAR_URL="https://piston-data.mojang.com/v1/objects/4707d00eb834b446575d89a61a11b5d548d8c001/server.jar"
JAR_DEST="$MC_DIR/server.jar"
echo "Downloading Minecraft server JAR to $JAR_DEST..."
curl -o "$JAR_DEST" "$JAR_URL"

# Create the eula.txt file
echo "Creating eula.txt in $MC_DIR..."
cat <<EOL | tee "$MC_DIR/eula.txt"
#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://aka.ms/MinecraftEULA).
#Mon Dec 30 02:29:38 UTC 2024
eula=true
EOL

# Create the minecraft.service file
SERVICE_FILE="/etc/systemd/system/minecraft.service"
echo "Creating systemd service file at $SERVICE_FILE..."
cat <<EOL | tee "$SERVICE_FILE"
[Unit]
Description=Minecraft Server
After=network.target

[Service]
User=root
WorkingDirectory=$MC_DIR
ExecStart=/usr/bin/screen -dmS minecraft java -Xmx4096M -Xms1024M -jar server.jar
Type=oneshot
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOL

# Enable and start the service
echo "Enabling and starting the Minecraft service..."

systemctl daemon-reload
systemctl enable minecraft.service
systemctl start minecraft.service

echo "Minecraft server setup is complete and will start on boot."
