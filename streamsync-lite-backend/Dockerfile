# Dockerfile (backend)
FROM node:20-alpine

WORKDIR /app
COPY package*.json ./
RUN npm install

COPY . .

# If you use Prisma:
RUN npx prisma generate

EXPOSE 3000

CMD ["npm", "run", "dev"]
