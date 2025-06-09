//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//

import UIKit
import SnapKit
import RxSwift
import RxRelay

class SportsModeViewController: UIViewController {
    private let exerciseItem: CarouselViewModel.ExerciseItem
    private let disposeBag = DisposeBag()
    
    private let modeSelectedRelay = PublishRelay<String>()
    
    init(exerciseItem: CarouselViewModel.ExerciseItem) {
        self.exerciseItem = exerciseItem
        super.init(nibName: nil, bundle: nil)
        self.title = "운동 선택"
        navigationItem.backButtonTitle = ""
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    private let effectLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    private let caloriesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textAlignment = .center
        return label
    }()
    private let CooperationModeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.setTitle("협력 모드", for: .normal)
        return button
    }()
    private let BattleModeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.setTitle("대결 모드", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.applyCustomAppearance()
        setupUI()
        configureUI(with: exerciseItem)
        bind()
    }

    private func bind() {
        CooperationModeButton.rx.tap
            .map { [weak self] in self?.exerciseItem.title ?? "" }
            .bind(to: modeSelectedRelay)
            .disposed(by: disposeBag)
        
        BattleModeButton.rx.tap
            .map { [weak self] in self?.exerciseItem.title ?? "" }
            .bind(to: modeSelectedRelay)
            .disposed(by: disposeBag)
        
        modeSelectedRelay.asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] title in
                let goalVC = GoalSelectionViewController()
                goalVC.viewModel.updateSelectedTitle(title)
                self?.navigationController?.pushViewController(goalVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        backgroundView.addSubview(imageView)
        [
            backgroundView,
            titleLabel,
            descriptionLabel,
            effectLabel,
            caloriesLabel,
            CooperationModeButton,
            BattleModeButton
        ].forEach { view.addSubview($0) }
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
        CooperationModeButton.snp.makeConstraints {
            $0.top.equalTo(caloriesLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().inset(20)
            $0.width.equalTo(157)
            $0.height.equalTo(60)
        }
        BattleModeButton.snp.makeConstraints {
            $0.top.equalTo(CooperationModeButton)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(157)
            $0.height.equalTo(60)
        }
    }
    private func configureUI(with item: CarouselViewModel.ExerciseItem) {
        titleLabel.text = item.title
        imageView.image = item.image
        descriptionLabel.text = item.description
        effectLabel.text = "운동 효과: \(item.effect)"
        caloriesLabel.text = "칼로리 소모: \(item.calorie)"
    }
}
