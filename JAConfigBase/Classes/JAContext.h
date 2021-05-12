

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
/*
 * 统一管理TabBarController
 * 可以更容易获取根UINavigationController
 * @xzoscar
 */
@interface JAContext : NSObject


+ (JAContext *)sharedContext;


- (UINavigationController *)topNavigation;


- (nullable UITabBarController *)rootViewController;

/*
 * 切换到 index tab
 * @xzoscar */

- (void)switchToTapIndex:(NSUInteger)index;

- (void)clearViewCtrlersWithCommplete:(dispatch_block_t)complete;

//移除navigation栈其中某一个VC
- (void)removeOneOfVC:(Class)className;


/*
 * 清除root tabBarController下 所有view controllers
 * @paras tabIndex : clear完成后:切换到index tab
 * @paras controller :
 *        如果controller是UINavigationController, present controller \
 *        如果controller是UIViewController, push controller \
 * @xzoscar
 */
- (void)switchToTabIndex:(NSUInteger)tabIndex targetCtrler:(UIViewController *)controller animated:(BOOL)animated;

/*
 * 清除root tabBarController下 所有view controllers
 * @paras 'controller' : clear完成后,present controller
 * @xzoscar
 */
- (void)presentViewController:(UINavigationController *)viewController animated: (BOOL)flag completion:(void (^)(void))completion;

//回到第一个tab下
- (void)goToHome;

//返回标签tab控制器中的某个index下
- (void)backToTabIndex:(NSInteger)index;

//当前显示VC
- (nullable UIViewController *)currentVisibleController;

//判断在首页，哪个tab
- (NSInteger)IndexOfTabAtHomePage:(UIViewController *)vc;
//获取显示在最上层的VC
- (UIViewController *)topViewController;

@end

NS_ASSUME_NONNULL_END
