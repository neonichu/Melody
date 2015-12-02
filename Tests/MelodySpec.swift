import Foundation
@testable import Melody
import Spectre

describe("melody") {
	$0.it("should generate search URLs") {
		let url = Melody().searchUrl("lucky")

		try expect(url) == NSURL(string:"https://sticky-summer-lb.inkstone-clients.net/api/v1/searchMusic?term=lucky&genreId=&limit=30&lang=en_us&country=de&media=appleMusic&entity=track")!
	}

	$0.it("should parse JSON responses") {
		let fixture = NSData(contentsOfFile: "Tests/fixture.json")!
		let json = try NSJSONSerialization.JSONObjectWithData(fixture, options: [])
		let track: Track = try Melody().parse(json).first!
		let urlString = "https://itunes.apple.com/de/album/get-lucky-radio-edit-feat./id636967993?i=636968288"

		try expect(track.artist.name) == "Daft Punk"
		try expect(track.artist.url) == NSURL(string: "https://itunes.apple.com/de/artist/daft-punk/id5468295")!
		try expect(track.name) == "Get Lucky (Radio Edit) [feat. Pharrell Williams]"
		try expect(track.url) == NSURL(string: urlString)!
		try expect(track.appleMusicUrl) == NSURL(string: "\(urlString)&app=music")!
	}

	$0.it("can fetch live data for albums") {
		let expectation = Expectation(timeoutInterval: 15)

		var albums: [Album]?
		var error: NSError?

		Melody().searchAlbums("nirvana") {
			albums = $0
			error = $1

			expectation.fulfil()
		}

		try expectation.wait()

		let album = albums?.first
		try expect(album != nil).to.beTrue()

		if let album = album {
			try expect(album.name) == "Smells Like Teen Spirit"
		}
	}

	$0.it("can fetch live data for tracks") {
		let expectation = Expectation(timeoutInterval: 15)

		var error: NSError?
		var tracks: [Track]?
		
		Melody().searchTracks("lucky") {
			tracks = $0
			error = $1

			expectation.fulfil()
		}

		try expectation.wait()

		try expect(tracks != nil).to.beTrue()
		try expect(error).to.beNil()

		if let track = tracks?.first! {
			try expect(track.name) == "Get Lucky (Radio Edit) [feat. Pharrell Williams]"
		}
	}
}
