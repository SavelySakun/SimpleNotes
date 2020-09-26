//
//  Constants.swift
//  Very Simple Notes
//
//  Created by Савелий Сакун on 08.07.2020.
//  Copyright © 2020 Savely Sakun. All rights reserved.
//

struct K {
    static let empty = "empty"
    
    struct segues {
        static let registrationComplete = "registrationComplete"
        static let loginComplete = "loginComplete"
        static let addNewNoteStart = "addNewNoteStart"
        static let openNote = "openNote"
        static let editExistingNote = "editExistingNote"
    }
    
    struct myColors {
        static let lightGrayBackground = "LightGrayBackground"
    }
    
    struct cell {
        static let cellNibName = "NotesListCell"
        static let cellIdentifier = "ReusableCell"
    }

}
