import Foundation
@objc(ScheduleValueTransformer)

class ScheduleValueTransformer: ValueTransformer {
    override class func allowsReverseTransformation() -> Bool {
        true
    }
    
    override class func transformedValueClass() -> AnyClass {
        NSData.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let customClass = value as? [WeekDay] else { return nil }
        let encoder = JSONEncoder()
        return try? encoder.encode(customClass)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode([WeekDay].self, from: data)
    }
}



