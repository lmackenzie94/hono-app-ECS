FROM node:18-slim

WORKDIR /app

COPY package*.json ./
COPY index.mjs ./

RUN npm install

EXPOSE 3000

CMD ["npm", "start"]