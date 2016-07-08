FROM robsharp/rpi-transmission
MAINTAINER Shivneil Prasad <sprasad0603@gmail.com>

# Install dependencies
RUN apt-get update && apt-get install -y \
    cron \
    rsyslog \
    supervisor \
    wget \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Import crontab file
#ADD ./crontab /etc/crontab
RUN touch /var/log/cron.log /etc/crontab /var/log/syslog && mkdir -p /var/log/supervisor /etc/cron.daily

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY transmission-blocklist-updater.sh /etc/cron.daily/transmission-blocklist-updater

COPY settings.json.template transmission-start.sh first-run.sh /

# Define default command
CMD ["/transmission-start.sh"]
