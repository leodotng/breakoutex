.PHONY: help

APP_NS ?= neslinesli93
APP_NAME ?= `grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g'`
APP_VSN ?= `grep 'version:' mix.exs | cut -d '"' -f2`
BUILD ?= `git rev-parse --short HEAD`

help:
	@echo "$(APP_NAME):$(APP_VSN)-$(BUILD)"
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## Build the Docker image for prod use
	docker build -f Dockerfile-prod \
		--build-arg APP_NAME=$(APP_NAME) \
		--build-arg APP_VSN=$(APP_VSN) \
		-t $(APP_NS)/$(APP_NAME):$(APP_VSN)-$(BUILD) \
		-t $(APP_NS)/$(APP_NAME):latest .

run: ## Run the app in Docker, using prod env
	docker run --env-file env/docker.env.prod \
		--expose 4000 -p 4000:4000 \
		--rm -it $(APP_NS)/$(APP_NAME):latest
