//
//  BookController.swift
//  Reading List
//
//  Created by Michael Redig on 4/30/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit


class BookController {
	private(set) var books = MyOrderedSet<Book>()
	
	var readBooks: [Book] {
		return books.filter{ $0.hasBeenRead }.sorted(by: { (a, b) -> Bool in
			a.title < b.title
		})
	}
	
	var unreadBooks: [Book] {
		return books.filter{ !$0.hasBeenRead }.sorted(by: { (a, b) -> Bool in
			a.title < b.title
		})
	}
	
	private var readingListURL: URL? {
		let fm = FileManager.default
		guard let documents = fm.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
		return documents.appendingPathComponent("ReadingList.plist")
	}
	
	init() {
		loadFromPersistentStore()
	}
	
	func createBook(titled title: String, because reasonToRead: String, image: UIImage? = nil) {
		var newBook = Book(title: title, reasonToRead: reasonToRead)
		newBook.image = image
		books.append(newBook)
		saveToPersistentStore()
	}
	
	func delete(book: Book) {
		books.remove(book)
		saveToPersistentStore()
	}
	
	@discardableResult func updateHasBeenRead(for book: Book) -> Book? {
		guard let index = books.index(of: book) else { return nil }
		books[index].hasBeenRead.toggle()
		saveToPersistentStore()
		return books[index]
	}
	
	func update(title: String? = nil, reasonToRead reason: String? = nil, image: UIImage? = nil, forBook book: Book) {
		guard let index = books.index(of: book) else { return }
		if let title = title {
			books[index].title = title
		}
		if let reason = reason {
			books[index].reasonToRead = reason
		}
		if let image = image {
			books[index].image = image
		}
		saveToPersistentStore()
	}

	func saveToPersistentStore() {
		guard let filePath = readingListURL else {
			print("couldn't get reading list url")
			return
		}
		let encoder = PropertyListEncoder()
		do {
			let booksData = try encoder.encode(books)
			try booksData.write(to: filePath)
		} catch {
			print("caught error saving data: \(error)")
		}
	}
	
	func loadFromPersistentStore() {
		guard let readingListURL = readingListURL else { return }
		do {
			let data = try Data(contentsOf: readingListURL)
			let decoder = PropertyListDecoder()
			let decodedBooks = try decoder.decode(MyOrderedSet<Book>.self, from: data)
			books = decodedBooks
		} catch {
			print("Caught error loading data: \(error)")
		}
	}
}


protocol BookControllerProtocol {
	var bookController: BookController? {get set}
}
