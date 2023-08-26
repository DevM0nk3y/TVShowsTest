//
//  TVShowsTableViewCell.swift
//  TestTVShows
//
//  Created by Abel Lazaro on 21/01/21.
//

import UIKit
//import SDWebImage

class TVShowsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tvShowImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
//    public func configure(with model: Datos) {
//
//        self.titleLabel.text = "\((model.show?.name)!)"
//
//        if let imagen = model.show?.image?.medium {
//            self.tvShowImage.sd_setImage(with: URL(string: "\(imagen)"))
//        }
//
//    }

}
