# aq3stat前端应用Dockerfile
# 多阶段构建：构建阶段 + 运行阶段

# 构建阶段
FROM node:18-alpine AS builder
RUN echo "https://mirrors.aliyun.com/alpine/v3.19/main" > /etc/apk/repositories && echo "https://mirrors.aliyun.com/alpine/v3.19/community" >> /etc/apk/repositories

# 设置构建参数
ARG NODE_VERSION=18
ARG VUE_APP_API_BASE_URL=/api
ARG VUE_APP_TITLE="aq3stat网站统计系统"
ARG BUILD_TIME
ARG VERSION

# 设置工作目录
WORKDIR /app

# 安装构建依赖
RUN apk add --no-cache git python3 make g++

# 复制package文件
COPY package.json ./

# 安装依赖（包括开发依赖，用于构建）
RUN npm install --silent

# 复制源代码
COPY . .

# 设置环境变量
ENV VUE_APP_API_BASE_URL=${VUE_APP_API_BASE_URL}
ENV VUE_APP_TITLE=${VUE_APP_TITLE}
ENV VUE_APP_VERSION=${VERSION}
ENV VUE_APP_BUILD_TIME=${BUILD_TIME}

# 构建应用
RUN npm run build

# 运行阶段
FROM nginx:1.24-alpine
RUN echo "https://mirrors.aliyun.com/alpine/v3.18/main" > /etc/apk/repositories && echo "https://mirrors.aliyun.com/alpine/v3.18/community" >> /etc/apk/repositories

# 设置标签
LABEL maintainer="aq3stat Team <support@aq3stat.com>"
LABEL description="aq3stat Website Statistics System Frontend"
LABEL version="${VERSION}"

# 安装运行时依赖
RUN apk add --no-cache \
    curl \
    tzdata \
    && rm -rf /var/cache/apk/*

# 设置时区
ENV TZ=Asia/Shanghai

# 创建nginx用户目录
RUN mkdir -p /var/cache/nginx/client_temp \
             /var/cache/nginx/proxy_temp \
             /var/cache/nginx/fastcgi_temp \
             /var/cache/nginx/uwsgi_temp \
             /var/cache/nginx/scgi_temp \
             /var/log/nginx \
             /etc/nginx/ssl

# 从构建阶段复制构建产物
COPY --from=builder /app/dist /usr/share/nginx/html

# 复制nginx配置文件
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf

# 创建nginx配置目录并设置权限
RUN chown -R nginx:nginx /usr/share/nginx/html \
                         /var/cache/nginx \
                         /var/log/nginx \
                         /etc/nginx/ssl

# 暴露端口
EXPOSE 80 443

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# 启动nginx
CMD ["nginx", "-g", "daemon off;"]
