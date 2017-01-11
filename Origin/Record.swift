import RealmSwift
//import SwiftDate

class Record: Object {
    dynamic var comment = ""
    dynamic var date = Date()
    var datestring: String {
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = DateFormatter.Style.short
        dateformatter.timeStyle = DateFormatter.Style.short
        let now = dateformatter.string(from: date)
        return now
    }
}
