//
//  HelperMethod.swift
//  Simple Notes
//
//  Created by Савелий Сакун on 25.09.2020.
//  Copyright © 2020 Savely Sakun. All rights reserved.
//

import UIKit

class HelperMethod {
    
    static let shared = HelperMethod()
    
    // Recieve current date and convert it into nice String.
    func getCurrentDateAndReturnString() -> String {
        
        let date = Date()
        let calendar = Calendar.current
        
        let currentDay = calendar.component(.day, from: date)
        let currentMonth = calendar.component(.month, from: date)
        let currentYear = calendar.component(.year, from: date)
        
        let formattedCurrentDate = "\(currentDay).\(currentMonth).\(currentYear)"
        return formattedCurrentDate
    }
    
    // Using nanoseconds from users current time as new note id.
    func generateUniqueId() -> String {
        
        let date = Date()
        let calendar = Calendar.current
        let uniqueId = String(calendar.component(.nanosecond, from: date))
        
        return uniqueId
    }
    
}
