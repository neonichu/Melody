.PHONY: test

test:
	pod lib lint Melody.podspec.json --allow-warnings
	conche test
