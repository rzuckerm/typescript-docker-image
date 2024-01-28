FROM node:20.11.0-alpine3.19

COPY TYPESCRIPT_* /tmp/
RUN npm install -g typescript@$(cat /tmp/TYPESCRIPT_VERSION) @types/node@$(cat /tmp/TYPESCRIPT_TYPES_VERSION)
