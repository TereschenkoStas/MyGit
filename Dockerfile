FROM ubuntu:latest

RUN echo y|apt-get update && echo y|apt-get upgrade 

# Install cron
RUN apt-get -y install cron

RUN touch /var/test.log 

RUN (crontab -l 2>/dev/null; echo "* * * * * echo "1" >> /var/test.log" ) | crontab -

CMD cron && tail -f /var/test.log
