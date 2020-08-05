//
//  NotesListCell.swift
//  Very Simple Notes
//
//  Created by Савелий Сакун on 08.07.2020.
//  Copyright © 2020 Savely Sakun. All rights reserved.
//

import UIKit

class NotesListCell: UITableViewCell {
    
    // MARK: - Properties
    @IBOutlet weak var noteDate: UILabel!
    @IBOutlet weak var noteName: UILabel!
    @IBOutlet weak var noteBody: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
