//
//  ResultsView.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/22/21.
//

import SwiftUI

struct ResultsView: View {
    var results: Seeker.CheckResults
    
    var body: some View {
        List {
            ForEach(results.data.reversed()) { result in
                Text(result.description)
            }
        }.animation(.default)
    }
}
