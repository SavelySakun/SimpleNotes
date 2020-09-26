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
    
    static let shared = FirebaseService()
    let firestoreModel = FirestoreModel()
    let databaseFirestore = Firestore.firestore()
    let currentDate = HelperMethod.shared.getCurrentDateAndReturnString()
    
    func registerNewUser(email: String, password: String, completion: @escaping (Error?, AuthDataResult?) -> Void) {
        
        DispatchQueue.global(qos: .utility).async {
            Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
            completion(error, authDataResult)}
        }
    }
    
    func loginExistingUser(email: String, password: String, completion: @escaping (Error?, AuthDataResult?) -> Void) {
        
        DispatchQueue.global(qos: .utility).async {
            Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
                completion(error, authDataResult)
            }
        }
    }
    
    
    func retrieveNoteListFromFirebase(completion: @escaping (Result<[Note], Error>) -> Void) {
        
        let userEmail = Auth.auth().currentUser?.email
        var notesData: [Note] = []
        
        guard let currentUserEmail = userEmail else { return }
        
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
    
    func retrieveNoteFromFirebase(with noteId: String, completion: @escaping (Result<Note, Error>) -> Void) {
        
        let userEmail = Auth.auth().currentUser?.email
        guard let currentUserEmail = userEmail else { return }
        
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
    
    func loadNewNoteToFirebase(noteName: String, noteContent: String, completion: @escaping (Error?) -> Void) {
        
        let userEmail = Auth.auth().currentUser?.email
        let dateForSorting = Date().timeIntervalSince1970
        let uniqueNumberForNoteId = HelperMethod.shared.generateUniqueId()
        guard let currentUserEmail = userEmail else { return }
        
        databaseFirestore
            .collection(firestoreModel.usersCollection)
            .document(currentUserEmail)
            .collection(firestoreModel.notesCollection)
            .document(uniqueNumberForNoteId)
            .setData([
                
                firestoreModel.noteName: noteName,
                firestoreModel.noteContent: noteContent,
                firestoreModel.dateForSorting: dateForSorting,
                firestoreModel.date: currentDate,
                firestoreModel.noteId: uniqueNumberForNoteId
                
            ]) { error in
                completion(error)
        }
    }
    
    func updateExistingNoteOnFirebase(noteId: String, noteName: String, noteContent: String, completion: @escaping (Error?) -> Void) {
        
        let userEmail = Auth.auth().currentUser?.email
        let dateForSorting = Date().timeIntervalSince1970
        guard let currentUserEmail = userEmail else { return }
        
        databaseFirestore
            .collection(firestoreModel.usersCollection)
            .document(currentUserEmail)
            .collection(firestoreModel.notesCollection)
            .document(noteId)
            .updateData([
                
                firestoreModel.noteName: noteName,
                firestoreModel.noteContent: noteContent,
                firestoreModel.dateForSorting: dateForSorting,
                firestoreModel.date: currentDate,
                
            ]) { error in
                completion(error)
        }
    }
    
    func deleteNote(with noteId: String) {
        
        let userEmail = Auth.auth().currentUser?.email
        guard let currentUserEmail = userEmail else { return }
        
        databaseFirestore
            .collection(firestoreModel.usersCollection)
            .document(currentUserEmail)
            .collection(firestoreModel.notesCollection)
            .document(noteId)
            .delete()
    }
    
}


