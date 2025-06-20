//
//  SplashViewController.swift
//  FitMate
//
//  Created by soophie on 6/20/25.
//

import UIKit
import SnapKit

class SplashViewController: UIViewController {
    
    private let logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "logo_bgX")
        
        return imageView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setConstraints()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let loginVC = LoginViewController()
            self.navigationController?.pushViewController(loginVC, animated: true)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .background800
        view.addSubview(logoImage)
        
    }
    private func setConstraints() {
        logoImage.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.5)
        }
    }
}
