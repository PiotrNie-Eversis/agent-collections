# Multi-stage build for the eversis-collections MCP server (stdio transport).
# Runtime stage ships no dev toolchain and runs as a non-root user; only
# `dist/` + production dependencies are present.

FROM node:20-slim AS builder
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install
COPY tsconfig.json ./
COPY src ./src
RUN npm run build

FROM node:20-slim AS runtime
WORKDIR /app
ENV NODE_ENV=production
COPY package.json package-lock.json ./
RUN npm install --omit=dev && npm cache clean --force
COPY --from=builder /app/dist ./dist
RUN groupadd --system eversis \
  && useradd --system --gid eversis --home-dir /app --shell /usr/sbin/nologin eversis \
  && chown -R eversis:eversis /app
USER eversis

ENTRYPOINT ["node", "dist/index.js"]
