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
 * 反例：留白过多 / 唯品会首页内容挤左侧
 *
 * 复刻对象：唯品会 App 首页，双屏横屏。顶部整窗宽的粉色渐变头：左侧定位「广州」、
 *   中间白色圆角搜索框「春季新品风暴 低至1折」、右侧扫一扫图标；头图下方是
 *   「推荐 / 唯品奥莱 / 女装 / 男装 / 鞋靴 / 美妆 / 母婴 / 运动」横滑频道条，
 *   一条「3.8 品牌狂欢节」横幅，再往下是两列瀑布流品牌卡——彩色渐变封面占位 +
 *   品牌名（耐克 / 古驰 / 欧莱雅 / 薇姿 / 拉夫劳伦 / 阿迪达斯 / 斐乐 / 迪奥）+
 *   红色折扣「2.3折起」+「进入」胶囊。频道条、横幅与瀑布流全部固定在
 *   459.6vp 的单屏内容列里、贴窗口左缘排布，右侧只剩和页面同色的浅灰底。
 *
 * 设计基准：以单屏折叠态 459.6×672vp 为基准宽度做的 1:1 移动端排版。
 *   所有尺寸 / 字号先按 窗口宽度 / 459.6 换算（sceneScale），
 *   再把放大倍率钳制在 1.02 —— 宽窗口下整列只轻微放大 2%，绝不铺满窗口，
 *   这正是留白反例的根源。
 *   状态栏占位 36vp；头部高 92vp（粉渐变 #F10180 → #FF3D8F）；
 *   定位字 12vp；搜索框高 34vp、圆角 17vp、提示字 13vp；
 *   频道条行高 46vp、字 15vp、选中项下红条 18×3vp；
 *   横幅高 86vp、圆角 10vp、主字 19vp；瀑布流两列间距 8vp、卡片圆角 10vp、
 *   封面高 165～230vp（左右两列错落）、品牌名 15vp、折扣 13vp、
 *   「进入」胶囊 58×24vp、字 12vp。
 *
 * 三态实测（内容列宽 = 459.6 × sceneScale，右缘之外全是页面底色的空白）：
 *   单屏态      459.6×672vp   —— 内容列与窗口同宽，无额外留白（正常形态）；
 *   双屏态竖屏  664.7×939.6vp —— 内容列 468.8vp，右侧空出 195.9vp，约占宽度的 29%；
 *   双屏态横屏  939.6×664.7vp —— 内容列 468.8vp，右侧空出 470.8vp，约占宽度的 50%，
 *                                瀑布流只占左半屏，右半屏一整块空着。
 *
 * 问题表现：
 *   频道条、横幅、瀑布流全部挤在左侧一条手机宽度里；窗口越宽，右侧的浅灰空白越大
 *   ——横屏下整整半屏没有任何内容；只有顶部粉色头图横贯整窗，
 *   反而把头图下方右侧那块空无一物的区域衬得更刺眼。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 配色：浅灰页面、白卡片、近黑正文、灰副标题、品牌粉、红折扣 */
const WSVIP_PAGE_BG: string = '#F4F4F6';
const WSVIP_CARD_BG: string = '#FFFFFF';
const WSVIP_TEXT_MAIN: string = '#1A1A1A';
const WSVIP_TEXT_SUB: string = '#8C8C99';
const WSVIP_PINK_MAIN: string = '#F10180';
const WSVIP_PINK_TOP: string = '#F10180';
const WSVIP_PINK_BOTTOM: string = '#FF3D8F';
const WSVIP_PRICE_RED: string = '#E2264D';
const WSVIP_SEARCH_HINT: string = '#B9B9C4';
const WSVIP_GO_PILL_BG: string = '#FDEBF4';

/** 基准：单屏折叠态窗口宽 459.6vp；宽窗口下缩放倍率钳制在 1.02 */
const WSVIP_BASE_WIDTH: number = 459.6;
const WSVIP_MAX_SCALE: number = 1.02;

/** 头部：状态栏占位 36vp + 内容行 56vp = 92vp */
const WSVIP_STATUS_PAD: number = 36;
const WSVIP_HEADER_HEIGHT: number = 92;
const WSVIP_HEADER_PAD_SIDE: number = 14; const WSVIP_HEADER_GAP: number = 10;
const WSVIP_LOCATION_FONT: number = 12; const WSVIP_LOCATION_ICON: number = 14;
const WSVIP_SEARCH_PILL_HEIGHT: number = 34; const WSVIP_SEARCH_PILL_RADIUS: number = 17;
const WSVIP_SEARCH_PILL_PAD: number = 12; const WSVIP_SEARCH_HINT_FONT: number = 13;
const WSVIP_SEARCH_ICON: number = 16; const WSVIP_SCAN_ICON: number = 22;

/** 频道条：行高 46vp、字 15vp、间距 18vp、选中下红条 18×3vp */
const WSVIP_TAB_ROW_HEIGHT: number = 46; const WSVIP_TAB_FONT: number = 15;
const WSVIP_TAB_GAP: number = 18; const WSVIP_TAB_IND_W: number = 18;
const WSVIP_TAB_IND_H: number = 3; const WSVIP_TAB_PAD_SIDE: number = 14;

/** 横幅：高 86vp、圆角 10vp、主字 19vp、副字 12vp、内边距 16vp */
const WSVIP_BANNER_HEIGHT: number = 86; const WSVIP_BANNER_RADIUS: number = 10;
const WSVIP_BANNER_TITLE_FONT: number = 19; const WSVIP_BANNER_SUB_FONT: number = 12;
const WSVIP_BANNER_PAD_SIDE: number = 16; const WSVIP_BANNER_MARGIN_TOP: number = 10;
const WSVIP_BANNER_ICON: number = 34; const WSVIP_BANNER_TAG_PAD: number = 6;

/** 瀑布流：两列间距 8vp、卡片圆角 10vp、封面占位、卡片内边距 10vp */
const WSVIP_FALLS_PAD_SIDE: number = 12; const WSVIP_FALLS_GAP: number = 8;
const WSVIP_CARD_RADIUS: number = 10; const WSVIP_CARD_PAD: number = 10;
const WSVIP_COVER_RADIUS: number = 10; const WSVIP_BRAND_FONT: number = 15;
const WSVIP_EN_FONT: number = 11; const WSVIP_DISCOUNT_FONT: number = 13;
const WSVIP_HEAT_FONT: number = 11; const WSVIP_GO_PILL_W: number = 58;
const WSVIP_GO_PILL_H: number = 24; const WSVIP_GO_PILL_FONT: number = 12;
const WSVIP_INITIAL_FONT: number = 34; const WSVIP_CARD_TEXT_GAP: number = 6;
const WSVIP_FOOTER_FONT: number = 12; const WSVIP_FOOTER_MARGIN: number = 18;

/** 频道条 tab */
interface VipCategoryTab {
  tabKey: string;
  tabLabel: string;
  tabActive: boolean;
}

/** 瀑布流品牌卡 */
interface VipBrandCard {
  brandKey: string;
  brandName: string;
  brandEnName: string;
  /** 封面占位里的大写首字母 */
  brandInitial: string;
  discountText: string;
  heatText: string;
  /** 封面占位高度（基准 vp），左右两列错落 */
  coverHeight: number;
  coverTopColor: string;
  coverBottomColor: string;
}

const WSVIP_TABS: VipCategoryTab[] = [
  { tabKey: 'vip-tab-reco', tabLabel: '推荐', tabActive: true },
  { tabKey: 'vip-tab-outlet', tabLabel: '唯品奥莱', tabActive: false },
  { tabKey: 'vip-tab-women', tabLabel: '女装', tabActive: false },
  { tabKey: 'vip-tab-men', tabLabel: '男装', tabActive: false },
  { tabKey: 'vip-tab-shoes', tabLabel: '鞋靴', tabActive: false },
  { tabKey: 'vip-tab-beauty', tabLabel: '美妆', tabActive: false },
  { tabKey: 'vip-tab-baby', tabLabel: '母婴', tabActive: false },
  { tabKey: 'vip-tab-sport', tabLabel: '运动', tabActive: false }
];

/** 瀑布流左列（封面高一些） */
const WSVIP_BRANDS_LEFT: VipBrandCard[] = [
  { brandKey: 'vip-brand-nike', brandName: '耐克 NIKE', brandEnName: 'JUST DO IT', brandInitial: 'N', discountText: '2.3折起', heatText: '1.2万人已抢', coverHeight: 210, coverTopColor: '#2E2E38', coverBottomColor: '#5A5A6E' },
  { brandKey: 'vip-brand-loreal', brandName: '欧莱雅', brandEnName: "L'ORÉAL PARIS", brandInitial: 'L', discountText: '3.1折起', heatText: '8963人已抢', coverHeight: 178, coverTopColor: '#3B2C52', coverBottomColor: '#7A5B9E' },
  { brandKey: 'vip-brand-ralph', brandName: '拉夫劳伦', brandEnName: 'POLO RALPH LAUREN', brandInitial: 'R', discountText: '2.8折起', heatText: '4310人已抢', coverHeight: 228, coverTopColor: '#1F3A5F', coverBottomColor: '#4872A8' },
  { brandKey: 'vip-brand-fila', brandName: '斐乐 FILA', brandEnName: '意大利百年运动', brandInitial: 'F', discountText: '3.5折起', heatText: '6712人已抢', coverHeight: 165, coverTopColor: '#8A2333', coverBottomColor: '#C25B6A' }
];

/** 瀑布流右列（封面矮一档，与左列错落出瀑布节奏） */
const WSVIP_BRANDS_RIGHT: VipBrandCard[] = [
  { brandKey: 'vip-brand-gucci', brandName: '古驰 GUCCI', brandEnName: 'MAISON DE MODE', brandInitial: 'G', discountText: '2.6折起', heatText: '9846人已抢', coverHeight: 175, coverTopColor: '#22392B', coverBottomColor: '#4E7360' },
  { brandKey: 'vip-brand-vichy', brandName: '薇姿 VICHY', brandEnName: 'DERCOS 实验室', brandInitial: 'V', discountText: '3.4折起', heatText: '5231人已抢', coverHeight: 216, coverTopColor: '#0E4C5A', coverBottomColor: '#3D8FA3' },
  { brandKey: 'vip-brand-adidas', brandName: '阿迪达斯', brandEnName: 'IMPOSSIBLE IS NOTHING', brandInitial: 'A', discountText: '2.9折起', heatText: '1.8万人已抢', coverHeight: 162, coverTopColor: '#37414E', coverBottomColor: '#6B7889' },
  { brandKey: 'vip-brand-dior', brandName: '迪奥 DIOR', brandEnName: 'MISS DIOR 系列', brandInitial: 'D', discountText: '2.4折起', heatText: '7688人已抢', coverHeight: 224, coverTopColor: '#40222E', coverBottomColor: '#8A5566' }
];

@Component
export struct VipShopHomeBlankPage {
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
   *  放大倍率钳制在 1.02 —— 宽窗口下内容列只轻微放大、不铺满窗口（留白反例根源） */
  private sceneScale(): number {
    if (this.winWidthVp <= 0) {
      return 1;
    }
    return Math.min(this.winWidthVp / WSVIP_BASE_WIDTH, WSVIP_MAX_SCALE);
  }

  /** 把基准宽度下的设计值换算到当前窗口 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  // ------------------------------------------------------------------
  // 顶部：整窗宽粉色渐变头（定位 + 搜索框 + 扫一扫）
  // ------------------------------------------------------------------

  @Builder
  searchPill() {
    Row({ space: this.vs(WSVIP_HEADER_GAP) }) {
      SymbolGlyph($r('sys.symbol.magnifyingglass'))
        .fontSize(this.vs(WSVIP_SEARCH_ICON))
        .fontColor([WSVIP_PINK_MAIN])

      Text('春季新品风暴 低至1折')
        .fontSize(this.vs(WSVIP_SEARCH_HINT_FONT))
        .fontColor(WSVIP_SEARCH_HINT)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)

      SymbolGlyph($r('sys.symbol.camera'))
        .fontSize(this.vs(WSVIP_SEARCH_ICON))
        .fontColor([WSVIP_TEXT_SUB])
    }
    .height(this.vs(WSVIP_SEARCH_PILL_HEIGHT))
    .layoutWeight(1)
    .padding({
      left: this.vs(WSVIP_SEARCH_PILL_PAD),
      right: this.vs(WSVIP_SEARCH_PILL_PAD)
    })
    .backgroundColor(WSVIP_CARD_BG)
    .borderRadius(this.vs(WSVIP_SEARCH_PILL_RADIUS))
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  headerBand() {
    Column() {
      Row({ space: this.vs(WSVIP_HEADER_GAP) }) {
        Column({ space: this.vs(2) }) {
          SymbolGlyph($r('sys.symbol.pin'))
            .fontSize(this.vs(WSVIP_LOCATION_ICON))
            .fontColor([Color.White])

          Text('广州')
            .fontSize(this.vs(WSVIP_LOCATION_FONT))
            .fontColor(Color.White)
            .maxLines(1)
        }
        .alignItems(HorizontalAlign.Center)

        this.searchPill()

        SymbolGlyph($r('sys.symbol.qrcode'))
          .fontSize(this.vs(WSVIP_SCAN_ICON))
          .fontColor([Color.White])
      }
      .width('100%')
      .layoutWeight(1)
      .padding({
        left: this.vs(WSVIP_HEADER_PAD_SIDE),
        right: this.vs(WSVIP_HEADER_PAD_SIDE)
      })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(this.vs(WSVIP_HEADER_HEIGHT))
    .linearGradient({
      angle: 180,
      colors: [[WSVIP_PINK_TOP, 0.0], [WSVIP_PINK_BOTTOM, 1.0]]
    })
    .padding({ top: this.vs(WSVIP_STATUS_PAD) })
  }

  // ------------------------------------------------------------------
  // 频道条：横滑 tab，选中项粉色加粗 + 下方红条
  // ------------------------------------------------------------------

  @Builder
  channelStrip() {
    Scroll() {
      Row({ space: this.vs(WSVIP_TAB_GAP) }) {
        ForEach(WSVIP_TABS, (tab: VipCategoryTab) => {
          Column({ space: this.vs(4) }) {
            Text(tab.tabLabel)
              .fontSize(this.vs(WSVIP_TAB_FONT))
              .fontWeight(tab.tabActive ? FontWeight.Bold : FontWeight.Normal)
              .fontColor(tab.tabActive ? WSVIP_PINK_MAIN : WSVIP_TEXT_MAIN)
              .maxLines(1)

            Row()
              .width(tab.tabActive ? this.vs(WSVIP_TAB_IND_W) : this.vs(1))
              .height(this.vs(WSVIP_TAB_IND_H))
              .backgroundColor(tab.tabActive ? WSVIP_PINK_MAIN : Color.Transparent)
              .borderRadius(this.vs(WSVIP_TAB_IND_H / 2))
          }
          .alignItems(HorizontalAlign.Center)
        }, (tab: VipCategoryTab) => tab.tabKey)
      }
      .padding({
        left: this.vs(WSVIP_TAB_PAD_SIDE),
        right: this.vs(WSVIP_TAB_PAD_SIDE)
      })
    }
    .width('100%')
    .height(this.vs(WSVIP_TAB_ROW_HEIGHT))
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .align(Alignment.Start)
  }

  // ------------------------------------------------------------------
  // 横幅：3.8 品牌狂欢节
  // ------------------------------------------------------------------

  @Builder
  bannerCard() {
    Row() {
      Column({ space: this.vs(4) }) {
        Row({ space: this.vs(8) }) {
          Text('3.8 品牌狂欢节')
            .fontSize(this.vs(WSVIP_BANNER_TITLE_FONT))
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .maxLines(1)

          Text('进行中')
            .fontSize(this.vs(WSVIP_BANNER_SUB_FONT))
            .fontColor(Color.White)
            .maxLines(1)
            .padding({
              left: this.vs(WSVIP_BANNER_TAG_PAD),
              right: this.vs(WSVIP_BANNER_TAG_PAD),
              top: this.vs(2),
              bottom: this.vs(2)
            })
            .backgroundColor('#33FFFFFF')
            .borderRadius(this.vs(9))
        }
        .alignItems(VerticalAlign.Center)

        Text('大牌特卖低至1折 · 满300减50 · 限时秒杀')
          .fontSize(this.vs(WSVIP_BANNER_SUB_FONT))
          .fontColor(Color.White)
          .opacity(0.9)
          .maxLines(1)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      SymbolGlyph($r('sys.symbol.gift_fill'))
        .fontSize(this.vs(WSVIP_BANNER_ICON))
        .fontColor([Color.White])
    }
    .width('100%')
    .height(this.vs(WSVIP_BANNER_HEIGHT))
    .padding({
      left: this.vs(WSVIP_BANNER_PAD_SIDE),
      right: this.vs(WSVIP_BANNER_PAD_SIDE)
    })
    .linearGradient({
      angle: 135,
      colors: [[WSVIP_PINK_TOP, 0.0], ['#7A2AE0', 1.0]]
    })
    .borderRadius(this.vs(WSVIP_BANNER_RADIUS))
    .alignItems(VerticalAlign.Center)
    .margin({ top: this.vs(WSVIP_BANNER_MARGIN_TOP) })
  }

  // ------------------------------------------------------------------
  // 瀑布流品牌卡
  // ------------------------------------------------------------------

  @Builder
  brandCover(card: VipBrandCard) {
    Stack({ alignContent: Alignment.Center }) {
      Column({ space: this.vs(4) }) {
        Text(card.brandInitial)
          .fontSize(this.vs(WSVIP_INITIAL_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .opacity(0.92)
          .maxLines(1)

        Text(card.brandEnName)
          .fontSize(this.vs(WSVIP_EN_FONT))
          .fontColor(Color.White)
          .opacity(0.72)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Center)
      .padding({ left: this.vs(6), right: this.vs(6) })
    }
    .width('100%')
    .height(this.vs(card.coverHeight))
    .linearGradient({
      angle: 160,
      colors: [[card.coverTopColor, 0.0], [card.coverBottomColor, 1.0]]
    })
    .borderRadius(this.vs(WSVIP_COVER_RADIUS))
  }

  @Builder
  brandCard(card: VipBrandCard) {
    Column() {
      this.brandCover(card)

      Column({ space: this.vs(WSVIP_CARD_TEXT_GAP) }) {
        Text(card.brandName)
          .fontSize(this.vs(WSVIP_BRAND_FONT))
          .fontWeight(FontWeight.Medium)
          .fontColor(WSVIP_TEXT_MAIN)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row() {
          Text(card.discountText)
            .fontSize(this.vs(WSVIP_DISCOUNT_FONT))
            .fontWeight(FontWeight.Bold)
            .fontColor(WSVIP_PRICE_RED)
            .maxLines(1)

          Blank()

          Text('进入')
            .fontSize(this.vs(WSVIP_GO_PILL_FONT))
            .fontColor(WSVIP_PINK_MAIN)
            .maxLines(1)
            .width(this.vs(WSVIP_GO_PILL_W))
            .height(this.vs(WSVIP_GO_PILL_H))
            .textAlign(TextAlign.Center)
            .backgroundColor(WSVIP_GO_PILL_BG)
            .borderRadius(this.vs(WSVIP_GO_PILL_H / 2))
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        Text(card.heatText)
          .fontSize(this.vs(WSVIP_HEAT_FONT))
          .fontColor(WSVIP_TEXT_SUB)
          .maxLines(1)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding(this.vs(WSVIP_CARD_PAD))
    }
    .width('100%')
    .backgroundColor(WSVIP_CARD_BG)
    .borderRadius(this.vs(WSVIP_CARD_RADIUS))
    .clip(true)
  }

  @Builder
  fallsArea() {
    Row({ space: this.vs(WSVIP_FALLS_GAP) }) {
      Column({ space: this.vs(WSVIP_FALLS_GAP) }) {
        ForEach(WSVIP_BRANDS_LEFT, (leftCard: VipBrandCard) => {
          this.brandCard(leftCard)
        }, (leftCard: VipBrandCard) => leftCard.brandKey)
      }
      .layoutWeight(1)

      Column({ space: this.vs(WSVIP_FALLS_GAP) }) {
        ForEach(WSVIP_BRANDS_RIGHT, (rightCard: VipBrandCard) => {
          this.brandCard(rightCard)
        }, (rightCard: VipBrandCard) => rightCard.brandKey)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .padding({
      left: this.vs(WSVIP_FALLS_PAD_SIDE),
      right: this.vs(WSVIP_FALLS_PAD_SIDE)
    })
    .alignItems(VerticalAlign.Top)
    .margin({ top: this.vs(WSVIP_FALLS_GAP) })
  }

  @Builder
  fallsFooter() {
    Text('— 已经到底啦，换个频道逛逛吧 —')
      .fontSize(this.vs(WSVIP_FOOTER_FONT))
      .fontColor(WSVIP_TEXT_SUB)
      .maxLines(1)
      .width('100%')
      .textAlign(TextAlign.Center)
      .margin({
        top: this.vs(WSVIP_FOOTER_MARGIN),
        bottom: this.vs(WSVIP_FOOTER_MARGIN)
      })
  }

  // ------------------------------------------------------------------
  // 内容列：固定基准宽度、贴窗口左缘，右侧留白
  // ------------------------------------------------------------------

  @Builder
  contentStage() {
    Row() {
      Column() {
        this.channelStrip()

        Scroll() {
          Column() {
            this.bannerCard()

            this.fallsArea()

            this.fallsFooter()
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
      .width(this.vs(WSVIP_BASE_WIDTH))
      .height('100%')
      .backgroundColor(WSVIP_PAGE_BG)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .layoutWeight(1)
    .alignItems(VerticalAlign.Top)
    .backgroundColor(WSVIP_PAGE_BG)
  }

  build() {
    NavDestination() {
      Column() {
        this.headerBand()

        this.contentStage()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(WSVIP_PAGE_BG)
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
