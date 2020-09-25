//
//  AddNewNoteVC.swift
//  Very Simple Notes
//
//  Created by Савелий Сакун on 09.07.2020.
//  Copyright © 2020 Savely Sakun. All rights reserved.
//

import UIKit
import Firebase
import UITextView_Placeholder

class AddNewNoteVC: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var noteNameTextField: UITextField!
    @IBOutlet weak var noteContentTextView: UITextView!
    
    @IBOutlet weak var noteNameView: UIView!
    @IBOutlet weak var noteContentView: UIView!
    
    
    
    // Firestore database.
    let db = Firestore.firestore()
    var noteId = K.empty
    
    
    // MARK: - LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        designSetup()
        fetchDataFromFirestoreIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBarSetup()
    }
    
    // MARK: - Helpers
    func fetchDataFromFirestoreIfNeeded() {
        if noteId == K.empty {
            return
        } else {
            titleLabel.text = "Editing note"
            
            DispatchQueue.global(qos: .utility).async {
                
                FirebaseService.shared.retrieveNoteFromFirebase(with: self.noteId) { (result) in
                    switch result {
                    case .success(let note):
                        
                        DispatchQueue.main.async {
                            self.noteContentTextView.text = note.noteContent
                            self.noteNameTextField.text = note.noteName
                        }
    
                    case .failure(_):
                        break
                    }
                }
            }
        }
    }
    
    func designSetup() {
        view.backgroundColor = UIColor(named: K.myColors.lightGrayBackground)
        
        noteNameView.layer.cornerRadius = 10
        noteContentView.layer.cornerRadius = 10
        
        noteContentTextView.placeholder = "Add your note here."
    }
    
    func navigationBarSetup() {
        
        // leftBarButtonItem
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Discard", style: .done, target: self, action: #selector(discardEditing))
        navigationItem.leftBarButtonItem?.tintColor = .systemRed
        
        // rightBarButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveNewNote))
    }
    
    
    // Сhecks whether there is content in the fields. If not, it dismiss view. If yes, show alert.
    @objc func discardEditing() {
        if noteNameTextField.text!.isEmpty, noteContentTextView.text!.isEmpty {
            
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
            
        } else {
            discardEditingAlert()
        }
    }
    
    // Alert for discard.
    func discardEditingAlert() {
        
        let alert = UIAlertController(title: "Are you sure?", message: "Do you really want to dismiss any changes?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            
            // Actions for leftBarItem from alert
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Return", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    // Tap on 'Save' button.
    @objc func saveNewNote() {
        
        if noteNameTextField.text!.isEmpty, noteContentTextView.text!.isEmpty {
            showAlertIfNothingToSave()
        } else {
            saveDataToFirestoreUser()
        }
    }
    
    
    func showAlertIfNothingToSave() {
        
        let alert = UIAlertController(title: "Nothing to save", message: "Please add content to your note.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil ))
        self.present(alert, animated: true)
        
    }
    
    func saveDataToFirestoreUser() {
        if noteId == K.empty {
            createNewNoteDocument()
        } else {
            updateExistingNote()
        }
    }
    
    func updateExistingNote() {
        let currentUserEmail = Auth.auth().currentUser?.email
        let dateForSorting = Date().timeIntervalSince1970
        
        if let noteName = noteNameTextField.text, let noteContent = noteContentTextView.text, let userEmail = currentUserEmail {
            
            db.collection(K.FStore.usersCollection).document(userEmail).collection(K.FStore.notesCollection).document(noteId)
                .updateData([
                    
                    K.FStore.noteName : noteName,
                    K.FStore.noteContent : noteContent,
                    K.FStore.dateForSorting : dateForSorting,
                    K.FStore.date : getCurrentDateAndReturnString(),
                    
                ]) { (error) in
                    
                    if let errorText = error {
                        self.showAlertErrorWhileSavingToFirebase(error: errorText)
                    } else {
                        self.navigationController?.popViewController(animated: true)?
                            .dismiss(animated: true, completion: nil)
                    }
            }
        }
        
    }
    
    fileprivate func createNewNoteDocument() {
        
        let dateForSorting = Date().timeIntervalSince1970
        let currentUserEmail = Auth.auth().currentUser?.email
        
        // Getting random number for note id.
        let randomNumberForNoteId = String(Int.random(in: 1...9999) + Int.random(in: 1...9999))
        
        if let noteName = noteNameTextField.text, let noteContent = noteContentTextView.text, let userEmail = currentUserEmail {
            
            db.collection(K.FStore.usersCollection).document(userEmail).collection(K.FStore.notesCollection).document(randomNumberForNoteId)
                .setData([
                    
                    K.FStore.noteName : noteName,
                    K.FStore.noteContent : noteContent,
                    K.FStore.dateForSorting : dateForSorting,
                    K.FStore.date : getCurrentDateAndReturnString(),
                    K.FStore.noteId : randomNumberForNoteId
                    
                ]) { (error) in
                    
                    if let errorText = error {
                        self.showAlertErrorWhileSavingToFirebase(error: errorText)
                    } else {
                        self.navigationController?.popViewController(animated: true)?
                            .dismiss(animated: true, completion: nil)
                    }
            }
        }
    }
    
    func showAlertErrorWhileSavingToFirebase(error: Error) {
        
        let alert = UIAlertController(title: "Here is the Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
        
        // Return to 'NotesListVC'.
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil ))
        self.present(alert, animated: true)
    }
    
    // Recieve current date and convert it into nice String.
    func getCurrentDateAndReturnString() -> String {
        
        let date = Date()
        let calendar = Calendar.current
        
        let currentDay = calendar.component(.day, from: date)
        let currentMonth = calendar.component(.month, from: date)
        let currentYear = calendar.component(.year, from: date)
        
        let formattedCurrentDate = "\(currentDay).\(currentMonth).\(currentYear)"
        return formattedCurrentDate
    }
}
