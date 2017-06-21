//
//  Message.swift
//  FireChat-Swift
//
//  Created by Katherine Fang on 8/20/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

import Foundation

class Message : NSObject, JSQMessageData
{
    var text_: String = ""
    var sender_: String = ""
    var date_: Date

    var imageUrl_: String?
    
    var senderDisplayName_:String = ""
    var isMediaMessage_:Bool = false
    var sectionName_:String = ""
    
    convenience init(text: String?, sender: String?, withSenderDisplayName displayName:String?, withMedia isMedia:Bool, withMessageHase messageHash:UInt,withDate date:Date, withStrDate strDate:NSString )
    {
        self.init(text: text, sender: sender, imageUrl: nil, withSenderDisplayName:displayName, withMedia: isMedia, withMessageHase: messageHash,withDate: date)
        
    }
    
    init(text: String?, sender: String?, imageUrl: String?, withSenderDisplayName displayName:String?, withMedia isMedia:Bool, withMessageHase messageHash:UInt, withDate date:Date) {
        self.text_ = text!
        self.sender_ = sender!
        self.date_ = date
        self.imageUrl_ = imageUrl
        self.senderDisplayName_ = displayName!
        self.isMediaMessage_ = isMedia
              
    }
    
    
    func text() -> String! {
        return text_;
    }
    
    func sender() -> String! {
        return sender_;
    }
    
    func imageUrl() -> String? {
        return imageUrl_;
    }
    func senderId() -> String
    {
        return sender_
    }
    func senderDisplayName() -> String
    {
        return senderDisplayName_
    }
    func date() -> Date! {
        return date_;
    }
    func isMediaMessage() -> Bool
    {
        return isMediaMessage_
    }
    func messageHash() -> UInt
    {
        return UInt(self.hash)
    }
    
    func sectionName() -> String!
    {
     return sectionName_
    }
    
}
