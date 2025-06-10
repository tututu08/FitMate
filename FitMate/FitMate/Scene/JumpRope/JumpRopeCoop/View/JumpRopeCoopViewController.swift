//
//  RunningViewController.swift
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//
import UIKit
import RxSwift
import RxCocoa

class JumpRopeCoopViewController: BaseViewController {

    private let rootView = JumpRopeCoopView()
    private var viewModel: JumpRopeCoopViewModel!

    private let startRelay = PublishRelay<Void>()
    private let mateCountRelay = PublishRelay<Int>()

    override func loadView() {
        self.view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // 저장된 목표치를 가져와 기본값 100을 사용합니다.
        let saved = UserDefaults.standard.integer(forKey: "JumpRopeGoal")
        let goal = saved > 0 ? saved : 100
        rootView.updateGoal("목표 \(goal)회")
        viewModel = JumpRopeCoopViewModel(goalCount: goal)
        startRelay.accept(())
    }

    override func bindViewModel() {
        let input = JumpRopeCoopViewModel.Input(
            start: startRelay.asObservable(),
            mateCount: mateCountRelay.asObservable()
        )
        let output = viewModel.transform(input: input)

        output.myCountText
            .drive(onNext: { [weak self] text in
                self?.rootView.updateMyRecord(text)
            })
            .disposed(by: disposeBag)

        output.mateCountText
            .drive(onNext: { [weak self] text in
                self?.rootView.updateMateRecord(text)
            })
            .disposed(by: disposeBag)

        output.progress
            .drive(onNext: { [weak self] ratio in
                self?.rootView.updateProgress(ratio: ratio)
            })
            .disposed(by: disposeBag)
    }
}
