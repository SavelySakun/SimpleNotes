//
//  NotesListVC.swift
//  Very Simple Notes
//
//  Created by Савелий Сакун on 08.07.2020.
//  Copyright © 2020 Savely Sakun. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class NotesListVC: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var notesTableView: UITableView!
    
    let databaseFirestore = Firestore.firestore()
    var selectedIndexPath = 0 // value for 'Prepare for segue' method.
    var notesData: [Note] = []
    
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(true)
        navigationBarSetup()
        setupDataFromFireBaseForTableView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCustomCellAndDataSource()
    }
    
    // MARK: - Helpers
    func registerCustomCellAndDataSource() {
        
        notesTableView.delegate = self
        notesTableView.dataSource = self
        notesTableView.register(UINib(nibName: K.cell.cellNibName, bundle: nil), forCellReuseIdentifier: K.cell.cellIdentifier)
    }
    
    func setupDataFromFireBaseForTableView() {
        
        notesData = []
        
        DispatchQueue.global(qos: .utility).async {
            FirebaseService.shared.retrieveNoteListFromFirebase { result in
                switch result {
                case .success(let notes):
                    
                    self.notesData = notes
                    DispatchQueue.main.async { self.notesTableView.reloadData() }
                    
                case .failure(_):
                    self.showErrorAlert()
                    break
                }
            }
        }
    }
    
    func showErrorAlert() {
        let alert = UIAlertController(title: "Error", message: "Failure with loading notes from Database", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}

// MARK: - 'navigationBarSetup()' (with alerts and sign out method)
extension NotesListVC {
    
    func navigationBarSetup() {
        
        navigationItem.title = "Your notes"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log out", style: .done, target: self, action: #selector(userSignOut))
        navigationItem.leftBarButtonItem?.tintColor = .systemRed
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(sequeToAddNewNote))
    }
    
    // Sign out method for left button of navigation controller.
    @objc func userSignOut() {
        logOutConfirmationAlert()
    }
    
    // Just a simple segue to AddNewNoteVC.
    @objc func sequeToAddNewNote() {
        performSegue(withIdentifier: K.segues.addNewNoteStart, sender: self)
    }
    
    // Shows when user tap on 'Log out' leftBarItem.
    func logOutConfirmationAlert() {
        
        let alert = UIAlertController(title: "Do you really want to log out?", message: "Press 'Log out' to end session.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Log out", style: .default, handler: { action in
            // Action for leftBarItem from alert
            self.signOutFirebase()
        }))
        
        alert.addAction(UIAlertAction(title: "Return", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    // User sign out.
    func signOutFirebase() {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError.localizedDescription)
        }
    }
}

// MARK: - TableView Setup
extension NotesListVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notesData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = notesTableView.dequeueReusableCell(withIdentifier: K.cell.cellIdentifier, for: indexPath) as! NotesListCell
        
        let note = notesData[indexPath.row]
        
        cell.noteName.text = note.noteName
        cell.noteBody.text = note.noteContent
        cell.noteDate.text = note.noteDate
        
        return cell
    }
}

// MARK: - UITableViewDelegate. All methods for segue.
extension NotesListVC: UITableViewDelegate {
    
    // Tap on cell.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath.row
        performSegue(withIdentifier: K.segues.openNote, sender: self)
    }
    
    // This method pass 'noteId' value to ReadNoteVC.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.segues.openNote {
            let destinationVC = segue.destination as! ReadNoteVC
            
            guard let noteId = notesData[selectedIndexPath].noteId else { return }
            destinationVC.noteId = noteId
        }
    }
}
