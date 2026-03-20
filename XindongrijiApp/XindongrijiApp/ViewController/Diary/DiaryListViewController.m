// BEGINNER GUIDE:
// File: DiaryListViewController.m
// Role: UI layer: builds screens, handles taps, and calls services.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp DiaryListViewController.m
#import "DiaryListViewController.h"
#import "DiaryEditViewController.h"
#import "ViewController/Tag/TagManagerViewController.h"
#import "Network/HTTPClient.h"
#import "DB/CoreDataManager.h"
#import "Utils/ToastUtils.h"
#import "Utils/DateUtils.h"

@interface DiaryListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIActivityIndicatorView *footerLoadingView;

@property (nonatomic, strong) NSMutableArray<DiaryModel *> *diaries;
@property (nonatomic, strong) NSArray<TagModel *> *tags;
@property (nonatomic, strong, nullable) NSNumber *selectedTagId;

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL hasMore;

@end

@implementation DiaryListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"心动日记";
    self.view.backgroundColor = [UIColor colorWithRed:0.99 green:0.98 blue:0.96 alpha:1.0];

    self.diaries = [NSMutableArray array];
    self.tags = @[];
    self.page = 0;
    self.pageSize = 10;
    self.hasMore = YES;

    [self buildNavigation];
    [self buildTableView];
    [self loadCachedDiariesFirst];
    [self requestDiariesReset:YES showLoading:YES];
}

- (void)buildNavigation {
    UIBarButtonItem *tagManagerItem = [[UIBarButtonItem alloc] initWithTitle:@"标签管理" style:UIBarButtonItemStylePlain target:self action:@selector(tagManagerTapped)];
    self.navigationItem.leftBarButtonItem = tagManagerItem;

    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addDiaryTapped)];
    UIBarButtonItem *filterItem = [[UIBarButtonItem alloc] initWithTitle:@"筛选" style:UIBarButtonItemStylePlain target:self action:@selector(filterTapped)];
    self.navigationItem.rightBarButtonItems = @[addItem, filterItem];
}

- (void)buildTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 88;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:self.tableView];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshTriggered) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];

    self.footerLoadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.footerLoadingView.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 44);
    self.tableView.tableFooterView = self.footerLoadingView;

    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (void)loadCachedDiariesFirst {
    NSArray<DiaryModel *> *cached = [[CoreDataManager sharedManager] cachedDiariesSortedByDateDesc];
    if (cached.count == 0) {
        return;
    }
    [self.diaries removeAllObjects];
    [self.diaries addObjectsFromArray:cached];
    [self.tableView reloadData];
}

- (void)refreshTriggered {
    [self requestDiariesReset:YES showLoading:NO];
}

- (void)requestDiariesReset:(BOOL)reset showLoading:(BOOL)showLoading {
    if (self.isLoading) {
        return;
    }
    self.isLoading = YES;

    if (reset) {
        self.page = 0;
        self.hasMore = YES;
    }

    if (showLoading) {
        [ToastUtils showLoadingInView:self.view text:@"加载日记..."];
    }
    if (!reset) {
        [self.footerLoadingView startAnimating];
    }

    __weak typeof(self) weakSelf = self;
    [[HTTPClient sharedClient] fetchDiariesWithPage:self.page size:self.pageSize tagId:self.selectedTagId success:^(NSArray<DiaryModel *> *items, NSInteger total) {
        __strong typeof(weakSelf) self = weakSelf;
        self.isLoading = NO;
        [self.refreshControl endRefreshing];
        [self.footerLoadingView stopAnimating];
        if (showLoading) {
            [ToastUtils hideLoadingInView:self.view];
        }

        if (reset) {
            [self.diaries removeAllObjects];
        }
        [self.diaries addObjectsFromArray:items];

        self.hasMore = self.diaries.count < total && items.count > 0;
        if (self.hasMore) {
            self.page += 1;
        }

        [[CoreDataManager sharedManager] cacheDiariesFromServer:items replaceAll:reset];
        [self.tableView reloadData];

        [[CoreDataManager sharedManager] syncPendingDiaryOperationsWithCompletion:^(NSInteger syncedCount, NSInteger remainingCount) {
            if (syncedCount > 0) {
                [self requestDiariesReset:YES showLoading:NO];
            }
        }];
    } failure:^(NSError *error, NSString *message, NSInteger code) {
        __strong typeof(weakSelf) self = weakSelf;
        self.isLoading = NO;
        [self.refreshControl endRefreshing];
        [self.footerLoadingView stopAnimating];
        if (showLoading) {
            [ToastUtils hideLoadingInView:self.view];
        }

        if (reset) {
            [self loadCachedDiariesFirst];
        }
        [ToastUtils showToastInView:self.view text:message ?: @"加载失败，已展示本地缓存"];
    }];
}

- (void)addDiaryTapped {
    __weak typeof(self) weakSelf = self;
    DiaryEditViewController *editVC = [[DiaryEditViewController alloc] initWithDiary:nil onSaved:^{
        [weakSelf loadCachedDiariesFirst];
        [weakSelf requestDiariesReset:YES showLoading:NO];
    }];
    [self.navigationController pushViewController:editVC animated:YES];
}

- (void)tagManagerTapped {
    TagManagerViewController *tagVC = [[TagManagerViewController alloc] init];
    [self.navigationController pushViewController:tagVC animated:YES];
}

- (void)filterTapped {
    __weak typeof(self) weakSelf = self;
    [[HTTPClient sharedClient] fetchTagsWithSuccess:^(NSArray<TagModel *> *items) {
        __strong typeof(weakSelf) self = weakSelf;
        self.tags = items;
        [self presentFilterSheet];
    } failure:^(NSError *error, NSString *message, NSInteger code) {
        __strong typeof(weakSelf) self = weakSelf;
        [ToastUtils showToastInView:self.view text:message ?: @"标签加载失败"];
    }];
}

- (void)presentFilterSheet {
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"按标签筛选" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    [sheet addAction:[UIAlertAction actionWithTitle:@"全部标签" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.selectedTagId = nil;
        self.title = @"心动日记";
        [self requestDiariesReset:YES showLoading:YES];
    }]];

    for (TagModel *tag in self.tags) {
        NSString *title = [NSString stringWithFormat:@"#%@", tag.name ?: @""];
        [sheet addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.selectedTagId = @(tag.tagId);
            self.title = [NSString stringWithFormat:@"心动日记 · %@", tag.name ?: @""];
            [self requestDiariesReset:YES showLoading:YES];
        }]];
    }

    [sheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:sheet animated:YES completion:nil];
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.diaries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"XindongrijiApp.DiaryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    DiaryModel *diary = self.diaries[indexPath.row];
    cell.textLabel.text = diary.title;

    NSString *displayDate = [DateUtils displayDateStringFromApiDateString:diary.date ?: @""];
    NSString *preview = diary.content.length > 24 ? [[diary.content substringToIndex:24] stringByAppendingString:@"..."] : diary.content;

    NSMutableArray<NSString *> *tagNames = [NSMutableArray array];
    for (TagModel *tag in diary.tags) {
        [tagNames addObject:[NSString stringWithFormat:@"#%@", tag.name ?: @""]];
    }
    NSString *tagPart = tagNames.count > 0 ? [tagNames componentsJoinedByString:@" "] : @"#无标签";
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@  %@\n%@", displayDate, tagPart, preview ?: @""];
    cell.detailTextLabel.numberOfLines = 2;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.diaries.count - 1 && self.hasMore && !self.isLoading) {
        [self requestDiariesReset:NO showLoading:NO];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DiaryModel *diary = self.diaries[indexPath.row];
    __weak typeof(self) weakSelf = self;
    DiaryEditViewController *editVC = [[DiaryEditViewController alloc] initWithDiary:diary onSaved:^{
        [weakSelf loadCachedDiariesFirst];
        [weakSelf requestDiariesReset:YES showLoading:NO];
    }];
    [self.navigationController pushViewController:editVC animated:YES];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"删除" handler:^(UIContextualAction *action, UIView *sourceView, void (^completionHandler)(BOOL)) {
        __strong typeof(weakSelf) self = weakSelf;
        DiaryModel *diary = self.diaries[indexPath.row];

        void (^removeLocal)(void) = ^{
            [[CoreDataManager sharedManager] removeDiaryById:diary.diaryId];
            [[CoreDataManager sharedManager] removePendingOperationsForDiaryId:diary.diaryId];
            [self.diaries removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            completionHandler(YES);
        };

        if (diary.diaryId <= 0) {
            removeLocal();
            return;
        }

        [[HTTPClient sharedClient] deleteDiaryId:diary.diaryId success:^{
            removeLocal();
        } failure:^(NSError *error, NSString *message, NSInteger code) {
            NSDictionary *payload = @{@"diaryId": @(diary.diaryId)};
            [[CoreDataManager sharedManager] enqueuePendingOperationType:@"delete" payload:payload replaceForLocalDiaryId:@(diary.diaryId)];
            removeLocal();
            [ToastUtils showToastInView:self.view text:@"已离线删除，网络恢复后自动同步"];
        }];
    }];

    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
    config.performsFirstActionWithFullSwipe = YES;
    return config;
}

@end
