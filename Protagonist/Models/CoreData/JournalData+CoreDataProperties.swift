//
//  JournalData+CoreDataProperties.swift
//  Protagonist
//
//  Created by Yahya Ayyash on 04/05/21.
//
//

import Foundation
import CoreData


extension JournalData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<JournalData> {
        return NSFetchRequest<JournalData>(entityName: "JournalData")
    }

    @NSManaged public var subtitle: String?
    @NSManaged public var title: String?
    @NSManaged public var isBookmarked: Bool
    @NSManaged public var entries: NSOrderedSet?

}

// MARK: Generated accessors for entries
extension JournalData {

    @objc(insertObject:inEntriesAtIndex:)
    @NSManaged public func insertIntoEntries(_ value: JournalEntry, at idx: Int)

    @objc(removeObjectFromEntriesAtIndex:)
    @NSManaged public func removeFromEntries(at idx: Int)

    @objc(insertEntries:atIndexes:)
    @NSManaged public func insertIntoEntries(_ values: [JournalEntry], at indexes: NSIndexSet)

    @objc(removeEntriesAtIndexes:)
    @NSManaged public func removeFromEntries(at indexes: NSIndexSet)

    @objc(replaceObjectInEntriesAtIndex:withObject:)
    @NSManaged public func replaceEntries(at idx: Int, with value: JournalEntry)

    @objc(replaceEntriesAtIndexes:withEntries:)
    @NSManaged public func replaceEntries(at indexes: NSIndexSet, with values: [JournalEntry])

    @objc(addEntriesObject:)
    @NSManaged public func addToEntries(_ value: JournalEntry)

    @objc(removeEntriesObject:)
    @NSManaged public func removeFromEntries(_ value: JournalEntry)

    @objc(addEntries:)
    @NSManaged public func addToEntries(_ values: NSOrderedSet)

    @objc(removeEntries:)
    @NSManaged public func removeFromEntries(_ values: NSOrderedSet)

}

extension JournalData : Identifiable {

}
