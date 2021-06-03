FROM mkodockx/docker-clamav
USER root
#RUN apt-get update && apt-get install -y curl inotify-tools
RUN apt-get update && apt-get install -y telnet inotify-tools
RUN apt-get clean --dry-run
USER clamav
