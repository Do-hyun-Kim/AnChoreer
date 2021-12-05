//
//  AnChoreerTableViewCell.swift
//  AnChoreer
//
//  Created by Kim dohyun on 2021/12/02.
//

import UIKit

class AnChoreerTableViewCell: UITableViewCell {

    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieDirectorLabel: UILabel!
    @IBOutlet weak var movieActorLabel: UILabel!
    @IBOutlet weak var movieUserRatingLabel: UILabel!
    @IBOutlet weak var movieUserSuggestButton: UIButton!
    var suggestButtonClosure: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configureCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func configureCell() {
        movieTitleLabel.textColor = .black
        movieTitleLabel.textAlignment = .left
        movieDirectorLabel.textColor = .black
        movieDirectorLabel.textAlignment = .left
        movieImageView.contentMode = .scaleToFill
        movieUserSuggestButton.addTarget(self, action: #selector(suggestCellButtonDidTap(_:)), for: .touchUpInside)
    }
    
    @objc
    public func suggestCellButtonDidTap(_ sender: UIButton) {
        suggestButtonClosure!()
    }
    
}
