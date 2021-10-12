//
//  Category.swift
//  ISEmojiView - https://github.com/isaced/ISEmojiView
//
//  Created by Beniamin Sarkisyan on 03/08/2018.
//

import Foundation

public enum Category: Equatable {
  case recents
  case smileysAndPeople
  case animalsAndNature
  case foodAndDrink
  case activity
  case travelAndPlaces
  case objects
  case symbols
  case flags
  case custom(String, String)
  
  static var count = 10
  
  init(category: String) {
    if category == "Frequently Used" {
      self = .recents
    } else if category == "Smileys & People" {
      self = .smileysAndPeople
    } else if category == "Animals & Nature" {
      self = .animalsAndNature
    } else if category == "Food & Drink" {
      self = .foodAndDrink
    } else if category == "Activities" {
      self = .activity
    } else if category == "Travel & Places" {
      self = .travelAndPlaces
    } else if category == "Objects" {
      self = .objects
    } else if category == "Symbols" {
      self = .symbols
    } else if category == "Flags" {
      self = .flags
    } else {
      self = .custom("error", "error")
    }
  }
  
  var title: String {
    switch self {
    case .recents:
      return "Frequently Used"
    case .smileysAndPeople:
      return "Smileys & People"
    case .animalsAndNature:
      return "Animals & Nature"
    case .foodAndDrink:
      return "Food & Drink"
    case .activity:
      return "Activity"
    case .travelAndPlaces:
      return "Travel & Places"
    case .objects:
      return "Objects"
    case .symbols:
      return "Symbols"
    case .flags:
      return "Flags"
    case .custom(let title, _):
      return title
    }
  }
  
  var iconName: String {
    switch self {
    case .recents:
      return "ic_recents"
    case .smileysAndPeople:
      return "ic_smileys_people"
    case .animalsAndNature:
      return "ic_animals_nature"
    case .foodAndDrink:
      return "ic_food_drink"
    case .activity:
      return "ic_activity"
    case .travelAndPlaces:
      return "ic_travel_places"
    case .objects:
      return "ic_objects"
    case .symbols:
      return "ic_symbols"
    case .flags:
      return "ic_flags"
    case .custom(_, let iconName):
      return iconName
    }
  }
}
