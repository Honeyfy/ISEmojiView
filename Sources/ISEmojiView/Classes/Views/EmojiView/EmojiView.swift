//
//  EmojiView.swift
//  ISEmojiView - https://github.com/isaced/ISEmojiView
//
//  Created by Beniamin Sarkisyan on 01/08/2018.
//

import Foundation

public protocol EmojiViewDelegate: AnyObject {
  func emojiViewDidSelect(emoji: String, emojiView: EmojiView)
}

final public class EmojiView: UIView {
  
  // MARK: - IBInspectable variables
  
  let suggestedEmojis = [ "🙌", "👍", "🔥", "😂", "👏", "💪"]

  @IBInspectable private var countOfRecentsEmojis: Int = 12 {
    didSet {
      RecentEmojisManager.sharedInstance.maxCountOfCenetEmojis = countOfRecentsEmojis
      
      if countOfRecentsEmojis > 0 {
        if !emojis.contains(where: { $0.category == .recents }) {
          emojis.insert(EmojiLoader.recentEmojiCategory(), at: 0)
        }
      } else if let index = emojis.firstIndex(where: { $0.category == .recents }) {
        emojis.remove(at: index)
      }
      
      emojiCollectionView?.emojis = emojis
      categoriesBottomView?.categories = emojis.map { $0.category }
    }
  }
  
  // MARK: - Public variables
  
  public weak var delegate: EmojiViewDelegate?
  
  // MARK: - Private variables
  
  private weak var bottomContainerView: UIView?
  private weak var emojiCollectionView: EmojiCollectionView?
  private weak var categoriesBottomView: CategoriesView?
  private var bottomConstraint: NSLayoutConstraint?
  
//  private var bottomType: BottomType!
  private var emojis: [EmojiCategory]!
  //    private var keyboardSettings: KeyboardSettings?
  
  // MARK: - Init functions
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    emojis = EmojiLoader.emojiCategories()
    
    if RecentEmojisManager.sharedInstance.recentEmojis().count == 0 {
      for emoji in suggestedEmojis {
        _ = RecentEmojisManager.sharedInstance.add(emoji: emoji, selectedEmoji: emoji)
      }
    }
    emojis.insert(EmojiLoader.recentEmojiCategory(), at: 0)
    
    setupView()
    setupSubviews()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    emojis = EmojiLoader.emojiCategories()
    if RecentEmojisManager.sharedInstance.recentEmojis().count > 0 {
      emojis.insert(EmojiLoader.recentEmojiCategory(), at: 0)
    }
    
    setupSubviews()
  }
  
  // MARK: - Override functions
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    if #available(iOS 11.0, *) {
      bottomConstraint?.constant = -safeAreaInsets.bottom
    } else {
      bottomConstraint?.constant = 0
    }
    
  }
  
  override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    if point.y > 0 {
      return super.point(inside: point, with: event)
    }
    return emojiCollectionView?.point(inside: point, with: event) ?? true
  }
  
}

// MARK: - EmojiCollectionViewDelegate

extension EmojiView: EmojiCollectionViewDelegate {
  
  func emojiViewDidSelectEmoji(emojiView: EmojiCollectionView, emoji: String, selectedEmoji: String) {
    if RecentEmojisManager.sharedInstance.add(emoji: emoji, selectedEmoji: selectedEmoji) {
    }
    delegate?.emojiViewDidSelect(emoji: selectedEmoji, emojiView: self)
  }
  
  func emojiViewDidChangeCategory(_ category: Category, emojiView: EmojiCollectionView) {
    categoriesBottomView?.updateCurrentCategory(category)
  }
}

// MARK: - CategoriesBottomViewDelegate

extension EmojiView: CategoriesViewDelegate {
  
  func categoriesBottomViewDidSelecteCategory(_ category: Category, bottomView: CategoriesView) {
    emojiCollectionView?.scrollToCategory(category)
  }
}

// MARK: - Private functions

extension EmojiView {
  
  private func setupView() {
    backgroundColor = UIColor(red: 249/255.0, green: 249/255.0, blue: 249/255.0, alpha: 1)
  }
  
  private func setupSubviews() {
    setupEmojiCollectionView()
    setupBottomContainerView()
    setupConstraints()
  }
  
  private func setupEmojiCollectionView() {
    let emojiCollectionView = EmojiCollectionView.loadFromNib(emojis: emojis)
    emojiCollectionView.delegate = self
    emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(emojiCollectionView)
    
    self.emojiCollectionView = emojiCollectionView
  }
  
  private func setupBottomContainerView() {
    let bottomContainerView = UIView()
    bottomContainerView.backgroundColor = .clear
    bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(bottomContainerView)
    
    self.bottomContainerView = bottomContainerView
    
    setupBottomView()
  }
  
  private func setupBottomView() {
    bottomContainerView?.subviews.forEach { $0.removeFromSuperview() }
    
    let categories: [Category] = emojis.map { $0.category }
    var _bottomView: UIView?
    
    let categoryView = CategoriesView.loadFromNib(
      with: categories
    )
    categoryView.delegate = self
    self.categoriesBottomView = categoryView
    
    _bottomView = categoryView
    
    guard let bottomView = _bottomView else {
      return
    }
    
    bottomView.translatesAutoresizingMaskIntoConstraints = false
    bottomContainerView?.addSubview(bottomView)
    
    let views = ["bottomView": bottomView]
    
    addConstraints(
      NSLayoutConstraint.constraints(
        withVisualFormat: "H:|-0-[bottomView]-0-|",
        options: NSLayoutConstraint.FormatOptions(rawValue: 0),
        metrics: nil,
        views: views
      )
    )
    
    addConstraints(
      NSLayoutConstraint.constraints(
        withVisualFormat: "V:|-0-[bottomView]-0-|",
        options: NSLayoutConstraint.FormatOptions(rawValue: 0),
        metrics: nil,
        views: views
      )
    )
  }
  
  private func setupConstraints() {
    guard let emojiCollectionView = emojiCollectionView, let bottomContainerView = bottomContainerView else {
      return
    }
    
    let views = [
      "emojiCollectionView": emojiCollectionView,
      "bottomContainerView": bottomContainerView
    ]
    
    addConstraints(
      NSLayoutConstraint.constraints(
        withVisualFormat: "H:|-0-[emojiCollectionView]-0-|",
        options: NSLayoutConstraint.FormatOptions(rawValue: 0),
        metrics: nil,
        views: views
      )
    )
    
    addConstraints(
      NSLayoutConstraint.constraints(
        withVisualFormat: "H:|-0-[bottomContainerView]-0-|",
        options: NSLayoutConstraint.FormatOptions(rawValue: 0),
        metrics: nil,
        views: views
      )
    )
    
    addConstraints(
      NSLayoutConstraint.constraints(
        withVisualFormat: "V:|-5-[bottomContainerView(44)]-(0)-[emojiCollectionView]-0-|",
        options: NSLayoutConstraint.FormatOptions(rawValue: 0),
        metrics: nil,
        views: views
      )
    )
  }
}
