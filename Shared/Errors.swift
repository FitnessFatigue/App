//
//  Errors.swift
//  intervals
//
//  Created by Matthew Roche on 08/11/2021.
//

import Foundation

// A queue to store our errors and ensure one displayed at a time
class ErrorQueue: Equatable {
    
    // The queue
    private var queue: [AppError] = []
    
    // Adding errors
    func append(_ error: Error) {
        queue.append(AppError(error))
        print(self.queue)
    }
    
    // Producing errors
    func next() -> AppError? {
        guard queue.count > 0 else {
            return nil
        }
        return queue.removeFirst()
    }
    
    // Compare queues
    static func == (lhs: ErrorQueue, rhs: ErrorQueue) -> Bool {
        return lhs.queue == rhs.queue
    }
    
}
