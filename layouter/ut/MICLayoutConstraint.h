//
//  MICLayoutContraint.h
//  AnothorWorld
//
//  Created by Mitsuki Toyota on 2019/08/09.
//  Copyright © 2019 Mitsuki Toyota. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "MICUiRectUtil.h"
#import "MICUiLayout.h"       // MICUiAlignEx を借用

#if defined(__cplusplus)

class MICLayoutConstraintBuilder {
private:
    NSMutableArray<NSLayoutConstraint *>* _constraints;
    UIView* _parentView;
public:
    MICLayoutConstraintBuilder(UIView* parentView) {
        _constraints = [NSMutableArray array];
        _parentView = parentView;
    }
    ~MICLayoutConstraintBuilder() {
        _constraints = nil;
        _parentView = nil;
    }
    
    MICLayoutConstraintBuilder&
    constraint(UIView* target, NSLayoutAttribute attr, UIView* relatedTo, NSLayoutAttribute attrTo,
                                       CGFloat constant = 0.0, CGFloat multiplier = 1.0,
                                       NSLayoutRelation relatedBy=NSLayoutRelationEqual,
                                       UILayoutPriority priority=UILayoutPriorityRequired);
    
    MICLayoutConstraintBuilder&
    constraintToSafeArea(UIView* target, MICUiPosEx pos = MICUiPosExALL, const UIEdgeInsets& margin=MICEdgeInsets(), int relativity=0);

    MICLayoutConstraintBuilder&
    constraintFitParent(UIView* target, MICUiPosEx pos, const UIEdgeInsets& margin);

    MICLayoutConstraintBuilder&
    constraintFitSibling(UIView* target, UIView* sibling, MICUiPosEx pos, const UIEdgeInsets& margin);

    MICLayoutConstraintBuilder& constraintToVarticalSibling(UIView* target, UIView* sibling, bool below, CGFloat spacing, MICUiAlignEx alignToSibling);
    
    MICLayoutConstraintBuilder& createBelowSibling(UIView* target, UIView* sibling, CGFloat spacing, MICUiAlignEx alignToSibling) {
        return constraintToVarticalSibling(target, sibling, true, spacing, alignToSibling);
    }
    
    MICLayoutConstraintBuilder& createAboveSibling(UIView* target, UIView* sibling, CGFloat spacing, MICUiAlignEx alignToSibling) {
        return constraintToVarticalSibling(target, sibling, false, spacing, alignToSibling);
    }
    
    MICLayoutConstraintBuilder& constraintToHorizontalSibling(UIView* target, UIView* sibling, bool right, CGFloat spacing, MICUiAlignEx alignToSibling);
    
    MICLayoutConstraintBuilder& createRightSibling(UIView* target, UIView* sibling, CGFloat spacing, MICUiAlignEx alignToSibling) {
        return constraintToHorizontalSibling(target, sibling, true, spacing, alignToSibling);
    }
    MICLayoutConstraintBuilder& createLeftSibling(UIView* target, UIView* sibling, CGFloat spacing, MICUiAlignEx alignToSibling) {
        return constraintToHorizontalSibling(target, sibling, false, spacing, alignToSibling);
    }
    
    void activate() {
//        [_parentView addConstraints:_constraints];
        [NSLayoutConstraint activateConstraints:_constraints];
    }
    
    NSMutableArray<NSLayoutConstraint *>* close(bool createNew) {
        auto r = _constraints;
        _constraints = nil;
        if(createNew) {
            _constraints = [NSMutableArray array];
        }
        return r;
    }
};

#endif

