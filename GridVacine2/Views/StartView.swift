//
//  StartView.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/23/21.
//

import SwiftUI

struct StartView: View {
    @ObservedObject var seeker: Seeker
    @State var gridSize: Int = 0
    @State var mode: Mode = .starting
    
    var body: some View {
        if(mode == .starting) {
            VStack{
                Spacer()
                HStack {
                    Spacer()
                    FindAntiVaxBotLocationsView(seeker: seeker, mode: $mode, gridSize: $gridSize)
                    Spacer()
                    SeekInvalidGridSize(seeker: seeker, mode: $mode)
                    Spacer()
                }
                Spacer()
            }
        } else if(mode == .seeking) {
            VStack {
                Spacer()
                HeaderView(checker: seeker.checker)
                ResultsView(results: seeker.results)
                Spacer()
            }
        } else if(mode == .finding) {
            VStack {
                Spacer()
                HeaderView(checker: seeker.checker)
                ValidPairsView(checker: seeker.checker)
                Button(action: {
                    seeker.checker.copyResultsToClipboard()
                }, label: {
                    Text("Copy")
                })
                Spacer()
            }
        }
    }
    
    enum Mode {
        case starting, finding, seeking
    }
}

struct FindAntiVaxBotLocationsView: View {
    var seeker: Seeker
    @Binding var mode: StartView.Mode
    @Binding var gridSize: Int
    @State var sizeText: String = ""
    
    var body: some View {
        VStack {
            VStack {
                Text("Find All").bold().font(.callout)
                Text("AntiVax Bot").bold().font(.callout)
                Text("Location Pairs").bold().font(.callout)
                VStack(alignment: .trailing, spacing: 5) {
                    HStack(spacing: 5) {
                        Text("Grid Size:")
                        TextField("", text: $sizeText).frame(maxWidth: 50)
                    }
                    Button(action: {
                        guard let size = Int(sizeText) else { return }
                        mode = .finding
                        gridSize = size
                        seeker.run(findLocationsInGrid: gridSize)
                    }, label: {
                        Text("Start")
                    })
                }
            }.padding(5).frame(width: 200, height: 200, alignment: .center)
        }.border(Color.black, width: 2).padding(10)
    }
}

struct SeekInvalidGridSize: View {
    var seeker: Seeker
    @Binding var mode: StartView.Mode
    
    var body: some View {
        VStack {
            VStack {
                VStack(spacing: 10) {
                    Text("Seek Grid With").bold().font(.callout)
                    Text("No Valid AntiVax Bot").bold().font(.callout)
                    Text("Location Pairs").bold().font(.callout)
                }
                Button(action: {
                    mode = .seeking
                    seeker.run()
                }, label: {
                    Text("Start")
                })
            }.padding(5).frame(width: 200, height: 200, alignment: .center)
        }.border(Color.black, width: 2).padding(10).padding(10)
    }
    
    
}
