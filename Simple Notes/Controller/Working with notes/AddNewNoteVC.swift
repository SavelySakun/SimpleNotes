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
    
    var noteId = K.empty
    
    
    // MARK: - LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        fetchDataFromFirestoreIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        designSetup()
        navigationBarSetup()
    }
    
    
    // MARK: - Helpers
    
    // Design
    func designSetup() {
        view.backgroundColor = UIColor(named: K.myColors.lightGrayBackground)
        noteNameView.layer.cornerRadius = 10
        noteContentView.layer.cornerRadius = 10
        noteContentTextView.placeholder = "Add your note here."
    }
    
    func navigationBarSetup() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Discard", style: .done, target: self, action: #selector(handleTapInDiscardEditingButton))
        navigationItem.leftBarButtonItem?.tintColor = .systemRed
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(handleTapOnSaveNoteButton))
    }
    
    
    // All work with Firestore methods.
    func fetchDataFromFirestoreIfNeeded() {
        if noteId == K.empty {
            return
        } else {
            titleLabel.text = "Editing note"
            
            DispatchQueue.global(qos: .utility).async {
                
                FirebaseService.shared.retrieveNoteFromFirebase(with: self.noteId) { result in
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
    
    func saveDataToFirestoreUser() {
        if noteId == K.empty {
            createNewNoteDocument()
        } else {
            updateExistingNote()
        }
    }
    
    fileprivate func createNewNoteDocument() {
        
        guard let noteName = noteNameTextField.text else { return }
        guard let noteContent = noteContentTextView.text else { return }
        
        DispatchQueue.global(qos: .utility).async {
            
            FirebaseService.shared.loadNewNoteToFirebase(noteName: noteName, noteContent: noteContent) { error in
                if let error = error {
                    self.showHandleErrorSavingToFirestoreAlert(error: error)
                } else {
                    self.navigationController?.popViewController(animated: true)?
                        .dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func updateExistingNote() {
        
        guard let noteName = noteNameTextField.text,
            let noteContent = noteContentTextView.text else { return }
        
        DispatchQueue.global(qos: .utility).async {
            
            FirebaseService.shared.updateExistingNoteOnFirebase(noteId: self.noteId, noteName: noteName, noteContent: noteContent) { error in
                
                if let error = error {
                    self.showHandleErrorSavingToFirestoreAlert(error: error)
                } else {
                    self.navigationController?.popViewController(animated: true)?
                        .dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    
    // Selectors
    @objc func handleTapInDiscardEditingButton() {
        if noteNameTextField.text!.isEmpty, noteContentTextView.text!.isEmpty {
            
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
            
        } else {
            showFindContentSureToDiscardAlert()
        }
    }
    
    
    @objc func handleTapOnSaveNoteButton() {
        
        if noteNameTextField.text!.isEmpty, noteContentTextView.text!.isEmpty {
            showAlertIfNothingToSave()
        } else {
            saveDataToFirestoreUser()
        }
    }
    
    
    // Alerts & Error handling.
    func showFindContentSureToDiscardAlert() {
        
        let alert = UIAlertController(title: "Are you sure?", message: "Do you really want to dismiss any changes?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Return", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func showAlertIfNothingToSave() {
        let alert = UIAlertController(title: "Nothing to save", message: "Please add content to your note.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil ))
        self.present(alert, animated: true)
    }
    
    func showHandleErrorSavingToFirestoreAlert(error: Error) {
        let alert = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
        
        // Return to 'NotesListVC'.
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil ))
        self.present(alert, animated: true)
    }
}
