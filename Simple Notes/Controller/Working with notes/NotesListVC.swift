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
    
    let db = Firestore.firestore()
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
    
    // MARK: - Setup data for tableView.
    func setupDataFromFireBaseForTableView() {
        
        // Reloading data for tableView before loading data from Firestore.
        DispatchQueue.main.async {
            self.notesTableView.reloadData()
        }
        
        notesData = []
        
        let currentUserEmail = Auth.auth().currentUser?.email
        
        db.collection(K.FStore.usersCollection).document(currentUserEmail!).collection(K.FStore.notesCollection)
            .order(by: K.FStore.dateForSorting, descending: true) // Order data by 'dateForSorting'
            .getDocuments { (querySnapshot, error) in
                
                if let error = error {
                    print(error)
                } else {
                    if let notesDataFromFirestore = querySnapshot?.documents {
                        
                        for note in notesDataFromFirestore {
                            let dataFromNote = note.data()
                            
                            // Setting data to note from every piece from database.
                            if let noteName = dataFromNote[K.FStore.noteName] as? String,
                                let noteContent = dataFromNote[K.FStore.noteContent] as? String,
                                let date = dataFromNote[K.FStore.date] as? String,
                                let noteId = dataFromNote[K.FStore.noteId] as? String {
                                
                                // Adding data to array.
                                let newNote = Note(noteName: noteName, noteBody: noteContent, noteDate: date, noteId: noteId)
                                self.notesData.append(newNote)
                                
                                // Reloading data for tableView after load data from FIrestore to array 'notesData'.
                                DispatchQueue.main.async {
                                    self.notesTableView.reloadData()
                                }
                                
                            }
                            
                        }
                        
                    }
                }
        }
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
        cell.noteBody.text = note.noteBody
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
            destinationVC.noteId = notesData[selectedIndexPath].noteId
        }
    }
}
