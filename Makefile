IMAGE_NAME=sampler
DEPS=Dockerfile
KEEPFILE=.imagebuild_$(IMAGE_NAME)

KEEPFILE?=.imagebuild_$(shell echo $(IMAGE_NAME) | cut -d ':' -f 1)
DOCKER_USERNAME?=erezbinyamin
PUSHTAG?=latest
BFLAGS?=
RFLAGS?=-it --network host --privileged

build:$(KEEPFILE)
$(KEEPFILE): $(DEPS)
	docker build $(BFLAGS) --tag $(IMAGE_NAME) .
	touch $(KEEPFILE)

rebuild:
	docker build $(BFLAGS) --no-cache --tag $(IMAGE_NAME) .
	touch $(KEEPFILE)

bash: build
	docker run --entrypoint "" $(RFLAGS) $(IMAGE_NAME) bash

clean:
	docker images | grep -q "^$(IMAGE_NAME)" && docker image rm $(IMAGE_NAME) || true
	rm -f $(KEEPFILE)

push: build
	docker tag $(IMAGE_NAME) $(DOCKER_USERNAME)/$(IMAGE_NAME):$(PUSHTAG)
	docker push $(DOCKER_USERNAME)/$(IMAGE_NAME)

example: build
	docker run --interactive --tty \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    --volume $(shell pwd)/example.yml:/root/config.yml \
    sampler --config /root/config.yml

help:
	@echo "Supported build targets:"
	@echo "  $(IMAGE_NAME): builds image"
	@echo "  build:   builds container locally"
	@echo "  rebuild: rebuilds container locally"
	@echo "  bash:    launches shell inside container"
	@echo "  example: runs sampler example.yml"
	@echo "  clean:   removes docker image from local repository"
	@echo "  help:    prints this help menu"
