//
//  Extensions.swift
//  TVShowsTest
//
//  Created by Abel Lazaro on 08/08/23.
//

import Foundation
import UIKit

extension UIViewController {
    
    func goBack(){
        if let nav = self.navigationController {
            nav.popViewController(animated: false)
        } else {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    func nextViewController(viewController: String, storyboard: String , _transparent: Bool = false){
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: viewController)
        if _transparent {
            viewController.providesPresentationContextTransitionStyle = true
            viewController.definesPresentationContext = true
            viewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        }
        self.present(viewController, animated: false, completion: nil)
        
    }
    
}
