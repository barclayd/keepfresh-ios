import Models
import Network
import Notifications
import UIKit
import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    let api = KeepFreshAPI()
    
    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void)
    {
        self.contentHandler = contentHandler
        self.bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let bestAttemptContent else {
            contentHandler(request.content)
            return
        }
        
        Task {
            await processNotification(
                request: request,
                bestAttemptContent: bestAttemptContent,
                contentHandler: contentHandler)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler, let bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    private func processNotification(
        request: UNNotificationRequest,
        bestAttemptContent: UNMutableNotificationContent,
        contentHandler: @escaping (UNNotificationContent) -> Void) async
    {
        let userInfo = request.content.userInfo
        
        if
            let statusString = userInfo["status"] as? String,
            let status = InventoryItemStatus(rawValue: statusString)
        {
            let category = NotificationActions.createCategory(
                status: status,
                hasOpenedExpiryDate: userInfo["openedExpiryDate"] as? String != nil,
                suggestions: userInfo["suggestions"] as? [String] ?? [])
            
            UNUserNotificationCenter.current().setNotificationCategories([category])
            bestAttemptContent.categoryIdentifier = category.identifier
        }
        
        guard let genmojiId = userInfo["genmojiId"] as? String else {
            contentHandler(bestAttemptContent)
            return
        }
        
        do {
            let response = try await api.getGenmoji(name: genmojiId)
            
            guard let imageData = response.imageContentData else {
                throw NSError(domain: "Genmoji", code: -1, userInfo: nil)
            }
            
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent("\(genmojiId).png")
            try imageData.write(to: fileURL)
            
            let attachment = try UNNotificationAttachment(
                identifier: "genmoji",
                url: fileURL,
                options: [UNNotificationAttachmentOptionsTypeHintKey: "public.png"])
            
            bestAttemptContent.attachments = [attachment]
            
            contentHandler(bestAttemptContent)
            
        } catch {
            contentHandler(bestAttemptContent)
        }
    }
}
