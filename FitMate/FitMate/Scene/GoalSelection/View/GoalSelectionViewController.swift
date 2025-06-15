//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import UIKit
import SnapKit
import RxSwift
import RxRelay

class GoalSelectionViewController: BaseViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    // ViewModel 인스턴스
    private let viewModel = GoalSelectionViewModel()
    
    // PickerView 인스턴스
    private let pickerView = UIPickerView()
    
    // Picker에 표시될 데이터
    private var pickerData: [String] = []
    
    // 선택된 운동 제목을 전달하는 Rx Relay
    private let selectedTitleRelay = BehaviorRelay<String>(value: "")
    // 선택된 운동 모드를 전달하는 Rx Relay
    private let selectedModeRelay = BehaviorRelay<SportsModeViewController.ExerciseMode>(value: .cooperation)
   // 선택된 목표치를 전달하는 Rx Relay
    private let selectedGoalRelay = BehaviorRelay<String>(value: "")
    // 타이틀 라벨: 안내 문구
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "pretendard-semibold", size: 24)
        label.textAlignment = .left
        label.text = "오늘 얼마나 \n운동하고 싶으신가요?"
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    // 서브 타이틀 라벨: 부가 설명
    private let subInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "pretendard-regular", size: 16)
        label.textAlignment = .left
        label.text = "파트너와 함께 정해보세요"
        label.textColor = .lightGray
        label.numberOfLines = 0
        return label
    }()
    
    // 목표 설정 버튼
    private let goalSettingButton: UIButton = {
        let button = UIButton()
        button.setTitle("목표 설정", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 4
        button.backgroundColor = .primary500
        button.titleLabel?.font = UIFont(name: "pretendard-semibold", size: 20)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 화면 제목 및 네비게이션 설정
        self.title = "목표치"
        navigationController?.navigationBar.applyCustomAppearance()
        navigationItem.backButtonTitle = ""
        
        // PickerView 델리게이트 및 데이터 소스 지정
        pickerView.dataSource = self
        pickerView.delegate = self
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        // selectedTitleRelay를 ViewModel에 입력으로 전달
        let input = GoalSelectionViewModel.Input(
            selectedTitle: selectedTitleRelay.asObservable(),
            selectedMode: selectedModeRelay.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        // ViewModel에서 전달받은 pickerItems를 구독하여 pickerData에 반영
        output.pickerItems
            .drive(onNext: { [weak self] data in
                self?.pickerData = data
                self?.pickerView.reloadAllComponents()
            })
            .disposed(by: disposeBag)
        // 목표 설정 클릭시 바인딩
        goalSettingButton.rx.tap
            .bind(onNext: { [weak self] selectedGoal in
                guard let self = self else { return }
                let selectedMode = self.selectedModeRelay.value
                let selectedGoal = self.selectedGoalRelay.value
                // 저장(종목 타이틀, 목표치)
                
                
                // 모드에 따른 화면 전환 분기
                switch selectedMode {
                case .cooperation:
                    // 협력 모드 화면 이동
                    let runningCooperationVC = RunningCoopViewController(goalText: selectedGoal)
                    runningCooperationVC.selectedGoalRelay.accept(selectedGoal)
                    self.navigationController?.pushViewController(runningCooperationVC, animated: true)
                    
                case .battle:
                    // 대결 모드 화면 이동
                    let runningBattleVC = RunningBattleViewController()
                    self.navigationController?.pushViewController(runningBattleVC, animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
    
    // 외부에서 선택된 운동 제목을 업데이트할 때 호출
    func updateSelectedTitle(_ title: String) {
        selectedTitleRelay.accept(title)
    }
    // 외부에서 선택된 운동 모드를 업데이트할 때 호출
    func updateSelectedMode(_ mode: SportsModeViewController.ExerciseMode) {
        selectedModeRelay.accept(mode)
    }
    
    override func configureUI() {
        super.configureUI()
        view.backgroundColor = .background800
        
        // UI 요소를 뷰에 추가
        [infoLabel, subInfoLabel, pickerView, goalSettingButton].forEach {
            view.addSubview($0)
        }
        
        // 오토레이아웃 설정
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(32)
            $0.leading.trailing.equalToSuperview().offset(24)
            $0.width.equalTo(327)
            $0.height.equalTo(68)
        }
        
        subInfoLabel.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().offset(24)
            $0.width.equalTo(327)
            $0.height.equalTo(24)
        }
        
        pickerView.snp.makeConstraints {
            $0.top.equalTo(subInfoLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.width.equalTo(311)
            $0.height.equalTo(296)
        }
        
        goalSettingButton.snp.makeConstraints {
            $0.top.equalTo(pickerView.snp.bottom).offset(35)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(335)
            $0.height.equalTo(60)
        }
    }
    
    // UIPickerViewDataSource
    // PickerView의 구성 요소 수 (여기선 1개 열)
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    // 각 열(row)의 항목 수
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerData.count
    }
    
    // UIPickerViewDelegate
    // 각 row에 표시될 UIView 커스터마이징
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let container = view ?? UIView()
        container.subviews.forEach { $0.removeFromSuperview() } // 재사용 뷰 정리
        
        let label = UILabel()
        label.text = pickerData[row]
        label.font = UIFont(name: "pretendard-semibold", size: 40)
        label.textAlignment = .center
        label.textColor = .white
        
        container.addSubview(label)
        label.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.bottom.equalToSuperview()
        }
        
        // 현재 선택된 행이라면 진하게 표시
        if row == pickerView.selectedRow(inComponent: component) {
            container.backgroundColor = .darkGray
            label.alpha = 1.0
            label.layer.borderWidth = 2
            label.layer.borderColor = UIColor.primary400.cgColor
            label.layer.cornerRadius = 4
            label.clipsToBounds = true
        } else {
            container.backgroundColor = UIColor.darkGray.withAlphaComponent(0.3)
            label.alpha = 0.7
        }
        
        return container
    }
    
    // Picker의 항목을 선택했을 때 호출
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selected = pickerData[row]
        selectedGoalRelay.accept(selected)
        pickerView.reloadAllComponents()
    }
    
    // 각 행의 높이 설정
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 100
    }
}
