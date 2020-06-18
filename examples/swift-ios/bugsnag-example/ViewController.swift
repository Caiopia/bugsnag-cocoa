// Copyright (c) 2016 Bugsnag, Inc. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall remain in place
// in this source code.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import Bugsnag

class ViewController: UITableViewController {

    @IBAction func generateUncaughtException(_ sender: AnyObject) {
        
        
        let onSendErrorBlock1: BugsnagOnSendErrorBlock = { (event) -> Bool in
            NSLog("Bugsnag: Callback 1")
            event.addMetadata(["Dog" : "Lilly"],
                              section: "ConfiguredMetadata")
            return true
        }
        let onSendErrorBlock2: BugsnagOnSendErrorBlock = { (event) -> Bool in
            NSLog("Bugsnag: Callback 2")
            event.addMetadata(["Dog" : "Rufey"],
                              section: "ConfiguredMetadata")
            return true
        }
        let onSendErrorBlock3: BugsnagOnSendErrorBlock = { (event) -> Bool in
            NSLog("Bugsnag: Callback 3")
            event.addMetadata(["Dog" : "Basil"],
                              section: "ConfiguredMetadata")
            return true
        }

        NSLog("Bugsnag: Adding callback 1")
        Bugsnag.addOnSendError(block: onSendErrorBlock1)
        NSLog("Bugsnag: Adding callback 1")
        Bugsnag.addOnSendError(block: onSendErrorBlock2)
        NSLog("Bugsnag: Adding callback 1")
        Bugsnag.addOnSendError(block: onSendErrorBlock3)
        
        NSLog("Bugsnag: About to crash!")
        let someJson : Dictionary = ["foo":self]
        do {
            let data = try JSONSerialization.data(withJSONObject: someJson, options: .prettyPrinted)
            print("Received data: %@", data)
        } catch {
            // Why does this crash the app? A very good question.
        }
    }

    @IBAction func generatePOSIXSignal(_ sender: Any) {
        AnObjCClass().trap()
    }

    @IBAction func generateStackOverflow(_ sender: Any) {
        let items = ["Something!"]

        if sender is ViewController || sender is UIButton {
            generateStackOverflow(self)
        }

        print("items: %@", items)
    }

    @IBAction func generateMemoryCorruption(_ sender: Any) {
        AnObjCClass().corruptSomeMemory()
    }

    @IBAction func generateAssertionFailure(_ sender: Any) {
        AnotherClass.crash3()
    }

    @IBAction func sendAnError(_ sender: Any) {

        let onSendErrorBlock1: BugsnagOnSendErrorBlock = { (event) -> Bool in
            NSLog("Bugsnag: Callback 1")
            event.addMetadata(["Dog" : "Lilly"],
                              section: "ConfiguredMetadata")
            return true
        }
        let onSendErrorBlock2: BugsnagOnSendErrorBlock = { (event) -> Bool in
            NSLog("Bugsnag: Callback 2")
            event.addMetadata(["Dog" : "Rufey"],
                              section: "ConfiguredMetadata")
            return true
        }
        let onSendErrorBlock3: BugsnagOnSendErrorBlock = { (event) -> Bool in
            NSLog("Bugsnag: Callback 3")
            event.addMetadata(["Dog" : "Basil"],
                              section: "ConfiguredMetadata")
            return true
        }

        Bugsnag.addOnSendError(block: onSendErrorBlock1)
        Bugsnag.addOnSendError(block: onSendErrorBlock2)
        Bugsnag.addOnSendError(block: onSendErrorBlock3)

        do {
            try FileManager.default.removeItem(atPath:"//invalid/file")
        } catch {
            Bugsnag.notifyError(error) { event in
                // modify report properties in the (optional) block
                event.severity = .info
                return true
            }
        }
    }
}
