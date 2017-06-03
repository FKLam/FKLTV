//
//  ChatToolsView.swift
//  FKLTV
//
//  Created by kun on 2017/5/20.
//  Copyright © 2017年 kun. All rights reserved.
//

import UIKit

protocol ChatToolsViewDelegate: class {
    func chatToolsView(toolView: ChatToolsView, message: String)
}

class ChatToolsView: UIView {

    weak var delegate: ChatToolsViewDelegate?
    
    fileprivate lazy var emoticonBtn: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
    fileprivate lazy var emoticonView: EmoticonView = EmoticonView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: 250))
    
    var inputTextField: UITextField!
    fileprivate var sendMsgBtn: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK:- 设置UI界面

extension ChatToolsView {
    fileprivate func setupUI() {
        
        let btnW: CGFloat = 60
        let btnH: CGFloat = 32
        let btnX: CGFloat = kScreenW - 10 - btnW
        let btnY: CGFloat = 10
        sendMsgBtn = UIButton(frame: CGRect(x: btnX, y: btnY, width: btnW, height: btnH))
        sendMsgBtn.backgroundColor = UIColor.orange
        sendMsgBtn.addTarget(self, action: #selector(sendBtnClick(_:)), for: .touchUpInside)
        addSubview(sendMsgBtn)
        
        let fieldX: CGFloat = 10
        let fieldY: CGFloat = 10
        let fieldW: CGFloat = kScreenW - 10 * 3 - btnW
        let fieldH: CGFloat = 32
        inputTextField = UITextField(frame: CGRect(x: fieldX, y: fieldY, width: fieldW, height: fieldH))
        inputTextField.borderStyle = .roundedRect
        inputTextField.backgroundColor = UIColor.white
        addSubview(inputTextField)
        
        emoticonBtn.setImage(UIImage(named: "chat_btn_emoji"), for: .normal)
        emoticonBtn.setImage(UIImage(named: "chat_btn_keyboard"), for: .selected)
        emoticonBtn.addTarget(self, action: #selector(emoticonBtnClick(_:)), for: .touchUpInside)
        inputTextField.rightView = emoticonBtn
        inputTextField.rightViewMode = .always
        inputTextField.allowsEditingTextAttributes = true
        
        emoticonView.emoticonClickCallback = {[weak self] emoticon in
            if emoticon.emoticonName == "delete-n" {
                self?.inputTextField.deleteBackward()
                return
            }
            guard let range = self?.inputTextField.selectedTextRange else {
                return
            }
            self?.inputTextField.replace(range, withText: emoticon.emoticonName)
        }
    }
}

// MARK:- 事件监听

extension ChatToolsView {
    @objc fileprivate func textFieldDidEdit(_ sender: UITextField) {
        sendMsgBtn.isEnabled = sender.text!.characters.count != 0
    }
    
    @objc fileprivate func sendBtnClick(_ sender: UIButton) {
        let message = inputTextField.text!
        inputTextField.text = ""
        sender.isEnabled = false
        delegate?.chatToolsView(toolView: self, message: message)
    }
    
    @objc fileprivate func emoticonBtnClick(_ btn: UIButton) {
        btn.isSelected = !btn.isSelected
        
        let range = inputTextField.selectedTextRange
        inputTextField.resignFirstResponder()
        inputTextField.inputView = inputTextField.inputView == nil ? emoticonView : nil
        inputTextField.becomeFirstResponder()
        inputTextField.selectedTextRange = range
    }
    
//    @objc fileprivate func insertEmoticon(_ emoticon: Emoticon) {
//        
//    }
}
