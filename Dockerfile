# Use official lightweight Node image
FROM node:18-alpine

# Create app directory
WORKDIR /usr/src/app

# Copy package metadata and install
COPY package.json ./
RUN npm install --production

# Copy app sources
COPY app/ ./app/

EXPOSE 3000

# Run the app
CMD ["npm", "start"]
