//
//  EmojiCategory.swift
//  ISEmojiView - https://github.com/isaced/ISEmojiView
//
//  Created by Beniamin Sarkisyan on 01/08/2018.
//

import Foundation

public class EmojiCategory {
  
  // MARK: - Public variables
  
  var category: Category
  var emojis: [String]!
  
  // MARK: - Initial functions
  
  public init(category: Category, emojis: [String]) {
    self.category = category
    self.emojis = emojis
  }
  
}
