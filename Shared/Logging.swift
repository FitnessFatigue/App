//
//  Logging.swift
//  Intervals (iOS)
//
//  Created by Matthew Roche on 23/11/2021.
//

import Foundation
import os

private let subsystem = "com.matthewroche.intervals"

struct Log {
  static let table = OSLog(subsystem: subsystem, category: "table")
}
