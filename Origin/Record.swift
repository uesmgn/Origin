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
    /*{
        let calendar = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let year = format(calendar.year!)
        let month = format(calendar.month!)
        let day = format(calendar.day!)
        let hour = format(calendar.hour!)
        let minute = format(calendar.minute!)
        
        return year+"/"+month+"/"+day+" "+hour+":"+minute
    }
    
    func format(_ num: Int) -> String {
        if num < 10 {
            return "0\(num)"
        } else {
            return "\(num)"
        }
    }*/
}
