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
    var selectedIndexPath = 0
    var notesData: [Note] = []
    
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(true)
        navigationBarSetup()
        loadNotesFromFirebaseToTableView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCustomCellAndDataSource()
    }
    
    
    // MARK: - Helpers
    
    // Design.
    func navigationBarSetup() {
        
        navigationItem.title = "Notes"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log out", style: .done, target: self, action: #selector(userSignOut))
        navigationItem.leftBarButtonItem?.tintColor = .systemRed
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(sequeToAddNewNote))
    }
    
    func registerCustomCellAndDataSource() {
        notesTableView.delegate = self
        notesTableView.dataSource = self
        notesTableView.register(UINib(nibName: K.cell.cellNibName, bundle: nil), forCellReuseIdentifier: K.cell.cellIdentifier)
    }
    
    
    // Selectors
    @objc func userSignOut() {
        showLogoutConfirmationAlert()
    }
    
    @objc func sequeToAddNewNote() {
        performSegue(withIdentifier: K.segues.addNewNoteStart, sender: self)
    }
    
    
    // All work with Firestore methods.
    func loadNotesFromFirebaseToTableView() {
        
        DispatchQueue.main.async { self.notesTableView.reloadData() }
        
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
    
    func handleSignOutFirebase() {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError.localizedDescription)
        }
    }
    
    
    // Alerts.
    func showErrorAlert() {
        let alert = UIAlertController(title: "Error", message: "Failure with loading notes from Database", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func showLogoutConfirmationAlert() {
        
        let alert = UIAlertController(title: "Do you really want to log out?", message: "Press 'Log out' to end session.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Log out", style: .default, handler: { action in
            self.handleSignOutFirebase()
        }))
        
        alert.addAction(UIAlertAction(title: "Return", style: .default, handler: nil))
        self.present(alert, animated: true)
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

// MARK: - UITableViewDelegate.
extension NotesListVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath.row
        performSegue(withIdentifier: K.segues.openNote, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.segues.openNote {
            let destinationVC = segue.destination as! ReadNoteVC
            
            guard let noteId = notesData[selectedIndexPath].noteId else { return }
            destinationVC.noteId = noteId
        }
    }
}
