all:
	zip -9 -r just-microwave-it.love ./ -x *.git* Makefile

test:
	love ./

.PHONY: all test
