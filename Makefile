CRYSTAL_BIN ?= $(shell which crystal)
ROCKETHOOK_BIN ?= $(shell which rockethook)
PREFIX ?= /usr/local

build:
	$(CRYSTAL_BIN) build --release -o bin/rockethook src/rockethook.cr $(CRFLAGS)
clean:
	rm -f ./bin/rockethook
test: build
	$(CRYSTAL_BIN) spec
install: build
	mkdir -p $(PREFIX)/bin
	cp ./bin/rockethook $(PREFIX)/bin
reinstall: build
	cp ./bin/rockethook $(ROCKETHOOK_BIN) -rf
