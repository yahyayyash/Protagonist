//
//  Entry+CoreDataProperties.swift
//  Protagonist
//
//  Created by Yahya Ayyash on 28/04/21.
//
//

import Foundation
import CoreData


extension Entry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entry> {
        return NSFetchRequest<Entry>(entityName: "Entry")
    }

    @NSManaged public var media: Data?
    @NSManaged public var date: Date?
    @NSManaged public var snippet: String?
    @NSManaged public var journal: Journal?

}

extension Entry : Identifiable {

}
