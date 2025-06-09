//
//  FitMate
//
//  Created by 강성훈 on 6/5/25.
//
import UIKit
import SnapKit
import RxSwift
import RxRelay

class GoalSelectionViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    let viewModel = GoalSelectionViewModel()
    let disposeBag = DisposeBag()
    
    let pickerView = UIPickerView()
    
    private var pickerData: [String] = []

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24)
        label.textAlignment = .left
        label.text = "오늘 얼마나 \n운동하고 싶으신가요?"
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    private let subInfoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .left
        label.text = "파트너와 함께 정해보세요"
        label.textColor = .lightGray
        label.numberOfLines = 0
        return label
    }()
    private let GoalSettingButton: UIButton = {
       let button = UIButton()
        button.setTitle("목표설정", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24, weight: .bold)
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "목표치"
        navigationController?.navigationBar.applyCustomAppearance()
        navigationItem.backButtonTitle = ""
        
        pickerView.dataSource = self
        pickerView.delegate = self
    
        setupUI()
        bindViewModel()
        
    }

    func bindViewModel() {
        viewModel.pickerDataDriver
            .drive(onNext: { [weak self] data in
                self?.pickerData = data
                self?.pickerView.reloadAllComponents()
            })
            .disposed(by: disposeBag)
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        [ infoLabel, subInfoLabel, pickerView, GoalSettingButton].forEach {
            view.addSubview($0)
        }
        
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalToSuperview().offset(24)
        }
        
        subInfoLabel.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(24)
        }
        
        pickerView.snp.makeConstraints {
            $0.top.equalTo(subInfoLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.width.equalTo(296)
            $0.height.equalTo(311)
        }
        
        GoalSettingButton.snp.makeConstraints {
            $0.top.equalTo(pickerView.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(200)
            $0.height.equalTo(50)
        }
    }

    
    
    // UIPickerViewDataSource / Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let container = view ?? UIView()
        container.subviews.forEach { $0.removeFromSuperview() }

        let label = UILabel()
        label.text = pickerData[row]
        label.font = .systemFont(ofSize: 40)
        label.textAlignment = .center
        label.textColor = .white

        container.addSubview(label)
        label.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().offset(24)
            $0.bottom.equalToSuperview().inset(24)
        }

        // 선택된 행이면 다크 그레이 배경, 아니면 반투명 배경
        if row == pickerView.selectedRow(inComponent: component) {
            container.backgroundColor = .darkGray
            label.alpha = 1.0
        } else {
            container.backgroundColor = UIColor.darkGray.withAlphaComponent(0.3)
            label.alpha = 0.5
        }

        return container
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerView.reloadAllComponents()
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 100
    }
}

extension UINavigationBar {
    func applyCustomAppearance(backgroundColor: UIColor = .black, titleColor: UIColor = .white, font: UIFont = .boldSystemFont(ofSize: 20)) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = backgroundColor
        appearance.titleTextAttributes = [
            .foregroundColor: titleColor,
            .font: font
        ]
        self.standardAppearance = appearance
        self.scrollEdgeAppearance = appearance
        self.compactAppearance = appearance
        
        self.tintColor = titleColor // 뒤로가기 버튼 등 색상 설정
    }
}
