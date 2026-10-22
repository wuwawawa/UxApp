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
 * 反例：大图大字 / 小红书信息流大图
 *
 * 复刻小红书「发现」信息流页：白色顶栏（搜索图标 + 关注 / 发现 / 附近页签 +
 * 菜单入口）、两列瀑布流笔记卡（渐变封面图 + 笔记标题 + 作者头像昵称 + 点赞数）、
 * 底部 TabBar（首页 / 商城 / 发布 / 消息 / 我）。「封面图」均以渐变色块 +
 * SymbolGlyph 绘制，不使用任何媒体资源。
 *
 * 设计基准：单屏态 459.6×672vp（1264×1848px，密度 2.75）。列宽约 210vp、
 * 封面高为列宽 × 1.05～1.42（约 220～300vp）、标题字号 13.5vp、单屏一屏
 * 约 4 张笔记。
 *
 * 三个屏态：
 *   单屏态        459.6×672vp   —— 列宽 210vp、封面高 220～300vp，一屏约 4 张笔记
 *   双屏态竖屏    664.7×939.6vp —— 全部 ×1.45：列宽 305vp、封面高 319～435vp，
 *                                  一屏只剩 2 张笔记
 *   双屏态横屏    939.6×664.7vp —— 全部 ×2.04：列宽 431vp、封面高 453～612vp，
 *                                  封面图放大两倍多、几乎占满整屏高度，
 *                                  一屏只剩 2 张图（每列 1 张）
 *
 * 问题表现（双屏态竖屏 / 横屏）：瀑布流封面图、标题与点赞数字号随窗口宽度整体
 * 等比放大：横屏下封面图 453～612vp 高，一张封面就吃掉大半屏，两列信息流退化成
 * 「一屏两张图」，浏览效率骤降；顶部页签与底部 Tab 却还是单屏态大小，上下小而
 * 中间巨大。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 单屏态窗口宽度（1264px / 密度 2.75）：信息流所有尺寸的基准宽度 */
const XHS_BASE_WIDTH: number = 459.6;
/** 单屏态窗口高度，拿不到窗口高度时兜底 */
const XHS_BASE_HEIGHT: number = 672;
/** 状态栏 / 底部手势区兜底高度（vp） */
const XHS_STATUS_BAR_FALLBACK: number = 32; const XHS_BOTTOM_INSET_FALLBACK: number = 8;
/** 配色 */
const XHS_PAGE_BG: string = '#F6F6F8';
const XHS_TEXT_MAIN: string = '#212126';
const XHS_TEXT_GRAY: string = '#8A8A90';
const XHS_LIKE_RED: string = '#FF2442';
/** 顶栏（固定尺寸，不随信息流放大） */
const XHS_TOP_BAR_HEIGHT: number = 44;
const XHS_TOP_ICON: number = 20;
const XHS_TAB_FONT: number = 16;
const XHS_TAB_UNDERLINE_WIDTH: number = 18;
const XHS_TAB_UNDERLINE_HEIGHT: number = 2.5;
const XHS_TOP_BAR_PAD: number = 12;
/** 瀑布流：左右留白 9vp、列间距 6vp、卡片圆角 8vp（随窗口放大） */
const XHS_FEED_SIDE_INSET: number = 9;
const XHS_FEED_COLUMN_GAP: number = 6;
const XHS_FEED_ROW_GAP: number = 6;
const XHS_CARD_RADIUS: number = 8;
const XHS_TITLE_FONT: number = 13.5;
const XHS_TITLE_LINE_HEIGHT: number = 19;
const XHS_AUTHOR_FONT: number = 11;
const XHS_AVATAR_SIZE: number = 16;
const XHS_COVER_GLYPH: number = 30;
/** 底部 TabBar（固定尺寸） */
const XHS_TAB_BAR_HEIGHT: number = 50;
const XHS_TAB_ICON: number = 22;
const XHS_TAB_LABEL_FONT: number = 10;
const XHS_PUBLISH_ICON: number = 30;

/** 瀑布流笔记卡数据：封面用渐变色块 + SymbolGlyph 绘制 */
interface XhsNoteCard {
  noteId: string;
  noteTitle: string;
  authorName: string;
  likeCount: string;
  /** 封面高 = 列宽 × coverRatio，各笔记高低错落形成瀑布流 */
  coverRatio: number;
  coverFrom: string;
  coverTo: string;
  coverSymbol: Resource;
}

const XHS_NOTES: XhsNoteCard[] = [
  {
    noteId: 'sunset', noteTitle: '追一场海边的日落｜超出片的 CityWalk 路线全攻略',
    authorName: '小鹿乱撞', likeCount: '1.2万', coverRatio: 1.30,
    coverFrom: '#FF9A62', coverTo: '#FF5E7E', coverSymbol: $r('sys.symbol.sun_max_fill')
  },
  {
    noteId: 'photo', noteTitle: '秋冬氛围感写真调色参数，直接抄作业',
    authorName: '阿白日记', likeCount: '8963', coverRatio: 1.18,
    coverFrom: '#8EC5FC', coverTo: '#E0C3FC', coverSymbol: $r('sys.symbol.camera_fill')
  },
  {
    noteId: 'cat', noteTitle: '小区流浪猫图鉴｜坚持投喂一个月的变化',
    authorName: '芝士就是力量', likeCount: '3.4万', coverRatio: 1.42,
    coverFrom: '#F6D365', coverTo: '#FDA085', coverSymbol: $r('sys.symbol.pawprint_fill')
  },
  {
    noteId: 'flower', noteTitle: '办公室水培鲜花指南，打工人的快乐源泉',
    authorName: '桃桃乌龙', likeCount: '5623', coverRatio: 1.24,
    coverFrom: '#FFDEE9', coverTo: '#B5FFFC', coverSymbol: $r('sys.symbol.flower')
  },
  {
    noteId: 'dinner', noteTitle: '深夜独居女生的治愈感一人食晚餐',
    authorName: '是月亮呀', likeCount: '9.8万', coverRatio: 1.36,
    coverFrom: '#4B6CB7', coverTo: '#182848', coverSymbol: $r('sys.symbol.moon_fill')
  },
  {
    noteId: 'anniv', noteTitle: '和男朋友的第 100 天纪念约会全记录',
    authorName: '小熊软糖', likeCount: '1.5万', coverRatio: 1.22,
    coverFrom: '#FF9A9E', coverTo: '#FECFEF', coverSymbol: $r('sys.symbol.heart_fill')
  },
  {
    noteId: 'bag', noteTitle: '通勤包里都有什么｜大包整理好物分享',
    authorName: '早起困难户', likeCount: '4488', coverRatio: 1.40,
    coverFrom: '#84FAB0', coverTo: '#8FD3F4', coverSymbol: $r('sys.symbol.bag_fill')
  },
  {
    noteId: 'music', noteTitle: '歌单分享｜适合写作业和阅读的纯音乐',
    authorName: '深夜电台', likeCount: '2.1万', coverRatio: 1.28,
    coverFrom: '#A18CD1', coverTo: '#FBC2EB', coverSymbol: $r('sys.symbol.music')
  }
];

/** 顶栏页签数据 */
interface XhsFeedTab {
  feedTabKey: string;
  feedTabLabel: string;
}

const XHS_FEED_TABS: XhsFeedTab[] = [
  { feedTabKey: 'follow', feedTabLabel: '关注' },
  { feedTabKey: 'find', feedTabLabel: '发现' },
  { feedTabKey: 'nearby', feedTabLabel: '附近' }
];

/** 底部 TabBar 数据 */
interface XhsBottomTabEntry {
  xtabKey: string;
  xtabLabel: string;
  xtabSymbol: Resource;
  xtabActive: boolean;
}

const XHS_BOTTOM_TABS: XhsBottomTabEntry[] = [
  { xtabKey: 'home', xtabLabel: '首页', xtabSymbol: $r('sys.symbol.house'), xtabActive: true },
  { xtabKey: 'mall', xtabLabel: '商城', xtabSymbol: $r('sys.symbol.store'), xtabActive: false },
  { xtabKey: 'publish', xtabLabel: '发布', xtabSymbol: $r('sys.symbol.plus_circle_fill'), xtabActive: false },
  { xtabKey: 'message', xtabLabel: '消息', xtabSymbol: $r('sys.symbol.message'), xtabActive: false },
  { xtabKey: 'mine', xtabLabel: '我', xtabSymbol: $r('sys.symbol.person'), xtabActive: false }
];

@Component
export struct XhsFeedBigImagePage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = XHS_BASE_WIDTH;
  @State winHeightVp: number = XHS_BASE_HEIGHT;
  /** 沉浸式下的状态栏 / 底部手势区高度（vp） */
  @State statusBarHeightVp: number = XHS_STATUS_BAR_FALLBACK;
  @State bottomInsetVp: number = XHS_BOTTOM_INSET_FALLBACK;
  /** 顶栏当前页签：follow / find / nearby */
  @State activeTab: string = 'find';

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
      // 顶栏是白底，系统栏内容用黑色
      this.windowToken = WindowModeController.acquire(win, '#000000');
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  // ---------- 尺寸与数据：瀑布流每一处尺寸由窗口宽度推出 ----------

  /** 场景缩放比：窗口宽度 / 单屏态宽度（459.6vp），展开态约 ×1.45 / ×2.04 */
  private sceneScale(): number {
    if (this.winWidthVp <= 0) {
      return 1;
    }
    return this.winWidthVp / XHS_BASE_WIDTH;
  }

  /** 按场景缩放比放大单屏态设计值 */
  private vs(designValue: number): number {
    return designValue * this.sceneScale();
  }

  /** 瀑布流列宽 = 可用宽度按两列均分 */
  private noteColumnWidthVp(): number {
    const usableWidth: number = this.winWidthVp - this.vs(XHS_FEED_SIDE_INSET) * 2 -
      this.vs(XHS_FEED_COLUMN_GAP);
    return usableWidth / 2;
  }

  /** 封面高 = 列宽 × 各自比例，随窗口宽度一起放大 */
  private noteCoverHeightVp(coverRatio: number): number {
    return this.noteColumnWidthVp() * coverRatio;
  }

  /** 瀑布流左列：偶数下标的笔记 */
  private leftColumnNotes(): XhsNoteCard[] {
    const leftNotes: XhsNoteCard[] = [];
    for (let noteIndex: number = 0; noteIndex < XHS_NOTES.length; noteIndex += 2) {
      leftNotes.push(XHS_NOTES[noteIndex]);
    }
    return leftNotes;
  }

  /** 瀑布流右列：奇数下标的笔记 */
  private rightColumnNotes(): XhsNoteCard[] {
    const rightNotes: XhsNoteCard[] = [];
    for (let noteIndex: number = 1; noteIndex < XHS_NOTES.length; noteIndex += 2) {
      rightNotes.push(XHS_NOTES[noteIndex]);
    }
    return rightNotes;
  }

  // ---------- 顶栏：搜索 + 页签 + 菜单（固定尺寸） ----------

  @Builder
  feedTab(feedTab: XhsFeedTab) {
    Column() {
      Text(feedTab.feedTabLabel)
        .fontSize(XHS_TAB_FONT)
        .fontWeight(this.activeTab === feedTab.feedTabKey ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.activeTab === feedTab.feedTabKey ? XHS_TEXT_MAIN : XHS_TEXT_GRAY)
        .maxLines(1)
      Column()
        .width(XHS_TAB_UNDERLINE_WIDTH)
        .height(XHS_TAB_UNDERLINE_HEIGHT)
        .backgroundColor(this.activeTab === feedTab.feedTabKey ? XHS_TEXT_MAIN : Color.Transparent)
        .borderRadius(XHS_TAB_UNDERLINE_HEIGHT / 2)
        .margin({ top: 3 })
    }
    .justifyContent(FlexAlign.End)
    .onClick(() => {
      this.activeTab = feedTab.feedTabKey;
    })
  }

  @Builder
  topTabBar() {
    Row() {
      SymbolGlyph($r('sys.symbol.magnifyingglass'))
        .fontSize(XHS_TOP_ICON).fontColor([XHS_TEXT_MAIN])
      Row({ space: 22 }) {
        ForEach(XHS_FEED_TABS, (feedTab: XhsFeedTab) => {
          this.feedTab(feedTab)
        }, (feedTab: XhsFeedTab) => feedTab.feedTabKey)
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      SymbolGlyph($r('sys.symbol.ellipsis_circle'))
        .fontSize(XHS_TOP_ICON).fontColor([XHS_TEXT_MAIN])
    }
    .width('100%')
    .height(XHS_TOP_BAR_HEIGHT)
    .padding({ left: XHS_TOP_BAR_PAD, right: XHS_TOP_BAR_PAD })
    .alignItems(VerticalAlign.Center)
  }

  // ---------- 瀑布流笔记卡：渐变封面 + 标题 + 作者行（随窗口放大） ----------

  @Builder
  noteCard(note: XhsNoteCard) {
    Column() {
      // 封面图：渐变色块 + SymbolGlyph
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width('100%')
          .height(this.noteCoverHeightVp(note.coverRatio))
          .linearGradient({ angle: 135, colors: [[note.coverFrom, 0.0], [note.coverTo, 1.0]] })
        SymbolGlyph(note.coverSymbol)
          .fontSize(this.vs(XHS_COVER_GLYPH)).fontColor([Color.White]).opacity(0.9)
      }
      .width('100%')
      .height(this.noteCoverHeightVp(note.coverRatio))
      Column({ space: this.vs(5) }) {
        Text(note.noteTitle)
          .fontSize(this.vs(XHS_TITLE_FONT))
          .lineHeight(this.vs(XHS_TITLE_LINE_HEIGHT))
          .fontWeight(FontWeight.Medium)
          .fontColor(XHS_TEXT_MAIN)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Row({ space: this.vs(4) }) {
          Stack({ alignContent: Alignment.Center }) {
            Column()
              .width(this.vs(XHS_AVATAR_SIZE)).height(this.vs(XHS_AVATAR_SIZE))
              .linearGradient({ angle: 135, colors: [[note.coverFrom, 0.0], [note.coverTo, 1.0]] })
              .borderRadius(this.vs(XHS_AVATAR_SIZE) / 2)
            SymbolGlyph($r('sys.symbol.person_fill'))
              .fontSize(this.vs(XHS_AVATAR_SIZE) * 0.7).fontColor([Color.White])
          }
          .width(this.vs(XHS_AVATAR_SIZE)).height(this.vs(XHS_AVATAR_SIZE))
          Text(note.authorName)
            .fontSize(this.vs(XHS_AUTHOR_FONT))
            .fontColor(XHS_TEXT_GRAY)
            .maxLines(1)
            .layoutWeight(1)
          SymbolGlyph($r('sys.symbol.heart'))
            .fontSize(this.vs(XHS_AUTHOR_FONT) * 0.95).fontColor([XHS_LIKE_RED])
          Text(note.likeCount)
            .fontSize(this.vs(XHS_AUTHOR_FONT))
            .fontColor(XHS_TEXT_GRAY)
            .maxLines(1)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .padding({ left: this.vs(7), right: this.vs(7), top: this.vs(6), bottom: this.vs(8) })
      .alignItems(HorizontalAlign.Start)
    }
    .width(this.noteColumnWidthVp())
    .backgroundColor(Color.White)
    .borderRadius(this.vs(XHS_CARD_RADIUS))
    .clip(true)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  feedWaterfall() {
    Row({ space: this.vs(XHS_FEED_COLUMN_GAP) }) {
      Column({ space: this.vs(XHS_FEED_ROW_GAP) }) {
        ForEach(this.leftColumnNotes(), (note: XhsNoteCard) => {
          this.noteCard(note)
        }, (note: XhsNoteCard) => note.noteId)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Column({ space: this.vs(XHS_FEED_ROW_GAP) }) {
        ForEach(this.rightColumnNotes(), (note: XhsNoteCard) => {
          this.noteCard(note)
        }, (note: XhsNoteCard) => note.noteId)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding({ left: this.vs(XHS_FEED_SIDE_INSET), right: this.vs(XHS_FEED_SIDE_INSET),
      top: this.vs(XHS_FEED_ROW_GAP) })
    .alignItems(VerticalAlign.Top)
  }

  // ---------- 底部 TabBar（固定尺寸） ----------

  @Builder
  bottomTabBar() {
    Row() {
      ForEach(XHS_BOTTOM_TABS, (entry: XhsBottomTabEntry) => {
        Column({ space: 3 }) {
          if (entry.xtabKey === 'publish') {
            // 发布入口：红色大按钮
            SymbolGlyph(entry.xtabSymbol)
              .fontSize(XHS_PUBLISH_ICON).fontColor([XHS_LIKE_RED])
          } else {
            SymbolGlyph(entry.xtabSymbol).fontSize(XHS_TAB_ICON)
              .fontColor([entry.xtabActive ? XHS_TEXT_MAIN : XHS_TEXT_GRAY])
          }
          Text(entry.xtabLabel).fontSize(XHS_TAB_LABEL_FONT)
            .fontWeight(entry.xtabActive ? FontWeight.Medium : FontWeight.Normal)
            .fontColor(entry.xtabActive ? XHS_TEXT_MAIN : XHS_TEXT_GRAY)
            .maxLines(1)
        }
        .layoutWeight(1)
        .height(XHS_TAB_BAR_HEIGHT)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }, (entry: XhsBottomTabEntry) => entry.xtabKey)
    }
    .width('100%')
    .height(XHS_TAB_BAR_HEIGHT)
    .alignItems(VerticalAlign.Center)
  }

  build() {
    NavDestination() {
      Column() {
        // ① 白色顶栏：搜索 + 页签 + 菜单（固定尺寸）
        Column() {
          this.topTabBar()
        }
        .width('100%')
        .padding({ top: this.statusBarHeightVp })
        .backgroundColor(Color.White)
        // ② 瀑布流：封面图 / 标题 / 点赞数全部随窗口宽度等比放大
        Scroll() {
          this.feedWaterfall()
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .backgroundColor(XHS_PAGE_BG)
        // ③ 底部 TabBar + 手势区避让（固定尺寸）
        Column() {
          this.bottomTabBar()
        }
        .width('100%')
        .padding({ bottom: this.bottomInsetVp })
        .backgroundColor(Color.White)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(XHS_PAGE_BG)
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
