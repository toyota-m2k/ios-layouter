//
//  MICLayoutConstraint.mm
//  AnotherWorld
//
//  Created by Mitsuki Toyota on 2019/08/09.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//

#import "MICLayoutConstraint.h"
#import "MICVar.h"

MICLayoutConstraintBuilder&
MICLayoutConstraintBuilder::constraint(UIView* target, NSLayoutAttribute attr, UIView* relatedTo, NSLayoutAttribute attrTo,
   CGFloat constant, CGFloat multiplier,
   NSLayoutRelation relatedBy,
   UILayoutPriority priority)
{
    let c = [NSLayoutConstraint constraintWithItem:target
                                         attribute:attr
                                         relatedBy:relatedBy
                                            toItem:relatedTo
                                         attribute:attrTo
                                        multiplier:multiplier
                                          constant:constant];
    c.priority = priority;
    [_constraints addObject:c];
    return *this;
}

static NSLayoutConstraint*
constraintToAnchorSub(NSLayoutAnchor* anchor, NSLayoutAnchor* relatedAnchor, CGFloat margin, int relativity) {
    if(relativity==0) {
        return [anchor constraintEqualToAnchor:relatedAnchor constant:margin];
    } else if(relativity>0) {
        return [anchor constraintGreaterThanOrEqualToAnchor:relatedAnchor constant:margin];
    } else {
        return [anchor constraintLessThanOrEqualToAnchor:relatedAnchor constant:margin];
    }
}

MICLayoutConstraintBuilder&
MICLayoutConstraintBuilder::constraintToSafeArea(UIView* target, MICUiPosEx pos, const UIEdgeInsets& margin, int relativity) {
    target.translatesAutoresizingMaskIntoConstraints = false;
    if((pos&MICUiPosLEFT)!=0) {
        [_constraints addObject:constraintToAnchorSub(target.leftAnchor, _parentView.safeAreaLayoutGuide.leftAnchor, margin.left, relativity)];
    }
    if((pos&MICUiPosTOP)!=0) {
        [_constraints addObject:constraintToAnchorSub(target.topAnchor, _parentView.safeAreaLayoutGuide.topAnchor, margin.top, relativity)];
    }
    if((pos&MICUiPosRIGHT)!=0) {
        [_constraints addObject:constraintToAnchorSub(target.rightAnchor, _parentView.safeAreaLayoutGuide.rightAnchor, margin.right, relativity)];
    }
    if((pos&MICUiPosBOTTOM)!=0) {
        [_constraints addObject:constraintToAnchorSub(target.bottomAnchor, _parentView.safeAreaLayoutGuide.bottomAnchor, margin.bottom, relativity)];
    }
    return *this;
}


MICLayoutConstraintBuilder&
MICLayoutConstraintBuilder::constraintFitParent(UIView* target, MICUiPosEx pos, const UIEdgeInsets& margin) {
    target.translatesAutoresizingMaskIntoConstraints = false;
    if((pos&MICUiPosLEFT)!=0) {
        constraint(target, NSLayoutAttributeLeft, _parentView, NSLayoutAttributeLeft, margin.left);
    }
    if((pos&MICUiPosTOP)!=0) {
        constraint(target, NSLayoutAttributeTop, _parentView, NSLayoutAttributeTop, margin.top);
    }
    if((pos&MICUiPosRIGHT)!=0) {
        constraint(target, NSLayoutAttributeRight, _parentView, NSLayoutAttributeRight, margin.right);
    }
    if((pos&MICUiPosBOTTOM)!=0) {
        constraint(target, NSLayoutAttributeBottom, _parentView, NSLayoutAttributeBottom, margin.bottom);
    }
    return *this;
}

MICLayoutConstraintBuilder&
MICLayoutConstraintBuilder::constraintToVarticalSibling(UIView* target, UIView* sibling, bool below, CGFloat spacing, MICUiAlignEx alignToSibling)
{
    if(below) {
        constraint(target, NSLayoutAttributeTop, sibling, NSLayoutAttributeBottom, spacing);
    } else {
        constraint(target, NSLayoutAttributeBottom, sibling, NSLayoutAttributeTop, spacing);
    }
    switch(alignToSibling) {
        case MICUiAlignExTOP:
            constraint(target, NSLayoutAttributeLeft, sibling, NSLayoutAttributeLeft);
            break;
        case MICUiAlignExBOTTOM:
            constraint(target, NSLayoutAttributeRight, sibling, NSLayoutAttributeRight);
            break;
        case MICUiAlignExCENTER:
            constraint(target, NSLayoutAttributeCenterX, sibling, NSLayoutAttributeCenterX);
            break;
        case MICUiAlignExFILL:
            constraint(target, NSLayoutAttributeLeft, sibling, NSLayoutAttributeLeft);
            constraint(target, NSLayoutAttributeRight, sibling, NSLayoutAttributeRight);
            break;
    }
    return *this;
}

MICLayoutConstraintBuilder&
MICLayoutConstraintBuilder::constraintToHorizontalSibling(UIView* target, UIView* sibling, bool right, CGFloat spacing, MICUiAlignEx alignToSibling)
{
    if(right) {
        constraint(target, NSLayoutAttributeLeft, sibling, NSLayoutAttributeRight, spacing);
    } else {
        constraint(target, NSLayoutAttributeRight, sibling, NSLayoutAttributeLeft, spacing);
    }
    switch(alignToSibling) {
        case MICUiAlignExTOP:
            constraint(target, NSLayoutAttributeTop, sibling, NSLayoutAttributeTop);
            break;
        case MICUiAlignExBOTTOM:
            constraint(target, NSLayoutAttributeBottom, sibling, NSLayoutAttributeBottom);
            break;
        case MICUiAlignExCENTER:
            constraint(target, NSLayoutAttributeCenterY, sibling, NSLayoutAttributeCenterY);
            break;
        case MICUiAlignExFILL:
            constraint(target, NSLayoutAttributeTop, sibling, NSLayoutAttributeTop);
            constraint(target, NSLayoutAttributeBottom, sibling, NSLayoutAttributeBottom);
            break;
    }
    return *this;
}

