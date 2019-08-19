//
//  ViewController.m
//  layouterSample
//
//  Created by toyota-m2k on 2019/07/29.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "ViewController.h"
#import "MICVar.h"
#import "MICAutoLayoutBuilder.h"
#import "MICUiStackLayout.h"
#import "GridViewController.h"
#import "StackViewController.h"
#import "AccordionCellViewController.h"
#import "AccordionViewController.h"
#import "ExDDViewController.h"
#import "TabBarViewController.h"
#import "RelativeViewController.h"
#import "TabViewController.h"
#import "MICUiRectUtil.h"
#import "MICUiStackView.h"
#import "CollectionViewController.h"
#import "WPLBindViewController.h"
#import "WPLSampleViewController.h"

@interface ViewController ()
@end

@implementation ViewController {
//    MICUiStackView* _stackView;
}

#define MARGIN_VERT 20

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
    CMDWPLTest,
} CMD;

- (void)viewDidLoad {
    [super viewDidLoad];

    let rootView = [UIView new];
    [self.view addSubview:rootView];
    MICAutoLayoutBuilder lb(self.view);
    lb.fitToSafeArea(rootView);
    
    let stackView = [[MICUiStackView alloc] init];
    MICUiStackLayout* layouter = stackView.stackLayout;
    
    //    layouter = [[MICUiStackLayout alloc] initWithOrientation:MICUiVertical alignment:MICUiAlignExCENTER];
    layouter.orientation = MICUiVertical;
    layouter.cellAlignment = MICUiAlignExCENTER;
    layouter.fixedSideSize = self.view.frame.size.width;
    layouter.cellSpacing = 15;
    
    
    UIButton* btn;
    
//    btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    btn.frame = CGRectMake(0, 0, 200, 50);
//    btn.tag = CMDCollectionViewTest;
//    [btn setTitle:@"CollectionView Test" forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(onCommand:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn];
//    [layouter addChild:btn];
//
//
//    btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    btn.frame = CGRectMake(0, 0, 200, 50);
//    btn.tag = CMDNoteDemo;
//    [btn setTitle:@"Note Demo" forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(onCommand:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn];
//    [layouter addChild:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = MICRect(200, 50);
    btn.tag = CMDStackLayout;
    //    btn.backgroundColor = [UIColor redColor];
    [btn setTitle:@"Stack Layout" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onCommand:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [layouter addChild:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = MICRect(200, 50);
    btn.tag = CMDGridLayout;
    //    btn.backgroundColor = [UIColor blueColor];
    [btn setTitle:@"Grid Layout" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onCommand:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [layouter addChild:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = MICRect(200, 50);
    btn.tag = CMDAccordionCell;
    //    btn.backgroundColor = [UIColor blueColor];
    [btn setTitle:@"Accordion Cell" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onCommand:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [layouter addChild:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = MICRect(200, 50);
    btn.tag = CMDAccordion;
    [btn setTitle:@"Accordion" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onCommand:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [layouter addChild:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = MICRect(200, 50);
    btn.tag = CMDAccordionWithGridView;
    [btn setTitle:@"Accordion with GridView" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onCommand:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [layouter addChild:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = MICRect(200, 50);
    btn.tag = CMDTabBarView;
    [btn setTitle:@"Tab Bar View" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onCommand:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [layouter addChild:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = MICRect(200, 50);
    btn.tag = CMDTabView;
    [btn setTitle:@"Tab View" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onCommand:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [layouter addChild:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = MICRect(200, 50);
    btn.tag = CMDRelativeLayout;
    [btn setTitle:@"Relative Layout" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onCommand:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [layouter addChild:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = MICRect(200, 50);
    btn.tag = CMDWPLTest;
    [btn setTitle:@"WPL Sample" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onCommand:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [layouter addChild:btn];

    
    
    CGSize size = [layouter getSize];
//    CGRect frame = self.view.bounds;
//
//    CGFloat m = (frame.size.height - size.height)/2;
//    if(m<MARGIN_VERT) {
//        m = MARGIN_VERT;
//    }
//    stackView.frame = MICRect(frame) - MICEdgeInsets(0,m,0,m);
    stackView.contentSize = size;
    RALBuilder rb(rootView);
    rb.addView(stackView, RALParams()
                                .left().center(nil)
                                .horz().fixed(size.width)
                                .top().parent(10)
                                .bottom().parent(10)
                                .vert().free());
    

    [stackView updateLayout:false];
    
//    [self.view addSubview:stackView];

}

- (void) onCommand:(id)sender {
    switch( [sender tag]) {
//        case CMDNoteDemo:
//            [self navigateNoteDemo];
//            break;
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
//        case CMDCollectionViewTest:
//            [self navigateCollectionViewTest];
        case CMDWPLTest:
            [self navigateWPLPage];
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

- (void) navigateWPLPage {
    let controller = [[WPLSampleViewController alloc] init];
    [self presentViewController:controller animated:true completion:nil];
}

//- (void)navigateNoteDemo {
//    NoteDemoViewController* controller = [[NoteDemoViewController alloc] init];
//    [self presentViewController:controller animated:true completion:nil];
//}
//
//- (void)navigateCollectionViewTest {
//    CollectionViewController* controller = [[CollectionViewController alloc] init];
//    [self presentViewController:controller animated:true completion:nil];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
//    return true;
//}
//
//- (BOOL)shouldAutorotate {
//    return true;
//}
//
//- (NSUInteger)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskAll;
//}
//
//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    MICSize bounds = self.view.bounds.size;
//    CGSize contents = [_stackView.stackLayout getContentRect].size;
//
//    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
//        // landscape --> portrait
//        bounds.transpose();
//    } else if( UIInterfaceOrientationIsPortrait(self.interfaceOrientation) && UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
//        // portrait --> landscape;
//        bounds.transpose();
//    } else {
//    }
//
//    CGFloat m = (bounds.height - contents.height)/2;
//    if( m<MARGIN_VERT) {
//        m = MARGIN_VERT;
//    }
//
//    _stackView.frame = self.view.bounds - MICEdgeInsets(0,m,0,0);
//    _stackView.stackLayout.fixedSideSize = bounds.width;
//    [_stackView updateLayout:true];
//
//    //    _layouter.marginTop = m;
//    //    _layouter.marginBottom = m;
//    //    _layouter.fixedSideSize = bounds.width;
//    //    m = (frame.size.width - size.width)/2;
//    //    _layouter.marginLeft = m;
//    //    _layouter.marginRight = m;
//
//    //    [_layouter updateLayout:true onCompleted:nil];
//}
//
//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
//}


@end
