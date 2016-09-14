# Melody

[![No Maintenance Intended](http://unmaintained.tech/badge.svg)](http://unmaintained.tech/)

![](http://i.giphy.com/U77vQrdZYt8EU.gif)

A library for retrieving iTunes Music Store information.

## Usage

You can search for albums or tracks and retrieve some model objects:

```swift
Melody().searchTracks("lucky") { (tracks, _) in
	if let track = tracks?.first {
		print("\(track.name): \(track.appleMusicUrl)")
	}
}
```

The `appleMusicUrl` will open directly in `Music.app` :tada:

## Unit Tests

The tests require [Conche][1], install it via [Homebrew][2]:

```
$ brew install --HEAD kylef/formulae/conche
```

and run the tests:

```
$ make test
```

[1]: https://github.com/Conche/conche
[2]: http://brew.sh
