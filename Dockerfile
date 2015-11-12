FROM node:4.2

EXPOSE 3000

RUN npm install -g express@4.10.6

ADD . /srv

WORKDIR /srv

CMD node server
