//
//  EmojiCollectionView.swift
//  ISEmojiView - https://github.com/isaced/ISEmojiView
//
//  Created by Beniamin Sarkisyan on 01/08/2018.
//

import Foundation

/// emoji view action callback delegate
internal protocol EmojiCollectionViewDelegate: AnyObject {
  
  /// did press a emoji button
  ///
  /// - Parameters:
  ///   - emojiView: the emoji view
  ///   - emoji: a emoji
  ///   - selectedEmoji: the selected emoji
  func emojiViewDidSelectEmoji(emojiView: EmojiCollectionView, emoji: String, selectedEmoji: String)
  
  /// changed section
  ///
  /// - Parameters:
  ///   - category: current category
  ///   - emojiView: the emoji view
  func emojiViewDidChangeCategory(_ category: Category, emojiView: EmojiCollectionView)
  
}

/// A emoji keyboard view
internal class EmojiCollectionView: UIView {
  
  // MARK: - Public variables
  
  /// the delegate for callback
  internal weak var delegate: EmojiCollectionViewDelegate?
  
  internal var emojis: [EmojiCategory]! {
    didSet {
      collectionView.reloadData()
    }
  }
  
  // MARK: - Private variables
  
  private var scrollViewWillBeginDragging = false
  private var scrollViewWillBeginDecelerating = false

  // MARK: - IBOutlets
  
  @IBOutlet private weak var collectionView: UICollectionView! {
    didSet {
      collectionView.register(EmojiCollectionCell.self, forCellWithReuseIdentifier: "EmojiCollectionCell")
      collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
    }
  }
  
  // MARK: - Override variables
  
  internal override var intrinsicContentSize: CGSize {
    return CGSize(width: UIView.noIntrinsicMetric, height: frame.size.height)
  }

  // MARK: - Init functions
  
  static func loadFromNib(emojis: [EmojiCategory]) -> EmojiCollectionView {
    let nibName = String(describing: EmojiCollectionView.self)
    
    guard let nib = Bundle.main.loadNibNamed(nibName, owner: nil, options: nil) as? [EmojiCollectionView] else {
      fatalError()
    }
    
    guard let view = nib.first else {
      fatalError()
    }
    
    view.emojis = emojis
    
    return view
  }
  
  // MARK: - Override functions
  
  override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    guard point.y < 0 else {
      return super.point(inside: point, with: event)
    }
    return false
  }
  
  // MARK: - Internal functions
  
  internal func scrollToCategory(_ category: Category) {
    guard var section = emojis.firstIndex(where: { $0.category == category }) else {
      return
    }
    
    if category == .recents && emojis[section].emojis.isEmpty {
      section = emojis.firstIndex(where: { $0.category == Category.smileysAndPeople })!
    }
    
    if let attributes = collectionView.collectionViewLayout.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: section)) {
      collectionView.setContentOffset(CGPoint(x: 0, y: attributes.frame.origin.y - collectionView.contentInset.top), animated: true)
    }
  }
  
}

// MARK: - UICollectionViewDataSource

extension EmojiCollectionView: UICollectionViewDataSource {
  
  internal func numberOfSections(in collectionView: UICollectionView) -> Int {
    return emojis.count
  }
  
  internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return emojis[section].emojis.count
  }
  
  internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let emojiCategory = emojis[indexPath.section]
    let emoji = emojiCategory.emojis[indexPath.item]
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCollectionCell", for: indexPath) as! EmojiCollectionCell // swiftlint:disable:this force_cast
    cell.setEmoji(emoji)

    return cell
  }
}

// MARK: - UICollectionViewDelegate

extension EmojiCollectionView: UICollectionViewDelegate {
  
  internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let emojiCategory = emojis[indexPath.section]
    let emoji = emojiCategory.emojis[indexPath.item]
    
    delegate?.emojiViewDidSelectEmoji(emojiView: self, emoji: emoji, selectedEmoji: emoji)
  }
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if !scrollViewWillBeginDecelerating && !scrollViewWillBeginDragging {
      return
    }
    
    if let indexPath = collectionView.indexPathsForVisibleItems.min() {
      let emojiCategory = emojis[indexPath.section]
      delegate?.emojiViewDidChangeCategory(emojiCategory.category, emojiView: self)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    switch kind {
    case UICollectionView.elementKindSectionHeader:
      let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as! SectionHeader // swiftlint:disable:this force_cast
      sectionHeader.label.text = emojis[indexPath.section].category.title
      return sectionHeader
    default:
      return UICollectionReusableView()
    }
  }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension EmojiCollectionView: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    var inset = UIEdgeInsets.zero
    
    if let recentsEmojis = emojis.first(where: { $0.category == Category.recents }) {
      if (!recentsEmojis.emojis.isEmpty && section != 0) || (recentsEmojis.emojis.isEmpty && section > 1) {
        inset.left = 3
      }
    }
    
    if section == 0 {
      inset.left = 3
    }
    
    if section == emojis.count - 1 {
      inset.right = 4
    }
    
    return inset
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: self.collectionView.frame.size.width, height: 35)
  }
  
}

class SectionHeader: UICollectionReusableView {
  var label: UILabel = {
    let label: UILabel = UILabel()
    label.textColor = .black
    label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    label.sizeToFit()
    return label
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    addSubview(label)
    
    label.translatesAutoresizingMaskIntoConstraints = false
    label.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12).isActive = true
    label.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UIScrollView

extension EmojiCollectionView {
  
  internal func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    scrollViewWillBeginDragging = true
  }
  
  internal func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
    scrollViewWillBeginDecelerating = true
  }

  internal func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    scrollViewWillBeginDragging = false
  }
  
  internal func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    scrollViewWillBeginDecelerating = false
  }
  
}
