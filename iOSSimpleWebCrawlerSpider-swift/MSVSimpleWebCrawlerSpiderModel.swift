//
//  MSVSimpleWebCrawlerSpiderModel.swift
//  iOSSimpleWebCrawlerSpider
//
//  Created by Serge Moskalenko on 03.05.16.
//  Copyright (c) 2016 Serge Moskalenko. All rights reserved.
//
import Foundation
enum MSVSimpleWebCrawlerSpiderCurrentStatus : Int {
    case None
    case InWork
    case Suspended
    case Stopped
    case Done
}

class MSVSimpleWebCrawlerSpiderModel: NSObject {
    var searchSettings: MSVSimpleWebCrawlerSpiderSearchSettings
    var currentInfo: MSVSimpleWebCrawlerSpiderCurrentInfo
    var items: [MSVSimpleWebCrawlerSpiderItem]
    var levelManager: MSVSimpleWebCrawlerSpiderLevelManager
    var levelOperationSuspended: Bool = false
    var urls : Set = Set<String>()

    private var _currentStatus:MSVSimpleWebCrawlerSpiderCurrentStatus = .None
    var currentStatus: MSVSimpleWebCrawlerSpiderCurrentStatus {
        get {
            return _currentStatus
        }
        set(currentStatusNew) {
            self.willChangeValueForKey("currentStatus")
            _currentStatus = currentStatusNew
            self.didChangeValueForKey("currentStatus")
        }
    }

    weak var delegate: AnyObject?

    override init() {
        self.searchSettings = MSVSimpleWebCrawlerSpiderSearchSettings()
        self.currentInfo = MSVSimpleWebCrawlerSpiderCurrentInfo()
        self.levelManager = MSVSimpleWebCrawlerSpiderLevelManager()
        self.items = [MSVSimpleWebCrawlerSpiderItem]() as [MSVSimpleWebCrawlerSpiderItem]
    }
    deinit {
        
    }
    
    class func sharedModel() -> MSVSimpleWebCrawlerSpiderModel {
        var shared:MSVSimpleWebCrawlerSpiderModel {
            struct Static {
                static var token:dispatch_once_t = 0;
                static var instansce: MSVSimpleWebCrawlerSpiderModel? = nil
            }
            dispatch_once(&Static.token, { () -> Void in
                Static.instansce = MSVSimpleWebCrawlerSpiderModel()
            })
            return Static.instansce!
        }
        return shared;
    }

    func itemsArrayForLevel(level: Int) -> [AnyObject] {
        var result: [AnyObject] = NSMutableArray() as [AnyObject]
        for item: MSVSimpleWebCrawlerSpiderItem in self.items {
            if item.level == level {
                result.append(item)
            }
        }
        return result
    }

    func appendItem(item: MSVSimpleWebCrawlerSpiderItem) {
        let lockQueue = dispatch_queue_create("com.test.LockQueue", nil)
        dispatch_sync(lockQueue) {
            if self.items.count < self.searchSettings.maxResults {
                var notExists: Bool = true
                let urlString: String = item.urlString
                for item: MSVSimpleWebCrawlerSpiderItem in self.items as! [MSVSimpleWebCrawlerSpiderItem] {
                    if (item.urlString == urlString) {
                        notExists = false
                    }
                }
                if notExists {
                    self.urls.insert(item.urlString)
                    self.items.append(item)
                }
            }
        }
    }

    func appendItemWithURLString(urlString: String, level: Int) {
        if self.urls.contains(urlString) {
            return
        }
        let item: MSVSimpleWebCrawlerSpiderItem = MSVSimpleWebCrawlerSpiderItem()
        item.urlString = urlString
        item.level = level
        self.appendItem(item)
    }

    func start() {
        if self.currentStatus == .None || self.currentStatus == .Stopped || self.currentStatus == .Done {
            self.currentInfo.viewCount = 0
            self.currentInfo.foundCount = 0
            self.items.removeAll()
            MSVSimpleWebCrawlerSpiderLoader.sharedLoader().operationQueue!.maxConcurrentOperationCount = self.searchSettings.maxFlow
            let item: MSVSimpleWebCrawlerSpiderItem = MSVSimpleWebCrawlerSpiderItem()
            item.urlString = self.searchSettings.urlStartString
            item.level = 1
            items.append(item)
            self.levelManager = MSVSimpleWebCrawlerSpiderLevelManager()
            self.levelManager.delegate = delegate!
            levelManager.runLevels(self.searchSettings.maxDeep)
            self.currentStatus = .InWork
        }
    }

    func pause() {
        self.levelOperationSuspended = self.levelManager.operationQueue.suspended
        self.levelManager.operationQueue.suspended = true
        MSVSimpleWebCrawlerSpiderLoader.sharedLoader().operationQueue!.suspended = true
        self.currentStatus = .Suspended
    }

    func resume() {
        MSVSimpleWebCrawlerSpiderLoader.sharedLoader().operationQueue!.maxConcurrentOperationCount = self.searchSettings.maxFlow
        MSVSimpleWebCrawlerSpiderLoader.sharedLoader().operationQueue!.suspended = false
        self.levelManager.operationQueue.suspended = self.levelOperationSuspended
        self.currentStatus = .InWork
    }

    func stop() {
        self.searchSettings.maxFlow = 0
        levelManager.operationQueue.cancelAllOperations()
        MSVSimpleWebCrawlerSpiderLoader.sharedLoader().operationQueue!.cancelAllOperations()
        let session: NSURLSession = NSURLSession.sharedSession()
        session.delegateQueue.cancelAllOperations()
        self.currentStatus = .Stopped
    }

    func doneLevels() {
        self.currentStatus = .Done
    }
}

