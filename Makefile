all: prepare build push

prepare:
	docker pull alpine:3.6

build:
	docker build --squash -t gone/haproxy --no-cache .

push:
	docker push gone/haproxy