FROM python:3.12.9

WORKDIR /usr/app

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 更新清华源
RUN sed -i 's/http:\/\/deb.debian.org/https:\/\/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list.d/debian.sources \
    && apt-get update \
    && apt-get install --reinstall libgl1-mesa-glx libgl1-mesa-dri vim -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* # 额外清理apt的列表文件

COPY . .

# 安装
RUN sh uv-installer.sh && export PATH="$HOME/.local/bin:$PATH" && uv sync && uv pip install -e ".[prj]"

EXPOSE 6800

CMD ["bash", "-c", "source .venv/bin/activate && cd scrapyd && python __main__.py"]
