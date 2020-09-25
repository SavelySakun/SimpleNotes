//
//  FirebaseService.swift
//  Simple Notes
//
//  Created by Савелий Сакун on 25.09.2020.
//  Copyright © 2020 Savely Sakun. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class FirebaseService {
    
    init() {}
    
    static let shared = FirebaseService()
    let firestoreModel = FirestoreModel()
    let databaseFirestore = Firestore.firestore()
    let currentUserEmail = Auth.auth().currentUser?.email
    
    func retrieveNoteListFromFirebase(completion: @escaping (Result<[Note], Error>) -> ()) {
        
        var notesData: [Note] = []
        
        guard let currentUserEmail = currentUserEmail else { return }
        
        databaseFirestore
            .collection(firestoreModel.usersCollection)
            .document(currentUserEmail)
            .collection(firestoreModel.notesCollection)
            .order(by: firestoreModel.dateForSorting, descending: true) // Order data by 'dateForSorting'
            .getDocuments { (querySnapshot, error) in
                
                guard error == nil else { return }
                guard let querySnapshot = querySnapshot else { return }
                
                let notesDataFromFirestore = querySnapshot.documents
                
                notesDataFromFirestore.forEach { note in
                    let dataFromNote = note.data()
                    
                    // Setting data to note from every piece from database.
                    guard let noteName = dataFromNote[self.firestoreModel.noteName] as? String,
                        let noteContent = dataFromNote[self.firestoreModel.noteContent] as? String,
                        let date = dataFromNote[self.firestoreModel.date] as? String,
                        let noteId = dataFromNote[self.firestoreModel.noteId] as? String
                        else { return }
                    
                    // Adding data to array.
                    let newNote = Note(noteName: noteName,
                                       noteContent: noteContent,
                                       noteDate: date,
                                       noteId: noteId)
                    
                    notesData.append(newNote)
                    completion(.success(notesData))
                }
        }
    }
    
    func retrieveNoteFromFirebase(with noteId: String, completion: @escaping (Result<Note, Error>) -> ()) {
        
        guard let currentUserEmail = currentUserEmail else { return }
        
        databaseFirestore
            .collection(firestoreModel.usersCollection)
            .document(currentUserEmail)
            .collection(firestoreModel.notesCollection)
            .document(noteId)
            .getDocument { (documentSnapshot, error) in
                
                guard error == nil else { return }
                guard let noteData = documentSnapshot?.data() else { return }
                
                guard let noteNameString = noteData[self.firestoreModel.noteName] as? String,
                    let noteContentString = noteData[self.firestoreModel.noteContent] as? String,
                    let noteDateString = noteData[self.firestoreModel.date] as? String
                    else { return }
                
                let completeNoteData = Note(noteName: noteNameString, noteContent: noteContentString, noteDate: noteDateString, noteId: nil)
                
                completion(.success(completeNoteData))
        }
    }
}

