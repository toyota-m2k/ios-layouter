//
//  WPLConstraintController.m
//  layouterSample
//
//  Created by toyota-m2k on 2019/08/13.
//  Copyright © 2019 toyota-m2k. All rights reserved.
//

#import "WPLConstraintController.h"
#import "MICAutoLayoutBuilder.h"
#import "MICVar.h"

@interface WPLConstraintController ()

@end

@implementation WPLConstraintController {
}

- (UIView*) viewInColor:(UIColor*)color {
    let v = [[UIView alloc] initWithFrame:MICRect(MICPoint(), MICSize(20,20))];
    v.backgroundColor = color;
    return v;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIView* view = [UIView new];
    [self.view addSubview:view];
    
    MICAutoLayoutBuilder ab(self.view);
    ab.fitToSafeArea(view);
    ab.activate();

    RALBuilder builder(view);

    let v1 = [self viewInColor:UIColor.greenColor];
    builder.addView(v1,
                    RALParams()
                    .top().parent(10)
                    .left().parent(10));
    
    let v2 = [self viewInColor:UIColor.redColor];
    builder.addView(v2,
                    RALParams()
                    .top().parent(10)
                    .left().adjacent(v1, 10));

    let v3 = [self viewInColor:UIColor.magentaColor];
    v3.hidden = true;
    builder.addView(v3,
                    RALParams()
                    .top().fit(v2)
                    .left().adjacent(v2, 10)
                    .horz().fixed(60));

    let v4 = [self viewInColor:UIColor.orangeColor];
    builder.addView(v4,
                    RALParams()
                    .top().parent(10)
                    .right().parent(10));

    let v5 = [self viewInColor:UIColor.cyanColor];
    builder.addView(v5,
                    RALParams()
                    .top().fit(v2)
                    .left().adjacent(v3,10)
                    .right().adjacent(v4,10)
                    .horz(RALScaling().free()));

    let v6 = [self viewInColor:UIColor.blueColor];
    builder.addView(v6,
                    RALParams()
                    .top(RALAttach().adjacent(v4, 10))
                    .left().fit(v2)
                    .right().fit(v3)
                    .horz().free());
    
    let v7 = [self viewInColor:UIColor.purpleColor];
    builder.addView(v7,
                    RALParams()
                    .top().adjacent(v6, 10)
                    .left().center(nil)
                    .horz().relative(nil, 0.7));

    let v8 = [self viewInColor:UIColor.grayColor];
    builder.addView(v8,
                    RALParams()
                    .top().adjacent(v7, 10)
                    .left().fit(v7)
                    .horz().relative(v7, 0.5));
    
    let v9 = [self viewInColor:UIColor.grayColor];
    builder.addView(v9,
                    RALParams()
                    .top().adjacent(v8, 10)
                    .left().center(v8)
                    .horz().relative(v8, 0.5));

    let v10 = [self viewInColor:UIColor.blueColor];
    builder.addView(v10,
                    RALParams()
                    .top().adjacent(v9, 10)
                    .left().fit(v1)
                    .vert().fixed(100)
                    .horz().fixed(50));
    
    let v11 = [self viewInColor:UIColor.greenColor];
    builder.addView(v11,
                    RALParams()
                    .top().fit(v10)
                    .vert().relative(v10,1.0)
                    .horz().free()
                    .left().adjacent(v10, 10)
                    .right().adjacent(v5));
//    v11.hidden = true;
    let v12 = [self viewInColor:UIColor.redColor];
    builder.addView(v12,
                    RALParams()
                    .bottom().fit(v11)
                    .right().fit(v4)
                    .left().adjacent(v11, 10)
                    .horz().free());
    
    let back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.translatesAutoresizingMaskIntoConstraints = false;
    [back sizeToFit];
    [back setTitle:@"Back" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(navigateBack:) forControlEvents:UIControlEventTouchUpInside];
    builder.addView(back,
                     RALParams()
                     .bottom().parent(10)
                     .left().parent(10)
                     .right().parent(10)
                     .horz().free());

    
#if false
    MICAutoLayoutBuilder builder(self.view);
    
    let v1 = [self viewInColor:UIColor.greenColor];
    [self.view addSubview:v1];
    builder.fitToParent(v1, MICUiPosExUPPER, MICEdgeInsets(50));
    builder.constraint(v1, NSLayoutAttributeHeight, nil, NSLayoutAttributeHeight, 20);
    
    let v2 = [self viewInColor:UIColor.cyanColor];
    [self.view addSubview:v2];
    builder.constraint(v2, NSLayoutAttributeHeight, nil, NSLayoutAttributeHeight, 20);
//    builder.constraint(v2, NSLayoutAttributeWidth, v1, NSLayoutAttributeWidth, 0);
//    builder.constraint(v2, NSLayoutAttributeRight, v1, NSLayoutAttributeRight);
//    builder.constraint(v2, NSLayoutAttributeLeft, v1, NSLayoutAttributeLeft, 0);
//    builder.constraint(v2, NSLayoutAttributeTop, v1, NSLayoutAttributeBottom, 10);
    builder.putBelow(v2, v1, 10, MICUiAlignExFILL);
    
    let v3 = [self viewInColor:UIColor.purpleColor];
    [self.view addSubview:v3];
    builder.constraint(v3, NSLayoutAttributeHeight, nil, NSLayoutAttributeHeight, 20);
    builder.putBelow(v3, v2, 10, MICUiAlignExFILL);

    
    let back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [back sizeToFit];
    [back setTitle:@"Back" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(navigateBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];
    builder.fitToParent(back, MICUiPosExLOWER, MICEdgeInsets(50));
    builder.constraint(back, NSLayoutAttributeHeight, nil, NSLayoutAttributeHeight, back.frame.size.height);
    
    builder.activate();
#endif

}

- (void) navigateBack:(id)_ {
    [self dismissViewControllerAnimated:false completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
