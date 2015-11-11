FROM node:4.2

ADD . /srv

WORKDIR /srv

RUN npm install

EXPOSE 3000

CMD node app.js