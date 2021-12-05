//
//  AnChoreerDetailViewController.swift
//  AnChoreer
//
//  Created by Kim dohyun on 2021/12/03.
//

import UIKit
import WebKit

class AnChoreerDetailViewController: UIViewController {
    
    @IBOutlet weak var detailMovieImageView: UIImageView!
    @IBOutlet weak var detailMovieDirectorTitleLabel: UILabel!
    @IBOutlet weak var detailMovieActorTitleLabel: UILabel!
    @IBOutlet weak var detailMovieUserSuggestButton: UIButton!
    @IBOutlet weak var detailMovieUserRatingLabel: UILabel!
    @IBOutlet weak var detailWebView: WKWebView!
    
    var selectIndex: Int = 0
    var detailFlag: [Bool] = []
    public var suggestInfo:SearchModelInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        print("detailFlag Value \(detailFlag)")
        webViewConfigure()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if detailFlag[selectIndex] {
            self.detailMovieUserSuggestButton.setImage(UIImage(named: "starEnable"), for: .normal)
        } else {
            self.detailMovieUserSuggestButton.setImage(UIImage(named: "stardDisable"), for: .normal)
        }
    }
    
    
    private func configure() {
        let backbutton = UIButton(type: .custom)
        backbutton.setImage(UIImage(named: "navigationImage"), for: .normal)
        backbutton.addTarget(self, action: #selector(detailsendDataInfo), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backbutton)
        self.navigationController?.navigationBar.tintColor = .black
        let titleString = suggestInfo?.title.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        let detailTitleView = UILabel()
        detailTitleView.text = titleString ?? "값이 비워있습니다"
        detailTitleView.font = UIFont.boldSystemFont(ofSize: 18)
        self.navigationItem.titleView = detailTitleView
        detailMovieUserRatingLabel.text = "평점: \(suggestInfo?.userRating ?? "값이 비워있습니다")"
        detailMovieActorTitleLabel.text = "출연: \(suggestInfo?.actor ?? "값이 비워있습니다")"
        detailMovieDirectorTitleLabel.text = "배우: \(suggestInfo?.director ?? "값이 비워있습니다")"
        detailMovieImageView.contentMode = .scaleToFill
        if let bindingImage = suggestInfo?.image {
            guard let urlString = URL(string: bindingImage) else { return }
            
            guard let data = try? Data(contentsOf: urlString), let image = UIImage(data: data) else {
                return
            }
            detailMovieImageView.image = image
        }
        detailMovieUserSuggestButton.addTarget(self, action: #selector(suggestButtonDidTap), for: .touchUpInside)
    }
    
    private func webViewConfigure() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }
            guard let bindingLink = self.suggestInfo?.link else { return }
            guard let urlString = URL(string: bindingLink) else {
                return
            }
            let requestUrl = URLRequest(url: urlString)
            DispatchQueue.main.async {
                self.detailWebView.load(requestUrl)
            }
        }
    }
    
    @objc
    public func detailsendDataInfo() {
        guard let viewcontrollers = self.navigationController?.viewControllers else { return }
        if viewcontrollers.first is ViewController {
            if let mainViewController = viewcontrollers.first as? ViewController {
                mainViewController.mainisFlag = detailFlag
            }
        }
        print("detail send Flag \(detailFlag)")
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc
    public func suggestButtonDidTap() {
        if detailFlag[selectIndex] {
            detailFlag[selectIndex] = false
            UserDefaults.standard.set(detailFlag, forKey: "mainisFlag")
            self.detailMovieUserSuggestButton.setImage(UIImage(named: "stardDisable"), for: .normal)
        } else {
            detailFlag[selectIndex] = true
            UserDefaults.standard.set(detailFlag, forKey: "mainisFlag")
            self.detailMovieUserSuggestButton.setImage(UIImage(named: "starEnable"), for: .normal)
        }
    }
}
