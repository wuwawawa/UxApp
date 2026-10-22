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
 * 反例：截断 / 微信转账留言溢出（文字溢出）
 *
 * 复刻对象：微信「转账详情」对话页 —— 浅灰聊天底、导航条（返回 + 微信支付 + 更多）、
 *   「昨天 20:45」时间条、左侧好友头像 + 白色文字气泡（老板，款已转，请查收～）、
 *   右侧橙色渐变转账气泡（转账给个人 + ¥1,280.00 + 长备注留言 + 微信支付 / 已收钱）、
 *   「你的朋友已确认收钱」确认行、今天 09:12 的好友回复气泡、
 *   底部「退还转账 / 查看账单」按钮组。
 *
 * 设计基准（vp，按单屏态 459.6vp 宽绘制）：转账气泡宽为设计稿照抄的定值 240vp（反例根源）、
 *   圆角 8vp、贴屏幕右缘 12vp；气泡内金额 34vp 字、备注 11vp 字，内容行按基准宽度
 *   算出 214vp 宽（12vp 左缘 + 214vp = 226vp < 240vp，单屏态刚好装下）；
 *   头像 36×36vp、文字气泡最大宽 220vp、按钮 110×36vp。
 *
 * 三态实测：
 *   单屏态        459.6vp 宽 —— sceneScale 1.00，金额 ¥1,280.00 与备注都在 240vp 气泡内，完整显示；
 *   双屏态竖屏    664.7vp 宽 —— sceneScale 1.45，备注行放大到约 287vp，冲出气泡右缘约 64vp，
 *                              又顶到贴边的气泡被屏幕右边缘切断，「请查收」三字只看到半截；
 *   双屏态横屏    939.6vp 宽 —— sceneScale 2.04，金额行 34vp 字放大到 69vp、冲出气泡约 131vp，
 *                              金额与留言整段冲出气泡，被屏幕右边缘齐刷刷切断。
 *
 * 问题表现：
 *   转账气泡宽度是设计稿定值 240vp，不随窗口放大；气泡内的金额、备注字号与内容行宽
 *   却按 sceneScale 放大 —— 宽窗口下 ¥1,280.00 与长备注「老板，这是上次合作的货款尾款，请查收」
 *   冲出橙色气泡右缘，气泡又贴着屏幕右缘摆放，溢出文字被屏幕边缘直接切断，
 *   金额尾数和留言结尾都看不全。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 单屏态折叠屏基准宽度（vp），sceneScale 以它为 1.0 */
const WXT_TRANSFER_BASE_WIDTH: number = 459.6;

/** 状态栏 / 底部手势区兜底高度（vp） */
const WXT_STATUS_BAR_FALLBACK: number = 34;
const WXT_BOTTOM_INSET_FALLBACK: number = 8;

/** 转账气泡定宽：设计稿照抄的固定值（vp），不随窗口放大 —— 反例根源 */
const WXT_BUBBLE_FIXED_WIDTH: number = 240;
/** 气泡内容行宽（按基准宽度算出的 214vp 定值，随 sceneScale 放大后冲出气泡） */
const WXT_BUBBLE_ROW_WIDTH: number = 214;

const WXT_CHAT_BG: string = '#EDEDED';
const WXT_NAV_BG: string = '#EDEDED';
const WXT_TEXT_MAIN: string = '#191919';
const WXT_TEXT_SUB: string = '#9B9B9B';
const WXT_LINK_TEXT: string = '#576B95';
const WXT_TEXT_BUBBLE_BG: string = '#FFFFFF';
const WXT_AVATAR_BG: string = '#DFDFDF';
const WXT_TRANSFER_TOP: string = '#FA9D3E';
const WXT_TRANSFER_BOTTOM: string = '#EE7B30';
const WXT_CONFIRM_GREEN: string = '#07C160';

/** 聊天行：rowKind 决定渲染（date / friend-text / transfer / confirm / friend-reply） */
interface WxtChatRow {
  rowKey: string;
  rowKind: string;
  rowText: string;
}

const WXT_CHAT_ROWS: WxtChatRow[] = [
  { rowKey: 'wxt-date-yesterday', rowKind: 'date', rowText: '昨天 20:45' },
  { rowKey: 'wxt-friend-ask', rowKind: 'friend-text', rowText: '老板，款已转，请查收～' },
  { rowKey: 'wxt-transfer-card', rowKind: 'transfer', rowText: '¥1,280.00' },
  { rowKey: 'wxt-confirm-row', rowKind: 'confirm', rowText: '你的朋友已确认收钱' },
  { rowKey: 'wxt-date-today', rowKind: 'date', rowText: '今天 09:12' },
  { rowKey: 'wxt-friend-reply', rowKind: 'friend-reply', rowText: '收到，谢谢老板！' }
];

@Component
export struct WechatTransferNoteOverflowPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = WXT_TRANSFER_BASE_WIDTH;
  @State winHeightVp: number = 672;
  /** 沉浸式下的状态栏 / 底部手势区高度（vp） */
  @State statusBarHeightVp: number = WXT_STATUS_BAR_FALLBACK;
  @State bottomInsetVp: number = WXT_BOTTOM_INSET_FALLBACK;

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
      this.windowToken = WindowModeController.acquire(win, WXT_CHAT_BG);
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  /** 场景缩放比：窗口越宽，页面整体放大越多（单屏态为 1.0） */
  private sceneScale(): number {
    const widthRatio: number = this.winWidthVp / WXT_TRANSFER_BASE_WIDTH;
    return widthRatio < 1 ? 1 : widthRatio;
  }

  /** 把设计基准值（vp）换算到当前窗口宽度 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  // ------------------------------------------------------------------
  // 导航条
  // ------------------------------------------------------------------

  @Builder
  chatNavBar() {
    Stack({ alignContent: Alignment.Center }) {
      Text('微信支付')
        .fontSize(this.vs(15))
        .fontWeight(FontWeight.Medium)
        .fontColor(WXT_TEXT_MAIN)

      Row() {
        Row() {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(this.vs(20))
            .fontColor(['#191919'])
        }
        .width(this.vs(32))
        .height(this.vs(32))
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.pageStack.pop();
        })

        Blank()

        Text('···')
          .fontSize(this.vs(16))
          .fontColor('#191919')
          .width(this.vs(32))
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .padding({ left: this.vs(6), right: this.vs(6) })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(this.vs(44))
    .margin({ top: this.statusBarHeightVp })
    .backgroundColor(WXT_NAV_BG)
  }

  // ------------------------------------------------------------------
  // 聊天行
  // ------------------------------------------------------------------

  @Builder
  friendAvatar() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width(this.vs(36))
        .height(this.vs(36))
        .borderRadius(this.vs(6))
        .backgroundColor(WXT_AVATAR_BG)

      SymbolGlyph($r('sys.symbol.person_fill'))
        .fontSize(this.vs(20))
        .fontColor(['#FFFFFF'])
    }
    .width(this.vs(36))
    .height(this.vs(36))
  }

  @Builder
  dateChip(dateText: string) {
    Row() {
      Text(dateText)
        .fontSize(this.vs(10))
        .fontColor(WXT_TEXT_SUB)
        .padding({ left: this.vs(8), right: this.vs(8), top: this.vs(2), bottom: this.vs(2) })
    }
    .margin({ top: this.vs(14) })
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  friendTextBubble(bubbleText: string) {
    Row({ space: this.vs(8) }) {
      this.friendAvatar()

      Text(bubbleText)
        .fontSize(this.vs(13))
        .fontColor(WXT_TEXT_MAIN)
        .lineHeight(this.vs(18))
        .maxLines(2)
        .constraintSize({ maxWidth: this.vs(220) })
        .padding({ left: this.vs(10), right: this.vs(10), top: this.vs(8), bottom: this.vs(8) })
        .backgroundColor(WXT_TEXT_BUBBLE_BG)
        .borderRadius(this.vs(8))
    }
    .width('100%')
    .padding({ left: this.vs(12), right: this.vs(60) })
    .margin({ top: this.vs(14) })
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  confirmRow(confirmText: string) {
    Row({ space: this.vs(4) }) {
      SymbolGlyph($r('sys.symbol.checkmark_circle'))
        .fontSize(this.vs(12))
        .fontColor([WXT_CONFIRM_GREEN])

      Text(confirmText)
        .fontSize(this.vs(11))
        .fontColor(WXT_TEXT_SUB)
    }
    .margin({ top: this.vs(10) })
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  transferAmountRow() {
    // 金额行：宽 214vp 按 sceneScale 放大，气泡却定宽 240vp —— 冲出气泡右缘（反例核心）
    Text('¥1,280.00')
      .fontSize(this.vs(34))
      .fontWeight(FontWeight.Bold)
      .fontColor(Color.White)
      .lineHeight(this.vs(40))
      .maxLines(1)
      .width(this.vs(WXT_BUBBLE_ROW_WIDTH))
      .textOverflow({ overflow: TextOverflow.Clip })
  }

  @Builder
  transferNoteRow() {
    // 备注留言行：同样按 sceneScale 放大，宽窗口下冲出气泡并被屏幕右缘切断
    Text('老板，这是上次合作的货款尾款，请查收')
      .fontSize(this.vs(11))
      .fontColor('#FFF3E4')
      .lineHeight(this.vs(15))
      .maxLines(1)
      .width(this.vs(WXT_BUBBLE_ROW_WIDTH))
      .textOverflow({ overflow: TextOverflow.Clip })
      .margin({ top: this.vs(4) })
  }

  @Builder
  transferBubble() {
    Column() {
      Row({ space: this.vs(4) }) {
        SymbolGlyph($r('sys.symbol.person_fill'))
          .fontSize(this.vs(11))
          .fontColor([Color.White])

        Text('转账给个人')
          .fontSize(this.vs(11))
          .fontColor(Color.White)
      }
      .width(this.vs(WXT_BUBBLE_ROW_WIDTH))
      .alignItems(VerticalAlign.Center)

      this.transferAmountRow()
      this.transferNoteRow()

      Divider()
        .strokeWidth(this.vs(1))
        .color('#4DFFFFFF')
        .margin({ top: this.vs(10) })

      Row() {
        Text('微信支付')
          .fontSize(this.vs(9))
          .fontColor('#FFE3CB')

        Blank()

        Text('已收钱')
          .fontSize(this.vs(11))
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
      }
      .width('100%')
      .height(this.vs(26))
      .alignItems(VerticalAlign.Center)
    }
    .width(WXT_BUBBLE_FIXED_WIDTH)
    .padding({ left: this.vs(12), top: this.vs(10), bottom: this.vs(6) })
    .linearGradient({
      angle: 180,
      colors: [[WXT_TRANSFER_TOP, 0.0], [WXT_TRANSFER_BOTTOM, 1.0]]
    })
    .borderRadius(this.vs(8))
    .alignItems(HorizontalAlign.Start)
    .clip(false)
  }

  @Builder
  transferBubbleRow() {
    Row() {
      Blank()

      this.transferBubble()
    }
    .width('100%')
    .padding({ right: this.vs(12) })
    .margin({ top: this.vs(14) })
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  chatRow(rowItem: WxtChatRow) {
    Column() {
      if (rowItem.rowKind === 'date') {
        this.dateChip(rowItem.rowText)
      } else if (rowItem.rowKind === 'friend-text') {
        this.friendTextBubble(rowItem.rowText)
      } else if (rowItem.rowKind === 'transfer') {
        this.transferBubbleRow()
      } else if (rowItem.rowKind === 'confirm') {
        this.confirmRow(rowItem.rowText)
      } else {
        this.friendTextBubble(rowItem.rowText)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .clip(false)
  }

  // ------------------------------------------------------------------
  // 底部按钮组
  // ------------------------------------------------------------------

  @Builder
  bottomActionButtons() {
    Row({ space: this.vs(14) }) {
      Row() {
        Text('退还转账')
          .fontSize(this.vs(13))
          .fontColor(WXT_LINK_TEXT)
      }
      .width(this.vs(110))
      .height(this.vs(36))
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .backgroundColor(WXT_TEXT_BUBBLE_BG)
      .borderRadius(this.vs(6))

      Row() {
        Text('查看账单')
          .fontSize(this.vs(13))
          .fontColor(WXT_LINK_TEXT)
      }
      .width(this.vs(110))
      .height(this.vs(36))
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .backgroundColor(WXT_TEXT_BUBBLE_BG)
      .borderRadius(this.vs(6))
    }
    .width('100%')
    .height(this.vs(64))
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .position({ x: 0, y: this.winHeightVp - this.vs(64) - this.bottomInsetVp })
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        Column() {
          this.chatNavBar()

          Scroll() {
            Column() {
              ForEach(WXT_CHAT_ROWS, (rowItem: WxtChatRow) => {
                this.chatRow(rowItem)
              }, (rowItem: WxtChatRow) => rowItem.rowKey)

              Text('转账说明：转账完成后资金将存入零钱余额')
                .fontSize(this.vs(9))
                .fontColor('#BBBBBB')
                .margin({ top: this.vs(20) })
            }
            .width('100%')
            .padding({ bottom: this.vs(90) })
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .align(Alignment.Top)
        }
        .width('100%')
        .height('100%')
        .alignItems(HorizontalAlign.Start)

        this.bottomActionButtons()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(WXT_CHAT_BG)
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
