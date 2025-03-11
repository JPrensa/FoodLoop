struct AvailableTimeSlot: Codable {
    let day: Int // 0-6 für Wochentage
    let startTime: Date
    let endTime: Date
}