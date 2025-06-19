//
//  RunningViewController.swift
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import UIKit
import SnapKit
import RxRelay
import RxSwift
import RxCocoa

final class RunningCoopViewController: BaseViewController {
    // 루트 뷰
    private let rootView = RunningCoopView()
    // 뷰모델 선언
    private let runningCoopViewModel: RunningCoopViewModel
    // 시작 트리거용(버튼, viewDidLoad 등에서 신호 보낼 때 사용)
    private let startRelay = PublishRelay<Void>()
    private let mateDistanceRelay = BehaviorRelay<Double>(value: 0)
    private let myCharacter: String
    private let mateCharacter: String
    private let quitRelay = PublishRelay<Void>()
    private let mateQuitRelay = PublishRelay<Void>()

    init(goalDistance: Int, myCharacter: String, mateCharacter: String) {
        self.myCharacter = myCharacter
        self.mateCharacter = mateCharacter
        
        self.runningCoopViewModel = RunningCoopViewModel(
            goalDistance: goalDistance,
            myCharacter: myCharacter,
            mateCharacter: mateCharacter
        )
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func loadView() {
        self.view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        rootView.updateGoal("\(runningCoopViewModel.goalDistance)Km")
        rootView.updateMyCharacter(runningCoopViewModel.myCharacter)
        rootView.updateMateCharacter(runningCoopViewModel.mateCharacter)
        startRelay.accept(())
        rootView.stopButton.rx.tap
            .bind { [weak self] in
                self?.rootView.showQuitAlert(
                    type: .myQuitConfirm, // 내가 종료 시도
                    onResume: {
                        // 그냥 닫고 아무 동작 없음 (계속 운동)
                    },
                    onQuit: { [weak self] in
                        // 진짜로 종료 → 기록 저장 & 화면 이동 등
                        self?.runningCoopViewModel.finish(success: false)
                        // 혹은 didFinishRelay 트리거 등
                    }
                )
            }
            .disposed(by: disposeBag)
    }

    override func bindViewModel() {
        super.bindViewModel()

        let input = RunningCoopViewModel.Input(
            startTracking: startRelay.asObservable(),
            mateDistance: mateDistanceRelay.asObservable(),
            quit: quitRelay.asObservable(),
            mateQuit: mateQuitRelay.asObservable()
        )

        let output = runningCoopViewModel.transform(input: input)

        output.myDistanceText
            .drive(onNext: { [weak self] text in
                self?.rootView.updateMyRecord(text)
            })
            .disposed(by: disposeBag)

        output.mateDistanceText
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
    func receiveMateQuit()    {
        rootView.showQuitAlert(
            type: .mateQuit,
            onBack: { [weak self] in
                // 피니쉬화면으로 이동 등
                self?.navigationController?.popToRootViewController(animated: true)
            }
        )
    }
}
