//
//  MSVSimpleWebCrawlerSpiderLevelManager.swift
//  iOSSimpleWebCrawlerSpider
//
//  Created by Serge Moskalenko on 03.05.16.
//  Copyright (c) 2016 Serge Moskalenko. All rights reserved.
//
import Foundation
class MSVSimpleWebCrawlerSpiderLevelManager: NSObject {
    var operationQueue: NSOperationQueue
    
    var maxLevel: Int = 0
    weak var delegate: AnyObject?

    override init() {
        self.operationQueue = NSOperationQueue()
        self.operationQueue.maxConcurrentOperationCount = 1
    }
    deinit {
        
    }
    
    func runLevels(maxLevel: Int) {
        weak var weakSelf: MSVSimpleWebCrawlerSpiderLevelManager? = self
        var operationOld: NSBlockOperation? = nil
        for i in 1 ..< maxLevel + 1 {
            let operation: NSBlockOperation = NSBlockOperation(block: {() -> Void in
                    let oneLevel: MSVSimpleWebCrawlerSpiderLevel = MSVSimpleWebCrawlerSpiderLevel()
                    oneLevel.delegate = weakSelf!.delegate
                    oneLevel.operationQueue = weakSelf!.operationQueue
                    oneLevel.runLevel(i)
                })
            if operationOld != nil {
                operation.addDependency(operationOld!)
            }
            operationOld = operation
            operationQueue.addOperation(operation)
        }
        let operation: NSBlockOperation = NSBlockOperation(block: {() -> Void in
                MSVSimpleWebCrawlerSpiderModel.sharedModel().performSelectorOnMainThread(Selector("doneLevels"), withObject: nil, waitUntilDone: false)
                // [[MSVSimpleWebCrawlerSpiderModel sharedModel] doneLevels];
            })
        if operationOld != nil {
            operation.addDependency(operationOld!)
        }
        operationQueue.addOperation(operation)
    }
}

