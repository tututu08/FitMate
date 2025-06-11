//
//  RunningViewController.swift
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//
import UIKit
import SnapKit

class RunningBattleViewController: BaseViewController {
    private let battleView = BattleSportsView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureUI() {
        super.configureUI()
        
        view.backgroundColor = .black
        
        view.addSubview(battleView)
        
        battleView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func bindViewModel() {
        super.bindViewModel()
    }
    
}
