# ----- STAGE 1: Builder -----
# 在这个阶段，我们使用标准的 Node.js 镜像来构建您的自定义节点
FROM node:20-alpine AS builder

RUN npm install -g pnpm
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
COPY . .
# 运行编译命令，确保所有 ts 文件被转换为 js
RUN pnpm run build

# ----- STAGE 2: Final n8n Image -----
# --- 核心：使用 n8n 最新的 Debian 镜像 (自带 Node.js 18+，包含 apt-get) ---
FROM docker.n8n.io/n8nio/n8n:latest-debian

# 切换到 root 用户以安装系统依赖
USER root

# --- 核心：使用 apt-get 安装 Playwright 的系统依赖 ---
# 这个命令在新版 Debian 上可以完美运行
RUN apt-get update && \
    npx playwright install-deps chromium && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 设置自定义节点的工作目录
# 注意：这里使用与您 docker-compose.yml 中 volumes 一致的路径
WORKDIR /home/node/.n8n_playwright/custom

# 从 'builder' 阶段复制构建好的产物 (dist 目录) 和 package.json
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./package.json

# 只安装生产环境所需的依赖
RUN npm install --omit=dev && npm cache clean --force

# 将整个自定义数据目录的所有权交还给 n8n 的运行用户 (node)
RUN chown -R node:node /home/node/.n8n_playwright

# 切换回普通用户
USER node
WORKDIR /home/node/
