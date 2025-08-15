FROM python:3.12.9

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

# 先复制安装依赖所需的文件
ADD uv.tar.gz /usr/local/bin
COPY pyproject.toml .

# 安装项目依赖
RUN uv sync && uv pip install --no-cache-dir -e ".[prj]"

# 然后复制剩余文件
COPY . .

EXPOSE 6800

CMD ["bash", "-c", "cd scrapyd && python __main__.py"]