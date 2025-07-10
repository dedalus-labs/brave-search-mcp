# Use official Node.js runtime as base image
FROM node:18-alpine

# Set working directory inside container
WORKDIR /app

# Copy package files first for better caching
COPY package.json package-lock.json* ./

# Install dependencies
RUN npm install

# Install TypeScript globally for running .ts files directly
RUN npm install -g typescript ts-node

# Copy source code
COPY . .

# Build the TypeScript code
RUN npm run build

# Create a non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S mcp -u 1001

# Change ownership of app directory to non-root user
RUN chown -R mcp:nodejs /app
USER mcp

# Expose port 8000 for the MCP server
EXPOSE 8000

# Health check to ensure server is running
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8000/ || exit 1

# Set environment variables
ENV NODE_ENV=production
ENV PORT=8000

# Command to run the server
# Use compiled JavaScript for production, with --port flag for HTTP transport
CMD ["node", "dist/index.js", "--port", "8000"]