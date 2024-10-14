FROM elixir:1.17.3-otp-26


ADD start.sh /

RUN chmod +x /start.sh

RUN apt-get update - \
  && apt-get install -y inotify-tools build-essential git \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

RUN mix local.rebar --force \
    && mix local.hex --force

ENTRYPOINT ["bash"]

CMD ["/start.sh"]
