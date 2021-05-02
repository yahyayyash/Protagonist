//
//  DatabaseHelper.swift
//  Protagonist
//
//  Created by Yahya Ayyash on 02/05/21.
//

import Foundation
import CoreData
import UIKit

public class DatabaseHelper {
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    private func seedJournal() {
        let journals = [
            (title: "First Journal", subtitle: "It's my first after all."),
            (title: "Apple Academy", subtitle: "My developer journey.")
        ]
        
        for journal in journals {
            let newJournal = NSEntityDescription.insertNewObject(forEntityName: "JournalData", into: context) as! JournalData
            newJournal.title = journal.title
            newJournal.subtitle = journal.subtitle
        }
        
        do {
            try context.save()
        }
        catch {
            
        }
    }
    
    private func seedEntry(){
        

        
        let journalList = try! context.fetch(JournalData.fetchRequest()) as [JournalData]
        
        let entries = [
            (date: Date(timeInterval: -(60*60*24)*5, since: Date()), textDescription: "First entry", thumbnail: UIImage(named: "entry-1"), video: "#", journals: journalList.first),
            (date: Date(timeInterval: -(59*60*24)*5, since: Date()), textDescription: "Second entry", thumbnail: UIImage(named: "entry-2"), video: "#", journals: journalList.first),
            (date: Date(timeInterval: -(60*60*24)*4, since: Date()), textDescription: "Third entry", thumbnail: UIImage(named: "entry-3"), video: "#", journals: journalList.first),
            (date: Date(timeInterval: -(60*60*24)*3, since: Date()), textDescription: "Fourth entry", thumbnail: UIImage(named: "entry-4"), video: "#", journals: journalList.first),
            (date: Date(timeInterval: -(58*60*24)*3, since: Date()), textDescription: "Fifth entry", thumbnail: UIImage(named: "entry-5"), video: "#", journals: journalList.first),
            (date: Date(timeInterval: -(57*60*24)*3, since: Date()), textDescription: "Sixth entry", thumbnail: UIImage(named: "entry-6"), video: "#", journals: journalList.first),
            (date: Date(timeInterval: -(60*60*24), since: Date()), textDescription: "Seventh entry", thumbnail: UIImage(named: "entry-7"), video: "#", journals: journalList.first)
        ]
        
        for entry in entries {
            let newEntry = NSEntityDescription.insertNewObject(forEntityName: "JournalEntry", into: context) as! JournalEntry
            newEntry.date = entry.date
            newEntry.textDescription = entry.textDescription
            newEntry.thumbnail = entry.thumbnail?.pngData()
            newEntry.video = URL(string: entry.video)
            newEntry.journals = entry.journals
        }
        
        do {
            try context.save()
        }
        catch {
            
        }
    }
    
    func seedDataStore(){
        seedJournal()
        seedEntry()
    }
    
    func printJournals() {
        
        let allJournals = try! context.fetch(JournalData.fetchRequest())
        
        for journal in allJournals {
            print(journal)
        }
    }
}
