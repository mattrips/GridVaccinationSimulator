//
//  AppDelegate.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/2/21.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var seeker = Seeker()
    var tempChecker = GridChecker(size: 1001, findAll: false, searchState: nil, useLocalEndpoint: false)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView(seeker: seeker)

        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        tempChecker.run(findAll: false)
        print("setup complete")
        //postRequest.postTasks(size: 244, xCoordinate: 0, yRange: 0..<244)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
