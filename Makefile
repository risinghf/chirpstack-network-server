.PHONY: build clean test package serve update-vendor api
VERSION := $(shell git describe --always |sed -e "s/^v//")
API_VERSION := $(shell go list -m -f '{{ .Version }}' github.com/brocaar/chirpstack-api/go/v3 | awk '{n=split($$0, a, "-"); print a[n]}')

GIT_BRANCH:=$(shell git branch --show-current 2>/dev/null)
ifndef $(GIT_BRANCH)
GIT_BRANCH:=$(shell git rev-parse --abbrev-ref HEAD)
endif

GIT_COMMIT = $(shell git rev-parse --short HEAD)
GIT_TAG=$(strip $(shell git describe --tags --abbrev=0))
BINARY_VERSION=$(GIT_BRANCH)-$(GIT_COMMIT)
BUILD_TIME=$(shell date "+%Y/%m/%d-%H:%M:%S")

ifeq ($(findstring $(GIT_BRANCH),$(GIT_TAG)),)
        IMAGE_VERSION=$(GIT_BRANCH)
        BINARY_VERSION=$(GIT_BRANCH)
else
        IMAGE_VERSION=$(GIT_TAG)
        BINARY_VERSION=$(GIT_TAG)
endif

build:
	@echo "Compiling source"
	@mkdir -p build
	go build $(GO_EXTRA_BUILD_ARGS) -ldflags "-s -w -X main.version=$(VERSION)" -o build/chirpstack-network-server cmd/chirpstack-network-server/main.go

image: build
	@echo "Start build image"
	docker build -f Dockerfile-rxhf -t registry.cn-shenzhen.aliyuncs.com/risinghf/chirpstack-network-server:$(IMAGE_VERSION) --push .
        #docker push registry.cn-shenzhen.aliyuncs.com/risinghf/chirpstack-network-server:$(IMAGE_VERSION) 

clean:
	@echo "Cleaning up workspace"
	@rm -rf build
