
docker-build: antidote-connect
	docker build . -t peterzel/antidote-connect

antidote-connect: antidote-connect.go
	go build antidote-connect.go

deps:
	go get -v -t ./...