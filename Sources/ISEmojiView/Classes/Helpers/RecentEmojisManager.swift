//
//  RecentEmojisManager.swift
//  ISEmojiView - https://github.com/isaced/ISEmojiView
//
//  Created by Beniamin Sarkisyan on 01/08/2018.
//

import Foundation

private let RecentEmojisKey = "ISEmojiView.recent"
private let RecentEmojisFreqStorageKey = "ISEmojiView.recent-freq"

final internal class RecentEmojisManager {
  
  // MARK: - Public variables
  
  static let sharedInstance = RecentEmojisManager()
  
  internal var maxCountOfCenetEmojis: Int = 12
  
  // MARK: - Public functions
  
  internal func add(emoji: String, selectedEmoji: String) -> Bool {
    guard maxCountOfCenetEmojis > 0 else {
      return false
    }
    
    var emojis = recentEmojis()
    var freqData = recentEmojisFreqData()

    if let freq = freqData[selectedEmoji] {
      freqData[selectedEmoji] = freq+1
    } else {
      freqData[selectedEmoji] = 0
      
    }
    
    guard emojis.firstIndex(of: emoji) == nil// 'contains' is slow
    else {
      UserDefaults.standard.set(freqData, forKey: RecentEmojisFreqStorageKey)
      return true
      
    }
    
    if emojis.count > maxCountOfCenetEmojis {
      emojis.removeLast(emojis.count-maxCountOfCenetEmojis)
    }
    if emojis.count > 0 && emojis.count == maxCountOfCenetEmojis {
      let toRemove = emojis.removeLast()
      let newIndex = maxCountOfCenetEmojis/3
      let oldOne = emojis[newIndex]
      emojis.insert(emoji, at: newIndex)
      freqData[selectedEmoji] = (freqData[oldOne] ?? 0) + 1
      freqData.removeValue(forKey: toRemove)
    } else {
      emojis.append(emoji)
    }
    
    if let data = try? JSONEncoder().encode(emojis) {
      UserDefaults.standard.set(data, forKey: RecentEmojisKey)
    }
    UserDefaults.standard.set(freqData, forKey: RecentEmojisFreqStorageKey)
    return true
  }
  internal func recentEmojisFreqData() -> [String: Int] {
    guard let data = UserDefaults.standard.dictionary(forKey: RecentEmojisFreqStorageKey) as? [String: Int] else {return [:]}
    return data
  }
  internal func recentEmojis() -> [String] {
    guard let data = UserDefaults.standard.data(forKey: RecentEmojisKey) else {
      return []
    }
    
    guard let emojis = try? JSONDecoder().decode([String].self, from: data) else {
      return []
    }
    let freqData = recentEmojisFreqData()
    let seq = emojis.sorted {
      let left = freqData[$0] ?? 0
      let right = freqData[$1] ?? 0
      return left > right
    }
    return seq
  }
  
}
