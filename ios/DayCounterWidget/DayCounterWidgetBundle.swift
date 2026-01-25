//
//  DayCounterWidgetBundle.swift
//  DayCounterWidget
//
//  Created by Kihoonee Bang on 1/25/26.
//

import WidgetKit
import SwiftUI

@main
struct DayCounterWidgetBundle: WidgetBundle {
    var body: some Widget {
        DayCounterWidget()
        DayCounterWidgetControl()
    }
}
