//
//  HeaderView.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/22/21.
//

import SwiftUI

struct HeaderView: View {
    @ObservedObject var checker: GridChecker
    
    var body: some View {
        VStack {
            if(checker.settingUp) {
                GridLoadingView(checker: checker)
            } else {
                StatusView(checker: checker)
            }
        }.frame(height: 300)
    }
}

