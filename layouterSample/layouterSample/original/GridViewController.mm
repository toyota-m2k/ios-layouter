//
//  GridViewController.m
//  DTable
//
//  Created by M.TOYOTA on 2014/10/24.
//  Copyright (c) 2015年 toyota-m2k. All rights reserved.
//

#import "GridViewController.h"
#import "MICUiGridLayout.h"
#import "MICUiCellDragSupport.h"
#import "MICUiGridView.h"
#import "MICVar.h"
#import "MICUiRectUtil.h"
#import "MICAutoLayoutBuilder.h"

@interface GridViewController () {
//    MICUiGridLayout* _gridLayouter;
//    MICUiCellDragSupport* _dragSupporter;

    MICUiGridView*  _gridView;
}
@end

@implementation GridViewController

#define UNIT_G 4
#define CELL_SIZE 20

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
    let rootView = [UIView new];
    [self.view addSubview:rootView];
    MICAutoLayoutBuilder lb(self.view);
    lb.fitToSafeArea(rootView);

    
    let back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame = MICRect(200, 50);
    back.backgroundColor = [UIColor whiteColor];
    [back setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [back setTitle:@"Back" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [rootView addSubview:back];
    
    _gridView = [[MICUiGridView alloc] initWithFrame:CGRectMake(0,100, 300, 300)];
    [_gridView enableScrollSupport:true];
    [_gridView beginCustomizingWithLongPress:true endWithTap:true];
    
//    UIScrollView* scrollView = [[UIScrollView alloc] init];
    _gridView.backgroundColor = [UIColor blackColor];
//    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    
    
//    [self.view addSubview:scrollView];
    [rootView addSubview:_gridView];
    
//    _gridLayouter = [[MICUiGridLayout alloc] init];
//    _gridLayouter.cellSize = CGSizeMake(CELL_SIZE,CELL_SIZE);
//    _gridLayouter.marginTop = 50;
//    _gridLayouter.growingOrientation = MICUiVertical;
//    _gridLayouter.fixedSideCount = UNIT_G*3;

    MICUiGridLayout* gridLayout = _gridView.gridLayout;
    gridLayout.fixedSideCount = UNIT_G*3;
    gridLayout.cellSize = CGSizeMake(CELL_SIZE,CELL_SIZE);
    gridLayout.megaUnitX = UNIT_G;
    gridLayout.megaUnitY = UNIT_G;
    gridLayout.cellSpacingVert = 5;
    gridLayout.cellSpacingHorz = 5;
    
//    _dragSupporter = [[MICUiCellDragSupport alloc] initWithContainer:scrollView
//                                                     andLayouter:_gridLayouter
//                                         beginCustomizingOnLongPress:true
//                                                 endCustomizingOnTap:true];
    
    
    UILabel* label;
#if 1
    label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor blueColor];
    label.textColor = [UIColor whiteColor];
    label.text = @"1111";
    [_gridView addChild:label unitX:2*UNIT_G unitY:2*UNIT_G];
    
    label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor greenColor];
    label.textColor = [UIColor whiteColor];
    label.text = @"2222";
    [_gridView addChild:label unitX:1*UNIT_G unitY:2*UNIT_G];
    
    label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor yellowColor];
    label.textColor = [UIColor whiteColor];
    label.text = @"3333";
    [_gridView addChild:label unitX:3*UNIT_G unitY:1*UNIT_G];
    
    label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor purpleColor];
    label.textColor = [UIColor whiteColor];
    label.text = @"4444";
    [_gridView addChild:label unitX:2*UNIT_G unitY:1*UNIT_G];
    
    
    label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor purpleColor];
    label.textColor = [UIColor whiteColor];
    label.text = @"5555";
    [_gridView addChild:label unitX:1*UNIT_G unitY:3*UNIT_G];
    
    label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor purpleColor];
    label.textColor = [UIColor whiteColor];
    label.text = @"6666";
    [_gridView addChild:label unitX:3*UNIT_G unitY:3*UNIT_G];
    
    label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor purpleColor];
    label.textColor = [UIColor whiteColor];
    label.text = @"7777";
    [_gridView addChild:label unitX:3*UNIT_G unitY:2*UNIT_G];
    
    label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor purpleColor];
    label.textColor = [UIColor whiteColor];
    label.text = @"8888";
    [_gridView addChild:label unitX:2*UNIT_G unitY:3*UNIT_G];
#endif
    //
    //
    //    btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //    btn.backgroundColor = [UIColor orangeColor];
    //    [btn setTitle:@"BTN1" forState:UIControlStateNormal];
    //    [_gridLayouter addChild:btn unitX:1 unitY:1];
    //
    //
    //    [scrollView addSubview:btn];
    //
    //    btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //    btn.backgroundColor = [UIColor redColor];
    //    [btn setTitle:@"BTN2" forState:UIControlStateNormal];
    //    [_gridLayouter addChild:btn unitX:2 unitY:2];
    //    [scrollView addSubview:btn];
    //
    //
    //    btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //    btn.backgroundColor = [UIColor darkGrayColor];
    //    [btn setTitle:@"BTN3" forState:UIControlStateNormal];
    //    [_gridLayouter addChild:btn unitX:1*UNIT_G unitY:3*UNIT_G];
    //    [scrollView addSubview:btn];
    //
    //    btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //    btn.backgroundColor = [UIColor darkGrayColor];
    //    [btn setTitle:@"BTN4" forState:UIControlStateNormal];
    //    [_gridLayouter addChild:btn unitX:3*UNIT_G unitY:3*UNIT_G];
    //    [scrollView addSubview:btn];
    
    UIColor* colors[] = {
        //    [UIColor blackColor],      // 0.0 white
        [UIColor darkGrayColor],   // 0.333 white
        [UIColor lightGrayColor],  // 0.667 white
        //    [UIColor whiteColor],      // 1.0 white
        [UIColor grayColor],       // 0.5 white
        [UIColor redColor],       // 1.0, 0.0, 0.0 RGB
        [UIColor greenColor],      // 0.0, 1.0, 0.0 RGB
        [UIColor blueColor],       // 0.0, 0.0, 1.0 RGB
        [UIColor cyanColor],       // 0.0, 1.0, 1.0 RGB
        [UIColor yellowColor],     // 1.0, 1.0, 0.0 RGB
        [UIColor magentaColor],    // 1.0, 0.0, 1.0 RGB
        [UIColor orangeColor],     // 1.0, 0.5, 0.0 RGB
        [UIColor purpleColor],     // 0.5, 0.0, 0.5 RGB
        [UIColor brownColor],      // 0.6, 0.4, 0.2 RGB
        //    [UIColor clearColor],      // 0.0 white, 0.0 alpha
    };
    int colorCount = sizeof(colors)/sizeof(colors[0]);
    
    for(int i=0 ; i<100; i++ ) {
        if(i%10==0) {
            UIButton* btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            btn.backgroundColor = colors[i%colorCount];
            [btn setTitle:[NSString stringWithFormat:@"GROUP-%d",i/10+1] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(separatorTapped:) forControlEvents:UIControlEventTouchUpInside];
            [_gridView.gridLayout addChild:btn unitX:1 unitY:1 cellStyle:MICUiGlStyleSEPARATOR];
            //[scrollView addSubview:btn];
        }
        
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = colors[i%colorCount];
        label.textColor = [UIColor whiteColor];
        label.text = [NSString stringWithFormat:@"LABEL-%d",i];
        [_gridView addChild:label unitX:UNIT_G unitY:UNIT_G];
    }
    
    
    [_gridView updateLayout:true];
    
    CGSize layoutSize =[_gridView.gridLayout getSize];
    
    CGRect rcFrame = self.view.bounds;
    rcFrame.origin.y += 100;
    rcFrame.size.height -= 200;
    rcFrame.size.width = layoutSize.width;
    
    // gridView.frame = rcFrame;
    _gridView.contentSize = layoutSize;
    
    RALBuilder(rootView)
    .addView(back, RALParams()
                    .top().parent(10)
                    .left().center(nil))
    .addView(_gridView, RALParams()
                    .top().adjacent(back, 20)
                    .bottom().parent(10)
                    .vert().free()
                    .left().center(nil));
    
    
    
    //    _scrollView = scrollView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)separatorTapped:(id)sender{
    [((MICUiGridLayout*)_gridView.layouter) toggleGroupFolding:sender];
}

#if 0
- (void) beginDrag:(UIGestureRecognizer*)sender {
    CGPoint point = [sender locationInView:_scrollView];
    [_gridLayouter beginDrag:point];
}

- (void) dragTo:(UIGestureRecognizer*)sender {
    CGPoint point = [sender locationInView:_scrollView];
    [_gridLayouter dragTo:point];
}

- (void) endDrag:(UIGestureRecognizer*) sender {
    [_gridLayouter endDrag];
}

- (void) cancelDrag:(UIGestureRecognizer*) sender {
    [_gridLayouter cancelDrag];
}

- (void)onLongPress:(UILongPressGestureRecognizer*) sender {
    [_gridLayouter beginLayoutCustomize];
    
    if(sender.state == UIGestureRecognizerStateBegan) {
        if( _layoutCustomizeMode ) {
            return;
        }
        NSLog(@"begin customize.");
        _layoutCustomizeMode = true;
        [_gridLayouter beginLayoutCustomize];
        [_scrollView addGestureRecognizer:_panGesture];
        [_scrollView addGestureRecognizer:_tapGesture];
    }
    [self doDrag:sender];
}

- (void)onTap:(UITapGestureRecognizer*)sender{
    if( !_layoutCustomizeMode ) {
        
        // for Debug
        //        CGPoint point = [sender locationInView:_scrollView];
        //        MICUiGridCell* cell = [_gridLayouter hitTestAt:point.x and:point.y];
        //        if( nil==cell) {
        //            NSLog(@"No cell at (%f, %f)", point.x, point.y);
        //        } else {
        //            cell.view.alpha = cell.view.alpha < 0.9 ? 1.0 : 0.5;
        //        }
        
        
        return;
    }
    NSLog(@"end customize.");
    _layoutCustomizeMode = false;
    [_gridLayouter endLayoutCustomize];
    
    [_scrollView removeGestureRecognizer:_panGesture];
    [_scrollView removeGestureRecognizer:_tapGesture];
}

- (void)doDrag:(UIGestureRecognizer*)sender {
    if( !_layoutCustomizeMode){
        return;
    }
    switch(sender.state) {
        case UIGestureRecognizerStateBegan:
            //            NSLog(@"drag: begin");
            [self beginDrag:sender];
            break;
        case UIGestureRecognizerStateChanged:
            //            NSLog(@"drag: changed");
            [self dragTo:sender];
            break;
        case UIGestureRecognizerStateEnded:
            //            NSLog(@"drag: end");
            [self endDrag:sender];
            break;
        case UIGestureRecognizerStateCancelled:
            //            NSLog(@"drag: cancel");
            [self cancelDrag:sender];
            break;
        default:
            break;
    }
}

- (void)onDrag:(UIPanGestureRecognizer*)sender{
    //    NSLog(@"onDrag");
    [self doDrag:sender];
}
#endif

- (void) goBack:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
