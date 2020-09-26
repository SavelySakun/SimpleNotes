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
        
        alert.addAction(UIAlertAction(title: "Return", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { action in
            
            DispatchQueue.global(qos: .utility).async {
                FirebaseService.shared.deleteNote(with: self.noteId)
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
        
        DispatchQueue.global(qos: .utility).async {
            
            FirebaseService.shared.retrieveNoteFromFirebase(with: self.noteId) { result in
                switch result {
                case .success(let note):
                    
                    DispatchQueue.main.async {
                        self.noteDateLabel.text = note.noteDate
                        self.noteNameLabel.text = note.noteName
                        self.noteContentTextView.text = note.noteContent
                    }
                    
                case .failure(_):
                    break
                }
            }
        }
    }
}
