docker:
	docker build -t ship .

shell:
	docker run --rm -it \
		-v `pwd`/out:/out \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v `pwd`:/go/src/github.com/replicatedcom/ship \
		ship

githooks:
	echo 'make test' > .git/hooks/pre-push
	chmod +x .git/hooks/pre-push
	echo 'make fmt' > .git/hooks/pre-commit
	chmod +x .git/hooks/pre-commit

dep:
	dep ensure

fmt:
	goimports -w pkg
	goimports -w cmd


_vet:
	go vet ./pkg/...
	go vet ./cmd/...

vet: fmt _vet

_lint:
	golint ./pkg/... | grep -vE '_mock|e2e' || :
	golint ./cmd/... | grep -vE '_mock|e2e' || :

lint: vet _lint

_test:
	go test -v ./pkg/...

test: lint _test

build: test _build

_build:
	go build \
	    -i \
		-o bin/ship \
		./cmd/ship

e2e:
	./bin/ship e2e



run:
	./bin/ship --log-level=debug --studio-file=./app.yml

# this should really be in a different repo
build_yoonit_docker_image:
	docker build -t replicated/yoonit:latest -f deploy/Dockerfile-yoonit .
