//
//  RunningViewController.swift
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import UIKit
import SnapKit
import RxRelay

// 협동 러닝 화면을 담당하는 뷰 컨트롤러
class RunningCoopViewController: BaseViewController {
    private let rootView = CooperationSportsView() // 화면에 보여줄 커스텀 뷰 (UI 구성)
    private let runningCoopViewModel = RunningCoopViewModel() // 뷰모델 인스턴스 생성
    
    // 목표 데이터를 저장하고 전달하는 RxRelay (초기값은 빈 문자열)
    var selectedGoalRelay = BehaviorRelay<String>(value: "")
    
    // 외부에서 goalText를 받아와 selectedGoalRelay에 저장하는 초기화 메서드
    init(goalText: String) {
        super.init(nibName: nil, bundle: nil)
        selectedGoalRelay.accept(goalText) // 초기 목표값 설정
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 뷰를 rootView로 설정
    override func loadView() {
        self.view = rootView
    }
    
    // 뷰가 로드된 후 추가 작업을 수행할 수 있는 메서드
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // UI 구성
    override func configureUI() {
        super.configureUI()
        view.backgroundColor = .black // 배경색을 검정으로 설정
    }
    
    // ViewModel과 뷰를 바인딩하는 메서드
    override func bindViewModel() {
        super.bindViewModel()
        
        // ViewModel Input 생성
        let input = RunningCoopViewModel.Input(
            selectedGoalRelay: selectedGoalRelay.asObservable() // 목표 값 Observable로 전달
        )
        
        // ViewModel로부터 Output 반환받기
        let output = runningCoopViewModel.transform(input: input)
        
        // 목표 값이 바뀔 때마다 rootView의 목표 표시 UI 업데이트
        selectedGoalRelay
            .subscribe(onNext: { [weak self] goal in
                self?.rootView.updateGoal(goal) // 목표 텍스트 업데이트
            })
            .disposed(by: disposeBag)
        
        // 거리 텍스트가 변경되면 rootView에 있는 거리 UI 업데이트
        output.distanceText
            .drive(onNext: { [weak self] distance in
                self?.rootView.updateMyRecord(distance) // 내 기록 거리 업데이트
            })
            .disposed(by: disposeBag)
        
        rootView.updateMateRecord("")
        rootView.updateProgress(ratio: 0.7)
    }
}
