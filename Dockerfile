FROM python:3.9.14-slim-bullseye

COPY ./workspace /workspace/
WORKDIR /workspace
RUN pip install -r /workspace/requirements.txt
RUN chmod +x /workspace/start.sh
CMD ["sh", "/workspace/start.sh"]