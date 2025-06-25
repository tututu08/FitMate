//
//  SplashViewController.swift
//  FitMate
//
//  Created by soophie on 6/20/25.
//

import UIKit
import SnapKit
import FirebaseAuth

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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.checkAutoLogin()
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
    
    private func checkAutoLogin() {
        if let currentUser = Auth.auth().currentUser,
           UserDefaults.standard.bool(forKey: "isLoggedIn") {
            
            let tabBar = TabBarController(uid: currentUser.uid)
            transitionToRoot(tabBar)
            
        } else {
            let loginVC = LoginViewController()
            self.navigationController?.pushViewController(loginVC, animated: true)
        }
    }
    
    private func transitionToRoot(_ vc: UIViewController) {
        guard let window = UIApplication.shared.windows.first else { return }
        window.rootViewController = vc
        UIView.transition(with: window,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }
}
