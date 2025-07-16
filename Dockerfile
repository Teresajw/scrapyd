FROM python:3.12.9 AS builder

WORKDIR /usr/app

# 安装系统依赖
RUN apt-get update && apt-get install -y libgl1-mesa-glx libgl1-mesa-dri vim && rm -rf /var/lib/apt/lists/*

COPY . .

RUN sh uv-installer.sh && uv sync && uv pip install -e ".[prj]"


FROM python:3.12.9 AS runner

WORKDIR /usr/app

ENV TZ=Asia/Shanghai
RUN ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN sed -i 's/http:\/\/deb.debian.org/https:\/\/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list.d/debian.sources \
    && apt-get update \
    && apt-get install --reinstall libgl1-mesa-glx libgl1-mesa-dri vim -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 复制虚拟环境和代码
COPY --from=builder /usr/app/.venv .
COPY --from=builder /usr/app/scrapyd .

ENV PATH="/usr/app/.venv/bin:$PATH"

EXPOSE 6800

CMD ["bash", "-c", "cd scrapyd && python __main__.py"]