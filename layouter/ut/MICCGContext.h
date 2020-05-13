//
//  MICCGContext.h
//  LayoutDemo
//
//  Created by @toyota-m2k on 2014/12/03.
//  Copyright (c) 2014年 @toyota-m2k. All rights reserved.
//
#import <UIKit/UIKit.h>

#define MIC_RADIAN(deg) ((deg)*M_PI/180)

#if defined(__cplusplus)

#pragma mark - Releasing Resources function

template<typename T> inline void MICReleaseResource(T r) {
    NSCAssert(false, @"cannot release resource.");
    return;
}

template <> inline void MICReleaseResource<CGPathRef>(CGPathRef r) {
    CGPathRelease(r);
}

template <> inline void MICReleaseResource<CGMutablePathRef>(CGMutablePathRef r) {
    CGPathRelease(r);
}

template <> inline void MICReleaseResource<CGContextRef>(CGContextRef r) {
    CGContextRelease(r);
}

template <> inline void MICReleaseResource<CGImageRef>(CGImageRef r) {
    CGImageRelease(r);
}

template<> inline void MICReleaseResource<CGFontRef>(CGFontRef r) {
    CGFontRelease(r);
}

template<> inline void MICReleaseResource<CGColorRef>(CGColorRef r) {
    CGColorRelease(r);
}

#pragma mark - MICCGResource template class

template <typename T> class MICCGResource {
protected:
    bool _retained;
    T _res;

private:
    MICCGResource(const MICCGResource& src);
    
public:
    MICCGResource() {
        _retained = false;
        _res = NULL;
    }
    
    MICCGResource(T res, bool retained) {
        _retained = retained;
        _res = res;
    }
   
    virtual ~MICCGResource() {
        release();
    }

    void setResource(T res, bool retained) {
        release();
        _retained = retained;
        _res = res;
    }
    
    void release() {
        if(_retained && _res!=NULL) {
            MICReleaseResource<T>(_res);
            _res = NULL;
        }
    }
    
    T detach() {
        T r = _res;
        _res = NULL;
        _retained = false;
        return r;
    }
    
    operator T&() {
        return _res;
    }
};

#pragma mark - MICCGImage

/**
 * CGImageRef のラッパークラス
 */
class MICCGImage : public MICCGResource<CGImageRef> {
public:
    MICCGImage() {
    }
    
    MICCGImage(CGImageRef image, bool retained=true) : MICCGResource<CGImageRef>(image,retained) {
    }
};

#pragma mark - MICCGFont

/**
 * CGFontRef のラッパークラス
 */
class MICCGFont : public MICCGResource<CGFontRef> {
public:
    MICCGFont() {
    }
    
    MICCGFont(CGFontRef font, bool retained=true) : MICCGResource<CGFontRef>(font, retained) {
    }
    
    MICCGFont(UIFont* font) : MICCGResource<CGFontRef>(CGFontCreateWithFontName((CFStringRef)font.fontName),true) {
        
    }
};

#pragma mark - MICCGUIColor

/**
 * CGColorRefのラッパークラス
 */
class MICCGColor : public MICCGResource<CGColorRef> {
public:
    MICCGColor() {
    }
    
    MICCGColor(CGColorRef color, bool retained=true) : MICCGResource<CGColorRef>(color, retained) {
    }
    
    MICCGColor(UIColor* uicolor) {
        fromUIColor(uicolor);
    }

    MICCGColor(UIColor* uicolor, CGFloat alpha) :MICCGResource<CGColorRef>(CGColorCreateCopyWithAlpha(uicolor.CGColor,alpha), true) {
    }
    
    MICCGColor(CGFloat r, CGFloat g, CGFloat b, CGFloat a) {
        UIColor* c = [UIColor colorWithRed:r green:g blue:b alpha:a];
        fromUIColor(c);
    }
    
    void fromUIColor(UIColor* uicolor) {
        setResource(CGColorCreateCopy(uicolor.CGColor), true);
    }
    
    UIColor* asUIColor() {
        return [UIColor colorWithCGColor:_res];
    }
};


#pragma mark - MICCGPath

/**
 * CGPathRef のラッパークラス
 */
class MICCGPath : public MICCGResource<CGPathRef> {
public:
    MICCGPath() {
    }
    
    MICCGPath(CGPathRef path, bool retained=true)
    : MICCGResource<CGPathRef>(path,retained) {
    }
};

class MICCGMutablePath : public MICCGResource<CGMutablePathRef> {
public:
    MICCGMutablePath()
    : MICCGResource<CGMutablePathRef>(CGPathCreateMutable(), true){
    }
    
    MICCGMutablePath(CGMutablePathRef path, bool retained=true)
    : MICCGResource<CGMutablePathRef>(path,retained) {
    }
    
    const MICCGMutablePath& closePath() const {
        CGPathCloseSubpath(_res);
        return *this;
    }
    
    const MICCGMutablePath& moveTo(
                       CGFloat x,
                       CGFloat y,
                       CGAffineTransform* m = NULL
                       ) const {
        CGPathMoveToPoint(_res, m, x, y);
        return *this;
    }
    const MICCGMutablePath& moveTo(const CGPoint p, CGAffineTransform* m = NULL) const {
        moveTo(p.x, p.y, m);
        return *this;
    }
    
    const MICCGMutablePath& lineTo(
                       CGFloat x,
                       CGFloat y,
                       CGAffineTransform* m = NULL
                       ) const {
        CGPathAddLineToPoint(_res, m, x, y);
        return *this;
    }
    const MICCGMutablePath& lineTo( const CGPoint& p, CGAffineTransform* m = NULL) const {
        lineTo(p.x, p.y, m);
        return *this;
    }
    
    
    const MICCGMutablePath& addCurveToPoint(
                                CGFloat cp1x,
                                CGFloat cp1y,
                                CGFloat cp2x,
                                CGFloat cp2y,
                                CGFloat x,
                                CGFloat y,
                                CGAffineTransform* m = NULL
                                ) const {
        CGPathAddCurveToPoint(_res, m, cp1x, cp1y, cp2x, cp2y, x, y);
        return *this;
    }
    const MICCGMutablePath& addCurveToPoint(
                                CGPoint cp1,
                                CGPoint cp2,
                                CGPoint p,
                                CGAffineTransform* m = NULL
                                ) const {
        addCurveToPoint(cp1.x, cp1.y, cp2.x, cp2.y, p.x, p.y, m);
        return *this;
    }
    
    const MICCGMutablePath& addQuadCurveToPoint(
                                    CGFloat cp1x,
                                    CGFloat cp1y,
                                    CGFloat x,
                                    CGFloat y,
                                    CGAffineTransform* m = NULL
                                    ) const {
        CGPathAddQuadCurveToPoint(_res, m, cp1x, cp1y, x, y);
        return *this;
    }
    
    const MICCGMutablePath& addQuadCurveToPoint(
                                    CGPoint cp1,
                                    CGPoint p,
                                    CGAffineTransform* m = NULL
                                    ) const {
        addQuadCurveToPoint(cp1.x, cp1.y, p.x, p.y, m);
        return *this;
    }
    
    /* Add an arc of a circle to `path', possibly preceded by a straight line
     segment. The arc is approximated by a sequence of Bézier curves. The
     center of the arc is `(x,y)'; `radius' is its radius. `startAngle' is the
     angle to the first endpoint of the arc, measured counter-clockwise from
     the positive x-axis. `startAngle + delta' is the angle to the second
     endpoint of the arc. If `delta' is positive, then the arc is drawn
     counter-clockwise; if negative, clockwise. `startAngle' and `delta' are
     measured in radians. If `matrix' is non-NULL, then the constructed Bézier
     curves representing the arc will be transformed by `matrix' before they
     are added to the path. */
    //
    //    CG_EXTERN void CGPathAddRelativeArc(CGMutablePathRef cg_nullable path,
    //                                        const CGAffineTransform * __nullable matrix, CGFloat x, CGFloat y,
    //                                        CGFloat radius, CGFloat startAngle, CGFloat delta)
    const MICCGMutablePath& addArc (
                                    CGFloat x,
                                    CGFloat y,
                                    CGFloat radius,
                                    CGFloat startAngle,
                                    CGFloat delta,
                                    CGAffineTransform* m = NULL
                                    ) const {
        CGPathAddRelativeArc(_res, m, x, y, radius, startAngle, delta);
        return *this;
    }

    
    /* Add an arc of a circle to `path', possibly preceded by a straight line
     segment. The arc is approximated by a sequence of Bézier curves. `(x, y)'
     is the center of the arc; `radius' is its radius; `startAngle' is the
     angle to the first endpoint of the arc; `endAngle' is the angle to the
     second endpoint of the arc; and `clockwise' is true if the arc is to be
     drawn clockwise, false otherwise. `startAngle' and `endAngle' are
     measured in radians. If `m' is non-NULL, then the constructed Bézier
     curves representing the arc will be transformed by `m' before they are
     added to `path'.
     
     Note that using values very near 2π can be problematic. For example,
     setting `startAngle' to 0, `endAngle' to 2π, and `clockwise' to true will
     draw nothing. (It's easy to see this by considering, instead of 0 and 2π,
     the values ε and 2π - ε, where ε is very small.) Due to round-off error,
     however, it's possible that passing the value `2 * M_PI' to approximate
     2π will numerically equal to 2π + δ, for some small δ; this will cause a
     full circle to be drawn.
     
     If you want a full circle to be drawn clockwise, you should set
     `startAngle' to 2π, `endAngle' to 0, and `clockwise' to true. This avoids
     the instability problems discussed above. */
    //
    //    CG_EXTERN void CGPathAddArc(CGMutablePathRef cg_nullable path,
    //                                const CGAffineTransform * __nullable m,
    //                                CGFloat x, CGFloat y, CGFloat radius, CGFloat startAngle, CGFloat endAngle,
    //                                bool clockwise)
    const MICCGMutablePath& addArc (
                        CGFloat x,
                        CGFloat y,
                        CGFloat radius,
                        CGFloat startAngle,
                        CGFloat endAngle,
                        bool clockwise,
                        CGAffineTransform* m = NULL
                        ) const {
        CGPathAddArc(_res, m, x, y, radius, startAngle, endAngle, clockwise);
        return *this;
    }
    
    /* Add an arc of a circle to `path', possibly preceded by a straight line
     segment. The arc is approximated by a sequence of Bézier curves. `radius'
     is the radius of the arc. The resulting arc is tangent to the line from
     the current point of `path' to `(x1, y1)', and the line from `(x1, y1)'
     to `(x2, y2)'. If `m' is non-NULL, then the constructed Bézier curves
     representing the arc will be transformed by `m' before they are added to
     `path'. */
    //
    //    CG_EXTERN void CGPathAddArcToPoint(CGMutablePathRef cg_nullable path,
    //                                       const CGAffineTransform * __nullable m, CGFloat x1, CGFloat y1,
    //                                       CGFloat x2, CGFloat y2, CGFloat radius)

    const MICCGMutablePath& addArcToPoint(
                              const CGPoint& p1,
                              const CGPoint& p2,
                              CGFloat radius,
                              CGAffineTransform* m = NULL
                              ) const {
        CGPathAddArcToPoint(_res, m, p1.x, p1.y, p2.x, p2.y, radius);
        return *this;
    }
    
    CGPoint getCurrentPoint() const {
        return CGPathGetCurrentPoint(_res);
    }
};

#pragma mark - MICCGContext

/**
 * CGContextRef のラッパークラス
 */
class MICCGContext : public MICCGResource<CGContextRef> {
public:
    MICCGContext() {
        getCurrentContext();
    }

    MICCGContext(bool getContext) {
        if(getContext) {
            getCurrentContext();
        }
    }
    
    MICCGContext(const CGContextRef& ctx,bool retained)
        : MICCGResource<CGContextRef>(ctx, retained) {
    }
    
    void getCurrentContext() {
        release();
        _res = UIGraphicsGetCurrentContext();
        _retained = false;
    }
    
public:
#pragma mark - Path
    
    class Path {
    private:
        const CGContextRef& _context;
        
    public:
        Path(const CGContextRef& ctx) : _context(ctx){
            CGContextBeginPath(_context);
        }
        Path(const Path& src) : _context(src._context) {
        }
        
        const Path& closePath() const {
            CGContextClosePath(_context);
            return *this;
        }
        
        const Path& moveTo(
                    CGFloat x,
                    CGFloat y
                    ) const {
            CGContextMoveToPoint(_context, x, y);
            return *this;
        }
        const Path& moveTo(const CGPoint p) const {
            moveTo(p.x, p.y);
            return *this;
        }
        
        const Path& lineTo(
                     CGFloat x,
                     CGFloat y
                     ) const {
            CGContextAddLineToPoint(_context, x, y);
            return *this;
        }
        const Path& lineTo( const CGPoint& p) const {
            lineTo(p.x, p.y);
            return *this;
        }
        
        
        const Path& addArc (
                      CGFloat x,
                      CGFloat y,
                      CGFloat radius,
                      CGFloat startAngle,
                      CGFloat endAngle,
                      bool clockwise
                     ) const {
            CGContextAddArc(_context, x, y, radius, startAngle, endAngle, clockwise?1:0);
            return *this;
        }
        
        const Path& addArcToPoint(
                           CGFloat x1,
                           CGFloat y1,
                           CGFloat x2,
                           CGFloat y2,
                           CGFloat radius
                           ) const {
            CGContextAddArcToPoint(_context, x1, y1, x2, y2, radius);
            return *this;
        }
        
        const Path& addArcToPoint(
                           const CGPoint& p1,
                           const CGPoint& p2,
                           CGFloat radius
                           ) const {
            return addArcToPoint(p1.x, p1.y, p2.x, p2.y, radius);
        }
        
        const Path& addCurveToPoint(
                             CGFloat cp1x,
                             CGFloat cp1y,
                             CGFloat cp2x,
                             CGFloat cp2y,
                             CGFloat x,
                             CGFloat y
                             ) const {
            CGContextAddCurveToPoint(_context, cp1x, cp1y, cp2x, cp2y, x, y);
            return *this;
        }
        const Path& addCurveToPoint(
                                    CGPoint cp1,
                                    CGPoint cp2,
                                    CGPoint p
                                    ) const {
            CGContextAddCurveToPoint(_context, cp1.x, cp1.y, cp2.x, cp2.y, p.x, p.y);
            return *this;
        }

        const Path& addQuadCurveToPoint(
                                    CGFloat cp1x,
                                    CGFloat cp1y,
                                    CGFloat x,
                                    CGFloat y
                                    ) const {
            CGContextAddQuadCurveToPoint(_context, cp1x, cp1y, x, y);
            return *this;
        }
        const Path& addQuadCurveToPoint(
                                        CGPoint cp1,
                                        CGPoint p
                                        ) const {
            CGContextAddQuadCurveToPoint(_context, cp1.x, cp1.y, p.x, p.y);
            return *this;
        }

        const Path& addLine(
                     CGFloat x,
                     CGFloat y
                     ) const {
            return lineTo(x,y);
        }
        
        const Path& addPath(
                     const CGPathRef& path
                     ) const {
            CGContextAddPath(_context, path);
            return *this;
        }
        
        const Path& addRect(
                     const CGRect& rect
                     ) const {
            CGContextAddRect(_context, rect);
            return *this;
        }
        
        CGPathRef copyPath() const {
            return CGContextCopyPath(_context);
        }
        
        void copyPath(MICCGPath& r) const {
            r.release();
            r.setResource(copyPath(), true);
        }
        
        CGPoint getCurrentPoint() const {
            return CGContextGetPathCurrentPoint(_context);
        }
    };
    
    Path createPath() {
        return Path(_res);
    }
    
    CGPathRef copyPath() {
        return CGContextCopyPath(_res);
    }
    
    bool copyPath(MICCGPath& pathR) {
        CGPathRef p = copyPath();
        if(NULL!=p) {
            pathR.setResource(p, true);
            return true;
        }
        return false;
    }

    CGImageRef createImage() {
        return CGBitmapContextCreateImage(_res);
    }
    
    bool createImage(MICCGImage& imageR) {
        CGImageRef p = createImage();
        if(NULL!=p) {
            imageR.setResource(p, true);
            return true;
        }
        return false;
    }
    
#pragma mark - Setting Color, Color Space, and Shadow Values

    /**
     * Sets the opacity level for objects drawn in a graphics context.
     * This function sets the alpha value parameter for the specified graphics context. 
     * To clear the contents of the drawing canvas, use CGContextClearRect.
     */
    void setAlpha(CGFloat alpha) {
        CGContextSetAlpha(_res, alpha);
    }
    
    
    /**
     * Sets the current fill color in a graphics context, using a Quartz color.
     */
    void setFillColor(CGColorRef color) {
        CGContextSetFillColorWithColor(_res, color);
    }

    void setFillColor(UIColor* color) {
        setFillColor(color.CGColor);
    }

    /**
     * Sets the current stroke color to a value in the DeviceCMYK color space.
     */
    void setFillColor(
                          CGFloat red,
                          CGFloat green,
                          CGFloat blue,
                          CGFloat alpha) {
        CGContextSetRGBFillColor(_res, red, green, blue, alpha);
    }
    
    /**
     * Sets the current stroke color to a value in the DeviceCMYK color space.
     */
    void setFillColorCMYK(CGFloat cyan,
                      CGFloat magenta,
                      CGFloat yellow,
                      CGFloat black,
                      CGFloat alpha) {
        CGContextSetCMYKFillColor(_res, cyan, magenta, yellow, black, alpha);
    }

    void setStrokeColor(CGColorRef color) {
        CGContextSetStrokeColorWithColor(_res, color);
    }

    void setStrokeColor(UIColor* color) {
        setStrokeColor(color.CGColor);
    }
    
    void setStrokeColor(
                      CGFloat red,
                      CGFloat green,
                      CGFloat blue,
                      CGFloat alpha) {
        CGContextSetRGBStrokeColor(_res, red, green, blue, alpha);
    }

    void setStrokeColorCMYK(CGFloat cyan,
                            CGFloat magenta,
                            CGFloat yellow,
                            CGFloat black,
                            CGFloat alpha) {
        CGContextSetCMYKStrokeColor(_res, cyan, magenta, yellow, black, alpha);
    }

#pragma mark - Drop-shadow
    
    void setShadow(CGSize offset, CGFloat blur) {
        CGContextSetShadow(_res, offset, blur);
    }
    
    void setShadow(CGSize offset, CGFloat blur, CGColorRef color) {
        CGContextSetShadowWithColor(_res, offset, blur, color);
    }
    
    void disableShadow() {
        setShadow(CGSizeZero, 0, NULL);
    }
    
#pragma mark - Getting and Setting Graphics State Parameters
    CGInterpolationQuality getInterpolationQuality() {
        return CGContextGetInterpolationQuality(_res);
    }

    void setInterpolationQuality(CGInterpolationQuality v) {
        CGContextSetInterpolationQuality(_res,v);
    }
    
    void setFlatness(CGFloat flatness) {
        CGContextSetFlatness(_res, flatness);
    }
    
    void setLineCap(CGLineCap linecap) {
        CGContextSetLineCap(_res, linecap);
    }

    void setLineDash(CGFloat phase, const CGFloat lengths[], size_t count) {
        CGContextSetLineDash(_res, phase, lengths, count);
    }
    
    void setLineJoin( CGLineJoin join) {
        CGContextSetLineJoin(_res, join);
    }

    void setLineWidth(CGFloat width) {
        CGContextSetLineWidth(_res, width);
    }
    void setMiterLimit(CGFloat limit) {
        CGContextSetMiterLimit(_res, limit);
    }
    
    void setPatternPhase(CGSize phase) {
        CGContextSetPatternPhase(_res,phase);
    }
    
    void setFillPattern(CGPatternRef pattern, const CGFloat components[]) {
        CGContextSetFillPattern(_res, pattern, components);
    }
    
    void setRenderingIntent(CGColorRenderingIntent intent) {
        CGContextSetRenderingIntent(_res, intent);
    }
    
    void setStrokePattern(CGPatternRef pattern, const CGFloat components[]) {
        CGContextSetStrokePattern(_res,pattern,components);
    }
    
    /**
     * Sets how Quartz composites sample values for a graphics context.
     */
    void setBlendMode(CGBlendMode mode) {
        CGContextSetBlendMode(_res,mode);
    }

    void setShouldAntialias(bool shouldAntialias) {
        CGContextSetShouldAntialias(_res, shouldAntialias);
    }
    
    void setAllowsAntialiasing(bool allowsAntialiasing) {
        CGContextSetAllowsAntialiasing(_res, allowsAntialiasing);
    }
    
    void setShouldSmoothFonts(bool shouldSmoothFonts) {
        CGContextSetShouldSmoothFonts(_res, shouldSmoothFonts);
    }

    void setAllowFontSmoothing(bool allowsFontSmoothing) {
        CGContextSetAllowsFontSmoothing(_res,allowsFontSmoothing);
    }
    
    void setAllowsFontSubpixelPositioning(bool allowsFontSubpixelPositioning) {
        CGContextSetAllowsFontSubpixelPositioning(_res, allowsFontSubpixelPositioning);
    }

    void setShouldSubpixelPositionFonts(bool shouldSubpixelPositionFonts) {
        CGContextSetShouldSubpixelPositionFonts(_res, shouldSubpixelPositionFonts);
    }
    
    void setAllowsFontSubpixelQuantization(bool allowsFontSubpixelQuantization) {
        CGContextSetAllowsFontSubpixelQuantization(_res, allowsFontSubpixelQuantization);
    }
    
    void setShouldSubpixelQuantizeFonts(bool shouldSubpixelQuantizeFonts) {
        CGContextSetShouldSubpixelQuantizeFonts(_res, shouldSubpixelQuantizeFonts);
    }
    
    
#pragma mark - Painting Paths

    /**
     * Paints a transparent rectangle.
     *
     * If the provided context is a window or bitmap context, Quartz effectively clears the rectangle. 
     * For other context types, Quartz fills the rectangle in a device-dependent manner. 
     * However, you should not use this function in contexts other than window or bitmap contexts.
     */
    void clearRect(CGRect rc) {
        CGContextClearRect(_res, rc);
    }
    
    /**
     * 現在のパスを与えられたモードで描画する。
     * このメソッドを実行すると、現在のパスはクリアされる。
     *
     * @param mode  kCGPathFill             Render the area contained within the path using the non-zero winding number rule.
     *              kCGPathEOFill           Render the area within the path using the even-odd rule. (EOF==even odd fill)
     *              kCGPathStroke           Render a line along the path.
     *              kCGPathFillStroke       First fill and then stroke the path, using the nonzero winding number rule.
     *              kCGPathEOFillStroke     First fill and then stroke the path, using the even-odd rule.
     */
    void drawPath(CGPathDrawingMode mode) {
        CGContextDrawPath(_res,mode);
    }
    /**
     * drawPath(kCGPathEOFill) と等価だと思う。
     * EOF == even odd fill / != end of file
     */
    void eofFillPath() {
        CGContextEOFillPath(_res);
    }
    
    /**
     * drawPath(kCGPathFill) と等価だと思う。
     */
    void fillPath() {
        CGContextFillPath(_res);
    }
    
    /**
     * Paints a line along the current path.
     * drawPath(kCGPathStroke) と等価だと思う。
     */
    void strokePath() {
        CGContextStrokePath(_res);
    }
    
    /**
     * Paints the area contained within the provided rectangle, using the fill color in the current graphics state.
     * As a side effect when you call this function, Quartz clears the current path.
     */
    void fillRect(CGRect rc) {
        CGContextFillRect(_res, rc);
    }
    
    void fillRects(const CGRect rects[], size_t count) {
        CGContextFillRects(_res, rects, count);
    }

    /**
     * Paints the area of the ellipse that fits inside the provided rectangle, using the fill color in the current graphics state.
     * As a side effect when you call this function, Quartz clears the current path.
     */
    void fillEllipseInRect(CGRect rc) {
        CGContextFillEllipseInRect(_res, rc);
    }
    
    /**
     * Paints a rectangular path.
     * Quartz uses the line width and stroke color of the graphics state to paint the path. 
     * As a side effect when you call this function, Quartz clears the current path.
     */
    void strokeRect(CGRect rc) {
        CGContextStrokeRect(_res, rc);
    }
    
    /**
     * Paints a rectangular path, using the specified line width.
     * Aside from the line width value, Quartz uses the current attributes of the graphics 
     * state (such as stroke color) to paint the line. The line straddles the path, 
     * with half of the total width on either side.
     *
     * As a side effect when you call this function, Quartz clears the current path.
     */
    void strokeRect(CGRect rc, CGFloat width) {
        CGContextStrokeRectWithWidth(_res, rc, width);
    }
    
    /**
     * Strokes an ellipse that fits inside the specified rectangle.
     * As a side effect when you call this function, Quartz clears the current path.
     */
    void strokeEllipseInRect(CGRect rc) {
        CGContextStrokeEllipseInRect(_res, rc);
    }

    /**
     * Strokes a sequence of line segments.
     * As a side effect when you call this function, Quartz clears the current path.
     */
    void strokeLineSegments(const CGPoint points[], size_t count) {
        CGContextStrokeLineSegments(_res, points, count);
    }

#pragma mark - Drawing Text
    /**
     * CTLineDraw() でテキストを描画する位置
     */
    CGPoint getTextPosition() {
        return CGContextGetTextPosition(_res);
    }
    
    void setTextPosition(CGPoint pos) {
        CGContextSetTextPosition(_res, pos.x, pos.y);
    }

    /**
     * Sets the platform font in a graphics context.
     */
    void setFont(CGFontRef font) {
        CGContextSetFont(_res, font);
    }
    
    void setFontSize(CGFloat size) {
        CGContextSetFontSize(_res, size);
    }
    
    void setCharacterSpacing(CGFloat spacing) {
        CGContextSetCharacterSpacing(_res, spacing);
    }
    
    /**
     * @param mode  kCGTextFill             Perform a fill operation on the text.
     *              kCGTextStroke           Perform a stroke operation on the text.
     *              kCGTextInvisible        Do not draw the text, but do update the text position.
     *              kCGTextFillClip         Perform a fill operation, then intersect the text with the current clipping path.
     *              kCGTextStrokeClip       Perform a stroke operation, then intersect the text with the current clipping path.
     *              kCGTextFillStrokeClip   Perform fill then stroke operations, then intersect the text with the current clipping path.
     *              kCGTextClip             Specifies to intersect the text with the current clipping path. This mode does not paint the text.
     */
    void setTextDrawingMode(CGTextDrawingMode mode) {
        CGContextSetTextDrawingMode(_res, mode);
    }

#pragma mark - Affine transformation
    
    void rotate(CGFloat angle) {
        CGContextRotateCTM(_res, angle);
    }
    
    void rotate(CGFloat angle, CGPoint origin) {
        CGContextTranslateCTM(_res, origin.x, origin.y);
        CGContextRotateCTM(_res, angle);
        CGContextTranslateCTM(_res, -origin.x, -origin.y);
    }
    
    void translate(CGFloat x, CGFloat y) {
        CGContextTranslateCTM(_res, x, y);
    }
    
    void scale(CGFloat sx, CGFloat sy) {
        CGContextScaleCTM(_res, sx, sy);
    }
    void scale(CGFloat s) {
        CGContextScaleCTM(_res, s, s);
    }

};

#pragma mark - MICCGImageContext

/**
 * UIGraphicsBeginImageContext() または、UIGraphicsBeginImageContextWithOptions()で確保されるコンテキスト
 */
class MICCGImageContext : public MICCGContext {
public:
    MICCGImageContext(const CGSize& size) : MICCGContext(false) {
        UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
        _res = UIGraphicsGetCurrentContext();
    }
    MICCGImageContext(const CGSize& size, BOOL opaque, CGFloat scale) : MICCGContext(false) {
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
        _res = UIGraphicsGetCurrentContext();
    }
    ~MICCGImageContext() {
        UIGraphicsEndImageContext();
    }
    
    UIImage* getCurrentImage() {
        return UIGraphicsGetImageFromCurrentImageContext();
    }
};

#pragma mark - MICCGBitmapContext

/**
 * CGBitmapContextCreate() で確保されるコンテキスト
 */
class MICCGBitmapContext : public MICCGContext {
public:
    MICCGBitmapContext(void *data,
                 size_t width,
                 size_t height,
                 size_t bitsPerComponent,
                 size_t bytesPerRow,
                 CGColorSpaceRef colorspace,
                 CGBitmapInfo bitmapInfo)
    : MICCGContext(CGBitmapContextCreate(data,
                                         width,
                                         height,
                                         bitsPerComponent,
                                         bytesPerRow,
                                         colorspace,
                                         bitmapInfo), true) {
    }
};

#pragma mark - MICCGGStateStack

/**
 * CGContextのstateのスタック
 */
class MICCGGStateStack {
private:
    MICCGContext _context;
    int _pushed;
public:
    MICCGGStateStack(const CGContextRef& ctx, bool initialPush=true)
    : _context(CGContextRetain(ctx), true) {
        _pushed = 0;
        if(initialPush) {
            push();
        }
    }
    
    ~MICCGGStateStack() {
        popAll();
    }
    
    void pop() {
        if(_pushed>0) {
            _pushed--;
            CGContextRestoreGState(_context);
        }
        
    }
    
    void push() {
        _pushed++;
        CGContextSaveGState(_context);
    }
    
    void popAll() {
        while(_pushed>0) {
            _pushed--;
            CGContextRestoreGState(_context);
        }
    }
};

class MICCGAffinTransform {
protected:
    CGAffineTransform transform;
    
public:
    void copyFrom(const CGAffineTransform& src) {
        transform.a = src.a;
        transform.b = src.b;
        transform.c = src.b;
        transform.d = src.d;
        transform.tx = src.tx;
        transform.ty = src.ty;
    }

    MICCGAffinTransform() {
        copyFrom(CGAffineTransformIdentity);
    }
    
    MICCGAffinTransform(const CGAffineTransform& src) {
        copyFrom(src);
    }
    
    operator CGAffineTransform() {
        return transform;
    }
    operator CGAffineTransform*() {
        return &transform;
    }
    

    MICCGAffinTransform& scale(CGFloat scaleX, CGFloat scaleY) {
        transform = CGAffineTransformScale(transform, scaleX, scaleY);
        return *this;
    }
    
    MICCGAffinTransform& rotate(CGFloat rotate) {
        transform = CGAffineTransformRotate(transform, rotate);
        return *this;
    }
    
    MICCGAffinTransform& transrate(CGFloat x, CGFloat y) {
        transform = CGAffineTransformTranslate(transform, x, y);
        return *this;
    }
    
    MICCGAffinTransform& invert() {
        transform = CGAffineTransformInvert(transform);
        return *this;
    }
    
    MICCGAffinTransform& concat(const CGAffineTransform& src) {
        transform = CGAffineTransformConcat(transform, src);
        return *this;
    }
    
    bool operator == (const CGAffineTransform& src) {
        return CGAffineTransformEqualToTransform(src, transform);
    }
    
    bool operator != (const CGAffineTransform& src) {
        return !(*this == src);
    }
    
    CGPoint apply(const CGPoint& src) {
        return CGPointApplyAffineTransform(src, transform);
    }

    CGRect apply(const CGRect& src) {
        return CGRectApplyAffineTransform(src, transform);
    }
    
    CGSize apply(const CGSize& src) {
        return CGSizeApplyAffineTransform(src, transform);
    }

};

#endif

