FROM robsharp/rpi-transmission

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
RUN touch /var/log/cron.log /etc/crontab && mkdir -p /var/log/supervisor /etc/cron.daily

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY transmission-blocklist-updater.sh /etc/cron.daily/transmission-blocklist-updater
# && chmod +x /etc/cron.daily/transmission-blocklist-updater.sh

# Define default command
CMD ["/usr/bin/supervisord"]
#CMD rsyslogd && cron && tail -f /var/log/syslog /var/log/cron.log
