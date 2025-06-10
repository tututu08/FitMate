//
//  BaseViewController.swift
//  FitMate
//
//  Created by 강성훈 on 6/4/25.
//
import UIKit
import RxSwift

class BaseViewController: UIViewController {
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setLayoutUI()
        bindViewModel()
    }

    func configureUI() {
        // UI 구성은 각 VC에서 override
    }
    
    func setLayoutUI() {
        
    }

    func bindViewModel() {
        // Rx 바인딩은 각 VC에서 override
    }
}

