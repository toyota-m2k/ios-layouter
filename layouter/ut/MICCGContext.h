//
//  MICCGContext.h
//  LayoutDemo
//
//  Created by 豊田 光樹 on 2014/12/03.
//  Copyright (c) 2014年 M.TOYOTA. All rights reserved.
//
#import <UIKit/UIKit.h>

#define MIC_RADIAN(deg) ((deg)*M_PI/180)

#if defined(__cplusplus)

#pragma mark - Releasing Resources function

template<typename T> inline void MICReleaseResource(T r) {
    return;
}

template <> inline void MICReleaseResource<CGPathRef>(CGPathRef r) {
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
    
    operator T() const {
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
        CGContextRef& _context;
        
    public:
        Path(CGContextRef& ctx) : _context(ctx){
            CGContextBeginPath(_context);
        }
        Path(const Path& src) : _context(src._context) {
        }
        
        void closePath() {
            CGContextClosePath(_context);
        }
        
        Path& moveTo(
                    CGFloat x,
                    CGFloat y
                    ) {
            CGContextMoveToPoint(_context, x, y);
            return *this;
        }
        Path& moveTo(const CGPoint p) {
            moveTo(p.x, p.y);
            return *this;
        }
        
        Path& lineTo(
                     CGFloat x,
                     CGFloat y
                     ) {
            CGContextAddLineToPoint(_context, x, y);
            return *this;
        }
        Path& lineTo( const CGPoint& p) {
            lineTo(p.x, p.y);
            return *this;
        }
        
        
        Path& addArc (
                      CGFloat x,
                      CGFloat y,
                      CGFloat radius,
                      CGFloat startAngle,
                      CGFloat endAngle,
                      bool clockwise
                     ) {
            CGContextAddArc(_context, x, y, radius, startAngle, endAngle, clockwise?1:0);
            return *this;
        }
        
        Path& addArcToPoint(
                           CGFloat x1,
                           CGFloat y1,
                           CGFloat x2,
                           CGFloat y2,
                           CGFloat radius
                           ) {
            CGContextAddArcToPoint(_context, x1, y1, x2, y2, radius);
            return *this;
        }
        
        Path& addArcToPoint(
                           const CGPoint& p1,
                           const CGPoint& p2,
                           CGFloat radius
                           ) {
            return addArcToPoint(p1.x, p1.y, p2.x, p2.y, radius);
        }
        
        Path& addCurveToPoint(
                             CGFloat cp1x,
                             CGFloat cp1y,
                             CGFloat cp2x,
                             CGFloat cp2y,
                             CGFloat x,
                             CGFloat y
                             ) {
            CGContextAddCurveToPoint(_context, cp1x, cp1y, cp2x, cp2y, x, y);
            return *this;
        }
        
        Path& addLine(
                     CGFloat x,
                     CGFloat y
                     ) {
            return lineTo(x,y);
        }
        
        Path& addPath(
                     const CGPathRef& path
                     ) {
            CGContextAddPath(_context, path);
            return *this;
        }
        
        Path& addRect(
                     const CGRect& rect
                     ) {
            CGContextAddRect(_context, rect);
            return *this;
        }
        
        CGPathRef copyPath() {
            return CGContextCopyPath(_context);
        }
        
        void copyPath(MICCGPath& r) {
            r.release();
            r.setResource(copyPath(), true);
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
    
    void push() {
        if(_pushed>0) {
            _pushed--;
            CGContextRestoreGState(_context);
        }
        
    }
    
    void pop() {
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

#endif

