FROM debian:jessie
MAINTAINER fzerorubigd <fzero@rubi.gd> @fzerorubigd

RUN apt-get update && apt-get install -y --no-install-recommends \
		ssh \
        wget \
	&& rm -rf /var/lib/apt/lists/*

RUN wget http://dl.chenyufei.info/cow/latest/cow-linux64-0.9.6.gz -O /cow.gz
RUN gunzip /cow.gz && chmod a+x /cow

ADD docker-initscript.sh /sbin/docker-initscript.sh
RUN chmod 755 /sbin/docker-initscript.sh
EXPOSE 7777/tcp
RUN mkdir /data
VOLUME /data
ENTRYPOINT ["/sbin/docker-initscript.sh"]
CMD ["cow"]