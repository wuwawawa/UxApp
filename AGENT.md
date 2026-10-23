# AGENT.md — 折叠屏适配反例评测集

本工程是一个 **HarmonyOS 折叠屏 / 大屏适配问题的反例评测集**：每个案例页都 1:1 复刻某个真实 App 的
问题界面，并复现出该类适配问题。工程本身用于**后续的「问题检测 + 修复」评测**，所以案例页里
**不允许留下任何能直接得到答案的东西**（见下一节「铁律」）。

- 应用包名：`com.example.helloworld`（入口 Ability：`EntryAbility`，首页 `pages/Index`）
- 当前内容：4 个问题分类 —— 「截断重叠」16 个案例、「未避让安全区」15 个案例、
  「留白过多」14 个案例、「大图大字」10 个案例
- 验证方式：以常驻模拟器为主，设备名 / 序列号每次用 `devecocli device list` 现查，
  命令里显式指定 `--device` / `--target`（详见第三节）

---

## 一、铁律（违反即视为案例报废）

1. **禁止逃生通道**：不允许出现任何能一键关掉问题的开关或分支，包括但不限于
   - 顶层 `const XXX_ENABLED: boolean = false` / `ADAPTIVE_xxx` 之类的适配开关；
   - `private isXxxMode(): boolean { return ... }` 这种「返回 false 就不复现」的布尔谓词
     （判断条件应就地写在用到它的布局计算里）；
   - 被注释掉的「正确写法」、未调用的「正常版」@Builder / 组件；
   - 任何 `if (FIXED)` / `if (!BUGGY)` 形态的双实现。
2. **注释里不许写答案**：禁止出现
   - 「把 `X` 改成 `true/false` 即可看到正常的样子」这类操作指引；
   - 「设成 0 就不会重叠」「上下挪动 `XXX` 即可移动裁切位置」这类提示；
   - 「根因：……」段落、「旧版本为什么这么写」的推导、「这就是截断的来源」的结论。
   案例页头部注释只允许写四段：**复刻对象 → 设计基准 → 三态实测数据 → 问题表现**（现象描述）。
3. **图片必须用真图**：商品图、海报等要从截图里裁出来存成 `resources/base/media` 下的资源，
   用 `Image($r('app.media.xxx'))` 铺满，**不允许**用 `Row` / 色块 / 渐变块拼一个假图。
4. **尺寸必须量**：所有 vp 值从设备截图量出（密度 2.75，单屏态 `459.6×672vp` 为基准），
   注释里写清量测来源；不允许凭感觉调一个「差不多」的值。
5. **窗口尺寸不硬编码**：案例页用 `onAreaChange` 拿实时窗口宽高，随折叠 / 旋转即时重排；
   禁止把 `459.6` / `672` 当成运行时窗口尺寸去写死布局。
6. **首页文案只描述现象**：分类卡片、案例卡片、清单副标题都只写「看到什么」，
   不写「因为什么」「怎么修」。
7. **交付前三态实测**：改完必须在设备上切到三种屏态各截一张图确认，并跑通
   `devecocli build` 与 `devecocli check lint`（0 error）。

---

## 二、工程结构

```
UxApp/
├── AppScope/                     # 应用级配置（bundleName、图标、名称）
├── entry/                        # 唯一模块（@Entry 页面在 entry/src/main/ets/pages）
│   ├── build-profile.json5
│   └── src/main/
│       ├── module.json5          # deviceTypes: phone；页面入口 EntryAbility
│       ├── ets/
│       │   ├── entryability/EntryAbility.ets
│       │   ├── entrybackupability/EntryBackupAbility.ets
│       │   ├── common/
│       │   │   ├── WindowModeController.ets   # 沉浸式窗口协调（setWindowLayoutFullScreen + 系统栏内容色）
│       │   │   ├── HemaTownScene.ets          # 盒马首页公共场景（整页按窗口宽度缩放）
│       │   │   └── MeituanBikeScene.ets       # 美团骑车首页公共场景
│       │   └── pages/
│       │       ├── Index.ets                  # 首页：4 个问题分类 + 统一路由解析 resolvePage
│       │       ├── truncation/                # 分类 01「截断重叠」
│       │       │   ├── TruncationCaseList.ets      # 分类页：案例表 + 搜索/标签筛选 + 页面注册
│       │       │   ├── FilterDialogTruncation.ets
│       │       │   ├── VipRenewalSheetTruncation.ets
│       │       │   ├── HemaTaskSheetTruncation.ets
│       │       │   ├── HemaMyMenuTruncation.ets
│       │       │   ├── BikeGiftDialogTruncation.ets
│       │       │   ├── CouponRulesDialogTruncation.ets
│       │       │   ├── PharmacySearchTruncation.ets
│       │       │   ├── LoginPageOverlapTruncation.ets
│       │       │   ├── FundDetailOverflow.ets       # 平安基金详情页大字溢出
│       │       │   ├── HnaTravelProductOverflow.ets # 海航出行产品页标题溢出
│       │       │   ├── HnaMealServiceOverlap.ets    # 海航餐食服务页文字压字
│       │       │   ├── HnaLoungeWrap.ets            # 海航贵宾室机场名竖排
│       │       │   ├── DisneyTicketDateOverflow.ets # 迪士尼门票日期格溢出
│       │       │   ├── StationBoardOverflow.ets     # 车站大屏检票口压行
│       │       │   ├── DidiDeliveryHeaderOverflow.ets # 滴滴送货首页标题叠字
│       │       │   └── DidiOrderListOverflow.ets    # 滴滴我的订单地址溢出
│       │       ├── safearea/                  # 分类 02「未避让安全区」
│       │       │   ├── SafeAreaCaseList.ets        # 分类页：案例表 + 搜索/标签筛选 + 页面注册
│       │       │   ├── TaobaoOrderDetailNotch.ets  # 淘宝订单详情标题压挖孔（单屏态·顶部正中）
│       │       │   ├── WeiboHomeComposeNotch.ets   # 微博发布按钮压挖孔（双屏横屏·右上角，兼压状态栏）
│       │       │   ├── ElemeStoreMoreNotch.ets     # 饿了么店铺更多按钮压挖孔（双屏横屏·右上角，兼压状态栏）
│       │       │   ├── DidiRideTabsNotch.ets       # 滴滴车型切换压挖孔（单屏态·顶部正中）
│       │       │   ├── QqMusicLyricNotch.ets       # QQ音乐歌词页歌名压挖孔（单屏态·顶部正中）
│       │       │   ├── CalendarMonthNotch.ets      # 日历月视图月份压挖孔（单屏态·顶部正中）
│       │       │   ├── WechatMomentCameraNotch.ets # 朋友圈相机按钮压挖孔（双屏横屏·右上角，兼压状态栏）
│       │       │   ├── MeituanOrderServiceNotch.ets # 美团外卖客服按钮压挖孔（双屏横屏·右上角，兼压状态栏）
│       │       │   ├── JdOrderConfirmNotch.ets     # 京东确认订单标题压挖孔（单屏态·顶部正中）
│       │       │   ├── CtripFloatServiceNotch.ets  # 携程我的订单标题压挖孔（单屏态·顶部正中）
│       │       │   ├── BankTransferNavBar.ets      # 银行转账按钮压导航条
│       │       │   ├── GameStartNavBar.ets         # 游戏登录开始键压导航条
│       │       │   ├── FlightFilterStatusBar.ets   # 机票筛选面板压状态栏
│       │       │   ├── MailAddressStatusBar.ets    # 邮寄地址页拉起键盘压状态栏
│       │       │   └── ProfilePhoneStatusBar.ets   # 我的页手机号压状态栏
│       │       ├── whitespace/                # 分类 03「留白过多」
│       │       │   ├── WhitespaceCaseList.ets      # 分类页：案例表 + 搜索/标签筛选 + 页面注册
│       │       │   ├── GameCenterList.ets          # 游戏中心列表右侧空白
│       │       │   ├── PodcastCatalogSheet.ets     # 播客目录弹层「播放」到首集空白
│       │       │   ├── JobSearchCards.ets          # 招聘结果卡片右侧空白
│       │       │   ├── BankTransferHome.ets        # 转账首页「常用转账」下方空白
│       │       │   ├── FandengRankBoard.ets        # 榜单页右侧整列空白
│       │       │   ├── FlightStatusDetail.ets      # 航班动态页整屏空白
│       │       │   ├── CarSpecCompare.ets          # 配置对比表右侧空白
│       │       │   ├── BaiduSearchHot.ets          # 百度热搜榜大面积留白
│       │       │   ├── LuckinSearchResult.ets      # 咖啡搜索结果右侧空白
│       │       │   ├── QidianBrowseHistory.ets     # 浏览历史右侧空白
│       │       │   ├── QidianMonthRank.ets         # 月票榜右侧空白
│       │       │   ├── BookshelfHistory.ets        # 书架历史右侧空白
│       │       │   ├── GalaxyNewsFavorite.ets      # 资讯收藏页整屏空白
│       │       │   └── WeiboUserCenterMargins.ets  # 用户中心展开态两侧边距
│       │       └── bigcontent/                # 分类 04「大图大字」
│       │           ├── BigContentCaseList.ets      # 分类页：案例表 + 页面注册
│       │           ├── PharmacyProductBigImage.ets # 看病买药商品图放大
│       │           ├── HemaMatchGridBigContent.ets # 盒马搭配商品图与字号放大
│       │           ├── TaobaoHomeBigBanner.ets     # 淘宝首页banner放大
│       │           ├── PddHomeBigContent.ets       # 拼多多首页大字大图
│       │           ├── DouyinProfileBigAvatar.ets  # 抖音个人页头像放大
│       │           ├── JdHomeBigIcon.ets           # 京东首页金刚区放大
│       │           ├── ElemeHomeBigBanner.ets      # 饿了么首页banner放大
│       │           ├── WeiboHotBigText.ets         # 微博热搜大字排行
│       │           ├── CtripHomeBigBanner.ets      # 携程首页卡片放大
│       │           └── XhsFeedBigImage.ets         # 小红书信息流大图
│       └── resources/base/
│           ├── element/          # color / float / string
│           ├── media/            # 图标 + 真实素材：product_*、hema_match_* 等从截图裁出；bc_*（大图大字案例）用 tools/draw_*.ps1（System.Drawing）绘制生成
│           └── profile/main_pages.json
├── tools/                        # 参考截图（原始证据，不入库）；hdc_screenshot.bat 辅助脚本
├── shots/                        # 本机验证截图（临时目录，不入库）
├── repro/                        # layout dump 临时文件（.gitignore 已忽略）
├── build-profile.json5           # 签名 + 产品配置（API 23）
├── code-linter.json5
└── oh-package.json5
```

路由分两层，两者压进同一个 `NavPathStack`：

1. `Index.ets` 的 `HOME_CATEGORIES` 管「问题分类」，`resolvePage()` 依次查分类表 →
   各分类的 `resolveXxxCasePage()`；
2. 分类页文件（`TruncationCaseList.ets` / `BigContentCaseList.ets`）里管「案例表 + @Builder」，
   案例路由统一形如 `truncation/pharmacy-search`、`bigcontent/pharmacy-big-image`。

> 案例页都是 `NavDestination`，不是独立的 `@Entry` 页面，所以**新增案例不需要改
> `resources/base/profile/main_pages.json`**，只改分类表和 `Index.ets` 的路由解析。

---

## 三、屏态与设备

三种屏态的分辨率与窗口尺寸（评测基准，取自 `tools/` 参考截图，密度 **2.75**，`vp = px / 2.75`）：

| 屏态 | 物理分辨率 (px) | 窗口 (vp) | 触发方式（模拟器） |
|---|---|---|---|
| 单屏态 | 1264×1848 | 459.6×672 | `fold close` |
| 双屏态竖屏 | 1828×2584 | 664.7×939.6 | `fold open`（不旋转） |
| 双屏态横屏 | 2584×1828 | 939.6×664.7 | `fold open` + `rotate` |

> 该设备的 `fold` 只接受 `open | half-open | close`（没有 `vertical-open`）；
> 竖屏 / 横屏是**旋转**决定的，不是折叠状态决定的。

### 挖孔（前置摄像头）位置实测 —— Pura X Max

同一颗物理挖孔圆，随屏态 / 旋转出现在不同位置（矩形单位 px，坐标系随屏幕当前方向）：

| 屏态 | 分辨率 (px) | 挖孔矩形 [X,Y,W,H] | 位置换算（vp，密度 2.75） |
|---|---|---|---|
| 单屏态（外屏） | 1264×1848 | `[599, 26, 66, 66]` | 顶部正中，24vp 圆：x 218~242，y 9.5~33.5 |
| 双屏态竖屏 | 1828×2584 | `[1728, 2470, 72, 72]` | 右下角，26.2vp 圆：距右 10.2vp、距底 15.3vp |
| 双屏态横屏 | 2584×1828 | `[2470, 28, 72, 72]` | 右上角，26.2vp 圆：距右 15.3vp、距顶 10.2vp |

- 瀑布屏四边（`WaterFall_L/T/R/B`）全为 0，本机无曲面参数。
- 展开态折痕：横屏是竖向中缝 `LiveCreaseRects [1194, 0, 196, 1828]`（196px 宽）；
  竖屏是横向中缝 `[0, 1194, 1828, 196]`。
- 挖孔数据挂在 **DisplayManagerService** 下（`WindowManagerService` 里没有），现查命令：

```powershell
hdc -t <serial> shell "hidumper -s DisplayManagerService -a '-a'"
# 输出里找 [CUTOUT INFO] 段：
#   BoundingRects<X,Y,W,H>      挖孔矩形（px，随当前旋转方向）
#   WaterFall_L/T/R/B<X,Y,W,H>  四边曲面区域
# 同段落的 PhysicalFoldStatus / Bounds<L,T,W,H> 标明当前屏态与分辨率
```

- 应用内等价 API：`display.getCutoutInfo()`（`@ohos.display`，取 `boundingRects`）或
  `window.getWindowAvoidArea(WindowAvoidAreaType.TYPE_CUTOUT)`。

### 选设备

- 模拟器一般常驻，**日常验证都走模拟器**（能脚本切折叠态、旋转、截图）。
- 设备名 / 序列号随时会变，不要写死：每次用 `devecocli device list` 现查，再显式传参 ——
  `ui` / `log` / `run` 用 `--device <name|serial>`，`emulator` 子命令用 `--target <name|serial>`。
- 不指定目标时，只要当前连接了多台设备就会报 `Multiple devices found`。

#### 没有设备可用时：自己拉起模拟器

`devecocli device list` 一台都没有（原样输出 `No active devices.` + 一句提示启动模拟器），或
`run` 报 `NO_DEVICE_AVAILABLE` / `No active devices` 时，**不要让用户手动去开、也不要空等**，
自己把常驻模拟器起起来：

```powershell
devecocli emulator list                    # 实例清单：Status=stopped 就是没在跑的
devecocli emulator start "Pura X Max"      # 起常驻实例（名字带空格，必须加引号）
devecocli device list                      # 轮询到它出现为止：Serial 由 - 变成 127.0.0.1:5555
```

- `start` 是**异步**的：返回 `started successfully` 只代表进程拉起来了。必须等到 `device list`
  里出现这台设备（实测冷启约 70s，再启动会快一些）再执行 `run` / `ui` / `log`，否则会
  `No active devices`；轮询间隔 3s 左右即可。
- 跑完不要停模拟器，保持常驻，下次直接 `device list` 复用。
- 起来之后照旧现查名字 / 序列号：重启模拟器后端口可能变，不要沿用旧值。
- `Pura X Max` 起不来就换 `Pura X Max2`；只有明确提示协议 / license 未接受时才交给用户处理
  （`devecocli emulator license`，需要交互终端），不要反复重试。
- `devecocli run --device "<已停止的模拟器>"` 会顺手把它拉起来，但 `ui` / `log` 不会 ——
  所以统一先按上面三步起设备、轮询到可用，再跑别的子命令。
- 刚起来的设备会沿用上次的折叠 / 旋转状态：接手后第一个动作建议 `fold close`（单屏态基准）
  再截一张图确认方向，别假设它已经是你想要的屏态。

#### 任务收尾：把设备恢复成双屏态横屏

一轮任务里会反复 `fold close` / `fold open` / `rotate`，设备很容易停在单屏态或双屏竖屏。
**收尾（提交 / 交付前）必须把模拟器恢复成「双屏态横屏」**：2584×1828px、窗口 939.6×664.7vp，
状态栏沿上边长边；不要留在单屏态、双屏竖屏或单屏横屏。

```powershell
devecocli emulator fold open --target "<dev>"                 # 先确保是展开态
devecocli ui screenshot --device "<dev>" --path .\shots\restore-<n>.png
# 按图片宽高判形态（不要信命令返回值，rotate 会滞后）：
#   2584×1828 = 双屏态横屏 → 目标形态，就停在这里
#   1828×2584 = 双屏态竖屏 → 再 rotate right 一次
#   1264×1848 / 1848×1264 = 单屏态 → 回到上面补 fold open
devecocli emulator rotate right --target "<dev>"              # 竖屏时补一次（每次转 90°）
```

- 判定只看截图：宽 > 高才是横屏。`rotate` 返回 success 不代表已生效，转完隔 3~5s 重截一张确认。
- `fold open` 自己就可能把方向带成横屏（本机实测会），也可能保持竖屏 —— 一律以截图尺寸为准。
- 恢复完再 `devecocli device list` 确认设备仍在线，并把这个最终形态写进交付说明。

---

## 四、常用命令

所有命令在工程根目录执行。下文 `<dev>` 用 `devecocli device list` 查到的设备名 / 序列号替换
（名字里带空格要加引号）；模拟器常驻，日常验证都用它。`ui` / `log` / `run` 传 `--device "<dev>"`，
`emulator` 子命令传 `--target "<dev>"`。

### 构建 / 部署

```powershell
devecocli build                                        # 编译打包（debug）
devecocli build clean                                  # 清理产物
devecocli run --device "<dev>"                         # 构建 + 安装 + 拉起（推荐）
devecocli run --skip-build --device "<dev>"            # 只安装已构建产物（改完代码需先 build）
devecocli run --uninstall --device "<dev>"             # 签名不一致时先卸载
hdc -t <serial> shell aa force-stop com.example.helloworld   # 冷启前杀进程
```

### 静态检查 / 日志

```powershell
devecocli check lint                                   # 要求 0 error（warning 允许）
devecocli log --device "<dev>" --level E --tail 200
devecocli log --device "<dev>" --crash --bundle-name com.example.helloworld
```

### 截图 / 交互 / 布局树

```powershell
devecocli ui screenshot --device "<dev>" --path .\shots\01.png   # 文件已存在会报错，每次换名
devecocli ui click --device "<dev>" 620 720                     # 当前方向下的 px 坐标
devecocli ui longclick --device "<dev>" 620 720
devecocli ui swipe --device "<dev>" 1200 1500 1200 650 --speed 2000
devecocli ui dircfling --device "<dev>" up                      # 方向翻页（滚动列表）
devecocli ui text --device "<dev>" "氯雷他定"                    # 往当前焦点输入
devecocli ui layout --device "<dev>" --format json              # 可见区域布局树（bounds 单位 px）
devecocli ui window list --device "<dev>" --format json
```

`ui layout --format json` 的输出前后会混入 CLI 的版本提示，解析前先截取第一个 `[` 到最后一个 `]`：

```powershell
$raw = (devecocli ui layout --device "<dev>" --format json 2>$null) -join "`n"
$json = $raw.Substring($raw.IndexOf('['), $raw.LastIndexOf(']') - $raw.IndexOf('[') + 1) | ConvertFrom-Json
```

### 折叠 / 旋转（仅模拟器）

```powershell
devecocli emulator fold close --target "<dev>"   # 单屏态
devecocli emulator fold open  --target "<dev>"   # 双屏态（保持当前方向）
devecocli emulator rotate right --target "<dev>" # 旋转 90°，横竖屏切换靠它
```

### 查设备信息 / 起设备

```powershell
devecocli device list                                                          # 设备名 / 序列号
devecocli emulator list                                                        # 模拟器实例（stopped 即没在跑）
devecocli emulator start "<name>"                                              # 没设备时自己拉起，再轮询 device list
devecocli device view -t "<dev>"                                               # 设备详情
hdc -t <serial> shell hidumper -s RenderService -a screen                      # 当前渲染分辨率
hdc -t <serial> shell "hidumper -s DisplayManagerService -a '-a'"              # Density / DPI / 挖孔位置（[CUTOUT INFO]，详见第三节）
```

---

## 五、新增一个案例

1. **量设计值**：从 `tools/` 的参考截图里按像素量位置和尺寸（`vp = px / 2.75`），
   用 PowerShell + `System.Drawing` 扫色块边界；商品图 / 海报等按边界裁成 `.jpg` 存到
   `entry/src/main/resources/base/media/`。
2. **写案例页**：`pages/<分类目录>/<CaseName>.ets`，`NavDestination` 根节点、
   `hideTitleBar(true)`、`WindowModeController.acquire(win, '#000000')`（离开 `release`）、
   `onAreaChange` 更新 `winWidthVp` / `winHeightVp`。
3. **注册路由**：在对应分类页文件的 `XXX_CASES` 里追加一条（`caseRoute` / `caseTitle` /
   `caseTag` / `caseIcon` / `caseSummary` / `casePage`），并补一个 `@Builder`。
   分类页的搜索框与标签筛选栏（「全部」+ 各 `caseTag` 去重、带案例数）都是自动从这张表生成的，
   新增案例只需填好 `caseTag`，不用单独改筛选栏。
4. **同步数量**：分类的 `categoryCaseCount` 用导出的 `XXX_CASE_COUNT`，首页卡片文案只写现象。
5. **三态自测**：在模拟器上切单屏 / 双屏竖屏 / 双屏横屏各截一张，确认该案例的目标屏态稳定复现；
   另外两态按复刻对象核对，以原 App 截图的实际表现为准（不要求「一定完全正常」）。
6. **构建 + lint + 收尾**：`devecocli build`、`devecocli check lint` 通过后，按第三节
   「任务收尾」把设备恢复成**双屏态横屏**（截图 2584×1828）再提交。

> 写 `.ets` 前，若当前环境装有 `hmos-arkui-develop-skill`（ArkTS 致命坑清单 / API 签名）
> 与 `deveco-cli`（构建、部署、设备、UI 操作）两个技能，先加载它们再动手；本仓库的
> ArkTS 约定（显式类型、ForEach 必须给 key、V1/V2 状态管理不混用等）以该技能为准。

案例页注释模板（只这四段，不要多写）：

```ets
/**
 * 反例：截断 / 看病买药搜索框截断（文字截断）
 *
 * 复刻美团「看病买药」首页：黄色渐变头部、白底搜索框、频道栏……
 *
 * 头部与卡片尺寸都按单屏态截图（459.6×672vp，密度 2.75）量出的设计值摆放：
 *   单屏态        459.6×672vp   —— 正常
 *   双屏态竖屏    664.7×939.6vp —— 正常
 *   双屏态横屏    939.6×664.7vp —— 搜索框上面一半被裁掉
 *
 * 问题表现（双屏态横屏）：
 *   贴着标题行下沿露出白色，占位文字、相机图标、「搜索」都只剩半截。
 */
```

---

## 六、已知坑

1. **多设备必须选目标**：连接了多台设备时，`ui` / `log` / `run` 不带 `--device` 会报
   `Multiple devices found`；`emulator` 子命令的 `--target` 是必填项。
2. **`rotate` 不一定立即生效**：命令返回 success 但方向可能没变（会被合并 / 延后到下一次窗口变化），
   必须截图后按图片尺寸判断当前方向；不生效就再发一次，或改用 `rotate right`。切换页面 / 重装
   也可能把方向带走。所以**收尾必须按第三节把设备恢复成双屏态横屏（2584×1828）**。
3. **截图可能拿到上一帧**：点进去后立刻截图有机会拿到旧画面。等 1.5~2s 再截，或换文件名重截一张。
4. **`ui click` 用的是当前方向的 px 坐标**，不是 vp，旋转后要重新量（可用 `ui layout` 取 bounds 中心）。
5. **不要用 PowerShell 的 `Set-Content` 改 `.ets`**：会把 UTF-8 写成 GBK，出现
   `Unterminated string literal` / 乱码注释，必须用编辑器工具按 UTF-8 写。
6. **折叠 / 旋转不需要重启 App**：页面靠 `onAreaChange` 即时重排；但没有 `onAreaChange` 的页面不会跟着变。
7. **沉浸式是全局状态**：`WindowModeController` 用 token 集合 + 串行队列管理
   `setWindowLayoutFullScreen`，页面进入 `acquire`、退出 `release`，不要自己直接调窗口接口。
8. **`devecocli ui screenshot` 不覆盖已有文件**：同一路径第二次会报
   `Screenshot file already exists`，每次给新路径。
9. **没设备就自己起**：`device list` 为空 / `run` 报 `NO_DEVICE_AVAILABLE` 时，按第三节
   「没有设备可用时」自己 `emulator start`，轮询 `device list` 到该设备出现再继续，
   不要停下来等用户去开模拟器；`emulator start` 返回成功 ≠ 已可连。
10. **模拟器会掉**：机器休眠 / 重启 / 模拟器被关掉后 `Status` 会变成 `stopped`，`Serial` 变回 `-`；
    接手任务先 `device list`，空了就按上一条重新拉起，别照抄上次的序列号。

---

## 七、提交规范

- 提交信息用英文前缀 + 简短描述，与历史保持一致：
  `feat: add xxx case`、`refactor: ...`、`docs: ...`、`fix: ...`
- 一个案例一个 `feat:` 提交（案例页 + 分类表 + 首页路由 + 图片资源）。
- **不要提交**：`tools/` 下的原始参考截图、`shots/` 下的验证截图、`repro/` 与构建产物（部分已在 `.gitignore`）。
- 提交前确认 `git status` 里只剩预期文件，并保证 `devecocli build`、`devecocli check lint` 通过；
  同时确认设备已恢复成**双屏态横屏**（2584×1828，见第三节「任务收尾」）。
