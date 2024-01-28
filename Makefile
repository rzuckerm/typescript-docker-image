TYPESCRIPT_VERSION := $(shell cat TYPESCRIPT_VERSION)-$(shell cat TYPESCRIPT_TYPES_VERSION)
TYPESCRIPT_DEPS := $(wildcard TYPESCRIPT_*)
DOCKER_TAG_PREFIX := rzuckerm/typescript:$(TYPESCRIPT_VERSION)
DOCKER_TAG_SUFFIX ?= -dev

META_BUILD_TARGET := .meta-build
META_CREATE_BUILDER_TARGET := .meta-create-builder
META_BUILDX_TARGET := .meta-buildx

BUILDER := mybuilder
PLATFORMS := linux/amd64 linux/arm64
COMMA := ,
NOTHING :=
SPACE := $(NOTHING) $(NOTHING)

BUILDX = docker buildx build \
	--builder=$(BUILDER) \
	--platform $(subst $(SPACE),$(COMMA),$(PLATFORMS)) \
	-t $(DOCKER_TAG_PREFIX)$(DOCKER_TAG_SUFFIX) \
	-f Dockerfile .

.PHONY: help
help:
	@echo "build         - Build docker image"
	@echo "buildx        - Build multi-arch docker images"
	@echo "clean         - Clean build output"
	@echo "test          - Test docker image"
	@echo "publish       - Publish docker image"
	@echo "publishx      - Publish mult-arch docker images"
	@echo ""

.PHONY: build
build: $(META_BUILD_TARGET)
$(META_BUILD_TARGET): Dockerfile Makefile $(TYPESCRIPT_DEPS)
	@echo "*** Building regular $(DOCKER_TAG_PREFIX)$(DOCKER_TAG_SUFFIX) ***"
	docker rmi -f $(DOCKER_TAG_PREFIX)$(DOCKER_TAG_SUFFIX)
	docker build -t $(DOCKER_TAG_PREFIX)$(DOCKER_TAG_SUFFIX) -f Dockerfile .
	touch $@
	rm -f $(META_BUILDX_TARGET)
	@echo ""

.PHONY: buildx
buildx: $(META_BUILDX_TARGET)
$(META_BUILDX_TARGET): $(META_CREATE_BUILDER_TARGET) Dockerfile Makefile $(TYPESCRIPT_DEPS)
	@echo "*** Building multi-arch $(DOCKER_TAG_PREFIX)$(DOCKER_TAG_SUFFIX) ***"
	docker rmi -f $(DOCKER_TAG_PREFIX)$(DOCKER_TAG_SUFFIX)
	$(BUILDX)
	touch $@
	rm -f $(META_BUILD_TARGET)
	@echo ""

.PHONY: create-builder
create-builder: $(META_CREATE_BUILDER_TARGET)
$(META_CREATE_BUILDER_TARGET):
	@echo "*** Creating builder if does not exist ***"
	@if ! (docker buildx ls | grep -sq $(BUILDER)); then docker buildx create --name $(BUILDER); fi
	touch $@
	@echo ""

.PHONY: clean
clean:
	rm -f .meta*

.PHONY: test
test: $(META_BUILD_TARGET)
	@echo "*** Testing regular $(DOCKER_TAG_PREFIX)$(DOCKER_TAG_SUFFIX) ***"
	./test.sh $(DOCKER_TAG_PREFIX)$(DOCKER_TAG_SUFFIX)
	@echo ""


.PHONY: publish
publish: $(META_BUILD_TARGET)
	@echo "*** Publishing regular $(DOCKER_TAG_PREFIX)$(DOCKER_TAG_SUFFIX) ***"
	docker push $(DOCKER_TAG_PREFIX)$(DOCKER_TAG_SUFFIX)
	@echo ""

.PHONY: publishx
publishx: $(META_CREATE_BUILDER_TARGET)
	@echo "*** Publishing multi-arch $(DOCKER_TAG_PREFIX)$(DOCKER_TAG_SUFFIX) ***"
	docker rmi -f $(DOCKER_TAG_PREFIX)$(DOCKER_TAG_SUFFIX)
	$(BUILDX) --push
	@echo ""
