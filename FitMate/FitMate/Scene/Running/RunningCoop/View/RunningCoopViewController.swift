//
//  RunningViewController.swift
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//
import UIKit
import SnapKit
import RxRelay

class RunningCoopViewController: BaseViewController {
    private let rootView = CooperationSportsView()

    private let runningCoopViewModel = RunningCoopViewModel()
    
    var selectedGoalRelay = BehaviorRelay<String>(value: "")
    
    init(goalText: String) {
        super.init(nibName: nil, bundle: nil)
        selectedGoalRelay.accept(goalText)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureUI() {
        super.configureUI()
        
        view.backgroundColor = .black
    }
    override func bindViewModel() {
        super.bindViewModel()
        let input = RunningCoopViewModel.Input(
            selectedGoalRelay: selectedGoalRelay.asObservable()
        )
        let output = runningCoopViewModel.transform(input: input)
        selectedGoalRelay
            .subscribe(onNext: { [weak self] goal in
                self?.rootView.updateGoal(goal)
            })
            .disposed(by: disposeBag)
        
        output.distanceText
            .drive(onNext: { [weak self] distance in
                self?.rootView.updateMyRecord(distance)
            })
            .disposed(by: disposeBag)
        
        rootView.updateMateRecord("")
        rootView.updateProgress(ratio: 0.7)
    }
    
}
