
# Use Node.js 18 Alpine — lightweight Linux base image
FROM node:18-alpine

# Set working directory inside the container
WORKDIR /app

# Copy package files first
# Docker caches this layer — if package.json hasn't
# changed, it won't re-run npm install on next build
COPY package*.json ./

# Install dependencies inside the container
RUN npm install --production
# --production skips devDependencies — keeps image small

# Copy all application code
COPY . .

# Tell Docker our app runs on port 3000
EXPOSE 3000

# Start the server
CMD ["node", "server.js"]