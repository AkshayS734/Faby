import Foundation

extension DateFormatter {
    static let postDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()
    
    static let postTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    static let databaseDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    static func formatPostDate(_ dateString: String?) -> String {
        print("📅 Formatting date string: \(dateString ?? "nil")")
        
        guard let dateString = dateString else {
            print("❌ Date string is nil")
            return "Just now"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // or TimeZone.current
        
        guard let date = formatter.date(from: dateString) else {
            print("❌ Failed to parse date from string: \(dateString)")
            return "Just now"
        }
        
        print("✅ Successfully parsed date: \(date)")
        
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day, .weekOfYear, .month, .year], from: date, to: now)
        
        if let year = components.year, year > 0 {
            return "\(year) year\(year == 1 ? "" : "s") ago"
        } else if let month = components.month, month > 0 {
            return "\(month) month\(month == 1 ? "" : "s") ago"
        } else if let week = components.weekOfYear, week > 0 {
            return "\(week) week\(week == 1 ? "" : "s") ago"
        } else if let day = components.day, day > 0 {
            if day == 1 { return "Yesterday" }
            if day < 7 { return "\(day) days ago" }
            return postDateFormatter.string(from: date)
        } else if let hour = components.hour, hour > 0 {
            return "\(hour) hour\(hour == 1 ? "" : "s") ago"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute) minute\(minute == 1 ? "" : "s") ago"
        } else {
            return "Just now"
        }
    }
}
