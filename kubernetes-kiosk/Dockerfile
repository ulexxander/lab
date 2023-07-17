FROM debian:bookworm
RUN \
  apt-get update && \
  apt-get install -y firefox-esr && \
  apt-get clean
RUN useradd -m firefox
USER firefox
WORKDIR /home/firefox
CMD ["/usr/bin/firefox", "--profile", "/home/firefox"]
