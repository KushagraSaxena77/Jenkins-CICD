
# Use official lightweight Node image
FROM node:18-alpine

# Create app directory
WORKDIR /usr/src/app

# Copy package metadata and install (no deps for this minimal app)
COPY package.json ./

# Copy app sources
COPY app/ ./app/

EXPOSE 3000

# Run the app
CMD ["node", "app/index.js"]
=======
FROM node:18-alpine
WORKDIR /app
COPY package.json .
RUN npm install --production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
>>>>>>> 9eac8d7a082bd601510aacec7907fc0f38a7e069
