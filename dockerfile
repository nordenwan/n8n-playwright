# ----- STAGE 1: Builder -----
# 构建您的自定义节点
FROM node:20-alpine AS builder

RUN npm install -g pnpm
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
COPY . .
RUN pnpm run build

# ----- STAGE 2: Final n8n Image -----
# --- 使用 n8n 最新的、基于 Debian 的镜像 ---
FROM docker.n8n.io/n8nio/n8n:latest-debian

# 切换到 root 用户
USER root

# --- 使用 apt-get 安装依赖 ---
# 这个命令在新的 Debian 镜像上可以正常工作
RUN apt-get update && \
    npx playwright install-deps chromium && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 设置自定义节点的工作目录
WORKDIR /home/node/.n8n_playwright/custom

# 从 'builder' 阶段复制构建好的代码
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./package.json

# 只安装生产依赖
RUN npm install --omit=dev && npm cache clean --force

# 修正权限
RUN chown -R node:node /home/node/.n8n_playwright

# 切换回普通用户
USER node
WORKDIR /home/node/
