//
//  ReadNote.swift
//  Very Simple Notes
//
//  Created by Савелий Сакун on 09.07.2020.
//  Copyright © 2020 Savely Sakun. All rights reserved.
//

import UIKit
import Firebase

class ReadNoteVC: UIViewController {
    
    // MARK: - Properties.
    var noteId = K.empty // Note id for Firestore.
    let db = Firestore.firestore()
    
    @IBOutlet weak var noteNameLabel: UILabel!
    @IBOutlet weak var noteDateLabel: UILabel!
    @IBOutlet weak var noteContentTextView: UITextView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        navigationBarSetup()
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDataFromFirestore()
    }
    
}

// MARK: - Navigation bar setup.
extension ReadNoteVC {
    
    func navigationBarSetup() {
        
        let delete = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteCurrentNote))
        let edit = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editCurrentNote))
        
        delete.tintColor = .red
        
        navigationItem.rightBarButtonItems = [edit, delete]
    }
    
    @objc func deleteCurrentNote() {
        
        let alert = UIAlertController(title: "Are you sure?", message: "Press 'Delete' to proceed.", preferredStyle: .alert)
        
        // Return to 'NotesListVC'.
        alert.addAction(UIAlertAction(title: "Return", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { action in
            
            if let currentUserEmail = Auth.auth().currentUser?.email {
                self.db.collection(K.FStore.usersCollection).document(currentUserEmail).collection(K.FStore.notesCollection).document(self.noteId)
                    .delete()
            }
            self.navigationController?.popViewController(animated: true)?
            .dismiss(animated: true, completion: nil)
            
        } ))
        self.present(alert, animated: true)
        
    }
    
    @objc func editCurrentNote() {
        performSegue(withIdentifier: K.segues.editExistingNote, sender: self)
    }
    // This method pass 'noteId' value to 'AddNewNoteVC'.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.segues.editExistingNote {
            let destinationVC = segue.destination as! AddNewNoteVC
            destinationVC.noteId = noteId
        }
    }
}

// MARK: - Load data of note from Firestore.
extension ReadNoteVC {
    
    func getDataFromFirestore() {
        
        if let currentUserEmail = Auth.auth().currentUser?.email {
            
            db.collection(K.FStore.usersCollection).document(currentUserEmail).collection(K.FStore.notesCollection).document(noteId)
                .addSnapshotListener { (documentSnapshot, error) in
                    
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        
                        if let noteData = documentSnapshot?.data() {
                            
                            if let noteNameData = noteData[K.FStore.noteName] as? String,
                                let noteContentData = noteData[K.FStore.noteContent] as? String,
                                let noteDateData = noteData[K.FStore.date] as? String {
                                
                                // Set data from firestore to labels and textView.
                                self.noteDateLabel.text = noteDateData
                                self.noteNameLabel.text = noteNameData
                                self.noteContentTextView.text = noteContentData
                                
                            }
                            
                        }
                    }
            }
        }
    }
    
    
}
