APP=$(shell basename $(shell git remote get-url origin))
REGISTRY=vitvat
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=linux
TARGETARCH=amd64
TARGETNAME=kbot

a:
	$(eval TARGETARCH=arm64)

d: 
	$(eval TARGETOS=darwin)

w:
	$(eval TARGETOS=windows)
	$(eval TARGETNAME=kbot.exe)

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

get:
	go get

build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o ${TARGETNAME} -ldflags "-X="github.com/vitvat/kbot/cmd.appVersion=${VERSION}

linux: build

arm: a build

darwin: d build

windows: w build
	

image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

clean:
	rm -rf kbot
	rm -rf kbot.exe
	docker rmi -f ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}