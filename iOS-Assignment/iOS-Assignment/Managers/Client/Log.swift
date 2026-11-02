//
//  Log.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import XCGLogger

let log: XCGLogger = {
    let log = XCGLogger.default
    #if DEBUG
    log.setup(level: .debug, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true)
    #else
    log.setup(level: .warning, showThreadName: false, showLevel: true, showFileNames: false, showLineNumbers: false)
    #endif
    return log
}()
