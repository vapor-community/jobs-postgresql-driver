import XCTest

import JobsRedisDriverTests

var tests = [XCTestCaseEntry]()
tests += JobsPostgreSQLDriverTests.allTests()
XCTMain(tests)