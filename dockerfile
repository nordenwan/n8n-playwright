# 核心修改 1: 使用与您版本号相同的、但基于 Debian 的镜像
# 这确保了 apt-get 命令的存在
FROM docker.n8n.io/n8nio/n8n:1.79.3-debian

# 切换到 root 用户以安装依赖
USER root

# 核心修改 2: 为旧版 Debian 修复软件源
# 这是必须的，否则 apt-get update 会失败
RUN sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/archive.debian.org/g' /etc/apt/sources.list && \
    sed -i '/buster-updates/d' /etc/apt/sources.list

# 您的原始依赖列表，只做了一处必要的修改
RUN apt-get update && apt-get install -y --no-install-recommends \
    libwoff1 \
    libopus0 \
    libwebp6 \
    libwebpdemux2 \
    libenchant1c2a \
    libgudev-1.0-0 \
    libsecret-1-0 \
    libhyphen0 \
    libgdk-pixbuf2.0-0 \
    libegl1 \
    libnotify4 \
    libxslt1.1 \
    libevent-2.1-7 \
    libgles2 \
    libvpx6 \
    libxcomposite1 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libatspi2.0-0 \
    libcairo2 \
    libepoxy0 \
    libfontconfig1 \
    libfreetype6 \
    libgbm1 \
    libglib2.0-0 \
    libharfbuzz0b \
    libicu66 \
    libjpeg8 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libpangoft2-1.0-0 \
    libpixman-1-0 \
    libpng16-16 \
    libwayland-client0 \
    libwayland-egl1 \
    libwayland-server0 \
    libx11-6 \
    libdbus-glib-1-2 \
    libxt6 \
    libxcb1 \
    libxext6 \
    libxfixes3 \
    libpci3 \
    libasound2 \
    libxi6 \
    libxkbcommon0 \
    libxrandr2 \
    libxrender1 \
    libxshmfence1 \
    libgtk-3-0 \
    fonts-liberation \
    fonts-noto-color-emoji \
    # 核心修改 3: 移除了 Debian 中不存在的 'ttf-ubuntu-font-family' 包
    && rm -rf /var/lib/apt/lists/*

# 切换回 node 用户
USER node

# 后续所有内容均与您原始文件保持一致
# Set working directory
WORKDIR /home/node/.n8n

# Create a volume for persistent data
VOLUME /home/node/.n8n

# Expose port 5678
EXPOSE 5678

# Set environment variables
ENV NODE_ENV=production

# Use the default n8n command to start the application
CMD ["n8n", "start"]
