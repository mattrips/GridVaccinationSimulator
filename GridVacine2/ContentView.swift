//
//  ContentView.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/2/21.
//

import SwiftUI

struct ContentView: View {
    var seeker: Seeker
    
    var body: some View {
        StartView(seeker: seeker)
            .frame(width: 700, height: 600, alignment: .center)
    }
}
