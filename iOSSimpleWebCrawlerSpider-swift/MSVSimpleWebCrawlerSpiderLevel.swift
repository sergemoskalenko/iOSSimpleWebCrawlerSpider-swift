//
//  MSVSimpleWebCrawlerSpiderLevel.swift
//  iOSSimpleWebCrawlerSpider
//
//  Created by Serge Moskalenko on 03.05.16.
//  Copyright (c) 2016 Serge Moskalenko. All rights reserved.
//
import Foundation
class MSVSimpleWebCrawlerSpiderLevel: NSObject {
    weak var operationQueue: NSOperationQueue?
    weak var delegate: AnyObject?
    var requestsCount: NSInteger = 0
    
    override init() {
    }
    deinit {
        
    }
    
    func runLevel(level: Int) {
        // self.operationQueue!.suspended = true
        
        self.requestsCount = 0
        weak var weakSelf_: MSVSimpleWebCrawlerSpiderLevel? = self
        let searchedString: String = MSVSimpleWebCrawlerSpiderModel.sharedModel().searchSettings.searchedString
        let items: [AnyObject] = MSVSimpleWebCrawlerSpiderModel.sharedModel().itemsArrayForLevel(level)
        for item: MSVSimpleWebCrawlerSpiderItem in items as! [MSVSimpleWebCrawlerSpiderItem] {
            while self.requestsCount >= MSVSimpleWebCrawlerSpiderModel.sharedModel().searchSettings.maxFlow {
                NSThread.sleepForTimeInterval(0.1)
            }
            weak var itemWeak: MSVSimpleWebCrawlerSpiderItem? = item
                // NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:item.urlString]];
            let url : NSURL? = NSURL(string: item.urlString)
            if url == nil {
                item.status = .Error
                item.statusError = "Invalid URL"
                continue
            }
            
            let request: NSURLRequest? = NSURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 5)
            
            //print ("\(request?.timeoutInterval)")
            
            if request == nil {
                item.status = .Error
                item.statusError = "Invalid URL"
                continue
            }
            
            // 5 sec for page
            MSVSimpleWebCrawlerSpiderLoader.sharedLoader().addRequest(request!, withHandler: {(response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                
                let weakSelf: MSVSimpleWebCrawlerSpiderLevel! = weakSelf_
                
                if error != nil {
                    itemWeak!.statusError = error!.localizedDescription
                    itemWeak!.status = .Error
                }
                else {
                    var htmlString: String? = String(data: data!, encoding: NSUTF8StringEncoding)
                    if htmlString == nil {
                        htmlString = ""
                    }
                        // 1
                    let components: [String] = htmlString!.componentsSeparatedByString(searchedString)
                    itemWeak!.numberResult = Int(components.count) - 1
                    if itemWeak!.numberResult > 0 {
                        itemWeak!.status = .Found
                        MSVSimpleWebCrawlerSpiderModel.sharedModel().currentInfo.foundCount += itemWeak!.numberResult
                    }
                    else {
                        itemWeak!.status = .NotFound
                    }
                    
                    if MSVSimpleWebCrawlerSpiderModel.sharedModel().items.count < MSVSimpleWebCrawlerSpiderModel.sharedModel().searchSettings.maxResults {
                        // 2
                        var regex: NSRegularExpression
                        do {
                            regex = try NSRegularExpression(pattern: "<a.+?href=\"([^\"]+)", options: .CaseInsensitive)
                            
                            var arrayOfAllMatches: [NSTextCheckingResult]? = nil
                            if htmlString != "" && htmlString != nil {
                                arrayOfAllMatches = regex.matchesInString(htmlString!, options: [], range: NSMakeRange(0, htmlString!.characters.count))
                            
                            print ("\(arrayOfAllMatches?.count)")
                                
                            var i : Int = 0
                            for match: NSTextCheckingResult in arrayOfAllMatches! {
                                if MSVSimpleWebCrawlerSpiderModel.sharedModel().items.count >= MSVSimpleWebCrawlerSpiderModel.sharedModel().searchSettings.maxResults {
                                    continue
                                }
                                
                                i += 1
                                
                                // print ("i:\(i) - \(match)")
                                
                                let range = htmlString!.startIndex.advancedBy(match.range.location) ..< htmlString!.startIndex.advancedBy(match.range.location + match.range.length)
                                var substringForMatch: String = htmlString!.substringWithRange(range)
                                
                                let r:Range? = substringForMatch.rangeOfString("href=", options: NSStringCompareOptions.CaseInsensitiveSearch)
                                
                                if r != nil
                                {
                                    let r2:Range = substringForMatch.startIndex ..< r!.endIndex
                                    [substringForMatch .removeRange(r2)]
                                    
                                    substringForMatch = substringForMatch.stringByReplacingOccurrencesOfString("\"", withString: "")
                                    substringForMatch = substringForMatch.stringByReplacingOccurrencesOfString("https://", withString: "https://", options: NSStringCompareOptions.CaseInsensitiveSearch)
                                    substringForMatch = substringForMatch.stringByReplacingOccurrencesOfString("http://", withString: "http://", options: NSStringCompareOptions.CaseInsensitiveSearch)
                                }
                                
                                var newUrl: String? = substringForMatch
                                if newUrl != "" && newUrl != nil {
                                    if !newUrl!.containsString("http://") && !newUrl!.containsString("https://") {
                                        
                                        let urlBase : NSURL? = NSURL(string: itemWeak!.urlString)!
                                        if (urlBase != nil)
                                        {
                                            let url : NSURL? = NSURL(string: newUrl!, relativeToURL: urlBase)
                                            
                                            if url != nil {
                                                newUrl = url?.absoluteString
                                            } else {
                                             newUrl = ""
                                            }
                                        }
                                        else
                                        {
                                            newUrl = ""
                                        }
                                    }
                                    if newUrl != "" {
                                        // print("!!!")
                                        if MSVSimpleWebCrawlerSpiderModel.sharedModel().items.count < MSVSimpleWebCrawlerSpiderModel.sharedModel().searchSettings.maxResults {
                                            MSVSimpleWebCrawlerSpiderModel.sharedModel().appendItemWithURLString(newUrl!, level: level + 1)
                                        }
                                        
                                        NSOperationQueue.mainQueue().addOperationWithBlock({() -> Void in
                                        if weakSelf!.delegate!.respondsToSelector(Selector("newItem")) {
                                            weakSelf!.delegate!.performSelectorOnMainThread(Selector("newItem"), withObject: nil, waitUntilDone: false)
                                        }
                                        })
                                    }
                                }

                            }
                        }
                        } catch let error as NSError {
                            print(error.localizedDescription)
                            
                            item.status = .Error
                            item.statusError = error.localizedDescription // "Invalid URL"
                        }
                    }
                }
                
                weakSelf.requestsCount -= 1
                MSVSimpleWebCrawlerSpiderModel.sharedModel().currentInfo.flowCount = (MSVSimpleWebCrawlerSpiderLoader.sharedLoader().operationQueue?.operations.count)! // weakSelf!.requestsCount
                MSVSimpleWebCrawlerSpiderModel.sharedModel().currentInfo.viewCount += 1
                
                if self.requestsCount == 0 {
                    weakSelf!.operationQueue!.suspended = false
                }

                NSOperationQueue.mainQueue().addOperationWithBlock({() -> Void in
                    if weakSelf!.delegate!.respondsToSelector(Selector("downloadedItem")) {
                        weakSelf!.delegate!.performSelectorOnMainThread(Selector("downloadedItem"), withObject: nil, waitUntilDone: false)
                    }
                })
            })
            self.requestsCount += 1
            MSVSimpleWebCrawlerSpiderModel.sharedModel().currentInfo.flowCount = (MSVSimpleWebCrawlerSpiderLoader.sharedLoader().operationQueue?.operations.count)! // weakSelf!.requestsCount
        }
        if items.count != 0 {
            self.operationQueue!.suspended = true
        }
    }
}

