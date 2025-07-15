FROM python:3.12.9

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 更新清华源
RUN sed -i 's/http:\/\/deb.debian.org/https:\/\/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list.d/debian.sources \
    && apt-get update \
    && apt-get install --reinstall libgl1-mesa-glx libgl1-mesa-dri vim -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* # 额外清理apt的列表文件

# 上传脚本
ADD uv-installer.sh .

# 安装
RUN sh uv-installer.sh

WORKDIR /usr/app

COPY pyproject.toml .
COPY .python-version .

RUN export PATH="$HOME/.local/bin:$PATH" && uv sync && uv pip install -e ".[prj]"
