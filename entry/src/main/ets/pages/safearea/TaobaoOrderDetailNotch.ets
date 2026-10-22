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
 * 反例：未避让安全区 / 淘宝订单详情标题压挖孔（挖孔）
 *
 * 复刻对象：淘宝「订单详情」页 —— 橙色渐变头部（返回 + 居中「订单详情」 + 更多）、
 *   「已发货·运输中」状态条、白色收货地址卡（定位图标 + 收件人 + 手机号 + 一行长收货地址）、
 *   店铺卡（天猫超市 + 进店 + 两个商品行：渐变色占位图、标题、规格、价格、数量）、
 *   金额明细卡（商品金额 / 运费 / 店铺优惠 / 淘金币抵扣 / 实付款）、订单信息卡
 *   （订单编号 / 创建时间 / 付款时间 / 发货方式 / 物流单号），底部固定操作栏
 *   （咋联系卖家 / 查看物流 / 评价）。
 *
 * 设计基准：以单屏折叠态窗口宽 459.6vp 为基准（页面所有尺寸按窗口宽度 / 459.6 等比换算）：
 *   头部从窗口顶边铺起，标题行高 44vp、标题 18vp（水平居中）；状态条高 58vp；
 *   卡片左右留白 10vp、圆角 14vp、内边距 14vp；商品图 74vp 见方；底部操作栏高 52vp。
 *
 * 挖孔实测（Pura X Max 模拟器，密度 2.75，hidumper DisplayManagerService BoundingRects）：
 *   单屏态        459.6×672vp   —— 挖孔圆 24vp，顶部正中（x 218~242vp，y 9.5~33.5vp）；
 *   双屏态竖屏    664.7×939.6vp —— 挖孔圆 26.2vp，右下角（距右 10.2vp、距底 15.3vp）；
 *   双屏态横屏    939.6×664.7vp —— 挖孔圆 26.2vp，右上角（距右 15.3vp、距顶 10.2vp）。
 *
 * 三态实测：
 *   单屏态        459.6×672vp   —— 标题行占窗口顶部 0~44vp，「订单详情」四个 18vp 的字
 *                                 水平居中落在 x 约 194~266vp、竖直约 13~31vp，
 *                                 与挖孔圆（x 218~242vp、y 9.5~33.5vp）完全重合；
 *   双屏态竖屏    664.7×939.6vp —— 标题行放大到 0~63.7vp，标题字放大到 26vp，
 *                                 仍从窗口顶边铺起，压住状态栏区域；
 *   双屏态横屏    939.6×664.7vp —— 标题行放大到 0~90vp，右上角「•••」
 *                                 （x 约 890~915vp）与挖孔圆（x 898~924vp）相交。
 *
 * 问题表现：
 *   单屏态下「订单详情」标题正对前置摄像头挖孔，四个字被黑色圆孔从正中穿过，
 *   时间、电量图标同时叠在橙色头部的标题行上；双屏态两个方向标题行同样贴着
 *   窗口顶边铺开，状态栏图标与标题 / 返回箭头 / 「•••」互相压盖。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 缩放基准：单屏折叠态窗口宽度（1264px / 2.75） */
const TAO_BASE_WIDTH: number = 459.6;

/** 状态栏 / 底部手势区兜底高度（vp） */
const TAO_STATUS_BAR_FALLBACK: number = 32;
const TAO_BOTTOM_INSET_FALLBACK: number = 8;

const TAO_PAGE_BG: string = '#F5F5F5';
const TAO_HEADER_START: string = '#FF9000';
const TAO_HEADER_END: string = '#FF5000';
const TAO_ORANGE: string = '#FF5000';
const TAO_TEXT_MAIN: string = '#111111';
const TAO_TEXT_SUB: string = '#888888';
const TAO_TEXT_LIGHT: string = '#BBBBBB';
const TAO_PRICE_RED: string = '#FF3C1E';
const TAO_PILL_BG: string = '#F5F5F5';

/** 头部：标题行 44vp、标题 18vp、返回箭头 24vp */
const TAO_TITLE_ROW_HEIGHT: number = 44;
const TAO_TITLE_FONT: number = 18;
const TAO_BACK_FONT: number = 24;

/** 状态条：高 58vp、主文案 17vp、副文案 12vp、定位图标圆 30vp */
const TAO_STATUS_STRIP_HEIGHT: number = 58;
const TAO_STATUS_MAIN_FONT: number = 17;
const TAO_STATUS_SUB_FONT: number = 12;
const TAO_PIN_CIRCLE: number = 30;

/** 卡片：左右留白 10vp、圆角 14vp、内边距 14vp、卡间距 10vp */
const TAO_CARD_INSET: number = 10;
const TAO_CARD_RADIUS: number = 14;
const TAO_CARD_PAD: number = 14;
const TAO_CARD_GAP: number = 10;

/** 地址卡：收件人 16vp、手机号 14vp、地址 15vp */
const TAO_RECIPIENT_FONT: number = 16;
const TAO_PHONE_FONT: number = 14;
const TAO_ADDRESS_FONT: number = 15;

/** 地址行行宽（基准值） */
const TAO_ADDRESS_ROW_WIDTH: number = 500;

/** 商品行：图 74vp、标题 14vp、规格 12vp、价格 15vp、数量 12vp */
const TAO_GOODS_PIC: number = 74;
const TAO_GOODS_TITLE_FONT: number = 14;
const TAO_GOODS_SPEC_FONT: number = 12;
const TAO_GOODS_PRICE_FONT: number = 15;
const TAO_GOODS_COUNT_FONT: number = 12;

/** 金额明细：标签 13vp、金额 14vp、实付款 17vp */
const TAO_PRICE_LABEL_FONT: number = 13;
const TAO_PRICE_VALUE_FONT: number = 14;
const TAO_FINAL_FONT: number = 17;

/** 订单信息：标签 12vp、内容 13vp */
const TAO_INFO_LABEL_FONT: number = 12;
const TAO_INFO_VALUE_FONT: number = 13;

/** 底部操作栏：高 52vp、按钮文字 14vp */
const TAO_BOTTOM_BAR_HEIGHT: number = 52;
const TAO_ACTION_FONT: number = 14;

/** 商品数据 */
interface TaobaoOrderGoodsItem {
  goodsTitle: string;
  goodsSpec: string;
  goodsPrice: string;
  goodsCount: string;
  goodsTintStart: string;
  goodsTintEnd: string;
}

const TAO_GOODS_LIST: TaobaoOrderGoodsItem[] = [
  {
    goodsTitle: '天猫超市 新疆阿克苏苹果 75-80mm 5kg装整箱 新鲜水果礼盒',
    goodsSpec: '组合装 75-80mm 5kg',
    goodsPrice: '¥49.90',
    goodsCount: 'x2',
    goodsTintStart: '#8FD08A',
    goodsTintEnd: '#4CA64C'
  },
  {
    goodsTitle: '三只松鼠 零食大礼包 全家欢乐装 整箱30包 网红休闲小吃',
    goodsSpec: '整箱 1452g/箱',
    goodsPrice: '¥89.00',
    goodsCount: 'x1',
    goodsTintStart: '#FFB36B',
    goodsTintEnd: '#F2703E'
  }
];

/** 金额明细行 */
interface TaobaoPriceRowItem {
  priceLabel: string;
  priceValue: string;
  priceEmphasis: boolean;
}

const TAO_PRICE_ROWS: TaobaoPriceRowItem[] = [
  { priceLabel: '商品金额', priceValue: '¥188.80', priceEmphasis: false },
  { priceLabel: '运费（快递）', priceValue: '¥0.00', priceEmphasis: false },
  { priceLabel: '店铺优惠', priceValue: '-¥10.00', priceEmphasis: false },
  { priceLabel: '淘金币抵扣', priceValue: '-¥2.60', priceEmphasis: false },
  { priceLabel: '实付款', priceValue: '¥176.20', priceEmphasis: true }
];

/** 订单信息行 */
interface TaobaoInfoRowItem {
  infoLabel: string;
  infoValue: string;
}

const TAO_INFO_ROWS: TaobaoInfoRowItem[] = [
  { infoLabel: '订单编号', infoValue: '2026102214691234567' },
  { infoLabel: '创建时间', infoValue: '2026-10-22 14:32:08' },
  { infoLabel: '付款时间', infoValue: '2026-10-22 14:32:35' },
  { infoLabel: '发货方式', infoValue: '快递 · 菜鸟裹裹' },
  { infoLabel: '物流单号', infoValue: 'SF1420261022489012' }
];

@Component
export struct TaobaoOrderDetailNotchPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = TAO_BASE_WIDTH;
  @State winHeightVp: number = 672;
  /** 沉浸式下的状态栏 / 底部手势区高度（vp） */
  @State statusBarHeightVp: number = TAO_STATUS_BAR_FALLBACK;
  @State bottomInsetVp: number = TAO_BOTTOM_INSET_FALLBACK;

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
      this.windowToken = WindowModeController.acquire(win, TAO_HEADER_END);
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  /** 场景缩放比：当前窗口宽 / 单屏折叠态基准宽 */
  private sceneScale(): number {
    return this.winWidthVp / TAO_BASE_WIDTH;
  }

  /** 把基准宽下的设计值换算到当前窗口宽度 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  /** 头部标题行：返回 + 订单详情 + 更多 */
  @Builder
  titleBar() {
    Stack({ alignContent: Alignment.Center }) {
      Text('订单详情')
        .fontSize(this.vs(TAO_TITLE_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)

      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(this.vs(TAO_BACK_FONT))
          .fontColor([Color.White])
          .onClick(() => {
            this.pageStack.pop();
          })

        Blank()

        Text('•••')
          .fontSize(this.vs(TAO_BACK_FONT))
          .fontColor(Color.White)
      }
      .width('100%')
      .padding({ left: this.vs(12), right: this.vs(12) })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(this.vs(TAO_TITLE_ROW_HEIGHT))
  }

  /** 状态条：定位圆标 + 已发货文案 */
  @Builder
  statusStrip() {
    Row() {
      Column() {
        SymbolGlyph($r('sys.symbol.pin'))
          .fontSize(this.vs(15))
          .fontColor([Color.White])
      }
      .width(this.vs(TAO_PIN_CIRCLE))
      .height(this.vs(TAO_PIN_CIRCLE))
      .justifyContent(FlexAlign.Center)
      .backgroundColor('rgba(255,255,255,0.25)')
      .borderRadius(this.vs(TAO_PIN_CIRCLE / 2))

      Column() {
        Text('已发货 · 运输中')
          .fontSize(this.vs(TAO_STATUS_MAIN_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)

        Text('包裹已从【杭州萧山转运中心】发出，预计10月24日 18:00 前送达')
          .fontSize(this.vs(TAO_STATUS_SUB_FONT))
          .fontColor('rgba(255,255,255,0.9)')
          .maxLines(1)
          .margin({ top: this.vs(3) })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: this.vs(10) })
    }
    .width('100%')
    .height(this.vs(TAO_STATUS_STRIP_HEIGHT))
    .padding({ left: this.vs(14), right: this.vs(14) })
    .alignItems(VerticalAlign.Center)
  }

  /** 收货地址卡 */
  @Builder
  addressCard() {
    Column() {
      Row() {
        Text('王小明')
          .fontSize(this.vs(TAO_RECIPIENT_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(TAO_TEXT_MAIN)

        Text('138****6688')
          .fontSize(this.vs(TAO_PHONE_FONT))
          .fontColor(TAO_TEXT_MAIN)
          .margin({ left: this.vs(10) })

        Text('家')
          .fontSize(this.vs(11))
          .fontColor(TAO_ORANGE)
          .backgroundColor('#FFF0E6')
          .borderRadius(this.vs(3))
          .padding({ left: this.vs(5), right: this.vs(5), top: this.vs(2), bottom: this.vs(2) })
          .margin({ left: this.vs(8) })

        Blank()

        Text('修改地址')
          .fontSize(this.vs(TAO_PHONE_FONT))
          .fontColor(TAO_TEXT_SUB)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Row() {
        Text('北京市海淀区中关村软件园二期互联网创新中心东区B座3层302室（南门东侧丰巢快递柜旁）')
          .fontSize(this.vs(TAO_ADDRESS_FONT))
          .fontColor('#3D3D3D')
          .maxLines(1)
          .width(this.vs(TAO_ADDRESS_ROW_WIDTH))
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ top: this.vs(8) })
    }
    .width('100%')
    .padding(this.vs(TAO_CARD_PAD))
    .backgroundColor(Color.White)
    .borderRadius(this.vs(TAO_CARD_RADIUS))
    .margin({ left: this.vs(TAO_CARD_INSET), right: this.vs(TAO_CARD_INSET), bottom: this.vs(12) })
    .alignItems(HorizontalAlign.Start)
    .clip(false)
  }

  /** 商品占位图：渐变色块 + 购物袋图标（无图片资源） */
  @Builder
  goodsPic(goods: TaobaoOrderGoodsItem) {
    Column() {
      SymbolGlyph($r('sys.symbol.bag_fill'))
        .fontSize(this.vs(26))
        .fontColor(['rgba(255,255,255,0.85)'])
    }
    .width(this.vs(TAO_GOODS_PIC))
    .height(this.vs(TAO_GOODS_PIC))
    .justifyContent(FlexAlign.Center)
    .linearGradient({ angle: 135, colors: [[goods.goodsTintStart, 0], [goods.goodsTintEnd, 1]] })
    .borderRadius(this.vs(8))
  }

  @Builder
  goodsRow(goods: TaobaoOrderGoodsItem) {
    Row() {
      this.goodsPic(goods)

      Column() {
        Text(goods.goodsTitle)
          .fontSize(this.vs(TAO_GOODS_TITLE_FONT))
          .fontColor(TAO_TEXT_MAIN)
          .maxLines(2)
          .lineHeight(this.vs(19))

        Text(goods.goodsSpec)
          .fontSize(this.vs(TAO_GOODS_SPEC_FONT))
          .fontColor(TAO_TEXT_LIGHT)
          .backgroundColor(TAO_PILL_BG)
          .borderRadius(this.vs(3))
          .padding({ left: this.vs(6), right: this.vs(6), top: this.vs(2), bottom: this.vs(2) })
          .margin({ top: this.vs(6) })
          .alignSelf(ItemAlign.Start)

        Row() {
          Text(goods.goodsPrice)
            .fontSize(this.vs(TAO_GOODS_PRICE_FONT))
            .fontWeight(FontWeight.Bold)
            .fontColor(TAO_TEXT_MAIN)

          Blank()

          Text(goods.goodsCount)
            .fontSize(this.vs(TAO_GOODS_COUNT_FONT))
            .fontColor(TAO_TEXT_SUB)
        }
        .width('100%')
        .margin({ top: this.vs(8) })
        .alignItems(VerticalAlign.Center)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: this.vs(10) })
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
    .margin({ top: this.vs(12) })
  }

  /** 店铺 + 商品卡 */
  @Builder
  goodsCard() {
    Column() {
      Row() {
        Column() {
          Text('猫')
            .fontSize(this.vs(15))
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
        }
        .width(this.vs(24))
        .height(this.vs(24))
        .justifyContent(FlexAlign.Center)
        .backgroundColor(TAO_ORANGE)
        .borderRadius(this.vs(6))

        Text('天猫超市 官方旗舰店')
          .fontSize(this.vs(TAO_GOODS_TITLE_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(TAO_TEXT_MAIN)
          .margin({ left: this.vs(8) })

        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(this.vs(12))
          .fontColor([TAO_TEXT_SUB])
          .margin({ left: this.vs(4) })

        Blank()

        Text('进店')
          .fontSize(this.vs(TAO_GOODS_SPEC_FONT))
          .fontColor(TAO_TEXT_SUB)
          .border({ width: this.vs(1), color: '#DDDDDD' })
          .borderRadius(this.vs(12))
          .padding({ left: this.vs(10), right: this.vs(10), top: this.vs(3), bottom: this.vs(3) })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      ForEach(TAO_GOODS_LIST, (goods: TaobaoOrderGoodsItem) => {
        this.goodsRow(goods)
      }, (goods: TaobaoOrderGoodsItem) => goods.goodsTitle)
    }
    .width('100%')
    .padding(this.vs(TAO_CARD_PAD))
    .backgroundColor(Color.White)
    .borderRadius(this.vs(TAO_CARD_RADIUS))
    .margin({ bottom: this.vs(TAO_CARD_GAP) })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  priceRow(price: TaobaoPriceRowItem) {
    Row() {
      Text(price.priceLabel)
        .fontSize(this.vs(TAO_PRICE_LABEL_FONT))
        .fontColor(TAO_TEXT_SUB)

      Blank()

      Text(price.priceValue)
        .fontSize(this.vs(price.priceEmphasis ? TAO_FINAL_FONT : TAO_PRICE_VALUE_FONT))
        .fontWeight(price.priceEmphasis ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(price.priceEmphasis ? TAO_PRICE_RED : TAO_TEXT_MAIN)
    }
    .width('100%')
    .height(this.vs(price.priceEmphasis ? 30 : 26))
    .alignItems(VerticalAlign.Center)
  }

  /** 金额明细卡 */
  @Builder
  priceCard() {
    Column() {
      ForEach(TAO_PRICE_ROWS, (price: TaobaoPriceRowItem) => {
        this.priceRow(price)
      }, (price: TaobaoPriceRowItem) => price.priceLabel)
    }
    .width('100%')
    .padding(this.vs(TAO_CARD_PAD))
    .backgroundColor(Color.White)
    .borderRadius(this.vs(TAO_CARD_RADIUS))
    .margin({ bottom: this.vs(TAO_CARD_GAP) })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  infoRow(info: TaobaoInfoRowItem) {
    Row() {
      Text(info.infoLabel)
        .fontSize(this.vs(TAO_INFO_LABEL_FONT))
        .fontColor(TAO_TEXT_LIGHT)

      Blank()

      Text(info.infoValue)
        .fontSize(this.vs(TAO_INFO_VALUE_FONT))
        .fontColor(TAO_TEXT_MAIN)
    }
    .width('100%')
    .height(this.vs(24))
    .alignItems(VerticalAlign.Center)
  }

  /** 订单信息卡 */
  @Builder
  orderInfoCard() {
    Column() {
      ForEach(TAO_INFO_ROWS, (info: TaobaoInfoRowItem) => {
        this.infoRow(info)
      }, (info: TaobaoInfoRowItem) => info.infoLabel)
    }
    .width('100%')
    .padding(this.vs(TAO_CARD_PAD))
    .backgroundColor(Color.White)
    .borderRadius(this.vs(TAO_CARD_RADIUS))
    .margin({ bottom: this.vs(TAO_CARD_GAP) })
    .alignItems(HorizontalAlign.Start)
  }

  /** 底部操作栏：咋联系卖家 / 查看物流 / 评价 */
  @Builder
  bottomActionBar() {
    Row({ space: this.vs(10) }) {
      Row({ space: this.vs(4) }) {
        SymbolGlyph($r('sys.symbol.headphones'))
          .fontSize(this.vs(14))
          .fontColor([TAO_TEXT_MAIN])

        Text('咋联系卖家')
          .fontSize(this.vs(TAO_ACTION_FONT))
          .fontColor(TAO_TEXT_MAIN)
      }
      .height(this.vs(34))
      .padding({ left: this.vs(14), right: this.vs(14) })
      .justifyContent(FlexAlign.Center)
      .border({ width: this.vs(1), color: '#DDDDDD' })
      .borderRadius(this.vs(17))

      Row({ space: this.vs(4) }) {
        SymbolGlyph($r('sys.symbol.map'))
          .fontSize(this.vs(14))
          .fontColor([TAO_TEXT_MAIN])

        Text('查看物流')
          .fontSize(this.vs(TAO_ACTION_FONT))
          .fontColor(TAO_TEXT_MAIN)
      }
      .height(this.vs(34))
      .padding({ left: this.vs(14), right: this.vs(14) })
      .justifyContent(FlexAlign.Center)
      .border({ width: this.vs(1), color: '#DDDDDD' })
      .borderRadius(this.vs(17))

      Blank()

      Row({ space: this.vs(4) }) {
        SymbolGlyph($r('sys.symbol.star'))
          .fontSize(this.vs(14))
          .fontColor([Color.White])

        Text('评价')
          .fontSize(this.vs(TAO_ACTION_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
      }
      .height(this.vs(34))
      .padding({ left: this.vs(16), right: this.vs(16) })
      .justifyContent(FlexAlign.Center)
      .linearGradient({ angle: 90, colors: [[TAO_HEADER_START, 0], [TAO_HEADER_END, 1]] })
      .borderRadius(this.vs(17))
    }
    .width('100%')
    .height(this.vs(TAO_BOTTOM_BAR_HEIGHT) + this.bottomInsetVp)
    .padding({ left: this.vs(14), right: this.vs(14), bottom: this.bottomInsetVp })
    .backgroundColor(Color.White)
    .alignItems(VerticalAlign.Center)
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          this.titleBar()
          this.statusStrip()
          this.addressCard()
        }
        .width('100%')
        .linearGradient({ angle: 180, colors: [[TAO_HEADER_START, 0], [TAO_HEADER_END, 1]] })

        Scroll() {
          Column() {
            this.goodsCard()
            this.priceCard()
            this.orderInfoCard()

            Row()
              .width('100%')
              .height(this.vs(16))
          }
          .width('100%')
          .padding({ left: this.vs(TAO_CARD_INSET), right: this.vs(TAO_CARD_INSET), top: this.vs(TAO_CARD_GAP) })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .backgroundColor(TAO_PAGE_BG)

        this.bottomActionBar()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(TAO_PAGE_BG)
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
