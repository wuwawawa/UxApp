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
 * 反例：未避让安全区 / 银行转账按钮压导航条（导航条）
 *
 * 复刻银行 App 转账页：蓝色头部（返回、「转账」标题、客服图标），转账金额卡
 * （标签、¥8,600.00 大字、可用余额与大写金额），收款信息卡（收款户名 / 收款卡号 /
 * 开户行三行），转账方式卡（实时到账 / 付款账户 / 手续费），底部提示文案与
 * 固定在屏幕底边的蓝色「确认转账」大按钮。
 *
 * 设计基准：单屏态 459.6×672vp（1264×1848px，密度 2.75），vp = px / 2.75。
 *   头部：顶部 40vp 固定留白（不缩放，保证标题永不进状态栏）+ 标题行 44vp
 *         （标题 18vp、返回 / 客服图标 22vp），头部内容只向下放大；
 *   金额卡：标签 13vp、金额行 46vp（¥ 20vp、数字 38vp 加粗）、
 *           余额行 30vp、卡高约 150vp；
 *   信息卡 / 方式卡：行高 46vp（标签 13vp 灰、取值 14.5vp、行首图标 17vp）、
 *           行间 0.5vp 分隔线、圆角 10vp；
 *   底部按钮带：高 84vp 固定（不随窗口宽度变化），按钮顶对齐：
 *           按钮高 48vp（设计值）、左右留白 14vp、圆角 8vp、文字 17vp，
 *           按 sceneScale = 窗口宽 / 459.6 等比放大——
 *           按钮顶边钉在 窗口高-84vp，放大后向下伸出屏幕底边。
 *
 * 三态实测（同一套设计值；系统导航条（小白条）占屏幕底部约 34vp）：
 *   单屏态      459.6×672vp   —— ×1.000：按钮 y (H-84)～(H-36)，下沿刚好在导航条上方
 *   双屏态竖屏  664.7×939.6vp —— ×1.446：按钮高 69.4vp，y (H-84)～(H-14.6)，
 *                                下部 19.4vp 压进导航条
 *   双屏态横屏  939.6×664.7vp —— ×2.044：按钮高 98.1vp，y (H-84)～(H+14.1)，
 *                                伸出屏幕底 14.1vp，加上导航条 34vp，
 *                                「确认转账」下半截沉到导航条下方被小白条挡住
 *
 * 问题表现（双屏态）：
 *   底部按钮不避让导航条：按钮顶边钉死在窗口底上方 84vp 处，窗口变宽后按钮等比放大
 *   只向下生长，双屏竖屏起下半部被导航条小白条压住，横屏时近一半按钮沉到屏幕外，
 *   「确认转账」几乎点不到。单屏态下按钮完整落在导航条上方。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 单屏态窗口宽度（1264px / 密度 2.75），整页横向尺寸的基准 */
const BT_BASE_WIDTH: number = 459.6;

/** 配色 */
const BT_PAGE_BG: string = '#F3F5F9';
const BT_BRAND_BLUE: string = '#2E6BE6';
const BT_CARD_WHITE: string = '#FFFFFF';
const BT_TEXT: string = '#1A1A1A';
const BT_LABEL_GRAY: string = '#8C919C';
const BT_NOTE_GRAY: string = '#B3B9C4';
const BT_HAIRLINE: string = '#EEF0F4';

/** 头部：固定顶部留白 + 标题行（只向下放大，顶部永不进状态栏） */
const BT_TOP_SPACE: number = 40;
const BT_HEADER_ROW: number = 44;
const BT_HEADER_FONT: number = 18;
const BT_HEADER_ICON: number = 22;

/** 卡片：左右留白、间距、圆角、行高 */
const BT_CARD_SIDE: number = 12.7;
const BT_CARD_GAP: number = 11;
const BT_CARD_RADIUS: number = 10;
const BT_FIELD_ROW: number = 46;

/** 底部按钮带：高度固定，按钮顶对齐、按窗口宽度等比放大后向下伸出屏幕底 */
const BT_BOTTOM_BAND: number = 84;
const BT_BUTTON_HEIGHT: number = 48;
const BT_BUTTON_SIDE: number = 14;
const BT_BUTTON_FONT: number = 17;

/** 信息卡 / 方式卡的一行 */
interface BankTransferFieldRow {
  rowKey: string;
  rowLabel: string;
  rowValue: string;
  /** 行首小图标（没有则留空） */
  rowSymbol: Resource | undefined;
  /** 取值是否高亮红字 */
  rowHilite: boolean;
}

@Component
export struct BankTransferNavBarPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽度（vp），随折叠 / 旋转实时更新；整页缩放比由它算出 */
  @State winWidthVp: number = BT_BASE_WIDTH;

  /** 窗口高度（vp） */
  @State winHeightVp: number = 672;

  private contentScroller: Scroller = new Scroller();
  private pageActive: boolean = false;
  private windowToken: number = 0;

  private payeeRows: BankTransferFieldRow[] = [];
  private methodRows: BankTransferFieldRow[] = [];

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
    this.payeeRows = [
      {
        rowKey: 'bt-payee-name',
        rowLabel: '收款户名',
        rowValue: '王建国',
        rowSymbol: undefined,
        rowHilite: false
      },
      {
        rowKey: 'bt-payee-card',
        rowLabel: '收款卡号',
        rowValue: '6222 0217 **** **** 8873',
        rowSymbol: undefined,
        rowHilite: false
      },
      {
        rowKey: 'bt-payee-bank',
        rowLabel: '开户行',
        rowValue: '中国建设银行北京中关村支行',
        rowSymbol: undefined,
        rowHilite: false
      }
    ];

    this.methodRows = [
      {
        rowKey: 'bt-method-realtime',
        rowLabel: '转账方式',
        rowValue: '实时到账',
        rowSymbol: $r('sys.symbol.bolt'),
        rowHilite: true
      },
      {
        rowKey: 'bt-method-account',
        rowLabel: '付款账户',
        rowValue: '储蓄卡 · 尾号8873',
        rowSymbol: $r('sys.symbol.creditcard'),
        rowHilite: false
      },
      {
        rowKey: 'bt-method-fee',
        rowLabel: '手续费',
        rowValue: '免费',
        rowSymbol: $r('sys.symbol.ticket_fill'),
        rowHilite: false
      }
    ];
  }

  /** 整页缩放比：窗口宽度 / 单屏态宽度（459.6vp） */
  private sceneScale(): number {
    if (this.winWidthVp <= 0) {
      return 1;
    }
    return this.winWidthVp / BT_BASE_WIDTH;
  }

  /** 把按单屏态量出的设计值换算到当前窗口 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  /** 底部按钮宽度：窗口宽减去左右留白（跟随窗口放大） */
  private buttonWidthVp(): number {
    return Math.max(this.winWidthVp - this.vs(BT_BUTTON_SIDE * 2), 0);
  }

  // ------------------------------------------------------------------
  // 蓝色头部：返回 + 转账 + 客服（顶部固定留白，只向下放大）
  // ------------------------------------------------------------------

  @Builder
  headerRow() {
    Stack({ alignContent: Alignment.Center }) {
      Text('转账')
        .fontSize(this.vs(BT_HEADER_FONT))
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)

      Row() {
        Row() {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(this.vs(BT_HEADER_ICON))
            .fontColor([Color.White])
        }
        .width(this.vs(BT_HEADER_ROW))
        .height(this.vs(BT_HEADER_ROW))
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .onClick(() => {
          this.pageStack.pop();
        })

        Blank()

        Row() {
          SymbolGlyph($r('sys.symbol.headphones'))
            .fontSize(this.vs(BT_HEADER_ICON))
            .fontColor([Color.White])
        }
        .width(this.vs(BT_HEADER_ROW))
        .height(this.vs(BT_HEADER_ROW))
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(this.vs(BT_HEADER_ROW))
  }

  // ------------------------------------------------------------------
  // 转账金额卡
  // ------------------------------------------------------------------

  @Builder
  amountCard() {
    Column({ space: this.vs(8) }) {
      Text('转账金额')
        .fontSize(this.vs(13))
        .fontColor(BT_LABEL_GRAY)

      Row({ space: this.vs(3) }) {
        Text('¥')
          .fontSize(this.vs(20))
          .fontWeight(FontWeight.Bold)
          .fontColor(BT_TEXT)
          .margin({ top: this.vs(12) })

        Text('8,600.00')
          .fontSize(this.vs(38))
          .fontWeight(FontWeight.Bold)
          .fontColor(BT_TEXT)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Row() {
        Text('可用余额 62,415.37 元')
          .fontSize(this.vs(12))
          .fontColor(BT_LABEL_GRAY)

        Blank()

        Text('大写：捌仟陆佰元整')
          .fontSize(this.vs(12))
          .fontColor(BT_LABEL_GRAY)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ top: this.vs(2) })
    }
    .width('100%')
    .padding({ left: this.vs(16), right: this.vs(16), top: this.vs(15), bottom: this.vs(15) })
    .backgroundColor(BT_CARD_WHITE)
    .borderRadius(this.vs(BT_CARD_RADIUS))
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: this.vs(BT_CARD_GAP) })
  }

  // ------------------------------------------------------------------
  // 信息卡 / 方式卡：标签 + 取值 + 箭头
  // ------------------------------------------------------------------

  @Builder
  fieldRow(row: BankTransferFieldRow) {
    Row({ space: this.vs(9) }) {
      if (row.rowSymbol !== undefined) {
        SymbolGlyph(row.rowSymbol)
          .fontSize(this.vs(17))
          .fontColor([BT_BRAND_BLUE])
      }

      Text(row.rowLabel)
        .fontSize(this.vs(13))
        .fontColor(BT_LABEL_GRAY)
        .width(this.vs(62))

      Text(row.rowValue)
        .fontSize(this.vs(14.5))
        .fontWeight(FontWeight.Medium)
        .fontColor(row.rowHilite ? '#E2543F' : BT_TEXT)
        .maxLines(1)
        .layoutWeight(1)

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(this.vs(14))
        .fontColor(['#C4C9D2'])
    }
    .width('100%')
    .height(this.vs(BT_FIELD_ROW))
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  fieldCard(rows: BankTransferFieldRow[]) {
    Column() {
      ForEach(rows, (row: BankTransferFieldRow) => {
        this.fieldRow(row)

        if (row.rowKey !== rows[rows.length - 1].rowKey) {
          Row()
            .width('100%')
            .height(0.5)
            .backgroundColor(BT_HAIRLINE)
        }
      }, (row: BankTransferFieldRow) => row.rowKey)
    }
    .width('100%')
    .padding({ left: this.vs(16), right: this.vs(16) })
    .backgroundColor(BT_CARD_WHITE)
    .borderRadius(this.vs(BT_CARD_RADIUS))
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: this.vs(BT_CARD_GAP) })
  }

  // ------------------------------------------------------------------
  // 底部提示与「确认转账」按钮（顶边钉在窗口底上方 84vp，向下放大）
  // ------------------------------------------------------------------

  @Builder
  bottomNote() {
    Text('请仔细核对收款人信息，转账提交后不可撤销')
      .fontSize(this.vs(11))
      .fontColor(BT_NOTE_GRAY)
      .margin({ top: this.vs(4), bottom: this.vs(10) })
  }

  @Builder
  bottomBand() {
    Stack({ alignContent: Alignment.Top }) {
      Row() {
        Text('确认转账')
          .fontSize(this.vs(BT_BUTTON_FONT))
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
      }
      .width(this.buttonWidthVp())
      .height(this.vs(BT_BUTTON_HEIGHT))
      .borderRadius(this.vs(8))
      .backgroundColor(BT_BRAND_BLUE)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(BT_BOTTOM_BAND)
    .padding({ left: this.vs(BT_BUTTON_SIDE), right: this.vs(BT_BUTTON_SIDE) })
    .backgroundColor(BT_CARD_WHITE)
  }

  build() {
    NavDestination() {
      Column() {
        Row()
          .width('100%')
          .height(BT_TOP_SPACE)

        this.headerRow()

        Scroll(this.contentScroller) {
          Column() {
            this.amountCard()

            Column() {
              Text('收款信息')
                .fontSize(this.vs(13))
                .fontColor(BT_TEXT)
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: this.vs(2) })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            this.fieldCard(this.payeeRows)

            this.fieldCard(this.methodRows)

            this.bottomNote()

            Row()
              .height(BT_BOTTOM_BAND)
          }
          .width('100%')
          .padding({ left: this.vs(BT_CARD_SIDE), right: this.vs(BT_CARD_SIDE) })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.None)
        .align(Alignment.Top)

        Row()
          .width('100%')
          .height(0.5)
          .backgroundColor(BT_HAIRLINE)

        this.bottomBand()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(BT_PAGE_BG)
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
