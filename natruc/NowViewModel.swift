//
//  NowViewModel.swift
//  natruc
//
//  Created by Jiri Dutkevic on 19/07/15.
//  Copyright (c) 2015 Jiri Dutkevic. All rights reserved.
//

import Foundation

internal enum Progress {
    case NotLoaded
    case NotStarted
    case Progress(ProgramItem, ProgramItem, ProgramItem)
    case Ended
}

internal final class NowViewModel {

    private let model: Model
    private var items: [[ProgramItem]]
    private var start: NSDate?
    private var end: NSDate?

    internal var dataChanged: (Void -> Void)?

    internal init(model: Model) {

        self.model = model

        if let items = model.program, start = model.start, end = model.end {

            self.items = items
            self.start = start
            self.end = end

            if let dc = dataChanged {
                dc()
            }

        } else {

            items = [[ProgramItem]]()
            start = .None
            end = .None

            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("dataLoaded"), name: model.DataLoadedNotification, object: model)
        }
    }

    @objc func dataLoaded() {

        NSNotificationCenter.defaultCenter().removeObserver(self, name: model.DataLoadedNotification, object: model)

        if let items = model.program, start = model.start, end = model.end {

            self.items = items
            self.start = start
            self.end = end

            if let dc = dataChanged {
                dc()
            }
            
        }
    }

    internal func state() -> Progress {

        if items.count == 3 {

            let now = Components.shared.now().timeIntervalSince1970
            let start = self.start!
            let end = self.end!

            if now < start.timeIntervalSince1970 {

                return .NotStarted

            } else if now > end.timeIntervalSince1970 {

                return .Ended

            } else {

                var s1 = currentBand(0)!
                var s2 = currentBand(1)!
                var s3 = currentBand(2)!

                return .Progress(s1, s2, s3)
            }

        } else {

            return .NotLoaded
        }
    }

    internal func currentBand(stage: Int) -> ProgramItem? {

        let now = Components.shared.now().timeIntervalSince1970

        var band: ProgramItem?
        for i in items[stage] {
            if i.end.timeIntervalSince1970 > now {
                band = i
                break
            }
        }

        return band
    }
}
