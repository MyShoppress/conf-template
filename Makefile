DOCKER_COMPOSE_BIN := docker-compose
BOX=.box.phar
$(BOX):
	wget -q https://github.com/box-project/box/releases/download/3.12.2/box.phar -O$(BOX)

clean:
	rm -rf ./dist/*

build-phar: $(BOX) clean
	echo "Compiling"
	chmod +x $(BOX)
	./$(BOX) compile

build-image: build-phar
	docker build --no-cache -t myshoppress/tmpl:$(VER) -f dockerfile-phar .
	docker run --rm -it -v $(shell pwd)/examples:/app myshoppress/tmpl "-f nginx.conf.hbs"

ifdef VER

check-version:
	@echo "Makeing release $(VER)"

docker-rel: build-image
	docker push myshoppress/tmpl:$(VER)

git-rel: build-phar
	gh release create $(VER) ./dist/tmpl -t "Release $(VER)"  -p

release: test clean check-version git-rel docker-rel

endif

build-dep:
	@$(DOCKER_COMPOSE_BIN) run --rm php composer update


test:
	@$(DOCKER_COMPOSE_BIN) run --rm php "composer run test"

