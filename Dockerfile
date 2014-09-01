# Sal Dockerfile
# Version 0.3
FROM ubuntu:14.04.1

MAINTAINER Graham Gilbert <graham@grahamgilbert.com>

ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV APPNAME Sal
ENV APP_DIR /home/docker/sal
ENV TZ Europe/London
ENV DOCKER_SAL_TZ Europe/London
ENV DOCKER_SAL_ADMINS Docker User, docker@localhost
ENV DOCKER_SAL_LANG en_GB
ENV DOCKER_SAL_DISPLAY_NAME Sal
ENV DOCKER_SAL_PLUGIN_ORDER Activity,Status,OperatingSystem,Uptime,Memory

RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:nginx/stable

RUN apt-get -y update


RUN apt-get -y install \
    git \
    python-setuptools \
    nginx \
    postgresql \
    postgresql-contrib \
    libpq-dev \
    python-dev \
    supervisor \
    nano \
    && easy_install pip

RUN git clone https://github.com/grahamgilbert/sal.git $APP_DIR
RUN pip install -r $APP_DIR/setup/requirements.txt
RUN pip install psycopg2==2.5.3
RUN pip install gunicorn
RUN pip install setproctitle
ADD nginx/nginx-env.conf /etc/nginx/main.d/
ADD nginx/sal.conf /etc/nginx/sites-enabled/sal.conf
ADD nginx/nginx.conf /etc/nginx/nginx.conf
ADD settings.py $APP_DIR/sal/
ADD settings_import.py $APP_DIR/sal/
ADD wsgi.py $APP_DIR/
ADD gunicorn_config.py $APP_DIR/
ADD django/management/ $APP_DIR/sal/management/
ADD run.sh /run.sh
ADD supervisord.conf /etc/supervisor/supervisord.conf
RUN update-rc.d -f postgresql remove
RUN update-rc.d -f nginx remove
RUN rm -f /etc/nginx/sites-enabled/default

CMD ["/run.sh"]

EXPOSE 8000

VOLUME ["$APP_DIR/plugins", "$APP_DIR/sal/settings.py"]
RUN mkdir -p /home/app
RUN ln -s $APP_DIR /home/app/sal
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*