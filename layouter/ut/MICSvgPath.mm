//
//  MICSvgPath.m
//  AnotherWorld
//
//  Created by @toyota-m2k on 2019/03/11.
//  Copyright  2019年 @toyota-m2k. All rights reserved.
//

#import "MICSvgPath.h"
#import "MICUiRectUtil.h"
#import "MICVar.h"
#import "MICCGContext.h"
#import <vector>

/**
 * SVG Path の命令定義
 */
typedef enum _SvgCommand {
    SvgCmdMOVE,                         // M/m
    SvgCmdLINE,                         // L/l
    SvgCmdHORZ,                         // H/h
    SvgCmdVERT,                         // V/v
    SvgCmdBEZIER_CUBIC,                 // C/c
    SvgCmdBEZIER_CUBIC_SMOOTH,          // S/s
    SvgCmdBEZIER_QUADRATIC,             // Q/q
    SvgCmdBEZIER_QUADRATIC_SMOOTH,      // T/t
    SvgCmdARC,                          // A/a
    SvgCmdCLOSE,                        // Z/z
} SvgCommand;

/**
 * SVG命令の単位要素（基底クラス）
 */
class SvgElement {
public:
    SvgCommand command;
    bool relative;
public:
    SvgElement(SvgCommand command, bool relative) {
        this->command = command;
        this->relative = relative;
    }
    virtual ~SvgElement() {}
    
    virtual void draw(const MICCGMutablePath& path, SvgElement* prev) = 0;
};

/**
 * 直線(M/L)描画命令
 */
class SvgLineElement :public  SvgElement {
protected:
    std::vector<CGPoint> points;
public:
    SvgLineElement(SvgCommand command, bool relative, size_t pointsCount=0)
    : SvgElement(command, relative) {
        if(pointsCount>0) {
            points.reserve(pointsCount);
        }
    }
    
    virtual void draw(const MICCGMutablePath& path, SvgElement* prev) {
        if(command==SvgCmdMOVE) {
            move(path, prev);
        } else {
            line(path,prev);
        }
    }
    
    void addPoint(CGPoint point) {
        points.push_back(point);
    }
    
protected:
    CGPoint pointAt(const MICCGMutablePath& path, size_t i) {
        if(relative) {
            return path.getCurrentPoint()+MICVector(points[i]);
        } else {
            return points[i];
        }
    }
    
    size_t pointsCount() {
        return points.size();
    }
    
private:
    void move(const MICCGMutablePath& path, SvgElement* prev) {
        MICPoint prevPoint;
        if(!prev) {
            relative = false;
        }
        size_t ci = pointsCount();
        if(ci>0) {
            CGPoint point = pointAt(path, 0);
            path.moveTo(point);
            prevPoint = point;
        }
        for(size_t i=1; i<ci; i++) {
            CGPoint point = pointAt(path, i);
            path.lineTo(point);
            prevPoint = point;
        }
    }
    void line(const MICCGMutablePath& path, SvgElement* prev) {
        MICPoint prevPoint;
        if(!prev) {
            relative = false;
        }
        
        for(size_t i=0,ci=pointsCount(); i<ci; i++) {
            CGPoint point = pointAt(path, i);
            path.lineTo(point);
            prevPoint = point;
        }
    }
};

/**
 * 水平・垂直線(V/H) 描画命令
 */
class SvgVHLineElement : public SvgElement {
protected:
    std::vector<CGFloat> values;
public:
    SvgVHLineElement(SvgCommand command, bool relative, size_t pointsCount=0)
    :SvgElement(command, relative) {
        if(pointsCount>0) {
            values.reserve(pointsCount);
        }
    }
    
    virtual void draw(const MICCGMutablePath& path, SvgElement* prev) {
        line(path, prev);
    }
    
    void addValue(CGFloat value) {
        values.push_back(value);
    }
private:
    CGPoint pointAt(const MICCGMutablePath& path, size_t i) {
        MICPoint point(path.getCurrentPoint());
        CGFloat v = values[i];
        if(command==SvgCmdHORZ) {
            if(relative) {
                point.x += v;
            } else {
                point.x = v;
            }
        } else {
            if(relative) {
                point.y += v;
            } else {
                point.y = v;
            }
        }
        return point;
    }
    
    size_t pointsCount() {
        return values.size();
    }
    void line(const MICCGMutablePath& path, SvgElement* prev) {
        MICPoint prevPoint;
        if(!prev) {
            relative = false;
        }
        for(size_t i=0,ci=pointsCount();i<ci;i++) {
            CGPoint point = pointAt(path, i);
            path.lineTo(point);
            prevPoint = point;
        }
    }
};

/**
 * ベジエ曲線描画命令(C/S/Q/T)
 */
class SvgBezierElement : public SvgLineElement {
protected:
    MICPoint lastCtrlPoint;
public:
    SvgBezierElement(SvgCommand cmd, bool relative, size_t pointsCount=0)
    : SvgLineElement(cmd,relative,pointsCount) {
    }
    virtual ~SvgBezierElement() {
        
    }
    virtual void draw(const MICCGMutablePath &path, SvgElement *prev) {
        switch(command) {
            case SvgCmdBEZIER_CUBIC:
                drawCubic(path,prev);
                break;
            case SvgCmdBEZIER_CUBIC_SMOOTH:
                drawCubicSmooth(path,prev);
                break;
            case SvgCmdBEZIER_QUADRATIC:
                drawQuadratic(path,prev);
                break;
            case SvgCmdBEZIER_QUADRATIC_SMOOTH:
                drawQuadraticSmooth(path,prev);
                break;
            default:
                return;
        }
    }
private:
    void drawCubic(const MICCGMutablePath &path, SvgElement *prev) {
        MICPoint prevPoint;
        if(!prev) {
            relative = false;
        }
        for(size_t i=0, ci=pointsCount() ; i+2<ci ; i+=3) {
            MICPoint pc1 = pointAt(path, i);
            MICPoint pc2 = pointAt(path, i+1);
            MICPoint p = pointAt(path, i+2);
            prevPoint = p;
            lastCtrlPoint = pc2;
            path.addCurveToPoint(pc1, pc2, p);
        }
    }
    
    void drawQuadratic(const MICCGMutablePath &path, SvgElement *prev) {
        MICPoint prevPoint;
        if(!prev) {
            relative = false;
        }
        for(size_t i=0, ci=pointsCount() ; i+1<ci ; i+=2) {
            MICPoint pc1 = pointAt(path, i);
            MICPoint p = pointAt(path, i+1);
            prevPoint = p;
            lastCtrlPoint = pc1;
            path.addQuadCurveToPoint(pc1, p);
        }
    }
    
    CGPoint getFirstControlPoint(const MICCGMutablePath &path, SvgElement* prev) {
        MICPoint pc;
        if(prev!=NULL) {
            let cmd = prev->command;
            if(  cmd==SvgCmdBEZIER_QUADRATIC
               ||cmd==SvgCmdBEZIER_QUADRATIC_SMOOTH
               ||cmd==SvgCmdBEZIER_CUBIC
               ||cmd==SvgCmdBEZIER_CUBIC_SMOOTH) {
                return getNextControlPoint(((SvgBezierElement*)prev)->lastCtrlPoint, path.getCurrentPoint());
            }
        }
        return path.getCurrentPoint();
    }
    
    CGPoint getNextControlPoint(CGPoint prevControlPoint, CGPoint currentPoint) {
        return currentPoint + (prevControlPoint-currentPoint);
    }
    
    void drawCubicSmooth(const MICCGMutablePath &path, SvgElement *prev) {
        MICPoint pc1 = getFirstControlPoint(path, prev);
        if(!prev) {
            relative = false;
        }
        for(size_t i=0, ci=pointsCount() ; i+1<ci ; i+=2) {
            MICPoint pc2 = pointAt(path, i);
            MICPoint p = pointAt(path, i+1);
            lastCtrlPoint = pc2;
            path.addCurveToPoint(pc1, pc2, p);
            pc1 = getNextControlPoint(pc2, p);
        }
    }
    
    void drawQuadraticSmooth(const MICCGMutablePath &path, SvgElement *prev) {
        MICPoint prevPoint;
        MICPoint pc1 = getFirstControlPoint(path, prev);
        if(!prev) {
            relative = false;
        }
        for(size_t i=0, ci=pointsCount() ; i<ci ; i++) {
            MICPoint p = pointAt(path, i);
            lastCtrlPoint = pc1;
            path.addQuadCurveToPoint(pc1, p);
            pc1 = getNextControlPoint(pc1, p);
        }
    }
};

/**
 * 円弧描画命令(A)
 */
class SvgArcElement : public SvgElement {
protected:
    class ArcEntry {
    public:
        CGSize radius;
        CGPoint point;
        CGFloat xrotation;
        bool largeArc;
        bool sweep;
    public:
        ArcEntry() {
            radius = MICSize();
            point = MICPoint();
            xrotation = 0;
            largeArc = false;
            sweep = 0;
        }
        ArcEntry(const CGSize& radius, const CGPoint& point, CGFloat xrotation, bool largeArc, bool sweep) {
            this->radius = radius;
            this->point = point;
            this->xrotation = xrotation;
            this->largeArc = largeArc;
            this->sweep = sweep;
        }
        ArcEntry(const ArcEntry& src) {
            radius = src.radius;
            point = src.point;
            xrotation = src.xrotation;
            largeArc = src.largeArc;
            sweep = src.sweep;
        }
    };
    std::vector<ArcEntry> _arcs;
public:
    SvgArcElement(bool relative)
    : SvgElement(SvgCmdARC, relative) {
    }
    
    void addArc(CGSize radius, CGFloat xrot, bool large, bool sweep, CGPoint point) {
        ArcEntry param(radius, point, xrot, large, sweep);
        _arcs.push_back(param);
    }
    
    virtual void draw(const MICCGMutablePath &path, SvgElement *prev) {
        arc(path, prev);
    }
private:
    CGPoint getPoint(const MICCGMutablePath &path, const ArcEntry& entry) {
        if(relative) {
            return path.getCurrentPoint() + MICVector(entry.point);
        } else {
            return entry.point;
        }
    }
    void arc(const MICCGMutablePath &path, SvgElement* prev) {
        if(!prev) {
            relative = false;
        }
        for(size_t i=0, ci=_arcs.size() ; i<ci ; i++) {
            ArcEntry a = _arcs[i];
            MICPoint r(a.radius.width, a.radius.height);
            MICPoint p2(getPoint(path, a));
            if(r.x == 0 || r.y==0 ) {
                path.lineTo(p2);
                continue;
            }
            

            MICPoint p1(path.getCurrentPoint());
            
            //
            // Center parameterization --> End-Point parameterization 変換
            // see https://www.w3.org/TR/SVG/implnote.html#ArcImplementationNotes
            //
            
            CGFloat phi = fmod(a.xrotation * M_PI/180.0, M_PI*2);
            CGFloat cosPhi = cos(phi);
            CGFloat sinPhi = sin(phi);
            CGFloat x1p = cosPhi * (p1.x-p2.x)/2 + sinPhi * (p1.y-p2.y)/2;
            CGFloat y1p = -sinPhi * (p1.x-p2.x)/2 + cosPhi * (p1.y-p2.y)/2;
            CGFloat rx_2 = r.x*r.x;
            CGFloat ry_2 = r.y*r.y;
            CGFloat xp_2 = x1p*x1p;
            CGFloat yp_2 = y1p*y1p;
            CGFloat delta = xp_2/rx_2 + yp_2/ry_2;
            if(delta>1.0) {
                r.x *= sqrt(delta);
                r.y *= sqrt(delta);
                rx_2 = r.x * r.x;
                ry_2 = r.y * r.y;
            }
            CGFloat sign = (a.largeArc == a.sweep) ? -1 : 1;
            CGFloat numerator = MAX(rx_2*ry_2 - rx_2*yp_2 - ry_2*xp_2, 0);
            CGFloat denom = rx_2*yp_2 + ry_2*xp_2;
            CGFloat lhs = sign * sqrt(numerator/denom);
            
            CGFloat cxp = lhs * (r.x*y1p)/r.y;
            CGFloat cyp = lhs * -((r.y * x1p) / r.x);
            CGFloat cx = cosPhi * cxp - sinPhi * cyp + (p1.x+p2.x)/2;
            CGFloat cy = sinPhi * cxp + cosPhi * cyp + (p1.y+p2.y)/2;
            
            MICCGAffinTransform tr(CGAffineTransformMakeScale(1.0/r.x, 1.0/r.x));
            tr.rotate(-phi);
            tr.transrate(-cx, -cy);
            
            MICPoint arcPt1(tr.apply(p1));
            MICPoint arcPt2(tr.apply(p2));
            CGFloat startAngle = atan2(arcPt1.y, arcPt1.x);
            CGFloat endAngle = atan2(arcPt2.y, arcPt2.x);
            CGFloat angleDelta = endAngle - startAngle;
            if(a.sweep) {
                if(angleDelta<0) {
                    angleDelta += M_PI*2.0;
                }
            } else {
                if(angleDelta>0) {
                    angleDelta -= M_PI*2.0;
                }
            }
            MICCGAffinTransform trInv(CGAffineTransformMakeTranslation(cx, cy));
            trInv.rotate(-phi);
            trInv.scale(r.x, r.y);

            path.addArc(0, 0, 1.0, startAngle, angleDelta, trInv);
        }
    }
};

/**
 * パスクローズ命令 (Z)
 */
class SvgCloseElement : public SvgElement {
public:
    SvgCloseElement() : SvgElement(SvgCmdCLOSE, false) {
    }
    
    virtual void draw(const MICCGMutablePath& path, SvgElement* prev) {
        path.closePath();
    }
};

/**
 * SvgElementのコンテナクラス
 */
class SvgPath {
    std::vector<SvgElement*> paths;
    
public:
    SvgPath() {
        
    }
    virtual ~SvgPath() {
        for(size_t i=0, ci=paths.size() ; i<ci ; i++) {
            delete paths[i];
        }
        paths.clear();
    }
    
    void addElement(SvgElement* elem) {
        paths.push_back(elem);
    }
    
    void draw(const MICCGMutablePath& path) {
        SvgElement *prev = NULL, *elem;
        for(size_t i=0, ci=paths.size() ; i<ci; i++) {
            elem = paths[i];
            elem->draw(path, prev);
            prev = elem;
        }
    }
};


/**
 * SVG パス文字列の解析＋解析結果の保持を行うクラス
 */
@implementation MICSvgPath {
    CGSize _viewboxSize;
    MICCGMutablePath _path;
}

- (CGPathRef) cgpath {
    return _path;
}

- (CGPathRef) detachCGPath {
    return _path.detach();
}


- (instancetype) initWithViewboxSize:(CGSize) size pathString:(NSString*)pathString {
    self = [super init];
    if(nil!=self) {
        _pathString = pathString;
        _viewboxSize = size;
        SvgPath svgPath;
        [self.class parse:pathString toPath:svgPath];
        svgPath.draw(_path);
    }
    return self;
}

+ (instancetype) pathWithViewboxSize:(CGSize)size pathString:(NSString*)pathString {
    return [[MICSvgPath alloc] initWithViewboxSize:size pathString:pathString];
}

- (void)dealloc {
    _path.release();
}

- (void) draw:(CGContextRef) rctx dstRect:(CGRect) dstRect fillColor:(UIColor*)fillColor stroke:(UIColor*)strokeColor strokeWidth:(CGFloat)strokeWidth{
    MICCGContext ctx(rctx, false);
    MICCGGStateStack ss(rctx);
    
    ctx.translate(dstRect.origin.x, dstRect.origin.y);
    ctx.scale(dstRect.size.width/_viewboxSize.width, dstRect.size.height/_viewboxSize.height);
    ctx.createPath().addPath(_path);
    if(fillColor!=nil) {
        ctx.setFillColor(fillColor);
        ctx.fillPath();
    }
    if(strokeColor!=nil&&strokeWidth>0) {
        ctx.setStrokeColor(strokeColor);
        ctx.setLineWidth(strokeWidth);
    }
}

/**
 * Pathを描画（ミラー対応版）
 */
- (void) draw:(CGContextRef) rctx dstRect:(CGRect) dstRect fillColor:(UIColor*)fillColor stroke:(UIColor*)strokeColor strokeWidth:(CGFloat)strokeWidth mirrorX:(bool)mirrorX mirrorY:(bool)mirrorY {
    MICCGContext ctx(rctx, false);
    MICCGGStateStack ss(rctx);
    
    CGFloat msx = mirrorX ? -1 : 1;
    CGFloat msy = mirrorY ? -1 : 1;
    ctx.translate(dstRect.origin.x, dstRect.origin.y);
    ctx.scale(msx*dstRect.size.width/_viewboxSize.width, msy*dstRect.size.height/_viewboxSize.height);
    CGFloat mtx = mirrorX ? _viewboxSize.width : 0;
    CGFloat mty = mirrorY ? _viewboxSize.height : 0;
    ctx.translate(-mtx, -mty);

    ctx.createPath().addPath(_path);
    if(fillColor!=nil) {
        ctx.setFillColor(fillColor);
        ctx.fillPath();
    }
    if(strokeColor!=nil&&strokeWidth>0) {
        ctx.setStrokeColor(strokeColor);
        ctx.setLineWidth(strokeWidth);
    }
}

- (void) fill:(CGContextRef) rctx dstRect:(CGRect) dstRect fillColor:(UIColor*)fillColor {
    [self draw:rctx dstRect:dstRect fillColor:fillColor stroke:nil strokeWidth:0];
}

- (void) stroke:(CGContextRef) rctx dstRect:(CGRect) dstRect strokeColor:(UIColor*)strokeColor strokeWidth:(CGFloat)strokeWidth {
    [self draw:rctx dstRect:dstRect fillColor:nil stroke:strokeColor strokeWidth:strokeWidth];
}


+ (NSString*) extractFrom:(NSString*)str withRange:(NSRange)range {
    if(range.location != NSNotFound && range.length>0) {
        return [str substringWithRange:range];
    }
    return nil;
}

+ (NSString*) extractFrom:(NSString*)str withMatch:(NSTextCheckingResult*)match atIndex:(NSInteger)index {
    if(index>=match.numberOfRanges) {
        return nil;
    }
    return [self extractFrom:str withRange:[match rangeAtIndex:index]];
}

+ (NSInteger) nextPointFrom:(NSArray<NSString*>*)ary atIndex:(NSInteger)index toPoint:(CGPoint&)point {
    if(index+1>=ary.count) {
        return NSNotFound;
    }
    NSString* sx = ary[index];
    NSString* sy = ary[index+1];
    point.x = sx.doubleValue;
    point.y = sy.doubleValue;
    return index+2;
}
+ (NSInteger) nextSizeFrom:(NSArray<NSString*>*)ary atIndex:(NSInteger)index toSize:(CGSize&)size {
    if(index+1>=ary.count) {
        return NSNotFound;
    }
    NSString* sx = ary[index];
    NSString* sy = ary[index+1];
    size.width = sx.doubleValue;
    size.height = sy.doubleValue;
    return index+2;
}

+ (NSInteger) nextFlagFrom:(NSArray<NSString*>*)ary atIndex:(NSInteger)index toFlag:(bool&)flag {
    if(index>=ary.count) {
        return NSNotFound;
    }
    NSString* s = ary[index];
    flag = s.floatValue != 0;
    return index+1;
    
}
+ (NSInteger) nextFloatFrom:(NSArray<NSString*>*)ary atIndex:(NSInteger)index toValue:(CGFloat&)value {
    if(index>=ary.count) {
        return NSNotFound;
    }
    NSString* s = ary[index];
    value = (CGFloat)s.doubleValue;
    return index+1;
    
}

+ (SvgVHLineElement*) createVHLineElement:(SvgCommand)cmd relative:(bool)relative params:(NSArray<NSString*>*)params {
    SvgVHLineElement* elem = new SvgVHLineElement(cmd, relative, params.count);
    size_t index = 0;
    CGFloat value;
    while((index=[self nextFloatFrom:params atIndex:index toValue:value])!=NSNotFound) {
        elem->addValue(value);
    }
    return elem;
}

+ (SvgLineElement*) createLineElement:(SvgCommand)cmd relative:(bool)relative params:(NSArray<NSString*>*)params {
    SvgLineElement* elem = new SvgLineElement(cmd, relative, params.count/2);
    size_t index = 0;
    CGPoint point;
    while((index=[self nextPointFrom:params atIndex:index toPoint:point])!=NSNotFound) {
        elem->addPoint(point);
    }
    return elem;
}

+ (SvgBezierElement*) createBezierElement:(SvgCommand)cmd relative:(bool)relative params:(NSArray<NSString*>*)params {
    SvgBezierElement* elem = new SvgBezierElement(cmd, relative, params.count/2);
    size_t index = 0;
    CGPoint point;
    while((index=[self nextPointFrom:params atIndex:index toPoint:point])!=NSNotFound) {
        elem->addPoint(point);
    }
    return elem;
}

+ (SvgArcElement*) createArcElement:(SvgCommand)cmd relative:(bool)relative params:(NSArray<NSString*>*)params {
    SvgArcElement* elem = new SvgArcElement(relative);
    for(size_t i=0, ci=params.count ; i+6<ci ; ) {
        MICSize radius;
        CGFloat xrot = 0;
        bool largeArc = false, sweep = false;
        CGPoint point;
        i = [self nextSizeFrom:params atIndex:i toSize:radius];
        i = [self nextFloatFrom:params atIndex:i toValue:xrot];
        i = [self nextFlagFrom:params atIndex:i toFlag:largeArc];
        i = [self nextFlagFrom:params atIndex:i toFlag:sweep];
        i = [self nextPointFrom:params atIndex:i toPoint:point];
        elem->addArc(radius, xrot, largeArc, sweep, point);
    }
    return elem;
}

+ (void) parse:(NSString*) pathString toPath:(SvgPath&) path {
    NSString* svgPattern = @"([MmLlHhVvCcSsQqTtAa])([eE.,\\s\\d]+)";
    NSError* error;
    let regexCmd = [NSRegularExpression regularExpressionWithPattern:svgPattern options:(NSRegularExpressionCaseInsensitive) error:&error];
    
    let results = [regexCmd matchesInString:pathString options:0 range:NSMakeRange(0,pathString.length)];
    for(NSTextCheckingResult* match in results) {
        NSString* cmd = [self extractFrom:pathString withMatch:match atIndex:1];
        NSArray* params = [self parseParams:[self extractFrom:pathString withMatch:match atIndex:2]];
        bool relative = false;
        SvgElement* elem;
        switch([cmd characterAtIndex:0]) {
            case 'm':
                relative = true;
            case 'M':
                elem = [self createLineElement:SvgCmdMOVE relative:relative params:params];
                break;
            case 'l':
                relative = true;
            case 'L':
                elem = [self createLineElement:SvgCmdLINE relative:relative params:params];
                break;
            case 'h':
                relative = true;
            case 'H':
                elem = [self createVHLineElement:SvgCmdHORZ relative:relative params:params];
                break;
            case 'v':
                relative = true;
            case 'V':
                elem = [self createVHLineElement:SvgCmdVERT relative:relative params:params];
                break;
            case 'z':
            case 'Z':
                elem = new SvgCloseElement();
                break;  // appended on 2019.8.11
            case 'c':
                relative = true;
            case 'C':
                elem = [self createBezierElement:SvgCmdBEZIER_CUBIC relative:relative params:params];
                break;
            case 's':
                relative = true;
            case 'S':
                elem = [self createBezierElement:SvgCmdBEZIER_CUBIC_SMOOTH relative:relative params:params];
                break;
            case 'q':
                relative = true;
            case 'Q':
                elem = [self createBezierElement:SvgCmdBEZIER_QUADRATIC relative:relative params:params];
                break;
            case 't':
                relative = true;
            case 'T':
                elem = [self createBezierElement:SvgCmdBEZIER_QUADRATIC_SMOOTH relative:relative params:params];
                break;  // appended on 2019.8.11
            case 'a':
                relative = true;
            case 'A':
                elem = [self createArcElement:SvgCmdARC relative:relative params:params];
                break;
            default:
                continue;
        }
        path.addElement(elem);
    }
}

+ (NSArray*) parseParams:(NSString*) paramString {
    NSString* pattern = @"([+-]?(?:\\d*\\.)?\\d+(?:[Ee][+-]?\\d+)?)";
    let array = [NSMutableArray array];
    NSError* error;
    let regexCmd = [NSRegularExpression regularExpressionWithPattern:pattern options:(NSRegularExpressionCaseInsensitive) error:&error];
    
    let results = [regexCmd matchesInString:paramString options:0 range:NSMakeRange(0,paramString.length)];
    for(NSTextCheckingResult* match in results) {
        for(NSInteger i=1, ci=match.numberOfRanges ; i<ci ; i++) {
            let p = [self extractFrom:paramString withMatch:match atIndex:i];
            if(nil!=p) {
                [array addObject:p];
            }
        }
    }
    return array;
}

@end
