FROM node:18-alpine
WORKDIR /app

# install deps
COPY package.json package-lock.json* ./
RUN npm install --production || true

# copy source
COPY src ./src
COPY .env.example ./

ENV NODE_ENV=production
EXPOSE 4000
CMD ["node", "src/index.js"]
