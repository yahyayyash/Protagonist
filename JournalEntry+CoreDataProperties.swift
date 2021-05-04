//
//  JournalEntry+CoreDataProperties.swift
//  Protagonist
//
//  Created by Yahya Ayyash on 04/05/21.
//
//

import Foundation
import CoreData


extension JournalEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<JournalEntry> {
        return NSFetchRequest<JournalEntry>(entityName: "JournalEntry")
    }

    @NSManaged public var date: Date?
    @NSManaged public var textDescription: String?
    @NSManaged public var thumbnail: Data?
    @NSManaged public var video: URL?
    @NSManaged public var journals: JournalData?

}

extension JournalEntry : Identifiable {

}
