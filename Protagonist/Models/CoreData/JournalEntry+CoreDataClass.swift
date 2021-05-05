//
//  JournalEntry+CoreDataClass.swift
//  Protagonist
//
//  Created by Yahya Ayyash on 01/05/21.
//
//

import Foundation
import CoreData

@objc(JournalEntry)
public class JournalEntry: NSManagedObject {
    @objc var isoDate: String { get {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        
        return formatter.string(from: date! as Date)
    }}
}
