//
//  ValidPairsView.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/23/21.
//

import SwiftUI

struct ValidPairsView: View {
    @ObservedObject var checker: GridChecker
    
    var body: some View {
        List {
            ForEach(checker.validPairs.reversed()) { pair in
                Text(pair.description)
            }
        }.animation(.default)
    }
}
