import RealmSwift

class UserSong: Object {
    dynamic var id = 0
    dynamic var title = ""
    dynamic var artist = ""
    dynamic var album = ""
    dynamic var artwork:Data?
    dynamic var trackSource = ""
    dynamic var rating = 0
    dynamic var isKnown:Bool = true //既知
    dynamic var playbackTime = 0
    
    func playbackTimeStr() -> String {
        let ms = self.playbackTime
        return "\(ms/1000/60):\(ms/1000%60)"
    }
    override static func primaryKey() -> String? {
        return "id"
    }
}

class OtherSong: Object {
    dynamic var id = 0
    dynamic var title = ""
    dynamic var artist = ""
    dynamic var artistUrl = ""
    dynamic var album = ""
    dynamic var artwork = ""
    dynamic var trackSource = ""
    dynamic var genre = "1"
    dynamic var rating = 0
    dynamic var isKnown:Bool = false //未知
    dynamic var playbackTime = 0
    
    func playbackTimeStr() -> String {
        let ms = self.playbackTime
        return "\(ms/1000/60):\(ms/1000%60)"
    }
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Album: Object {
    dynamic var id = ""
    dynamic var artwork:Data?
    dynamic var albumTitle = ""
    dynamic var artistName = ""
    let songs = List<UserSong>()
}

class Artist: Object {
    dynamic var id = ""
    dynamic var artwork:Data?
    dynamic var artistName = ""
    var albums = List<Album>()
}
