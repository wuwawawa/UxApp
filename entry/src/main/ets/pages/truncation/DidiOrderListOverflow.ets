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
 * 反例：截断 / 滴滴「我的订单」地址溢出（文字溢出）
 *
 * 复刻对象：滴滴出行「我的订单」页 —— 返回 + 我的订单 + 开发票、全部 / 打车 / 骑行 / 顺风车
 *   标签栏（全部带橙色下划线），下面是一列订单卡：服务名 + 状态胶囊 + 金额 + 箭头、
 *   下单时间、绿 / 橙圆点串起的起终点地址、底部垃圾桶与「再来…」胶囊。
 *
 * 设计基准：参考截图 2048×2232px（密度 2.75，vp = px / 2.75，744.7×811.6vp）量出的设计值：
 *   标题行高 36vp、标题 22vp；标签栏高 33vp、标签 23vp、下划线 2.2vp；
 *   订单卡左右留白 14.5vp、圆角 8.7vp、卡内边距 17.5vp；
 *   服务名 22vp、状态胶囊 12.6vp、「上周末 20:09」17vp、地址 19.6vp；
 *   同页的窄态截图 1008×2232px（366.5vp 宽）用于核对窄窗口下的折行。
 *   内容列最多铺到 744.7vp，更宽的窗口下居中；窗口更窄时整列等比缩小。
 *
 * 三态实测：
 *   单屏态        459.6×672vp   —— 内容列 459.6vp，订单卡 430.6vp，私房菜地址被屏幕右沿切断；
 *   双屏态竖屏    664.7×939.6vp —— 内容列 664.7vp，订单卡 635.7vp，地址文字冲出卡片右沿；
 *   双屏态横屏    939.6×664.7vp —— 内容列 744.7vp 居中，订单卡 715.7vp，右侧露出白底。
 *
 * 问题表现：
 *   订单卡里的地址没有做省略，长地址「海淀区印象晋南私房菜(中关村环保园1号楼)」
 *   一直排到卡片右边之外，被屏幕右沿裁掉半截字；
 *   「再来…」胶囊与垃圾桶挤在卡片底边，胶囊文字同样被压扁。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 参考截图宽度：2048px / 2.75 = 744.7vp */
const DOL_REFERENCE_WIDTH: number = 744.7;

/** 状态栏 / 底部手势区兜底高度（vp） */
const DOL_STATUS_BAR_FALLBACK: number = 32;
const DOL_BOTTOM_INSET_FALLBACK: number = 8;

const DOL_PAGE_BG: string = '#FFFFFF';
const DOL_TEXT_MAIN: string = '#1A1A1A';
const DOL_TEXT_GRAY: string = '#8C8C8C';
const DOL_TAB_ACTIVE: string = '#1A1A1A';
const DOL_UNDERLINE: string = '#FF6A00';
const DOL_PILL_BG: string = '#F2F2F2';
const DOL_GREEN: string = '#10C39A';
const DOL_ORANGE: string = '#FF7A45';
const DOL_BUTTON_BORDER: string = '#F2A37B';
const DOL_BUTTON_TEXT: string = '#F26A3A';

/** 标题行 36vp、标题 22vp、开发票 19vp */
const DOL_TITLE_ROW_HEIGHT: number = 36;
const DOL_TITLE_FONT: number = 22;
const DOL_ACTION_FONT: number = 19;

/** 标签栏：高 33vp、标签 23vp、下划线 2.2vp */
const DOL_TAB_BAR_HEIGHT: number = 33;
const DOL_TAB_FONT: number = 23;
const DOL_TAB_UNDERLINE_HEIGHT: number = 2.2;
const DOL_TAB_GAP: number = 42;

/** 订单卡：左右留白 14.5vp、圆角 8.7vp、卡内边距 17.5vp、卡间距 11vp */
const DOL_CARD_INSET: number = 14.5;
const DOL_CARD_RADIUS: number = 8.7;
const DOL_CARD_PAD: number = 17.5;
const DOL_CARD_GAP: number = 11;

/** 卡内文字：服务名 22vp、状态 12.6vp、时间 17vp、地址 26vp */
const DOL_SERVICE_FONT: number = 22;
const DOL_STATUS_FONT: number = 12.6;
const DOL_TIME_FONT: number = 17;
const DOL_ADDRESS_FONT: number = 30;
const DOL_MONEY_FONT: number = 22;
const DOL_DOT_SIZE: number = 14.5;

/** 地址行固定宽度：比卡片可用宽度更宽，长地址因此冲出卡沿 */
const DOL_ADDRESS_WIDTH: number = 660;

/** 订单数据 */
interface DolOrderItem {
  orderService: string;
  orderStatus: string;
  orderMoney: string;
  orderTime: string;
  orderFrom: string;
  orderTo: string;
  orderFromColor: string;
}

const DOL_ORDERS: DolOrderItem[] = [
  {
    orderService: '单车',
    orderStatus: '已完成',
    orderMoney: '1.50元',
    orderTime: '上周末 20:09',
    orderFrom: '福益盛便利店东南侧',
    orderTo: '大牛坊社区1期-北门附近',
    orderFromColor: '#10C39A'
  },
  {
    orderService: '单车',
    orderStatus: '已完成',
    orderMoney: '1.50元',
    orderTime: '上周末 18:42',
    orderFrom: '中关村软件园二期南门',
    orderTo: '后厂村路公交站',
    orderFromColor: '#10C39A'
  }
];

@Component
export struct DidiOrderListOverflowPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = 459.6;
  @State winHeightVp: number = 672;
  /** 沉浸式下的状态栏 / 底部手势区高度（vp） */
  @State statusBarHeightVp: number = DOL_STATUS_BAR_FALLBACK;
  @State bottomInsetVp: number = DOL_BOTTOM_INSET_FALLBACK;

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

  /** 内容列宽度：设计宽 744.7vp 为上限，宽窗口下居中，更窄时整体缩小 */
  private pageWidth(): number {
    return Math.min(this.winWidthVp, DOL_REFERENCE_WIDTH);
  }

  private s(baseVp: number): number {
    return baseVp * this.pageWidth() / DOL_REFERENCE_WIDTH;
  }

  @Builder
  titleBar() {
    Stack({ alignContent: Alignment.Center }) {
      Text('我的订单')
        .fontSize(this.s(DOL_TITLE_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(DOL_TEXT_MAIN)

      Row() {
        Text('‹')
          .fontSize(this.s(30))
          .fontColor(DOL_TEXT_MAIN)
          .onClick(() => {
            this.pageStack.pop();
          })

        Blank()

        Text('开发票')
          .fontSize(this.s(DOL_ACTION_FONT))
          .fontColor(DOL_TEXT_GRAY)
      }
      .width('100%')
      .padding({ left: this.s(16), right: this.s(16) })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(this.statusBarHeightVp + this.s(DOL_TITLE_ROW_HEIGHT))
    .padding({ top: this.statusBarHeightVp })
  }

  @Builder
  tabItem(tabLabel: string, tabActive: boolean) {
    Column() {
      Text(tabLabel)
        .fontSize(this.s(DOL_TAB_FONT))
        .fontWeight(tabActive ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(tabActive ? DOL_TAB_ACTIVE : '#3D3D3D')

      Row()
        .width(this.s(tabActive ? 62 : 0))
        .height(this.s(DOL_TAB_UNDERLINE_HEIGHT))
        .backgroundColor(DOL_UNDERLINE)
        .margin({ top: this.s(4) })
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  tabBar() {
    Row({ space: this.s(DOL_TAB_GAP) }) {
      this.tabItem('全部', true)
      this.tabItem('打车', false)
      this.tabItem('骑行', false)
      this.tabItem('顺风车', false)
    }
    .width('100%')
    .height(this.s(DOL_TAB_BAR_HEIGHT))
    .padding({ left: this.s(14.5) })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  addressRow(addressText: string, dotColor: string) {
    Row() {
      Row()
        .width(this.s(DOL_DOT_SIZE))
        .height(this.s(DOL_DOT_SIZE))
        .backgroundColor(dotColor)
        .borderRadius(this.s(2.5))
        .margin({ right: this.s(12) })

      Text(addressText)
        .fontSize(this.s(DOL_ADDRESS_FONT))
        .fontColor('#3D3D3D')
        .maxLines(1)
        .width(this.s(DOL_ADDRESS_WIDTH))
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  trashIcon() {
    Column() {
      Row()
        .width(this.s(20))
        .height(this.s(2))
        .backgroundColor('#9A9A9A')
        .borderRadius(this.s(1))

      Column() {
        Row()
          .width(this.s(16))
          .height(this.s(2))
          .backgroundColor('#9A9A9A')

        Row()
          .width(this.s(14))
          .height(this.s(16))
          .border({ width: this.s(1.8), color: '#9A9A9A' })
          .margin({ top: this.s(1) })
      }
      .margin({ top: this.s(2) })
    }
    .width(this.s(24))
    .height(this.s(26))
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  orderCard(order: DolOrderItem) {
    Column() {
      Row() {
        Text(order.orderService)
          .fontSize(this.s(DOL_SERVICE_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(DOL_TEXT_MAIN)

        Text(order.orderStatus)
          .fontSize(this.s(DOL_STATUS_FONT))
          .fontColor('#8C8C8C')
          .backgroundColor(DOL_PILL_BG)
          .borderRadius(this.s(3))
          .padding({ left: this.s(6), right: this.s(6), top: this.s(3), bottom: this.s(3) })
          .margin({ left: this.s(10) })

        Blank()

        Text(order.orderMoney)
          .fontSize(this.s(DOL_MONEY_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(DOL_TEXT_MAIN)

        Text('›')
          .fontSize(this.s(26))
          .fontColor('#C7C7C7')
          .margin({ left: this.s(6) })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Text(order.orderTime)
        .fontSize(this.s(DOL_TIME_FONT))
        .fontColor('#9A9A9A')
        .margin({ top: this.s(8) })

      Column() {
        this.addressRow(order.orderFrom, order.orderFromColor)

        Row()
          .width(this.s(1.5))
          .height(this.s(22))
          .backgroundColor('#E0E0E0')
          .margin({ left: this.s(4.5) })
          .alignSelf(ItemAlign.Start)

        this.addressRow(order.orderTo, DOL_ORANGE)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ top: this.s(10) })

      Row() {
        this.trashIcon()

        Blank()

        Text('再来…')
          .fontSize(this.s(15))
          .fontColor(DOL_BUTTON_TEXT)
          .height(this.s(30))
          .padding({ left: this.s(16), right: this.s(16) })
          .border({ width: this.s(1), color: DOL_BUTTON_BORDER })
          .borderRadius(this.s(15))
      }
      .width('100%')
      .margin({ top: this.s(12) })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(this.s(DOL_CARD_PAD))
    .backgroundColor(Color.White)
    .borderRadius(this.s(DOL_CARD_RADIUS))
    .border({ width: this.s(0.5), color: '#F0F0F0' })
    .margin({ bottom: this.s(DOL_CARD_GAP) })
    .alignItems(HorizontalAlign.Start)
    .clip(false)
  }

  @Builder
  highlightCard() {
    Column() {
      Row() {
        Row()
          .width(this.s(DOL_DOT_SIZE))
          .height(this.s(DOL_DOT_SIZE))
          .backgroundColor(DOL_ORANGE)
          .borderRadius(this.s(2.5))
          .margin({ right: this.s(12) })

        Text('海淀区印象晋南私房菜(中关村环保园1号楼)3层302室')
          .fontSize(this.s(DOL_ADDRESS_FONT))
          .fontColor('#3D3D3D')
          .maxLines(1)
          .width(this.s(DOL_ADDRESS_WIDTH))
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Row() {
        this.trashIcon()

        Blank()

        Text('再来…')
          .fontSize(this.s(15))
          .fontColor(DOL_BUTTON_TEXT)
          .height(this.s(30))
          .padding({ left: this.s(16), right: this.s(16) })
          .border({ width: this.s(1), color: DOL_BUTTON_BORDER })
          .borderRadius(this.s(15))
      }
      .width('100%')
      .margin({ top: this.s(12) })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(this.s(DOL_CARD_PAD))
    .backgroundColor(Color.White)
    .borderRadius(this.s(DOL_CARD_RADIUS))
    .border({ width: this.s(0.5), color: '#F0F0F0' })
    .margin({ bottom: this.s(DOL_CARD_GAP) })
    .alignItems(HorizontalAlign.Start)
    .clip(false)
  }

  build() {
    NavDestination() {
      Column() {
        this.titleBar()
        this.tabBar()

        Scroll() {
          Column() {
            this.highlightCard()

            ForEach(DOL_ORDERS, (order: DolOrderItem) => {
              this.orderCard(order)
            }, (order: DolOrderItem) => order.orderService + order.orderTime)

            Row()
              .width('100%')
              .height(this.bottomInsetVp + this.s(20))
          }
          .width('100%')
          .padding({ left: this.s(DOL_CARD_INSET), right: this.s(DOL_CARD_INSET), top: this.s(9) })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(DOL_PAGE_BG)
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
