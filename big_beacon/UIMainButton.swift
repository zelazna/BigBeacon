//
//  UIMainButton.swift
//  big_beacon
//
//  Created by Sara on 27/04/2018.
//  Copyright © 2018 constantin guidon. All rights reserved.
//

import UIKit

class UIMainButton: UIButton {
    override func awakeFromNib() {
        super .awakeFromNib()
        self.setTitleColor(UIColor(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        self.layer.backgroundColor = UIColor(red: 1, green: 0.92941, blue: 0, alpha: 1).cgColor
        self.layer.cornerRadius = 23
        self.layer.shadowColor = UIColor(red: 1, green: 0.92941, blue: 0, alpha: 1).cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 10
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
