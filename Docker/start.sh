#!/bin/bash

SERVER="/mnt/enshrouded/server"
PERSISTENT="/mnt/enshrouded/persistentdata"
SAVES="${PERSISTENT}/savegame"
LOGS="${PERSISTENT}/logs"
SETTINGS="${PERSISTENT}/settings"
ENSHROUDED_CONFIG="${SETTINGS}/enshrouded_server.json"

# Quick function to generate a timestamp
timestamp () {
  date +"%Y-%m-%d %H:%M:%S,%3N"
}

shutdown () {
    echo ""
    echo "$(timestamp) INFO: Recieved SIGTERM, shutting down gracefully"
    kill -2 $enshrouded_pid
}

# Set our trap
trap 'shutdown' TERM

mkdir -p "${SERVER}"
mkdir -p "${PERSISTENT}"
mkdir -p "${SAVES}"
mkdir -p "${LOGS}"
mkdir -p "${SETTINGS}"

echo "Load extra Box64 and Fex-emu settings from emulators.rc"
source /load_emulators_env.sh
echo " "

/print_app_versions.sh

# Install/Update Enshrouded
echo "$(timestamp) INFO: Updating Enshrouded Dedicated Server"
steamcmd.sh +@sSteamCmdForcePlatformType windows +force_install_dir "${SERVER}" +login anonymous +app_update 2278520 validate +quit

# Check that steamcmd was successful
if [ $? != 0 ]; then
    echo "ERROR: steamcmd was unable to successfully initialize and update Enshrouded..."
    exit 1
fi

# Copy example server config if not already present
if ! [ -f "${ENSHROUDED_CONFIG}" ]; then
    echo "$(timestamp) INFO: Enshrouded server config not present, copying example"
    cp enshrouded_server_example.json "${ENSHROUDED_CONFIG}"
fi

# Check for proper save permissions
if ! touch "${SAVES}/test"; then
    echo ""
    echo "$(timestamp) ERROR: The ownership of ${SAVES} is not correct and the server will not be able to save..."
    echo ""
    exit 1
fi

rm "${SAVES}/test"

# Launch Enshrouded
echo " "
echo "$(timestamp) INFO: Starting Enshrouded Dedicated Server"
wine ${SERVER}/enshrouded_server.exe --config ${ENSHROUDED_CONFIG} &

# Find pid for enshrouded_server.exe
timeout=0
while [ $timeout -lt 11 ]; do
    if ps -e | grep "enshrouded_serv"; then
        enshrouded_pid=$(ps -e | grep "enshrouded_serv" | awk '{print $1}')
        break
    elif [ $timeout -eq 10 ]; then
        echo "$(timestamp) ERROR: Timed out waiting for enshrouded_server.exe to be running"
        exit 1
    fi
    sleep 6
    ((timeout++))
    echo "$(timestamp) INFO: Waiting for enshrouded_server.exe to be running"
done

echo " "
echo "Checking NTSYNC"
echo "The NTSYNC module has been present in the Linux kernel since version 6.14 and is usually included only in the generic kernel versions."
echo "Kernel version on this machine is -- $(uname -r)"

echo " "
/usr/bin/lsof /dev/ntsync
echo " "
if /sbin/lsmod | grep -q ntsync; then
  if /usr/bin/lsof /dev/ntsync > /dev/null 2>&1; then
    echo "NTSYNC Module is present in kernel, ntsync is running."
  else
    echo "NTSYNC Module is present in kernel, but ntsync is NOT running. No problem — ntsync is not nessesary."
  fi
else
  echo "NTSYNC Module is NOT present in kernel. No problem — ntsync is not nessesary."
fi
echo " "

# Hold us open until we recieve a SIGTERM
wait

# Handle post SIGTERM from here
# Hold us open until WSServer-Linux pid closes, indicating full shutdown, then go home
tail --pid=$enshrouded_pid -f /dev/null

# o7
echo "$(timestamp) INFO: Shutdown complete."
exit 0
