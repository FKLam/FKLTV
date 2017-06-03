//
//  FKLSocket.swift
//  Client
//
//  Created by kun on 2017/5/21.
//  Copyright © 2017年 kun. All rights reserved.
//

import Foundation

protocol FKLSocketDelegate: class {
    func socket(_ socket: FKLSocket, joinRoom user: UserInfo)
    func socket(_ socket: FKLSocket, leaveRoom user: UserInfo)
    func socket(_ socket: FKLSocket, chatMsg: TextMessage)
    func socket(_ socket: FKLSocket, giftMsg: GiftMessage)
}

class FKLSocket: NSObject {
    
    fileprivate var tcpClient: TCPClient
    fileprivate lazy var userInfo: UserInfo.Builder = {
        let userInfo = UserInfo.Builder()
        userInfo.name = "lfk\(arc4random_uniform(10))"
        userInfo.level = 20
        return userInfo
    }()
    weak var delegate: FKLSocketDelegate?
    init(addr: String, port: Int) {
        tcpClient = TCPClient(addr: addr, port: port)
    }
}

extension FKLSocket {
    func connectedServer() -> Bool {
        return tcpClient.connect(timeout: 5).0
    }
    
    func sendMsg(data: Data, type: Int) {
        
        // 将消息长度，写入到data
        var length = data.count
        let headerData = Data(bytes: &length, count: 4)
        // 消息类型
        var tempType = type
        let typeData = Data(bytes: &tempType, count: 2)
        // 发送消息
        let totalData = headerData + typeData + data
        
        let result = tcpClient.send(data: totalData).0
        if result {
            print("发送成功")
        } else {
            print("发送失败")
        }
    }
    
    func startReadMsg() {
        DispatchQueue.global().async {
            while true {
                guard let lMsg = self.tcpClient.read(4) else {
                    continue
                }
                    // 读取长度的Data
                let msgData = Data(bytes: lMsg, count: 4)
                var lenght: Int = 0
                (msgData as NSData).getBytes(&lenght, length: 4)
                
                // 读取类型
                guard let typeMsg = self.tcpClient.read(2) else {
                    return
                }
                let typeData = Data(bytes: typeMsg, count: 2)
                var type: Int = 0
                (typeData as NSData).getBytes(&type, length: 2)
                print(type)
                
                // 根据长度，读取真实消息
                guard let msg = self.tcpClient.read(lenght) else {
                    return
                }
                let data = Data(bytes: msg, count: lenght)
                
                // 处理消息
                DispatchQueue.main.async {
                    self.handleMsg(type: type, data: data)
                }
                
            }
        }
    }
    
    fileprivate func handleMsg(type: Int, data: Data) {
        switch type {
        case 0, 1:
            let user = try! UserInfo.parseFrom(data: data)
            print("Join/Leave：\(user.name)")
            type == 0 ? delegate?.socket(self, joinRoom: user) : delegate?.socket(self, leaveRoom: user)
        case 2:
            let textMsg = try! TextMessage.parseFrom(data: data)
            print("Message: \(textMsg.text)")
            delegate?.socket(self, chatMsg: textMsg)
        case 3:
            let giftMsg = try! GiftMessage.parseFrom(data: data)
            print("GiftMessage: \(giftMsg.giftname)")
            delegate?.socket(self, giftMsg: giftMsg)
        default:
            print("未知类型")
        }
    }
}

extension FKLSocket {
    func sendJoinRoom() {
        // 获取消息的长度
        let msgData = (try! userInfo.build()).data()
        // 发送消息
        sendMsg(data: msgData, type: 0)
    }
    
    func sendLeaveRoom() {
        // 获取消息的长度
        let msgData = (try! userInfo.build()).data()
        // 发送消息
        sendMsg(data: msgData, type: 1)
    }
    
    func sendTextMsg(message: String) {
        // 创建TextMessage类型
        let textMsg = TextMessage.Builder()
        textMsg.user = try! userInfo.build()
        textMsg.text = message
        // 获取对应的data
        let chatData = (try! textMsg.build()).data()
        // 发送消息到服务器
        sendMsg(data: chatData, type: 2)
    }
    
    func sendGiftMsg(giftName: String, giftUrl: String, giftCount: String) {
        // 创建GiftMessage类型
        let giftMsg = GiftMessage.Builder()
        giftMsg.user = try! userInfo.build()
        giftMsg.giftname = giftName
        giftMsg.giftUrl = giftUrl
        giftMsg.giftCount = giftCount
        // 获取对应的data
        let giftData = (try! giftMsg.build()).data()
        // 发送消息到服务器
        sendMsg(data: giftData, type: 3)
    }
    
    func sendHeartBeat() {
        
    }
}
