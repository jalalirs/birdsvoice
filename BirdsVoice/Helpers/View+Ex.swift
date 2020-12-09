//
//  View+Ex.swift
//  Fabragi
//
//  Created by Usman on 27/07/2020.
//  Copyright © 2020 Believerz. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func setViewCard(_ cornerRadius: CGFloat = 16, _ shadowColor: CGColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1) , shadowWidth:CGFloat=0.0 , shadowHeight:CGFloat=0.0, borderColor: UIColor = .clear, borderSize: CGFloat = 0) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = shadowColor
        self.layer.shadowOffset = CGSize(width: shadowWidth, height: shadowHeight)
        self.layer.shadowOpacity = 1
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderSize
        self.layer.cornerRadius = cornerRadius
    }
    func setViewCardWidthSpecificRoundCorner(_ cornerRadius: CGFloat = 10, _ shadowColor: CGColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1), corners: CACornerMask) {
//        self.layer.masksToBounds = false
        self.layer.maskedCorners = corners
        self.layer.shadowColor = shadowColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowOpacity = 0.8
        self.layer.cornerRadius = cornerRadius
        
    }
    func removeCardView() {
        self.layer.masksToBounds = false
        self.layer.shadowOpacity = 0.0
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowColor = UIColor.clear.cgColor
    }
    
    func roundView(with radius:CGFloat,_ borderColor: UIColor = .clear, _ borderSize: CGFloat = 0, _ cardView: Bool = false){
        if cardView{
            setViewCard(radius)
        }else{
            
            self.layer.cornerRadius = radius
        }
        
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderSize
        self.clipsToBounds = true
        
    }
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func roundCornerByCorner( _ corners: CACornerMask, radius: CGFloat,_ borderColor: UIColor = UIColor.clear , _ borderWidth: CGFloat = 0 ) {
        self.layer.maskedCorners = corners
        self.layer.cornerRadius = radius
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        
    }

    func applyGradient(with colours: [UIColor], locations: [NSNumber]? = nil) {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
    }
}

