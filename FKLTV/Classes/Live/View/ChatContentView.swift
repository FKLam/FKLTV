//
//  ChatContentView.swift
//  FKLTV
//
//  Created by kun on 2017/5/23.
//  Copyright © 2017年 kun. All rights reserved.
//

private let kChatContentCellID = "kChatContentCellID"

import UIKit

class ChatContentView: UIView {

    fileprivate var tableView: UITableView!
    fileprivate lazy var messages: [NSMutableAttributedString] = [NSMutableAttributedString]()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func insertMsg(_ message: NSMutableAttributedString) {
        messages.append(message)
        tableView.reloadData()
        let indexPath = IndexPath(item: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}

extension ChatContentView {
    fileprivate func setupUI() {
        tableView = UITableView(frame: self.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.clear
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(tableView)
    }
}

extension ChatContentView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: kChatContentCellID) as? ChatContentViewCell
        if cell == nil {
            cell = ChatContentViewCell(style: .default, reuseIdentifier: kChatContentCellID)
        }
        cell?.contentLabel.attributedText = messages[indexPath.row]
        return cell!
    }
}
