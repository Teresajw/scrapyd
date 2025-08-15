FROM python:3.12.9 AS builder

WORKDIR /usr/app

# 先复制安装依赖所需的文件
ADD uv.tar.gz /usr/local/bin

COPY . .

# 安装系统依赖
RUN apt-get update && apt-get install -y libgl1-mesa-glx libgl1-mesa-dri vim && rm -rf /var/lib/apt/lists/*

RUN uv --version  && uv sync && uv pip install -e ".[prj]"


FROM python:3.12.9 AS runner

WORKDIR /etc/scrapyd

ENV TZ=Asia/Shanghai \
    PATH="/etc/scrapyd/.venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    PYTHONPYCACHEPREFIX=/tmp/pycache

RUN ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN sed -i 's/http:\/\/deb.debian.org/https:\/\/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list.d/debian.sources \
    && apt-get update \
    && apt-get install --reinstall libgl1-mesa-glx libgl1-mesa-dri vim -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 复制虚拟环境和代码
COPY --from=builder /usr/local/bin/uv* /usr/local/bin
COPY --from=builder /usr/app/.venv /etc/scrapyd/.venv
COPY --from=builder /usr/app/scrapyd /etc/scrapyd

EXPOSE 6800

CMD ["bash", "-c", "python __main__.py"]