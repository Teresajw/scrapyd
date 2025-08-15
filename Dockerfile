FROM python:3.12.9

WORKDIR /etc/scrapyd

ENV TZ=Asia/Shanghai

RUN ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN sed -i 's/http:\/\/deb.debian.org/https:\/\/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list.d/debian.sources \
    && apt-get update \
    && apt-get install --reinstall libgl1-mesa-glx libgl1-mesa-dri vim -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY . .

RUN sh uv-installer.sh && export PATH="$HOME/.local/bin:$PATH" && uv sync && uv pip install -e ".[prj]"

ENV PATH="/etc/scrapyd/.venv/bin:$PATH"

EXPOSE 6800

CMD ["bash", "-c", "cd scrapyd && python __main__.py"]