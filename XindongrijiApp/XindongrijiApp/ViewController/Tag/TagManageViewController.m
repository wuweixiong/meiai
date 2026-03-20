// BEGINNER GUIDE:
// File: TagManageViewController.m
// Role: UI layer: builds screens, handles taps, and calls services.
// Reading tip: Read declarations in .h first, then implementation flow in .m.

// XindongrijiApp TagManageViewController.m
#import "TagManageViewController.h"
#import "Network/XDJTagService.h"
#import "Utils/UIViewController+XDJHUD.h"

@interface TagManageViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<XDJTag *> *items;
@property (nonatomic, strong) XDJTagService *tagService;

@end

@implementation TagManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"标签管理";
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    self.items = [NSMutableArray array];
    self.tagService = [[XDJTagService alloc] init];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"新增" style:UIBarButtonItemStylePlain target:self action:@selector(addTapped)];

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];

    [self fetchTags];
}

- (void)fetchTags {
    __weak typeof(self) weakSelf = self;
    [self.tagService fetchTagsWithSuccess:^(NSArray<XDJTag *> *items) {
        __strong typeof(weakSelf) self = weakSelf;
        [self.items removeAllObjects];
        [self.items addObjectsFromArray:items];
        [self.tableView reloadData];
    } failure:^(NSError *error, NSString *message) {
        __strong typeof(weakSelf) self = weakSelf;
        [self xdj_showToast:message ?: @"标签加载失败"];
    }];
}

- (void)addTapped {
    [self showEditAlertWithTitle:@"新增标签" defaultText:nil confirm:^(NSString *name) {
        [self.tagService createTagWithName:name success:^(XDJTag *tag) {
            [self fetchTags];
        } failure:^(NSError *error, NSString *message) {
            [self xdj_showToast:message ?: @"新增失败"];
        }];
    }];
}

- (void)showEditAlertWithTitle:(NSString *)title defaultText:(NSString *)defaultText confirm:(void(^)(NSString *name))confirm {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = defaultText;
        textField.placeholder = @"标签名";
    }];

    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *name = alert.textFields.firstObject.text ?: @"";
        if (name.length == 0) {
            [self xdj_showToast:@"标签名不能为空"];
            return;
        }
        confirm(name);
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"XindongrijiApp.TagCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    XDJTag *tag = self.items[indexPath.row];
    cell.textLabel.text = tag.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"#%ld", (long)tag.id];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    XDJTag *tag = self.items[indexPath.row];
    [self showEditAlertWithTitle:@"编辑标签" defaultText:tag.name confirm:^(NSString *name) {
        [self.tagService updateTagWithId:tag.id name:name success:^(XDJTag *updatedTag) {
            [self fetchTags];
        } failure:^(NSError *error, NSString *message) {
            [self xdj_showToast:message ?: @"更新失败"];
        }];
    }];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"删除" handler:^(UIContextualAction *action, UIView *sourceView, void (^completionHandler)(BOOL)) {
        XDJTag *tag = weakSelf.items[indexPath.row];
        [weakSelf.tagService deleteTagWithId:tag.id success:^{
            [weakSelf.items removeObjectAtIndex:indexPath.row];
            [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            completionHandler(YES);
        } failure:^(NSError *error, NSString *message) {
            [weakSelf xdj_showToast:message ?: @"删除失败"];
            completionHandler(NO);
        }];
    }];
    return [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
}

@end
