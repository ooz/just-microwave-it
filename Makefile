all:
	zip -9 -r just-microwave-it.love ./ -x *.git* -x Makefile -x \*asset_src\* -x \*unused\* -x \*screenshots\*

test:
	love ./ --console

clean:
	rm -rf just-microwave-it.love

.PHONY: all test clean
