//
//  CategoriesBottomView.swift
//  ISEmojiView - https://github.com/isaced/ISEmojiView
//
//  Created by Beniamin Sarkisyan on 01/08/2018.
//

import Foundation

private let MinCellSize = CGFloat(35)

internal protocol CategoriesViewDelegate: AnyObject {
  
  func categoriesBottomViewDidSelecteCategory(_ category: Category, bottomView: CategoriesView)
}

final internal class CategoriesView: UIView {
  
  // MARK: - Internal variables
  
  internal weak var delegate: CategoriesViewDelegate?
  internal var categories: [Category]! {
    didSet {
      collectionView.reloadData()
      if let selectedItems = collectionView.indexPathsForSelectedItems, selectedItems.isEmpty {
        selectFirstCell()
      }
    }
  }
  
  // MARK: - IBOutlets
  
  @IBOutlet private weak var collectionView: UICollectionView! {
    didSet {
      collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: "CategoryCell")
    }
  }
  
  // MARK: - Init functions
  
  static internal func loadFromNib(with categories: [Category]) -> CategoriesView {
    let nibName = String(describing: CategoriesView.self)
    
    guard let nib = Bundle.main.loadNibNamed(nibName, owner: nil, options: nil) as? [CategoriesView] else {
      fatalError()
    }
    
    guard let bottomView = nib.first else {
      fatalError()
    }
    
    bottomView.categories = categories
    bottomView.selectFirstCell()
    
    return bottomView
  }
  
  // MARK: - Override functions
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
      var size = collectionView.bounds.size
      
      if categories.count < Category.count - 2 {
        size.width = MinCellSize
      } else {
        size.width = collectionView.bounds.width/CGFloat(categories.count)
      }
      
      layout.itemSize = size
      collectionView.collectionViewLayout.invalidateLayout()
    }
  }
  
  // MARK: - Internal functions
  
  internal func updateCurrentCategory(_ category: Category) {
    guard let item = categories.firstIndex(where: { $0 == category }) else {
      return
    }
    
    guard let selectedItem = collectionView.indexPathsForSelectedItems?.first?.item else {
      return
    }
    
    guard selectedItem != item else {
      return
    }
    
    (0..<categories.count).forEach {
      let indexPath = IndexPath(item: $0, section: 0)
      collectionView.deselectItem(at: indexPath, animated: false)
    }
    
    let indexPath = IndexPath(item: item, section: 0)
    collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
  }
}

// MARK: - UICollectionViewDataSource

extension CategoriesView: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return categories.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell // swiftlint:disable:this force_cast
    cell.setEmojiCategory(categories[indexPath.item])
    return cell
  }
  
}

// MARK: - UICollectionViewDelegate

extension CategoriesView: UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    delegate?.categoriesBottomViewDidSelecteCategory(categories[indexPath.item], bottomView: self)
  }
  
}

// MARK: - Private functions

extension CategoriesView {
  
  private func selectFirstCell() {
    let indexPath = IndexPath(item: 0, section: 0)
    collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
  }
  
}
