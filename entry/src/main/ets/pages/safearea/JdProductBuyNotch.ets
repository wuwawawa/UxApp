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
 * 反例：未避让安全区 / 京东商品购买键压挖孔（挖孔）
 *
 * 复刻对象：京东「商品详情」页 —— 白底商品大图（MacBook Air 实拍 + 左上「京东·百亿补贴」
 *   角标、悬浮返回/分享/更多圆钮）、标题「Apple/苹果 MacBook Air 13.6英寸 8+256GB 银色
 *   M3芯片」、「百亿补贴 已补贴¥3650」条、价格行 ¥7199（划线价¥10849、领券满1999减100）、
 *   优惠/服务/已选三行灰字条、用户评价卡（好评率97% + 标签 + 一条热评）、京东自营店铺卡，
 *   底部固定操作栏（客服/店铺/购物车 + 浅橙「加入购物车」+ 红色「立即购买」双联按钮）。
 *
 * 设计基准：以单屏折叠态窗口宽 459.6vp 为基准（真机 Pura X Max 双屏竖屏截图
 *   1828×2584px、密度 2.75 等比折算，页面所有尺寸按窗口宽度 / 459.6 等比换算）：
 *   商品图区高 234vp；标题 13vp；价格 21vp；底部操作栏高 33vp，左端客服/店铺/购物车
 *   三组图标（图标 12vp、文字 7.5vp），右端「加入购物车」x 95~274vp（浅橙底 #FFE7CC、
 *   深橙字）与「立即购买」x 274~452vp（#FF465D 红底白字）双联拼接、按钮高 30vp、
 *   距右 7vp（截图 y2330~2462 底栏、y2400 行采样量出）。
 *
 * 挖孔实测（Pura X Max，密度 2.75，hidumper DisplayManagerService BoundingRects）：
 *   单屏态        459.6×672vp   —— 挖孔圆 24vp，顶部正中（x 218~242vp，y 9.5~33.5vp）；
 *   双屏态竖屏    664.7×939.6vp —— 挖孔圆 26.2vp，右下角（距右 10.2vp、距底 15.3vp）；
 *   双屏态横屏    939.6×664.7vp —— 挖孔圆 26.2vp，右上角（距右 15.3vp、距顶 10.2vp）。
 *
 * 三态实测：
 *   单屏态        459.6×672vp   —— 底部操作栏贴窗口底边铺到 y 672vp，「立即购买」
 *                                 落在 x 274~452vp、y 626~656vp，被底部手势区
 *                                 小白条从中间压过（顶部挖孔在正中，不与按钮相交）；
 *   双屏态竖屏    664.7×939.6vp —— 操作栏放大后贴窗口底边，「立即购买」放大到
 *                                 x 396~654.5vp、y 886~929.6vp，右下角挖孔圆
 *                                 （x 628.3~654.5vp、y 898.1~924.3vp）把按钮右端
 *                                 整块穿透，「立即购买」末字被黑孔吃掉一角；
 *   双屏态横屏    939.6×664.7vp —— 操作栏贴底放大到全宽，「立即购买」在
 *                                 x 560~925vp，右上角挖孔圆（x 898~924vp、y 10~36vp）
 *                                 不与底栏相交，底部手势区仍从按钮中间压过。
 *
 * 问题表现：
 *   双屏竖屏展开态右下角的前置摄像头挖孔正好落在「立即购买」按钮右端，红色按钮被
 *   黑色圆孔削掉一角、末字「买」被盖住半截；单屏态与双屏横屏下操作栏同样贴着窗口
 *   底边铺开，导航条小白条从按钮中间横穿。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 缩放基准：单屏折叠态窗口宽度（1264px / 2.75） */
const JD_BASE_WIDTH: number = 459.6;

const JD_PAGE_BG: string = '#F4F5F7';
const JD_CARD_BG: string = '#FFFFFF';
const JD_TEXT_MAIN: string = '#262626';
const JD_TEXT_SUB: string = '#8C8C8C';
const JD_TEXT_LIGHT: string = '#B5B5B5';
const JD_RED: string = '#E93B3D';
const JD_BUY_RED: string = '#FF465D';
const JD_CART_BG: string = '#FFE7CC';
const JD_CART_TEXT: string = '#A65800';

/** 商品图区：高 234vp、悬浮圆钮 30vp、角标高 16vp */
const JD_GALLERY_HEIGHT: number = 234;
const JD_FLOAT_BTN: number = 30;
const JD_BADGE_HEIGHT: number = 16;
const JD_BADGE_FONT: number = 8.5;

/** 标题 13vp、补贴条、价格行 */
const JD_TITLE_FONT: number = 13;
const JD_SUBSIDY_FONT: number = 9.5;
const JD_PRICE_BIG: number = 21;
const JD_PRICE_SMALL: number = 9.5;
const JD_COUPON_FONT: number = 8.5;

/** 信息行：高 26vp、文字 10.5vp */
const JD_INFO_ROW_HEIGHT: number = 26;
const JD_INFO_FONT: number = 10.5;
const JD_INFO_LABEL_FONT: number = 9.5;

/** 评价卡 / 店铺卡 */
const JD_CMT_NAME_FONT: number = 9;
const JD_CMT_TEXT_FONT: number = 10.5;
const JD_TAG_FONT: number = 8.5;
const JD_SHOP_FONT: number = 12;

/** 底部操作栏：高 33vp、双联按钮高 30vp、距右 7vp */
const JD_BAR_HEIGHT: number = 33;
const JD_BAR_ICON: number = 12;
const JD_BAR_LABEL_FONT: number = 7.5;
const JD_BTN_HEIGHT: number = 30;
const JD_BTN_FONT: number = 12;
const JD_CART_BTN_WIDTH: number = 179;
const JD_BUY_BTN_WIDTH: number = 178;
const JD_BAR_RIGHT_INSET: number = 7;

/** 底部操作栏左侧功能项 */
interface JdBarEntry {
  barIcon: Resource;
  barLabel: string;
}

const JD_BAR_ENTRIES: JdBarEntry[] = [
  { barIcon: $r('sys.symbol.headphones'), barLabel: '客服' },
  { barIcon: $r('sys.symbol.house'), barLabel: '店铺' },
  { barIcon: $r('sys.symbol.cart'), barLabel: '购物车' }
];

/** 信息行 */
interface JdInfoRow {
  infoLabel: string;
  infoValue: string;
}

const JD_INFO_ROWS: JdInfoRow[] = [
  { infoLabel: '优惠', infoValue: '领券立减、Plus会员再补贴、白条免息' },
  { infoLabel: '服务', infoValue: '京东物流 · 7天无理由退换 · 晚发赔' },
  { infoLabel: '已选', infoValue: 'MacBook Air 13.6英寸，8+256GB，银色' }
];

/** 评价标签 */
const JD_REVIEW_TAGS: string[] = ['性价比高', '运行流畅', '正品保障', '轻薄便携'];

/** 商品详情页主体 */
@Component
export struct JdProductBuyNotchPage {
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

  /** 商品大图区：实拍图 + 角标 + 悬浮圆钮 */
  @Builder
  galleryArea() {
    Stack({ alignContent: Alignment.TopStart }) {
      Image($r('app.media.sa_jd_product'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Contain)

      Row() {
        Text('京东')
          .fontSize(this.vs(JD_BADGE_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)

        Text('百亿补贴')
          .fontSize(this.vs(JD_BADGE_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFD33D')
          .margin({ left: this.vs(3) })
      }
      .height(this.vs(JD_BADGE_HEIGHT))
      .padding({ left: this.vs(7), right: this.vs(7) })
      .backgroundColor('rgba(0,0,0,0.68)')
      .borderRadius(this.vs(JD_BADGE_HEIGHT / 2))
      .margin({ left: this.vs(8), top: this.vs(8) })

      Row() {
        Column() {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(this.vs(16))
            .fontColor(['#333333'])
            .onClick(() => {
              this.pageStack.pop();
            })
        }
        .width(this.vs(JD_FLOAT_BTN))
        .height(this.vs(JD_FLOAT_BTN))
        .justifyContent(FlexAlign.Center)
        .backgroundColor('rgba(255,255,255,0.85)')
        .borderRadius(this.vs(JD_FLOAT_BTN / 2))

        Blank()

        Column() {
          SymbolGlyph($r('sys.symbol.share'))
            .fontSize(this.vs(14))
            .fontColor(['#333333'])
        }
        .width(this.vs(JD_FLOAT_BTN))
        .height(this.vs(JD_FLOAT_BTN))
        .justifyContent(FlexAlign.Center)
        .backgroundColor('rgba(255,255,255,0.85)')
        .borderRadius(this.vs(JD_FLOAT_BTN / 2))

        Column() {
          SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
            .fontSize(this.vs(14))
            .fontColor(['#333333'])
        }
        .width(this.vs(JD_FLOAT_BTN))
        .height(this.vs(JD_FLOAT_BTN))
        .justifyContent(FlexAlign.Center)
        .backgroundColor('rgba(255,255,255,0.85)')
        .borderRadius(this.vs(JD_FLOAT_BTN / 2))
        .margin({ left: this.vs(6) })
      }
      .width('100%')
      .padding({ left: this.vs(8), right: this.vs(8), top: this.vs(8) })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(this.vs(JD_GALLERY_HEIGHT))
    .backgroundColor(JD_CARD_BG)
  }

  /** 标题 + 补贴 + 价格 */
  @Builder
  titlePriceBlock() {
    Column() {
      Text('Apple/苹果 MacBook Air 13.6英寸笔记本电脑 8+256GB 银色 M3芯片（国际版）')
        .fontSize(this.vs(JD_TITLE_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(JD_TEXT_MAIN)
        .lineHeight(this.vs(20))

      Row({ space: this.vs(6) }) {
        Text('百亿补贴')
          .fontSize(this.vs(JD_SUBSIDY_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .backgroundColor(JD_RED)
          .borderRadius(this.vs(2))
          .padding({ left: this.vs(4), right: this.vs(4), top: this.vs(1.5), bottom: this.vs(1.5) })

        Text('已补贴 ¥3650，到手价不高于官网')
          .fontSize(this.vs(JD_SUBSIDY_FONT))
          .fontColor(JD_RED)
      }
      .alignItems(VerticalAlign.Center)
      .margin({ top: this.vs(8) })

      Row() {
        Text('¥')
          .fontSize(this.vs(13))
          .fontWeight(FontWeight.Bold)
          .fontColor(JD_RED)

        Text('7199')
          .fontSize(this.vs(JD_PRICE_BIG))
          .fontWeight(FontWeight.Bold)
          .fontColor(JD_RED)

        Text('¥10849')
          .fontSize(this.vs(JD_PRICE_SMALL))
          .fontColor(JD_TEXT_LIGHT)
          .decoration({ type: TextDecorationType.LineThrough })
          .margin({ left: this.vs(6) })

        Blank()

        Text('领券满1999减100')
          .fontSize(this.vs(JD_COUPON_FONT))
          .fontColor(JD_RED)
          .border({ width: this.vs(0.5), color: JD_RED })
          .borderRadius(this.vs(2))
          .padding({ left: this.vs(4), right: this.vs(4), top: this.vs(1.5), bottom: this.vs(1.5) })
      }
      .width('100%')
      .alignItems(VerticalAlign.Bottom)
      .margin({ top: this.vs(10) })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: this.vs(12), right: this.vs(12), top: this.vs(12) })
    .backgroundColor(JD_CARD_BG)
  }

  @Builder
  infoRow(info: JdInfoRow) {
    Row() {
      Text(info.infoLabel)
        .fontSize(this.vs(JD_INFO_LABEL_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(JD_TEXT_MAIN)

      Text(info.infoValue)
        .fontSize(this.vs(JD_INFO_FONT))
        .fontColor(JD_TEXT_SUB)
        .maxLines(1)
        .layoutWeight(1)
        .margin({ left: this.vs(10) })

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(this.vs(10))
        .fontColor([JD_TEXT_LIGHT])
    }
    .width('100%')
    .height(this.vs(JD_INFO_ROW_HEIGHT))
    .alignItems(VerticalAlign.Center)
  }

  /** 信息三行卡 */
  @Builder
  infoCard() {
    Column() {
      ForEach(JD_INFO_ROWS, (info: JdInfoRow) => {
        this.infoRow(info)
      }, (info: JdInfoRow) => info.infoLabel)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: this.vs(12), right: this.vs(12), top: this.vs(6), bottom: this.vs(4) })
    .backgroundColor(JD_CARD_BG)
    .margin({ top: this.vs(8) })
  }

  /** 评价卡 */
  @Builder
  reviewCard() {
    Column() {
      Row() {
        Text('用户评价（999+）')
          .fontSize(this.vs(JD_CMT_TEXT_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(JD_TEXT_MAIN)

        Blank()

        Text('好评率 97%')
          .fontSize(this.vs(JD_CMT_NAME_FONT))
          .fontColor(JD_RED)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Row({ space: this.vs(6) }) {
        ForEach(JD_REVIEW_TAGS, (tag: string) => {
          Text(tag)
            .fontSize(this.vs(JD_TAG_FONT))
            .fontColor(JD_TEXT_SUB)
            .backgroundColor('#F5F5F5')
            .borderRadius(this.vs(2))
            .padding({ left: this.vs(5), right: this.vs(5), top: this.vs(2), bottom: this.vs(2) })
        }, (tag: string) => tag)
      }
      .alignItems(VerticalAlign.Center)
      .margin({ top: this.vs(8) })

      Row() {
        Column() {
          Text('j')
            .fontSize(this.vs(10))
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
        }
        .width(this.vs(20))
        .height(this.vs(20))
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#5B8DEF')
        .borderRadius(this.vs(10))

        Column() {
          Text('j***y')
            .fontSize(this.vs(JD_CMT_NAME_FONT))
            .fontColor(JD_TEXT_SUB)

          Text('M3芯片性能够用，日常办公非常流畅，重量也轻，续航比上一代明显更扎实。')
            .fontSize(this.vs(JD_CMT_TEXT_FONT))
            .fontColor(JD_TEXT_MAIN)
            .lineHeight(this.vs(15))
            .margin({ top: this.vs(4) })

          Row() {
            Text('2026-10-18')
              .fontSize(this.vs(JD_CMT_NAME_FONT))
              .fontColor(JD_TEXT_LIGHT)

            Blank()

            Row({ space: this.vs(3) }) {
              SymbolGlyph($r('sys.symbol.hand_thumbsup'))
                .fontSize(this.vs(10))
                .fontColor([JD_TEXT_LIGHT])

              Text('2145')
                .fontSize(this.vs(JD_CMT_NAME_FONT))
                .fontColor(JD_TEXT_LIGHT)
            }
            .alignItems(VerticalAlign.Center)
          }
          .width('100%')
          .margin({ top: this.vs(6) })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: this.vs(8) })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
      .margin({ top: this.vs(10) })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(this.vs(12))
    .backgroundColor(JD_CARD_BG)
    .margin({ top: this.vs(8) })
  }

  /** 店铺卡 */
  @Builder
  shopCard() {
    Row() {
      Text('京东自营')
        .fontSize(this.vs(JD_SHOP_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(JD_RED)

      Text('自营')
        .fontSize(this.vs(JD_TAG_FONT))
        .fontColor(Color.White)
        .backgroundColor(JD_RED)
        .borderRadius(this.vs(2))
        .padding({ left: this.vs(4), right: this.vs(4), top: this.vs(1.5), bottom: this.vs(1.5) })
        .margin({ left: this.vs(6) })

      Blank()

      Text('进店')
        .fontSize(this.vs(JD_TAG_FONT))
        .fontColor(JD_TEXT_MAIN)
        .border({ width: this.vs(0.5), color: '#CCCCCC' })
        .borderRadius(this.vs(11))
        .padding({ left: this.vs(12), right: this.vs(12), top: this.vs(4), bottom: this.vs(4) })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .padding(this.vs(12))
    .backgroundColor(JD_CARD_BG)
    .margin({ top: this.vs(8), bottom: this.vs(16) })
  }

  /** 底部操作栏：功能图标 + 加入购物车/立即购买双联按钮，贴窗口底边 */
  @Builder
  bottomActionBar() {
    Row() {
      ForEach(JD_BAR_ENTRIES, (entry: JdBarEntry) => {
        Column() {
          SymbolGlyph(entry.barIcon)
            .fontSize(this.vs(JD_BAR_ICON))
            .fontColor([JD_TEXT_MAIN])

          Text(entry.barLabel)
            .fontSize(this.vs(JD_BAR_LABEL_FONT))
            .fontColor(JD_TEXT_MAIN)
            .margin({ top: this.vs(2) })
        }
        .alignItems(HorizontalAlign.Center)
        .margin({ right: this.vs(16) })
      }, (entry: JdBarEntry) => entry.barLabel)

      Blank()

      Row() {
        Text('加入购物车')
          .fontSize(this.vs(JD_BTN_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(JD_CART_TEXT)
          .width(this.vs(JD_CART_BTN_WIDTH))
          .height(this.vs(JD_BTN_HEIGHT))
          .textAlign(TextAlign.Center)
          .backgroundColor(JD_CART_BG)
          .borderRadius({ topLeft: this.vs(JD_BTN_HEIGHT / 2), bottomLeft: this.vs(JD_BTN_HEIGHT / 2) })

        Text('立即购买')
          .fontSize(this.vs(JD_BTN_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .width(this.vs(JD_BUY_BTN_WIDTH))
          .height(this.vs(JD_BTN_HEIGHT))
          .textAlign(TextAlign.Center)
          .backgroundColor(JD_BUY_RED)
          .borderRadius({ topRight: this.vs(JD_BTN_HEIGHT / 2), bottomRight: this.vs(JD_BTN_HEIGHT / 2) })
      }
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(this.vs(JD_BAR_HEIGHT) + 16)
    .padding({ left: this.vs(14), right: this.vs(JD_BAR_RIGHT_INSET) })
    .backgroundColor('#F7F7F7')
    .alignItems(VerticalAlign.Center)
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column() {
            this.galleryArea()
            this.titlePriceBlock()
            this.infoCard()
            this.reviewCard()
            this.shopCard()
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .backgroundColor(JD_PAGE_BG)

        this.bottomActionBar()
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
