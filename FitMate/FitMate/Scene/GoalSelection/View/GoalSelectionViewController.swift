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
    // 숫자만
    private let selectedGoalValueRelay = BehaviorRelay<Int>(value: 0)
    // 단위만
    private let selectedGoalUnitRelay = BehaviorRelay<String>(value: "")
    
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
        label.text = "메이트와 함께 정해보세요"
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
    
    // 자신의 uid
    private let uid: String // 로그인 유저의 uid
    private var mateUid = "" // 메이트 uid
    
    init(uid: String) {
        self.uid = uid
        
        super.init(nibName: nil, bundle: nil)
        self.findMateUid(uid: uid) // 메이트 uid 검색
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    /// - 로그인 유저의 uid를 이용해 자신의 메이트 uid 검색
    private func findMateUid(uid: String) {
        FirestoreService.shared.findMateUid(uid: uid)
            .subscribe(onSuccess: { data in
                //guard let self else { return }
                self.mateUid = data
                print("메이트 UID 가져오기 성공: \(self.mateUid)")
            },onFailure: { error in
                print("문서 가져오기 실패: \(error.localizedDescription)")
            }).disposed(by: disposeBag)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        // selectedTitleRelay를 ViewModel에 입력으로 전달
        let input = GoalSelectionViewModel.Input(
            selectedTitle: selectedTitleRelay.asObservable(), // 운동 종목
            selectedMode: selectedModeRelay.asObservable()  // 운동 모드
        )
        
        let output = viewModel.transform(input: input)
        
        // ViewModel에서 전달받은 pickerItems를 구독하여 pickerData에 반영
        output.pickerItems
            .drive(onNext: { [weak self] data in
                guard let self else { return }
                self.pickerData = data
                self.pickerView.reloadAllComponents()
                // 초기 로드 시 첫 번째 항목을 선택 상태로 설정
                if let first = data.first {
                    self.pickerView.selectRow(0, inComponent: 0, animated: false)
                    self.updateGoalSelection(with: first)
                }
            })
            .disposed(by: disposeBag)
        
        // 목표 설정 클릭시 바인딩
        goalSettingButton.rx.tap
            .bind(onNext: { [weak self] selectedGoal in
                guard let self = self else { return }
                
                // 저장(종목 타이틀, 목표치)
                //                let selectedMode = self.selectedModeRelay.value // 운동 모드 저장
                //                let selectedGoal = self.selectedGoalRelay.value // 운동 목표 저장
                if self.selectedGoalValueRelay.value == 0,
                   self.pickerData.indices.contains(self.pickerView.selectedRow(inComponent: 0)) {
                    let text = self.pickerData[self.pickerView.selectedRow(inComponent: 0)]
                    self.updateGoalSelection(with: text)
                }
                // MARK: Firestore 데이터 저장
                // "matches" 컬렉션 및 "matchID" 문서 생성
                FirestoreService.shared.createMatchDocument(
                    inviterUid: self.uid,
                    inviteeUid: self.mateUid,
                    exerciseType: self.selectedTitleRelay.value,
                    goalValue: self.selectedGoalValueRelay.value,
                    goalUnit: self.selectedGoalUnitRelay.value,
                    mode: self.selectedModeRelay.value.asString
                )
                .subscribe(
                    onSuccess: { matchCode in
                        print("Match 생성 성공 \(matchCode)")
                        // 로딩 화면으로 이동
                        self.navigationController?.pushViewController(LoadingViewController(uid: self.uid, matchCode: matchCode), animated: true)
                    },
                    onFailure: { error in print("실패: \(error)") }
                ).disposed(by: disposeBag)
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
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.height.equalTo(380)
        }
        
        goalSettingButton.snp.makeConstraints {
            $0.top.equalTo(pickerView.snp.bottom).offset(33)
            $0.leading.trailing.equalToSuperview().inset(20)
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
        updateGoalSelection(with: selected)
        pickerView.reloadAllComponents()
    }
    private func updateGoalSelection(with text: String) {
        selectedGoalRelay.accept(text)
        let (value, unit) = splitValueAndUnit(from: text)
        guard let intValue = Int(value) else { return }
        selectedGoalValueRelay.accept(intValue)
        selectedGoalUnitRelay.accept(unit)
    }
    
    // 각 행의 높이 설정
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 100
    }
    // 문자열 분리 메서드
    private func splitValueAndUnit(from text: String) -> (String, String) {
        // 정규식 패턴 정의
        // ^         : 문자열 시작
        // (\d+)     : 숫자 한 개 이상을 첫 번째 그룹으로 캡처 (예: "200", "5", "10")
        // \s*       : 0개 이상의 공백 문자 (숫자와 단위 사이에 공백 있을 수 있음)
        // ([^\d\s]+): 숫자와 공백이 아닌 문자 한 개 이상을 두 번째 그룹으로 캡처 (단위 부분, 예: "회", "km", "분")
        // $         : 문자열 끝
        let pattern = #"^(\d+)\s*([^\d\s]+)$"#
        // 위 패턴으로 정규식 객체 생성 (대소문자 구분 없이)
        let regex   = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        // text에서 정규식과 첫 번째 매칭을 찾기
        if let match = regex?.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
           // 매칭된 결과에서 첫 번째 캡처 그룹(숫자)의 범위를 얻음
           let vR = Range(match.range(at: 1), in: text),
           // 매칭된 결과에서 두 번째 캡처 그룹(단위)의 범위를 얻음
           let uR = Range(match.range(at: 2), in: text) {
            // 숫자 부분을 String로 변환, 실패 시 0으로 처리
            let value = String(text[vR])
            // 단위 부분을 String으로 변환하고 앞뒤 공백 제거
            let unit  = String(text[uR]).trimmingCharacters(in: .whitespaces)
            // 숫자와 단위를 튜플로 반환
            return (value, unit)
        }
        // 패턴에 맞지 않을 경우 기본값 반환 (빈 문자열)
        return ("", "")
    }
}
