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
 * 反例：截断 / 小红书笔记标签竖排（文字折行）
 *
 * 复刻对象：小红书「笔记详情」页 —— 白底页面、返回 + 「笔记」 + 分享的导航条、
 *   整幅渐变图片占位（暖色晚霞）、两行加粗标题「周末带娃去山里露营，人均不到300块！」、
 *   编辑时间、话题标签区（两列固定宽度的标签柱：#户外露营 / #周末去哪儿 / #户外露营好物推荐 等）、
 *   作者行（渐变头像 + 「山野拾光」 + 关注按钮 + 点赞 / 收藏 / 评论图标）、
 *   评论区（全部评论 (128) + 3 条评论）、底部「说点什么」输入条。
 *
 * 设计基准（vp，按单屏态 459.6vp 宽绘制）：图片占位高 310vp；标题 17vp 字两行；
 *   标签字号 11.5vp；两列标签柱宽度为设计稿照抄的定值：左列 56vp、右列 100vp，
 *   每枚标签高 22vp、间距 6vp，整块标签区定高 78vp；作者行高 64vp；输入条高 46vp。
 *
 * 三态实测：
 *   单屏态        459.6vp 宽 —— sceneScale 1.00，标签在定宽列里单行横排，两列整齐；
 *   双屏态竖屏    664.7vp 宽 —— sceneScale 1.45，标签字放大到 16.6vp，右列长标签开始
 *                              折成 2 行，折行文字压到下一枚标签上；
 *   双屏态横屏    939.6vp 宽 —— sceneScale 2.04，标签字放大到 23.5vp，每行只装得下 2 个字，
 *                              标签逐字竖排成 2~3 行，整块标签区被竖排文字撑爆。
 *
 * 问题表现：
 *   标签列宽度（56/100vp）与标签行高（22vp）、整块高度（78vp）都是设计稿定值，不随窗口放大，
 *   而标签字号按 sceneScale 放大 —— 宽窗口下标签文本放不进定宽列，被逐字折行竖排；
 *   折行后的文字高度远超 22vp 的行高，竖排文字压到下一枚标签和标签区下方的作者行上，
 *   两列标签错位重叠，「#户外露营好物推荐」完全看不出是一个话题标签。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 单屏态折叠屏基准宽度（vp），sceneScale 以它为 1.0 */
const XHS_NOTE_BASE_WIDTH: number = 459.6;

/** 状态栏 / 底部手势区兜底高度（vp） */
const XHS_STATUS_BAR_FALLBACK: number = 34;
const XHS_BOTTOM_INSET_FALLBACK: number = 8;

/** 标签区：两列定宽（设计稿照抄的固定值，不随窗口放大 —— 反例根源） */
const XHS_TAG_COL_NARROW: number = 56;
const XHS_TAG_COL_WIDE: number = 100;
/** 每枚标签的固定行高、间距与整块定高（vp） */
const XHS_TAG_ROW_HEIGHT: number = 22;
const XHS_TAG_GAP: number = 6;
const XHS_TAG_BLOCK_HEIGHT: number = 78;

const XHS_PAGE_BG: string = '#FFFFFF';
const XHS_TITLE_TEXT: string = '#333333';
const XHS_SUB_TEXT: string = '#999999';
const XHS_TAG_BG: string = '#EDF1F7';
const XHS_TAG_TEXT: string = '#13386C';
const XHS_BRAND_RED: string = '#FF2442';
const XHS_DIVIDER: string = '#F0F0F0';

/** 话题标签：chipKey 用于 ForEach 键，chipText 是标签文案 */
interface XhsNoteTagChip {
  chipKey: string;
  chipText: string;
}

/** 左列（56vp 定宽）：短标签，宽窗口下最先逐字竖排 */
const XHS_TAG_COL_LEFT: XhsNoteTagChip[] = [
  { chipKey: 'xhs-tag-camp', chipText: '#户外露营' },
  { chipKey: 'xhs-tag-kids', chipText: '#亲子游' },
  { chipKey: 'xhs-tag-gear', chipText: '#装备分享' }
];

/** 右列（100vp 定宽）：长标签，双屏竖屏开始折行 */
const XHS_TAG_COL_RIGHT: XhsNoteTagChip[] = [
  { chipKey: 'xhs-tag-weekend', chipText: '#周末去哪儿' },
  { chipKey: 'xhs-tag-camp-goods', chipText: '#户外露营好物推荐' },
  { chipKey: 'xhs-tag-spring', chipText: '#春日出行计划' }
];

/** 评论区数据 */
interface XhsNoteComment {
  commentKey: string;
  commenterName: string;
  commentText: string;
  commentTime: string;
  commentTint: string;
}

const XHS_NOTE_COMMENTS: XhsNoteComment[] = [
  {
    commentKey: 'xhs-cmt-1', commenterName: '一只柚子', commentTime: '02-11',
    commentText: '收藏了！请问帐篷是什么牌子的呀，求链接～',
    commentTint: '#F6A96C'
  },
  {
    commentKey: 'xhs-cmt-2', commenterName: '山野拾光(作者)', commentTime: '02-11',
    commentText: '回复 一只柚子:帐篷是牧高笛的冷山2，链接挂在橱窗啦',
    commentTint: '#7EB8E8'
  },
  {
    commentKey: 'xhs-cmt-3', commenterName: '月亮不睡我不睡', commentTime: '02-10',
    commentText: '人均300太值了，带娃党狂喜，周末就冲！',
    commentTint: '#8CC6A0'
  }
];

@Component
export struct XhsNoteTagWrapPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = XHS_NOTE_BASE_WIDTH;
  @State winHeightVp: number = 672;
  /** 沉浸式下的状态栏 / 底部手势区高度（vp） */
  @State statusBarHeightVp: number = XHS_STATUS_BAR_FALLBACK;
  @State bottomInsetVp: number = XHS_BOTTOM_INSET_FALLBACK;

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
      this.windowToken = WindowModeController.acquire(win, XHS_PAGE_BG);
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  /** 场景缩放比：窗口越宽，页面整体放大越多（单屏态为 1.0） */
  private sceneScale(): number {
    const widthRatio: number = this.winWidthVp / XHS_NOTE_BASE_WIDTH;
    return widthRatio < 1 ? 1 : widthRatio;
  }

  /** 把设计基准值（vp）换算到当前窗口宽度 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  // ------------------------------------------------------------------
  // 导航条与图片区
  // ------------------------------------------------------------------

  @Builder
  noteNavBar() {
    Stack({ alignContent: Alignment.Center }) {
      Text('笔记')
        .fontSize(this.vs(15))
        .fontWeight(FontWeight.Medium)
        .fontColor(XHS_TITLE_TEXT)

      Row() {
        Row() {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(this.vs(20))
            .fontColor(['#333333'])
        }
        .width(this.vs(32))
        .height(this.vs(32))
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.pageStack.pop();
        })

        Blank()

        SymbolGlyph($r('sys.symbol.share'))
          .fontSize(this.vs(18))
          .fontColor(['#333333'])
      }
      .width('100%')
      .padding({ left: this.vs(8), right: this.vs(12) })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(this.vs(44))
    .margin({ top: this.statusBarHeightVp })
    .backgroundColor(XHS_PAGE_BG)
  }

  @Builder
  noteImageBlock() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 160,
          colors: [['#FCE0C3', 0.0], ['#F5AE96', 0.55], ['#DE8FA8', 1.0]]
        })

      Row({ space: this.vs(4) }) {
        SymbolGlyph($r('sys.symbol.camera'))
          .fontSize(this.vs(12))
          .fontColor([Color.White])

        Text('12 张图')
          .fontSize(this.vs(10))
          .fontColor(Color.White)
      }
      .padding({ left: this.vs(8), right: this.vs(8), top: this.vs(3), bottom: this.vs(3) })
      .backgroundColor('#33000000')
      .borderRadius(this.vs(10))
      .margin({ right: this.vs(12), bottom: this.vs(10) })
    }
    .width('100%')
    .height(this.vs(310))
  }

  @Builder
  noteTitleBlock() {
    Column() {
      Text('周末带娃去山里露营，人均不到300块！')
        .fontSize(this.vs(17))
        .fontWeight(FontWeight.Bold)
        .fontColor(XHS_TITLE_TEXT)
        .lineHeight(this.vs(24))
        .maxLines(2)

      Text('编辑于 昨天 12:30 浙江 · 温州')
        .fontSize(this.vs(11))
        .fontColor(XHS_SUB_TEXT)
        .margin({ top: this.vs(6) })
    }
    .width('100%')
    .padding({ left: this.vs(14), right: this.vs(14) })
    .margin({ top: this.vs(12) })
    .alignItems(HorizontalAlign.Start)
  }

  // ------------------------------------------------------------------
  // 标签区：两列定宽标签柱（反例核心）
  // ------------------------------------------------------------------

  @Builder
  tagChipColumn(tagColumnWidth: number, tagChips: XhsNoteTagChip[]) {
    Column({ space: XHS_TAG_GAP }) {
      ForEach(tagChips, (chipItem: XhsNoteTagChip) => {
        Text(chipItem.chipText)
          .fontSize(this.vs(11.5))
          .fontColor(XHS_TAG_TEXT)
          .lineHeight(this.vs(14))
          .maxLines(4)
          .height(XHS_TAG_ROW_HEIGHT)
          .padding({ left: this.vs(6), right: this.vs(4) })
          .backgroundColor(XHS_TAG_BG)
          .borderRadius(this.vs(6))
      }, (chipItem: XhsNoteTagChip) => chipItem.chipKey)
    }
    .width(tagColumnWidth)
    .alignItems(HorizontalAlign.Start)
    .clip(false)
  }

  @Builder
  tagWrapBlock() {
    Row({ space: this.vs(10) }) {
      this.tagChipColumn(XHS_TAG_COL_NARROW, XHS_TAG_COL_LEFT)
      this.tagChipColumn(XHS_TAG_COL_WIDE, XHS_TAG_COL_RIGHT)
    }
    .width('100%')
    .height(XHS_TAG_BLOCK_HEIGHT)
    .padding({ left: this.vs(14), right: this.vs(14) })
    .margin({ top: this.vs(10) })
    .alignItems(VerticalAlign.Top)
    .clip(false)
  }

  // ------------------------------------------------------------------
  // 作者行与评论区
  // ------------------------------------------------------------------

  @Builder
  authorRow() {
    Row({ space: this.vs(8) }) {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width(this.vs(36))
          .height(this.vs(36))
          .borderRadius(this.vs(18))
          .linearGradient({
            angle: 135,
            colors: [['#FFC69E', 0.0], ['#F2826B', 1.0]]
          })

        SymbolGlyph($r('sys.symbol.person_fill'))
          .fontSize(this.vs(18))
          .fontColor([Color.White])
      }
      .width(this.vs(36))
      .height(this.vs(36))

      Column() {
        Text('山野拾光')
          .fontSize(this.vs(13))
          .fontWeight(FontWeight.Medium)
          .fontColor(XHS_TITLE_TEXT)

        Text('温州 · 户外博主')
          .fontSize(this.vs(10))
          .fontColor(XHS_SUB_TEXT)
          .margin({ top: this.vs(2) })
      }
      .alignItems(HorizontalAlign.Start)

      Text('关注')
        .fontSize(this.vs(12))
        .fontColor(Color.White)
        .width(this.vs(58))
        .height(this.vs(26))
        .textAlign(TextAlign.Center)
        .backgroundColor(XHS_BRAND_RED)
        .borderRadius(this.vs(13))

      Blank()

      Row({ space: this.vs(12) }) {
        Column() {
          SymbolGlyph($r('sys.symbol.heart_fill'))
            .fontSize(this.vs(18))
            .fontColor([XHS_BRAND_RED])

          Text('1.2万')
            .fontSize(this.vs(9))
            .fontColor(XHS_SUB_TEXT)
            .margin({ top: this.vs(2) })
        }
        .alignItems(HorizontalAlign.Center)

        Column() {
          SymbolGlyph($r('sys.symbol.star'))
            .fontSize(this.vs(18))
            .fontColor(['#666666'])

          Text('3562')
            .fontSize(this.vs(9))
            .fontColor(XHS_SUB_TEXT)
            .margin({ top: this.vs(2) })
        }
        .alignItems(HorizontalAlign.Center)

        Column() {
          SymbolGlyph($r('sys.symbol.ellipsis_message_fill'))
            .fontSize(this.vs(18))
            .fontColor(['#666666'])

          Text('128')
            .fontSize(this.vs(9))
            .fontColor(XHS_SUB_TEXT)
            .margin({ top: this.vs(2) })
        }
        .alignItems(HorizontalAlign.Center)
      }
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .height(this.vs(64))
    .padding({ left: this.vs(14), right: this.vs(14) })
    .margin({ top: this.vs(14) })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  commentRow(commentItem: XhsNoteComment) {
    Row({ space: this.vs(8) }) {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width(this.vs(30))
          .height(this.vs(30))
          .borderRadius(this.vs(15))
          .backgroundColor(commentItem.commentTint)

        SymbolGlyph($r('sys.symbol.person_fill'))
          .fontSize(this.vs(15))
          .fontColor([Color.White])
      }
      .width(this.vs(30))
      .height(this.vs(30))

      Column() {
        Text(commentItem.commenterName)
          .fontSize(this.vs(11))
          .fontColor('#8899A6')

        Text(commentItem.commentText)
          .fontSize(this.vs(12))
          .fontColor(XHS_TITLE_TEXT)
          .lineHeight(this.vs(17))
          .margin({ top: this.vs(3) })
          .maxLines(2)

        Text(commentItem.commentTime + ' · 浙江')
          .fontSize(this.vs(9))
          .fontColor('#BBBBBB')
          .margin({ top: this.vs(4) })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      SymbolGlyph($r('sys.symbol.heart'))
        .fontSize(this.vs(14))
        .fontColor(['#BBBBBB'])
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
    .margin({ top: this.vs(12) })
  }

  @Builder
  commentSection() {
    Column() {
      Text('全部评论 (128)')
        .fontSize(this.vs(13))
        .fontWeight(FontWeight.Medium)
        .fontColor(XHS_TITLE_TEXT)

      ForEach(XHS_NOTE_COMMENTS, (commentItem: XhsNoteComment) => {
        this.commentRow(commentItem)
      }, (commentItem: XhsNoteComment) => commentItem.commentKey)
    }
    .width('100%')
    .padding({ left: this.vs(14), right: this.vs(14), top: this.vs(12), bottom: this.vs(70) })
    .margin({ top: this.vs(10) })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  bottomInputBar() {
    Row({ space: this.vs(12) }) {
      Row({ space: this.vs(6) }) {
        SymbolGlyph($r('sys.symbol.face_smiling'))
          .fontSize(this.vs(16))
          .fontColor(['#999999'])

        Text('说点什么...')
          .fontSize(this.vs(12))
          .fontColor('#BBBBBB')
      }
      .layoutWeight(1)
      .height(this.vs(32))
      .padding({ left: this.vs(12) })
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#F5F5F5')
      .borderRadius(this.vs(16))

      SymbolGlyph($r('sys.symbol.heart_fill'))
        .fontSize(this.vs(20))
        .fontColor([XHS_BRAND_RED])

      SymbolGlyph($r('sys.symbol.star'))
        .fontSize(this.vs(20))
        .fontColor(['#666666'])

      SymbolGlyph($r('sys.symbol.paperplane'))
        .fontSize(this.vs(20))
        .fontColor(['#666666'])
    }
    .width('100%')
    .height(this.vs(46))
    .padding({ left: this.vs(14), right: this.vs(14) })
    .alignItems(VerticalAlign.Center)
    .backgroundColor(XHS_PAGE_BG)
    .border({ width: { top: this.vs(1) }, color: XHS_DIVIDER })
    .position({ x: 0, y: this.winHeightVp - this.vs(46) - this.bottomInsetVp })
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        Scroll() {
          Column() {
            this.noteNavBar()
            this.noteImageBlock()
            this.noteTitleBlock()
            this.tagWrapBlock()
            this.authorRow()
            Divider()
              .strokeWidth(this.vs(1))
              .color(XHS_DIVIDER)
              .margin({ top: this.vs(14), left: this.vs(14), right: this.vs(14) })
            this.commentSection()
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .backgroundColor(XHS_PAGE_BG)
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .align(Alignment.Top)

        this.bottomInputBar()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(XHS_PAGE_BG)
      .clip(true)
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
