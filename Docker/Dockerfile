FROM tsxcloud/steamcmd-wine-ntsync:latest

RUN apt-get update
RUN apt-get install -y procps jq winbind

COPY enshrouded_server_example.json .
COPY emulators.rc .

COPY load_emulators_env.sh /load_emulators_env.sh
RUN chmod +x /load_emulators_env.sh

COPY start.sh /start.sh
RUN chmod +x /start.sh
ENTRYPOINT []
CMD ["/start.sh"]
