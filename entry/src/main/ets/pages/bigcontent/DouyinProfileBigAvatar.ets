/*
 * Copyright (c) 2026 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * 反例：大图大字 / 抖音个人页头像放大
 *
 * 复刻抖音个人主页：深色背景、返回 / 分享 / 扫一扫顶栏、圆形头像（bc_dy_avatar
 * 图片）、昵称与抖音号、性别 / 地区 / 年龄标签、关注 / 粉丝 / 获赞数据行、
 * 「编辑资料 / 分享主页」按钮、作品 / 喜欢 / 收藏页签、3×3 作品网格
 * （作品封面图片 + 点赞数角标）与底部 TabBar（含中间「+」发布按钮）。
 * 头像与作品封面使用 resources/base/media 下的图片资源（bc_dy_*）。
 *
 * 设计基准：单屏态截图 459.6×672vp（1264×1848px，密度 2.75）。
 * 头像直径 96vp、昵称字号 24vp、数据数字字号 24vp、作品缩略图高 140vp。
 *
 * 三个屏态的实测结果（头像、数据数字与作品缩略图随窗口宽度等比放大）：
 *   单屏态        459.6×672vp   —— 头像 96vp、数字字号 24vp，一屏能看两行作品
 *   双屏态竖屏    664.7×939.6vp —— 头像 139vp（×1.45）、数字字号 35vp，
 *                                 网格缩略图高 203vp，作品被推到屏幕下沿
 *   双屏态横屏    939.6×664.7vp —— 头像 196vp（×2.04）、数字字号 49vp，
 *                                 昵称与数据行被放大数倍，昵称顶出屏幕首屏，
 *                                 作品网格几乎完全看不见；顶栏与底部 TabBar
 *                                 仍是单屏态大小，中间巨大上下小
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 单屏态窗口宽度（1264px / 密度 2.75）：内容区所有尺寸的基准宽度 */
const DOUYIN_PROFILE_BASE_WIDTH: number = 459.6;
/** 单屏态窗口高度（1848px / 密度 2.75）：拿不到窗口高度时兜底 */
const DOUYIN_PROFILE_BASE_HEIGHT: number = 672;

/** 顶栏（固定尺寸，不随内容区放大）：行高 / 左右留白 / 圆形按钮直径 */
const DOUYIN_TOP_BAR_HEIGHT: number = 46;
const DOUYIN_TOP_BAR_PAD: number = 12;
const DOUYIN_ROUND_ICON: number = 30;

/** 头像：直径 96vp（随窗口等比放大） */
const DOUYIN_AVATAR_DIAMETER: number = 96;

/** 资料区字号（均随窗口等比放大）：昵称 24 / 抖音号 13 / 签名 13 / 标签 11 */
const DOUYIN_NICK_FONT: number = 24;
const DOUYIN_SUB_FONT: number = 13;
const DOUYIN_TAG_FONT: number = 11;

/** 数据行：数字字号 24 / 标签字号 12 / 单元宽（均随窗口等比放大） */
const DOUYIN_STAT_NUMBER_FONT: number = 24;
const DOUYIN_STAT_LABEL_FONT: number = 12;
const DOUYIN_STAT_CELL_WIDTH: number = 88;

/** 资料按钮：高 36vp / 字号 14（均随窗口等比放大） */
const DOUYIN_PROFILE_BUTTON_HEIGHT: number = 36;
const DOUYIN_PROFILE_BUTTON_FONT: number = 14;

/** 作品页签行：行高 44 / 字号 16 / 下划线 24×3（均随窗口等比放大） */
const DOUYIN_TAB_ROW_HEIGHT: number = 44;
const DOUYIN_TAB_FONT: number = 16;
const DOUYIN_TAB_UNDERLINE_WIDTH: number = 24;

/** 作品网格：缩略图高 140 / 点赞字号 11 / 列数与间距（均随窗口等比放大） */
const DOUYIN_WORK_THUMB_HEIGHT: number = 140;
const DOUYIN_WORK_LIKE_FONT: number = 11;
const DOUYIN_WORK_COLUMNS: number = 3;
const DOUYIN_WORK_GAP: number = 2;

/** 底部 TabBar（固定尺寸）：内容高 / 中间「+」按钮直径 */
const DOUYIN_TAB_BAR_HEIGHT: number = 52;
const DOUYIN_POST_BUTTON: number = 40;

/** 状态栏 / 底部手势区兜底高度（vp），拿不到避让区时使用 */
const DOUYIN_STATUS_BAR_FALLBACK: number = 32;
const DOUYIN_BOTTOM_INSET_FALLBACK: number = 8;

/** 配色 */
const DOUYIN_PAGE_BG: string = '#161823';
const DOUYIN_CARD_DARK: string = '#232530';
const DOUYIN_TEXT_MAIN: string = '#FFFFFF';
const DOUYIN_TEXT_GRAY: string = '#8A8C99';
const DOUYIN_BADGE_RED: string = '#FE2C55';
const DOUYIN_ACCENT_CYAN: string = '#25F4EE';

/** 头像与资料标签 */
const DOUYIN_PROFILE_TAGS: string[] = ['女', '上海', '24岁'];

/** 数据行：关注 / 粉丝 / 获赞 */
interface DouyinProfileStat {
  statId: string;
  statCount: string;
  statLabel: string;
}

const DOUYIN_PROFILE_STATS: DouyinProfileStat[] = [
  { statId: 'following', statCount: '128', statLabel: '关注' },
  { statId: 'followers', statCount: '3.2w', statLabel: '粉丝' },
  { statId: 'likes', statCount: '12.8w', statLabel: '获赞' }
];

/** 作品页签：第一个「作品」为选中态 */
const DOUYIN_WORK_TABS: string[] = ['作品', '喜欢', '收藏'];
const DOUYIN_ACTIVE_WORK_TAB: string = '作品';

/** 作品缩略图：视频封面图片资源 */
interface DouyinWorkThumb {
  workId: string;
  workImage: Resource;
  workLikeCount: string;
}

/** 作品网格：3×3 共 9 条作品 */
const DOUYIN_WORK_THUMBS: DouyinWorkThumb[] = [
  { workId: 'w1', workImage: $r('app.media.bc_dy_work_1'), workLikeCount: '12.8万' },
  { workId: 'w2', workImage: $r('app.media.bc_dy_work_2'), workLikeCount: '3.2万' },
  { workId: 'w3', workImage: $r('app.media.bc_dy_work_3'), workLikeCount: '8765' },
  { workId: 'w4', workImage: $r('app.media.bc_dy_work_4'), workLikeCount: '1.1万' },
  { workId: 'w5', workImage: $r('app.media.bc_dy_work_5'), workLikeCount: '5678' },
  { workId: 'w6', workImage: $r('app.media.bc_dy_work_6'), workLikeCount: '2.4万' },
  { workId: 'w7', workImage: $r('app.media.bc_dy_work_7'), workLikeCount: '932' },
  { workId: 'w8', workImage: $r('app.media.bc_dy_work_8'), workLikeCount: '6.8万' },
  { workId: 'w9', workImage: $r('app.media.bc_dy_work_9'), workLikeCount: '4521' }
];

/** 底部 TabBar：最后一个「我」为选中态 */
interface DouyinBottomTabEntry {
  tabId: string;
  tabLabel: string;
  tabSymbol: Resource;
  tabActive: boolean;
}

const DOUYIN_BOTTOM_TABS: DouyinBottomTabEntry[] = [
  { tabId: 'tab-home', tabLabel: '首页', tabSymbol: $r('sys.symbol.house'), tabActive: false },
  { tabId: 'tab-friend', tabLabel: '朋友', tabSymbol: $r('sys.symbol.person_2'), tabActive: false }
];

const DOUYIN_BOTTOM_TABS_RIGHT: DouyinBottomTabEntry[] = [
  { tabId: 'tab-message', tabLabel: '消息', tabSymbol: $r('sys.symbol.message'), tabActive: false },
  { tabId: 'tab-mine', tabLabel: '我', tabSymbol: $r('sys.symbol.person_fill'), tabActive: true }
];

/** 作品网格 9 条按 3 列折行后的行序号（3 行） */
const DOUYIN_WORK_ROW_INDEXES: number[] = [0, 1, 2];

@Component
export struct DouyinProfileBigAvatarPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = DOUYIN_PROFILE_BASE_WIDTH;
  @State winHeightVp: number = DOUYIN_PROFILE_BASE_HEIGHT;
  /** 沉浸式下的状态栏 / 底部手势区高度（vp） */
  @State statusBarHeightVp: number = DOUYIN_STATUS_BAR_FALLBACK;
  @State bottomInsetVp: number = DOUYIN_BOTTOM_INSET_FALLBACK;

  private pageActive: boolean = false;
  private windowToken: number = 0;

  aboutToAppear(): void {
    this.pageActive = true;
    this.enterImmersiveMode();
  }

  aboutToDisappear(): void {
    this.pageActive = false;
    if (this.windowToken > 0) {
      WindowModeController.release(this.windowToken);
      this.windowToken = 0;
    }
  }

  private enterImmersiveMode(): void {
    const hostContext = this.getUIContext().getHostContext();
    if (hostContext === undefined) {
      return;
    }
    window.getLastWindow(hostContext).then((win: window.Window) => {
      if (!this.pageActive) {
        return;
      }
      const avoidArea: window.AvoidArea = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      const topInset: number = this.getUIContext().px2vp(avoidArea.topRect.height);
      if (topInset > 0) {
        this.statusBarHeightVp = topInset;
      }
      const bottomInset: number = this.getUIContext().px2vp(avoidArea.bottomRect.height);
      if (bottomInset > 0) {
        this.bottomInsetVp = bottomInset;
      }
      this.windowToken = WindowModeController.acquire(win, DOUYIN_PAGE_BG);
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  // 尺寸计算：资料区每一处尺寸 = 单屏态设计值 × 窗口宽度比；顶栏与底部 TabBar 固定

  /** 内容区缩放比：窗口宽度 / 单屏态宽度（459.6vp） */
  private sceneScale(): number {
    if (this.winWidthVp <= 0) {
      return 1;
    }
    return this.winWidthVp / DOUYIN_PROFILE_BASE_WIDTH;
  }

  /** 把单屏态设计值放大到当前窗口宽度 */
  private vs(dimension: number): number {
    return dimension * this.sceneScale();
  }

  /** 取作品网格第 rowIndex 行（9 条作品按 3 列折行） */
  private worksOfRow(rowIndex: number): DouyinWorkThumb[] {
    const startIndex: number = rowIndex * DOUYIN_WORK_COLUMNS;
    return DOUYIN_WORK_THUMBS.slice(startIndex, startIndex + DOUYIN_WORK_COLUMNS);
  }

  // 顶栏（固定尺寸，不随内容区放大）

  @Builder
  roundIconButton(iconRes: Resource) {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width(DOUYIN_ROUND_ICON)
        .height(DOUYIN_ROUND_ICON)
        .backgroundColor(DOUYIN_CARD_DARK)
        .borderRadius(DOUYIN_ROUND_ICON / 2)

      SymbolGlyph(iconRes)
        .fontSize(15)
        .fontColor([DOUYIN_TEXT_MAIN])
    }
    .width(DOUYIN_ROUND_ICON)
    .height(DOUYIN_ROUND_ICON)
  }

  @Builder
  topBar() {
    Row({ space: 8 }) {
      SymbolGlyph($r('sys.symbol.chevron_left'))
        .fontSize(24)
        .fontColor([DOUYIN_TEXT_MAIN])
        .width(DOUYIN_ROUND_ICON + 4)
        .height(DOUYIN_ROUND_ICON + 4)
        .onClick(() => {
          this.pageStack.pop();
        })

      Blank()

      this.roundIconButton($r('sys.symbol.arrow_right_up_and_square'))

      this.roundIconButton($r('sys.symbol.qrcode'))
    }
    .width('100%')
    .height(DOUYIN_TOP_BAR_HEIGHT)
    .padding({ left: DOUYIN_TOP_BAR_PAD, right: DOUYIN_TOP_BAR_PAD })
    .alignItems(VerticalAlign.Center)
  }

  // 资料区：头像、昵称、数据行全部随窗口宽度等比放大

  @Builder
  avatarBlock() {
    Image($r('app.media.bc_dy_avatar'))
      .width(this.vs(DOUYIN_AVATAR_DIAMETER))
      .height(this.vs(DOUYIN_AVATAR_DIAMETER))
      .borderRadius(this.vs(DOUYIN_AVATAR_DIAMETER / 2))
      .objectFit(ImageFit.Cover)
  }

  @Builder
  profileMeta() {
    Column({ space: this.vs(8) }) {
      this.avatarBlock()

      Text('旅行日记本')
        .fontSize(this.vs(DOUYIN_NICK_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(DOUYIN_TEXT_MAIN)
        .maxLines(1)

      Text('抖音号: lvxing666')
        .fontSize(this.vs(DOUYIN_SUB_FONT))
        .fontColor(DOUYIN_TEXT_GRAY)
        .maxLines(1)

      Row({ space: this.vs(8) }) {
        ForEach(DOUYIN_PROFILE_TAGS, (tagLabel: string) => {
          Text(tagLabel)
            .fontSize(this.vs(DOUYIN_TAG_FONT))
            .fontColor(DOUYIN_TEXT_GRAY)
            .padding({ left: this.vs(8), right: this.vs(8), top: this.vs(2), bottom: this.vs(2) })
            .backgroundColor(DOUYIN_CARD_DARK)
            .borderRadius(this.vs(9))
        }, (tagLabel: string) => tagLabel)
      }
      .alignItems(VerticalAlign.Center)

      Text('自驾318川藏线 | 用镜头记录祖国大好河山')
        .fontSize(this.vs(DOUYIN_SUB_FONT))
        .fontColor(DOUYIN_TEXT_GRAY)
        .maxLines(1)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  statCell(statEntry: DouyinProfileStat) {
    Column({ space: this.vs(3) }) {
      Text(statEntry.statCount)
        .fontSize(this.vs(DOUYIN_STAT_NUMBER_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(DOUYIN_TEXT_MAIN)
        .maxLines(1)

      Text(statEntry.statLabel)
        .fontSize(this.vs(DOUYIN_STAT_LABEL_FONT))
        .fontColor(DOUYIN_TEXT_GRAY)
        .maxLines(1)
    }
    .width(this.vs(DOUYIN_STAT_CELL_WIDTH))
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  statRow() {
    Row() {
      ForEach(DOUYIN_PROFILE_STATS, (statEntry: DouyinProfileStat) => {
        this.statCell(statEntry)
      }, (statEntry: DouyinProfileStat) => statEntry.statId)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .margin({ top: this.vs(14) })
  }

  @Builder
  profileButtons() {
    Row({ space: this.vs(10) }) {
      Text('编辑资料')
        .fontSize(this.vs(DOUYIN_PROFILE_BUTTON_FONT))
        .fontColor(DOUYIN_TEXT_MAIN)
        .textAlign(TextAlign.Center)
        .height(this.vs(DOUYIN_PROFILE_BUTTON_HEIGHT))
        .layoutWeight(1)
        .backgroundColor(DOUYIN_CARD_DARK)
        .borderRadius(this.vs(DOUYIN_PROFILE_BUTTON_HEIGHT / 2))

      Text('分享主页')
        .fontSize(this.vs(DOUYIN_PROFILE_BUTTON_FONT))
        .fontColor(DOUYIN_TEXT_MAIN)
        .textAlign(TextAlign.Center)
        .height(this.vs(DOUYIN_PROFILE_BUTTON_HEIGHT))
        .layoutWeight(1)
        .border({ width: 1, color: '#3A3D4C' })
        .borderRadius(this.vs(DOUYIN_PROFILE_BUTTON_HEIGHT / 2))
    }
    .width('100%')
    .padding({ left: this.vs(16), right: this.vs(16) })
    .margin({ top: this.vs(14) })
    .alignItems(VerticalAlign.Center)
  }

  // 作品页签：字号与下划线随窗口宽度放大

  @Builder
  workTabItem(tabLabel: string) {
    Column() {
      Text(tabLabel)
        .fontSize(this.vs(DOUYIN_TAB_FONT))
        .fontWeight(tabLabel === DOUYIN_ACTIVE_WORK_TAB ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(tabLabel === DOUYIN_ACTIVE_WORK_TAB ? DOUYIN_TEXT_MAIN : DOUYIN_TEXT_GRAY)
        .maxLines(1)

      Column()
        .width(this.vs(DOUYIN_TAB_UNDERLINE_WIDTH))
        .height(this.vs(3))
        .backgroundColor(tabLabel === DOUYIN_ACTIVE_WORK_TAB ? DOUYIN_TEXT_MAIN : Color.Transparent)
        .borderRadius(this.vs(1.5))
        .margin({ top: this.vs(5) })
    }
    .height(this.vs(DOUYIN_TAB_ROW_HEIGHT))
    .padding({ left: this.vs(14), right: this.vs(14) })
    .justifyContent(FlexAlign.End)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  workTabBar() {
    Row() {
      ForEach(DOUYIN_WORK_TABS, (tabLabel: string) => {
        this.workTabItem(tabLabel)
      }, (tabLabel: string) => tabLabel)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Top)
  }

  // 作品网格：缩略图随窗口宽度放大，横屏时一屏放不下一条作品

  @Builder
  workThumbCell(workItem: DouyinWorkThumb) {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(workItem.workImage)
        .width('100%')
        .height(this.vs(DOUYIN_WORK_THUMB_HEIGHT))
        .objectFit(ImageFit.Cover)

      Row({ space: this.vs(3) }) {
        SymbolGlyph($r('sys.symbol.heart'))
          .fontSize(this.vs(12))
          .fontColor([Color.White])

        Text(workItem.workLikeCount)
          .fontSize(this.vs(DOUYIN_WORK_LIKE_FONT))
          .fontColor(Color.White)
          .maxLines(1)
      }
      .padding(this.vs(6))
      .alignItems(VerticalAlign.Center)
    }
    .layoutWeight(1)
    .height(this.vs(DOUYIN_WORK_THUMB_HEIGHT))
    .clip(true)
  }

  @Builder
  worksGrid() {
    Column({ space: this.vs(DOUYIN_WORK_GAP) }) {
      ForEach(DOUYIN_WORK_ROW_INDEXES, (rowIndex: number) => {
        Row({ space: this.vs(DOUYIN_WORK_GAP) }) {
          ForEach(this.worksOfRow(rowIndex), (workItem: DouyinWorkThumb) => {
            this.workThumbCell(workItem)
          }, (workItem: DouyinWorkThumb) => workItem.workId)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
      }, (rowIndex: number) => 'douyin-work-row-' + rowIndex.toString())
    }
    .width('100%')
    .padding({ left: 0, right: 0, top: this.vs(2), bottom: this.vs(12) })
  }

  // 底部 TabBar（固定尺寸）：中间「+」为渐变发布按钮

  @Builder
  bottomTabItem(tabEntry: DouyinBottomTabEntry) {
    Column({ space: 3 }) {
      SymbolGlyph(tabEntry.tabSymbol)
        .fontSize(22)
        .fontColor([tabEntry.tabActive ? Color.White : DOUYIN_TEXT_GRAY])

      Text(tabEntry.tabLabel)
        .fontSize(10.5)
        .fontColor(tabEntry.tabActive ? Color.White : DOUYIN_TEXT_GRAY)
        .maxLines(1)
    }
    .layoutWeight(1)
    .height(DOUYIN_TAB_BAR_HEIGHT)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  postButton() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width(DOUYIN_POST_BUTTON)
        .height(DOUYIN_POST_BUTTON)
        .linearGradient({ angle: 135, colors: [[DOUYIN_ACCENT_CYAN, 0.0], [DOUYIN_BADGE_RED, 1.0]] })
        .borderRadius(DOUYIN_POST_BUTTON / 2)

      Text('+')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
    }
    .width(DOUYIN_POST_BUTTON + 8)
    .height(DOUYIN_TAB_BAR_HEIGHT)
  }

  @Builder
  bottomTabBar() {
    Row() {
      ForEach(DOUYIN_BOTTOM_TABS, (tabEntry: DouyinBottomTabEntry) => {
        this.bottomTabItem(tabEntry)
      }, (tabEntry: DouyinBottomTabEntry) => tabEntry.tabId)

      this.postButton()

      ForEach(DOUYIN_BOTTOM_TABS_RIGHT, (tabEntry: DouyinBottomTabEntry) => {
        this.bottomTabItem(tabEntry)
      }, (tabEntry: DouyinBottomTabEntry) => tabEntry.tabId)
    }
    .width('100%')
    .height(DOUYIN_TAB_BAR_HEIGHT)
    .alignItems(VerticalAlign.Center)
  }

  build() {
    NavDestination() {
      Column() {
        // ① 顶栏：固定尺寸（padding.top 让出状态栏）
        Column() {
          this.topBar()
        }
        .width('100%')
        .padding({ top: this.statusBarHeightVp })

        // ② 资料区：头像、昵称、数据、作品网格全部随窗口宽度等比放大
        Scroll() {
          Column() {
            this.profileMeta()

            this.statRow()

            this.profileButtons()

            this.workTabBar()

            this.worksGrid()
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)

        // ③ 底部 TabBar + 手势区避让
        Column() {
          this.bottomTabBar()
        }
        .width('100%')
        .padding({ bottom: this.bottomInsetVp })
        .border({ width: { top: 0.5 }, color: '#2A2B33' })
        .backgroundColor(DOUYIN_PAGE_BG)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(DOUYIN_PAGE_BG)
      .onAreaChange((oldArea: Area, newArea: Area) => {
        if (typeof newArea.width === 'number' && newArea.width > 0) {
          this.winWidthVp = newArea.width;
        }
        if (typeof newArea.height === 'number' && newArea.height > 0) {
          this.winHeightVp = newArea.height;
        }
      })
    }
    .hideTitleBar(true)
  }
}
