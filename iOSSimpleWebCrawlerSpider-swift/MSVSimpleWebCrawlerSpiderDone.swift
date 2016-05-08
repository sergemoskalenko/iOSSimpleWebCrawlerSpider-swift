//
//  MSVSimpleWebCrawlerSpiderDone.swift
//  iOSSimpleWebCrawlerSpider
//
//  Created by Serge Moskalenko on 03.05.16.
//  Copyright (c) 2016 Serge Moskalenko. All rights reserved.
//
import Foundation
class MSVSimpleWebCrawlerSpiderDone: NSObject {
    weak var delegate: AnyObject?

    override init() {
    }
    deinit {
    }
    
    func done() {
        if self.delegate!.respondsToSelector(Selector("doneLevels")) {
            self.delegate!.performSelectorOnMainThread(Selector("doneLevels"), withObject: nil, waitUntilDone: false)
        }
    }
}

