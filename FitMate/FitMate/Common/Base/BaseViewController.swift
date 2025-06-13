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
        // 색상, 폰트 등 뷰 스타일 구성
    }
    
    func setLayoutUI() {
        
    }
    
    func setLayoutUI() {
        
    }

    func setupLayout() {
        // SnapKit을 활용한 레이아웃 설정
    }
    
    func bindViewModel() {
        // RxSwift 등 바인딩 처리
    }

}

