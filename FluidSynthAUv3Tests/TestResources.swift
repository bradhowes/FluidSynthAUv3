//
//  TestResources.swift
//  FluidSynthAUTests
//
//  Created by Brad Howes on 11/08/2023.
//

import Foundation

func getSoundFontUrls() -> [URL] {
  for bundle in Bundle.allBundles {
    if let found = bundle.urls(forResourcesWithExtension: "sf2", subdirectory: nil), !found.isEmpty {
      return found
    }
  }
  return []
}

func getResourceUrl(index: Int) -> URL {
  let found = getSoundFontUrls().filter { !$0.absoluteString.contains("ZZZ") }
  return found[index];
}

func getBadResourceUrl(index: Int) -> URL {
  let found = getSoundFontUrls().filter { $0.absoluteString.contains("ZZZ") }
  return found[index];
}
