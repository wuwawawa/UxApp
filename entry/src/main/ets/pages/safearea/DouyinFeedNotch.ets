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
 * 反例：未避让安全区 / 抖音视频流图标压挖孔（挖孔）
 *
 * 复刻抖音视频流页：全屏深色视频区（渐变占位 + 播放按钮 + 底部红色进度条与时长角标）、
 * 右侧操作列（头像 + 关注加号、点赞 12.3w、评论 5277、收藏 3216、分享 2316、旋转唱片）、
 * 左下角作者信息（@山野拾光、文案两行、原声条），底部「首页 / 推荐 / ＋ / 消息 / 我」页签。
 *
 * 设计基准：单屏态 459.6×672vp（1264×1848px，密度 2.75），vp = px / 2.75。
 *   底部页签：固定 56vp（不缩放），视频区高 = 窗口高 - 56vp；
 *   右侧操作列：宽 46vp、距右 10vp，底对齐设计高度 442vp
 *           （头像 54 + 间距 24 + 四个图标项 38+4+17 + 项距 18/18/18/24 + 唱片 50）；
 *   操作列纵向居中：列顶 y = (视频区高 - 442×scale) / 2，全部图标尺寸随窗口宽度等比放大；
 *   作者区：左下角，宽 232vp，距底 16vp；进度条高 2.5vp、时长角标右下 54×30vp。
 *
 * 三态实测（状态栏 + 挖孔摄像头占屏幕顶部约 0～40vp，挖孔在顶部一角）：
 *   单屏态      459.6×672vp   —— ×1.000：视频区高 616vp，图标列 y 87～529，完整显示
 *   双屏态竖屏  664.7×939.6vp —— ×1.446：视频区高 883.6vp，图标列 y 122～761，完整显示
 *   双屏态横屏  939.6×664.7vp —— ×2.044：视频区高 608.7vp，图标列放大到 903.4vp，
 *                                列顶 y -147：头像被整枚推出屏幕，点赞图标 y 12～90，
 *                                上半部压进顶部状态栏 / 挖孔摄像头区域
 *
 * 问题表现（双屏态横屏）：
 *   右侧点赞 / 评论图标列不避让挖孔：横屏放大后整列纵向撑爆视频区，头像滑出屏幕，
 *   点赞图标上半部压进挖孔摄像头区域被切一半，时间 / 电量叠在图标上。
 *   单屏态与双屏态竖屏下操作列位置正常。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 单屏态窗口宽度（1264px / 密度 2.75），整页横向尺寸的基准 */
const DY_BASE_WIDTH: number = 459.6;

/** 配色 */
const DY_PAGE_BG: string = '#0E0E12';
const DY_LIKE_RED: string = '#FE2C55';
const DY_ICON_TEXT: string = '#F2F2F4';
const DY_CAPTION_TEXT: string = '#E8E8E8';
const DY_TAB_DIM: string = '#9A9AA3';

/** 底部页签：固定高度（三态一致），视频区高度随之确定 */
const DY_TAB_BAR_HEIGHT: number = 56;

/** 右侧操作列：宽、右边距与各段设计高度 */
const DY_COL_WIDTH: number = 46;
const DY_COL_RIGHT: number = 10;
const DY_COL_AVATAR: number = 54;
const DY_COL_AVATAR_GAP: number = 24;
const DY_COL_ICON: number = 38;
const DY_COL_ICON_TEXT_GAP: number = 4;
const DY_COL_COUNT: number = 17;
const DY_COL_TAIL_GAP: number = 24;
const DY_COL_DISC: number = 50;

/** 右侧操作列整体设计高度：头像 + 间距 + 四个图标项（含计数行） + 尾距 + 唱片 = 442vp */
const DY_COL_TOTAL: number = DY_COL_AVATAR + DY_COL_AVATAR_GAP +
  4 * (DY_COL_ICON + DY_COL_ICON_TEXT_GAP + DY_COL_COUNT) + 3 * 18 + DY_COL_TAIL_GAP + DY_COL_DISC;

/** 右侧操作列条目（点赞 / 评论 / 收藏 / 分享） */
interface DouyinActionItem {
  actionKey: string;
  /** 计数文案（12.3w / 5277 / 3216 / 2316） */
  actionLabel: string;
  actionSymbol: Resource;
  actionTint: string;
  /** 该条与下一条的间距（vp，设计值） */
  actionGap: number;
}

@Component
export struct DouyinFeedNotchStatusBarPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽度（vp），随折叠 / 旋转实时更新；整页缩放比由它算出 */
  @State winWidthVp: number = DY_BASE_WIDTH;

  /** 窗口高度（vp）：视频区与操作列位置由它算出 */
  @State winHeightVp: number = 672;

  private pageActive: boolean = false;
  private windowToken: number = 0;

  private actionItems: DouyinActionItem[] = [];

  aboutToAppear(): void {
    this.pageActive = true;
    this.buildPageData();
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
      this.windowToken = WindowModeController.acquire(win, '#FFFFFF');
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  private buildPageData(): void {
    this.actionItems = [
      {
        actionKey: 'dy-like',
        actionLabel: '12.3w',
        actionSymbol: $r('sys.symbol.heart_fill'),
        actionTint: DY_LIKE_RED,
        actionGap: 18
      },
      {
        actionKey: 'dy-comment',
        actionLabel: '5277',
        actionSymbol: $r('sys.symbol.message'),
        actionTint: '#FFFFFF',
        actionGap: 18
      },
      {
        actionKey: 'dy-star',
        actionLabel: '3216',
        actionSymbol: $r('sys.symbol.star'),
        actionTint: '#FFFFFF',
        actionGap: 18
      },
      {
        actionKey: 'dy-share',
        actionLabel: '2316',
        actionSymbol: $r('sys.symbol.share'),
        actionTint: '#FFFFFF',
        actionGap: DY_COL_TAIL_GAP
      }
    ];
  }

  /** 整页缩放比：窗口宽度 / 单屏态宽度（459.6vp） */
  private sceneScale(): number {
    if (this.winWidthVp <= 0) {
      return 1;
    }
    return this.winWidthVp / DY_BASE_WIDTH;
  }

  /** 把按单屏态量出的设计值换算到当前窗口 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  /** 视频区高度：窗口高度减去底部页签 */
  private videoAreaHeightVp(): number {
    return Math.max(this.winHeightVp - DY_TAB_BAR_HEIGHT, 0);
  }

  /** 操作列左边：贴住窗口右缘 */
  private actionColumnXVp(): number {
    return this.winWidthVp - this.vs(DY_COL_RIGHT + DY_COL_WIDTH);
  }

  /** 操作列列顶：纵向居中；横屏放大后为负值，整列上沿冲出屏幕顶 */
  private actionColumnTopVp(): number {
    const columnHeight: number = this.vs(DY_COL_TOTAL);
    return (this.videoAreaHeightVp() - columnHeight) / 2;
  }

  // ------------------------------------------------------------------
  // 视频占位区
  // ------------------------------------------------------------------

  @Builder
  videoPlaceholder() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({ angle: 160, colors: [['#4A3B6E', 0.0], ['#2A3356', 0.55], ['#141826', 1.0]] })

      SymbolGlyph($r('sys.symbol.play_fill'))
        .fontSize(this.vs(56))
        .fontColor(['#59FFFFFF'])

      Column({ space: this.vs(6) }) {
        Text('城市黄昏 · 实拍')
          .fontSize(this.vs(12))
          .fontColor('#B9B9C6')
          .maxLines(1)

        Text('1080P 高清')
          .fontSize(this.vs(9))
          .fontColor('#8C8C99')
          .maxLines(1)
      }
      .alignItems(HorizontalAlign.Center)
      .margin({ top: this.vs(120) })
    }
    .width('100%')
    .height('100%')
  }

  // ------------------------------------------------------------------
  // 右侧操作列：头像 + 点赞 / 评论 / 收藏 / 分享 + 唱片
  // ------------------------------------------------------------------

  @Builder
  actionAvatar() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        SymbolGlyph($r('sys.symbol.person'))
          .fontSize(this.vs(24))
          .fontColor([Color.White])
      }
      .width(this.vs(DY_COL_WIDTH))
      .height(this.vs(DY_COL_WIDTH))
      .borderRadius(this.vs(DY_COL_WIDTH / 2))
      .linearGradient({ angle: 135, colors: [['#8C7BAA', 0.0], ['#4A5578', 1.0]] })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      Row() {
        SymbolGlyph($r('sys.symbol.plus'))
          .fontSize(this.vs(13))
          .fontColor([Color.White])
      }
      .width(this.vs(19))
      .height(this.vs(19))
      .borderRadius(this.vs(9.5))
      .backgroundColor(DY_LIKE_RED)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .offset({ y: this.vs(9.5) })
    }
    .width(this.vs(DY_COL_WIDTH))
    .height(this.vs(DY_COL_AVATAR))
  }

  @Builder
  actionItem(item: DouyinActionItem) {
    Column() {
      SymbolGlyph(item.actionSymbol)
        .fontSize(this.vs(DY_COL_ICON))
        .fontColor([item.actionTint])

      Text(item.actionLabel)
        .fontSize(this.vs(13))
        .fontColor(DY_ICON_TEXT)
        .height(this.vs(DY_COL_COUNT))
        .maxLines(1)
        .margin({ top: this.vs(DY_COL_ICON_TEXT_GAP) })
    }
    .width(this.vs(DY_COL_WIDTH))
    .alignItems(HorizontalAlign.Center)
    .margin({ bottom: this.vs(item.actionGap) })
  }

  @Builder
  musicDisc() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(this.vs(DY_COL_DISC))
        .height(this.vs(DY_COL_DISC))
        .borderRadius(this.vs(DY_COL_DISC / 2))
        .linearGradient({ angle: 135, colors: [['#3A4256', 0.0], ['#14161E', 1.0]] })

      Row()
        .width(this.vs(30))
        .height(this.vs(30))
        .borderRadius(this.vs(15))
        .backgroundColor(DY_PAGE_BG)

      Row()
        .width(this.vs(10))
        .height(this.vs(10))
        .borderRadius(this.vs(5))
        .linearGradient({ angle: 135, colors: [[DY_LIKE_RED, 0.0], ['#6E48C9', 1.0]] })
    }
    .width(this.vs(DY_COL_DISC))
    .height(this.vs(DY_COL_DISC))
  }

  @Builder
  actionColumn() {
    Column() {
      this.actionAvatar()

      Row()
        .height(this.vs(DY_COL_AVATAR_GAP))

      ForEach(this.actionItems, (item: DouyinActionItem) => {
        this.actionItem(item)
      }, (item: DouyinActionItem) => item.actionKey)

      this.musicDisc()
    }
    .width(this.vs(DY_COL_WIDTH))
    .alignItems(HorizontalAlign.Center)
    .position({ x: this.actionColumnXVp(), y: this.actionColumnTopVp() })
  }

  // ------------------------------------------------------------------
  // 左下角作者信息
  // ------------------------------------------------------------------

  @Builder
  authorBlock() {
    Column() {
      Text('@山野拾光')
        .fontSize(this.vs(16))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .maxLines(1)

      Text('路过全世界的黄昏，也算一种浪漫 #治愈系 #风景')
        .fontSize(this.vs(13.5))
        .fontColor(DY_CAPTION_TEXT)
        .maxLines(2)
        .lineHeight(this.vs(19))
        .margin({ top: this.vs(6) })

      Row({ space: this.vs(7) }) {
        Row()
          .width(this.vs(16))
          .height(this.vs(16))
          .borderRadius(this.vs(8))
          .linearGradient({ angle: 135, colors: [[DY_LIKE_RED, 0.0], ['#6E48C9', 1.0]] })

        Text('夜空的寂静 - 慧君 · 原声')
          .fontSize(this.vs(12.5))
          .fontColor('#D9D9DE')
          .maxLines(1)
      }
      .alignItems(VerticalAlign.Center)
      .margin({ top: this.vs(9) })
    }
    .width(this.vs(232))
    .alignItems(HorizontalAlign.Start)
    .margin({ left: this.vs(12), bottom: this.vs(16) })
  }

  // ------------------------------------------------------------------
  // 进度条与时长角标
  // ------------------------------------------------------------------

  @Builder
  progressBar() {
    Stack({ alignContent: Alignment.Start }) {
      Row()
        .width('100%')
        .height(this.vs(2.5))
        .backgroundColor('#33FFFFFF')

      Row()
        .width('34%')
        .height(this.vs(2.5))
        .backgroundColor(DY_LIKE_RED)
    }
    .width('100%')
    .height(this.vs(2.5))
    .position({ x: 0, y: this.videoAreaHeightVp() - this.vs(3) })
  }

  @Builder
  durationChip() {
    Text('05:12')
      .fontSize(this.vs(10))
      .fontColor(Color.White)
      .padding({ left: this.vs(6), right: this.vs(6), top: this.vs(2), bottom: this.vs(2) })
      .borderRadius(this.vs(4))
      .backgroundColor('#4D000000')
      .position({ x: this.winWidthVp - this.vs(54), y: this.videoAreaHeightVp() - this.vs(30) })
  }

  // ------------------------------------------------------------------
  // 底部页签（固定尺寸）：首页 / 推荐 / ＋ / 消息 / 我
  // ------------------------------------------------------------------

  @Builder
  feedTabLabel(tabText: string, tabActive: boolean) {
    Text(tabText)
      .fontSize(16)
      .fontWeight(tabActive ? FontWeight.Bold : FontWeight.Normal)
      .fontColor(tabActive ? Color.White : DY_TAB_DIM)
      .layoutWeight(1)
      .height('100%')
      .textAlign(TextAlign.Center)
  }

  @Builder
  postButton() {
    Row() {
      SymbolGlyph($r('sys.symbol.plus'))
        .fontSize(20)
        .fontColor([Color.White])
    }
    .width(46)
    .height(31)
    .borderRadius(8)
    .linearGradient({ angle: 90, colors: [[DY_LIKE_RED, 0.0], ['#FB6E52', 1.0]] })
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .margin({ left: 6, right: 6 })
  }

  @Builder
  bottomTabBar() {
    Row() {
      this.feedTabLabel('首页', true)
      this.feedTabLabel('推荐', false)
      this.postButton()
      this.feedTabLabel('消息', false)
      this.feedTabLabel('我', false)
    }
    .width('100%')
    .height(DY_TAB_BAR_HEIGHT)
    .backgroundColor(DY_PAGE_BG)
    .border({ width: { top: 0.5 }, color: '#1F1F26' })
    .alignItems(VerticalAlign.Center)
  }

  build() {
    NavDestination() {
      Column() {
        Stack({ alignContent: Alignment.BottomStart }) {
          this.videoPlaceholder()
          this.authorBlock()
          this.actionColumn()
          this.progressBar()
          this.durationChip()
        }
        .width('100%')
        .layoutWeight(1)

        this.bottomTabBar()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(DY_PAGE_BG)
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
