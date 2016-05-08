//
//  MSVSimpleWebCrawlerSpiderLoader.swift
//  iOSSimpleWebCrawlerSpider
//
//  Created by Serge Moskalenko on 03.05.16.
//  Copyright (c) 2016 Serge Moskalenko. All rights reserved.
//
import Foundation
typealias MSVSimpleWebCrawlerSpiderLoaderHandler = (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void
class MSVSimpleWebCrawlerSpiderLoader: NSObject {
    weak var operationQueue: NSOperationQueue?
    {
        get {
            return self.session?.delegateQueue
        }
    }
    
    weak var session: NSURLSession?
    {
        get {
            return NSURLSession.sharedSession()
        }
    }
    
    override init() {
    }
    deinit {
    }
    
    class func sharedLoader() -> MSVSimpleWebCrawlerSpiderLoader {
        var loader:MSVSimpleWebCrawlerSpiderLoader {
            struct Static {
                static var token:dispatch_once_t = 0;
                static var instansce: MSVSimpleWebCrawlerSpiderLoader? = nil
            }
            dispatch_once(&Static.token, { () -> Void in
                Static.instansce = MSVSimpleWebCrawlerSpiderLoader()
            })
            return Static.instansce!
        }
        return loader;
    }

    func addRequest(request: NSURLRequest, withHandler requestHandler: MSVSimpleWebCrawlerSpiderLoaderHandler) {        
        // let session: NSURLSession = NSURLSession.sharedSession()
        let task: NSURLSessionDataTask = self.session!.dataTaskWithRequest(request, completionHandler: {(data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                requestHandler(response: response, data: data, error: error)
            })
        task.resume()
    }
}

