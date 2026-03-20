// BEGINNER GUIDE:
// File: TagManagerViewController.m
// Role: UI layer: builds screens, handles taps, and calls services.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp TagManagerViewController.m
#import "TagManagerViewController.h"
#import "Network/HTTPClient.h"
#import "Utils/ToastUtils.h"

@interface TagManagerViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<TagModel *> *tags;

@end

@implementation TagManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"标签管理";
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    self.tags = [NSMutableArray array];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"新增" style:UIBarButtonItemStylePlain target:self action:@selector(addTapped)];

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleInsetGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];

    [self requestTags];
}

- (void)requestTags {
    __weak typeof(self) weakSelf = self;
    [[HTTPClient sharedClient] fetchTagsWithSuccess:^(NSArray<TagModel *> *items) {
        __strong typeof(weakSelf) self = weakSelf;
        [self.tags removeAllObjects];
        [self.tags addObjectsFromArray:items];
        [self.tableView reloadData];
    } failure:^(NSError *error, NSString *message, NSInteger code) {
        __strong typeof(weakSelf) self = weakSelf;
        [ToastUtils showToastInView:self.view text:message ?: @"标签加载失败"];
    }];
}

- (void)addTapped {
    [self showTagEditAlertWithTitle:@"新增标签" defaultValue:nil onConfirm:^(NSString *name) {
        [[HTTPClient sharedClient] createTagWithName:name success:^(TagModel *tag) {
            [self requestTags];
        } failure:^(NSError *error, NSString *message, NSInteger code) {
            [ToastUtils showToastInView:self.view text:message ?: @"新增失败"];
        }];
    }];
}

- (void)showTagEditAlertWithTitle:(NSString *)title defaultValue:(nullable NSString *)defaultValue onConfirm:(void(^)(NSString *name))onConfirm {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = defaultValue;
        textField.placeholder = @"标签名";
    }];

    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *name = alert.textFields.firstObject.text ?: @"";
        if (name.length == 0) {
            [ToastUtils showToastInView:self.view text:@"标签名不能为空"];
            return;
        }
        onConfirm(name);
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tags.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"XindongrijiApp.TagManageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }

    TagModel *tag = self.tags[indexPath.row];
    cell.textLabel.text = tag.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"#%ld", (long)tag.tagId];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TagModel *tag = self.tags[indexPath.row];
    [self showTagEditAlertWithTitle:@"编辑标签" defaultValue:tag.name onConfirm:^(NSString *name) {
        [[HTTPClient sharedClient] updateTagId:tag.tagId name:name success:^(TagModel *tag) {
            [self requestTags];
        } failure:^(NSError *error, NSString *message, NSInteger code) {
            [ToastUtils showToastInView:self.view text:message ?: @"编辑失败"];
        }];
    }];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"删除" handler:^(UIContextualAction *action, UIView *sourceView, void (^completionHandler)(BOOL)) {
        __strong typeof(weakSelf) self = weakSelf;
        TagModel *tag = self.tags[indexPath.row];
        [[HTTPClient sharedClient] deleteTagId:tag.tagId success:^{
            [self.tags removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            completionHandler(YES);
        } failure:^(NSError *error, NSString *message, NSInteger code) {
            [ToastUtils showToastInView:self.view text:message ?: @"删除失败"];
            completionHandler(NO);
        }];
    }];

    return [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
}

@end
