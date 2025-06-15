//
//  MateCodeVIewController.swift
//  FitMate
//
//  Created by Sophie on 6/6/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class MateCodeVIewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let customNavBar: UIView = {
        let view = UIView()
        return view
    }()
    
    private let backButton: UIButton = {
        let back = UIButton()
        back.setImage(UIImage(named: "backButton"), for: .normal)
        back.setTitle("              메이트 코드 입력", for: .normal)
        back.setTitleColor(.white, for: .normal)
        back.titleLabel?.font = .systemFont(ofSize: 20)
        back.contentHorizontalAlignment = .leading // 백버튼 위치
        return back
    }()
    
    private let mateDefaultAvatar: UIImageView = {
        let defaultAvatar = UIImageView()
        defaultAvatar.contentMode = .scaleAspectFit
        defaultAvatar.clipsToBounds = true
        defaultAvatar.image = UIImage(named: "mumu") //  이미지 추가
        return defaultAvatar
    }()
    
    private let fillInMateCode = CustomTextField(placeholder: "파트너 코드를 입력해주세요")
    
    private let completeButton: UIButton = {
        let complete = UIButton()
        complete.setTitle("입력 완료", for: .normal)
        complete.setTitleColor(.white, for: .normal)
        complete.titleLabel?.font = UIFont.systemFont(ofSize: 22) // 폰트 변경 필요
        complete.backgroundColor = .systemPurple // 컬러 변경 필요
        return complete
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setUpUI()
        backButtonTapped()
        completeTapped()
    }
    
    private func setUpUI() {
        [customNavBar,mateDefaultAvatar, fillInMateCode,
         completeButton].forEach({view.addSubview($0)})
        
        customNavBar.addSubview(backButton)
        
        customNavBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(56)
        }
        
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        
        mateDefaultAvatar.snp.makeConstraints { make in
            make.top.equalTo(customNavBar.snp.bottom).offset(86)
            make.leading.trailing.equalToSuperview().inset(110)
            make.height.equalTo(mateDefaultAvatar.snp.width).multipliedBy(1.0)
        }
        
        fillInMateCode.snp.makeConstraints { make in
            make.top.equalTo(mateDefaultAvatar.snp.bottom).offset(83)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(60)
        }
        
        completeButton.snp.makeConstraints { make in
            make.top.equalTo(fillInMateCode.snp.bottom).offset(20)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.width.equalTo(335)
            make.height.equalTo(60)
        }
    }
    
    private func backButtonTapped() {
        backButton.rx.tap
            .bind { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func completeTapped() {
        completeButton.rx.tap
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] _ in
                let main = MainViewController()
                self?.navigationController?.pushViewController(main, animated: true)
            })
            .disposed(by: disposeBag)
    }

}
