.PHONY: all doc test

all: test

doc:
	jazzy -o doc --podspec Melody.podspec.json
	@cat doc/undocumented.txt

test:
	pod lib lint Melody.podspec.json --allow-warnings --verbose
	conche test
