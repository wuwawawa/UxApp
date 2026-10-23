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
 * 反例：未避让安全区 / 京东确认订单标题压挖孔（挖孔）
 *
 * 复刻对象：京东「确认订单」页 —— 白色顶栏（返回箭头 + 居中「确认订单」+ 右侧「客服」）、
 *   收货地址卡（收件人、手机号、详细地址）、商品清单行（件数与「查看」）、
 *   支付方式 / 优惠券 / 京豆 / 发票四行可选项、金额明细（商品总额、运费、优惠、应付）、
 *   底部结算栏（合计金额 + 「提交订单」红色按钮 + 协议勾选）。
 *
 * 设计基准：以单屏折叠态窗口宽 459.6vp 为基准（页面所有尺寸按窗口宽度 / 459.6 等比换算）：
 *   顶栏高 44vp、从窗口顶边铺起，标题 16vp 加粗、垂直居中；两端字 13vp；
 *   卡片圆角 12vp、内边距 14vp；地址收件人 15vp、地址 12.5vp；
 *   选项行高 40vp、标签 13vp、值 12.5vp；
 *   底部结算栏高 50vp、提交按钮 78×38vp、距窗口右沿 30vp、按钮文字 14vp。
 *
 * 挖孔实测（Pura X Max 模拟器，密度 2.75，hidumper DisplayManagerService BoundingRects）：
 *   单屏态        459.6×672vp   —— 挖孔圆 24vp，顶部正中（x 218~242vp，y 9.5~33.5vp）；
 *   双屏态竖屏    664.7×939.6vp —— 挖孔圆 26.2vp，右下角（距右 10.2vp、距底 15.3vp）；
 *   双屏态横屏    939.6×664.7vp —— 挖孔圆 26.2vp，右上角（距右 15.3vp、距顶 10.2vp）。
 *
 * 三态实测：
 *   单屏态        459.6×672vp   —— 顶栏 0~44vp，标题「确认订单」四字落在 x 198~262vp、
 *                                 y 14~28vp，挖孔圆（x 218~242vp、y 9.5~33.5vp）从正中穿过；
 *   双屏态竖屏    664.7×939.6vp —— 结算栏占窗口底部 867~939.6vp，提交按钮落在
 *                                 x 508~621vp、y 876~931vp，右下角挖孔圆
 *                                 （x 628~655vp、y 898~924vp）落在按钮右侧空白处，
 *                                 两者不相交；
 *   双屏态横屏    939.6×664.7vp —— 标题放大到 32.7vp、落在 x 404~535vp、y 26~63vp，
 *                                 结算栏落到 562~665vp、按钮落在 x 719~878vp、y 575~652vp，
 *                                 挖孔在右上角（x 898~924vp、y 10.2~36.4vp），均不相交。
 *
 * 问题表现：
 *   单屏态下顶部居中的「确认订单」正对前置摄像头挖孔，「认」「订」两字被黑色圆孔从
 *   正中穿过，只剩两侧半截笔画；状态栏的时间、电量图标同时叠在顶栏两端。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 缩放基准：单屏折叠态窗口宽度（1264px / 2.75） */
const JD_BASE_WIDTH: number = 459.6;

const JD_PAGE_BG: string = '#F2F2F2';
const JD_CARD_BG: string = '#FFFFFF';
const JD_TEXT_MAIN: string = '#1A1A1A';
const JD_TEXT_SUB: string = '#8A8A8A';
const JD_TEXT_DARK: string = '#333333';
const JD_RED: string = '#E1251B';
const JD_RED_LIGHT: string = '#FFF3F2';

/** 顶栏：高 44vp、标题 16vp、两端字 13vp */
const JD_HEADER_HEIGHT: number = 44;
const JD_TITLE_FONT: number = 16;
const JD_HEADER_SIDE_FONT: number = 13;

/** 卡片：圆角 12vp、内边距 14vp、卡间距 8vp */
const JD_CARD_RADIUS: number = 12;
const JD_CARD_PAD: number = 14;
const JD_CARD_GAP: number = 8;

/** 地址卡：收件人 15vp、地址 12.5vp */
const JD_NAME_FONT: number = 15;
const JD_ADDRESS_FONT: number = 12.5;

/** 选项行：高 40vp、标签 13vp、值 12.5vp */
const JD_OPTION_ROW_HEIGHT: number = 40;
const JD_OPTION_LABEL_FONT: number = 13;
const JD_OPTION_VALUE_FONT: number = 12.5;

/** 金额行：高 24vp、文字 12vp、应付 15vp */
const JD_FEE_ROW_HEIGHT: number = 24;
const JD_FEE_FONT: number = 12;
const JD_TOTAL_FONT: number = 15;

/** 底部结算栏：高 50vp、按钮 78×38vp、距右 30vp、文字 14vp */
const JD_BOTTOM_BAR_HEIGHT: number = 50;
const JD_SUBMIT_WIDTH: number = 78;
const JD_SUBMIT_HEIGHT: number = 38;
const JD_SUBMIT_RIGHT_INSET: number = 30;
const JD_SUBMIT_FONT: number = 14;

/** 选项行数据 */
interface JdOptionRow {
  optionKey: string;
  optionLabel: string;
  optionValue: string;
  optionAccent: boolean;
}

const JD_OPTION_ROWS: JdOptionRow[] = [
  { optionKey: 'opt-pay', optionLabel: '支付方式', optionValue: '京东支付 · 满减立减 3 元', optionAccent: true },
  { optionKey: 'opt-coupon', optionLabel: '优惠券', optionValue: '2 张可用', optionAccent: true },
  { optionKey: 'opt-bean', optionLabel: '京豆抵扣', optionValue: '可用 1280 京豆抵 ¥12.80', optionAccent: false },
  { optionKey: 'opt-invoice', optionLabel: '发票', optionValue: '不开发票', optionAccent: false }
];

/** 金额行数据 */
interface JdFeeRow {
  feeKey: string;
  feeLabel: string;
  feeValue: string;
  feeEmphasis: boolean;
}

const JD_FEE_ROWS: JdFeeRow[] = [
  { feeKey: 'fee-goods', feeLabel: '商品总额', feeValue: '¥268.00', feeEmphasis: false },
  { feeKey: 'fee-ship', feeLabel: '运费', feeValue: '¥0.00', feeEmphasis: false },
  { feeKey: 'fee-coupon', feeLabel: '优惠', feeValue: '-¥31.00', feeEmphasis: false },
  { feeKey: 'fee-pay', feeLabel: '应付金额', feeValue: '¥237.00', feeEmphasis: true }
];

@Component
export struct JdOrderConfirmNotchPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = JD_BASE_WIDTH;
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
    return this.winWidthVp / JD_BASE_WIDTH;
  }

  /** 把基准宽下的设计值换算到当前窗口宽度 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  /** 顶栏：返回 + 居中标题 + 客服 */
  @Builder
  confirmHeader() {
    Stack({ alignContent: Alignment.Center }) {
      Text('确认订单')
        .fontSize(this.vs(JD_TITLE_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(JD_TEXT_MAIN)
        .maxLines(1)

      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(this.vs(JD_TITLE_FONT + 6))
          .fontColor([JD_TEXT_MAIN])
          .onClick(() => {
            this.pageStack.pop();
          })

        Blank()

        Text('客服')
          .fontSize(this.vs(JD_HEADER_SIDE_FONT))
          .fontColor(JD_TEXT_DARK)
      }
      .width('100%')
      .height('100%')
      .padding({ left: this.vs(10), right: this.vs(14) })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(this.vs(JD_HEADER_HEIGHT))
    .backgroundColor(JD_CARD_BG)
  }

  /** 收货地址卡 */
  @Builder
  addressCard() {
    Column({ space: this.vs(6) }) {
      Row() {
        Text('王小明')
          .fontSize(this.vs(JD_NAME_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(JD_TEXT_MAIN)

        Text('138****6688')
          .fontSize(this.vs(JD_ADDRESS_FONT + 0.5))
          .fontColor(JD_TEXT_MAIN)
          .margin({ left: this.vs(10) })

        Blank()

        Text('›')
          .fontSize(this.vs(16))
          .fontColor(JD_TEXT_SUB)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Text('浙江省杭州市西湖区文三路 128 号 3 幢 2 单元 601 室')
        .fontSize(this.vs(JD_ADDRESS_FONT))
        .fontColor(JD_TEXT_DARK)
        .maxLines(2)
        .lineHeight(this.vs(18))
    }
    .width('100%')
    .padding(this.vs(JD_CARD_PAD))
    .backgroundColor(JD_CARD_BG)
    .borderRadius(this.vs(JD_CARD_RADIUS))
    .alignItems(HorizontalAlign.Start)
  }

  /** 商品清单行 */
  @Builder
  goodsSummaryCard() {
    Row() {
      Column({ space: this.vs(4) }) {
        Text('商品清单 · 共 3 件')
          .fontSize(this.vs(JD_OPTION_LABEL_FONT))
          .fontColor(JD_TEXT_MAIN)

        Text('Apple iPad 11 英寸 128G WLAN 版 · 银色 等 3 件')
          .fontSize(this.vs(JD_ADDRESS_FONT))
          .fontColor(JD_TEXT_SUB)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text('查看 ›')
        .fontSize(this.vs(JD_OPTION_VALUE_FONT))
        .fontColor(JD_TEXT_SUB)
        .margin({ left: this.vs(10) })
    }
    .width('100%')
    .padding(this.vs(JD_CARD_PAD))
    .backgroundColor(JD_CARD_BG)
    .borderRadius(this.vs(JD_CARD_RADIUS))
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  optionRow(option: JdOptionRow) {
    Row() {
      Text(option.optionLabel)
        .fontSize(this.vs(JD_OPTION_LABEL_FONT))
        .fontColor(JD_TEXT_MAIN)

      Blank()

      Text(option.optionValue)
        .fontSize(this.vs(JD_OPTION_VALUE_FONT))
        .fontColor(option.optionAccent ? JD_RED : JD_TEXT_SUB)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ left: this.vs(12) })

      Text('›')
        .fontSize(this.vs(14))
        .fontColor(JD_TEXT_SUB)
        .margin({ left: this.vs(6) })
    }
    .width('100%')
    .height(this.vs(JD_OPTION_ROW_HEIGHT))
    .alignItems(VerticalAlign.Center)
  }

  /** 选项卡：支付方式 / 优惠券 / 京豆 / 发票 */
  @Builder
  optionCard() {
    Column() {
      ForEach(JD_OPTION_ROWS, (option: JdOptionRow) => {
        this.optionRow(option)
      }, (option: JdOptionRow) => option.optionKey)
    }
    .width('100%')
    .padding({ left: this.vs(JD_CARD_PAD), right: this.vs(JD_CARD_PAD), top: this.vs(4), bottom: this.vs(4) })
    .backgroundColor(JD_CARD_BG)
    .borderRadius(this.vs(JD_CARD_RADIUS))
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  feeRow(fee: JdFeeRow) {
    Row() {
      Text(fee.feeLabel)
        .fontSize(this.vs(JD_FEE_FONT))
        .fontColor(JD_TEXT_SUB)

      Blank()

      Text(fee.feeValue)
        .fontSize(this.vs(fee.feeEmphasis ? JD_TOTAL_FONT : JD_FEE_FONT))
        .fontWeight(fee.feeEmphasis ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(fee.feeEmphasis ? JD_RED : JD_TEXT_MAIN)
    }
    .width('100%')
    .height(this.vs(JD_FEE_ROW_HEIGHT))
    .alignItems(VerticalAlign.Center)
  }

  /** 金额明细卡 */
  @Builder
  feeCard() {
    Column() {
      ForEach(JD_FEE_ROWS, (fee: JdFeeRow) => {
        this.feeRow(fee)
      }, (fee: JdFeeRow) => fee.feeKey)
    }
    .width('100%')
    .padding(this.vs(JD_CARD_PAD))
    .backgroundColor(JD_CARD_BG)
    .borderRadius(this.vs(JD_CARD_RADIUS))
    .alignItems(HorizontalAlign.Start)
  }

  /** 底部结算栏：合计 + 提交订单 */
  @Builder
  submitBar() {
    Column() {
      Row() {
        Row() {
          Stack({ alignContent: Alignment.Center }) {
            Circle()
              .width(this.vs(14))
              .height(this.vs(14))
              .fill(JD_RED)

            Text('✓')
              .fontSize(this.vs(9))
              .fontColor(Color.White)
          }
          .width(this.vs(14))
          .height(this.vs(14))

          Text('已同意《京东服务协议》')
            .fontSize(this.vs(10))
            .fontColor(JD_TEXT_SUB)
            .margin({ left: this.vs(6) })
        }
        .alignItems(VerticalAlign.Center)

        Blank()

        Row() {
          Text('合计 ')
            .fontSize(this.vs(11))
            .fontColor(JD_TEXT_DARK)

          Text('¥237.00')
            .fontSize(this.vs(JD_TOTAL_FONT))
            .fontWeight(FontWeight.Bold)
            .fontColor(JD_RED)
        }
        .alignItems(VerticalAlign.Center)

        Row() {
          Text('提交订单')
            .fontSize(this.vs(JD_SUBMIT_FONT))
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
        }
        .width(this.vs(JD_SUBMIT_WIDTH))
        .height(this.vs(JD_SUBMIT_HEIGHT))
        .justifyContent(FlexAlign.Center)
        .backgroundColor(JD_RED)
        .borderRadius(this.vs(JD_SUBMIT_HEIGHT / 2))
        .margin({ left: this.vs(10) })
      }
      .width('100%')
      .layoutWeight(1)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(this.vs(JD_BOTTOM_BAR_HEIGHT))
    .padding({ left: this.vs(JD_CARD_PAD), right: this.vs(JD_SUBMIT_RIGHT_INSET) })
    .backgroundColor(JD_CARD_BG)
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    NavDestination() {
      Column() {
        this.confirmHeader()

        Scroll() {
          Column({ space: this.vs(JD_CARD_GAP) }) {
            this.addressCard()
            this.goodsSummaryCard()
            this.optionCard()
            this.feeCard()

            Text('提交订单后商家将在 24 小时内发货，支持 7 天无理由退货')
              .fontSize(this.vs(10.5))
              .fontColor(JD_TEXT_SUB)
              .lineHeight(this.vs(16))
              .padding({ left: this.vs(4), right: this.vs(4), top: this.vs(4) })
          }
          .width('100%')
          .padding({ left: this.vs(JD_CARD_PAD - 4), right: this.vs(JD_CARD_PAD - 4), top: this.vs(JD_CARD_GAP) })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .backgroundColor(JD_PAGE_BG)

        this.submitBar()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(JD_PAGE_BG)
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
