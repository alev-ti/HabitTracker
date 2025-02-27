import Foundation
@objc(ScheduleValueTransformer)

class ScheduleValueTransformer: ValueTransformer {
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let customClass = value as? [WeekDays] else { return nil }
        let encoder = JSONEncoder()
        return try? encoder.encode(customClass)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode([WeekDays].self, from: data)
    }
}



