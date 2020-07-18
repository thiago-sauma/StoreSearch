//
//  SearchResultCellTableViewCell.swift
//  StoreSearch
//
//  Created by Thiago on 7/18/20.
//  Copyright © 2020 Curso IOS. All rights reserved.
//

import UIKit

class SearchResultCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var artWorkImageView: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        self.changeSelectionCellColor()
    }
    
    func changeSelectionCellColor (){
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 0.5)
        self.selectedBackgroundView = selectedView
    }

    

}
