//
//  ViewController.m
//  DTable
//
//  Created by 豊田 光樹 on 2014/10/15.
//  Copyright (c) 2014年 豊田 光樹. All rights reserved.
//

#import "ViewController.h"
#import "MMJUiStackLayout.h"
#import "GridViewController.h"
#import "StackViewController.h"
#import "AccordionCellViewController.h"
#import "AccordionViewController.h"
#import "ExDDViewController.h"
#import "TabBarViewController.h"
#import "RelativeViewController.h"
#import "NoteDemoViewController.h"
#import "TabViewController.h"
#import "MMJUiRectUtil.h"
#import "MMJUiStackView.h"
#import "CollectionViewController.h"

@interface ViewController () {
//    MMJUiStackLayout* _layouter;
    MMJUiStackView* _stackView;
}
@end

#define MARGIN_VERT 20

@implementation ViewController

typedef enum _CMD{
    CMDStackLayout,
    CMDGridLayout,
    CMDAccordionCell,
    CMDAccordion,
    CMDAccordionWithGridView,
    CMDTabBarView,
    CMDRelativeLayout,
    CMDTabView,
    CMDNoteDemo,
    CMDCollectionViewTest,
} CMD;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _stackView = [[MMJUiStackView alloc] init];
    MMJUiStackLayout* layouter = _stackView.stackLayout;
    
//    layouter = [[MMJUiStackLayout alloc] initWithOrientation:MMJUiVertical alignment:MMJUiAlignExCENTER];
    layouter.orientation = MMJUiVertical;
    layouter.cellAlignment = MMJUiAlignExCENTER;
    layouter.fixedSideSize = self.view.frame.size.width;
    layouter.cellSpacing = 15;
    
    
    UIButton* btn;

    btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(0, 0, 200, 50);
    btn.tag = CMDCollectionViewTest;
    [btn setTitle:@"CollectionView Test" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onCommand:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [layouter addChild:btn];
    
    
    btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(0, 0, 200, 50);
    btn.tag = CMDNoteDemo;
    [btn setTitle:@"Note Demo" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onCommand:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [layouter addChild:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(0, 0, 200, 50);
    btn.tag = CMDStackLayout;
//    btn.backgroundColor = [UIColor redColor];
    [btn setTitle:@"Stack Layout" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onCommand:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [layouter addChild:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(0, 0, 200, 50);
    btn.tag = CMDGridLayout;
//    btn.backgroundColor = [UIColor blueColor];
    [btn setTitle:@"Grid Layout" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onCommand:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [layouter addChild:btn];

    btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(0, 0, 200, 50);
    btn.tag = CMDAccordionCell;
    //    btn.backgroundColor = [UIColor blueColor];
    [btn setTitle:@"Accordion Cell" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onCommand:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [layouter addChild:btn];

    btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(0, 0, 200, 50);
    btn.tag = CMDAccordion;
    [btn setTitle:@"Accordion" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onCommand:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [layouter addChild:btn];

    btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(0, 0, 200, 50);
    btn.tag = CMDAccordionWithGridView;
    [btn setTitle:@"Accordion with GridView" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onCommand:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [layouter addChild:btn];

    btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(0, 0, 200, 50);
    btn.tag = CMDTabBarView;
    [btn setTitle:@"Tab Bar View" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onCommand:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [layouter addChild:btn];

    btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(0, 0, 200, 50);
    btn.tag = CMDTabView;
    [btn setTitle:@"Tab View" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onCommand:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [layouter addChild:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(0, 0, 200, 50);
    btn.tag = CMDRelativeLayout;
    [btn setTitle:@"Relative Layout" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onCommand:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [layouter addChild:btn];
    
    
    
    
    CGSize size = [layouter getSize];
    CGRect frame = self.view.bounds;
    
    CGFloat m = (frame.size.height - size.height)/2;
    if(m<MARGIN_VERT) {
        m = MARGIN_VERT;
    }
    _stackView.frame = MMJRect(frame) - MMJEdgeInsets(0,m,0,m);
    [_stackView updateLayout:false];
    
    [self.view addSubview:_stackView];

//    _layouter.marginTop = m;
//    _layouter.marginBottom = m;
//    m = (frame.size.width - size.width)/2;
//    _layouter.marginLeft = m;
//    _layouter.marginRight = m;
//    
//    [_layouter updateLayout:false onCompleted:nil];
    

}

- (void) onCommand:(id)sender {
    switch( [sender tag]) {
        case CMDNoteDemo:
            [self navigateNoteDemo];
            break;
        case CMDStackLayout:
            [self navigateStackLayoutPage];
            break;
        case CMDGridLayout:
            [self navigateGridLayoutPage];
            break;
        case CMDAccordionCell:
            [self navigateAccordionCellPage];
            break;
        case CMDAccordion:
            [self navigateAccordionPage];
            break;
        case CMDAccordionWithGridView:
            [self navigateExDDViewPage];
            break;
        case CMDTabBarView:
            [self navigateTabBarView];
            break;
        case CMDRelativeLayout:
            [self navigateRelativeLayoutPage];
            break;
        case CMDTabView:
            [self navigateTabView];
            break;
        case CMDCollectionViewTest:
            [self navigateCollectionViewTest];
        default:
            break;
    }
}

- (void) navigateStackLayoutPage {
    StackViewController* controller = [[StackViewController alloc] init];
    [self presentViewController:controller animated:true completion:nil];
}

- (void) navigateGridLayoutPage {
    GridViewController* controller = [[GridViewController alloc] init];
    [self presentViewController:controller animated:true completion:nil];
}

- (void) navigateAccordionCellPage {
    AccordionCellViewController* controller = [[AccordionCellViewController alloc] init];
    [self presentViewController:controller animated:true completion:nil];
}

- (void) navigateAccordionPage {
    AccordionViewController* controller = [[AccordionViewController alloc] init];
    [self presentViewController:controller animated:true completion:nil];
}

- (void) navigateExDDViewPage {
    ExDDViewController* controller = [[ExDDViewController alloc] init];
    [self presentViewController:controller animated:true completion:nil];
}

- (void) navigateTabBarView {
    TabBarViewController* controller = [[TabBarViewController alloc] init];
    [self presentViewController:controller animated:true completion:nil];
}

- (void) navigateTabView {
    TabViewController* controller = [[TabViewController alloc] init];
    [self presentViewController:controller animated:true completion:nil];
}

- (void)navigateRelativeLayoutPage {
    RelativeViewController* controller = [[RelativeViewController alloc] init];
    [self presentViewController:controller animated:true completion:nil];
}

- (void)navigateNoteDemo {
    NoteDemoViewController* controller = [[NoteDemoViewController alloc] init];
    [self presentViewController:controller animated:true completion:nil];
}

- (void)navigateCollectionViewTest {
    CollectionViewController* controller = [[CollectionViewController alloc] init];
    [self presentViewController:controller animated:true completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return true;
}

- (BOOL)shouldAutorotate {
    return true;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    MMJSize bounds = self.view.bounds.size;
    CGSize contents = [_stackView.stackLayout getContentRect].size;
    
    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        // landscape --> portrait
        bounds.transpose();
    } else if( UIInterfaceOrientationIsPortrait(self.interfaceOrientation) && UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        // portrait --> landscape;
        bounds.transpose();
    } else {
    }
    
    CGFloat m = (bounds.height - contents.height)/2;
    if( m<MARGIN_VERT) {
        m = MARGIN_VERT;
    }
    
    _stackView.frame = self.view.bounds - MMJEdgeInsets(0,m,0,0);
    _stackView.stackLayout.fixedSideSize = bounds.width;
    [_stackView updateLayout:true];
    
//    _layouter.marginTop = m;
//    _layouter.marginBottom = m;
//    _layouter.fixedSideSize = bounds.width;
    //    m = (frame.size.width - size.width)/2;
    //    _layouter.marginLeft = m;
    //    _layouter.marginRight = m;
    
//    [_layouter updateLayout:true onCompleted:nil];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
}

@end
