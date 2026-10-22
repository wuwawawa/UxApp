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
 * 反例：留白过多 / 苏宁首页右侧留白
 *
 * 复刻对象：苏宁易购 App 首页，双屏横屏。顶部整窗宽的黄色渐变头：左侧定位「广州」、
 *   中间白色圆角搜索框「大家电以旧换新至高补20%」、右侧消息图标；头图下方是
 *   橙红色「818发烧节」横幅、两排五行分类宫格（苏宁超市 / 大家电 / 手机数码 /
 *   电脑办公 / 生活缴费 / 充话费 / 附近门店 / 领券中心 / 以旧换新 / 会员专区）、
 *   「大聚惠」楼层（美的空调 / 海尔冰箱 / 格力挂机 三张爆款卡）、
 *   「为你推荐」楼层（iPhone 17 / 小米平板 / 海信电视 / 联想拯救者 四张大卡）。
 *   这些楼层全部固定在 459.6vp 的单屏内容列里贴左排布，右侧只剩页面底色，
 *   横屏时右半屏空无一物。
 *
 * 设计基准：以单屏折叠态 459.6×672vp 为基准宽度 1:1 还原移动端排版。
 *   所有尺寸 / 字号按 窗口宽度 / 459.6 换算（sceneScale）后把倍率钳制在 1.04
 *   ——宽窗口下内容列只放大 4%，右侧留白随窗口宽度线性增大。
 *   状态栏占位 36vp；头部高 92vp（黄渐变 #FFAA00 → #FFD34E）；
 *   搜索框高 34vp、提示字 13vp；横幅高 86vp、主字 18vp；
 *   分类宫格图标 44vp 圆、字 12vp；大聚惠卡封面高 92vp；
 *   推荐卡图 110×110vp、主字 14vp、价格数字 18vp。
 *
 * 三态实测（内容列宽 = 459.6 × sceneScale，右缘之外全是页面底色的空白）：
 *   单屏态      459.6×672vp   —— 内容列与窗口同宽，无额外留白（正常形态）；
 *   双屏态竖屏  664.7×939.6vp —— 内容列 478.0vp，右侧空出 186.7vp，约占宽度的 28%；
 *   双屏态横屏  939.6×664.7vp —— 内容列 478.0vp，右侧空出 461.6vp，约占宽度的 49%，
 *                                首页楼层固定窄宽，横屏右半屏空无一物。
 *
 * 问题表现：
 *   横幅、分类宫格、大聚惠、为你推荐等楼层全部锁死在一条手机宽度里贴左排；
 *   窗口展开后楼层不重排、不分栏，右半屏从横幅底边到屏幕底边都是空页面底色；
 *   只有顶部黄色头图横贯整窗，把下面右侧的大片留白衬得格外显眼。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 配色：浅灰页面、白卡片、近黑正文、灰副标题、苏宁黄、红价格 */
const WSSUN_PAGE_BG: string = '#F4F4F5';
const WSSUN_CARD_BG: string = '#FFFFFF';
const WSSUN_TEXT_MAIN: string = '#1F1F26';
const WSSUN_TEXT_SUB: string = '#8E8E99';
const WSSUN_YELLOW_TOP: string = '#FFAA00';
const WSSUN_YELLOW_BOTTOM: string = '#FFD34E';
const WSSUN_PRICE_RED: string = '#F20C00';
const WSSUN_STRIKE_COLOR: string = '#A9A9A9';
const WSSUN_SEARCH_HINT: string = '#B9B9C4';
const WSSUN_JUHUI_TAG_BG: string = '#FFF1E6';
const WSSUN_JUHUI_TAG_TEXT: string = '#FF6A00';
const WSSUN_BANNER_TOP: string = '#FF4E1F';
const WSSUN_BANNER_BOTTOM: string = '#FF9A3D';

/** 基准：单屏折叠态窗口宽 459.6vp；宽窗口下缩放倍率钳制在 1.04 */
const WSSUN_BASE_WIDTH: number = 459.6;
const WSSUN_MAX_SCALE: number = 1.04;

/** 头部：状态栏占位 36vp + 内容行 56vp = 92vp */
const WSSUN_STATUS_PAD: number = 36;
const WSSUN_HEADER_HEIGHT: number = 92;
const WSSUN_HEADER_PAD_SIDE: number = 14; const WSSUN_HEADER_GAP: number = 10;
const WSSUN_LOCATION_FONT: number = 12; const WSSUN_LOCATION_ICON: number = 14;
const WSSUN_SEARCH_PILL_HEIGHT: number = 34; const WSSUN_SEARCH_PILL_RADIUS: number = 17;
const WSSUN_SEARCH_PILL_PAD: number = 12; const WSSUN_SEARCH_HINT_FONT: number = 13;
const WSSUN_SEARCH_ICON: number = 16; const WSSUN_MESSAGE_ICON: number = 22;

/** 横幅：高 86vp、圆角 10vp */
const WSSUN_BANNER_HEIGHT: number = 86; const WSSUN_BANNER_RADIUS: number = 10;
const WSSUN_BANNER_TITLE_FONT: number = 18; const WSSUN_BANNER_SUB_FONT: number = 12;
const WSSUN_BANNER_PAD_SIDE: number = 16; const WSSUN_BANNER_ICON: number = 36;
const WSSUN_BANNER_TAG_PAD: number = 6;

/** 分类宫格：图标圆 44vp、字 12vp、两排之间 14vp、与横幅间距 12vp */
const WSSUN_CAT_ICON_BG: number = 44; const WSSUN_CAT_ICON: number = 22;
const WSSUN_CAT_FONT: number = 12; const WSSUN_CAT_GAP: number = 14;
const WSSUN_CAT_TOP: number = 12; const WSSUN_CAT_PAD_SIDE: number = 12;

/** 楼层卡片：圆角 12vp、内边距 12vp、楼层之间 10vp */
const WSSUN_FLOOR_RADIUS: number = 12; const WSSUN_FLOOR_PAD: number = 12;
const WSSUN_FLOOR_GAP: number = 10; const WSSUN_FLOOR_TITLE_FONT: number = 16;
const WSSUN_FLOOR_SUB_FONT: number = 10; const WSSUN_FLOOR_MORE_FONT: number = 12;
const WSSUN_FLOOR_MORE_ICON: number = 12;

/** 大聚惠卡：封面高 92vp、三列、间距 8vp */
const WSSUN_DEAL_COVER_H: number = 92; const WSSUN_DEAL_GAP: number = 8;
const WSSUN_DEAL_INITIAL_FONT: number = 22; const WSSUN_DEAL_NAME_FONT: number = 12;
const WSSUN_DEAL_NAME_LINE: number = 17; const WSSUN_DEAL_PRICE_FONT: number = 15;
const WSSUN_DEAL_YEN_FONT: number = 11; const WSSUN_DEAL_STRIKE_FONT: number = 10;

/** 推荐卡：图 110×110vp、主字 14vp、价格数字 18vp */
const WSSUN_REC_IMG: number = 110; const WSSUN_REC_IMG_RADIUS: number = 8;
const WSSUN_REC_INITIAL_FONT: number = 26; const WSSUN_REC_NAME_FONT: number = 14;
const WSSUN_REC_NAME_LINE: number = 20; const WSSUN_REC_TAG_FONT: number = 11;
const WSSUN_REC_PRICE_FONT: number = 18; const WSSUN_REC_YEN_FONT: number = 12;
const WSSUN_REC_STRIKE_FONT: number = 11; const WSSUN_REC_SOLD_FONT: number = 11;
const WSSUN_REC_GAP: number = 12; const WSSUN_REC_CARD_GAP: number = 12;

const WSSUN_FOOTER_FONT: number = 12; const WSSUN_FOOTER_MARGIN: number = 16;

/** 分类宫格入口 */
interface SuningCategoryCell {
  cellKey: string;
  cellLabel: string;
  cellSymbol: Resource;
  /** 图标圆底色 */
  cellTint: string;
}

/** 大聚惠爆款卡 */
interface SuningDealCard {
  dealKey: string;
  dealName: string;
  dealPrice: string;
  dealOldPrice: string;
  dealInitial: string;
  dealTopColor: string;
  dealBottomColor: string;
}

/** 为你推荐大卡 */
interface SuningBigDeal {
  recKey: string;
  recName: string;
  recTag: string;
  recPrice: string;
  recOldPrice: string;
  recSold: string;
  recTopColor: string;
  recBottomColor: string;
}

const WSSUN_CATS_ROW1: SuningCategoryCell[] = [
  { cellKey: 'sun-cat-market', cellLabel: '苏宁超市', cellSymbol: $r('sys.symbol.bag_fill'), cellTint: '#FF8C1E' },
  { cellKey: 'sun-cat-appliance', cellLabel: '大家电', cellSymbol: $r('sys.symbol.house_fill'), cellTint: '#2E7BF6' },
  { cellKey: 'sun-cat-phone', cellLabel: '手机数码', cellSymbol: $r('sys.symbol.doc_text'), cellTint: '#7A5AF8' },
  { cellKey: 'sun-cat-computer', cellLabel: '电脑办公', cellSymbol: $r('sys.symbol.building'), cellTint: '#0E9C8C' },
  { cellKey: 'sun-cat-utility', cellLabel: '生活缴费', cellSymbol: $r('sys.symbol.wallet'), cellTint: '#F2A413' }
];

const WSSUN_CATS_ROW2: SuningCategoryCell[] = [
  { cellKey: 'sun-cat-recharge', cellLabel: '充话费', cellSymbol: $r('sys.symbol.creditcard'), cellTint: '#2FA962' },
  { cellKey: 'sun-cat-nearby', cellLabel: '附近门店', cellSymbol: $r('sys.symbol.map'), cellTint: '#F2555C' },
  { cellKey: 'sun-cat-coupon', cellLabel: '领券中心', cellSymbol: $r('sys.symbol.ticket_fill'), cellTint: '#E83B4E' },
  { cellKey: 'sun-cat-tradein', cellLabel: '以旧换新', cellSymbol: $r('sys.symbol.arrow_clockwise'), cellTint: '#00A6E0' },
  { cellKey: 'sun-cat-vip', cellLabel: '会员专区', cellSymbol: $r('sys.symbol.star_rosette'), cellTint: '#C9932B' }
];

const WSSUN_JUHUI_DEALS: SuningDealCard[] = [
  { dealKey: 'sun-deal-midea', dealName: '美的空调 大1.5匹 酷省电', dealPrice: '2199', dealOldPrice: '¥2999', dealInitial: '美', dealTopColor: '#2E5F94', dealBottomColor: '#5B8FC7' },
  { dealKey: 'sun-deal-haier', dealName: '海尔冰箱 321升 风冷无霜', dealPrice: '2899', dealOldPrice: '¥3699', dealInitial: '海', dealTopColor: '#0E4C5A', dealBottomColor: '#3D8FA3' },
  { dealKey: 'sun-deal-gree', dealName: '格力挂机 1.5匹 云锦三代', dealPrice: '2599', dealOldPrice: '¥3299', dealInitial: '格', dealTopColor: '#1F5C3D', dealBottomColor: '#4E9170' }
];

const WSSUN_REC_DEALS: SuningBigDeal[] = [
  { recKey: 'sun-rec-iphone', recName: 'Apple iPhone 17 128GB 黑色 5G双卡双待手机', recTag: '苏宁自营 · 以旧换新至高补1000', recPrice: '5999', recOldPrice: '¥6499', recSold: '1.2万人已买', recTopColor: '#37414E', recBottomColor: '#6B7889' },
  { recKey: 'sun-rec-pad', recName: '小米平板7 Pro 11.2英寸 8+256GB 骁龙8s', recTag: '苏宁自营 · 12期免息', recPrice: '1999', recOldPrice: '¥2299', recSold: '8963人已买', recTopColor: '#3B2C52', recBottomColor: '#7A5B9E' },
  { recKey: 'sun-rec-tv', recName: '海信电视 75E5N Pro 75英寸 240Hz 高刷', recTag: '以旧换新 · 送装一体', recPrice: '4299', recOldPrice: '¥5299', recSold: '5412人已买', recTopColor: '#1F3A5F', recBottomColor: '#4872A8' },
  { recKey: 'sun-rec-legion', recName: '联想拯救者Y7000P 16英寸 RTX5060 游戏本', recTag: '苏宁自营 · 学生优惠', recPrice: '7499', recOldPrice: '¥8299', recSold: '3104人已买', recTopColor: '#8A2333', recBottomColor: '#C25B6A' }
];

@Component
export struct SuningHomeBlankPage {
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
      this.windowToken = WindowModeController.acquire(win, '#000000');
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  /** 整页缩放比：窗口宽度 / 单屏基准宽度（459.6vp），
   *  放大倍率钳制在 1.04 —— 宽窗口下楼层只轻微放大、不铺满窗口（留白反例根源） */
  private sceneScale(): number {
    if (this.winWidthVp <= 0) {
      return 1;
    }
    return Math.min(this.winWidthVp / WSSUN_BASE_WIDTH, WSSUN_MAX_SCALE);
  }

  /** 把基准宽度下的设计值换算到当前窗口 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  // ------------------------------------------------------------------
  // 顶部：整窗宽黄色渐变头（定位 + 搜索框 + 消息）
  // ------------------------------------------------------------------

  @Builder
  searchPill() {
    Row({ space: this.vs(WSSUN_HEADER_GAP) }) {
      SymbolGlyph($r('sys.symbol.magnifyingglass'))
        .fontSize(this.vs(WSSUN_SEARCH_ICON)).fontColor([WSSUN_TEXT_MAIN])

      Text('大家电以旧换新至高补20%')
        .fontSize(this.vs(WSSUN_SEARCH_HINT_FONT)).fontColor(WSSUN_SEARCH_HINT)
        .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis }).layoutWeight(1)

      SymbolGlyph($r('sys.symbol.camera'))
        .fontSize(this.vs(WSSUN_SEARCH_ICON)).fontColor([WSSUN_TEXT_SUB])
    }
    .height(this.vs(WSSUN_SEARCH_PILL_HEIGHT)).layoutWeight(1)
    .padding({ left: this.vs(WSSUN_SEARCH_PILL_PAD), right: this.vs(WSSUN_SEARCH_PILL_PAD) })
    .backgroundColor(WSSUN_CARD_BG).borderRadius(this.vs(WSSUN_SEARCH_PILL_RADIUS))
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  headerBand() {
    Column() {
      Row({ space: this.vs(WSSUN_HEADER_GAP) }) {
        Column({ space: this.vs(2) }) {
          SymbolGlyph($r('sys.symbol.pin'))
            .fontSize(this.vs(WSSUN_LOCATION_ICON)).fontColor([WSSUN_TEXT_MAIN])

          Text('广州')
            .fontSize(this.vs(WSSUN_LOCATION_FONT)).fontColor(WSSUN_TEXT_MAIN).maxLines(1)
        }
        .alignItems(HorizontalAlign.Center)

        this.searchPill()

        SymbolGlyph($r('sys.symbol.message'))
          .fontSize(this.vs(WSSUN_MESSAGE_ICON)).fontColor([WSSUN_TEXT_MAIN])
      }
      .width('100%').layoutWeight(1)
      .padding({ left: this.vs(WSSUN_HEADER_PAD_SIDE), right: this.vs(WSSUN_HEADER_PAD_SIDE) })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%').height(this.vs(WSSUN_HEADER_HEIGHT))
    .linearGradient({ angle: 180, colors: [[WSSUN_YELLOW_TOP, 0.0], [WSSUN_YELLOW_BOTTOM, 1.0]] })
    .padding({ top: this.vs(WSSUN_STATUS_PAD) })
  }

  // ------------------------------------------------------------------
  // 818 发烧节横幅
  // ------------------------------------------------------------------

  @Builder
  bannerCard() {
    Row() {
      Column({ space: this.vs(4) }) {
        Row({ space: this.vs(8) }) {
          Text('818发烧节 · 全民嗨购')
            .fontSize(this.vs(WSSUN_BANNER_TITLE_FONT)).fontWeight(FontWeight.Bold)
            .fontColor(Color.White).maxLines(1)

          Text('预热中')
            .fontSize(this.vs(WSSUN_BANNER_SUB_FONT)).fontColor(Color.White).maxLines(1)
            .padding({ left: this.vs(WSSUN_BANNER_TAG_PAD), right: this.vs(WSSUN_BANNER_TAG_PAD), top: this.vs(2), bottom: this.vs(2) })
            .backgroundColor('#33FFFFFF').borderRadius(this.vs(9))
        }
        .alignItems(VerticalAlign.Center)

        Text('预付定金膨胀至高10倍 · 以旧换新双重补贴')
          .fontSize(this.vs(WSSUN_BANNER_SUB_FONT)).fontColor(Color.White)
          .opacity(0.9).maxLines(1)
      }
      .alignItems(HorizontalAlign.Start).layoutWeight(1)

      SymbolGlyph($r('sys.symbol.gift_fill'))
        .fontSize(this.vs(WSSUN_BANNER_ICON)).fontColor([Color.White])
    }
    .width('100%').height(this.vs(WSSUN_BANNER_HEIGHT))
    .padding({ left: this.vs(WSSUN_BANNER_PAD_SIDE), right: this.vs(WSSUN_BANNER_PAD_SIDE) })
    .linearGradient({ angle: 135, colors: [[WSSUN_BANNER_TOP, 0.0], [WSSUN_BANNER_BOTTOM, 1.0]] })
    .borderRadius(this.vs(WSSUN_BANNER_RADIUS)).alignItems(VerticalAlign.Center)
    .margin({ top: this.vs(WSSUN_FLOOR_GAP) })
  }

  // ------------------------------------------------------------------
  // 分类宫格：两排五行
  // ------------------------------------------------------------------

  @Builder
  catRow(cells: SuningCategoryCell[]) {
    Row() {
      ForEach(cells, (cell: SuningCategoryCell) => {
        Column({ space: this.vs(6) }) {
          Stack({ alignContent: Alignment.Center }) {
            SymbolGlyph(cell.cellSymbol)
              .fontSize(this.vs(WSSUN_CAT_ICON)).fontColor([Color.White])
          }
          .width(this.vs(WSSUN_CAT_ICON_BG)).height(this.vs(WSSUN_CAT_ICON_BG))
          .borderRadius(this.vs(WSSUN_CAT_ICON_BG / 2)).backgroundColor(cell.cellTint)

          Text(cell.cellLabel)
            .fontSize(this.vs(WSSUN_CAT_FONT)).fontColor(WSSUN_TEXT_MAIN).maxLines(1)
        }
        .layoutWeight(1).alignItems(HorizontalAlign.Center)
      }, (cell: SuningCategoryCell) => cell.cellKey)
    }
    .width('100%').alignItems(VerticalAlign.Top)
    .margin({ top: this.vs(WSSUN_CAT_GAP) })
  }

  @Builder
  categoryGrid() {
    Column() {
      this.catRow(WSSUN_CATS_ROW1)

      this.catRow(WSSUN_CATS_ROW2)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: this.vs(WSSUN_CAT_PAD_SIDE), right: this.vs(WSSUN_CAT_PAD_SIDE), top: this.vs(WSSUN_CAT_TOP) })
  }

  // ------------------------------------------------------------------
  // 大聚惠楼层：三张爆款卡
  // ------------------------------------------------------------------

  @Builder
  juhuiDealCard(card: SuningDealCard) {
    Column({ space: this.vs(6) }) {
      Stack({ alignContent: Alignment.Center }) {
        Text(card.dealInitial)
          .fontSize(this.vs(WSSUN_DEAL_INITIAL_FONT)).fontWeight(FontWeight.Bold)
          .fontColor(Color.White).opacity(0.92).maxLines(1)
      }
      .width('100%').height(this.vs(WSSUN_DEAL_COVER_H))
      .linearGradient({ angle: 140, colors: [[card.dealTopColor, 0.0], [card.dealBottomColor, 1.0]] })
      .borderRadius(this.vs(WSSUN_REC_IMG_RADIUS))

      Text(card.dealName)
        .fontSize(this.vs(WSSUN_DEAL_NAME_FONT)).lineHeight(this.vs(WSSUN_DEAL_NAME_LINE))
        .fontColor(WSSUN_TEXT_MAIN).maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Row() {
        Text('¥')
          .fontSize(this.vs(WSSUN_DEAL_YEN_FONT)).lineHeight(this.vs(14))
          .fontColor(WSSUN_PRICE_RED).maxLines(1)
          .margin({ bottom: this.vs(2) })

        Text(card.dealPrice)
          .fontSize(this.vs(WSSUN_DEAL_PRICE_FONT)).lineHeight(this.vs(20))
          .fontWeight(FontWeight.Bold).fontColor(WSSUN_PRICE_RED).maxLines(1)

        Text(card.dealOldPrice)
          .fontSize(this.vs(WSSUN_DEAL_STRIKE_FONT)).lineHeight(this.vs(14))
          .fontColor(WSSUN_STRIKE_COLOR).maxLines(1)
          .decoration({ type: TextDecorationType.LineThrough, color: WSSUN_STRIKE_COLOR })
          .margin({ left: this.vs(4), bottom: this.vs(2) })
      }
      .width('100%').alignItems(VerticalAlign.Bottom)
    }
    .layoutWeight(1).alignItems(HorizontalAlign.Start)
  }

  @Builder
  juhuiFloor() {
    Column() {
      Row({ space: this.vs(6) }) {
        Text('大聚惠')
          .fontSize(this.vs(WSSUN_FLOOR_TITLE_FONT)).fontWeight(FontWeight.Bold)
          .fontColor(WSSUN_TEXT_MAIN).maxLines(1)

        Text('超值爆款 限时抢购')
          .fontSize(this.vs(WSSUN_FLOOR_SUB_FONT)).fontColor(WSSUN_JUHUI_TAG_TEXT).maxLines(1)
          .padding({ left: this.vs(WSSUN_BANNER_TAG_PAD), right: this.vs(WSSUN_BANNER_TAG_PAD), top: this.vs(2), bottom: this.vs(2) })
          .backgroundColor(WSSUN_JUHUI_TAG_BG).borderRadius(this.vs(8))

        Blank()

        Text('更多')
          .fontSize(this.vs(WSSUN_FLOOR_MORE_FONT)).fontColor(WSSUN_TEXT_SUB).maxLines(1)

        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(this.vs(WSSUN_FLOOR_MORE_ICON)).fontColor([WSSUN_TEXT_SUB])
      }
      .width('100%').alignItems(VerticalAlign.Center)

      Row({ space: this.vs(WSSUN_DEAL_GAP) }) {
        ForEach(WSSUN_JUHUI_DEALS, (deal: SuningDealCard) => {
          this.juhuiDealCard(deal)
        }, (deal: SuningDealCard) => deal.dealKey)
      }
      .width('100%').alignItems(VerticalAlign.Top)
      .margin({ top: this.vs(WSSUN_DEAL_GAP) })
    }
    .width('100%').alignItems(HorizontalAlign.Start)
    .padding(this.vs(WSSUN_FLOOR_PAD))
    .backgroundColor(WSSUN_CARD_BG).borderRadius(this.vs(WSSUN_FLOOR_RADIUS))
    .margin({ top: this.vs(WSSUN_FLOOR_GAP) })
  }

  // ------------------------------------------------------------------
  // 为你推荐楼层：四张大卡
  // ------------------------------------------------------------------

  @Builder
  recDealCard(item: SuningBigDeal) {
    Row({ space: this.vs(WSSUN_REC_GAP) }) {
      Stack({ alignContent: Alignment.Center }) {
        SymbolGlyph($r('sys.symbol.star'))
          .fontSize(this.vs(WSSUN_REC_INITIAL_FONT)).fontColor([Color.White]).opacity(0.9)
      }
      .width(this.vs(WSSUN_REC_IMG)).height(this.vs(WSSUN_REC_IMG))
      .linearGradient({ angle: 140, colors: [[item.recTopColor, 0.0], [item.recBottomColor, 1.0]] })
      .borderRadius(this.vs(WSSUN_REC_IMG_RADIUS))

      Column({ space: this.vs(6) }) {
        Text(item.recName)
          .fontSize(this.vs(WSSUN_REC_NAME_FONT)).lineHeight(this.vs(WSSUN_REC_NAME_LINE))
          .fontWeight(FontWeight.Medium).fontColor(WSSUN_TEXT_MAIN)
          .maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(item.recTag)
          .fontSize(this.vs(WSSUN_REC_TAG_FONT)).fontColor(WSSUN_JUHUI_TAG_TEXT).maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row() {
          Text('¥')
            .fontSize(this.vs(WSSUN_REC_YEN_FONT)).lineHeight(this.vs(16))
            .fontColor(WSSUN_PRICE_RED).maxLines(1)
            .margin({ bottom: this.vs(2) })

          Text(item.recPrice)
            .fontSize(this.vs(WSSUN_REC_PRICE_FONT)).lineHeight(this.vs(24))
            .fontWeight(FontWeight.Bold).fontColor(WSSUN_PRICE_RED).maxLines(1)

          Text(item.recOldPrice)
            .fontSize(this.vs(WSSUN_REC_STRIKE_FONT)).lineHeight(this.vs(16))
            .fontColor(WSSUN_STRIKE_COLOR).maxLines(1)
            .decoration({ type: TextDecorationType.LineThrough, color: WSSUN_STRIKE_COLOR })
            .margin({ left: this.vs(4), bottom: this.vs(2) })

          Blank()

          Text(item.recSold)
            .fontSize(this.vs(WSSUN_REC_SOLD_FONT)).fontColor(WSSUN_TEXT_SUB).maxLines(1)
        }
        .width('100%').alignItems(VerticalAlign.Bottom)
      }
      .layoutWeight(1).alignItems(HorizontalAlign.Start)
    }
    .width('100%').alignItems(VerticalAlign.Top)
    .padding({ top: this.vs(WSSUN_REC_CARD_GAP / 2), bottom: this.vs(WSSUN_REC_CARD_GAP / 2) })
  }

  @Builder
  recommendFloor() {
    Column() {
      Row({ space: this.vs(6) }) {
        Text('为你推荐')
          .fontSize(this.vs(WSSUN_FLOOR_TITLE_FONT)).fontWeight(FontWeight.Bold)
          .fontColor(WSSUN_TEXT_MAIN).maxLines(1)

        Blank()

        Text('换一批')
          .fontSize(this.vs(WSSUN_FLOOR_MORE_FONT)).fontColor(WSSUN_TEXT_SUB).maxLines(1)

        SymbolGlyph($r('sys.symbol.arrow_clockwise'))
          .fontSize(this.vs(WSSUN_FLOOR_MORE_ICON)).fontColor([WSSUN_TEXT_SUB])
      }
      .width('100%').alignItems(VerticalAlign.Center)

      ForEach(WSSUN_REC_DEALS, (item: SuningBigDeal) => {
        Column() {
          this.recDealCard(item)

          if (item.recKey !== 'sun-rec-legion') {
            Row()
              .width('100%').height(this.vs(0.5))
              .backgroundColor(WSSUN_PAGE_BG)
              .margin({ top: this.vs(WSSUN_REC_CARD_GAP / 2) })
          }
        }
        .width('100%').alignItems(HorizontalAlign.Start)
      }, (item: SuningBigDeal) => item.recKey)
    }
    .width('100%').alignItems(HorizontalAlign.Start)
    .padding(this.vs(WSSUN_FLOOR_PAD))
    .backgroundColor(WSSUN_CARD_BG).borderRadius(this.vs(WSSUN_FLOOR_RADIUS))
    .margin({ top: this.vs(WSSUN_FLOOR_GAP) })
  }

  @Builder
  homeFooter() {
    Text('— 上拉加载更多 —')
      .fontSize(this.vs(WSSUN_FOOTER_FONT)).fontColor(WSSUN_TEXT_SUB).maxLines(1)
      .width('100%').textAlign(TextAlign.Center)
      .margin({ top: this.vs(WSSUN_FOOTER_MARGIN), bottom: this.vs(WSSUN_FOOTER_MARGIN) })
  }

  // ------------------------------------------------------------------
  // 内容列：固定基准宽度、贴窗口左缘，右侧留白
  // ------------------------------------------------------------------

  @Builder
  contentStage() {
    Row() {
      Column() {
        Scroll() {
          Column() {
            this.bannerCard()

            this.categoryGrid()

            this.juhuiFloor()

            this.recommendFloor()

            this.homeFooter()
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.None)
        .align(Alignment.Start)
      }
      .width(this.vs(WSSUN_BASE_WIDTH))
      .height('100%')
      .backgroundColor(WSSUN_PAGE_BG)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .layoutWeight(1)
    .alignItems(VerticalAlign.Top)
    .backgroundColor(WSSUN_PAGE_BG)
  }

  build() {
    NavDestination() {
      Column() {
        this.headerBand()

        this.contentStage()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(WSSUN_PAGE_BG)
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
