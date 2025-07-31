import UIKit
import SnapKit

// 마이페이지 내 누적기록카드 셀
final class WorkRecordCell: UICollectionViewCell {
    static let identifier = "WorkRecordCell"
    
    // 셀 전체를 감싸는 기록카드 스타일뷰
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .background0
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    // 캐릭터 이미지 담는 뷰(그냥 캐릭터 넣으면 캐릭터가 찌그러짐 이슈가 발생해서 넣음)
    private let characterImageView: UIView = {
        let view = UIView()
        view.backgroundColor = .background0
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()
    
    // 실제 캐릭터 이미지 뷰
    private let characterImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // 운동 종목 라벨
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.text = "종목명"
        label.font = UIFont(name: "Pretendard-Medium", size: 20)
        label.textColor = .background900
        return label
    }()
    
    // 누적기록 라벨
    private let totalLabel: UILabel = {
        let label = UILabel()
        label.text = "총기록"
        label.font = UIFont(name: "Pretendard-Bold", size: 48)
        label.textColor = .background900
        return label
    }()
    
    // 단위 라벨
    private let unitLabel: UILabel = {
        let label = UILabel()
        label.text = "단위"
        label.font = UIFont(name: "Pretendard-Medium", size: 14)
        //label.textColor = UIColor(red: 87/255, green: 87/255, blue: 87/255, alpha: 1) //에셋에서 불러오니 다크모드변경에 따라 색상이 하얀색으로 보일 때가 있어서 그냥 RGB로 지정시킴
        label.textColor = .background600
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 레이아웃 구성
    private func setupLayout() {
        // TODO: - 오토 레이아웃 다시 잡아야 됨.
        // 피그마에 있는 폰트로 수정 시, 레이아웃 깨짐.
        
        contentView.addSubview(cardView)
        cardView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(144)
            $0.width.equalTo(335)
        }
        
        //이미지 뷰 내부에 이미지 추가
        characterImageView.addSubview(characterImage)
        characterImage.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(88)
            $0.height.equalTo(88)
        }
        
        // 텍스트 스택 (종목명,누적기롱,단위)
        let infoStack = UIStackView(arrangedSubviews: [typeLabel, totalLabel, unitLabel])
        infoStack.axis = .vertical
        infoStack.spacing = 4
        
        // 캐릭터이미지와 누적기록 묶은 컨테이너박스
        let containerStack = UIStackView(arrangedSubviews: [characterImageView, infoStack])
        containerStack.axis = .horizontal
        containerStack.spacing = 12
        containerStack.alignment = .center
        
        cardView.addSubview(containerStack)
        containerStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }
        
        characterImageView.snp.makeConstraints {
            $0.width.equalTo(144)
            $0.height.equalTo(112)
        }
    }
    
    // 외부에서 데이터를 받아 셀에 적용시키는 메서드
    func configure(with record: WorkoutRecord, index: Int) {
        typeLabel.text = record.type

        let unit = record.unit.trimmingCharacters(in: .whitespacesAndNewlines)
        let raw = record.totalDistance.trimmingCharacters(in: .whitespacesAndNewlines)

        if let value = Double(raw) {
            let cleanedValue = abs(value) < 0.01 ? 0.0 : value

            if record.type == "플랭크" {
                // 초 단위로 저장된 값은 분으로 전환시킴
                let minutes = Int(cleanedValue / 60.0)
                totalLabel.text = "\(minutes)"
                unitLabel.text = "분"
            } else {
                // 단위에 따라 포맷 분기처리
                switch unit {
                case "Km":
                    totalLabel.text = String(format: "%.2f", cleanedValue) // 소수 둘째자리까지만
                case "회", "초":
                    totalLabel.text = String(format: "%.0f", cleanedValue) // 정수로 출력되도록
                default:
                    totalLabel.text = String(format: "%.0f", cleanedValue)
                }
                unitLabel.text = record.unit
            }
        } else {
            totalLabel.text = "0"
        }

        // 종목에 따른 캐릭터 이미지 설정
        switch record.type {
        case "걷기":
            characterImage.image = UIImage(named: "walk")
        case "달리기":
            characterImage.image = UIImage(named: "run")
        case "플랭크":
            characterImage.image = UIImage(named: "plank")
        case "자전거":
            characterImage.image = UIImage(named: "bicycle")
        case "줄넘기":
            characterImage.image = UIImage(named: "jumpRope")
        default:
            characterImage.image = nil
        }

        // 인덱스에 따라 카드 색상 다르게 지정 (캐릭터들어가는 뷰도 함께)
        switch index {
        case 0:
            cardView.backgroundColor = UIColor(named: "Primary50")
            characterImageView.backgroundColor = UIColor(named: "Primary50")
        case 1:
            cardView.backgroundColor = UIColor(named: "Primary100")
            characterImageView.backgroundColor = UIColor(named: "Primary100")
        case 2:
            cardView.backgroundColor = UIColor(named: "Primary200")
            characterImageView.backgroundColor = UIColor(named: "Primary200")
        case 3:
            cardView.backgroundColor = UIColor(named: "Secondary50")
            characterImageView.backgroundColor = UIColor(named: "Secondary50")
        case 4:
            cardView.backgroundColor = UIColor(named: "Secondary100")
            characterImageView.backgroundColor = UIColor(named: "Secondary100")
        default:
            cardView.backgroundColor = .background0
            characterImageView.backgroundColor = .background0
        }
    }
}
