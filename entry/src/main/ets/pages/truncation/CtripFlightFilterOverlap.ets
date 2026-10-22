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
 * 反例：截断 / 携程机票筛选项压行（文字重叠）
 *
 * 反例主题：筛选标签行与「经济舱1.8折」起价行互相压盖。
 *
 * 复刻对象：携程旅行机票列表页 —— 蓝色头部（返回 + 「北京 → 上海 10月23日」
 *   搜索条 + 日历图标）、「单程 / 往返」页签行、白色筛选行（时间▾ / 航空公司▾ /
 *   选中胶囊「经济舱<¥980」）、浅橙低价提醒条（「低价提醒 经济舱1.8折 ¥580起」）、
 *   排序行（时间早-晚 / 价格低-高 / 只看直飞）、3 张航班卡（航司圆标 + 航班号、
 *   起降时刻与机场、历时、红色价格与折扣标签）。
 *
 * 设计基准：以单屏折叠态窗口宽 459.6vp 为基准：
 *   头部搜索条高 34vp、页签行高 40vp；筛选行高写死 32vp（反例根源）；
 *   胶囊文字 14vp、行距内边距上下 4vp、胶囊线高 20vp（基准下胶囊总高约 30vp
 *   刚好塞进 32vp 行）；低价提醒条文字 12vp；排序行高 36vp、排序文字 13vp；
 *   航班卡留白 10vp、圆角 12vp、内边距 12vp、时刻 20vp、机场 11vp、价格 20vp。
 *
 * 三态实测：
 *   单屏态        459.6×672vp   —— 筛选行 32vp、胶囊高约 30vp，刚好互不压盖；
 *   双屏态竖屏    664.7×939.6vp —— 胶囊随窗口放大到约 43.4vp，而筛选行仍是 32vp，
 *                                 胶囊上下各溢出约 5.7vp，压住上方页签行与
 *                                 下方「经济舱1.8折」低价提醒条，文字互相叠字；
 *   双屏态横屏    939.6×664.7vp —— 胶囊放大到约 61.2vp，筛选行仍 32vp，
 *                                 上下各溢出约 14.6vp，「时间」「航空公司」胶囊
 *                                 与「经济舱<¥980」「经济舱1.8折」两行彻底叠在一起。
 *
 * 问题表现：
 *   筛选标签行行高按单屏基准写死 32vp，胶囊里的文字与内边距却按窗口宽度等比放大；
 *   窗口变宽后胶囊比行更高，从行里上下溢出（行未开裁剪），与上方「单程/往返」
 *   页签行和下方「低价提醒 经济舱1.8折 ¥580起」起价行互相压盖，文字叠字难辨。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 缩放基准：单屏折叠态窗口宽度（1264px / 2.75） */
const CTF_BASE_WIDTH: number = 459.6;

/** 状态栏 / 底部手势区兜底高度（vp） */
const CTF_STATUS_BAR_FALLBACK: number = 32;
const CTF_BOTTOM_INSET_FALLBACK: number = 8;

const CTF_PAGE_BG: string = '#F5F6F8';
const CTF_HEADER_START: string = '#1E8DF5';
const CTF_HEADER_END: string = '#0086F6';
const CTF_BLUE: string = '#0086F6';
const CTF_BLUE_LIGHT: string = '#E8F3FF';
const CTF_TEXT_MAIN: string = '#1A1A1A';
const CTF_TEXT_SUB: string = '#8C8C8C';
const CTF_TEXT_LIGHT: string = '#B9C0C9';
const CTF_PRICE_RED: string = '#FF4E3A';
const CTF_PROMO_BG: string = '#FFF4E8';
const CTF_PROMO_TEXT: string = '#C06314';

/** 头部：搜索条高 34vp、搜索文字 14vp、页签行高 40vp、页签文字 15vp、下划线 2.5vp */
const CTF_SEARCH_ROW_HEIGHT: number = 34;
const CTF_SEARCH_FONT: number = 14;
const CTF_TAB_ROW_HEIGHT: number = 40;
const CTF_TAB_FONT: number = 15;
const CTF_TAB_UNDERLINE: number = 2.5;

/** 筛选行：行高写死 32vp（反例根源）、胶囊文字 14vp、线高 20vp、上下内边距 4vp */
const CTF_FILTER_ROW_HEIGHT: number = 32;
const CTF_FILTER_FONT: number = 14;
const CTF_FILTER_LINE_HEIGHT: number = 20;
const CTF_FILTER_PAD_Y: number = 4;
const CTF_FILTER_PAD_X: number = 10;

/** 低价提醒条：文字 12vp、上下内边距 5vp */
const CTF_PROMO_FONT: number = 12;
const CTF_PROMO_PAD_Y: number = 5;

/** 排序行：高 36vp、文字 13vp */
const CTF_SORT_ROW_HEIGHT: number = 36;
const CTF_SORT_FONT: number = 13;

/** 航班卡：留白 10vp、圆角 12vp、内边距 12vp、航司圆标 26vp、时刻 20vp、机场 11vp、价格 20vp */
const CTF_CARD_INSET: number = 10;
const CTF_CARD_RADIUS: number = 12;
const CTF_CARD_PAD: number = 12;
const CTF_AIR_LOGO: number = 26;
const CTF_TIME_FONT: number = 20;
const CTF_AIRPORT_FONT: number = 11;
const CTF_DURATION_FONT: number = 11;
const CTF_PRICE_FONT: number = 20;
const CTF_DISCOUNT_FONT: number = 11;

/** 航班数据 */
interface CtripFlightItem {
  flightKey: string;
  airlineName: string;
  flightNo: string;
  airlineTint: string;
  depTime: string;
  depAirport: string;
  arrTime: string;
  arrAirport: string;
  flightDuration: string;
  flightPrice: string;
  flightDiscount: string;
}

const CTF_FLIGHTS: CtripFlightItem[] = [
  {
    flightKey: 'MU5137',
    airlineName: '中国东航',
    flightNo: 'MU5137',
    airlineTint: '#2B6CB8',
    depTime: '08:30',
    depAirport: '首都机场T2',
    arrTime: '10:55',
    arrAirport: '虹桥机场T2',
    flightDuration: '2h25m',
    flightPrice: '¥580',
    flightDiscount: '经济舱1.8折'
  },
  {
    flightKey: 'CA1501',
    airlineName: '中国国航',
    flightNo: 'CA1501',
    airlineTint: '#D03A2B',
    depTime: '09:00',
    depAirport: '首都机场T3',
    arrTime: '11:25',
    arrAirport: '虹桥机场T2',
    flightDuration: '2h25m',
    flightPrice: '¥760',
    flightDiscount: '经济舱2.3折'
  },
  {
    flightKey: 'MF8556',
    airlineName: '厦门航空',
    flightNo: 'MF8556',
    airlineTint: '#0E7C86',
    depTime: '13:45',
    depAirport: '大兴机场',
    arrTime: '16:10',
    arrAirport: '虹桥机场T2',
    flightDuration: '2h25m',
    flightPrice: '¥690',
    flightDiscount: '经济舱2.1折'
  }
];

@Component
export struct CtripFlightFilterOverlapPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = CTF_BASE_WIDTH;
  @State winHeightVp: number = 672;
  /** 沉浸式下的状态栏 / 底部手势区高度（vp） */
  @State statusBarHeightVp: number = CTF_STATUS_BAR_FALLBACK;
  @State bottomInsetVp: number = CTF_BOTTOM_INSET_FALLBACK;

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
      this.windowToken = WindowModeController.acquire(win, CTF_HEADER_END);
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  /** 场景缩放比：当前窗口宽 / 单屏折叠态基准宽 */
  private sceneScale(): number {
    return this.winWidthVp / CTF_BASE_WIDTH;
  }

  /** 把基准宽下的设计值换算到当前窗口宽度 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  /** 头部：返回 + 搜索条 + 日历 */
  @Builder
  searchRow() {
    Row() {
      SymbolGlyph($r('sys.symbol.chevron_left'))
        .fontSize(this.vs(24))
        .fontColor([Color.White])
        .onClick(() => {
          this.pageStack.pop();
        })

      Row({ space: this.vs(6) }) {
        SymbolGlyph($r('sys.symbol.magnifyingglass'))
          .fontSize(this.vs(14))
          .fontColor(['#7A8CA3'])

        Text('北京 → 上海 · 10月23日')
          .fontSize(this.vs(CTF_SEARCH_FONT))
          .fontColor('#33445C')
      }
      .height(this.vs(CTF_SEARCH_ROW_HEIGHT))
      .padding({ left: this.vs(12), right: this.vs(12) })
      .backgroundColor(Color.White)
      .borderRadius(this.vs(CTF_SEARCH_ROW_HEIGHT / 2))
      .alignItems(VerticalAlign.Center)
      .layoutWeight(1)
      .margin({ left: this.vs(10), right: this.vs(10) })

      SymbolGlyph($r('sys.symbol.calendar'))
        .fontSize(this.vs(22))
        .fontColor([Color.White])
    }
    .width('100%')
    .height(this.vs(44))
    .padding({ left: this.vs(12), right: this.vs(12) })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  tripTab(tabLabel: string, tabActive: boolean) {
    Column() {
      Text(tabLabel)
        .fontSize(this.vs(CTF_TAB_FONT))
        .fontWeight(tabActive ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(tabActive ? Color.White : 'rgba(255,255,255,0.85)')

      Row()
        .width(this.vs(tabActive ? 24 : 0))
        .height(this.vs(CTF_TAB_UNDERLINE))
        .backgroundColor(Color.White)
        .borderRadius(this.vs(CTF_TAB_UNDERLINE / 2))
        .margin({ top: this.vs(4) })
    }
    .alignItems(HorizontalAlign.Center)
    .clip(false)
  }

  /** 页签行：单程 / 往返 */
  @Builder
  tripTabRow() {
    Row({ space: this.vs(36) }) {
      this.tripTab('单程', true)
      this.tripTab('往返', false)
    }
    .width('100%')
    .height(this.vs(CTF_TAB_ROW_HEIGHT))
    .padding({ left: this.vs(16) })
    .alignItems(VerticalAlign.Center)
    .clip(false)
  }

  /** 普通筛选胶囊（带下拉箭头） */
  @Builder
  filterChip(chipLabel: string) {
    Row({ space: this.vs(4) }) {
      Text(chipLabel)
        .fontSize(this.vs(CTF_FILTER_FONT))
        .lineHeight(this.vs(CTF_FILTER_LINE_HEIGHT))
        .fontColor(CTF_TEXT_MAIN)

      Text('⌄')
        .fontSize(this.vs(12))
        .fontColor(CTF_TEXT_SUB)
    }
    .padding({
      left: this.vs(CTF_FILTER_PAD_X),
      right: this.vs(CTF_FILTER_PAD_X),
      top: this.vs(CTF_FILTER_PAD_Y),
      bottom: this.vs(CTF_FILTER_PAD_Y)
    })
    .border({ width: this.vs(1), color: '#DCE0E6' })
    .borderRadius(this.vs(15))
    .alignItems(VerticalAlign.Center)
  }

  /** 选中的舱位胶囊：蓝字蓝框浅蓝底 */
  @Builder
  cabinChip() {
    Row() {
      Text('经济舱<¥980')
        .fontSize(this.vs(CTF_FILTER_FONT))
        .lineHeight(this.vs(CTF_FILTER_LINE_HEIGHT))
        .fontWeight(FontWeight.Medium)
        .fontColor(CTF_BLUE)
    }
    .padding({
      left: this.vs(CTF_FILTER_PAD_X),
      right: this.vs(CTF_FILTER_PAD_X),
      top: this.vs(CTF_FILTER_PAD_Y),
      bottom: this.vs(CTF_FILTER_PAD_Y)
    })
    .backgroundColor(CTF_BLUE_LIGHT)
    .border({ width: this.vs(1), color: CTF_BLUE })
    .borderRadius(this.vs(15))
    .alignItems(VerticalAlign.Center)
  }

  /**
   * 筛选行：行高写死 32vp（反例核心）。
   * 胶囊随窗口放大后比行更高，从行里上下溢出，压住页签行与低价提醒条。
   */
  @Builder
  filterRow() {
    Row({ space: this.vs(10) }) {
      this.filterChip('时间')
      this.filterChip('航空公司')
      this.cabinChip()

      Blank()

      Text('筛选')
        .fontSize(this.vs(CTF_FILTER_FONT))
        .lineHeight(this.vs(CTF_FILTER_LINE_HEIGHT))
        .fontColor(CTF_TEXT_MAIN)
        .padding({
          left: this.vs(CTF_FILTER_PAD_X),
          right: this.vs(CTF_FILTER_PAD_X),
          top: this.vs(CTF_FILTER_PAD_Y),
          bottom: this.vs(CTF_FILTER_PAD_Y)
        })
        .border({ width: this.vs(1), color: '#DCE0E6' })
        .borderRadius(this.vs(15))
    }
    .width('100%')
    .height(CTF_FILTER_ROW_HEIGHT)
    .padding({ left: this.vs(12), right: this.vs(12) })
    .backgroundColor(Color.White)
    .alignItems(VerticalAlign.Center)
    .clip(false)
  }

  /** 低价提醒条：「经济舱1.8折 ¥580起」起价行，被放大后的筛选胶囊压盖 */
  @Builder
  promoStrip() {
    Row({ space: this.vs(6) }) {
      SymbolGlyph($r('sys.symbol.star_circle'))
        .fontSize(this.vs(14))
        .fontColor([CTF_PROMO_TEXT])

      Text('低价提醒 经济舱1.8折 ¥580起，价格随时变动')
        .fontSize(this.vs(CTF_PROMO_FONT))
        .fontColor(CTF_PROMO_TEXT)
        .maxLines(1)

      Blank()

      Text('换低价日历')
        .fontSize(this.vs(CTF_PROMO_FONT))
        .fontColor(CTF_PROMO_TEXT)
    }
    .width('100%')
    .padding({
      left: this.vs(12),
      right: this.vs(12),
      top: this.vs(CTF_PROMO_PAD_Y),
      bottom: this.vs(CTF_PROMO_PAD_Y)
    })
    .backgroundColor(CTF_PROMO_BG)
    .alignItems(VerticalAlign.Center)
    .clip(false)
  }

  @Builder
  sortTab(sortLabel: string, sortActive: boolean) {
    Row({ space: this.vs(3) }) {
      Text(sortLabel)
        .fontSize(this.vs(CTF_SORT_FONT))
        .fontWeight(sortActive ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(sortActive ? CTF_TEXT_MAIN : CTF_TEXT_SUB)
    }
    .alignItems(VerticalAlign.Center)
  }

  /** 排序行 */
  @Builder
  sortRow() {
    Row({ space: this.vs(26) }) {
      this.sortTab('时间早-晚', true)
      this.sortTab('价格低-高', false)
      this.sortTab('只看直飞', false)

      Blank()

      Text('共23个航班')
        .fontSize(this.vs(CTF_AIRPORT_FONT))
        .fontColor(CTF_TEXT_LIGHT)
    }
    .width('100%')
    .height(this.vs(CTF_SORT_ROW_HEIGHT))
    .padding({ left: this.vs(12), right: this.vs(12) })
    .backgroundColor(Color.White)
    .alignItems(VerticalAlign.Center)
    .margin({ top: this.vs(8) })
  }

  /** 航司圆标 */
  @Builder
  airlineLogo(flight: CtripFlightItem) {
    Column() {
      Text(flight.airlineName.substring(2, 3))
        .fontSize(this.vs(13))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
    }
    .width(this.vs(CTF_AIR_LOGO))
    .height(this.vs(CTF_AIR_LOGO))
    .justifyContent(FlexAlign.Center)
    .backgroundColor(flight.airlineTint)
    .borderRadius(this.vs(CTF_AIR_LOGO / 2))
  }

  @Builder
  flightCard(flight: CtripFlightItem) {
    Row() {
      Column() {
        Row({ space: this.vs(6) }) {
          this.airlineLogo(flight)

          Text(flight.airlineName + ' ' + flight.flightNo)
            .fontSize(this.vs(CTF_DURATION_FONT))
            .fontColor(CTF_TEXT_SUB)
        }
        .alignItems(VerticalAlign.Center)

        Row() {
          Column() {
            Text(flight.depTime)
              .fontSize(this.vs(CTF_TIME_FONT))
              .fontWeight(FontWeight.Bold)
              .fontColor(CTF_TEXT_MAIN)

            Text(flight.depAirport)
              .fontSize(this.vs(CTF_AIRPORT_FONT))
              .fontColor(CTF_TEXT_SUB)
              .margin({ top: this.vs(3) })
          }
          .alignItems(HorizontalAlign.Center)

          Column() {
            Text(flight.flightDuration)
              .fontSize(this.vs(CTF_DURATION_FONT))
              .fontColor(CTF_TEXT_LIGHT)

            Row()
              .width(this.vs(24))
              .height(this.vs(1.5))
              .backgroundColor('#D5DBE3')
              .margin({ top: this.vs(4) })

            Text('直飞')
              .fontSize(this.vs(CTF_AIRPORT_FONT))
              .fontColor(CTF_TEXT_LIGHT)
              .margin({ top: this.vs(3) })
          }
          .alignItems(HorizontalAlign.Center)
          .layoutWeight(1)

          Column() {
            Text(flight.arrTime)
              .fontSize(this.vs(CTF_TIME_FONT))
              .fontWeight(FontWeight.Bold)
              .fontColor(CTF_TEXT_MAIN)

            Text(flight.arrAirport)
              .fontSize(this.vs(CTF_AIRPORT_FONT))
              .fontColor(CTF_TEXT_SUB)
              .margin({ top: this.vs(3) })
          }
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .margin({ top: this.vs(12) })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Column() {
        Row({ space: this.vs(2) }) {
          Text('¥')
            .fontSize(this.vs(13))
            .fontColor(CTF_PRICE_RED)
            .margin({ top: this.vs(6) })

          Text(flight.flightPrice.substring(1))
            .fontSize(this.vs(CTF_PRICE_FONT))
            .fontWeight(FontWeight.Bold)
            .fontColor(CTF_PRICE_RED)
        }
        .alignItems(VerticalAlign.Top)

        Text(flight.flightDiscount)
          .fontSize(this.vs(CTF_DISCOUNT_FONT))
          .fontColor(CTF_PRICE_RED)
          .backgroundColor('#FFEDE9')
          .borderRadius(this.vs(3))
          .padding({ left: this.vs(5), right: this.vs(5), top: this.vs(2), bottom: this.vs(2) })
          .margin({ top: this.vs(5) })

        Text('含税价')
          .fontSize(this.vs(CTF_AIRPORT_FONT))
          .fontColor(CTF_TEXT_LIGHT)
          .margin({ top: this.vs(4) })
      }
      .alignItems(HorizontalAlign.End)
      .margin({ left: this.vs(10) })
    }
    .width('100%')
    .padding(this.vs(CTF_CARD_PAD))
    .backgroundColor(Color.White)
    .borderRadius(this.vs(CTF_CARD_RADIUS))
    .margin({ bottom: this.vs(10) })
    .alignItems(VerticalAlign.Top)
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          this.searchRow()
          this.tripTabRow()
        }
        .width('100%')
        .linearGradient({ angle: 180, colors: [[CTF_HEADER_START, 0], [CTF_HEADER_END, 1]] })
        .padding({ top: this.statusBarHeightVp })

        // 筛选行（固定 32vp）紧贴低价提醒条，放大后胶囊压盖两侧
        Column() {
          this.filterRow()
          this.promoStrip()
          this.sortRow()
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        Scroll() {
          Column() {
            ForEach(CTF_FLIGHTS, (flight: CtripFlightItem) => {
              this.flightCard(flight)
            }, (flight: CtripFlightItem) => flight.flightKey)

            Row()
              .width('100%')
              .height(this.vs(16))
          }
          .width('100%')
          .padding({ left: this.vs(CTF_CARD_INSET), right: this.vs(CTF_CARD_INSET), top: this.vs(8) })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .backgroundColor(CTF_PAGE_BG)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(CTF_PAGE_BG)
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
