//
//  EmojiLoader.swift
//  ISEmojiView - https://github.com/isaced/ISEmojiView
//
//  Created by Beniamin Sarkisyan on 01/08/2018.
//

import Foundation

final public class EmojiLoader {
  
  static func recentEmojiCategory() -> EmojiCategory {
    return EmojiCategory(
      category: .recents,
      emojis: RecentEmojisManager.sharedInstance.recentEmojis()
    )
  }
  
  static func emojiCategories() -> [EmojiCategory]? {
    guard let file = Bundle.podBundle.path(forResource: "apple", ofType: "json") else {
      return nil
    }
    
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: file), options: .mappedIfSafe), let jsonResult = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) else {
      return nil
    }
    if let jsonDictionary = jsonResult as? [String: AnyObject] {
      var emojiCategories = [EmojiCategory]()
      if let emojisFromDictionary = jsonDictionary["emojis"] as? [String: AnyObject] {
        var emojis = [String]()
        var name2Emoji = [String: String]()
        for emojiValue in emojisFromDictionary {
          var emojiStr = ""
          if let stri = emojiValue.value["b"] as? String {
            let arr = stri.split(separator: "-")
            for hex in arr {
              if let charCode = UInt32(hex, radix: 16), let unicode = UnicodeScalar(charCode) {
                emojiStr.append(String(unicode))
              }
            }
            name2Emoji.updateValue(emojiStr, forKey: emojiValue.key)
            emojis.append(emojiStr)
          }
        }
        if let categories = jsonDictionary["categories"] as? [[String: AnyObject]] {
          for category in categories {
            var emojisArr = [String]()
            if let emojisOfCategory = category["emojis"] as? [String] {
              for emoji in emojisOfCategory {
                if let emojiFound = name2Emoji[emoji] {
                  emojisArr.append(emojiFound)
                }
              }
            }
            if let categoryName = category["name"] as? String {
              let emojiCategory = EmojiCategory(category: Category(category: categoryName), emojis: emojisArr)
              emojiCategories.append(emojiCategory)
            }
          }
        }
        return emojiCategories
      }
    }
    return nil
  }
}
