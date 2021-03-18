# A partir du fichier fourni par Tanguy

FROM ubuntu:18.04
MAINTAINER ILKILAB

RUN apt-get update
RUN apt install apache2 -yqq
RUN apt-get install python-pip -yqq
RUN pip install pymysql

RUN a2dismod mpm_event
RUN a2enmod mpm_prefork cgi

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

EXPOSE 80

ADD https://s3.amazonaws.com/richbourg-s3/mtwa/web/000-default.conf /etc/apache2/sites-enabled/000-default.conf
ADD https://s3.amazonaws.com/richbourg-s3/mtwa/web/ports.conf /etc/apache2/ports.conf

RUN mkdir /etc/mtwa
RUN mkdir /var/www/html/appdemo

ADD Multi-Tier-App-Demo/mtwa.conf /etc/mtwa/mtwa.conf
ADD Multi-Tier-App-Demo/html/* /var/www/html/appdemo/
ADD Multi-Tier-App-Demo/scripts/* /var/www/html/appdemo/
 

