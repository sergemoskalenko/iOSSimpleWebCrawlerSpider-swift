//
//  MSVSimpleWebCrawlerSpiderItem.swift
//  iOSSimpleWebCrawlerSpider
//
//  Created by Serge Moskalenko on 03.05.16.
//  Copyright (c) 2016 Serge Moskalenko. All rights reserved.
//
import Foundation
enum MSVSimpleWebCrawlerSpiderItemStatus : Int {
    case Wait
    case InWork
    case NotFound
    case Found
    case Error
}

class MSVSimpleWebCrawlerSpiderItem: NSObject {
    var urlString: String = ""
    var statusError: String = ""
    var status: MSVSimpleWebCrawlerSpiderItemStatus = .Wait
    var numberResult: Int = 0
    var level: Int = 0
    
    override init() {
    }
    deinit {
    }
}

