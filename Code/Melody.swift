import Decodable
import Foundation

private func undefined<T>(hint:String="", file:StaticString=__FILE__, line:UInt=__LINE__) -> T {
    let message = hint == "" ? "" : ": \(hint)"
    fatalError("undefined \(T.self)\(message)", file:file, line:line)
}

private func makeAppleMusicUrl(url: NSURL, _ propertyName: String) -> NSURL {
	let urlString = "\(url.absoluteString)&app=music"
	return NSURL(string: urlString) ?? undefined("can't generate \(propertyName)")
}

/// Model object for an iTunes album
public struct Album: Decodable {
	/// Artist who made the album
	public let artist: Artist
	/// URL to an image of the album art
	public let artworkUrl: NSURL
	/// Genre
	public let genre: String
	/// iTunes identifier
	public let identifier: String
	/// Album name
	public let name: String
	/// iTunes URL for the album
	public let url: NSURL

	/// Apple Music URL for the album
	public var appleMusicUrl: NSURL {
		return makeAppleMusicUrl(url, "Album.appleMusicUrl")
	}

	/// Decode album from JSON
	public static func decode(json: AnyObject) throws -> Album {
		let artworkUrlString: String = try json => "artworkUrl100"
		let urlString: String = try json => "trackViewUrl"

		return try Album(
			artist: Artist.decode(json),
			artworkUrl: NSURL(string: artworkUrlString) ?? undefined("can't decode Album.artworkUrl"),
			genre: json => "primaryGenreName",
			identifier: json => "id",
			name: json => "name",
			url: NSURL(string: urlString) ?? undefined("can't decode Album.urlString")
		)
	}
}

/// Model object for an iTunes artist
public struct Artist: Decodable {
	/// iTunes identifier
	public let identifier: String
	/// URL to an image of the artist
	public let imageUrl: NSURL
	/// Artist name
	public let name: String
	/// iTunes URL for the artist
	public let url: NSURL

	/// Apple Music URL for the artist
	public var appleMusicUrl: NSURL {
		return makeAppleMusicUrl(url, "Artist.appleMusicUrl")
	}

	/// Decode artist from JSON
	public static func decode(json: AnyObject) throws -> Artist {
		let artistUrlString: String = try json => "artistUrl"
		let imageUrlString: String = try json => "artistImage"

		return try Artist(
			identifier: json => "artistId",
			imageUrl: NSURL(string: imageUrlString) ?? undefined("can't decode Artist.imageUrl"),
			name: json => "artistName",
			url: NSURL(string: artistUrlString) ?? undefined("can't decode Artist.artistUrl")
		)
	}
}

/// Model object for an iTunes track
public struct Track: Decodable {
	/// Artist who made the track
	public let artist: Artist
	/// URL to an image of the album art
	public let artworkUrl: NSURL
	/// Genre
	public let genre: String
	/// iTunes identifier
	public let identifier: String
	/// Track name
	public let name: String
	/// iTunes URL of the track
	public let url: NSURL

	/// Apple Music URL of the track
	public var appleMusicUrl: NSURL {
		return makeAppleMusicUrl(url, "Track.appleMusicUrl")
	}

	/// Decode track from JSON
	public static func decode(json: AnyObject) throws -> Track {
		//let artworkUrlString: String = try json => "artwork" => "url"
		let artworkUrlString: String = try json => "artworkUrl100"
		let urlString: String = try json => "trackViewUrl"

		return try Track(
			artist: Artist.decode(json),
			artworkUrl: NSURL(string: artworkUrlString) ?? undefined("can't decode Track.artworkUrl"),
			genre: json => "primaryGenreName",
			identifier: json => "id",
			name: json => "name",
			url: NSURL(string: urlString) ?? undefined("can't decode Track.urlString")
		)
	}
}

enum Entity: String {
	case Album = "album"
	case Track = "track"
}

/// Search the iTunes Store for albums and tracks
public class Melody {
	private let baseUrl = "https://sticky-summer-lb.inkstone-clients.net/api/v1/searchMusic"
	private let session: NSURLSession

	func parse<T: Decodable>(json: AnyObject) throws -> [T] {
		return try json => "results"
	}

	func searchUrl(term: String, entity: Entity = .Track, country: String = "de") -> NSURL {
		let parameters: [String:AnyObject] = [
			"term": term,
			"country": country,
			"media": "appleMusic",
			"entity": entity.rawValue,
			"genreId": "",
			"limit": 30,
			"lang": "en_us"
		]

		let components = NSURLComponents(string: baseUrl) ?? undefined("NSURLComponents is nil")
		components.queryItems = parameters.map() { (key, value) in 
			NSURLQueryItem(name: key, value: value.description)
		}

		return components.URL ?? undefined("NSURLComponents.URL is nil")
	}

	/// Initializer
	public init() {
		let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
		session = NSURLSession(configuration: sessionConfiguration)
	}

	private func search<T: Decodable>(term: String, _ entity: Entity, _ completion: ([T]?, NSError?) -> Void) -> NSURLSessionDataTask {
		let task = session.dataTaskWithURL(searchUrl(term)) { (data, response, error) in
			var elements: [T]?

			if let data = data, json = try? NSJSONSerialization.JSONObjectWithData(data, options: []) {
				elements = try? self.parse(json)
			}

			completion(elements, error)
		}

		task.resume()
		return task
	}

	/// Search for albums
	public func searchAlbums(term: String, _ completion: ([Album]?, NSError?) -> Void) -> NSURLSessionDataTask {
		return search(term, .Album, completion)
	}

	/// Search for tracks
	public func searchTracks(term: String, _ completion: ([Track]?, NSError?) -> Void) -> NSURLSessionDataTask {
		return search(term, .Track, completion)
	}
}
