//
//  CollectionViewController.m
//  LayoutDemo
//
//  UICollectionViewのテスト
//
//  Created by M.TOYOTA on 2015/01/19.
//  Copyright (c) 2015年 toyota-m2k. All rights reserved.
//

#import "CollectionViewController.h"

@interface TestCellView :UICollectionViewCell

@property (nonatomic) UILabel* labelView;
@property (nonatomic) NSString* label;

@end

@implementation TestCellView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(nil!=self) {
        _labelView = [[UILabel alloc] initWithFrame:CGRectMake(5,5,frame.size.width-10,frame.size.height-10     )];
        self.selected = false;
//        UIView* bkv = self.backgroundView;
//        bkv.backgroundColor = [UIColor greenColor];
//        _labelView.textColor = [UIColor whiteColor];
//        self.contentView = _labelView;
        [self.contentView addSubview:_labelView];
    }
    return self;
}

- (void) setLabel:(NSString *)label {
    _labelView.text = label;
}

- (NSString*) label {
    return _labelView.text;
}

- (void)setSelected:(BOOL)selected {
    if(selected) {
        _labelView.backgroundColor = [UIColor whiteColor];
        _labelView.textColor = [UIColor blackColor];
    } else {
        _labelView.backgroundColor = [UIColor blueColor];
        _labelView.textColor = [UIColor whiteColor];
    }
}

@end


@interface CollectionViewController () {
    UICollectionView* _collectionView;
    NSMutableSet* _reuseChecker;
}

@end


@implementation CollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton* back;
    back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    CGRect bkrc = CGRectMake(10, 10, 100, 50);
    back.frame = bkrc;
    back.backgroundColor = [UIColor whiteColor];
    [back setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [back setTitle:@"Back" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];

    _reuseChecker = [[NSMutableSet alloc] init];
    
    [self createCollectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)createCollectionView
{
    /*UICollectionViewのコンテンツの設定 UICollectionViewFlowLayout*/
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.itemSize = CGSizeMake(100, 100);  //表示するアイテムのサイズ
    flowLayout.minimumLineSpacing = 10.0f;  //セクションとアイテムの間隔
    flowLayout.minimumInteritemSpacing = 12.0f;  //アイテム同士の間隔
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    /*UICollectionViewの土台を作成*/
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 150) collectionViewLayout:flowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[TestCellView class] forCellWithReuseIdentifier:@"TestCellView"];  //collectionViewにcellのクラスを登録。セルの表示に使う
    
    [self.view addSubview:_collectionView];
}

#pragma mark - UICollectionViewDelegate

/*セクションの数*/
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

/*セクションに応じたセルの数*/
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return (section==0) ? 100 : 0;
    
//    if (section == 0) {
//        return 3;
//    }else if(section == 1){
//        return 5;
//    }else{
//        return 10;
//    }
}



#pragma mark - UICollectionViewDataSource

/*セルの内容を返す*/
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"TestCellView";
    
    TestCellView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    NSString* newlabel = [NSString stringWithFormat:@"Cell-%ld",(long)indexPath.item];
    
    if([_reuseChecker containsObject:cell]) {
        NSLog(@"reused %@ --> %@ (count=%ld)", cell.label, newlabel, (unsigned long)_reuseChecker.count);
    }

    [_reuseChecker addObject:cell];
    cell.label = newlabel;
//    NSLog(@"collectionView(%lx):cell=%ld", (unsigned long)cell, indexPath.item);

    
//    UIColor* colors[] = {
//        //    [UIColor blackColor],      // 0.0 white
////        [UIColor darkGrayColor],   // 0.333 white
////        [UIColor lightGrayColor],  // 0.667 white
////        //    [UIColor whiteColor],      // 1.0 white
////        [UIColor grayColor],       // 0.5 white
//        [UIColor redColor],       // 1.0, 0.0, 0.0 RGB
//        [UIColor greenColor],      // 0.0, 1.0, 0.0 RGB
//        [UIColor blueColor],       // 0.0, 0.0, 1.0 RGB
//        [UIColor cyanColor],       // 0.0, 1.0, 1.0 RGB
//        [UIColor yellowColor],     // 1.0, 1.0, 0.0 RGB
//        [UIColor magentaColor],    // 1.0, 0.0, 1.0 RGB
//        [UIColor orangeColor],     // 1.0, 0.5, 0.0 RGB
//        [UIColor purpleColor],     // 0.5, 0.0, 0.5 RGB
//        [UIColor brownColor],      // 0.6, 0.4, 0.2 RGB
//        //    [UIColor clearColor],      // 0.0 white, 0.0 alpha
//    };
//    int colorCount = sizeof(colors)/sizeof(colors[0]);
////    cell.backgroundColor = colors[indexPath.item%colorCount];
    
//    if (indexPath.section == 0) {
//        cell.backgroundColor =[UIColor redColor];
//    }else if (indexPath.section == 1){
//        cell.backgroundColor =[UIColor greenColor];
//    }else{
//        cell.backgroundColor =[UIColor blueColor];
//    }
//
    
    
    return cell;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void) goBack:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}


@end
