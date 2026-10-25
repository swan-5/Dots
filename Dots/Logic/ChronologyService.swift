import Foundation

/// Pure, testable chronology logic. Timeline ground truth lives here, independent of
/// any SwiftUI or persistence concern, so it can be unit tested directly.
enum ChronologySort {

    enum Direction {
        case newestFirst
        case oldestFirst
    }

    /// Total, deterministic order: eventDate (by direction), then createdAt (always ascending
    /// as a stable tie-breaker), then id string (final deterministic fallback).
    static func sorted(_ dots: [Dot], direction: Direction) -> [Dot] {
        dots.sorted { a, b in
            if a.eventDate != b.eventDate {
                switch direction {
                case .newestFirst: return a.eventDate > b.eventDate
                case .oldestFirst: return a.eventDate < b.eventDate
                }
            }
            if a.createdAt != b.createdAt {
                return a.createdAt < b.createdAt
            }
            return a.id.uuidString < b.id.uuidString
        }
    }

    struct MonthGroup: Identifiable {
        let id: String
        let year: Int
        let month: Int
        let dots: [Dot]
    }

    /// Groups an already-sorted list of dots by calendar year/month, preserving the incoming order.
    static func groupedByMonth(_ sortedDots: [Dot], calendar: Calendar = .current) -> [MonthGroup] {
        var order: [String] = []
        var buckets: [String: (year: Int, month: Int, dots: [Dot])] = [:]

        for dot in sortedDots {
            let comps = calendar.dateComponents([.year, .month], from: dot.eventDate)
            let year = comps.year ?? 0
            let month = comps.month ?? 0
            let key = "\(year)-\(month)"
            if buckets[key] == nil {
                buckets[key] = (year, month, [])
                order.append(key)
            }
            buckets[key]?.dots.append(dot)
        }

        return order.compactMap { key in
            guard let bucket = buckets[key] else { return nil }
            return MonthGroup(id: key, year: bucket.year, month: bucket.month, dots: bucket.dots)
        }
    }
}
