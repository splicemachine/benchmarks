NAME = splicemachine/benchmark
VERSION = 0.3.0

.PHONY: all build clean push realclean

all: build

run:
	docker run -e SCALE=1 $(NAME):$(VERSION) -h localhost

build:
	docker build --rm --compress -t $(NAME):$(VERSION) -f Dockerfile .
	docker tag $(NAME):$(VERSION) $(NAME):latest

push:
	docker push $(NAME):latest
	docker push $(NAME):$(VERSION)
	#docker push $(NAME):$(GITTAG)

clean:
	-docker rmi $(NAME):latest
	-docker rmi $(NAME):$(VERSION)
	#-docker rmi $(NAME):$(GITTAG)
	#-docker system prune -f  #-a

realclean:
	-docker kill $(shell docker ps -q)
	-docker rm $(shell docker ps -a -q)
	-docker rmi $(shell docker images -q)
	-docker system prune -f -a
