//
//  SingletonFunctions.swift
//  TVShowsTest
//
//  Created by Abel Lazaro on 08/08/23.
//

import Foundation
import UIKit

class SingletonFunctions {
    
    static var shared = SingletonFunctions()
    
    func showAlert(title: String, message: String, actionDone: UIAlertAction,context:UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(actionDone)
        context.present(alert, animated: true, completion: nil)
    }
    
}
