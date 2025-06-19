//
//  RunningViewController.swift
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//
import RxSwift
import Foundation
import RxCocoa

class RunningBattleViewController: BaseViewController {

    private let rootView = RunningBattleView()
    private let viewModel: RunningBattleViewModel
    // 시작 트리거용(버튼, viewDidLoad 등에서 신호 보낼 때 사용)
    private let startTrriger = PublishRelay<Void>()
    
    private let mateDistanceRelay = PublishRelay<Double>()
    
    private let matchCode: String
    private let mateUid: String
    private let myUid: String
    private let myCharacter: String
    private let mateCharacter: String
    
    init(goalDistance: Int, matchCode: String, myUid: String, mateUid: String, myCharacter: String, mateCharacter: String) {
        self.matchCode = matchCode
        self.myUid = myUid
        self.mateUid = mateUid
        self.myCharacter = myCharacter
        self.mateCharacter = mateCharacter
        self.viewModel = RunningBattleViewModel(
            goalDistance: goalDistance,
            myCharacter: myCharacter,
            mateCharacter: mateCharacter,
            matchCode: matchCode,
            myUid: myUid
        )
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("not implemented") }
    
    override func loadView() {
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rootView.updateGoal("\(viewModel.goalDistance)Km")
        rootView.updateMyCharacter(myCharacter)
        rootView.updateMateCharacter(mateCharacter)
        
        // MARK: - Firestore로부터 메이트 거리 수신
        FirestoreService.shared
            .observeMateProgress(matchCode: matchCode, mateUid: mateUid)
            .bind(to: mateDistanceRelay)
            .disposed(by: disposeBag)
        
        startTrriger.accept(())
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        let input = RunningBattleViewModel.Input(
            startTracking: startTrriger.asObservable(),
            mateDistance: mateDistanceRelay.asObservable()
        )
        let output = viewModel.transform(input: input)
        
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
        
        output.myProgress
            .drive(onNext: { [weak self] progress in
                self?.rootView.myUpdateProgress(ratio: progress)
            })
            .disposed(by: disposeBag)
        
        output.mateProgress
            .drive(onNext: { [weak self] progress in
                self?.rootView.mateUpdateProgress(ratio: progress)
            })
            .disposed(by: disposeBag)
    }
}
