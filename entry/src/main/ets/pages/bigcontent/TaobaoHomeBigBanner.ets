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
 * 反例：大图大字 / 淘宝首页 banner 放大
 *
 * 复刻淘宝首页：橙色渐变头部（搜索框 + 扫一扫 + 消息）、「38 焕新周」大促
 * banner（橙红渐变色块 + 促销文案 + 礼物图标）、10 个圆形分类图标
 * （2 行 × 5 列：天猫新品 / 淘宝好价 / 充值中心 / 天猫国际 / 营养生鲜 /
 * 今日爆款 / 淘宝二手 / 会员中心 / 芭芭农场 / 看直播）、「淘宝好价」楼层
 * （2×2 商品卡：促销角标 + 标题 + 价格 + 已售）与底部 TabBar。
 * banner 与商品图全部用渐变色块 + SymbolGlyph 绘制，不依赖任何图片资源。
 *
 * 设计基准：单屏态截图 459.6×672vp（1264×1848px，密度 2.75）。
 * banner 高 142vp、分类图标圆 46vp、好价卡图高 150vp、
 * 商品标题字号 15vp、价格字号 21vp、banner 主标题字号 30vp。
 *
 * 三个屏态的实测结果（内容区所有尺寸与字号随窗口宽度等比放大）：
 *   单屏态        459.6×672vp   —— banner 高 142vp、图标圆 46vp，一屏能看全主要楼层
 *   双屏态竖屏    664.7×939.6vp —— banner 高 206vp（×1.45）、图标圆 67vp，
 *                                 好价卡图高 218vp，楼层被整体推到屏幕下半段
 *   双屏态横屏    939.6×664.7vp —— banner 高 290vp（×2.04）吃掉近半屏高，
 *                                 图标圆 94vp、主标题字号 61vp，好价楼层被挤出首屏；
 *                                 头部与 TabBar 仍是单屏态大小，上下小而中间巨大
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 单屏态窗口宽度（1264px / 密度 2.75）：内容区所有尺寸的基准宽度 */
const TAOBAO_BANNER_BASE_WIDTH: number = 459.6;
/** 单屏态窗口高度（1848px / 密度 2.75）：拿不到窗口高度时兜底 */
const TAOBAO_BANNER_BASE_HEIGHT: number = 672;

/** 头部（固定尺寸，不随内容区放大）：搜索行高 / 搜索框高 / 头部左右留白 */
const TAOBAO_SEARCH_ROW_HEIGHT: number = 46;
const TAOBAO_SEARCH_BAR_HEIGHT: number = 34;
const TAOBAO_HEADER_PAD: number = 12;

/** 内容区（随窗口宽度等比放大）：左右留白 / 卡片圆角 / 楼层间距 */
const TAOBAO_CONTENT_PAD: number = 12;
const TAOBAO_CARD_RADIUS: number = 14;
const TAOBAO_SECTION_GAP: number = 12;

/** 大促 banner：内边距（高 142 / 圆角 16 / 字号 12·30·15·18·58 均随窗口等比放大） */
const TAOBAO_BANNER_PAD: number = 18;
/** banner 角标与主标题字号 */
const TAOBAO_BANNER_TAG_FONT: number = 12;
const TAOBAO_BANNER_TITLE_FONT: number = 30;

/** 分类图标：圆底 46vp（图标 24 / 标签 12 / 行距 14 均随窗口等比放大）与列数 */
const TAOBAO_ICON_CIRCLE: number = 46;
const TAOBAO_ICON_GRID_COLUMNS: number = 5;

/** 好价楼层：商品图高 / 已售字号 / 列数（标题 15、价格 21、角标 11 等随窗口等比放大） */
const TAOBAO_DEAL_IMAGE_HEIGHT: number = 150;
const TAOBAO_DEAL_SOLD_FONT: number = 12;
const TAOBAO_DEAL_COLUMNS: number = 2;

/** 底部 TabBar 内容高度（不含手势区） */
const TAOBAO_TAB_BAR_HEIGHT: number = 52;

/** 状态栏 / 底部手势区兜底高度（vp），拿不到避让区时使用 */
const TAOBAO_STATUS_BAR_FALLBACK: number = 32;
const TAOBAO_BOTTOM_INSET_FALLBACK: number = 8;

/** 配色 */
const TAOBAO_PAGE_BG: string = '#F4F4F4';
const TAOBAO_HEADER_TOP: string = '#FF9500';
const TAOBAO_HEADER_BOTTOM: string = '#FF5000';
const TAOBAO_BRAND_ORANGE: string = '#FF5000';
const TAOBAO_TEXT_MAIN: string = '#1A1A1A';
const TAOBAO_TEXT_GRAY: string = '#9A9A9A';
const TAOBAO_PRICE_RED: string = '#FF3C1E';

/** 分类图标：浅色圆底 + 主题色 SymbolGlyph */
interface TaobaoCategoryIconItem {
  iconId: string;
  iconLabel: string;
  iconSymbol: Resource;
  iconBgTint: string;
  iconGlyphTint: string;
}

/** 单屏态首页金刚区：2 行 × 5 列共 10 个入口 */
const TAOBAO_CATEGORY_ICONS: TaobaoCategoryIconItem[] = [
  { iconId: 'tm-new', iconLabel: '天猫新品', iconSymbol: $r('sys.symbol.star'), iconBgTint: '#FFE4D6', iconGlyphTint: '#FF5000' },
  { iconId: 'tb-haojia', iconLabel: '淘宝好价', iconSymbol: $r('sys.symbol.ticket_fill'), iconBgTint: '#FFF0C7', iconGlyphTint: '#C87C1E' },
  { iconId: 'recharge', iconLabel: '充值中心', iconSymbol: $r('sys.symbol.wallet'), iconBgTint: '#D9F2D0', iconGlyphTint: '#3FA45B' },
  { iconId: 'tm-global', iconLabel: '天猫国际', iconSymbol: $r('sys.symbol.map'), iconBgTint: '#D6E8FF', iconGlyphTint: '#3E7FE8' },
  { iconId: 'fresh', iconLabel: '营养生鲜', iconSymbol: $r('sys.symbol.leaf'), iconBgTint: '#D4F0E4', iconGlyphTint: '#2E9E6F' },
  { iconId: 'hot', iconLabel: '今日爆款', iconSymbol: $r('sys.symbol.gift_fill'), iconBgTint: '#FFDCE0', iconGlyphTint: '#E8445E' },
  { iconId: 'second-hand', iconLabel: '淘宝二手', iconSymbol: $r('sys.symbol.bag_fill'), iconBgTint: '#EAE2D6', iconGlyphTint: '#8A6F4D' },
  { iconId: 'vip', iconLabel: '会员中心', iconSymbol: $r('sys.symbol.star_rosette'), iconBgTint: '#FFE9C4', iconGlyphTint: '#B98A1E' },
  { iconId: 'farm', iconLabel: '芭芭农场', iconSymbol: $r('sys.symbol.drop_fill'), iconBgTint: '#D6F4F0', iconGlyphTint: '#1E9E94' },
  { iconId: 'live', iconLabel: '看直播', iconSymbol: $r('sys.symbol.camera'), iconBgTint: '#E4DFF8', iconGlyphTint: '#7A5FE8' }
];

/** 好价楼层商品卡：商品图用渐变色块 + SymbolGlyph 代替 */
interface TaobaoDealProduct {
  dealId: string;
  dealTitle: string;
  dealPrice: string;
  dealOrigin: string;
  dealSold: string;
  dealBadge: string;
  dealTintFrom: string;
  dealTintTo: string;
  dealSymbol: Resource;
}

/** 「淘宝好价」楼层：2×2 四张商品卡 */
const TAOBAO_DEAL_PRODUCTS: TaobaoDealProduct[] = [
  { dealId: 'dress', dealTitle: '春季新款法式碎花连衣裙 长袖雪纺衬衫', dealPrice: '129', dealOrigin: '¥299', dealSold: '已售2.3万+', dealBadge: '限时直降', dealTintFrom: '#FFB199', dealTintTo: '#FF7E55', dealSymbol: $r('sys.symbol.person') },
  { dealId: 'cream', dealTitle: '玻尿酸补水保湿面霜 50g 修护屏障', dealPrice: '79', dealOrigin: '¥139', dealSold: '已售8.7万+', dealBadge: '券后价', dealTintFrom: '#B8E986', dealTintTo: '#7ECB5C', dealSymbol: $r('sys.symbol.leaf') },
  { dealId: 'earphone', dealTitle: '主动降噪蓝牙耳机 Pro 无线长续航', dealPrice: '199', dealOrigin: '¥399', dealSold: '已售1.2万+', dealBadge: '官方立减', dealTintFrom: '#A8D8FF', dealTintTo: '#5BA8F5', dealSymbol: $r('sys.symbol.headphones') },
  { dealId: 'shoes', dealTitle: '增高百搭小白鞋女 春秋新款厚底', dealPrice: '89', dealOrigin: '¥199', dealSold: '已售5.4万+', dealBadge: '淘金币抵钱', dealTintFrom: '#D6B8FF', dealTintTo: '#9D6BF0', dealSymbol: $r('sys.symbol.bag_fill') }
];

/** 底部 TabBar：第一个「首页」为选中态 */
interface TaobaoTabEntry {
  tabId: string;
  tabLabel: string;
  tabSymbol: Resource;
  tabActive: boolean;
}

const TAOBAO_TABS: TaobaoTabEntry[] = [
  { tabId: 'tab-home', tabLabel: '首页', tabSymbol: $r('sys.symbol.house'), tabActive: true },
  { tabId: 'tab-video', tabLabel: '视频', tabSymbol: $r('sys.symbol.camera'), tabActive: false },
  { tabId: 'tab-message', tabLabel: '消息', tabSymbol: $r('sys.symbol.message'), tabActive: false },
  { tabId: 'tab-cart', tabLabel: '购物车', tabSymbol: $r('sys.symbol.cart'), tabActive: false },
  { tabId: 'tab-mine', tabLabel: '我的淘宝', tabSymbol: $r('sys.symbol.person'), tabActive: false }
];

/** 图标区 10 个入口按 5 列折行后的行序号（2 行） */
const TAOBAO_ICON_ROW_INDEXES: number[] = [0, 1];
/** 好价楼层 4 张商品卡按 2 列折行后的行序号（2 行） */
const TAOBAO_DEAL_ROW_INDEXES: number[] = [0, 1];

@Component
export struct TaobaoHomeBigBannerPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = TAOBAO_BANNER_BASE_WIDTH;
  @State winHeightVp: number = TAOBAO_BANNER_BASE_HEIGHT;
  /** 沉浸式下的状态栏 / 底部手势区高度（vp） */
  @State statusBarHeightVp: number = TAOBAO_STATUS_BAR_FALLBACK;
  @State bottomInsetVp: number = TAOBAO_BOTTOM_INSET_FALLBACK;

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
      this.windowToken = WindowModeController.acquire(win, TAOBAO_HEADER_TOP);
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  // 尺寸计算：内容区每一处尺寸 = 单屏态设计值 × 窗口宽度比；头部与底部 TabBar 固定

  /** 内容区缩放比：窗口宽度 / 单屏态宽度（459.6vp） */
  private sceneScale(): number {
    if (this.winWidthVp <= 0) {
      return 1;
    }
    return this.winWidthVp / TAOBAO_BANNER_BASE_WIDTH;
  }

  /** 把单屏态设计值放大到当前窗口宽度 */
  private vs(dimension: number): number {
    return dimension * this.sceneScale();
  }

  /** 取分类图标区第 rowIndex 行（10 个入口按 5 列折行） */
  private iconsOfRow(rowIndex: number): TaobaoCategoryIconItem[] {
    const startIndex: number = rowIndex * TAOBAO_ICON_GRID_COLUMNS;
    return TAOBAO_CATEGORY_ICONS.slice(startIndex, startIndex + TAOBAO_ICON_GRID_COLUMNS);
  }

  /** 取好价楼层第 rowIndex 行的商品（4 张卡按 2 列折行） */
  private dealsOfRow(rowIndex: number): TaobaoDealProduct[] {
    const startIndex: number = rowIndex * TAOBAO_DEAL_COLUMNS;
    return TAOBAO_DEAL_PRODUCTS.slice(startIndex, startIndex + TAOBAO_DEAL_COLUMNS);
  }

  // 头部（固定尺寸，不随内容区放大）

  @Builder
  searchRow() {
    Row({ space: 10 }) {
      Row({ space: 6 }) {
        SymbolGlyph($r('sys.symbol.magnifyingglass'))
          .fontSize(16)
          .fontColor(['#5C5C5C'])

        Text('连衣裙')
          .fontSize(15)
          .fontColor('#3A3A3A')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)

        SymbolGlyph($r('sys.symbol.camera'))
          .fontSize(17)
          .fontColor(['#3A3A3A'])
      }
      .height(TAOBAO_SEARCH_BAR_HEIGHT)
      .padding({ left: 12, right: 12 })
      .backgroundColor(Color.White)
      .borderRadius(TAOBAO_SEARCH_BAR_HEIGHT / 2)
      .layoutWeight(1)
      .alignItems(VerticalAlign.Center)

      SymbolGlyph($r('sys.symbol.qrcode'))
        .fontSize(22)
        .fontColor([Color.White])

      SymbolGlyph($r('sys.symbol.message'))
        .fontSize(22)
        .fontColor([Color.White])
    }
    .width('100%')
    .height(TAOBAO_SEARCH_ROW_HEIGHT)
    .padding({ left: TAOBAO_HEADER_PAD, right: TAOBAO_HEADER_PAD })
    .alignItems(VerticalAlign.Center)
  }

  // 大促 banner：整体随窗口宽度等比放大，横屏下一张占近半屏

  @Builder
  promoBanner() {
    Row() {
      Column({ space: this.vs(7) }) {
        Text('38焕新周')
          .fontSize(this.vs(TAOBAO_BANNER_TAG_FONT))
          .fontColor(Color.White)
          .padding({ left: this.vs(7), right: this.vs(7), top: this.vs(2), bottom: this.vs(2) })
          .border({ width: 1, color: '#66FFFFFF' })
          .borderRadius(this.vs(TAOBAO_BANNER_TAG_FONT))

        Text('春日焕新季')
          .fontSize(this.vs(TAOBAO_BANNER_TITLE_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .maxLines(1)

        Text('每满300减40 · 上不封顶')
          .fontSize(this.vs(15))
          .fontColor('#FFE8D6')
          .maxLines(1)

        Text('¥299起')
          .fontSize(this.vs(18))
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .maxLines(1)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width(this.vs(84))
          .height(this.vs(84))
          .backgroundColor('#33FFFFFF')
          .borderRadius(this.vs(42))

        SymbolGlyph($r('sys.symbol.gift_fill'))
          .fontSize(this.vs(58))
          .fontColor([Color.White])
      }
      .width(this.vs(84))
      .height(this.vs(84))
    }
    .width('100%')
    .height(this.vs(142))
    .padding({ left: this.vs(TAOBAO_BANNER_PAD), right: this.vs(TAOBAO_BANNER_PAD) })
    .borderRadius(this.vs(16))
    .linearGradient({ angle: 135, colors: [['#FF2E00', 0.0], ['#FF8A3C', 1.0]] })
    .alignItems(VerticalAlign.Center)
    .clip(true)
  }

  // 分类图标区：圆底 + SymbolGlyph，圆底直径随窗口宽度放大

  @Builder
  categoryIconCell(iconItem: TaobaoCategoryIconItem) {
    Column({ space: this.vs(6) }) {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width(this.vs(TAOBAO_ICON_CIRCLE))
          .height(this.vs(TAOBAO_ICON_CIRCLE))
          .backgroundColor(iconItem.iconBgTint)
          .borderRadius(this.vs(TAOBAO_ICON_CIRCLE / 2))

        SymbolGlyph(iconItem.iconSymbol)
          .fontSize(this.vs(24))
          .fontColor([iconItem.iconGlyphTint])
      }
      .width(this.vs(TAOBAO_ICON_CIRCLE))
      .height(this.vs(TAOBAO_ICON_CIRCLE))

      Text(iconItem.iconLabel)
        .fontSize(this.vs(12))
        .fontColor(TAOBAO_TEXT_MAIN)
        .maxLines(1)
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }

  /** 图标区白底卡片：2 行 × 5 列 */
  @Builder
  iconGridCard() {
    Column({ space: this.vs(14) }) {
      ForEach(TAOBAO_ICON_ROW_INDEXES, (rowIndex: number) => {
        Row() {
          ForEach(this.iconsOfRow(rowIndex), (iconItem: TaobaoCategoryIconItem) => {
            this.categoryIconCell(iconItem)
          }, (iconItem: TaobaoCategoryIconItem) => iconItem.iconId)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
      }, (rowIndex: number) => 'taobao-icon-row-' + rowIndex.toString())
    }
    .width('100%')
    .padding(this.vs(TAOBAO_BANNER_PAD))
    .backgroundColor(Color.White)
    .borderRadius(this.vs(TAOBAO_CARD_RADIUS))
  }

  // 「淘宝好价」楼层

  @Builder
  floorTitleRow() {
    Row({ space: this.vs(6) }) {
      Text('淘宝好价')
        .fontSize(this.vs(18))
        .fontWeight(FontWeight.Bold)
        .fontColor(TAOBAO_TEXT_MAIN)

      Text('每天0点上新')
        .fontSize(this.vs(TAOBAO_DEAL_SOLD_FONT))
        .fontColor(TAOBAO_TEXT_GRAY)
        .padding({ left: this.vs(6), right: this.vs(6), top: this.vs(2), bottom: this.vs(2) })
        .backgroundColor('#FFF0E8')
        .borderRadius(this.vs(9))

      Blank()

      Text('更多好价')
        .fontSize(this.vs(TAOBAO_DEAL_SOLD_FONT))
        .fontColor(TAOBAO_TEXT_GRAY)

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(this.vs(12))
        .fontColor([TAOBAO_TEXT_GRAY])
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  dealProductCard(dealProduct: TaobaoDealProduct) {
    Column() {
      Stack({ alignContent: Alignment.TopStart }) {
        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width('100%')
            .height(this.vs(TAOBAO_DEAL_IMAGE_HEIGHT))
            .linearGradient({
              angle: 135,
              colors: [[dealProduct.dealTintFrom, 0.0], [dealProduct.dealTintTo, 1.0]]
            })

          SymbolGlyph(dealProduct.dealSymbol)
            .fontSize(this.vs(56))
            .fontColor(['#33FFFFFF'])
        }
        .width('100%')
        .height(this.vs(TAOBAO_DEAL_IMAGE_HEIGHT))

        Text(dealProduct.dealBadge)
          .fontSize(this.vs(11))
          .fontColor(Color.White)
          .padding({ left: this.vs(7), right: this.vs(7), top: this.vs(3), bottom: this.vs(3) })
          .backgroundColor(TAOBAO_BRAND_ORANGE)
          .borderRadius(this.vs(9))
          .margin(this.vs(7))
      }
      .width('100%')
      .height(this.vs(TAOBAO_DEAL_IMAGE_HEIGHT))
      .borderRadius({ topLeft: this.vs(TAOBAO_CARD_RADIUS), topRight: this.vs(TAOBAO_CARD_RADIUS) })
      .clip(true)

      Column({ space: this.vs(5) }) {
        Text(dealProduct.dealTitle)
          .fontSize(this.vs(15))
          .lineHeight(this.vs(21))
          .fontColor(TAOBAO_TEXT_MAIN)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Row() {
          Text('¥')
            .fontSize(this.vs(13))
            .fontWeight(FontWeight.Bold)
            .fontColor(TAOBAO_PRICE_RED)

          Text(dealProduct.dealPrice)
            .fontSize(this.vs(21))
            .fontWeight(FontWeight.Bold)
            .fontColor(TAOBAO_PRICE_RED)

          Text(dealProduct.dealOrigin)
            .fontSize(this.vs(12))
            .fontColor(TAOBAO_TEXT_GRAY)
            .decoration({ type: TextDecorationType.LineThrough, color: '#B0B0B0' })
            .margin({ left: this.vs(4) })

          Blank()

          Text(dealProduct.dealSold)
            .fontSize(this.vs(TAOBAO_DEAL_SOLD_FONT))
            .fontColor(TAOBAO_TEXT_GRAY)
            .maxLines(1)
        }
        .width('100%')
        .alignItems(VerticalAlign.Bottom)
      }
      .width('100%')
      .padding(this.vs(10))
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(this.vs(TAOBAO_CARD_RADIUS))
    .clip(true)
    .alignItems(HorizontalAlign.Start)
  }

  /** 好价楼层：标题行 + 2×2 商品卡 */
  @Builder
  dealFloor() {
    Column({ space: this.vs(10) }) {
      this.floorTitleRow()

      ForEach(TAOBAO_DEAL_ROW_INDEXES, (rowIndex: number) => {
        Row({ space: this.vs(10) }) {
          ForEach(this.dealsOfRow(rowIndex), (dealProduct: TaobaoDealProduct) => {
            this.dealProductCard(dealProduct)
          }, (dealProduct: TaobaoDealProduct) => dealProduct.dealId)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
      }, (rowIndex: number) => 'taobao-deal-row-' + rowIndex.toString())
    }
    .width('100%')
  }

  // 底部 TabBar（固定尺寸）

  @Builder
  tabBarItem(tabEntry: TaobaoTabEntry) {
    Column({ space: 3 }) {
      SymbolGlyph(tabEntry.tabSymbol)
        .fontSize(22)
        .fontColor([tabEntry.tabActive ? TAOBAO_BRAND_ORANGE : '#5C5C5C'])

      Text(tabEntry.tabLabel)
        .fontSize(10.5)
        .fontColor(tabEntry.tabActive ? TAOBAO_BRAND_ORANGE : '#5C5C5C')
        .maxLines(1)
    }
    .layoutWeight(1)
    .height(TAOBAO_TAB_BAR_HEIGHT)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  bottomTabBar() {
    Row() {
      ForEach(TAOBAO_TABS, (tabEntry: TaobaoTabEntry) => {
        this.tabBarItem(tabEntry)
      }, (tabEntry: TaobaoTabEntry) => tabEntry.tabId)
    }
    .width('100%')
    .height(TAOBAO_TAB_BAR_HEIGHT)
    .backgroundColor(Color.White)
    .alignItems(VerticalAlign.Center)
  }

  build() {
    NavDestination() {
      Column() {
        // ① 橙色渐变头部：固定尺寸（padding.top 让出状态栏）
        Column() {
          this.searchRow()
        }
        .width('100%')
        .padding({ top: this.statusBarHeightVp })
        .linearGradient({ angle: 180, colors: [[TAOBAO_HEADER_TOP, 0.0], [TAOBAO_HEADER_BOTTOM, 1.0]] })

        // ② 内容区：banner / 图标 / 好价楼层全部随窗口宽度等比放大
        Scroll() {
          Column({ space: this.vs(TAOBAO_SECTION_GAP) }) {
            this.promoBanner()

            this.iconGridCard()

            this.dealFloor()
          }
          .width('100%')
          .padding({
            left: this.vs(TAOBAO_CONTENT_PAD),
            right: this.vs(TAOBAO_CONTENT_PAD),
            top: this.vs(TAOBAO_SECTION_GAP),
            bottom: this.vs(TAOBAO_SECTION_GAP)
          })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .backgroundColor(TAOBAO_PAGE_BG)

        // ③ 底部 TabBar + 手势区避让
        Column() {
          this.bottomTabBar()
        }
        .width('100%')
        .padding({ bottom: this.bottomInsetVp })
        .backgroundColor(Color.White)
      }
      .width('100%')
      .height('100%')
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
