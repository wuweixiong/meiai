// BEGINNER GUIDE:
// File: DiaryEditorViewController.m
// Role: UI layer: builds screens, handles taps, and calls services.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp DiaryEditorViewController.m
#import "DiaryEditorViewController.h"
#import "Network/XDJDiaryService.h"
#import "Network/XDJTagService.h"
#import "Utils/XDJValidator.h"
#import "Utils/XDJDateHelper.h"
#import "Utils/UIViewController+XDJHUD.h"

@interface DiaryEditorViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITextField *titleField;
@property (nonatomic, strong) UITextView *contentView;
@property (nonatomic, strong) UIButton *dateButton;
@property (nonatomic, strong) UITableView *tagTableView;

@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSMutableArray<XDJTag *> *tagItems;
@property (nonatomic, strong) NSMutableSet<NSNumber *> *selectedTagIds;

@property (nonatomic, strong) XDJDiary *editingDiary;
@property (nonatomic, copy) dispatch_block_t submitSuccessBlock;

@property (nonatomic, strong) XDJDiaryService *diaryService;
@property (nonatomic, strong) XDJTagService *tagService;

@end

@implementation DiaryEditorViewController

- (instancetype)initWithDiary:(XDJDiary *)diary submitSuccessBlock:(dispatch_block_t)submitSuccessBlock {
    self = [super init];
    if (self) {
        _editingDiary = diary;
        _submitSuccessBlock = [submitSuccessBlock copy];
        _diaryService = [[XDJDiaryService alloc] init];
        _tagService = [[XDJTagService alloc] init];
        _tagItems = [NSMutableArray array];
        _selectedTagIds = [NSMutableSet set];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.editingDiary ? @"编辑日记" : @"新建日记";
    self.view.backgroundColor = UIColor.systemBackgroundColor;

    [self setupViews];
    [self loadTags];
    [self fillDataIfNeeded];
}

- (void)setupViews {
    CGFloat width = self.view.bounds.size.width - 24;

    self.titleField = [[UITextField alloc] initWithFrame:CGRectMake(12, 100, width, 44)];
    self.titleField.placeholder = @"标题（1-100字）";
    self.titleField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.titleField];

    self.contentView = [[UITextView alloc] initWithFrame:CGRectMake(12, CGRectGetMaxY(self.titleField.frame) + 8, width, 120)];
    self.contentView.layer.borderWidth = 1;
    self.contentView.layer.borderColor = UIColor.systemGray4Color.CGColor;
    self.contentView.layer.cornerRadius = 8;
    [self.view addSubview:self.contentView];

    self.dateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.dateButton.frame = CGRectMake(12, CGRectGetMaxY(self.contentView.frame) + 8, width, 40);
    [self.dateButton setTitle:@"选择日期" forState:UIControlStateNormal];
    [self.dateButton addTarget:self action:@selector(selectDateTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.dateButton];

    UILabel *tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, CGRectGetMaxY(self.dateButton.frame) + 8, width, 24)];
    tagLabel.text = @"标签（可多选）";
    [self.view addSubview:tagLabel];

    self.tagTableView = [[UITableView alloc] initWithFrame:CGRectMake(12, CGRectGetMaxY(tagLabel.frame) + 4, width, 180) style:UITableViewStylePlain];
    self.tagTableView.dataSource = self;
    self.tagTableView.delegate = self;
    [self.view addSubview:self.tagTableView];

    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    submitButton.frame = CGRectMake(12, CGRectGetMaxY(self.tagTableView.frame) + 12, width, 44);
    [submitButton setTitle:self.editingDiary ? @"更新日记" : @"保存日记" forState:UIControlStateNormal];
    submitButton.layer.cornerRadius = 8;
    submitButton.layer.borderWidth = 1;
    submitButton.layer.borderColor = UIColor.systemBlueColor.CGColor;
    [submitButton addTarget:self action:@selector(submitTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submitButton];
}

- (void)fillDataIfNeeded {
    if (!self.editingDiary) {
        self.selectedDate = [NSDate date];
        [self.dateButton setTitle:[XDJDateHelper displayDateStringFromDate:self.selectedDate] forState:UIControlStateNormal];
        return;
    }

    self.titleField.text = self.editingDiary.title;
    self.contentView.text = self.editingDiary.content;
    self.selectedDate = [XDJDateHelper dateFromApiDateString:self.editingDiary.date ?: @""];
    [self.dateButton setTitle:[XDJDateHelper displayDateStringFromDate:self.selectedDate] forState:UIControlStateNormal];

    for (XDJTag *tag in self.editingDiary.tags) {
        [self.selectedTagIds addObject:@(tag.id)];
    }
}

- (void)loadTags {
    __weak typeof(self) weakSelf = self;
    [self.tagService fetchTagsWithSuccess:^(NSArray<XDJTag *> *items) {
        __strong typeof(weakSelf) self = weakSelf;
        [self.tagItems removeAllObjects];
        [self.tagItems addObjectsFromArray:items];
        [self.tagTableView reloadData];
    } failure:^(NSError *error, NSString *message) {
        __strong typeof(weakSelf) self = weakSelf;
        [self xdj_showToast:message ?: @"标签加载失败"];
    }];
}

- (void)selectDateTapped {
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"选择日期" message:@"\n\n\n\n\n\n\n\n" preferredStyle:UIAlertControllerStyleActionSheet];

    UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(10, 20, sheet.view.bounds.size.width - 20, 160)];
    picker.datePickerMode = UIDatePickerModeDate;
    picker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    picker.date = self.selectedDate ?: [NSDate date];

    [sheet.view addSubview:picker];

    [sheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [sheet addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.selectedDate = picker.date;
        [self.dateButton setTitle:[XDJDateHelper displayDateStringFromDate:self.selectedDate] forState:UIControlStateNormal];
    }]];

    [self presentViewController:sheet animated:YES completion:nil];
}

- (void)submitTapped {
    NSString *title = self.titleField.text ?: @"";
    NSString *content = self.contentView.text ?: @"";

    if (![XDJValidator isValidDiaryTitle:title]) {
        [self xdj_showToast:@"标题不能为空且最多100字"]; return;
    }
    if (![XDJValidator isValidDiaryContent:content]) {
        [self xdj_showToast:@"内容不能为空"]; return;
    }

    NSString *date = [XDJDateHelper apiDateStringFromDate:self.selectedDate ?: [NSDate date]];
    NSArray<NSNumber *> *tagIds = [self.selectedTagIds allObjects];

    [self xdj_showLoading:@"提交中..."];
    __weak typeof(self) weakSelf = self;

    if (self.editingDiary) {
        [self.diaryService updateDiaryId:self.editingDiary.diaryId title:title content:content date:date tagIds:tagIds success:^(XDJDiary *diary) {
            __strong typeof(weakSelf) self = weakSelf;
            [self xdj_hideLoading];
            if (self.submitSuccessBlock) { self.submitSuccessBlock(); }
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSError *error, NSString *message) {
            __strong typeof(weakSelf) self = weakSelf;
            [self xdj_hideLoading];
            [self xdj_showToast:message ?: @"更新失败"];
        }];
    } else {
        [self.diaryService createDiaryWithTitle:title content:content date:date tagIds:tagIds success:^(XDJDiary *diary) {
            __strong typeof(weakSelf) self = weakSelf;
            [self xdj_hideLoading];
            if (self.submitSuccessBlock) { self.submitSuccessBlock(); }
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSError *error, NSString *message) {
            __strong typeof(weakSelf) self = weakSelf;
            [self xdj_hideLoading];
            [self xdj_showToast:message ?: @"创建失败"];
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tagItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"XindongrijiApp.TagSelectCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    XDJTag *tag = self.tagItems[indexPath.row];
    cell.textLabel.text = tag.name;
    cell.accessoryType = [self.selectedTagIds containsObject:@(tag.id)] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    XDJTag *tag = self.tagItems[indexPath.row];
    NSNumber *tagId = @(tag.id);
    if ([self.selectedTagIds containsObject:tagId]) {
        [self.selectedTagIds removeObject:tagId];
    } else {
        [self.selectedTagIds addObject:tagId];
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
