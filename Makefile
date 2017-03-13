NAME := $(shell jq -r .docker_name package.json)
TAG := $(shell jq -r .version package.json)

image:
	docker build -t ${NAME}:${TAG} .

image-no-cache:
	docker build --rm=true --no-cache -t ${NAME}:${TAG} .
	docker tag ${NAME}:${TAG} ${NAME}:latest

tests:
	npm test

push: image tests
	docker push ${NAME}:${TAG}
	docker rmi ${NAME}:${TAG}
