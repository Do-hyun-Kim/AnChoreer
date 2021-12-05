//
//  AnchoreerEmptyTableViewCell.swift
//  AnChoreer
//
//  Created by Kim dohyun on 2021/12/02.
//

import UIKit

class AnchoreerEmptyTableViewCell: UITableViewCell {
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var emptyImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        emptyConfigureCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func emptyConfigureCell() {
        emptyLabel.text = "데이터가 없습니다"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .black
        emptyImageView.contentMode = .scaleToFill
        
    }
    
}
