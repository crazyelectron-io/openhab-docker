FROM node:alpine
## Install Wizzy
RUN apk add --no-cache bash && \
	npm install -g wizzy
## Set working directory and entrypoint
WORKDIR /wizzy
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
## Run the commands (default command is import)
ENTRYPOINT ["/entrypoint.sh"]
