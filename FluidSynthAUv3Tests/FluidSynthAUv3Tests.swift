// Copyright © 2023 Brad Howes. All rights reserved.

import XCTest
@testable import FluidSynthAUv3

class FluidSynthAUv3Tests: XCTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testLoad0() throws {
    let z = FluidSynthBridge()
    let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 48000.0, channels: 2, interleaved: false)!
    z.setRenderingFormat(1, format: format, maxFramesToRender: 512)
    let url = getResourceUrl(index: 0)
    XCTAssertTrue(z.load(url))
    XCTAssertEqual(235, z.presets.count)
    XCTAssertEqual(0, z.presets[0].bank)
    XCTAssertEqual(0, z.presets[0].program)
    XCTAssertEqual("Piano 1", z.presets[0].name)
    XCTAssertEqual(0, z.presets[1].bank)
    XCTAssertEqual(1, z.presets[1].program)
    XCTAssertEqual("Piano 2", z.presets[1].name)
    XCTAssertEqual(128, z.presets[234].bank)
    XCTAssertEqual(56, z.presets[234].program)
    XCTAssertEqual("SFX", z.presets[234].name)
  }

  func testLoad1() throws {
    let z = FluidSynthBridge()
    let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 48000.0, channels: 2, interleaved: false)!
    z.setRenderingFormat(1, format: format, maxFramesToRender: 512)
    let url = getResourceUrl(index: 1)
    XCTAssertTrue(z.load(url))
    XCTAssertEqual(270, z.presets.count)
    XCTAssertEqual(0, z.presets[0].bank)
    XCTAssertEqual(0, z.presets[0].program)
    XCTAssertEqual("Stereo Grand", z.presets[0].name)
    XCTAssertEqual(0, z.presets[1].bank)
    XCTAssertEqual(1, z.presets[1].program)
    XCTAssertEqual("Bright Grand", z.presets[1].name)
    XCTAssertEqual(128, z.presets[269].bank)
    XCTAssertEqual(56, z.presets[269].program)
    XCTAssertEqual("SFX", z.presets[269].name)
  }

  func testLoad2() throws {
    let z = FluidSynthBridge()
    let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 48000.0, channels: 2, interleaved: false)!
    z.setRenderingFormat(1, format: format, maxFramesToRender: 512)
    let url = getResourceUrl(index: 2)
    XCTAssertTrue(z.load(url))
    XCTAssertEqual(1, z.presets.count)
    XCTAssertEqual(0, z.presets[0].bank)
    XCTAssertEqual(1, z.presets[0].program)
    XCTAssertEqual("Nice Piano", z.presets[0].name)
  }

  //    func testPerformanceExample() throws {
  //        // This is an example of a performance test case.
  //        self.measure {
  //            // Put the code you want to measure the time of here.
  //        }
  //    }

}
