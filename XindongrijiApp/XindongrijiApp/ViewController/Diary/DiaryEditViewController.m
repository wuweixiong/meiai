// BEGINNER GUIDE:
// File: DiaryEditViewController.m
// Role: UI layer: builds screens, handles taps, and calls services.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp DiaryEditViewController.m
#import "DiaryEditViewController.h"
#import "Network/HTTPClient.h"
#import "DB/CoreDataManager.h"
#import "Utils/FormValidator.h"
#import "Utils/DateUtils.h"
#import "Utils/ToastUtils.h"

@interface DiaryEditViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITextField *titleField;
@property (nonatomic, strong) UITextView *contentTextView;
@property (nonatomic, strong) UIButton *dateButton;
@property (nonatomic, strong) UIButton *addTagButton;
@property (nonatomic, strong) UITableView *tagsTableView;

@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSMutableArray<TagModel *> *allTags;
@property (nonatomic, strong) NSMutableSet<NSNumber *> *selectedTagIds;

@property (nonatomic, strong, nullable) DiaryModel *editingDiary;
@property (nonatomic, copy) dispatch_block_t onSaved;

@end

@implementation DiaryEditViewController

- (instancetype)initWithDiary:(DiaryModel *)diary onSaved:(dispatch_block_t)onSaved {
    self = [super init];
    if (self) {
        _editingDiary = diary;
        _onSaved = [onSaved copy];
        _allTags = [NSMutableArray array];
        _selectedTagIds = [NSMutableSet set];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.editingDiary ? @"日记详情" : @"写日记";
    self.view.backgroundColor = [UIColor colorWithRed:0.99 green:0.98 blue:0.96 alpha:1.0];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(saveTapped)];

    [self buildUI];
    [self applyEditingDataIfNeeded];
    [self loadTags];
}

- (void)buildUI {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scrollView];

    UIView *contentView = [[UIView alloc] init];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:contentView];

    self.titleField = [[UITextField alloc] init];
    self.titleField.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleField.borderStyle = UITextBorderStyleRoundedRect;
    self.titleField.placeholder = @"标题（不超过100字）";

    self.contentTextView = [[UITextView alloc] init];
    self.contentTextView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentTextView.font = [UIFont systemFontOfSize:16];
    self.contentTextView.layer.cornerRadius = 10;
    self.contentTextView.layer.borderWidth = 1;
    self.contentTextView.layer.borderColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.93 alpha:1.0].CGColor;
    self.contentTextView.textContainerInset = UIEdgeInsetsMake(12, 10, 12, 10);

    self.dateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.dateButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.dateButton.layer.cornerRadius = 8;
    self.dateButton.layer.borderWidth = 1;
    self.dateButton.layer.borderColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.93 alpha:1.0].CGColor;
    [self.dateButton setTitleColor:[UIColor colorWithRed:0.36 green:0.36 blue:0.40 alpha:1.0] forState:UIControlStateNormal];
    [self.dateButton setTitle:@"选择日期" forState:UIControlStateNormal];
    [self.dateButton addTarget:self action:@selector(dateTapped) forControlEvents:UIControlEventTouchUpInside];

    UILabel *tagsLabel = [[UILabel alloc] init];
    tagsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    tagsLabel.font = [UIFont boldSystemFontOfSize:16];
    tagsLabel.text = @"标签";

    self.addTagButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.addTagButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.addTagButton setTitle:@"新增标签" forState:UIControlStateNormal];
    [self.addTagButton addTarget:self action:@selector(addTagTapped) forControlEvents:UIControlEventTouchUpInside];

    self.tagsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tagsTableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tagsTableView.dataSource = self;
    self.tagsTableView.delegate = self;
    self.tagsTableView.layer.cornerRadius = 10;
    self.tagsTableView.layer.borderWidth = 1;
    self.tagsTableView.layer.borderColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.93 alpha:1.0].CGColor;
    self.tagsTableView.scrollEnabled = NO;

    [contentView addSubview:self.titleField];
    [contentView addSubview:self.contentTextView];
    [contentView addSubview:self.dateButton];
    [contentView addSubview:tagsLabel];
    [contentView addSubview:self.addTagButton];
    [contentView addSubview:self.tagsTableView];

    [NSLayoutConstraint activateConstraints:@[
        [scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [contentView.topAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.topAnchor],
        [contentView.leadingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.leadingAnchor],
        [contentView.trailingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.trailingAnchor],
        [contentView.bottomAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.bottomAnchor],
        [contentView.widthAnchor constraintEqualToAnchor:scrollView.frameLayoutGuide.widthAnchor],

        [self.titleField.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:16],
        [self.titleField.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:16],
        [self.titleField.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-16],
        [self.titleField.heightAnchor constraintEqualToConstant:46],

        [self.contentTextView.topAnchor constraintEqualToAnchor:self.titleField.bottomAnchor constant:12],
        [self.contentTextView.leadingAnchor constraintEqualToAnchor:self.titleField.leadingAnchor],
        [self.contentTextView.trailingAnchor constraintEqualToAnchor:self.titleField.trailingAnchor],
        [self.contentTextView.heightAnchor constraintEqualToConstant:220],

        [self.dateButton.topAnchor constraintEqualToAnchor:self.contentTextView.bottomAnchor constant:12],
        [self.dateButton.leadingAnchor constraintEqualToAnchor:self.titleField.leadingAnchor],
        [self.dateButton.trailingAnchor constraintEqualToAnchor:self.titleField.trailingAnchor],
        [self.dateButton.heightAnchor constraintEqualToConstant:42],

        [tagsLabel.topAnchor constraintEqualToAnchor:self.dateButton.bottomAnchor constant:16],
        [tagsLabel.leadingAnchor constraintEqualToAnchor:self.titleField.leadingAnchor],

        [self.addTagButton.centerYAnchor constraintEqualToAnchor:tagsLabel.centerYAnchor],
        [self.addTagButton.trailingAnchor constraintEqualToAnchor:self.titleField.trailingAnchor],

        [self.tagsTableView.topAnchor constraintEqualToAnchor:tagsLabel.bottomAnchor constant:8],
        [self.tagsTableView.leadingAnchor constraintEqualToAnchor:self.titleField.leadingAnchor],
        [self.tagsTableView.trailingAnchor constraintEqualToAnchor:self.titleField.trailingAnchor],
        [self.tagsTableView.heightAnchor constraintEqualToConstant:240],
        [self.tagsTableView.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-24]
    ]];
}

- (void)applyEditingDataIfNeeded {
    if (!self.editingDiary) {
        self.selectedDate = [NSDate date];
        [self.dateButton setTitle:[DateUtils displayDateStringFromDate:self.selectedDate] forState:UIControlStateNormal];
        return;
    }

    self.titleField.text = self.editingDiary.title;
    self.contentTextView.text = self.editingDiary.content;
    self.selectedDate = [DateUtils dateFromApiDateString:self.editingDiary.date ?: @""];
    [self.dateButton setTitle:[DateUtils displayDateStringFromDate:self.selectedDate] forState:UIControlStateNormal];

    for (TagModel *tag in self.editingDiary.tags) {
        [self.selectedTagIds addObject:@(tag.tagId)];
    }
}

- (void)loadTags {
    __weak typeof(self) weakSelf = self;
    [[HTTPClient sharedClient] fetchTagsWithSuccess:^(NSArray<TagModel *> *items) {
        __strong typeof(weakSelf) self = weakSelf;
        [self.allTags removeAllObjects];
        [self.allTags addObjectsFromArray:items];
        [self.tagsTableView reloadData];
    } failure:^(NSError *error, NSString *message, NSInteger code) {
        __strong typeof(weakSelf) self = weakSelf;
        [ToastUtils showToastInView:self.view text:message ?: @"标签加载失败"];
    }];
}

- (void)dateTapped {
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"选择日期" message:@"\n\n\n\n\n\n\n\n" preferredStyle:UIAlertControllerStyleActionSheet];

    UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(8, 18, sheet.view.bounds.size.width - 16, 180)];
    picker.datePickerMode = UIDatePickerModeDate;
    picker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    picker.date = self.selectedDate ?: [NSDate date];
    [sheet.view addSubview:picker];

    [sheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [sheet addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.selectedDate = picker.date;
        [self.dateButton setTitle:[DateUtils displayDateStringFromDate:self.selectedDate] forState:UIControlStateNormal];
    }]];

    [self presentViewController:sheet animated:YES completion:nil];
}

- (void)addTagTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"新增标签" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"输入标签名";
    }];

    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"创建" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *name = alert.textFields.firstObject.text ?: @"";
        if (name.length == 0) {
            [ToastUtils showToastInView:self.view text:@"标签名不能为空"];
            return;
        }

        [[HTTPClient sharedClient] createTagWithName:name success:^(TagModel *tag) {
            [self.selectedTagIds addObject:@(tag.tagId)];
            [self loadTags];
        } failure:^(NSError *error, NSString *message, NSInteger code) {
            [ToastUtils showToastInView:self.view text:message ?: @"新增标签失败"];
        }];
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)saveTapped {
    NSString *title = self.titleField.text ?: @"";
    NSString *content = self.contentTextView.text ?: @"";

    if (![FormValidator isValidDiaryTitle:title]) {
        [ToastUtils showToastInView:self.view text:@"标题不能为空且不超过100字"]; return;
    }
    if (![FormValidator isValidDiaryContent:content]) {
        [ToastUtils showToastInView:self.view text:@"内容不能为空"]; return;
    }

    NSString *date = [DateUtils apiDateStringFromDate:self.selectedDate ?: [NSDate date]];
    NSArray<NSNumber *> *tagIds = self.selectedTagIds.allObjects;
    NSArray<TagModel *> *selectedTags = [self selectedTagsFromCurrentSelection];

    [ToastUtils showLoadingInView:self.view text:@"保存中..."];
    __weak typeof(self) weakSelf = self;

    BOOL isUpdateRemote = self.editingDiary && self.editingDiary.diaryId > 0;
    if (isUpdateRemote) {
        [[HTTPClient sharedClient] updateDiaryId:self.editingDiary.diaryId title:title content:content date:date tagIds:tagIds success:^(DiaryModel *diary) {
            __strong typeof(weakSelf) self = weakSelf;
            [[CoreDataManager sharedManager] upsertDiary:diary pendingAction:nil];
            [ToastUtils hideLoadingInView:self.view];
            if (self.onSaved) { self.onSaved(); }
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSError *error, NSString *message, NSInteger code) {
            __strong typeof(weakSelf) self = weakSelf;
            [self saveDiaryOfflineWithTitle:title content:content date:date selectedTags:selectedTags tagIds:tagIds isUpdate:YES];
            [ToastUtils hideLoadingInView:self.view];
            [ToastUtils showToastInView:self.view text:@"网络不可用，已离线保存，恢复后自动同步"];
            if (self.onSaved) { self.onSaved(); }
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } else {
        [[HTTPClient sharedClient] createDiaryWithTitle:title content:content date:date tagIds:tagIds success:^(DiaryModel *diary) {
            __strong typeof(weakSelf) self = weakSelf;
            [[CoreDataManager sharedManager] upsertDiary:diary pendingAction:nil];
            [ToastUtils hideLoadingInView:self.view];
            if (self.onSaved) { self.onSaved(); }
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSError *error, NSString *message, NSInteger code) {
            __strong typeof(weakSelf) self = weakSelf;
            [self saveDiaryOfflineWithTitle:title content:content date:date selectedTags:selectedTags tagIds:tagIds isUpdate:NO];
            [ToastUtils hideLoadingInView:self.view];
            [ToastUtils showToastInView:self.view text:@"网络不可用，已离线保存，恢复后自动同步"];
            if (self.onSaved) { self.onSaved(); }
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}

- (void)saveDiaryOfflineWithTitle:(NSString *)title
                          content:(NSString *)content
                             date:(NSString *)date
                     selectedTags:(NSArray<TagModel *> *)selectedTags
                           tagIds:(NSArray<NSNumber *> *)tagIds
                         isUpdate:(BOOL)isUpdate {
    DiaryModel *localDiary = [[DiaryModel alloc] init];
    NSInteger originalId = self.editingDiary.diaryId;
    if (isUpdate) {
        localDiary.diaryId = originalId;
    } else {
        NSInteger localId = originalId <= 0 ? -((NSInteger)(NSDate.date.timeIntervalSince1970 * 1000)) : originalId;
        localDiary.diaryId = localId;
    }

    localDiary.title = title;
    localDiary.content = content;
    localDiary.date = date;
    localDiary.tags = selectedTags;
    localDiary.createdAt = self.editingDiary.createdAt;

    NSString *pendingAction = isUpdate ? @"update" : @"create";
    [[CoreDataManager sharedManager] upsertDiary:localDiary pendingAction:pendingAction];

    NSMutableDictionary *payload = [@{
        @"title": title,
        @"content": content,
        @"date": date,
        @"tagIds": tagIds
    } mutableCopy];

    if (isUpdate) {
        payload[@"diaryId"] = @(localDiary.diaryId);
        [[CoreDataManager sharedManager] enqueuePendingOperationType:@"update" payload:payload replaceForLocalDiaryId:@(localDiary.diaryId)];
    } else {
        payload[@"localDiaryId"] = @(localDiary.diaryId);
        [[CoreDataManager sharedManager] enqueuePendingOperationType:@"create" payload:payload replaceForLocalDiaryId:@(localDiary.diaryId)];
    }
}

- (NSArray<TagModel *> *)selectedTagsFromCurrentSelection {
    NSMutableArray<TagModel *> *selected = [NSMutableArray array];
    for (TagModel *tag in self.allTags) {
        if ([self.selectedTagIds containsObject:@(tag.tagId)]) {
            [selected addObject:tag];
        }
    }
    return selected;
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allTags.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"XindongrijiApp.TagSelectCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }

    TagModel *tag = self.allTags[indexPath.row];
    cell.textLabel.text = tag.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"#%ld", (long)tag.tagId];
    cell.accessoryType = [self.selectedTagIds containsObject:@(tag.tagId)] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TagModel *tag = self.allTags[indexPath.row];
    NSNumber *tagId = @(tag.tagId);

    if ([self.selectedTagIds containsObject:tagId]) {
        [self.selectedTagIds removeObject:tagId];
    } else {
        [self.selectedTagIds addObject:tagId];
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
