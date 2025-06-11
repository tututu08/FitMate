//
//  RunningViewController.swift
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//
import UIKit
import SnapKit

class RunningCoopViewController: BaseViewController {
    private let coopView = CooperationSportsView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureUI() {
        super.configureUI()
        
        view.backgroundColor = .black
        view.addSubview(coopView)
        
        coopView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    override func bindViewModel() {
        super.bindViewModel()
        
        coopView.updateGoal("")
        coopView.updateMyRecord("")
        coopView.updateMateRecord("")
        coopView.updateProgress(ratio: 0.7)
    }
    
}
