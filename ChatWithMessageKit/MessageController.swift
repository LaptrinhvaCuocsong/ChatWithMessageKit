//
//  MessageController.swift
//  MessageKitDemo
//
//  Created by Apple on 06/03/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import Foundation
import InputBarAccessoryView
import MessageKit

class MessageController: MessagesViewController {
    weak var viewController: ViewController?
    lazy var slackInputBar = SlackInputBar()

    private var messageList: [Message] = []
    private let currentUser = User(senderId: "1", displayName: "")

    override func viewDidLoad() {
        super.viewDidLoad()

        configureMessageCollectionView()
        configureMessageInputBar()
    }

    func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        scrollsToLastItemOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        showMessageTimestampOnSwipeLeft = true // default false
        
        // Với những Cell của message do currentUser gửi thì sẽ không hiển thị avatar
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.outgoingMessageBottomLabelAlignment.textInsets.right = 12
            layout.photoMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.photoMessageSizeCalculator.outgoingMessageBottomLabelAlignment.textInsets.right = 12
        }
    }
    
    func configureMessageInputBar() {
        slackInputBar.slackDelegate = self
        slackInputBar.delegate = self
    }

    func insertMessage(_ message: Message) {
        messageList.append(message)
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messageList.count - 1])
            if messageList.count >= 2 {
                messagesCollectionView.reloadSections([messageList.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        })
    }

    func isLastSectionVisible() -> Bool {
        guard !messageList.isEmpty else { return false }
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
}

extension MessageController: MessagesDataSource, MessageCellDelegate, InputBarAccessoryViewDelegate, MessagesDisplayDelegate, MessagesLayoutDelegate, SlackInputBarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - MessagesDataSource

    func currentSender() -> SenderType {
        return currentUser
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }

    // MARK: - MessagesDisplayDelegate

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if message.sender.senderId == currentSender().senderId {
            avatarView.isHidden = true
        } else {
            avatarView.backgroundColor = .red
        }
    }

    // MARK: - SlackInputBarDelegate

    func slackInputBar(_ view: SlackInputBar, didTapCameraButton button: InputBarButtonItem) {
        print("Show camera")
    }

    func slackinputBar(_ view: SlackInputBar, didTapLibraryButton button: InputBarButtonItem) {
        let pickerVC = UIImagePickerController()
        pickerVC.sourceType = .photoLibrary
        pickerVC.modalPresentationStyle = .fullScreen
        pickerVC.delegate = self
        pickerVC.allowsEditing = true
        viewController?.present(pickerVC, animated: true, completion: nil)
    }

    // MARK: - InputBarAccessoryViewDelegate

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        processInputBar(slackInputBar)
    }

    func processInputBar(_ inputBar: InputBarAccessoryView) {
        // Here we can parse for which substrings were autocompleted
        let attributedText = inputBar.inputTextView.attributedText!
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { _, range, _ in

            let substring = attributedText.attributedSubstring(from: range)
            let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
            print("Autocompleted: `", substring, "` with context: ", context ?? [])
        }

        let components = inputBar.inputTextView.components
        inputBar.inputTextView.text = String()
        inputBar.invalidatePlugins()
        // Send button activity animation
        inputBar.sendButton.startAnimating()
        inputBar.inputTextView.placeholder = "Sending..."
        // Resign first responder for iPad split view
        inputBar.inputTextView.resignFirstResponder()
        DispatchQueue.global(qos: .default).async {
            // fake send request task
            sleep(1)
            DispatchQueue.main.async { [weak self] in
                inputBar.sendButton.stopAnimating()
                inputBar.inputTextView.placeholder = "Aa"
                self?.insertMessages(components)
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }

    private func insertMessages(_ data: [Any]) {
        for object in data {
            if let text = object as? String {
                let message = Message(sender: currentUser, messageId: String(Int.random(in: 0 ..< 100)), sentDate: Date(), text: text)
                insertMessage(message)
            } else if let image = object as? UIImage {
                let message = Message(sender: currentUser, messageId: String(Int.random(in: 0 ..< 100)), sentDate: Date(), image: image)
                insertMessage(message)
            }
        }
    }

    // MARKL - UIImagePickerControllerDelegate

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            let message = Message(sender: self.currentUser, messageId: String(Int.random(in: 0 ..< 100)), sentDate: Date(), image: image)
            self.insertMessage(message)
        }
    }
}

