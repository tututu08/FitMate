//
//  RunningViewController.swift
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//
import UIKit
import SnapKit

class JumpRopeCoopViewController: UIViewController {
    
    let CoopVIew = CooperationSportsView()
    
    
    override func loadView() {
        self.view = CoopVIew
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.addSubview(CoopVIew)
//     
//        CoopVIew.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
    }
}
