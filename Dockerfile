FROM node:4.2

EXPOSE 3000

ADD . /srv

WORKDIR /srv

CMD node server
