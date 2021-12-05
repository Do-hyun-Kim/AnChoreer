//
//  SuggestViewController.swift
//  AnChoreer
//
//  Created by Kim dohyun on 2021/12/04.
//

import UIKit

class SuggestViewController: UIViewController {
    @IBOutlet weak var suggestTableView: UITableView!

    public var suggestStatusType =  ViewStatus.Empty
    var suggestDataInfo:[SearchModelInfo] = []
    var suggestDataDictionary:[Int:SearchModelInfo] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setsuggestInfo()
        suggestConfigure()
        print("test data dictionary \(suggestDataInfo)")
    }
    
    private func suggestConfigure() {
        let titleView = UILabel()
        titleView.text = "즐겨찾기 목록"
        titleView.font = UIFont.boldSystemFont(ofSize: 18)
        self.navigationItem.titleView = titleView
        let rightButton = UIButton(type: .custom)
        rightButton.addTarget(self, action: #selector(rightButtonDidTap), for: .touchUpInside)
        rightButton.setImage(UIImage(named: "suggestImage"), for: .normal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: rightButton)
        suggestTableView.delegate = self
        suggestTableView.dataSource = self
        suggestTableView.separatorColor = .lightGray
        suggestTableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        suggestTableView.tableFooterView = UIView()
        suggestTableView.tableHeaderView = UIView()
        suggestStatusType = suggestDataInfo.isEmpty ? ViewStatus.Empty : ViewStatus.All
        let emptyNib = UINib(nibName: "AnchoreerEmptyTableViewCell", bundle: nil)
        suggestTableView.register(emptyNib, forCellReuseIdentifier: "EmptyCell")
        let suggestNib = UINib(nibName: "AnChoreerTableViewCell", bundle: nil)
        suggestTableView.register(suggestNib, forCellReuseIdentifier: "AnChoreerCell")
    }
    
    public func setsuggestInfo() {
        DispatchQueue.global().async {
            for (_,item) in self.suggestDataDictionary.enumerated() {
                self.suggestDataInfo.append(item.value)
            }
        }
    }
    
    private func configureDispatchCell(index indexPath: IndexPath) {
        if suggestStatusType == .All {
            DispatchQueue.global(qos: .utility).async { [weak self] in
                guard let self = self else { return }
                guard let urlString = URL(string: self.suggestDataInfo[indexPath.row].image) else { return }
                guard let data = try? Data(contentsOf: urlString), let image = UIImage(data: data) else { return }
                let replaceString = self.suggestDataInfo[indexPath.row].title.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                DispatchQueue.main.async {
                    if let cell = self.suggestTableView.cellForRow(at: indexPath) as? AnChoreerTableViewCell {
                        self.suggestTableView.isUserInteractionEnabled = true
                        self.suggestTableView.separatorColor = .lightGray
                        self.suggestTableView.isScrollEnabled = true
                        cell.movieImageView.image = image
                        cell.movieTitleLabel.text = replaceString
                        cell.movieDirectorLabel.text = "감독: \(self.suggestDataInfo[indexPath.row].director)"
                        cell.movieActorLabel.text = "출연 : \(self.suggestDataInfo[indexPath.row].actor)"
                        cell.movieUserRatingLabel.text = "평점: \(self.suggestDataInfo[indexPath.row].userRating)"
                        cell.movieUserSuggestButton.setImage(UIImage(named: "starEnable"), for: .normal)
                        cell.movieUserSuggestButton.isEnabled = false
                    }
                }
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if let emptyCell = self.suggestTableView.cellForRow(at: indexPath) as? AnchoreerEmptyTableViewCell {
                    emptyCell.selectionStyle = .none
                    self.suggestTableView.isScrollEnabled = false
                    self.suggestTableView.isUserInteractionEnabled = false
                    self.suggestTableView.separatorColor = .clear
                }
            }
        }
    }
    
    public func detailSendInfo(index indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let anchoreerDetailView = storyboard.instantiateViewController(withIdentifier: "AnChoreerDetailVC") as? AnChoreerDetailViewController
        guard let anchoreerDetailVC = anchoreerDetailView else { return }
        anchoreerDetailVC.suggestInfo = suggestDataInfo[indexPath.row]
        anchoreerDetailVC.selectIndex = indexPath.row
        self.navigationController?.pushViewController(anchoreerDetailVC, animated: true)
    }
    
    @objc
    private func rightButtonDidTap() {
        self.navigationController?.popViewController(animated: true)
    }
        
}



extension SuggestViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch suggestStatusType {
        case .Empty:
            return 1
        case .All:
            return suggestDataInfo.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch suggestStatusType {
        case .All:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AnChoreerCell", for: indexPath) as! AnChoreerTableViewCell
            configureDispatchCell(index: indexPath)
            return cell
        case .Empty:
            let emptyCell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell", for: indexPath) as? AnchoreerEmptyTableViewCell
            configureDispatchCell(index: indexPath)
            return emptyCell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        detailSendInfo(index: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch suggestStatusType {
        case .All:
            return UITableView.automaticDimension
        case .Empty:
            return tableView.frame.height
        }
    }

}
