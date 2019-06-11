//
//  MICUiRectUtil.h

//  CGRectを使いやすくするためのクラス
//
//  Created by @toyota-m2k on 2014/10/29.
//  Copyright (c) 2014年 @toyota-m2k. All rights reserved.
//

#ifndef __MICUiRectUtil_h
#define __MICUiRectUtil_h

//------------------------------------------------------------------------------------------
#pragma mark - CGRect操作用マクロ

// Left/Right/Top/Bottom を個別に設定/取得する。
#define MR_SetLeft(rc,v)        {CGFloat __w=MR_GetRight(rc); (rc).origin.x =(v); MR_SetRight(rc,__w);}
#define MR_SetRight(rc,v)       ((rc).size.width = (v) - (rc).origin.x)
#define MR_SetTop(rc,v)         {CGFloat __w=MR_GetBottom(rc); (rc).origin.y =(v); MR_SetBottom(rc,__w);}
#define MR_SetBottom(rc,v)      ((rc).size.height =(v)-(rc).origin.y)

#define MR_GetLeft(rc)          ((rc).origin.x)
#define MR_GetRight(rc)         ((rc).origin.x+(rc).size.width)
#define MR_GetTop(rc)           ((rc).origin.y)
#define MR_GetBottom(rc)        ((rc).origin.y+(rc).size.height)

// Left/Top/Right/Bottom を一括設定
#define MR_SetRectLTRB(rc,left,top,right,bottom)   ((rc).origin.x=(left), (rc).origin.y =(top), (rc).size.width=(right)-(left), (rc).size.height=(bottom)-(top))
#define MR_SetRectPoints(rc,lt,rb)   ((rc).origin = (lt), (rc).size.width=(rb).x-(lt).x, (rc).size.height=(rb).y-(lt).y)
#define MR_SetRectPointSize(rc,lt,s)   ((rc).origin=lt,(rc).size=(s))

// 中心座標の取得・設定
#define MR_GetCenterX(rc)       CGRectGetMidX(rc)
#define MR_GetCenterY(rc)       CGRectGetMidY(rc)
#define MR_GetCenter(rc)        CGPointMake(CGRectGetMidX(rc),CGRectGetMidY(rc))

// 移動
#define MR_MoveCenter(rc,point)  ((rc) = CGRectOffset((rc), (point).x -CGRectGetMidX(rc), (point).y - CGRectGetMidY(rc)))
#define MR_MoveLeftTop(rc,point) ((rc) = CGRectOffset((rc), (point).x -(rc).origin.x, (point).y - (rc).origin.y))

// サイズ取得・設定
#define MR_SetWidth(rc,w)       ((rc).size.width = (w))
#define MR_SetHeight(rc,h)      ((rc).size.height = (h))
#define MR_GetWidth(rc,h)       ((rc).size.width)
#define MR_GetHeight(rc,h)      ((rc).size.height)

#if defined(__cplusplus)
//------------------------------------------------------------------------------------------
#pragma mark - MICRect

/**
 * CGRectのラッパクラス
 */
class MICRect : public CGRect {
public:
    MICRect() {
        origin.x = 0; origin.y=0; size.width=0; size.height=0;
    }
    MICRect(const CGRect& src) {
        setRect(src);
    }
    MICRect(const CGPoint& origin) {
        setRect(origin.x, origin.y, 0, 0);
    }
    MICRect(const CGSize& size) {
        setRect(0,0,size.width,size.height);
    }
    MICRect(CGFloat w, CGFloat h) {
        setRect(0,0,w,h);
    }
    MICRect(const CGPoint& point, const CGSize& size) {
        setRect(point, size);
    }
    MICRect(const CGPoint& lt, const CGPoint& rb) {
        setRect(lt,rb);
    }
    MICRect(CGFloat l, CGFloat t, CGFloat r, CGFloat b) {
        setRect(l,t,r,b);
    }
    MICRect(NSValue* v) {
        setRect(fromValue(v));
    }
    static MICRect XYWH(CGFloat x, CGFloat y, CGFloat w, CGFloat h) {
        MICRect r;
        return r.setRectXYWH(x,y,w,h);
    }
    
    CGFloat x() const {
        return origin.x;
    }
    CGFloat y() const {
        return origin.y;
    }
    CGFloat width() const {
        return size.width;
    }
    CGFloat height() const {
        return size.height;
    }
    void setX(CGFloat x) {
        origin.x = x;
    }
    void setY(CGFloat y) {
        origin.y = y;
    }
    
    void setHeight(CGFloat v) {
        size.height = v;
    }
    void setWidth(CGFloat v) {
        size.width = v;
    }
    
    CGFloat left() const {
        return MR_GetLeft(*this);
    }
    CGFloat right() const {
        return MR_GetRight(*this);
    }
    CGFloat top() const {
        return MR_GetTop(*this);
    }
    CGFloat bottom() const {
        return origin.y+size.height;
    }
    CGFloat midX() const {
        return CGRectGetMidX(*this);
    }
    CGFloat midY() const {
        return CGRectGetMidY(*this);
    }
    
    CGPoint leftTop() const {
        return origin;
    }
    
    CGPoint rightBottom() const {
        return CGPointMake(right(), bottom());
    }
    
    CGPoint leftBottom() const {
        return CGPointMake(left(), bottom());
    }
    
    CGPoint rightTop() const {
        return CGPointMake(right(), top());
    }
    
    CGPoint midTop() const {
        return CGPointMake(midX(), top());
    }

    CGPoint midBottom() const {
        return CGPointMake(midX(), bottom());
    }
    
    CGPoint midLeft() const {
        return CGPointMake(left(), midY());
    }
    
    CGPoint midRight() const {
        return CGPointMake(right(), midY());
    }
    
    CGPoint LT() const {
        return leftTop();
    }
    
    CGPoint RB() const {
        return rightBottom();
    }
    
    CGPoint LB() const {
        return leftBottom();
    }
    CGPoint RT() const {
        return rightTop();
    }
    CGPoint MT() const {
        return midTop();
    }
    CGPoint MB() const {
        return midBottom();
    }
    CGPoint ML() const {
        return midLeft();
    }
    CGPoint MR() const {
        return midRight();
    }
    
    MICRect& setLeft(CGFloat v) {
        MR_SetLeft(*this, v);
        return *this;
    }
    MICRect& setRight(CGFloat v) {
        MR_SetRight(*this, v);
        return *this;
    }
    MICRect& setTop(CGFloat v) {
        MR_SetTop(*this, v);
        return *this;
    }
    MICRect& setBottom(CGFloat v) {
        MR_SetBottom(*this, v);
        return *this;
    }
    
    MICRect& setLeftTop(CGPoint lt) {
        setLeft(lt.x);
        setTop(lt.y);
        return *this;
    }
    MICRect& setRightBottom(CGPoint rb) {
        setRight(rb.x);
        setBottom(rb.y);
        return *this;
    }
    
    MICRect& setLeftBottom(CGPoint lb) {
        setLeft(lb.x);
        setBottom(lb.y);
        return *this;
    }
    
    MICRect& setRightTop(CGPoint rt) {
        setRight(rt.x);
        setTop(rt.y);
        return *this;
    }
    
    
    MICRect& setRect(const CGRect& src) {
        origin = src.origin;
        size = src.size;
        return *this;
    }
    
    MICRect& setRect(CGFloat left, CGFloat top, CGFloat right, CGFloat bottom) {
        MR_SetRectLTRB(*this, left, top, right, bottom);
        norimalize();
        return *this;
    }
    MICRect& setRect(const CGPoint& lt, const CGPoint& rb) {
        MR_SetRectPoints(*this, lt, rb);
        norimalize();
        return *this;
    }
    MICRect& setRect(const CGPoint& lt, const CGSize& size) {
        MR_SetRectPointSize(*this, lt, size);
        return *this;
    }
    MICRect& setRectXYWH(CGFloat x, CGFloat y,CGFloat width, CGFloat height) {
        origin.x = x; origin.y = y;
        size.width = width; size.height = height;
        return *this;
    }
    MICRect& setEmpty() {
        *this = CGRectZero;
        return *this;
    }
    MICRect& setNull() {
        *this = CGRectNull;
        return *this;
    }
    MICRect& setInfinite() {
        *this = CGRectInfinite;
        return *this;
    }
    bool isEmpty() {
        return CGRectIsEmpty(*this);
    }
    bool isNull() {
        return CGRectIsNull(*this);
    }
    bool isInfinite() {
        return CGRectIsInfinite(*this);
    }

    CGPoint center() const {
        return MR_GetCenter(*this);
    }
    
    /**
     * 中心座標を指定して矩形を移動
     */
    MICRect& moveCenter(const CGPoint& toPos) {
        MR_MoveCenter(*this, toPos);
        return *this;
    }
    
    /**
     * 左上座標を指定して矩形を移動
     */
    MICRect& moveLeftTop(const CGPoint& toPos) {
        MR_MoveLeftTop(*this, toPos);
        return *this;
    }

    MICRect& moveLeftBottom(const CGPoint& toPos);
    MICRect& moveRightTop(const CGPoint& toPos);
    MICRect& moveRightBottom(const CGPoint& toPos);

    /**
     * 移動量（ベクトル）を指定して矩形を移動
     */
    MICRect& move(const CGVector& v) {
        *this = CGRectOffset(*this, v.dx, v.dy);
        return *this;
    }
    MICRect& move(CGFloat dx, CGFloat dy) {
        *this = CGRectOffset(*this, dx, dy);
        return *this;
    }

    MICRect& norimalize() {
        if(size.width<0) {
            origin.x += size.width;
            size.width = -size.width;
        }
        if(size.height<0) {
            origin.y += size.height;
            size.height = -size.height;
        }
        return *this;
    }
    
    static CGRect unionRect(const CGRect& r1, const CGRect& r2) {
        return CGRectUnion(r1,r2);
    }
    
    MICRect& unionRect(const CGRect& r) {
        return setRect(CGRectUnion(*this, r));
    }

    static CGRect intersectRect(const CGRect& r1, const CGRect& r2) {
        return CGRectIntersection(r1,r2);
    }
    
    MICRect& intersectRect(const CGRect& r)  {
        return setRect(CGRectIntersection(*this, r));
    }
    
    bool containsPoint(const CGPoint& p) const {
        return CGRectContainsPoint(*this, p);
    }

    static bool containsPoint(const CGRect& rc, const CGPoint& p) {
        return CGRectContainsPoint(rc, p);
    }
    
    // Windows風エイリアス
    bool ptInRect(const CGPoint& p) const {
        return CGRectContainsPoint(*this, p);
    }

    
    MICRect& inflate(CGFloat l, CGFloat t, CGFloat r, CGFloat b) {
        l= left()-l;
        t= top()-t;
        r=right()+r;
        b=bottom()+b;
        
        setRect(l,t,r,b);
        return *this;
    }
    MICRect& deflate(CGFloat l, CGFloat t, CGFloat r, CGFloat b) {
        l= left()+l;
        t= top()+t;
        r=right()-r;
        b=bottom()-b;
        
        setRect(l,t,r,b);
        return *this;
    }
    MICRect& inflate(CGFloat width) {
        return inflate(width/2, width/2, width/2, width/2);
    }
    MICRect& deflate(CGFloat width) {
        return deflate(width/2, width/2, width/2, width/2);
    }
    
    MICRect& inflate(CGFloat width, CGFloat height) {
        return inflate(width/2, height/2, width/2, height/2);
    }
    MICRect& deflate(CGFloat width, CGFloat height) {
        return deflate(width/2, height/2, width/2, height/2);
    }
    
    MICRect& inflate(const CGSize& size) {
        return inflate(size.width, size.height);
    }
    MICRect& deflate(const CGSize& size) {
        return deflate(size.width, size.height);
    }
    
    MICRect& inflate(const UIEdgeInsets& insets) {
        return inflate(insets.left, insets.top, insets.right, insets.bottom);
    }
    MICRect& deflate(const UIEdgeInsets& insets) {
        return deflate(insets.left, insets.top, insets.right, insets.bottom);
    }

    /**
     * outer矩形に対して縦・横方向をセンタリングする。
     */
    MICRect& moveToCenterOfOuterRect(const MICRect& outer) {
        return moveCenter(outer.center());
    }
    
    /**
     * outer矩形に対して縦方向をセンタリングする。
     */
    MICRect& moveToVCenterOfOuterRect(const MICRect& outer) {
        CGPoint c = outer.center();
        c.x = center().x;
        return moveCenter(c);
    }
    /**
     * outer矩形に対して横方向をセンタリングする。
     */
    MICRect& moveToHCenterOfOuterRect(const MICRect& outer) {
        CGPoint c = outer.center();
        c.y = center().y;
        return moveCenter(c);
    }
    
    /**
     * サイズを変えずにtopの座標を移動
     */
    MICRect& moveTop(CGFloat y) {
        origin.y = y;
        return *this;
    }
    /**
     * サイズを変えずにbottomの座標を移動
     */
    MICRect& moveBottom(CGFloat y) {
        origin.y += (y-bottom());
        return *this;
    }
    
    /**
     * サイズを変えずにleftの座標を移動
     */
    MICRect& moveLeft(CGFloat x) {
        origin.x = x;
        return *this;
    }
    
    /**
     * サイズを変えずにrightの座標を移動
     */
    MICRect& moveRight(CGFloat x) {
        origin.x += (x-right());
        return *this;
    }
    
    
    bool operator == (const CGRect& rc) const {
        return CGRectEqualToRect(*this,rc);
    }
    
    bool operator != (const CGRect& rc) const {
        return !CGRectEqualToRect(*this,rc);
    }
    
    MICRect& operator += (const UIEdgeInsets& margin) {
        return inflate(margin);
    }
    MICRect& operator -= (const UIEdgeInsets& margin) {
        return deflate(margin);
    }
    
    MICRect& operator += (const CGVector& v) {
        origin.x += v.dx;
        origin.y += v.dy;
        return *this;
    }

    MICRect& operator -= (const CGVector& v) {
        origin.x -= v.dx;
        origin.y -= v.dy;
        return *this;
    }

    MICRect& transpose() {
        setRectXYWH(origin.y, origin.x, size.height, size.width);
        return *this;
    }
    
    static CGRect transpose(const CGRect& r) {
        return CGRectMake(r.origin.y, r.origin.x, r.size.height, r.size.width);
    }
   
    MICRect partialLeftRect(CGFloat width) const {
        MICRect r = *this;
        r.deflate(0,0,(size.width-width),0);
        return r;
    }
    MICRect partialRightRect(CGFloat width) const {
        MICRect r = *this;
        r.deflate((size.width-width),0,0,0);
        return r;
    }
    MICRect partialHorzCenterRect(CGFloat width) const {
        MICRect r = *this;
        r.deflate((size.width-width),0);
        return r;
    }

    MICRect partialTopRect(CGFloat height) const {
        MICRect r = *this;
        r.deflate(0,0,0,(size.height-height));
        return r;
    }
    MICRect partialBottomRect(CGFloat height) const {
        MICRect r = *this;
        r.deflate(0,(size.height-height),0,0);
        return r;
    }
    MICRect partialVertCenterRect(CGFloat height) const {
        MICRect r = *this;
        r.deflate(0,(size.height-height));
        return r;
    }
    
    static CGRect fromValue(NSValue* value) {
        return [value CGRectValue];
    }

    NSValue* asValue() {
        return [NSValue valueWithCGRect:*this];
    }
    
    static CGRect zero() {
        return CGRectZero;
    }
    
    MICRect& transform(const CGAffineTransform& tr) {
        *this = (CGRectApplyAffineTransform(*this, tr));
        return *this;
    }
};

inline CGRect operator +(const CGRect& rc, const UIEdgeInsets& margin) {
    MICRect mr(rc);
    return mr.inflate(margin);
}

inline CGRect operator -(const CGRect& rc, const UIEdgeInsets& margin) {
    MICRect mr(rc);
    return mr.deflate(margin);
}

inline CGRect operator +(const CGRect& rc, const CGVector& v) {
    MICRect mr(rc);
    mr+=v;
    return mr;
}

inline CGRect operator -(const CGRect& rc, const CGVector& v) {
    MICRect mr(rc);
    mr-=v;
    return mr;
}


//------------------------------------------------------------------------------------------
#pragma mark - MICSize

/**
 *　ついでに、MICSizeのラッパクラス
 */
class MICSize : public CGSize {
public:
    MICSize() {
        width = height = 0;
    }
    MICSize(const CGSize& src) {
        width = src.width;
        height = src.height;
    }
    MICSize(const CGVector& v) {
        width = v.dx;
        height = v.dy;
    }
    MICSize(CGFloat s) {
        width = height = s;
    }
    MICSize(CGFloat w, CGFloat h) {
        width = w;
        height = h;
    }
    
    MICSize(NSValue* value) {
        set(fromValue(value));
    }
    
    CGFloat x() const {
        return width;
    }
    CGFloat y() const {
        return height;
    }
    bool operator == (const CGSize& s) const {
        return CGSizeEqualToSize(*this, s);
    }
    bool operator != (const CGSize& s) const {
        return !CGSizeEqualToSize(*this, s);
    }
    
    operator CGVector() {
        return CGVectorMake(width,height);
    }
    
    MICSize& set(CGFloat w, CGFloat h) {
        width = w;
        height = h;
        return *this;
    }
    
    MICSize& set(const CGSize& size) {
        return set(size.width,size.height);
    }
    
    bool isEmpty() {
        return width == 0 && height == 0;
    }
    
    static bool isEmpty(const CGSize& size){
        return size.width ==0 && size.height==0;
    }
    
    MICSize& setEmpty() {
        width = height = 0;
        return *this;
    }
    
    MICSize& transpose() {
        CGFloat v = width;
        width = height;
        height = v;
        return *this;
    }

    MICSize& inflate(CGFloat dw, CGFloat dh) {
        width+=dw;
        height+=dh;
        return *this;
    }
    MICSize& inflate(CGFloat d) {
        return inflate(d,d);
    }
    MICSize& inflate(const UIEdgeInsets& insets) {
        return inflate(insets.left+insets.right, insets.top+insets.bottom);
    }
    MICSize& deflate(CGFloat dw, CGFloat dh) {
        width-=dw;
        height-=dh;
        return *this;
    }
    MICSize& deflate(const UIEdgeInsets& insets) {
        return deflate(insets.left+insets.right, insets.top+insets.bottom);
        return *this;
    }
    MICSize& deflate(CGFloat d) {
        return deflate(d,d);
    }
    
    static CGSize transpose(const CGSize& size) {
        return CGSizeMake(size.height, size.width);
    }
    
    static CGSize fromValue(NSValue* value) {
        return [value CGSizeValue];
    }
    
    NSValue* asValue() {
        return [NSValue valueWithCGSize:*this];
    }
    
    static CGSize zero() {
        return CGSizeZero;
    }
    
    MICSize& transform(const CGAffineTransform& tr) {
        *this = (CGSizeApplyAffineTransform(*this, tr));
        return *this;
    }
    
    static CGSize max(const CGSize& s1, const CGSize& s2);
    static CGSize min(const CGSize& s1, const CGSize& s2);
};

inline CGSize operator +(const CGSize& size, const UIEdgeInsets& margin) {
    MICSize ms(size);
    return ms.inflate(margin);
}

inline CGSize operator -(const CGSize& size, const UIEdgeInsets& margin) {
    MICSize ms(size);
    return ms.deflate(margin);
}

inline CGSize MICSize::max(const CGSize& s1, const CGSize& s2) {
    return MICSize(MAX(s1.width, s2.width), MAX(s1.height,s2.height));
}
inline CGSize MICSize::min(const CGSize& s1, const CGSize& s2) {
    return MICSize(MIN(s1.width, s2.width), MIN(s1.height,s2.height));
}

//------------------------------------------------------------------------------------------
#pragma mark - MICPoint

/**
 *　CGPointのラッパクラスも。
 */
class MICPoint : public CGPoint {
public:
    MICPoint() {
        x = y = 0;
    }
    MICPoint(CGFloat sx, CGFloat sy) {
        set(sx,sy);
    }
    MICPoint(const CGPoint& p) {
        x = p.x; y=p.y;
    }
    MICPoint(NSValue* value) {
        set(fromValue(value));
    }
    
    
    bool operator == (const CGPoint& s) const {
        return CGPointEqualToPoint(*this, s);
    }
    bool operator != (const CGPoint& s) const {
        return !CGPointEqualToPoint(*this, s);
    }
    
//    CGVector operator - (const CGPoint s) const {
//        return CGVectorMake(x-s.x, y-s.y);
//    }
//    
//    CGVector operator + (const CGPoint s) const {
//        return CGVectorMake(x+s.x, y+s.y);
//    }
    
    MICPoint& operator += (const CGVector& v) {
        x += v.dx;
        y += v.dy;
        return *this;
    }
    MICPoint& operator -= (const CGVector& v) {
        x -= v.dx;
        y -= v.dy;
        return *this;
    }

    MICPoint& transpose() {
        CGFloat v = x;
        x = y;
        y = v;
        return *this;
    }
    
    MICPoint& set(const CGPoint& src) {
        x = src.x;
        y = src.y;
        return *this;
    }
    MICPoint& set(CGFloat sx, CGFloat sy) {
        x = sx;
        y = sy;
        return *this;
    }
    
    
    static CGPoint transpose(CGPoint p) {
        return CGPointMake(p.y, p.x);
    }
    
    static CGPoint fromValue(NSValue* value) {
        return [value CGPointValue];
    }
    
    NSValue* asValue() {
        return [NSValue valueWithCGPoint:*this];
    }
  
    bool isContained(const CGRect& rc) {
        return CGRectContainsPoint(rc, *this);
    }
    
    static CGPoint zero() {
        return CGPointZero;
    }
    
    MICPoint& transform(const CGAffineTransform& tr) {
        *this = (CGPointApplyAffineTransform(*this, tr));
        return *this;
    }
};

inline CGVector operator -(const CGPoint& to, const CGPoint& from) {
    return CGVectorMake(to.x - from.x, to.y-from.y);
}

inline CGPoint operator +(const CGPoint& p, const CGVector& v) {
    return CGPointMake(p.x + v.dx, p.y + v.dy);
}

inline CGPoint operator -(const CGPoint& p, const CGVector& v) {
    return CGPointMake(p.x - v.dx, p.y - v.dy);
}

//------------------------------------------------------------------------------------------
#pragma mark - MICVector

/**
 *　CGVectorのラッパクラス
 */
class MICVector : public CGVector {
public:
    MICVector() {
        dx = dy = 0;
    }
    MICVector(CGFloat x, CGFloat y) {
        set(x,y);
    }
    
    // CGPoint --> CGVector
    MICVector(CGPoint pos) {
        dx = pos.x; dy = pos.y;
    }
    
    MICVector(const CGVector& p) {
        dx = p.dx; dy = p.dy;
    }
//    MICVector(const CGPoint& from, const CGPoint& to) {
//        dx = to.x - from.x;
//        dy = to.y - from.y;
//    }
    MICVector(NSValue* value) {
        set(fromValue(value));
    }
    
    bool operator == (const CGVector& s) const {
        return dx == s.dx && dy == s.dy;
    }
    bool operator != (const CGVector& s) const {
        return dx != s.dx || dy != s.dy;
    }
    
    MICVector& operator+=(const CGVector& s) {
        dx += s.dx;
        dy += s.dy;
        return *this;
    }
    MICVector& operator-=(const CGVector& s) {
        dx -= s.dx;
        dy -= s.dy;
        return *this;
    }
    
//    CGVector operator+(const CGVector& s) {
//        return CGVectorMake(dx+s.dx, dy+s.dy);
//    }
//    CGVector operator-(const CGVector& s) {
//        return CGVectorMake(dx-s.dx, dy-s.dy);
//    }
    
    MICVector& set(CGFloat x, CGFloat y) {
        dx = x;
        dy = y;
        return *this;
    }
    MICVector& set(const CGVector& src) {
        dx = src.dx;
        dy = src.dy;
        return *this;
    }
    
    MICVector& transpose() {
        CGFloat v = dx;
        dx = dy;
        dy = v;
        return *this;
    }
    static CGVector transpose(const CGVector p) {
        return CGVectorMake(p.dy, p.dx);
    }
    
    static CGVector fromValue(NSValue* value) {
        return [value CGVectorValue];
    }
    
    NSValue* asValue() {
        return [NSValue valueWithCGVector:*this];
    }
    
    CGFloat magnitude() const {
        return sqrtf(dx*dx+dy*dy);
    }
    
    static CGVector zero() {
        // return CGVectorZero; なんと！この定義はない。
        return MICVector(0,0);
    }
    
};

inline CGVector operator+(const CGVector& d, const CGVector& s) {
    return CGVectorMake(d.dx+s.dx, d.dy+s.dy);
}
inline CGVector operator-(const CGVector& d, const CGVector& s) {
    return CGVectorMake(d.dx-s.dx, d.dy-s.dy);
}

// MICRectのメンバー：MICVectorを使うので、ここにインラインで定義する
inline MICRect& MICRect::moveLeftBottom(const CGPoint& toPos) {
    return move(toPos-leftBottom());
}

inline MICRect& MICRect::moveRightTop(const CGPoint& toPos) {
    return move(toPos-rightTop());
}

inline MICRect& MICRect::moveRightBottom(const CGPoint& toPos) {
    return move(toPos-rightBottom());
}


//------------------------------------------------------------------------------------------
#pragma mark - MICEdgeInsets

/**
 *　UIEdgeInsetsのラッパクラス
 */
class MICEdgeInsets : public UIEdgeInsets {
public:
    MICEdgeInsets() {
        left = top = right = bottom = 0;
    }
    MICEdgeInsets(const UIEdgeInsets& src) {
        set(src);
    }
    /**
     * 周囲に同じサイズ(w)のマージンをセットする
     */
    MICEdgeInsets(CGFloat w) {
        set(w);
    }
    /**
     * 左右にh, 上下にvのマージンをセットする
     */
    MICEdgeInsets(CGFloat h, CGFloat v) {
        set(h,v);
    }
    MICEdgeInsets(CGFloat l, CGFloat t, CGFloat r, CGFloat b) {
        set(l,t,r,b);
    }
    MICEdgeInsets(const CGSize& lt, const CGSize& rb) {
        set(lt,rb);
    }
    MICEdgeInsets(const CGRect& outer, const CGRect& inner) {
        set(outer,inner);
    }
    MICEdgeInsets(NSValue* value) {
        set(fromValue(value));
    }
    
    MICEdgeInsets& set(const UIEdgeInsets& src) {
        left = src.left;
        top = src.top;
        right = src.right;
        bottom = src.bottom;
        return *this;
    }
    MICEdgeInsets& set(CGFloat w) {
        set(w,w,w,w);
        return *this;
    }
    MICEdgeInsets& set(CGFloat h, CGFloat v) {
        set(h,v,h,v);
        return *this;
    }
    MICEdgeInsets& set(CGFloat l, CGFloat t, CGFloat r, CGFloat b) {
        left = l;
        top = t;
        right = r;
        bottom = b;
        return *this;
    }
    MICEdgeInsets& set(const CGSize& lt, const CGSize& rb) {
        left = lt.width;
        top = lt.height;
        right = rb.width;
        bottom = rb.height;
        return *this;
    }
    MICEdgeInsets& set(const CGRect& outer, const CGRect& inner) {
        left = MR_GetLeft(inner) - MR_GetLeft(outer);
        top = MR_GetTop(inner) - MR_GetTop(outer);
        right = MR_GetRight(outer) - MR_GetRight(inner);
        bottom = MR_GetBottom(outer) - MR_GetBottom(inner);
        return *this;
    }
    
    bool operator==(const UIEdgeInsets& s) const {
        return UIEdgeInsetsEqualToEdgeInsets(*this, s);
    }

    bool operator!=(const UIEdgeInsets& s) const {
        return !UIEdgeInsetsEqualToEdgeInsets(*this, s);
    }
    
    MICEdgeInsets& operator+=(const UIEdgeInsets& s) {
        left += s.left;
        top += s.top;
        right += s.right;
        bottom += s.bottom;
        return *this;
    }

    MICEdgeInsets& operator-=(const UIEdgeInsets& s) {
        left -= s.left;
        top -= s.top;
        right -= s.right;
        bottom -= s.bottom;
        return *this;
    }
    
    UIEdgeInsets operator +(const UIEdgeInsets& s) {
        return MICEdgeInsets(left+s.left, top+s.top, right+s.right, bottom+s.bottom);
    }

    UIEdgeInsets operator -(const UIEdgeInsets& s) {
        return MICEdgeInsets(left-s.left, top-s.top, right-s.right, bottom-s.bottom);
    }

    MICEdgeInsets& transpose() {
        set(top,left,bottom,right);
        return *this;
    }
    
    static UIEdgeInsets transpose(const UIEdgeInsets& e) {
        return MICEdgeInsets(e.top, e.left, e.bottom,e.right);
    }
    
    CGFloat dh() const {
        return top+bottom;
    }
    static CGFloat dh(const UIEdgeInsets& v) {
        return v.top + v.bottom;
    }
    
    CGFloat dw() const {
        return left + right;
    }
    
    static CGFloat dw(const UIEdgeInsets& v) {
        return v.left + v.right;
    }
    
    static UIEdgeInsets fromValue(NSValue* value) {
        return [value UIEdgeInsetsValue];
    }
    
    NSValue* asValue() {
        return [NSValue valueWithUIEdgeInsets:*this];
    }
  
    bool isEmpty() {
        return left==0 && right==0 && top==0 && bottom == 0;
    }
    
    static bool isEmpty(const UIEdgeInsets& v) {
        return v.left ==0 && v.right ==0 && v.top==0 && v.bottom==0;
    }
    
    static UIEdgeInsets zero() {
        return UIEdgeInsetsZero;
    }
};

inline UIEdgeInsets operator -(const CGRect& outer, const CGRect& inner) {
    return MICEdgeInsets(outer, inner);
}

inline UIEdgeInsets operator+(const UIEdgeInsets& d, const UIEdgeInsets& s) {
    return MICEdgeInsets(d.left+s.left, d.top+s.top, d.right+s.right, d.bottom+s.bottom);
}
inline UIEdgeInsets operator-(const UIEdgeInsets& d, const UIEdgeInsets& s) {
    return MICEdgeInsets(d.left-s.left, d.top-s.top, d.right-s.right, d.bottom-s.bottom);
}



/**
 * ビューの座標系変換機能をもたせた、ちょっとイマイチなRectクラス。
 */
class MICViewRect {
private:
    __weak UIView* _owner;
    CGRect  _rect;
public:
    CGRect rect() {
        return _rect;
    }
    CGPoint point() {
        return _rect.origin;
    }
    
    MICViewRect() {
        _rect = CGRectZero;
        _owner = nil;
    }
    MICViewRect( const MICViewRect& src) {
        _rect = src._rect;
        _owner = src._owner;
    }

    MICViewRect(UIView* owner){
        _rect = CGRectZero;
        _owner = owner;
    }
    MICViewRect(UIView* owner, const CGRect& src) {
        _rect = src;
        _owner = owner;
    }
    MICViewRect(UIView* owner, const CGPoint& src) {
        _rect.origin = src;
        _rect.size = CGSizeZero;
        _owner = owner;
    }
    
    void setOwner(UIView* owner) {
        _owner = owner;
    }
    void setRect(const CGRect& rect) {
        _rect = rect;
    }
    void setPoint(const CGPoint& point) {
        _rect.origin = point;
    }
    void changeOwner(UIView* newOwner) {
        if(_owner == newOwner) {
            return;
        }
        _rect = [_owner convertRect:_rect toView:newOwner];
        _owner = newOwner;
    }
    
    MICViewRect getRectOnView(UIView* view) const {
        if(_owner == view) {
            return *this;
        }
        return MICViewRect(view, [_owner convertRect:_rect toView:view]);
    }
    
    void getRectOnView(UIView* view, CGRect& dst) const {
        dst = getRectOnView(view).rect();
    }
    
    void getPointOnView(UIView* view, CGPoint& dst) const {
        dst = getRectOnView(view).point();
    }
    
    void setRectFromView(UIView* view, const CGRect& src) {
        if(view == _owner) {
            _rect = src;
        } else {
            _rect = [_owner convertRect:src fromView:view];
        }
    }
    
    void setRectFromView(const MICViewRect& src) {
        setRectFromView(src._owner, src._rect);
    }
    
    void setPointFromView(UIView* view, const CGPoint& src) {
        if(view == _owner) {
            _rect.origin = src;
        } else {
            _rect.origin = [_owner convertPoint:src fromView:view];
        }
    }
    
    operator CGRect&() {
        return _rect;
    }
    operator CGPoint&() {
        return _rect.origin;
    }
    operator MICRect() {
        return _rect;
    }
    operator MICPoint() {
        return _rect.origin;
    }
};

#endif  // defined(__cplusplus)

#endif  // __MICUiRectUtil_h
