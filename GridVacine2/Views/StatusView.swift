//
//  StatusView.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/22/21.
//

import SwiftUI

struct StatusView: View {
    @ObservedObject var checker: GridChecker
    
    var body: some View {
        VStack {
            HStack {
                GridSizeView(size: checker.size)
                Spacer()
                GridSearchStatusView(checker: checker)
            }
            ElapsedTimeView(checker: checker)
            PairBatchesView(checker: checker)
        }.padding(10)
    }
}
