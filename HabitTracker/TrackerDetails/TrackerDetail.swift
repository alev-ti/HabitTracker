import UIKit

struct TrackerDetailCell {
    let header: String
    let type: DetailType
}

enum DetailType {
    case emoji([String])
    case color([UIColor])
}


