//
//  XCTestManifests.swift
//  KryptonTests
//
//  Copyright © 2019-2023 Farhan Ahmed. All rights reserved.
//

import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry]
    {
        return [
            testCase(KryptonTests.allTests),
            testCase(KryptonEventTests.allTests),
        ]
    }
#endif
