// Copyright 2017-present the Material Components for iOS authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <XCTest/XCTest.h>
#import "MDCCollectionViewLayoutAttributes.h"
#import "MDCCollectionViewStyling.h"
#import "MDCCollectionViewStylingDelegate.h"
#import "MDCCollectionViewStyler.h"

static MDCCollectionViewLayoutAttributes* cell00(void) {
  return [MDCCollectionViewLayoutAttributes
      layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
}
static MDCCollectionViewLayoutAttributes* cell01(void) {
  return [MDCCollectionViewLayoutAttributes
      layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
}
static MDCCollectionViewLayoutAttributes* header0(void) {
  return [MDCCollectionViewLayoutAttributes
      layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                   withIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
}
static MDCCollectionViewLayoutAttributes* header1(void) {
  return [MDCCollectionViewLayoutAttributes
      layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                   withIndexPath:[NSIndexPath indexPathForItem:1 inSection:1]];
}
static MDCCollectionViewLayoutAttributes* footer0(void) {
  return [MDCCollectionViewLayoutAttributes
      layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                   withIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
}
static MDCCollectionViewLayoutAttributes* footer1(void) {
  return [MDCCollectionViewLayoutAttributes
      layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                   withIndexPath:[NSIndexPath indexPathForItem:1 inSection:1]];
}

// Implementation of a MDCCollectionViewStylingDelegate for testing purpose.
@interface CollectionsStylerTestsDelegate : NSObject <MDCCollectionViewStylingDelegate>

@end

@implementation CollectionsStylerTestsDelegate

- (BOOL)collectionView:(UICollectionView*)collectionView
    shouldHideItemSeparatorAtIndexPath:(NSIndexPath*)indexPath {
  return indexPath.section == 0 && indexPath.item == 1;
}

- (BOOL)collectionView:(UICollectionView*)collectionView
    shouldHideHeaderSeparatorForSection:(NSInteger)section {
  return section == 1;
}

- (BOOL)collectionView:(UICollectionView*)collectionView
    shouldHideFooterSeparatorForSection:(NSInteger)section {
  return section == 0;
}

@end

@interface CollectionsStylerTests : XCTestCase
@end

@implementation CollectionsStylerTests

- (void)testHideSeparatorWithDelegate {
  // Given
  UICollectionView* collectionView =
      [[UICollectionView alloc] initWithFrame:CGRectZero
                         collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
  CollectionsStylerTestsDelegate* delegate = [[CollectionsStylerTestsDelegate alloc] init];
  MDCCollectionViewStyler* styler =
      [[MDCCollectionViewStyler alloc] initWithCollectionView:collectionView];
  styler.delegate = delegate;

  // Then
  XCTAssertFalse([styler shouldHideSeparatorForCellLayoutAttributes:cell00()]);
  XCTAssertTrue([styler shouldHideSeparatorForCellLayoutAttributes:cell01()]);
  XCTAssertFalse([styler shouldHideSeparatorForCellLayoutAttributes:header0()]);
  XCTAssertTrue([styler shouldHideSeparatorForCellLayoutAttributes:header1()]);
  XCTAssertTrue([styler shouldHideSeparatorForCellLayoutAttributes:footer0()]);
  XCTAssertFalse([styler shouldHideSeparatorForCellLayoutAttributes:footer1()]);
}

- (void)testHideSeparatorWithoutDelegate {
  // Given
  UICollectionView* collectionView =
      [[UICollectionView alloc] initWithFrame:CGRectZero
                         collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
  MDCCollectionViewStyler* styler =
      [[MDCCollectionViewStyler alloc] initWithCollectionView:collectionView];
  styler.delegate = nil;

  // When
  styler.shouldHideSeparators = YES;

  // Then
  XCTAssertTrue([styler shouldHideSeparatorForCellLayoutAttributes:cell00()]);
  XCTAssertTrue([styler shouldHideSeparatorForCellLayoutAttributes:cell01()]);
  XCTAssertTrue([styler shouldHideSeparatorForCellLayoutAttributes:header0()]);
  XCTAssertTrue([styler shouldHideSeparatorForCellLayoutAttributes:header1()]);
  XCTAssertTrue([styler shouldHideSeparatorForCellLayoutAttributes:footer0()]);
  XCTAssertTrue([styler shouldHideSeparatorForCellLayoutAttributes:footer1()]);
}

- (void)testShowSeparatorWithoutDelegate {
  // Given
  UICollectionView* collectionView =
      [[UICollectionView alloc] initWithFrame:CGRectZero
                         collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
  MDCCollectionViewStyler* styler =
      [[MDCCollectionViewStyler alloc] initWithCollectionView:collectionView];
  styler.delegate = nil;

  // When
  styler.shouldHideSeparators = NO;

  // Then
  XCTAssertFalse([styler shouldHideSeparatorForCellLayoutAttributes:cell00()]);
  XCTAssertFalse([styler shouldHideSeparatorForCellLayoutAttributes:cell01()]);
  XCTAssertFalse([styler shouldHideSeparatorForCellLayoutAttributes:header0()]);
  XCTAssertFalse([styler shouldHideSeparatorForCellLayoutAttributes:header1()]);
  XCTAssertFalse([styler shouldHideSeparatorForCellLayoutAttributes:footer0()]);
  XCTAssertFalse([styler shouldHideSeparatorForCellLayoutAttributes:footer1()]);
}

/** Verifies images returned for dynamic color are different when trait is changed. */
- (void)testBackgroundImageForCellLayoutAttributesWithTraitUpdate {
  UICollectionView* collectionView =
      [[UICollectionView alloc] initWithFrame:CGRectZero
                         collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
  MDCCollectionViewStyler* styler =
      [[MDCCollectionViewStyler alloc] initWithCollectionView:collectionView];
  styler.delegate = nil;
  styler.cellStyle = MDCCollectionViewCellStyleCard;

  if (@available(iOS 13.0, *)) {
    styler.cellBackgroundColor = [UIColor
        colorWithDynamicProvider:^UIColor* _Nonnull(UITraitCollection* _Nonnull traitCollection) {
          if (collectionView.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
            return UIColor.whiteColor;
          } else {
            return UIColor.darkGrayColor;
          }
        }];

    // Update to light mode.
    collectionView.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
  }

  UIImage* lightModeImage = [styler backgroundImageForCellLayoutAttributes:cell00()];
  XCTAssertNotNil(lightModeImage);

  // Update to dark mode.
  if (@available(iOS 13.0, *)) {
    collectionView.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;

    UIImage* darkModeImage = [styler backgroundImageForCellLayoutAttributes:cell00()];
    XCTAssertNotNil(darkModeImage);

    XCTAssertNotEqualObjects(lightModeImage, darkModeImage);
  }
}

@end
