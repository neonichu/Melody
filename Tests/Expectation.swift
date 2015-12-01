import Foundation
import Spectre

class Expectation {
  let timeoutInterval: NSTimeInterval
  let pollInterval: NSTimeInterval = 0.5
  var fulfilled = false

  init(timeoutInterval: NSTimeInterval = 10) {
    self.timeoutInterval = timeoutInterval
  }

  func fulfil() {
    fulfilled = true
  }

  func wait() throws {
    let runLoop = NSRunLoop.mainRunLoop()
    let startDate = NSDate()
    repeat {
      if fulfilled {
        break
      }

      let runDate = NSDate().dateByAddingTimeInterval(pollInterval)
      runLoop.runUntilDate(runDate)
    } while(NSDate().timeIntervalSinceDate(startDate) < timeoutInterval)

    if !fulfilled {
      throw failure("Expectation was not fulfilled")
    }
  }
}
