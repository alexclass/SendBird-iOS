//
//  IncomingUserMessageTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/6/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import AlamofireImage

class IncomingUserMessageTableViewCell: UITableViewCell {
    weak var delegate: MessageDelegate?
    
    @IBOutlet weak var dateSeperatorContainerView: UIView!
    @IBOutlet weak var dateSeperatorLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageDateLabel: UILabel!
    @IBOutlet weak var messageContainerView: UIView!
    
    @IBOutlet weak var dateLabelContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var messageDateLabelWidth: NSLayoutConstraint!
    @IBOutlet weak var dateContainerViewTopMargin: NSLayoutConstraint!
    @IBOutlet weak var profileImageLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var messageContainerLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var profileImageWidth: NSLayoutConstraint!
    @IBOutlet weak var messageContainerLeftPadding: NSLayoutConstraint!
    @IBOutlet weak var messageContainerBottomPadding: NSLayoutConstraint!
    @IBOutlet weak var messageContainerRightPadding: NSLayoutConstraint!
    @IBOutlet weak var messageContainerTopPadding: NSLayoutConstraint!
    @IBOutlet weak var messageDateLabelLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var messageDateLabelRightMargin: NSLayoutConstraint!
    @IBOutlet weak var dateContainerBottomMargin: NSLayoutConstraint!
    
    private var message: SBDUserMessage!
    private var prevMessage: SBDBaseMessage!
    private var displayNickname: Bool = true

    static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    static func cellReuseIdentifier() -> String {
        return String(describing: self)
    }
    
    @objc private func clickProfileImage() {
        if self.delegate != nil {
            self.delegate?.clickProfileImage(viewCell: self, user: self.message!.sender!)
        }
    }
    
    @objc private func clickUserMessage() {
        if self.delegate != nil {
            self.delegate?.clickMessage(view: self, message: self.message!)
        }
    }
    
    func setModel(aMessage: SBDUserMessage) {
        self.message = aMessage
        
        self.profileImageView.af_setImage(withURL: URL(string: (self.message.sender?.profileUrl!)!)!, placeholderImage: UIImage(named: "img_profile"))
        
        let profileImageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickProfileImage))
        self.profileImageView.isUserInteractionEnabled = true
        self.profileImageView.addGestureRecognizer(profileImageTapRecognizer)
        
        let messageContainerTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickUserMessage))
        self.messageContainerView.isUserInteractionEnabled = true
        self.messageContainerView.addGestureRecognizer(messageContainerTapRecognizer)
        
        // Message Date
        let messageDateAttribute = [
            NSFontAttributeName: Constants.messageDateFont(),
            NSForegroundColorAttributeName: Constants.messageDateColor()
        ]
        
        let messageTimestamp = Double(self.message.createdAt) / 1000.0
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        let messageCreatedDate = NSDate(timeIntervalSince1970: messageTimestamp)
        let messageDateString = dateFormatter.string(from: messageCreatedDate as Date)
        let messageDateAttributedString = NSMutableAttributedString(string: messageDateString, attributes: messageDateAttribute)
        self.messageDateLabel.attributedText = messageDateAttributedString
        
        // Seperator Date
        let seperatorDateFormatter = DateFormatter()
        seperatorDateFormatter.dateStyle = DateFormatter.Style.medium
        self.dateSeperatorLabel.text = seperatorDateFormatter.string(from: messageCreatedDate as Date)
        
        // Relationship between the current message and the previous message
        self.profileImageView.isHidden = false
        self.dateSeperatorContainerView.isHidden = false
        self.dateLabelContainerHeight.constant = 24.0
        self.dateContainerViewTopMargin.constant = 10.0
        self.dateContainerBottomMargin.constant = 10.0
        self.displayNickname = true
        if self.prevMessage != nil {
            // Day Changed
            let prevMessageDate = NSDate(timeIntervalSince1970: Double(self.prevMessage.createdAt) / 1000.0)
            let currMessageDate = NSDate(timeIntervalSince1970: Double(self.message.createdAt) / 1000.0)
            let prevMessageDateComponents = NSCalendar.current.dateComponents([.day, .month, .year], from: prevMessageDate as Date)
            let currMessagedateComponents = NSCalendar.current.dateComponents([.day, .month, .year], from: currMessageDate as Date)
            
            if prevMessageDateComponents.year != currMessagedateComponents.year || prevMessageDateComponents.month != currMessagedateComponents.month || prevMessageDateComponents.day != currMessagedateComponents.day {
                // Show date seperator.
                self.dateSeperatorContainerView.isHidden = false
                self.dateLabelContainerHeight.constant = 24.0
                self.dateContainerViewTopMargin.constant = 10.0
                self.dateContainerBottomMargin.constant = 10.0
            }
            else {
                // Hide date seperator.
                self.dateSeperatorContainerView.isHidden = true
                self.dateLabelContainerHeight.constant = 0
                self.dateContainerBottomMargin.constant = 0
                
                // Continuous Message
                if self.prevMessage is SBDAdminMessage {
                    self.dateContainerViewTopMargin.constant = 10.0
                }
                else {
                    var prevMessageSender: SBDUser?
                    var currMessageSender: SBDUser?
                    
                    if self.prevMessage is SBDUserMessage {
                        prevMessageSender = (self.prevMessage as! SBDUserMessage).sender
                    }
                    else if self.prevMessage is SBDFileMessage {
                        prevMessageSender = (self.prevMessage as! SBDFileMessage).sender
                    }
                    
                    currMessageSender = self.message.sender
                    
                    if prevMessageSender != nil && currMessageSender != nil {
                        if prevMessageSender?.userId == currMessageSender?.userId {
                            // Reduce margin
                            self.dateContainerViewTopMargin.constant = 5.0
                            self.profileImageView.isHidden = true
                            self.displayNickname = false
                        }
                        else {
                            // Set default margin.
                            self.profileImageView.isHidden = false
                            self.dateContainerViewTopMargin.constant = 10.0
                        }
                    }
                    else {
                        self.dateContainerViewTopMargin.constant = 10.0
                    }
                }
            }
        }
        else {
            // Show date seperator.
            self.dateSeperatorContainerView.isHidden = false
            self.dateLabelContainerHeight.constant = 24.0
            self.dateContainerViewTopMargin.constant = 10.0
            self.dateContainerBottomMargin.constant = 10.0
        }
        
        let fullMessage = self.buildMessage()
        self.messageLabel.attributedText = fullMessage
        
        self.layoutIfNeeded()
    }
    
    func setPreviousMessage(aPrevMessage: SBDBaseMessage?) {
        self.prevMessage = aPrevMessage
    }
    
    func buildMessage() -> NSAttributedString {
        var nicknameAttribute: [String:AnyObject]?
        switch (self.message.sender?.nickname?.characters.count)! % 5 {
        case 0:
            nicknameAttribute = [
                NSFontAttributeName: Constants.nicknameFontInMessage(),
                NSForegroundColorAttributeName: Constants.nicknameColorInMessageNo0()
            ]
            break;
        case 1:
            nicknameAttribute = [
                NSFontAttributeName: Constants.nicknameFontInMessage(),
                NSForegroundColorAttributeName: Constants.nicknameColorInMessageNo1()
            ]
            break;
        case 2:
            nicknameAttribute = [
                NSFontAttributeName: Constants.nicknameFontInMessage(),
                NSForegroundColorAttributeName: Constants.nicknameColorInMessageNo2()
            ]
            break;
        case 3:
            nicknameAttribute = [
                NSFontAttributeName: Constants.nicknameFontInMessage(),
                NSForegroundColorAttributeName: Constants.nicknameColorInMessageNo3()
            ]
            break;
        case 4:
            nicknameAttribute = [
                NSFontAttributeName: Constants.nicknameFontInMessage(),
                NSForegroundColorAttributeName: Constants.nicknameColorInMessageNo4()
            ]
            break;
        default:
            nicknameAttribute = [
                NSFontAttributeName: Constants.nicknameFontInMessage(),
                NSForegroundColorAttributeName: Constants.nicknameColorInMessageNo0()
            ]
            break;
        }
        
        let messageAttribute = [
            NSFontAttributeName: Constants.messageFont()
        ]
        
        let nickname = self.message.sender?.nickname
        let message = self.message.message
        
        var fullMessage: NSMutableAttributedString? = nil
        if self.displayNickname == true {
            fullMessage = NSMutableAttributedString.init(string: NSString(format: "%@\n%@", nickname!, message!) as String)
            
            fullMessage?.addAttributes(nicknameAttribute!, range: NSMakeRange(0, (nickname?.characters.count)!))
            fullMessage?.addAttributes(messageAttribute, range: NSMakeRange((nickname?.characters.count)! + 1, (message?.characters.count)!))
        }
        else {
            fullMessage = NSMutableAttributedString.init(string: message!)
            fullMessage?.addAttributes(messageAttribute, range: NSMakeRange(0, (message?.characters.count)!))
        }
        
        return fullMessage!
    }
    
    func getHeightOfViewCell() -> CGFloat {
        let fullMessage = self.buildMessage()
        
        var fullMessageRect: CGRect

        let messageLabelMaxWidth = self.frame.size.width - (self.profileImageLeftMargin.constant + self.profileImageWidth.constant + self.messageContainerLeftMargin.constant + self.messageContainerLeftPadding.constant + self.messageContainerRightPadding.constant + self.messageDateLabelLeftMargin.constant + self.messageDateLabelWidth.constant + self.messageDateLabelRightMargin.constant)
        fullMessageRect = fullMessage.boundingRect(with: CGSize.init(width: messageLabelMaxWidth, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)

        
        let cellHeight = self.dateContainerViewTopMargin.constant + self.dateLabelContainerHeight.constant + self.dateContainerBottomMargin.constant + self.messageContainerTopPadding.constant + fullMessageRect.size.height + self.messageContainerBottomPadding.constant
        
        return cellHeight
    }
}
