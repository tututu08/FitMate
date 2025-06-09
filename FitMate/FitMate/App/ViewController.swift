//
//  ViewController.swift
//  FitMate
//
//  Created by 강성훈 on 6/3/25.
//

import UIKit

class ViewController: UIViewController {

    override func loadView() {
        self.view = BattleSportsView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        // Do any additional setup after loading the view.
    }
}
