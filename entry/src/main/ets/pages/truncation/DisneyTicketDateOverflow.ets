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
 * 反例：截断 / 迪士尼门票订单日期条溢出（文字换行 + 价格被裁 + 右侧出屏）
 *
 * 复刻对象：上海迪士尼「订单填写」页：白色说明卡（门票全称）、
 *   「选择日期」标题 + 浅蓝胶囊「请先选择日期」、横向日期条（13 个浅色圆角日期格，
 *   每格自上而下是星期 / 日期 / 橙色价格），日期条右侧是蓝色「更多日期 ›」；
 *   底部「¥--」+ 灰字「请选择使用日期」、右侧橙色「去支付」按钮，页面底部是手势条。
 *
 * 设计基准：参考截图 3184×2232px（密度 2.75，vp = px / 2.75，即 1157.8×811.6vp）量出的设计值：
 *   状态栏 + 标题行 83.6vp（标题行 52vp、标题 26vp、返回 40vp）；
 *   卡片左右留白 16.7vp、上距 19vp、圆角 9vp；
 *   卡内门票名左起 70vp、上内距 44vp、字号 48vp、行高 60vp；分隔线在卡内 150vp 处；
 *   「选择日期」左起 51vp、字号 55vp、行高 66vp，与分隔线间距 39vp；
 *   浅蓝胶囊高 58vp、左右内距 32vp、字号 39vp，与标题间距 20vp；
 *   日期格宽 62.5vp、高 193.5vp、格间距 6.5vp、圆角 7vp，与标题行间距 57vp；
 *   格内星期 38vp / 行高 44vp、日期 40vp / 行高 42vp、橙价 34vp / 行高 40vp；
 *   「更多日期 ›」字号 40vp、行高 46vp、与日期条间距 18vp；
 *   底部操作条高 96vp，「¥--」28vp、「请选择使用日期」14vp、去支付 100.4×48.7vp、字号 20vp。
 *   页面按 1157.8vp 宽 1:1 复刻，窗口更宽时内容列居中，更窄时卡片与文字整体缩小。
 *
 * 三态实测（按本页布局推算）：
 *   单屏态        459.6×672vp   —— 日期条只露出前 6 格，第 7 格起整块落在窗口外；
 *   双屏态竖屏    664.7×939.6vp —— 日期条露出前 9 格，第 10 格起被窗口右边切掉；
 *   双屏态横屏    939.6×664.7vp —— 第 13 格右侧被窗口右边切掉，「更多日期 ›」整块在窗口外。
 *
 * 问题表现：
 *   日期格里的字号远大于格宽，日期「10-17」被折成「10 / -1 / 7」三行竖着堆下来；
 *   格高固定为 193.5vp，最下面的橙价只露出上半截，下半截被格子底边切掉；
 *   日期条整体比卡片宽，末尾几个日期格和「更多日期 ›」越过卡片右沿，直接被窗口右边切掉。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 参考截图宽度：3184px / 2.75 = 1157.8vp，页面按它 1:1 复刻 */
const DTD_REFERENCE_WIDTH: number = 1157.8;

/** 状态栏 / 底部手势区兜底高度（vp），拿不到避让区时使用 */
const DTD_STATUS_BAR_FALLBACK: number = 32;
const DTD_BOTTOM_INSET_FALLBACK: number = 10;

/** 页面底色 / 文字色 */
const DTD_PAGE_BG: string = '#EBEEF7';
const DTD_TEXT_MAIN: string = '#111111';
const DTD_DIVIDER: string = '#EBEBEB';
const DTD_CELL_BG: string = '#F6F7FB';
const DTD_PRICE_ORANGE: string = '#FF4E00';
const DTD_LINK_BLUE: string = '#0078E0';
const DTD_PILL_BG: string = '#EAF2FE';
const DTD_PILL_TEXT: string = '#0D62D0';
const DTD_PAY_ORANGE: string = '#FE9005';
const DTD_TOTAL_ORANGE: string = '#C1440E';
const DTD_HINT_TEXT: string = '#1A1A1A';

/** 标题栏：标题行 52vp、标题 26vp、返回 40vp、左内距 14vp */
const DTD_TITLE_ROW_HEIGHT: number = 52;
const DTD_TITLE_FONT: number = 26;
const DTD_BACK_FONT: number = 40;
const DTD_BACK_INSET: number = 14;

/** 卡片：宽 1123.6vp、左右留白 16.7vp、上距 19vp、圆角 9vp、底空 68vp */
const DTD_CARD_WIDTH: number = 1123.6;
const DTD_CARD_INSET: number = 16.7;
const DTD_CARD_TOP_GAP: number = 19;
const DTD_CARD_RADIUS: number = 9;
const DTD_CARD_BOTTOM: number = 68;

/** 门票名：左起 70vp、上内距 44vp、字号 48vp、行高 60vp、右侧留 16vp */
const DTD_NAME_LEFT: number = 70;
const DTD_NAME_RIGHT: number = 16;
const DTD_NAME_TOP: number = 44;
const DTD_NAME_FONT: number = 48;
const DTD_NAME_LINE: number = 60;

/** 门票名到分隔线 46vp（分隔线落在卡内 150vp） */
const DTD_DIVIDER_GAP: number = 46;

/** 选择日期：左起 51vp、字号 55vp、行高 66vp、与分隔线间距 39vp */
const DTD_SECTION_LEFT: number = 51;
const DTD_SECTION_FONT: number = 55;
const DTD_SECTION_LINE: number = 66;
const DTD_SECTION_GAP: number = 39;

/** 浅蓝胶囊：高 58vp、左右内距 32vp、字号 39vp、与标题间距 20vp */
const DTD_PILL_HEIGHT: number = 58;
const DTD_PILL_PAD: number = 32;
const DTD_PILL_FONT: number = 39;
const DTD_PILL_GAP: number = 20;

/** 日期格：宽 62.5vp、高 193.5vp、格间距 6.5vp、圆角 7vp、内距 3 / 6vp */
const DTD_CELL_WIDTH: number = 62.5;
const DTD_CELL_HEIGHT: number = 193.5;
const DTD_CELL_GAP: number = 6.5;
const DTD_CELL_RADIUS: number = 7;
const DTD_CELL_PAD_X: number = 3;
const DTD_CELL_PAD_TOP: number = 6;

/** 格内文字：星期 38 / 44vp，日期 40 / 42vp，橙价 34 / 40vp，日期与橙价间距 2vp */
const DTD_WEEKDAY_FONT: number = 38;
const DTD_WEEKDAY_LINE: number = 44;
const DTD_DAY_FONT: number = 40;
const DTD_DAY_LINE: number = 42;
const DTD_PRICE_FONT: number = 34;
const DTD_PRICE_LINE: number = 40;
const DTD_PRICE_GAP: number = 2;

/** 日期条与「选择日期」行之间 57vp */
const DTD_STRIP_GAP: number = 57;

/** 更多日期：与日期条间距 18vp、字号 40vp、行高 46vp、箭头 46vp、块宽 112vp */
const DTD_MORE_GAP: number = 18;
const DTD_MORE_FONT: number = 40;
const DTD_MORE_LINE: number = 46;
const DTD_MORE_CHEVRON_FONT: number = 46;
const DTD_MORE_WIDTH: number = 112;

/** 日期条总宽：13 格（含格后间距）+ 更多日期块前的余量 + 更多日期块 */
const DTD_STRIP_WIDTH: number =
  DTD_CELL_WIDTH * 13 + DTD_CELL_GAP * 13 + (DTD_MORE_GAP - DTD_CELL_GAP) + DTD_MORE_WIDTH;

/** 底部操作条：高 96vp、左右内距 18.5 / 18vp、上内距 9vp */
const DTD_BOTTOM_BAR_HEIGHT: number = 96;
const DTD_BOTTOM_LEFT: number = 18.5;
const DTD_BOTTOM_RIGHT: number = 18;
const DTD_BOTTOM_TOP: number = 9;
const DTD_BOTTOM_TEXT_TOP: number = 10;

/** 「¥--」28vp、「请选择使用日期」14vp、去支付 100.4×48.7vp、字号 20vp、圆角 9vp */
const DTD_TOTAL_FONT: number = 28;
const DTD_HINT_FONT: number = 14;
const DTD_HINT_GAP: number = 6;
const DTD_PAY_WIDTH: number = 100.4;
const DTD_PAY_HEIGHT: number = 48.7;
const DTD_PAY_RADIUS: number = 9;
const DTD_PAY_FONT: number = 20;

interface DtdDateCell {
  dateKey: string;
  weekday: string;
  dayText: string;
  dayPrice: string;
}

/** 截图里的日期条：10-17 起连续 13 天，价格从截图逐个读出（¥0 / ¥1 / ¥0 / ¥7 …） */
const DTD_DATE_CELLS: DtdDateCell[] = [
  { dateKey: '2026-10-17', weekday: '天', dayText: '10-17', dayPrice: '¥0' },
  { dateKey: '2026-10-18', weekday: '一', dayText: '10-18', dayPrice: '¥1' },
  { dateKey: '2026-10-19', weekday: '二', dayText: '10-19', dayPrice: '¥0' },
  { dateKey: '2026-10-20', weekday: '三', dayText: '10-20', dayPrice: '¥7' },
  { dateKey: '2026-10-21', weekday: '四', dayText: '10-21', dayPrice: '¥1' },
  { dateKey: '2026-10-22', weekday: '五', dayText: '10-22', dayPrice: '¥1' },
  { dateKey: '2026-10-23', weekday: '六', dayText: '10-23', dayPrice: '¥7' },
  { dateKey: '2026-10-24', weekday: '日', dayText: '10-24', dayPrice: '¥8' },
  { dateKey: '2026-10-25', weekday: '一', dayText: '10-25', dayPrice: '¥1' },
  { dateKey: '2026-10-26', weekday: '二', dayText: '10-26', dayPrice: '¥9' },
  { dateKey: '2026-10-27', weekday: '三', dayText: '10-27', dayPrice: '¥7' },
  { dateKey: '2026-10-28', weekday: '四', dayText: '10-28', dayPrice: '¥7' },
  { dateKey: '2026-10-29', weekday: '五', dayText: '10-29', dayPrice: '¥7' }
];

@Component
export struct DisneyTicketDateOverflowPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = 1157.8;
  @State winHeightVp: number = 811.6;
  /** 沉浸式下的状态栏 / 底部手势区高度（vp） */
  @State statusBarHeightVp: number = DTD_STATUS_BAR_FALLBACK;
  @State bottomInsetVp: number = DTD_BOTTOM_INSET_FALLBACK;

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
      this.windowToken = WindowModeController.acquire(win, '#000000');
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  /** 内容列宽度：参考设计宽 1157.8vp，窗口更宽时保持原宽并居中，更窄时整体缩小 */
  private pageWidth(): number {
    return Math.min(this.winWidthVp, DTD_REFERENCE_WIDTH);
  }

  /** 把 1157.8vp 参考宽下的设计值换算到当前内容列宽度 */
  private s(baseVp: number): number {
    return baseVp * this.pageWidth() / DTD_REFERENCE_WIDTH;
  }

  @Builder
  titleBar() {
    Stack({ alignContent: Alignment.Center }) {
      Text('订单填写')
        .fontSize(this.s(DTD_TITLE_FONT))
        .fontWeight(FontWeight.Medium)
        .fontColor(DTD_TEXT_MAIN)

      Row() {
        Text('‹')
          .fontSize(this.s(DTD_BACK_FONT))
          .fontColor(DTD_TEXT_MAIN)
      }
      .width('100%')
      .padding({ left: this.s(DTD_BACK_INSET) })
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        this.pageStack.pop();
      })
    }
    .width('100%')
    .height(this.statusBarHeightVp + this.s(DTD_TITLE_ROW_HEIGHT))
    .padding({ top: this.statusBarHeightVp })
    .backgroundColor(Color.White)
  }

  @Builder
  dateCell(cell: DtdDateCell) {
    Column() {
      Text(cell.weekday)
        .fontSize(DTD_WEEKDAY_FONT)
        .fontColor(DTD_TEXT_MAIN)
        .lineHeight(DTD_WEEKDAY_LINE)
        .width('100%')
        .textAlign(TextAlign.Center)

      Text(cell.dayText)
        .fontSize(DTD_DAY_FONT)
        .fontColor(DTD_TEXT_MAIN)
        .lineHeight(DTD_DAY_LINE)
        .width('100%')
        .textAlign(TextAlign.Center)
        .wordBreak(WordBreak.BREAK_ALL)

      Text(cell.dayPrice)
        .fontSize(DTD_PRICE_FONT)
        .fontColor(DTD_PRICE_ORANGE)
        .lineHeight(DTD_PRICE_LINE)
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ top: DTD_PRICE_GAP })
    }
    .width(DTD_CELL_WIDTH)
    .height(DTD_CELL_HEIGHT)
    .padding({ left: DTD_CELL_PAD_X, right: DTD_CELL_PAD_X, top: DTD_CELL_PAD_TOP })
    .backgroundColor(DTD_CELL_BG)
    .borderRadius(DTD_CELL_RADIUS)
    .clip(true)
    .alignItems(HorizontalAlign.Center)
    .margin({ right: DTD_CELL_GAP })
  }

  @Builder
  moreDatesBlock() {
    Row() {
      Column() {
        Text('更多')
          .fontSize(DTD_MORE_FONT)
          .fontColor(DTD_LINK_BLUE)
          .lineHeight(DTD_MORE_LINE)

        Text('日期')
          .fontSize(DTD_MORE_FONT)
          .fontColor(DTD_LINK_BLUE)
          .lineHeight(DTD_MORE_LINE)
      }
      .alignItems(HorizontalAlign.Center)

      Text('›')
        .fontSize(DTD_MORE_CHEVRON_FONT)
        .fontColor(DTD_LINK_BLUE)
        .margin({ left: DTD_CELL_GAP })
    }
    .width(DTD_MORE_WIDTH)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .margin({ left: DTD_MORE_GAP - DTD_CELL_GAP })
  }

  @Builder
  dateStrip() {
    Row() {
      ForEach(DTD_DATE_CELLS, (cell: DtdDateCell) => {
        this.dateCell(cell)
      }, (cell: DtdDateCell) => cell.dateKey)

      this.moreDatesBlock()
    }
    .width(DTD_STRIP_WIDTH)
    .height(DTD_CELL_HEIGHT)
    .alignItems(VerticalAlign.Center)
    .margin({ left: this.s(DTD_SECTION_LEFT), top: this.s(DTD_STRIP_GAP) })
  }

  @Builder
  ticketCard() {
    Column() {
      Text('上海迪士尼度假区迪士尼乐园1日门票')
        .fontSize(this.s(DTD_NAME_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(DTD_TEXT_MAIN)
        .lineHeight(this.s(DTD_NAME_LINE))
        .margin({ left: this.s(DTD_NAME_LEFT), right: this.s(DTD_NAME_RIGHT), top: this.s(DTD_NAME_TOP) })

      Row()
        .width('100%')
        .height(this.s(1))
        .backgroundColor(DTD_DIVIDER)
        .margin({ top: this.s(DTD_DIVIDER_GAP) })

      Row() {
        Text('选择日期')
          .fontSize(this.s(DTD_SECTION_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(DTD_TEXT_MAIN)
          .lineHeight(this.s(DTD_SECTION_LINE))

        Row() {
          Text('请先选择日期')
            .fontSize(this.s(DTD_PILL_FONT))
            .fontColor(DTD_PILL_TEXT)
            .lineHeight(this.s(DTD_PILL_FONT + 8))
        }
        .height(this.s(DTD_PILL_HEIGHT))
        .padding({ left: this.s(DTD_PILL_PAD), right: this.s(DTD_PILL_PAD) })
        .backgroundColor(DTD_PILL_BG)
        .borderRadius(this.s(DTD_PILL_HEIGHT / 2))
        .alignItems(VerticalAlign.Center)
        .margin({ left: this.s(DTD_PILL_GAP) })
      }
      .alignItems(VerticalAlign.Center)
      .margin({ left: this.s(DTD_SECTION_LEFT), top: this.s(DTD_SECTION_GAP) })

      this.dateStrip()
    }
    .width(this.s(DTD_CARD_WIDTH))
    .padding({ bottom: this.s(DTD_CARD_BOTTOM) })
    .backgroundColor(Color.White)
    .borderRadius(this.s(DTD_CARD_RADIUS))
    .alignItems(HorizontalAlign.Start)
    .clip(false)
  }

  @Builder
  bottomBar() {
    Row() {
      Column() {
        Text('¥--')
          .fontSize(this.s(DTD_TOTAL_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(DTD_TOTAL_ORANGE)
          .lineHeight(this.s(DTD_TOTAL_FONT + 8))

        Text('请选择使用日期')
          .fontSize(this.s(DTD_HINT_FONT))
          .fontColor(DTD_HINT_TEXT)
          .lineHeight(this.s(DTD_HINT_FONT + 8))
          .margin({ top: this.s(DTD_HINT_GAP) })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ top: this.s(DTD_BOTTOM_TEXT_TOP) })

      Blank()

      Text('去支付')
        .fontSize(this.s(DTD_PAY_FONT))
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .width(this.s(DTD_PAY_WIDTH))
        .height(this.s(DTD_PAY_HEIGHT))
        .backgroundColor(DTD_PAY_ORANGE)
        .borderRadius(this.s(DTD_PAY_RADIUS))
    }
    .width('100%')
    .height(this.s(DTD_BOTTOM_BAR_HEIGHT) + this.bottomInsetVp)
    .padding({ left: this.s(DTD_BOTTOM_LEFT), right: this.s(DTD_BOTTOM_RIGHT), top: this.s(DTD_BOTTOM_TOP) })
    .alignItems(VerticalAlign.Top)
    .backgroundColor(Color.White)
  }

  build() {
    NavDestination() {
      Column() {
        this.titleBar()

        Scroll() {
          Column() {
            this.ticketCard()
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .padding({ top: this.s(DTD_CARD_TOP_GAP), bottom: this.s(DTD_CARD_INSET) })
        }
        .width('100%')
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)

        this.bottomBar()
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
      .backgroundColor(DTD_PAGE_BG)
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
