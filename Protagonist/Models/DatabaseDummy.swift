//
//  DatabaseDummy.swift
//  Protagonist
//
//  Created by Yahya Ayyash on 30/04/21.
//

import Foundation
import UIKit

class DatabaseDummy{
    
    static let shared = DatabaseDummy()
    
    private var journals = [JournalData]()
    private var entries = [JournalEntry]()
    
    init() {
    }
    
    func seedJournal() {
        journals.append(JournalData(title: "Daily Journal", description: "Yahya's everyday lifes."))
        journals.append(JournalData(title: "Guitar Exercise", description: "My guitar learning progress."))
    }
    
    func seedEntry() {
        entries.append(JournalEntry(journalGroup: journals[0], date: Date(timeInterval: -(60*60*24)*7, since: Date()), textDescription: "However, the Treasury also issued larger denominations. They featured William McKinley ($500), Grover Cleveland ($1,000), James Madison ($5,000), and Salmon P. Chase ($10,000).", thumbnail: UIImage(named: "entry-1"), video: nil))
        entries.append(JournalEntry(journalGroup: journals[0], date: Date(timeInterval: -(60*60*24)*6, since: Date()), textDescription: "In captivity, both crows and ravens have been known to live for about thirty years - tops. In the wild, the average life span of a crow is 7-8 years.", thumbnail: UIImage(named: "entry-2"), video: nil))
        entries.append(JournalEntry(journalGroup: journals[0], date: Date(timeInterval: -(60*60*24)*5, since: Date()), textDescription: "A phenomenon called the Wind Chill factor makes us feel colder in winter than the air temperature really is. This is due to the interaction of air temperature and wind on the human body that is already giving off heat. Both temperature and wind cause heat loss from body surfaces.", thumbnail: UIImage(named: "entry-3"), video: nil))
        entries.append(JournalEntry(journalGroup: journals[0], date: Date(timeInterval: -(60*60*24)*4, since: Date()), textDescription: "Russia and Alaska are divided by the Bering Strait, which is about 55 miles at its narrowest point. In the middle of the Bering Strait are two small, sparsely populated islands: Big Diomede, which sits in Russian territory, and Little Diomede, which is part of the United States.", thumbnail: UIImage(named: "entry-4"), video: nil))
        entries.append(JournalEntry(journalGroup: journals[1], date: Date(timeInterval: -(60*60*24)*4, since: Date()), textDescription: "Apollo 11 was the spaceflight that landed the first humans on the Moon, Americans Neil Armstrong and Buzz Aldrin, on July 20, 1969, at 20:18 UTC. Armstrong became the first to step onto the lunar surface six hours later on July 21 at 02:56 UTC.", thumbnail: UIImage(named: "entry-5"), video: nil))
        entries.append(JournalEntry(journalGroup: journals[1], date: Date(timeInterval: -(60*60*24)*2, since: Date()), textDescription: "Eating ice cream, in a sense, makes your body think it is dehydrated, and in a sense, I suppose it is. This is one of the reasons that diabetics are thirsty all the time. Diabetes causes high blood glucose, and that increased concentration of blood solutes  makes the diabetic feel thirsty. In short: It's the salt.", thumbnail: UIImage(named: "entry-6"), video: nil))
        entries.append(JournalEntry(journalGroup: journals[1], date: Date(timeInterval: -(60*60*24)*1, since: Date()), textDescription: "Madagascar's giant, flightless elephant birds were once a common sight on the island, certainly up until the 17th century. It is generally believed that the elephant bird's extinction resulted from human activity, perhaps not surprising when one of their giant eggs would have fed an entire family.", thumbnail: UIImage(named: "entry-7"), video: nil))
    }
    
    func seedDatabase(){
        seedJournal()
        seedEntry()
    }
    
    func getJournals() -> [JournalData]{
        return journals
    }
    
    func getEntries() -> [JournalEntry]{
        return entries
    }
    
    func addJournal(title: String, description: String) {
        journals.append(JournalData(title: title, description: description))
        return
    }
    
    func getEntriesByJournal(journal: JournalData) -> [JournalEntry] {
        var entryByJournal = [JournalEntry]()
        
        for i in 0...(entries.count - 1) {
            if entries[i].journalGroup?.title == journal.title {
                entryByJournal.append(entries[i])
            }
        }
        return entryByJournal
    }
    
    func addEntry(group: JournalData, date: Date, description: String, thumbnail: UIImage, video: URL) {
        entries.append(JournalEntry(journalGroup: group, date: date, textDescription: description, thumbnail: thumbnail, video: video))
        return
    }
    
    func editDescription(entry: JournalEntry, text: String) {
        for i in 0...(entries.count - 1) {
            if entries[i].thumbnail == entry.thumbnail {
                entries[i].textDescription = text
                print("Save successful")
            }
        }
    }
    
}
