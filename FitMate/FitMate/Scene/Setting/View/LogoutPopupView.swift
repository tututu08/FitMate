
import UIKit
import SnapKit
import RxCocoa

//로그아웃 확인용 팝업 뷰
final class LogoutPopupView: UIView {
    
    let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        return view
    }()
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        return view
    }()
    
    // 로그아웃 여부 묻기
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "정말 로그아웃하시겠어요?"
        label.font = UIFont(name: "Pretendard-SemiBold", size: 24)
        label.textColor = UIColor(named: "Background900")
        label.textAlignment = .center
        return label
    }()
    
    //로그아웃 후 안내
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "로그아웃시 로그인화면으로 돌아갑니다."
        label.font = UIFont(name: "Pretendard-Medium", size: 14)
        label.textColor = UIColor(named: "Background400")
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    // 취소 버튼(팝업닫기)
    let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.setTitleColor(UIColor(named: "Background900"), for: .normal)
        button.backgroundColor = UIColor(named: "Background50")
        button.layer.cornerRadius = 4
        return button
    }()
    
    // 로그아웃버튼
    let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("로그아웃", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "Primary500")
        button.layer.cornerRadius = 4
        return button
    }()
    
    // 버튼 2개를 수평으로 배치하는 뷰
    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cancelButton, confirmButton])
        stack.axis = .horizontal
        stack.spacing = 20
        stack.distribution = .fillEqually
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //레이아웃구성
    private func setupLayout() {
        addSubview(backgroundView)
        addSubview(containerView)
        
        [titleLabel, descriptionLabel, buttonStack].forEach {
            containerView.addSubview($0)
        }
        
        backgroundView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(326)
            $0.height.equalTo(210)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        buttonStack.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
        }
    }
}
