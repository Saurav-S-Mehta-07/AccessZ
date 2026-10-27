FROM node:22-bookworm-slim

WORKDIR /app

COPY package.json package-lock.json ./
COPY backend/package.json backend/package.json
COPY frontend/package.json frontend/package.json
COPY backend/scripts backend/scripts

RUN npm ci --workspace backend --include-workspace-root=false --omit=dev

RUN npm exec --workspace backend playwright install-deps chromium

COPY backend/src backend/src

RUN npm run build --workspace backend \
    && PLAYWRIGHT_BROWSERS_PATH=0 node --input-type=module -e "const { chromium } = await import('playwright'); const browser = await chromium.launch({ headless: true }); console.log('Chromium image check:', browser.version()); await browser.close();"

ENV NODE_ENV=production
ENV PLAYWRIGHT_BROWSERS_PATH=0

USER node

CMD ["node", "backend/src/server.js"]
