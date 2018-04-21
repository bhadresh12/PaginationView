//
//  FlowLayout.swift
//  PaginationView
//
//  Created by iOS Developer on 21/04/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

import UIKit

class FlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        if let collectionView = collectionView,
            let startIndex = layoutAttributesForItem(at: IndexPath(item: 0, section: 0)),
            let endIndex = layoutAttributesForItem(at: IndexPath(item: (collectionView.numberOfItems(inSection: 0)) - 1, section: 0)) {
            
            let firstItem = (collectionView.bounds.size.width) / 2 - startIndex.bounds.size.width / 2
            let lastItem = (collectionView.bounds.size.width) / 2 - endIndex.bounds.size.width / 2
            collectionView.contentInset = UIEdgeInsets(top: 0, left: firstItem, bottom: 0, right: lastItem)
        }
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        let collectionViewSize = self.collectionView!.bounds.size
        let horizontalCenter = proposedContentOffset.x + collectionViewSize.width * 0.5
        
        var targetRect = self.collectionView!.bounds
        
        // comment this out if you don't want it to scroll so quickly
        targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionViewSize.width, height: collectionViewSize.height)
        
        var candidateAttributes: UICollectionViewLayoutAttributes?
        for attributes in self.layoutAttributesForElements(in: targetRect)! {
            // == Skip comparison with non-cell items (headers and footers) == //
            if attributes.representedElementCategory != .cell {
                continue
            }
            
            // Get collectionView current scroll position
            let currentOffset = self.collectionView!.contentOffset
            
            // Don't even bother with items on opposite direction
            // You'll get at least one, or else the fallback got your back
            // swiftlint:disable:next line_length
            if (attributes.center.x <= (currentOffset.x + collectionViewSize.width * 0.5) && velocity.x > 0) || (attributes.center.x >= (currentOffset.x + collectionViewSize.width * 0.5) && velocity.x < 0) {
                
                continue
            }
            
            // First good item in the loop
            if candidateAttributes == nil {
                candidateAttributes = attributes
                continue
            }
            
            // Save constants to improve readability
            let lastCenterOffset = candidateAttributes!.center.x - horizontalCenter
            let centerOffset = attributes.center.x - horizontalCenter
            
            if fabsf( Float(centerOffset) ) < fabsf( Float(lastCenterOffset) ) {
                candidateAttributes = attributes
            }
        }
        
        if candidateAttributes != nil {
            // Great, we have a candidate
            return CGPoint(x: candidateAttributes!.center.x - collectionViewSize.width * 0.5, y: proposedContentOffset.y)
        } else {
            // Fallback
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }
    }
}
