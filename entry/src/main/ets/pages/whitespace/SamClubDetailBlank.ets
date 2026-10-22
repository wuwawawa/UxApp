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
 * 反例：留白过多 / 山姆商品详情大片留白
 *
 * 复刻对象：山姆会员商店 App 商品详情页，双屏态。顶部整窗宽的蓝色渐变头：
 *   左返回箭头、居中标题「商品详情」、右侧分享与购物车图标；头图下方的全部内容
 *   ——白色商品大图占位（居中山姆礼盒图标 + 角标「会员专享」）、红色现价 ¥89.9
 *   与划线卖场价 ¥109、金色「会员价 ¥79.9」标签、促销标签行（满199减20 /
 *   限时直降20 / 极速达）、商品标题「Member's Mark 澳洲谷饲牛排 1.5kg」与副标题、
 *   参数表（产地 / 规格 / 保质期 / 储存方式 / 商品编号）、数量选择行、
 *   门店配送行（广州天河店 · 极速达）、用户评价区，以及底部「客服 / 购物车 /
 *   加入购物车 / 立即购买」操作栏——全部固定在 459.6vp 的单屏内容列里贴左排布，
 *   右侧直到屏幕边缘全部是页面底色。
 *
 * 设计基准：以单屏折叠态 459.6×672vp 为基准宽度 1:1 还原移动端排版。
 *   所有尺寸 / 字号按 窗口宽度 / 459.6 换算（sceneScale）后把倍率钳制在 1.0
 *   ——宽窗口下内容列完全不长大，右侧留白随窗口宽度线性增大。
 *   状态栏占位 36vp；头部高 88vp（蓝渐变 #0068B7 → #2E8FD8）；
 *   商品图高 340vp；现价数字 26vp、¥ 字 14vp；参数行高 44vp、字 14vp；
 *   数量行高 48vp；底部操作栏高 64vp、按钮字 15vp。
 *
 * 三态实测（内容列宽 = 459.6 × sceneScale = 恒定 459.6vp，贴窗口左缘）：
 *   单屏态      459.6×672vp   —— 内容列与窗口同宽，无额外留白（正常形态）；
 *   双屏态竖屏  664.7×939.6vp —— 右侧空出 205.1vp，约占宽度的 31%，
 *                                连底部「立即购买」按钮都够不到右半屏；
 *   双屏态横屏  939.6×664.7vp —— 右侧空出 480.0vp，约占宽度的 51%，
 *                                商品图与信息全挤在左侧，右侧像没加载完。
 *
 * 问题表现：
 *   从商品大图、价格、参数表到底部操作栏，整条内容带都锁死在手机宽度里；
 *   展开双屏后窗口宽了一倍，内容却一个像素都不挪，
 *   右侧整块空白从头部下方一直铺到屏幕右下角，横屏时尤其刺眼。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 配色：浅灰页面、白卡片、近黑正文、灰副标题、山姆蓝、红现价、金会员价 */
const WSSAM_PAGE_BG: string = '#F4F5F6';
const WSSAM_CARD_BG: string = '#FFFFFF';
const WSSAM_TEXT_MAIN: string = '#1A1A1A';
const WSSAM_TEXT_SUB: string = '#8A8F99';
const WSSAM_BLUE_MAIN: string = '#0068B7';
const WSSAM_BLUE_TOP: string = '#0068B7';
const WSSAM_BLUE_BOTTOM: string = '#2E8FD8';
const WSSAM_BLUE_LIGHT_BG: string = '#EDF5FE';
const WSSAM_PRICE_RED: string = '#E1251B';
const WSSAM_MEMBER_GOLD: string = '#B9833B';
const WSSAM_MEMBER_BG: string = '#FBF3E6';
const WSSAM_DIVIDER: string = '#EEEEF0';
const WSSAM_STRIKE_COLOR: string = '#A9A9A9';

/** 基准：单屏折叠态窗口宽 459.6vp；宽窗口下缩放倍率钳制在 1.0（完全不长个） */
const WSSAM_BASE_WIDTH: number = 459.6;
const WSSAM_MAX_SCALE: number = 1.0;

/** 头部：状态栏占位 36vp + 内容行 52vp = 88vp */
const WSSAM_STATUS_PAD: number = 36;
const WSSAM_HEADER_HEIGHT: number = 88;
const WSSAM_HEADER_PAD_SIDE: number = 14; const WSSAM_HEADER_ICON: number = 22;
const WSSAM_HEADER_ICON_GAP: number = 18; const WSSAM_TITLE_FONT: number = 17;

/** 商品图：高 340vp、角标「会员专享」 */
const WSSAM_HERO_HEIGHT: number = 340;
const WSSAM_HERO_ICON: number = 84; const WSSAM_HERO_ICON_FONT: number = 14;
const WSSAM_VIP_BADGE_FONT: number = 12; const WSSAM_VIP_BADGE_PAD: number = 8;

/** 价格块：现价数字 26vp、¥ 14vp、划线价 13vp、会员标签行 */
const WSSAM_PRICE_NUM_FONT: number = 26; const WSSAM_PRICE_YEN_FONT: number = 14;
const WSSAM_PRICE_YEN_LIFT: number = 7; const WSSAM_STRIKE_FONT: number = 13;
const WSSAM_STRIKE_LIFT: number = 4; const WSSAM_STRIKE_GAP: number = 8;
const WSSAM_MEMBER_FONT: number = 13; const WSSAM_MEMBER_PAD_H: number = 10;
const WSSAM_MEMBER_PAD_V: number = 4; const WSSAM_MEMBER_RADIUS: number = 12;
const WSSAM_PROMO_FONT: number = 11; const WSSAM_PROMO_PAD_H: number = 8;
const WSSAM_PROMO_PAD_V: number = 3; const WSSAM_PROMO_RADIUS: number = 9;
const WSSAM_PROMO_GAP: number = 6;

/** 标题块 / 参数表 / 数量行 / 配送行（标题字号复用头部 WSSAM_TITLE_FONT） */
const WSSAM_SUB_FONT: number = 13;
const WSSAM_SECTION_PAD: number = 14;
const WSSAM_ROW_HEIGHT: number = 44; const WSSAM_SPEC_FONT: number = 14;
const WSSAM_QTY_FONT: number = 14; const WSSAM_QTY_ROW_HEIGHT: number = 48;
const WSSAM_QTY_BTN: number = 26; const WSSAM_QTY_NUM_W: number = 40;
const WSSAM_DELIVERY_FONT: number = 13;

/** 评价区 */
const WSSAM_RATE_FONT: number = 15;
const WSSAM_CMT_NAME_FONT: number = 13; const WSSAM_CMT_FONT: number = 13;
const WSSAM_CMT_LINE: number = 20; const WSSAM_AVATAR_SIZE: number = 32;

/** 底部操作栏：高 64vp */
const WSSAM_BAR_HEIGHT: number = 64; const WSSAM_BAR_PAD_SIDE: number = 12;
const WSSAM_BAR_ICON: number = 20; const WSSAM_BAR_LABEL_FONT: number = 10;
const WSSAM_BAR_GAP: number = 8; const WSSAM_BTN_CART_W: number = 118;
const WSSAM_BTN_H: number = 42; const WSSAM_BTN_FONT: number = 15;
const WSSAM_BTN_RADIUS: number = 21; const WSSAM_BADGE_SIZE: number = 16;
const WSSAM_BADGE_FONT: number = 10;

/** 促销标签 */
interface SamPromoTag {
  promoKey: string;
  promoLabel: string;
  promoBg: string;
}

/** 参数表行 */
interface SamSpecRow {
  specKey: string;
  specLabel: string;
  specValue: string;
}

const WSSAM_PROMOS: SamPromoTag[] = [
  { promoKey: 'sam-promo-cut', promoLabel: '满199减20', promoBg: WSSAM_BLUE_LIGHT_BG },
  { promoKey: 'sam-promo-drop', promoLabel: '限时直降20', promoBg: '#FDECEA' },
  { promoKey: 'sam-promo-fast', promoLabel: '极速达', promoBg: '#E8F7EE' }
];

const WSSAM_SPECS: SamSpecRow[] = [
  { specKey: 'sam-spec-origin', specLabel: '产地', specValue: '澳大利亚' },
  { specKey: 'sam-spec-size', specLabel: '规格', specValue: '1.5kg / 袋' },
  { specKey: 'sam-spec-shelf', specLabel: '保质期', specValue: '12个月' },
  { specKey: 'sam-spec-store', specLabel: '储存方式', specValue: '-18℃以下冷冻保存' },
  { specKey: 'sam-spec-code', specLabel: '商品编号', specValue: '6944382910' }
];

/** 评价区口碑标签 */
const WSSAM_RATE_TAGS: string[] = ['新鲜', '包装完好', '物流快', '回购率高'];

@Component
export struct SamClubDetailBlankPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽度（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = 939.6;

  /** 窗口高度（vp），随折叠 / 旋转实时更新 */
  @State winHeightVp: number = 664.7;

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

  /** 整页缩放比：窗口宽度 / 单屏基准宽度（459.6vp），
   *  放大倍率钳制在 1.0 —— 宽窗口下内容列完全不长个（留白反例根源） */
  private sceneScale(): number {
    if (this.winWidthVp <= 0) {
      return 1;
    }
    return Math.min(this.winWidthVp / WSSAM_BASE_WIDTH, WSSAM_MAX_SCALE);
  }

  /** 把基准宽度下的设计值换算到当前窗口 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  // ------------------------------------------------------------------
  // 顶部：整窗宽蓝色渐变头（返回 + 标题 + 分享 / 购物车）
  // ------------------------------------------------------------------

  @Builder
  headerBand() {
    Stack({ alignContent: Alignment.Center }) {
      Text('商品详情')
        .fontSize(this.vs(WSSAM_TITLE_FONT)).fontWeight(FontWeight.Bold)
        .fontColor(Color.White).maxLines(1)

      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(this.vs(WSSAM_HEADER_ICON)).fontColor([Color.White])
          .width(this.vs(44)).height(this.vs(44))
          .onClick(() => {
            this.pageStack.pop();
          })

        Blank()

        Row({ space: this.vs(WSSAM_HEADER_ICON_GAP) }) {
          SymbolGlyph($r('sys.symbol.arrow_right_up_and_square'))
            .fontSize(this.vs(WSSAM_HEADER_ICON)).fontColor([Color.White])

          SymbolGlyph($r('sys.symbol.cart'))
            .fontSize(this.vs(WSSAM_HEADER_ICON)).fontColor([Color.White])
        }
        .alignItems(VerticalAlign.Center)
      }
      .width('100%').height('100%')
      .padding({ left: this.vs(WSSAM_HEADER_PAD_SIDE), right: this.vs(WSSAM_HEADER_PAD_SIDE) })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%').height(this.vs(WSSAM_HEADER_HEIGHT))
    .linearGradient({ angle: 180, colors: [[WSSAM_BLUE_TOP, 0.0], [WSSAM_BLUE_BOTTOM, 1.0]] })
    .padding({ top: this.vs(WSSAM_STATUS_PAD) })
  }

  // ------------------------------------------------------------------
  // 商品大图占位
  // ------------------------------------------------------------------

  @Builder
  productHero() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column({ space: this.vs(8) }) {
        SymbolGlyph($r('sys.symbol.gift_fill'))
          .fontSize(this.vs(WSSAM_HERO_ICON)).fontColor([Color.White])

        Text("Member's Mark")
          .fontSize(this.vs(WSSAM_HERO_ICON_FONT)).fontColor(Color.White)
          .opacity(0.85).maxLines(1)
      }
      .width('100%').height('100%')
      .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)

      Text('会员专享')
        .fontSize(this.vs(WSSAM_VIP_BADGE_FONT)).fontColor(Color.White).maxLines(1)
        .padding({ left: this.vs(WSSAM_VIP_BADGE_PAD), right: this.vs(WSSAM_VIP_BADGE_PAD), top: this.vs(4), bottom: this.vs(4) })
        .backgroundColor('#33FFFFFF').borderRadius(this.vs(11))
        .margin(this.vs(WSSAM_VIP_BADGE_PAD))
    }
    .width('100%').height(this.vs(WSSAM_HERO_HEIGHT))
    .linearGradient({ angle: 135, colors: [['#2E7FBB', 0.0], ['#74B6E3', 1.0]] })
  }

  // ------------------------------------------------------------------
  // 价格块：现价 + 划线价 + 会员价标签 + 促销标签
  // ------------------------------------------------------------------

  @Builder
  priceRow() {
    Column({ space: this.vs(8) }) {
      Row() {
        Text('¥')
          .fontSize(this.vs(WSSAM_PRICE_YEN_FONT)).lineHeight(this.vs(20))
          .fontColor(WSSAM_PRICE_RED).maxLines(1)
          .margin({ bottom: this.vs(WSSAM_PRICE_YEN_LIFT) })

        Text('89.9')
          .fontSize(this.vs(WSSAM_PRICE_NUM_FONT)).lineHeight(this.vs(34))
          .fontWeight(FontWeight.Bold).fontColor(WSSAM_PRICE_RED).maxLines(1)

        Text('卖场价¥109')
          .fontSize(this.vs(WSSAM_STRIKE_FONT)).lineHeight(this.vs(18))
          .fontColor(WSSAM_STRIKE_COLOR).maxLines(1)
          .decoration({ type: TextDecorationType.LineThrough, color: WSSAM_STRIKE_COLOR })
          .margin({ left: this.vs(WSSAM_STRIKE_GAP), bottom: this.vs(WSSAM_STRIKE_LIFT) })
      }
      .width('100%').alignItems(VerticalAlign.Bottom)

      Row() {
        Text('会员价 ¥79.9（含税）')
          .fontSize(this.vs(WSSAM_MEMBER_FONT)).fontWeight(FontWeight.Medium)
          .fontColor(WSSAM_MEMBER_GOLD).maxLines(1)
          .padding({ left: this.vs(WSSAM_MEMBER_PAD_H), right: this.vs(WSSAM_MEMBER_PAD_H), top: this.vs(WSSAM_MEMBER_PAD_V), bottom: this.vs(WSSAM_MEMBER_PAD_V) })
          .backgroundColor(WSSAM_MEMBER_BG).borderRadius(this.vs(WSSAM_MEMBER_RADIUS))
      }
      .width('100%').alignItems(VerticalAlign.Center)
    }
    .width('100%').alignItems(HorizontalAlign.Start)
  }

  @Builder
  promoRow() {
    Row({ space: this.vs(WSSAM_PROMO_GAP) }) {
      ForEach(WSSAM_PROMOS, (promo: SamPromoTag) => {
        Text(promo.promoLabel)
          .fontSize(this.vs(WSSAM_PROMO_FONT)).fontColor(WSSAM_BLUE_MAIN).maxLines(1)
          .padding({ left: this.vs(WSSAM_PROMO_PAD_H), right: this.vs(WSSAM_PROMO_PAD_H), top: this.vs(WSSAM_PROMO_PAD_V), bottom: this.vs(WSSAM_PROMO_PAD_V) })
          .backgroundColor(promo.promoBg).borderRadius(this.vs(WSSAM_PROMO_RADIUS))
      }, (promo: SamPromoTag) => promo.promoKey)
    }
    .width('100%').alignItems(VerticalAlign.Center)
    .margin({ top: this.vs(10) })
  }

  // ------------------------------------------------------------------
  // 标题块 / 参数表 / 数量行 / 配送行
  // ------------------------------------------------------------------

  @Builder
  titleBlock() {
    Column({ space: this.vs(6) }) {
      Text("Member's Mark 澳洲谷饲牛排 1.5kg 原切整块")
        .fontSize(this.vs(WSSAM_TITLE_FONT)).fontWeight(FontWeight.Medium)
        .fontColor(WSSAM_TEXT_MAIN).maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis }).lineHeight(this.vs(24))

      Text('谷饲300天 · 原切不拼接 · 顺丰冷链直达')
        .fontSize(this.vs(WSSAM_SUB_FONT)).fontColor(WSSAM_TEXT_SUB).maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%').alignItems(HorizontalAlign.Start)
  }

  @Builder
  specRow(row: SamSpecRow, showDivider: boolean) {
    Column() {
      Row() {
        Text(row.specLabel)
          .fontSize(this.vs(WSSAM_SPEC_FONT)).fontColor(WSSAM_TEXT_SUB).maxLines(1)

        Blank()

        Text(row.specValue)
          .fontSize(this.vs(WSSAM_SPEC_FONT)).fontColor(WSSAM_TEXT_MAIN).maxLines(1)
      }
      .width('100%').height(this.vs(WSSAM_ROW_HEIGHT))
      .alignItems(VerticalAlign.Center)

      if (showDivider) {
        Row()
          .width('100%').height(this.vs(0.5))
          .backgroundColor(WSSAM_DIVIDER)
      }
    }
    .width('100%').alignItems(HorizontalAlign.Start)
  }

  @Builder
  specSection() {
    Column() {
      ForEach(WSSAM_SPECS, (row: SamSpecRow) => {
        this.specRow(row, row.specKey !== 'sam-spec-code')
      }, (row: SamSpecRow) => row.specKey)
    }
    .width('100%').alignItems(HorizontalAlign.Start)
    .padding(this.vs(WSSAM_SECTION_PAD)).backgroundColor(WSSAM_CARD_BG)
  }

  @Builder
  quantityRow() {
    Row() {
      Text('数量')
        .fontSize(this.vs(WSSAM_QTY_FONT)).fontColor(WSSAM_TEXT_MAIN).maxLines(1)

      Blank()

      Text('－')
        .fontSize(this.vs(WSSAM_QTY_FONT)).fontColor(WSSAM_TEXT_SUB)
        .width(this.vs(WSSAM_QTY_BTN)).height(this.vs(WSSAM_QTY_BTN))
        .textAlign(TextAlign.Center).backgroundColor(WSSAM_PAGE_BG).borderRadius(this.vs(4))

      Text('1')
        .fontSize(this.vs(WSSAM_QTY_FONT)).fontColor(WSSAM_TEXT_MAIN)
        .width(this.vs(WSSAM_QTY_NUM_W)).height(this.vs(WSSAM_QTY_BTN))
        .textAlign(TextAlign.Center).maxLines(1)

      Text('＋')
        .fontSize(this.vs(WSSAM_QTY_FONT)).fontColor(WSSAM_BLUE_MAIN)
        .width(this.vs(WSSAM_QTY_BTN)).height(this.vs(WSSAM_QTY_BTN))
        .textAlign(TextAlign.Center).backgroundColor(WSSAM_BLUE_LIGHT_BG).borderRadius(this.vs(4))
    }
    .width('100%').height(this.vs(WSSAM_QTY_ROW_HEIGHT))
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  storeRow() {
    Row({ space: this.vs(6) }) {
      SymbolGlyph($r('sys.symbol.pin'))
        .fontSize(this.vs(14)).fontColor([WSSAM_BLUE_MAIN])

      Text('广州天河店 · 极速达 今日 18:00 前送达')
        .fontSize(this.vs(WSSAM_DELIVERY_FONT)).fontColor(WSSAM_TEXT_MAIN).maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis }).layoutWeight(1)

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(this.vs(14)).fontColor([WSSAM_TEXT_SUB])
    }
    .width('100%').height(this.vs(WSSAM_ROW_HEIGHT))
    .alignItems(VerticalAlign.Center)
  }

  // ------------------------------------------------------------------
  // 评价区
  // ------------------------------------------------------------------

  @Builder
  reviewSection() {
    Column({ space: this.vs(10) }) {
      Row() {
        Text('用户评价')
          .fontSize(this.vs(WSSAM_RATE_FONT)).fontWeight(FontWeight.Bold)
          .fontColor(WSSAM_TEXT_MAIN).maxLines(1)

        Text('（2.3万）')
          .fontSize(this.vs(WSSAM_SUB_FONT)).fontColor(WSSAM_TEXT_SUB).maxLines(1)

        Blank()

        Text('好评率 98%')
          .fontSize(this.vs(WSSAM_RATE_FONT)).fontWeight(FontWeight.Bold)
          .fontColor(WSSAM_PRICE_RED).maxLines(1)
      }
      .width('100%').alignItems(VerticalAlign.Bottom)

      Row({ space: this.vs(WSSAM_PROMO_GAP) }) {
        ForEach(WSSAM_RATE_TAGS, (rateTag: string) => {
          Text(rateTag)
            .fontSize(this.vs(WSSAM_PROMO_FONT)).fontColor(WSSAM_TEXT_SUB).maxLines(1)
            .padding({ left: this.vs(WSSAM_PROMO_PAD_H), right: this.vs(WSSAM_PROMO_PAD_H), top: this.vs(WSSAM_PROMO_PAD_V), bottom: this.vs(WSSAM_PROMO_PAD_V) })
            .backgroundColor(WSSAM_PAGE_BG).borderRadius(this.vs(WSSAM_PROMO_RADIUS))
        }, (rateTag: string) => 'sam-rate-' + rateTag)
      }
      .width('100%').alignItems(VerticalAlign.Center)

      Row({ space: this.vs(10) }) {
        Stack({ alignContent: Alignment.Center }) {
          SymbolGlyph($r('sys.symbol.person'))
            .fontSize(this.vs(16)).fontColor([Color.White])
        }
        .width(this.vs(WSSAM_AVATAR_SIZE)).height(this.vs(WSSAM_AVATAR_SIZE))
        .linearGradient({ angle: 135, colors: [['#5A8FCB', 0.0], ['#2E5F94', 1.0]] })
        .borderRadius(this.vs(WSSAM_AVATAR_SIZE / 2))

        Column({ space: this.vs(4) }) {
          Text('山姆达人_Momo')
            .fontSize(this.vs(WSSAM_CMT_NAME_FONT)).fontWeight(FontWeight.Medium)
            .fontColor(WSSAM_TEXT_MAIN).maxLines(1)

          Text('谷饲的就是香，煎五分熟刚刚好，家里娃抢着吃。回购第三次了，冷链到家还是硬的。')
            .fontSize(this.vs(WSSAM_CMT_FONT)).lineHeight(this.vs(WSSAM_CMT_LINE))
            .fontColor(WSSAM_TEXT_MAIN).maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(HorizontalAlign.Start).layoutWeight(1)
      }
      .width('100%').alignItems(VerticalAlign.Top)
    }
    .width('100%').alignItems(HorizontalAlign.Start)
    .padding(this.vs(WSSAM_SECTION_PAD))
    .backgroundColor(WSSAM_CARD_BG)
  }

  // ------------------------------------------------------------------
  // 底部操作栏：客服 / 购物车 + 加入购物车 + 立即购买
  // ------------------------------------------------------------------

  @Builder
  serviceCell(symbolRes: Resource, label: string) {
    Column({ space: this.vs(2) }) {
      SymbolGlyph(symbolRes)
        .fontSize(this.vs(WSSAM_BAR_ICON)).fontColor([WSSAM_TEXT_MAIN])

      Text(label)
        .fontSize(this.vs(WSSAM_BAR_LABEL_FONT)).fontColor(WSSAM_TEXT_SUB).maxLines(1)
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  bottomBar() {
    Row({ space: this.vs(WSSAM_BAR_GAP) }) {
      this.serviceCell($r('sys.symbol.headphones'), '客服')

      Stack({ alignContent: Alignment.TopEnd }) {
        this.serviceCell($r('sys.symbol.cart'), '购物车')

        Text('2')
          .fontSize(this.vs(WSSAM_BADGE_FONT)).fontColor(Color.White).maxLines(1)
          .width(this.vs(WSSAM_BADGE_SIZE)).height(this.vs(WSSAM_BADGE_SIZE))
          .textAlign(TextAlign.Center).backgroundColor(WSSAM_PRICE_RED)
          .borderRadius(this.vs(WSSAM_BADGE_SIZE / 2))
          .offset({ x: this.vs(4), y: -this.vs(4) })
      }

      Text('加入购物车')
        .fontSize(this.vs(WSSAM_BTN_FONT)).fontColor(WSSAM_BLUE_MAIN).maxLines(1)
        .width(this.vs(WSSAM_BTN_CART_W)).height(this.vs(WSSAM_BTN_H))
        .textAlign(TextAlign.Center).backgroundColor(WSSAM_BLUE_LIGHT_BG)
        .borderRadius(this.vs(WSSAM_BTN_RADIUS))

      Text('立即购买')
        .fontSize(this.vs(WSSAM_BTN_FONT)).fontWeight(FontWeight.Medium)
        .fontColor(Color.White).maxLines(1).layoutWeight(1)
        .height(this.vs(WSSAM_BTN_H)).textAlign(TextAlign.Center)
        .linearGradient({ angle: 90, colors: [[WSSAM_BLUE_TOP, 0.0], [WSSAM_BLUE_BOTTOM, 1.0]] })
        .borderRadius(this.vs(WSSAM_BTN_RADIUS))
    }
    .width('100%').height(this.vs(WSSAM_BAR_HEIGHT))
    .padding({ left: this.vs(WSSAM_BAR_PAD_SIDE), right: this.vs(WSSAM_BAR_PAD_SIDE) })
    .backgroundColor(WSSAM_CARD_BG).alignItems(VerticalAlign.Center)
  }

  // ------------------------------------------------------------------
  // 内容列：固定基准宽度、贴窗口左缘，右侧留白
  // ------------------------------------------------------------------

  @Builder
  contentStage() {
    Row() {
      Column() {
        Scroll() {
          Column({ space: this.vs(10) }) {
            this.productHero()

            Column({ space: this.vs(8) }) {
              this.priceRow()

              this.promoRow()
            }
            .width('100%').alignItems(HorizontalAlign.Start)
            .padding(this.vs(WSSAM_SECTION_PAD))
            .backgroundColor(WSSAM_CARD_BG)

            Column({ space: this.vs(4) }) {
              this.titleBlock()

              this.quantityRow()

              this.storeRow()
            }
            .width('100%').alignItems(HorizontalAlign.Start)
            .padding(this.vs(WSSAM_SECTION_PAD))
            .backgroundColor(WSSAM_CARD_BG)

            this.reviewSection()

            this.specSection()
          }
          .width('100%').alignItems(HorizontalAlign.Start)
        }
        .width('100%').layoutWeight(1)
        .scrollBar(BarState.Off).edgeEffect(EdgeEffect.None)
        .align(Alignment.Start)

        this.bottomBar()
      }
      .width(this.vs(WSSAM_BASE_WIDTH)).height('100%')
      .backgroundColor(WSSAM_PAGE_BG).alignItems(HorizontalAlign.Start)
    }
    .width('100%').layoutWeight(1)
    .alignItems(VerticalAlign.Top)
    .backgroundColor(WSSAM_PAGE_BG)
  }

  build() {
    NavDestination() {
      Column() {
        this.headerBand()

        this.contentStage()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(WSSAM_PAGE_BG)
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
