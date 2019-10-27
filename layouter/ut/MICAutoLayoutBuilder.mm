//
//  MICAutoLayoutBuilder.mm
//  AnotherWorld
//
//  Created by toyota-m2k on 2019/08/09.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "MICAutoLayoutBuilder.h"
#import "MICVar.h"

MICAutoLayoutBuilder&
MICAutoLayoutBuilder::constraint(UIView* target, NSLayoutAttribute attr, UIView* relatedTo, NSLayoutAttribute attrTo,
   CGFloat constant, CGFloat multiplier,
   NSLayoutRelation relatedBy,
   UILayoutPriority priority)
{
    target.translatesAutoresizingMaskIntoConstraints = false;
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

MICAutoLayoutBuilder&
MICAutoLayoutBuilder::anchorConstraint(NSLayoutAnchor* anchor, NSLayoutAnchor* relatedAnchor, CGFloat margin, int relativity) {
    if(@available(ios 9.0,*)) {
        NSLayoutConstraint* c;
        if(relativity==0) {
            
            c = [anchor constraintEqualToAnchor:relatedAnchor constant:margin];
        } else if(relativity>0) {
            c = [anchor constraintGreaterThanOrEqualToAnchor:relatedAnchor constant:margin];
        } else {
            c = [anchor constraintLessThanOrEqualToAnchor:relatedAnchor constant:margin];
        }
        [_constraints addObject:c];
    }
    return *this;
}

MICAutoLayoutBuilder&
MICAutoLayoutBuilder::fitToSafeArea(UIView* target, MICUiPosEx pos, const UIEdgeInsets& margin, int relativity) {
    if(@available(ios 11.0,*)) {
        target.translatesAutoresizingMaskIntoConstraints = false;
        if((pos&MICUiPosLEFT)!=0) {
            anchorConstraint(target.leftAnchor, _parentView.safeAreaLayoutGuide.leftAnchor, margin.left, relativity);
        }
        if((pos&MICUiPosTOP)!=0) {
            anchorConstraint(target.topAnchor, _parentView.safeAreaLayoutGuide.topAnchor, margin.top, relativity);
        }
        if((pos&MICUiPosRIGHT)!=0) {
            anchorConstraint(target.rightAnchor, _parentView.safeAreaLayoutGuide.rightAnchor, -margin.right, relativity);
        }
        if((pos&MICUiPosBOTTOM)!=0) {
            anchorConstraint(target.bottomAnchor, _parentView.safeAreaLayoutGuide.bottomAnchor, -margin.bottom, relativity);
        }
        return *this;
    } else {
        return fitToParent(target, pos, margin);
    }
}


MICAutoLayoutBuilder&
MICAutoLayoutBuilder::fitToParent(UIView* target, MICUiPosEx pos, const UIEdgeInsets& margin) {
    if(@available(ios 9.0,*)) {
        target.translatesAutoresizingMaskIntoConstraints = false;
        if((pos&MICUiPosLEFT)!=0) {
            anchorConstraint(target.leftAnchor, _parentView.leftAnchor, margin.left);
        }
        if((pos&MICUiPosTOP)!=0) {
            anchorConstraint(target.topAnchor, _parentView.topAnchor, margin.top);
        }
        if((pos&MICUiPosRIGHT)!=0) {
            anchorConstraint(target.rightAnchor, _parentView.rightAnchor, -margin.right);
        }
        if((pos&MICUiPosBOTTOM)!=0) {
            anchorConstraint(target.bottomAnchor, _parentView.bottomAnchor, -margin.bottom);
        }
    } else {
        if((pos&MICUiPosLEFT)!=0) {
            constraint(target, NSLayoutAttributeLeft, _parentView, NSLayoutAttributeLeft, margin.left);
        }
        if((pos&MICUiPosTOP)!=0) {
            constraint(target, NSLayoutAttributeTop, _parentView, NSLayoutAttributeTop, margin.top);
        }
        if((pos&MICUiPosRIGHT)!=0) {
            constraint(target, NSLayoutAttributeRight, _parentView, NSLayoutAttributeRight, -margin.right);
        }
        if((pos&MICUiPosBOTTOM)!=0) {
            constraint(target, NSLayoutAttributeBottom, _parentView, NSLayoutAttributeBottom, -margin.bottom);
        }
    }
    return *this;
}

MICAutoLayoutBuilder&
MICAutoLayoutBuilder::fitVerticallyToSibling(UIView* target, UIView* sibling, bool below, CGFloat spacing, MICUiAlignEx alignToSibling)
{
    if(@available(ios 9.0,*)) {
        target.translatesAutoresizingMaskIntoConstraints = false;
        if(below) {
            anchorConstraint(target.topAnchor, sibling.bottomAnchor, spacing);
        } else {
            anchorConstraint(target.bottomAnchor, sibling.topAnchor, -spacing);
        }
        switch(alignToSibling) {
            case MICUiAlignExTOP:
                anchorConstraint(target.leftAnchor, sibling.leftAnchor, 0);
                break;
            case MICUiAlignExBOTTOM:
                anchorConstraint(target.rightAnchor, sibling.rightAnchor, 0);
                break;
            case MICUiAlignExCENTER:
                anchorConstraint(target.centerXAnchor, sibling.centerXAnchor, 0);
                break;
            case MICUiAlignExFILL:
                anchorConstraint(target.leftAnchor, sibling.leftAnchor, 0);
                anchorConstraint(target.rightAnchor, sibling.rightAnchor, 0);
                break;
        }
    } else {
        if(below) {
            constraint(target, NSLayoutAttributeTop, sibling, NSLayoutAttributeBottom, spacing);
        } else {
            constraint(target, NSLayoutAttributeBottom, sibling, NSLayoutAttributeTop, -spacing);
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
    }
    return *this;
}

MICAutoLayoutBuilder&
MICAutoLayoutBuilder::fitHorizontallyToSibling(UIView* target, UIView* sibling, bool right, CGFloat spacing, MICUiAlignEx alignToSibling)
{
    if(@available(ios 9.0,*)) {
        target.translatesAutoresizingMaskIntoConstraints = false;
        if(right) {
            anchorConstraint(target.leftAnchor, sibling.rightAnchor, spacing);
        } else {
            anchorConstraint(target.rightAnchor, sibling.leftAnchor, spacing);
        }
        switch(alignToSibling) {
            case MICUiAlignExTOP:
                anchorConstraint(target.topAnchor, sibling.topAnchor, 0);
                break;
            case MICUiAlignExBOTTOM:
                anchorConstraint(target.bottomAnchor, sibling.bottomAnchor, 0);
                break;
            case MICUiAlignExCENTER:
                anchorConstraint(target.centerYAnchor, sibling.centerYAnchor, 0);
                break;
            case MICUiAlignExFILL:
                anchorConstraint(target.topAnchor, sibling.topAnchor, 0);
                anchorConstraint(target.bottomAnchor, sibling.bottomAnchor, 0);
                break;
        }
    } else {
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
    }
    return *this;
}


/**
 * RALParams の指定に従って、サブビューの配置を行うためのビルダー
 */


void RALBuilder::attachToRelated(UIView* target, UIView* related, MICUiPos pos, bool adjacent, CGFloat distance) {
    if(@available(ios 9.0,*)) {
        if(related==nil) {
            related = _parentView;
        }
        NSLayoutAnchor *targetAnchor, *relatedAnchor;
        switch(pos) {
            case MICUiPosLEFT:
                targetAnchor = target.leftAnchor;
                relatedAnchor = (adjacent) ? related.rightAnchor : related.leftAnchor;
                break;
            case MICUiPosTOP:
                targetAnchor = target.topAnchor;
                relatedAnchor = (adjacent) ? related.bottomAnchor : related.topAnchor;
                break;

            case MICUiPosRIGHT:
                targetAnchor = target.rightAnchor;
                relatedAnchor = (adjacent) ? related.leftAnchor : related.rightAnchor;
                distance *= -1.0;
                break;

                break;
            case MICUiPosBOTTOM:
                targetAnchor = target.bottomAnchor;
                relatedAnchor = (adjacent) ? related.topAnchor : related.bottomAnchor;
                distance *= -1.0;
                break;
        }
        anchorConstraint(targetAnchor, relatedAnchor, distance);
    } else {
        if(related==nil) {
            related = _parentView;
        }
        NSLayoutAttribute targetAttr, relatedAttr;
        switch(pos) {
            case MICUiPosLEFT:
                targetAttr = NSLayoutAttributeLeft;
                relatedAttr = (adjacent) ? NSLayoutAttributeRight : NSLayoutAttributeLeft;
                break;
            case MICUiPosTOP:
                targetAttr = NSLayoutAttributeTop;
                relatedAttr = (adjacent) ? NSLayoutAttributeBottom : NSLayoutAttributeTop;
                break;
                
            case MICUiPosRIGHT:
                targetAttr = NSLayoutAttributeRight;
                relatedAttr = (adjacent) ? NSLayoutAttributeLeft : NSLayoutAttributeRight;
                distance *= -1.0;
                break;
                
                break;
            case MICUiPosBOTTOM:
                targetAttr = NSLayoutAttributeBottom;
                relatedAttr = (adjacent) ? NSLayoutAttributeTop : NSLayoutAttributeBottom;
                distance *= -1.0;
                break;
        }
        constraint(target, targetAttr, related, relatedAttr, distance);
    }
}
        
void RALBuilder::attachCenter(UIView* view, UIView*related, bool vert) {
    if(related==nil) {
        related = _parentView;
    }
    
    if(@available(ios 9.0,*)) {
        if(vert) {
            anchorConstraint(view.centerYAnchor, related.centerYAnchor);
        } else {
            anchorConstraint(view.centerXAnchor, related.centerXAnchor);
        }
    } else {
        if(vert) {
            constraint(view, NSLayoutAttributeCenterY, related, NSLayoutAttributeCenterY);
        } else {
            constraint(view, NSLayoutAttributeCenterX, related, NSLayoutAttributeCenterX);
        }
    }
}
    
void RALBuilder::attachToRelated(UIView* view, const RALAttach& attach, MICUiPos pos) {
    bool adjacent = false;
    switch(attach._attach) {
        case RALAttach::ADJACENT:
            adjacent = true;
            // fall through ...
        case RALAttach::FIT:
            attachToRelated(view, attach._related, pos, adjacent, attach._value);
            break;
        default:
            break;
    }
}
    
void RALBuilder::scaleFor(UIView* view, const RALScaling& scaling, bool vert) {
    NSLayoutAttribute attr = vert ? NSLayoutAttributeHeight : NSLayoutAttributeWidth;
    CGFloat value = 0;
    CGFloat multi = 1.0;
    UIView* related = nil;
    
    switch(scaling._scaling) {
        case RALScaling::FREE:
            return;
        case RALScaling::FIXED:
            value = scaling._value;
            break;
        case RALScaling::NOSIZE:
            value = vert ? view.frame.size.height : view.frame.size.width;
            break;
        case RALScaling::RELATIVE:
            related = scaling._related;
            if(related==nil) {
                related = _parentView;
            }
            multi = scaling._value;
            break;
    }
    constraint(view, attr, related, attr, value, multi);
}

static void autoCorrectSub(RALAttach& a1, RALAttach& a2, RALScaling& s) {
    if(a1._attach==RALAttach::FREE && a2._attach==RALAttach::FREE) {
        // 両サイドがfreeだと位置が決められない。
        NSLog(@"RAL-autoCorrect: attach free on both-side. force attach start-side to parent.");
        a1.parent();
    }
    if(a1._attach==RALAttach::CENTER || a2._attach==RALAttach::CENTER ) {
        // センタリング指定の場合、サイズ指定は必須
        if(s._scaling == RALScaling::FREE) {
            NSLog(@"RAL-autoCorrect: on attach center, scaling must be specified. force scale with NOSIZE option.");
            s.nosize();
        }
    } else if(a1._attach==RALAttach::FREE || a2._attach==RALAttach::FREE) {
        // 片方だけattachが与えられている場合、サイズがフリーなら、もう片方が決められない
        if(s._scaling == RALScaling::FREE) {
            NSLog(@"RAL-autoCorrect: attach free and scaling free. force scale with NOSIZE option.");
            s.nosize();
        }
    } else {
        // 両サイドのattachが与えられていて、centering でもない
        if(s._scaling!=RALScaling::FREE) {
            // さらにscale まで与えられているが、これは無視するしかない。
            NSLog(@"RAL-autoCorrect: attach both-side with scaling. ignore scaling.");
            s.free();
        }
    }
}

static const RALAttach* getCenterAttach(const RALAttach& a1, const RALAttach& a2) {
    if(a1._attach == RALAttach::CENTER) {
        return &a1;
    } else if(a2._attach == RALAttach::CENTER) {
        return &a2;
    }
    return NULL;
}


RALBuilder& RALBuilder::addView(UIView* view, RALParams& params) {
    view.translatesAutoresizingMaskIntoConstraints = false;
    if(_autoAddSubview) {
        [_parentView addSubview:view];
    }

    // autoCorrect
    if(_autoCorrect) {
        autoCorrectSub(params._left, params._right, params._horz);
        autoCorrectSub(params._top, params._bottom, params._vert);
    }
    
    // Attach
    let vCenter = getCenterAttach(params._top, params._bottom);
    if(NULL!=vCenter) {
        attachCenter(view, vCenter->_related, true);
    } else {
        attachToRelated(view, params._top, MICUiPosTOP);
        attachToRelated(view, params._bottom, MICUiPosBOTTOM);
    }
    
    let hCenter = getCenterAttach(params._left, params._right);
    if(NULL!=hCenter) {
        attachCenter(view, hCenter->_related, false);
    } else {
        attachToRelated(view, params._left, MICUiPosLEFT);
        attachToRelated(view, params._right, MICUiPosRIGHT);
    }
    
    // Scaling
    scaleFor(view, params._vert, true);
    scaleFor(view, params._horz, false);
    return *this;
}

