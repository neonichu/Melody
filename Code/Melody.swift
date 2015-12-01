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

public struct Album: Decodable {
	let artist: Artist
	let artworkUrl: NSURL
	let genre: String
	let identifier: String
	let name: String
	let url: NSURL

	var appleMusicUrl: NSURL {
		return makeAppleMusicUrl(url, "Album.appleMusicUrl")
	}

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

public struct Artist: Decodable {
	let identifier: String
	let imageUrl: NSURL
	let name: String
	let url: NSURL

	var appleMusicUrl: NSURL {
		return makeAppleMusicUrl(url, "Artist.appleMusicUrl")
	}

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

public struct Track: Decodable {
	let artist: Artist
	let artworkUrl: NSURL
	let genre: String
	let identifier: String
	let name: String
	let url: NSURL

	var appleMusicUrl: NSURL {
		return makeAppleMusicUrl(url, "Track.appleMusicUrl")
	}

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

	public func searchAlbums(term: String, _ completion: ([Album]?, NSError?) -> Void) -> NSURLSessionDataTask {
		return search(term, .Album, completion)
	}

	public func searchTracks(term: String, _ completion: ([Track]?, NSError?) -> Void) -> NSURLSessionDataTask {
		return search(term, .Track, completion)
	}
}
