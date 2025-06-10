import UIKit
import SnapKit
import RxSwift
import RxRelay

// 운동 모드(협력/대결)를 선택하는 화면
class SportsModeViewController: BaseViewController {
    
    // 선택된 운동 항목
    private let exerciseItem: CarouselViewModel.ExerciseItem
    
    // 모드 선택 이벤트를 전달하는 Relay (Rx 방식)
    private let modeSelectedRelay = PublishRelay<String>()
    
    // 외부에서 운동 항목을 주입받는 초기화 함수
    init(exerciseItem: CarouselViewModel.ExerciseItem) {
        self.exerciseItem = exerciseItem
        super.init(nibName: nil, bundle: nil)
        self.title = "운동 선택"
        navigationItem.backButtonTitle = "" // 뒤로가기 버튼 제목 제거
    }
    
    // 인터페이스 빌더 사용 안함
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 이미지 배경 뷰
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    // 운동 대표 이미지
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // 운동 이름 라벨
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    // 운동 설명 라벨
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // 운동 효과 설명 라벨
    private let effectLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // 칼로리 정보 라벨
    private let caloriesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textAlignment = .center
        return label
    }()
    
    // 협력 모드 선택 버튼
    private let cooperationModeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.setTitle("협력 모드", for: .normal)
        return button
    }()
    
    // 대결 모드 선택 버튼
    private let battleModeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.setTitle("대결 모드", for: .normal)
        return button
    }()
    
    // 뷰 로드 시 설정
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.applyCustomAppearance() // 커스텀 네비게이션 바 적용
        configureUI(with: exerciseItem) // 운동 아이템 정보로 UI 설정
    }

    // Rx 바인딩 처리
    override func bindViewModel() {
        super.bindViewModel()
        
        // 협력 모드 버튼 탭 -> 운동 제목을 Relay로 전달
        cooperationModeButton.rx.tap
            .map { [weak self] in self?.exerciseItem.title ?? "" }
            .bind(to: modeSelectedRelay)
            .disposed(by: disposeBag)
        
        // 대결 모드 버튼 탭 -> 운동 제목을 Relay로 전달
        battleModeButton.rx.tap
            .map { [weak self] in self?.exerciseItem.title ?? "" }
            .bind(to: modeSelectedRelay)
            .disposed(by: disposeBag)
        
        // Relay로부터 선택된 제목을 GoalSelectionViewController에 전달하고 push
        modeSelectedRelay.asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] title in
                let goalVC = GoalSelectionViewController()
                goalVC.updateSelectedTitle(title) // 선택된 운동 이름 전달
                self?.navigationController?.pushViewController(goalVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    // 전체 UI 구성
    override func configureUI() {
        super.configureUI()
        view.backgroundColor = .white
        
        backgroundView.addSubview(imageView) // 배경 뷰에 이미지 추가
        [
            backgroundView,
            titleLabel,
            descriptionLabel,
            effectLabel,
            caloriesLabel,
            cooperationModeButton,
            battleModeButton
        ].forEach { view.addSubview($0) } // 모든 요소 메인 뷰에 추가
        
        // 오토레이아웃 설정 (SnapKit 사용)
        backgroundView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(307)
        }
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.equalTo(251)
            $0.height.equalTo(272)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(backgroundView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        effectLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        caloriesLabel.snp.makeConstraints {
            $0.top.equalTo(effectLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        cooperationModeButton.snp.makeConstraints {
            $0.top.equalTo(caloriesLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().inset(20)
            $0.width.equalTo(157)
            $0.height.equalTo(60)
        }
        battleModeButton.snp.makeConstraints {
            $0.top.equalTo(cooperationModeButton)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(157)
            $0.height.equalTo(60)
        }
    }
    
    // 운동 아이템을 기반으로 각 UI에 데이터 바인딩
    private func configureUI(with item: CarouselViewModel.ExerciseItem) {
        titleLabel.text = item.title
        imageView.image = item.image
        descriptionLabel.text = item.description
        effectLabel.text = "운동 효과: \(item.effect)"
        caloriesLabel.text = "칼로리 소모: \(item.calorie)"
    }
}
