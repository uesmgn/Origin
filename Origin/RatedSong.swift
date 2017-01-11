import RealmSwift
import KDEAudioPlayer

class RatedSong: Object {
    dynamic var id = ""
    dynamic var title = ""
    dynamic var artist = ""
    dynamic var album = ""
    dynamic var artworkUrl: String?
    dynamic var artworkData: Data?
    dynamic var trackSource = ""
    dynamic var have: Bool = false
    dynamic var rating = 0
    dynamic var isKnown: Bool = false //既知

    var audioItem: AudioItem? {
        let item = AudioItem(mediumQualitySoundURL: URL(string: trackSource))
        item?.title = title
        item?.artist = artist
        item?.album = album
        item?.artworkUrl = artworkUrl
        if let data = artworkData {
            item?.artworkImage = UIImage(data: data)
        }
        return item
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}
