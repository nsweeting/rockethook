CRYSTAL_BIN ?= $(shell which crystal)
ROCKETHOOK_BIN ?= $(shell which rockethook)
PREFIX ?= /usr/local/bin

build:
	$(CRYSTAL_BIN) build --release -o bin/rockethook src/rockethook.cr $(CRFLAGS)
clean:
	rm -f ./bin/rockethook
test: build
	$(CRYSTAL_BIN) spec
install: build
	mkdir -p $(PREFIX)
	sudo cp ./bin/rockethook $(PREFIX)/rockethook
reinstall: build
	cp ./bin/rockethook $(ROCKETHOOK_BIN) -rf
