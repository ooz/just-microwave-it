all:
	zip -9 -r just-microwave-it.love ./ -x *.git* -x Makefile -x \*asset_src\* -x \*unused\*

test:
	love ./ --console

.PHONY: all test
