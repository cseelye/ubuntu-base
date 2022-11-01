
# Make sure everything builds but don't save it as a tagged image
.PHONY: test-build
test-build: test-build20 test-build22 ;

.PHONY: test-build22
test-build22:
	docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 --build-arg UBUNTU_VERSION=22.04 --target=base . && \
	docker buildx build --platform linux/amd64,linux/arm64 --build-arg UBUNTU_VERSION=22.04 --target=base-dev . && \
	docker buildx build --platform linux/amd64,linux/arm64 --build-arg UBUNTU_VERSION=22.04 --target=base-ansible-dev .
.PHONY: test-build20
test-build20:
	docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 --target=base . && \
	docker buildx build --platform linux/amd64,linux/arm64 --target=base-dev . && \
	docker buildx build --platform linux/amd64,linux/arm64 --target=base-ansible-dev .

#
# Build individual images
#
.PHONY:base-intel
base-intel:
	docker buildx build --load --platform linux/amd64 --target base -t local/ubuntu-base-intel .

.PHONY:base-arm
base-arm:
	docker buildx build --load --platform linux/arm/v7 --target base -t local/ubuntu-base-arm .

.PHONY:base-arm64
base-arm64:
	docker buildx build --load --platform linux/arm64 --target base -t local/ubuntu-base-arm64 .

.PHONY:dev-intel
dev-intel:
	docker buildx build --load --platform linux/amd64 --target base-dev -t local/ubuntu-base-dev-intel .

.PHONY:dev-arm64
dev-arm64:
	docker buildx build --load --platform linux/arm64 --target base-dev -t local/ubuntu-base-dev-arm64 .

.PHONY:ansible-dev-intel
ansible-dev-intel:
	docker buildx build --load --platform linux/amd64 --target base-ansible-dev -t local/ubuntu-base-dev-intel .

.PHONY:ansible-dev-arm64
ansible-dev-arm64:
	docker buildx build --load --platform linux/arm64 --target base-ansible-dev -t local/ubuntu-base-dev-arm64 .
