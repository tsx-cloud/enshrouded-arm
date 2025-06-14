## Base information
The goal of this build is to enable running Enshrouded on Wine with all the latest features: staging-tkg-ntsync-wow64, on both arm64 and amd64 platforms.

In the logs folder, you can find startup logs of Enshrouded on the arm64 platform (Google Axion CPU).
The docker-compose-example folder contains a quickstart setup to launch.

Important note! ntsync support is available only in the latest Ubuntu version — 25.04, and even then it must be manually enabled.
The build works perfectly fine without ntsync — the only thing you need to do is comment out the following two lines in your docker-compose file:
```yaml
    #devices:
    #  - /dev/ntsync:/dev/ntsync
```
Autosave works correctly when using docker stop.

## ARM
You can set your custom Box64 configuration in  
`./enshrouded/persistentdata/settings/emulators.rc`  
This lets you fine-tune the emulator for your specific device or OS.

A list of available environment variables can be found here:  
https://github.com/ptitSeb/box64/blob/main/docs/USAGE.md

## Environment variables
This build doesn't rely on any special environment variables.  
All configuration is done *exclusively* through the `enshrouded_server.json` file:
`./enshrouded/persistentdata/settings/enshrouded_server.json`  
Simple and clean — just edit the file and you're good to go.

## Volumes


| Volume             | Container path              | Description                             |
| -------------------- | ----------------------------- | ----------------------------------------- |
| steam install path | /mnt/enshrouded/server         | path to hold the dedicated server files |
| world              | /mnt/enshrouded/persistentdata | path that holds the world files         |


## docker-compose.yml

```yaml
services:
  enshrouded:
    image: tsxcloud/enshrouded-arm:latest
    ports:
      - "15637:15637/udp"
      - "15638:15638/udp"
    volumes:
      - ./enshrouded/server:/mnt/enshrouded/server
      - ./enshrouded/persistentdata:/mnt/enshrouded/persistentdata
    restart: unless-stopped
    network_mode: bridge
    #This is required for ntsync to work inside Docker.
    #If ntsync support is not enabled in your Linux kernel, comment out this section, otherwise Docker Compose won't start.
#   devices:
#    - /dev/ntsync:/dev/ntsync
```


## Links
You can find the Docker builds here:
https://hub.docker.com/r/tsxcloud/enshrouded-arm

## Acknowledgments
https://github.com/jsknnr/enshrouded-server  
https://github.com/Kron4ek/Wine-Builds    
https://github.com/steamcmd/docker  

## 
Enjoying the project? A ⭐ goes a long way!


