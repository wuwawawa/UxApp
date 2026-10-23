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
 * 反例：未避让安全区 / 携程我的订单标题压挖孔（挖孔）
 *
 * 复刻对象：携程「我的订单」页 —— 蓝色渐变顶栏（返回箭头 + 居中「我的订单」+ 右侧筛选）、
 *   订单状态页签（全部 / 待付款 / 待出行 / 已完成）、订单卡列表（订单号、酒店名称、
 *   入住日期、房型、金额、状态标签、两个文字操作按钮）、右侧悬浮「在线客服」胶囊。
 *
 * 设计基准：以单屏折叠态窗口宽 459.6vp 为基准（页面所有尺寸按窗口宽度 / 459.6 等比换算）：
 *   顶栏高 44vp、从窗口顶边铺起，标题 16vp 加粗、垂直居中；页签行高 36vp、文字 13vp；
 *   订单卡圆角 12vp、内边距 14vp、订单号 10.5vp、酒店名 15vp、日期 12vp、金额 15vp；
 *   悬浮「在线客服」胶囊 74×30vp、贴窗口右沿 5vp、距窗口底边 58vp、文字 11vp。
 *
 * 挖孔实测（Pura X Max 模拟器，密度 2.75，hidumper DisplayManagerService BoundingRects）：
 *   单屏态        459.6×672vp   —— 挖孔圆 24vp，顶部正中（x 218~242vp，y 9.5~33.5vp）；
 *   双屏态竖屏    664.7×939.6vp —— 挖孔圆 26.2vp，右下角（距右 10.2vp、距底 15.3vp）；
 *   双屏态横屏    939.6×664.7vp —— 挖孔圆 26.2vp，右上角（距右 15.3vp、距顶 10.2vp）。
 *
 * 三态实测：
 *   单屏态        459.6×672vp   —— 顶栏 0~44vp，标题「我的订单」四字落在 x 198~261vp、
 *                                 y 14~28vp，挖孔圆（x 218~242vp、y 9.5~33.5vp）从正中穿过；
 *   双屏态竖屏    664.7×939.6vp —— 标题落到 x 286~379vp、y 19~45vp，悬浮胶囊
 *                                 x 550~658vp、y 812~856vp，右下角挖孔圆
 *                                 （x 628~655vp、y 898~924vp）落在胶囊下方空白处，
 *                                 三者互不相交；
 *   双屏态横屏    939.6×664.7vp —— 标题落到 x 404~535vp、y 26~63vp，悬浮胶囊
 *                                 x 778~929vp、y 485~546vp，挖孔在右上角
 *                                 （y 10.2~36.4vp），均不相交。
 *
 * 问题表现：
 *   单屏态下顶部居中的「我的订单」正对前置摄像头挖孔，中间「的」「订」两字被黑色圆孔
 *   压掉大半，只剩两侧残边；状态栏时间、电量图标同时叠在顶栏两端。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 缩放基准：单屏折叠态窗口宽度（1264px / 2.75） */
const CT_BASE_WIDTH: number = 459.6;

const CT_PAGE_BG: string = '#F4F6FA';
const CT_CARD_BG: string = '#FFFFFF';
const CT_HEAD_START: string = '#2B6CF6';
const CT_HEAD_END: string = '#1A4FD6';
const CT_TEXT_MAIN: string = '#1B1F27';
const CT_TEXT_SUB: string = '#7B8494';
const CT_TEXT_LIGHT: string = '#AAB2BF';
const CT_PRICE: string = '#F25C2A';
const CT_TAG_BG: string = '#EAF1FF';

/** 顶栏：高 44vp、标题 16vp、两端字 13vp */
const CT_HEADER_HEIGHT: number = 44;
const CT_TITLE_FONT: number = 16;
const CT_HEADER_SIDE_FONT: number = 13;

/** 页签行：高 36vp、文字 13vp */
const CT_TAB_ROW_HEIGHT: number = 36;
const CT_TAB_FONT: number = 13;

/** 订单卡：圆角 12vp、内边距 14vp、订单号 10.5vp、酒店名 15vp、日期 12vp、金额 15vp */
const CT_CARD_RADIUS: number = 12;
const CT_CARD_PAD: number = 14;
const CT_ORDER_NO_FONT: number = 10.5;
const CT_HOTEL_FONT: number = 15;
const CT_DATE_FONT: number = 12;
const CT_PRICE_FONT: number = 15;

/** 悬浮客服：胶囊 74×30vp、贴右 5vp、距底 58vp、文字 11vp */
const CT_FLOAT_WIDTH: number = 74;
const CT_FLOAT_HEIGHT: number = 30;
const CT_FLOAT_RIGHT: number = 5;
const CT_FLOAT_BOTTOM: number = 58;
const CT_FLOAT_FONT: number = 11;

/** 页签数据 */
interface CtripOrderTab {
  tabKey: string;
  tabLabel: string;
  tabActive: boolean;
}

const CT_TAB_LIST: CtripOrderTab[] = [
  { tabKey: 'tab-all', tabLabel: '全部', tabActive: true },
  { tabKey: 'tab-unpaid', tabLabel: '待付款', tabActive: false },
  { tabKey: 'tab-upcoming', tabLabel: '待出行', tabActive: false },
  { tabKey: 'tab-done', tabLabel: '已完成', tabActive: false }
];

/** 订单数据 */
interface CtripOrderItem {
  orderKey: string;
  orderNo: string;
  orderHotel: string;
  orderRoom: string;
  orderDate: string;
  orderPrice: string;
  orderStatus: string;
  orderPrimary: string;
  orderSecondary: string;
}

const CT_ORDER_LIST: CtripOrderItem[] = [
  {
    orderKey: 'order-hotel',
    orderNo: '订单号 8127440192837465',
    orderHotel: '杭州西湖柳莺里酒店',
    orderRoom: '湖景大床房 · 含双早',
    orderDate: '10 月 26 日 - 10 月 27 日 · 1 晚',
    orderPrice: '¥1,268',
    orderStatus: '待入住',
    orderPrimary: '在线付尾款',
    orderSecondary: '取消订单'
  },
  {
    orderKey: 'order-flight',
    orderNo: '订单号 8127440111005623',
    orderHotel: '杭州 - 成都 · CA4512',
    orderRoom: '经济舱 · 成人 1 人',
    orderDate: '11 月 02 日 08:15 起飞',
    orderPrice: '¥890',
    orderStatus: '待出行',
    orderPrimary: '选座值机',
    orderSecondary: '改签'
  },
  {
    orderKey: 'order-train',
    orderNo: '订单号 8127440199007711',
    orderHotel: '上海虹桥 - 杭州东 · G7501',
    orderRoom: '二等座 · 07 车 12F',
    orderDate: '10 月 21 日 07:22 出发',
    orderPrice: '¥73',
    orderStatus: '已完成',
    orderPrimary: '再次预订',
    orderSecondary: '开发票'
  }
];

@Component
export struct CtripFloatServiceNotchPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = CT_BASE_WIDTH;
  @State winHeightVp: number = 672;

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
      this.windowToken = WindowModeController.acquire(win, '#FFFFFF');
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  /** 场景缩放比：当前窗口宽 / 单屏折叠态基准宽 */
  private sceneScale(): number {
    return this.winWidthVp / CT_BASE_WIDTH;
  }

  /** 把基准宽下的设计值换算到当前窗口宽度 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  /** 顶栏：返回 + 居中标题 + 筛选 */
  @Builder
  orderHeader() {
    Stack({ alignContent: Alignment.Center }) {
      Text('我的订单')
        .fontSize(this.vs(CT_TITLE_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .maxLines(1)

      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(this.vs(CT_TITLE_FONT + 6))
          .fontColor([Color.White])
          .onClick(() => {
            this.pageStack.pop();
          })

        Blank()

        Text('筛选')
          .fontSize(this.vs(CT_HEADER_SIDE_FONT))
          .fontColor(Color.White)
      }
      .width('100%')
      .height('100%')
      .padding({ left: this.vs(10), right: this.vs(14) })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(this.vs(CT_HEADER_HEIGHT))
  }

  /** 订单状态页签 */
  @Builder
  orderTabs() {
    Row() {
      ForEach(CT_TAB_LIST, (tab: CtripOrderTab) => {
        Column({ space: this.vs(4) }) {
          Text(tab.tabLabel)
            .fontSize(this.vs(CT_TAB_FONT))
            .fontWeight(tab.tabActive ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(tab.tabActive ? CT_TEXT_MAIN : 'rgba(255,255,255,0.86)')

          Row()
            .width(this.vs(16))
            .height(this.vs(2.5))
            .backgroundColor(Color.White)
            .borderRadius(this.vs(1.2))
            .opacity(tab.tabActive ? 1 : 0)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
      }, (tab: CtripOrderTab) => tab.tabKey)
    }
    .width('100%')
    .height(this.vs(CT_TAB_ROW_HEIGHT))
    .alignItems(VerticalAlign.Center)
  }

  /** 订单卡 */
  @Builder
  orderCard(item: CtripOrderItem) {
    Column({ space: this.vs(7) }) {
      Row() {
        Text(item.orderNo)
          .fontSize(this.vs(CT_ORDER_NO_FONT))
          .fontColor(CT_TEXT_LIGHT)

        Blank()

        Text(item.orderStatus)
          .fontSize(this.vs(CT_ORDER_NO_FONT + 0.5))
          .fontColor(CT_HEAD_END)
          .backgroundColor(CT_TAG_BG)
          .borderRadius(this.vs(3))
          .padding({ left: this.vs(6), right: this.vs(6), top: this.vs(2), bottom: this.vs(2) })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Text(item.orderHotel)
        .fontSize(this.vs(CT_HOTEL_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(CT_TEXT_MAIN)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Text(item.orderRoom)
        .fontSize(this.vs(CT_DATE_FONT))
        .fontColor(CT_TEXT_SUB)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Text(item.orderDate)
        .fontSize(this.vs(CT_DATE_FONT))
        .fontColor(CT_TEXT_SUB)

      Row() {
        Text(item.orderPrice)
          .fontSize(this.vs(CT_PRICE_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(CT_PRICE)

        Blank()

        Row() {
          Text(item.orderSecondary)
            .fontSize(this.vs(CT_DATE_FONT - 0.5))
            .fontColor(CT_TEXT_SUB)
        }
        .height(this.vs(24))
        .padding({ left: this.vs(12), right: this.vs(12) })
        .justifyContent(FlexAlign.Center)
        .border({ width: this.vs(0.8), color: '#D8DEE8' })
        .borderRadius(this.vs(12))

        Row() {
          Text(item.orderPrimary)
            .fontSize(this.vs(CT_DATE_FONT - 0.5))
            .fontColor(Color.White)
        }
        .height(this.vs(24))
        .padding({ left: this.vs(14), right: this.vs(14) })
        .justifyContent(FlexAlign.Center)
        .linearGradient({ angle: 90, colors: [[CT_HEAD_START, 0], [CT_HEAD_END, 1]] })
        .borderRadius(this.vs(12))
        .margin({ left: this.vs(8) })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(this.vs(CT_CARD_PAD))
    .backgroundColor(CT_CARD_BG)
    .borderRadius(this.vs(CT_CARD_RADIUS))
    .alignItems(HorizontalAlign.Start)
  }

  /** 右下角悬浮客服胶囊 */
  @Builder
  floatServiceButton() {
    Row({ space: this.vs(5) }) {
      SymbolGlyph($r('sys.symbol.headphones'))
        .fontSize(this.vs(14))
        .fontColor([Color.White])

      Text('在线客服')
        .fontSize(this.vs(CT_FLOAT_FONT))
        .fontColor(Color.White)
    }
    .width(this.vs(CT_FLOAT_WIDTH))
    .height(this.vs(CT_FLOAT_HEIGHT))
    .justifyContent(FlexAlign.Center)
    .linearGradient({ angle: 90, colors: [[CT_HEAD_START, 0], [CT_HEAD_END, 1]] })
    .borderRadius(this.vs(CT_FLOAT_HEIGHT / 2))
    .shadow({ radius: this.vs(6), color: 'rgba(26,79,214,0.35)', offsetY: this.vs(2) })
    .margin({ right: this.vs(CT_FLOAT_RIGHT), bottom: this.vs(CT_FLOAT_BOTTOM) })
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.BottomEnd }) {
        Column() {
          Column() {
            this.orderHeader()
            this.orderTabs()
          }
          .width('100%')
          .linearGradient({ angle: 180, colors: [[CT_HEAD_START, 0], [CT_HEAD_END, 1]] })

          Scroll() {
            Column({ space: this.vs(10) }) {
              ForEach(CT_ORDER_LIST, (item: CtripOrderItem) => {
                this.orderCard(item)
              }, (item: CtripOrderItem) => item.orderKey)
            }
            .width('100%')
            .padding({ left: this.vs(12), right: this.vs(12), top: this.vs(12), bottom: this.vs(24) })
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .align(Alignment.Top)
          .backgroundColor(CT_PAGE_BG)
        }
        .width('100%')
        .height('100%')

        this.floatServiceButton()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(CT_PAGE_BG)
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
