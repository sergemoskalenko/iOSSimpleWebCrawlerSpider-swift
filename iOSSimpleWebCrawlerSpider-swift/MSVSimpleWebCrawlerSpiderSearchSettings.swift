//
//  MSVSimpleWebCrawlerSpiderSearchSettings.swift
//  iOSSimpleWebCrawlerSpider
//
//  Created by Serge Moskalenko on 03.05.16.
//  Copyright (c) 2016 Serge Moskalenko. All rights reserved.
//
import Foundation
class MSVSimpleWebCrawlerSpiderSearchSettings: NSObject {
    private var _urlStartString: String? = nil
    var urlStartString: String {
        get {
            return self._urlStartString!
        }
        set(urlStartStringNew) {
            // test & correct if need
            self._urlStartString = urlStartStringNew
        }
    }

    private var _searchedString: String? = nil
    var searchedString: String {
        get {
            return self._searchedString!
        }
        set(searchedStringNew) {
            // test & correct if need
            self._searchedString = searchedStringNew
        }
    }

    var _maxResults: Int = 0
    var maxResults: Int {
        get {
            return self._maxResults
        }
        set(maxResultsNew) {
            var value: Int = maxResultsNew
            if value > 500 {
                value = 500
            }
            if value < 1 {
                value = 1
            }
            self._maxResults = value
        }
    }

    var _maxDeep: Int = 0
    var maxDeep: Int {
        get {
            return self._maxDeep
        }
        set(maxDeepNew) {
            var value: Int = maxDeepNew
            if value > 5 {
                value = 5
            }
            if value < 1 {
                value = 1
            }
            self._maxDeep = value
        }
    }

    var _maxFlow: Int = 0
    var maxFlow: Int {
        get {
            return self._maxFlow
        }
        set(maxFlowNew) {
            var value: Int = maxFlowNew
            if value > 8 {
                value = 8
            }
            if value < 1 {
                value = 1
            }
            self._maxFlow = value
        }
    }
}

