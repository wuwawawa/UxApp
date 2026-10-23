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
 * 反例：未避让安全区 / 美团外卖订单客服按钮压挖孔（挖孔）
 *
 * 复刻对象：美团外卖「订单详情」页 —— 黄色顶栏（返回箭头 + 居中「订单详情」+ 右侧描边「客服」）、
 *   送餐状态区（「商家已接单」+ 预计送达 + 骑手信息）、商家卡（店名、地址、菜品行：名称、
 *   规格、数量、金额）、费用明细卡（商品小计、配送费、红包抵扣、实付）、
 *   底部操作栏（「联系商家」/「再来一单」）。
 *
 * 设计基准：以单屏折叠态窗口宽 459.6vp 为基准（页面所有尺寸按窗口宽度 / 459.6 等比换算）：
 *   顶栏高 19vp、从窗口顶边铺起；标题 11vp 加粗、垂直居中；返回箭头 16vp；
 *   「客服」描边胶囊高 15vp、文字 9.5vp、距窗口右沿 5.5vp；
 *   状态区高 44vp、主文案 14vp；卡片圆角 12vp、内边距 12vp；
 *   菜品名称 11.5vp、规格 9.5vp、金额 11.5vp；底部操作栏高 34vp。
 *
 * 挖孔实测（Pura X Max 模拟器，密度 2.75，hidumper DisplayManagerService BoundingRects）：
 *   单屏态        459.6×672vp   —— 挖孔圆 24vp，顶部正中（x 218~242vp，y 9.5~33.5vp）；
 *   双屏态竖屏    664.7×939.6vp —— 挖孔圆 26.2vp，右下角（距右 10.2vp、距底 15.3vp）；
 *   双屏态横屏    939.6×664.7vp —— 挖孔圆 26.2vp，右上角（距右 15.3vp、距顶 10.2vp）。
 *
 * 三态实测：
 *   单屏态        459.6×672vp   —— 顶栏 0~19vp，「客服」胶囊落在 x 371~412vp、
 *                                 y 2~17vp，挖孔在顶部正中（x 218~242vp），两者不相交；
 *   双屏态竖屏    664.7×939.6vp —— 顶栏放大到 0~27.5vp，「客服」胶囊落到 x 536~596vp、
 *                                 y 2.9~24.6vp，挖孔在右下角，两者不相交；
 *   双屏态横屏    939.6×664.7vp —— 顶栏放大到 0~38.8vp，「客服」胶囊放大到
 *                                 x 848~925vp、y 4~27vp，右上角挖孔圆
 *                                 （x 898~924vp、y 10.2~36.4vp）压在「服」字与右侧描边上。
 *
 * 问题表现（双屏态横屏）：
 *   顶栏右上角的「客服」被前置摄像头挖孔压掉右半个字与右侧描边框，「服」被整块盖住；
 *   状态栏时间、电量图标同时叠在黄色顶栏两端。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 缩放基准：单屏折叠态窗口宽度（1264px / 2.75） */
const MT_BASE_WIDTH: number = 459.6;

const MT_PAGE_BG: string = '#F5F5F5';
const MT_HEAD_START: string = '#FFD400';
const MT_HEAD_END: string = '#FFC300';
const MT_CARD_BG: string = '#FFFFFF';
const MT_TEXT_MAIN: string = '#222222';
const MT_TEXT_SUB: string = '#8C8C8C';
const MT_TEXT_DARK: string = '#3D2B00';
const MT_PRICE_RED: string = '#FF4B33';

/** 顶栏：高 19vp、标题 11vp、返回 16vp、客服胶囊高 15vp、距右 5.5vp */
const MT_HEADER_HEIGHT: number = 19;
const MT_TITLE_FONT: number = 11;
const MT_BACK_ICON: number = 16;
const MT_SERVICE_HEIGHT: number = 15;
const MT_SERVICE_FONT: number = 9.5;
const MT_SERVICE_RIGHT_INSET: number = 5.5;

/** 状态区：高 44vp、主文案 14vp、副文案 10vp */
const MT_STATUS_HEIGHT: number = 44;
const MT_STATUS_FONT: number = 14;
const MT_STATUS_SUB_FONT: number = 10;

/** 卡片：圆角 12vp、内边距 12vp、卡间距 8vp */
const MT_CARD_RADIUS: number = 12;
const MT_CARD_PAD: number = 12;
const MT_CARD_GAP: number = 8;

/** 菜品行：名称 11.5vp、规格 9.5vp、金额 11.5vp、行高 30vp */
const MT_DISH_ROW_HEIGHT: number = 30;
const MT_DISH_NAME_FONT: number = 11.5;
const MT_DISH_SPEC_FONT: number = 9.5;
const MT_DISH_PRICE_FONT: number = 11.5;

/** 费用行：标签 10.5vp、金额 10.5vp、行高 22vp */
const MT_FEE_ROW_HEIGHT: number = 22;
const MT_FEE_FONT: number = 10.5;

/** 底部操作栏：高 34vp、按钮文字 11vp */
const MT_BOTTOM_HEIGHT: number = 34;
const MT_BUTTON_FONT: number = 11;

/** 菜品数据 */
interface MeituanDishItem {
  dishKey: string;
  dishName: string;
  dishSpec: string;
  dishCount: string;
  dishPrice: string;
}

const MT_DISH_LIST: MeituanDishItem[] = [
  { dishKey: 'dish-burger', dishName: '香辣鸡腿堡', dishSpec: '不辣 / 加芝士', dishCount: 'x1', dishPrice: '¥21.00' },
  { dishKey: 'dish-wings', dishName: '奥尔良烤翅（4 只）', dishSpec: '中辣', dishCount: 'x1', dishPrice: '¥16.50' },
  { dishKey: 'dish-cola', dishName: '可口可乐 中杯', dishSpec: '少冰', dishCount: 'x2', dishPrice: '¥12.00' }
];

/** 费用行数据 */
interface MeituanFeeRow {
  feeKey: string;
  feeLabel: string;
  feeValue: string;
  feeEmphasis: boolean;
}

const MT_FEE_ROWS: MeituanFeeRow[] = [
  { feeKey: 'fee-goods', feeLabel: '商品小计', feeValue: '¥49.50', feeEmphasis: false },
  { feeKey: 'fee-delivery', feeLabel: '配送费', feeValue: '¥4.00', feeEmphasis: false },
  { feeKey: 'fee-coupon', feeLabel: '红包抵扣', feeValue: '-¥8.00', feeEmphasis: false },
  { feeKey: 'fee-total', feeLabel: '实付金额', feeValue: '¥45.50', feeEmphasis: true }
];

@Component
export struct MeituanOrderServiceNotchPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = MT_BASE_WIDTH;
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
      this.windowToken = WindowModeController.acquire(win, '#000000');
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  /** 场景缩放比：当前窗口宽 / 单屏折叠态基准宽 */
  private sceneScale(): number {
    return this.winWidthVp / MT_BASE_WIDTH;
  }

  /** 把基准宽下的设计值换算到当前窗口宽度 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  /** 顶栏：返回 + 居中标题 + 客服胶囊 */
  @Builder
  orderHeader() {
    Stack({ alignContent: Alignment.Center }) {
      Text('订单详情')
        .fontSize(this.vs(MT_TITLE_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(MT_TEXT_DARK)
        .maxLines(1)

      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(this.vs(MT_BACK_ICON))
          .fontColor([MT_TEXT_DARK])
          .onClick(() => {
            this.pageStack.pop();
          })

        Blank()

        Row() {
          Text('客服')
            .fontSize(this.vs(MT_SERVICE_FONT))
            .fontColor(MT_TEXT_DARK)
        }
        .height(this.vs(MT_SERVICE_HEIGHT))
        .padding({ left: this.vs(9), right: this.vs(9) })
        .justifyContent(FlexAlign.Center)
        .border({ width: this.vs(0.8), color: 'rgba(61,43,0,0.55)' })
        .borderRadius(this.vs(MT_SERVICE_HEIGHT / 2))
      }
      .width('100%')
      .height('100%')
      .padding({ left: this.vs(8), right: this.vs(MT_SERVICE_RIGHT_INSET) })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(this.vs(MT_HEADER_HEIGHT))
  }

  /** 送餐状态区 */
  @Builder
  statusArea() {
    Column() {
      Row() {
        Text('商家已接单')
          .fontSize(this.vs(MT_STATUS_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(MT_TEXT_DARK)

        Blank()

        Text('预计 12:35 送达')
          .fontSize(this.vs(MT_STATUS_SUB_FONT))
          .fontColor(MT_TEXT_DARK)
      }
      .width('100%')

      Text('骑手 王师傅 正在前往商家取餐')
        .fontSize(this.vs(MT_STATUS_SUB_FONT + 0.5))
        .fontColor('rgba(61,43,0,0.72)')
        .margin({ top: this.vs(6) })
    }
    .width('100%')
    .height(this.vs(MT_STATUS_HEIGHT))
    .padding({ left: this.vs(MT_CARD_PAD), right: this.vs(MT_CARD_PAD) })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  dishRow(dish: MeituanDishItem) {
    Row() {
      Column({ space: this.vs(3) }) {
        Text(dish.dishName)
          .fontSize(this.vs(MT_DISH_NAME_FONT))
          .fontColor(MT_TEXT_MAIN)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(dish.dishSpec)
          .fontSize(this.vs(MT_DISH_SPEC_FONT))
          .fontColor(MT_TEXT_SUB)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text(dish.dishCount)
        .fontSize(this.vs(MT_DISH_SPEC_FONT + 0.5))
        .fontColor(MT_TEXT_SUB)
        .margin({ right: this.vs(10) })

      Text(dish.dishPrice)
        .fontSize(this.vs(MT_DISH_PRICE_FONT))
        .fontColor(MT_TEXT_MAIN)
    }
    .width('100%')
    .height(this.vs(MT_DISH_ROW_HEIGHT))
    .alignItems(VerticalAlign.Center)
  }

  /** 商家卡：店名 + 地址 + 菜品 */
  @Builder
  merchantCard() {
    Column() {
      Row() {
        Text('华莱士 · 汉堡炸鸡（文三路店）')
          .fontSize(this.vs(MT_DISH_NAME_FONT + 0.5))
          .fontWeight(FontWeight.Bold)
          .fontColor(MT_TEXT_MAIN)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)

        Text('进店 ›')
          .fontSize(this.vs(MT_DISH_SPEC_FONT))
          .fontColor(MT_TEXT_SUB)
          .margin({ left: this.vs(8) })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      ForEach(MT_DISH_LIST, (dish: MeituanDishItem) => {
        this.dishRow(dish)
      }, (dish: MeituanDishItem) => dish.dishKey)
    }
    .width('100%')
    .padding(this.vs(MT_CARD_PAD))
    .backgroundColor(MT_CARD_BG)
    .borderRadius(this.vs(MT_CARD_RADIUS))
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  feeRow(fee: MeituanFeeRow) {
    Row() {
      Text(fee.feeLabel)
        .fontSize(this.vs(MT_FEE_FONT))
        .fontColor(fee.feeEmphasis ? MT_TEXT_MAIN : MT_TEXT_SUB)

      Blank()

      Text(fee.feeValue)
        .fontSize(this.vs(fee.feeEmphasis ? MT_FEE_FONT + 2 : MT_FEE_FONT))
        .fontWeight(fee.feeEmphasis ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(fee.feeEmphasis ? MT_PRICE_RED : MT_TEXT_MAIN)
    }
    .width('100%')
    .height(this.vs(fee.feeEmphasis ? MT_FEE_ROW_HEIGHT + 6 : MT_FEE_ROW_HEIGHT))
    .alignItems(VerticalAlign.Center)
  }

  /** 费用明细卡 */
  @Builder
  feeCard() {
    Column() {
      ForEach(MT_FEE_ROWS, (fee: MeituanFeeRow) => {
        this.feeRow(fee)
      }, (fee: MeituanFeeRow) => fee.feeKey)
    }
    .width('100%')
    .padding(this.vs(MT_CARD_PAD))
    .backgroundColor(MT_CARD_BG)
    .borderRadius(this.vs(MT_CARD_RADIUS))
    .alignItems(HorizontalAlign.Start)
  }

  /** 订单信息卡 */
  @Builder
  infoCard() {
    Column({ space: this.vs(6) }) {
      Text('订单编号  202610231147000812')
        .fontSize(this.vs(MT_FEE_FONT - 0.5))
        .fontColor(MT_TEXT_SUB)

      Text('下单时间  2026-10-23 11:47:02')
        .fontSize(this.vs(MT_FEE_FONT - 0.5))
        .fontColor(MT_TEXT_SUB)

      Text('配送地址  西湖区文三路 128 号 3 幢 2 单元 601')
        .fontSize(this.vs(MT_FEE_FONT - 0.5))
        .fontColor(MT_TEXT_SUB)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .padding(this.vs(MT_CARD_PAD))
    .backgroundColor(MT_CARD_BG)
    .borderRadius(this.vs(MT_CARD_RADIUS))
    .alignItems(HorizontalAlign.Start)
  }

  /** 底部操作栏 */
  @Builder
  bottomBar() {
    Row({ space: this.vs(8) }) {
      Row() {
        Text('联系商家')
          .fontSize(this.vs(MT_BUTTON_FONT))
          .fontColor(MT_TEXT_MAIN)
      }
      .height(this.vs(26))
      .padding({ left: this.vs(14), right: this.vs(14) })
      .justifyContent(FlexAlign.Center)
      .border({ width: this.vs(0.8), color: '#DDDDDD' })
      .borderRadius(this.vs(13))

      Blank()

      Row() {
        Text('再来一单')
          .fontSize(this.vs(MT_BUTTON_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(MT_TEXT_DARK)
      }
      .height(this.vs(26))
      .padding({ left: this.vs(18), right: this.vs(18) })
      .justifyContent(FlexAlign.Center)
      .linearGradient({ angle: 90, colors: [[MT_HEAD_START, 0], [MT_HEAD_END, 1]] })
      .borderRadius(this.vs(13))
    }
    .width('100%')
    .height(this.vs(MT_BOTTOM_HEIGHT))
    .padding({ left: this.vs(MT_CARD_PAD), right: this.vs(MT_CARD_PAD) })
    .backgroundColor(MT_CARD_BG)
    .alignItems(VerticalAlign.Center)
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          this.orderHeader()
          this.statusArea()
        }
        .width('100%')
        .linearGradient({ angle: 180, colors: [[MT_HEAD_START, 0], [MT_HEAD_END, 1]] })

        Scroll() {
          Column({ space: this.vs(MT_CARD_GAP) }) {
            this.merchantCard()
            this.feeCard()
            this.infoCard()
          }
          .width('100%')
          .padding({ left: this.vs(MT_CARD_PAD - 2), right: this.vs(MT_CARD_PAD - 2), top: this.vs(MT_CARD_GAP) })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .backgroundColor(MT_PAGE_BG)

        this.bottomBar()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(MT_PAGE_BG)
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
