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
 * 反例：未避让安全区 / 京东首页轮播压状态栏（状态栏）
 *
 * 复刻京东 App 首页：顶部红色头部（扫码入口、白色搜索胶囊「折叠屏 保护壳」、扫一扫与消息），
 * 红橙渐变的轮播大图（「跨店每满299减50」促销文案 + 轮播圆点），下方是白色金刚区
 * （两排共 10 个分类入口）、京东秒杀横排（时间段 + 三个秒杀商品）、双列商品卡片
 * （四张带渐变占位图的商品卡），以及底部五个页签。
 *
 * 设计基准：单屏态 459.6×672vp（1264×1848px，密度 2.75），vp = px / 2.75。
 *   顶部固定条：高 238vp（不随窗口宽度变化），红底；
 *           条内内容底对齐、按 sceneScale = 窗口宽 / 459.6 等比放大：
 *           搜索行 40vp、间距 10vp、轮播 banner 140vp（合计 190vp）；
 *           左右留白 12.7vp、搜索胶囊圆角 20vp、banner 圆角 10vp；
 *   金刚区：白卡高 148vp（图标 30vp + 标题 12vp，两排，行距 14vp，上下留白 14vp）；
 *   秒杀卡：头部行 34vp + 商品行 82vp（缩略图 66×66vp、价格 15vp）；
 *   商品卡：宽 211.6vp、占位图高 150vp、标题两行 13.5vp、价格 17vp；
 *   底部页签：固定 64vp，三态都不缩放；
 *   除顶部条高度与页签外，所有尺寸按窗口宽度等比放大。
 *
 * 三态实测（同一套设计值，按窗口宽度换算；状态栏占屏幕顶部约 0～40vp）：
 *   单屏态      459.6×672vp   —— ×1.000：搜索行 y 48～88、banner y 98～238，都在状态栏下方
 *   双屏态竖屏  664.7×939.6vp —— ×1.446：搜索行 y -36.7～20.2 被顶进状态栏；
 *                                banner y 35.6～238，顶端已探入状态栏
 *   双屏态横屏  939.6×664.7vp —— ×2.044：搜索行整条被推出屏幕外；
 *                                banner y -48.2～238，轮播大图顶到屏幕顶端
 *
 * 问题表现（双屏态）：
 *   顶部内容不避让状态栏：展开 / 横屏后轮播 banner 放大到顶出屏幕上沿，「跨店每满299减50」
 *   促销文字与状态栏的时间、电量图标叠在一起；搜索行更是被整体推出屏幕。
 *   单屏态下页面完全正常。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 单屏态窗口宽度（1264px / 密度 2.75），整页横向尺寸的基准 */
const JH_BASE_WIDTH: number = 459.6;

/** 配色 */
const JH_PAGE_BG: string = '#F4F5F7';
const JH_HEADER_RED_TOP: string = '#F83B4B';
const JH_HEADER_RED_BOTTOM: string = '#E01F2F';
const JH_BANNER_TOP: string = '#FF9A4D';
const JH_BANNER_BOTTOM: string = '#F0323F';
const JH_TEXT: string = '#1A1A1A';
const JH_SUBTEXT: string = '#999999';
const JH_PRICE_RED: string = '#E22E2E';
const JH_SECKILL_RED: string = '#E8332D';

/** 顶部固定条：高度不随窗口宽度变化；条内内容底对齐并整体等比放大 */
const JH_TOP_BAND: number = 238;
const JH_HEADER_SIDE: number = 12.7;
const JH_SEARCH_ROW: number = 40;
const JH_SEARCH_GAP: number = 10;
const JH_BANNER_HEIGHT: number = 140;
const JH_SEARCH_RADIUS: number = 20;
const JH_BANNER_RADIUS: number = 10;

/** 金刚区 */
const JH_CATEGORY_CARD_HEIGHT: number = 148;
const JH_CATEGORY_ICON: number = 30;
const JH_CATEGORY_FONT: number = 12;
const JH_CATEGORY_ROW_GAP: number = 14;
const JH_CATEGORY_PAD: number = 14;

/** 秒杀卡 */
const JH_SECKILL_HEAD: number = 34;
const JH_SECKILL_THUMB: number = 66;
const JH_SECKILL_AREA: number = 82;

/** 商品卡 */
const JH_PRODUCT_WIDTH: number = 211.6;
const JH_PRODUCT_IMAGE: number = 150;

/** 卡片通用：左右留白、间距、圆角 */
const JH_CARD_SIDE: number = 12.7;
const JH_CARD_GAP: number = 11;
const JH_CARD_RADIUS: number = 10;

/** 底部页签固定高度（三态一致） */
const JH_TAB_BAR_HEIGHT: number = 64;

/** 金刚区图标 */
interface JdHomeCategoryIcon {
  iconKey: string;
  iconLabel: string;
  iconSymbol: Resource;
  iconTint: string;
}

/** 金刚区一行（两排共 10 个入口） */
interface JdHomeCategoryRow {
  rowKey: string;
  rowIcons: JdHomeCategoryIcon[];
}

/** 秒杀商品 */
interface JdSeckillItem {
  itemKey: string;
  itemPrice: string;
  itemTag: string;
  itemTopColor: string;
  itemBottomColor: string;
}

/** 商品卡 */
interface JdProductCard {
  cardKey: string;
  cardTitle: string;
  cardPrice: string;
  cardSold: string;
  cardTopColor: string;
  cardBottomColor: string;
}

/** 底部页签 */
interface JdHomeTab {
  tabKey: string;
  tabLabel: string;
  tabSymbol: Resource;
  tabActive: boolean;
}

@Component
export struct JdHomeBannerStatusBarPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽度（vp），随折叠 / 旋转实时更新；整页缩放比由它算出 */
  @State winWidthVp: number = JH_BASE_WIDTH;

  /** 窗口高度（vp） */
  @State winHeightVp: number = 672;

  private contentScroller: Scroller = new Scroller();
  private pageActive: boolean = false;
  private windowToken: number = 0;

  private categoryRows: JdHomeCategoryRow[] = [];
  private seckillItems: JdSeckillItem[] = [];
  private productCards: JdProductCard[] = [];
  private homeTabs: JdHomeTab[] = [];

  aboutToAppear(): void {
    this.pageActive = true;
    this.buildPageData();
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

  private buildPageData(): void {
    this.categoryRows = [
      {
        rowKey: 'jd-cat-row-1',
        rowIcons: [
          { iconKey: 'jd-cat-market', iconLabel: '京东超市', iconSymbol: $r('sys.symbol.store'), iconTint: '#E8614C' },
          { iconKey: 'jd-cat-global', iconLabel: '京东国际', iconSymbol: $r('sys.symbol.building'), iconTint: '#4C7DE8' },
          { iconKey: 'jd-cat-digital', iconLabel: '数码电器', iconSymbol: $r('sys.symbol.camera'), iconTint: '#3E9BE8' },
          { iconKey: 'jd-cat-fresh', iconLabel: '京东生鲜', iconSymbol: $r('sys.symbol.leaf'), iconTint: '#4BB056' },
          { iconKey: 'jd-cat-home', iconLabel: '京东到家', iconSymbol: $r('sys.symbol.bag_fill'), iconTint: '#F09A3E' }
        ]
      },
      {
        rowKey: 'jd-cat-row-2',
        rowIcons: [
          { iconKey: 'jd-cat-recharge', iconLabel: '充值缴费', iconSymbol: $r('sys.symbol.creditcard'), iconTint: '#8C6FE8' },
          { iconKey: 'jd-cat-coupon', iconLabel: '领券中心', iconSymbol: $r('sys.symbol.gift_fill'), iconTint: '#E84C6F' },
          { iconKey: 'jd-cat-nine', iconLabel: '9.9包邮', iconSymbol: $r('sys.symbol.ticket_fill'), iconTint: '#E8A13F' },
          { iconKey: 'jd-cat-travel', iconLabel: '京东旅行', iconSymbol: $r('sys.symbol.airplane'), iconTint: '#37B0C9' },
          { iconKey: 'jd-cat-all', iconLabel: '全部频道', iconSymbol: $r('sys.symbol.square_grid_2x2'), iconTint: '#8C8C9C' }
        ]
      }
    ];

    this.seckillItems = [
      { itemKey: 'jd-sec-phone', itemPrice: '¥129', itemTag: '直降', itemTopColor: '#FFC24D', itemBottomColor: '#FF8A3C' },
      { itemKey: 'jd-sec-case', itemPrice: '¥59', itemTag: '秒杀', itemTopColor: '#8ED0FF', itemBottomColor: '#4C9BE8' },
      { itemKey: 'jd-sec-cable', itemPrice: '¥9.9', itemTag: '爆款', itemTopColor: '#B7E58A', itemBottomColor: '#5CB54E' }
    ];

    this.productCards = [
      {
        cardKey: 'jd-prod-hinge',
        cardTitle: '折叠屏铰链保护壳 全包防摔 磨砂手感 支持无线充电',
        cardPrice: '¥129',
        cardSold: '已售3000+',
        cardTopColor: '#FFD9B8',
        cardBottomColor: '#FF9C6E'
      },
      {
        cardKey: 'jd-prod-film',
        cardTitle: '折叠屏专用柔性膜 两片装 无气泡 高透防指纹',
        cardPrice: '¥39.9',
        cardSold: '已售1万+',
        cardTopColor: '#C9E8FF',
        cardBottomColor: '#7AB8F0'
      },
      {
        cardKey: 'jd-prod-charger',
        cardTitle: '65W 氮化镓快充头 双C口 适配折叠屏平板手机',
        cardPrice: '¥89',
        cardSold: '已售5000+',
        cardTopColor: '#FFE3A6',
        cardBottomColor: '#F5B84E'
      },
      {
        cardKey: 'jd-prod-stand',
        cardTitle: '折叠屏悬停支架 铝合金桌面懒人支架 可调节',
        cardPrice: '¥69',
        cardSold: '已售2000+',
        cardTopColor: '#D7C8FF',
        cardBottomColor: '#9A7FE8'
      }
    ];

    this.homeTabs = [
      { tabKey: 'jd-tab-home', tabLabel: '首页', tabSymbol: $r('sys.symbol.house_fill'), tabActive: true },
      { tabKey: 'jd-tab-sort', tabLabel: '分类', tabSymbol: $r('sys.symbol.square_grid_2x2'), tabActive: false },
      { tabKey: 'jd-tab-find', tabLabel: '发现', tabSymbol: $r('sys.symbol.camera'), tabActive: false },
      { tabKey: 'jd-tab-cart', tabLabel: '购物车', tabSymbol: $r('sys.symbol.cart'), tabActive: false },
      { tabKey: 'jd-tab-mine', tabLabel: '我的', tabSymbol: $r('sys.symbol.person'), tabActive: false }
    ];
  }

  /** 整页缩放比：窗口宽度 / 单屏态宽度（459.6vp） */
  private sceneScale(): number {
    if (this.winWidthVp <= 0) {
      return 1;
    }
    return this.winWidthVp / JH_BASE_WIDTH;
  }

  /** 把按单屏态量出的设计值换算到当前窗口 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  // ------------------------------------------------------------------
  // 顶部固定条：搜索行 + 轮播 banner（底对齐，随窗口宽度整体放大）
  // ------------------------------------------------------------------

  @Builder
  searchEntry(iconRes: Resource, iconLabel: string) {
    Column({ space: this.vs(3) }) {
      SymbolGlyph(iconRes)
        .fontSize(this.vs(19))
        .fontColor([Color.White])

      Text(iconLabel)
        .fontSize(this.vs(9.5))
        .fontColor(Color.White)
        .maxLines(1)
    }
    .width(this.vs(38))
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  searchRow() {
    Row({ space: this.vs(9) }) {
      this.searchEntry($r('sys.symbol.qrcode'), '扫一扫')

      Row({ space: this.vs(6) }) {
        SymbolGlyph($r('sys.symbol.magnifyingglass'))
          .fontSize(this.vs(15))
          .fontColor(['#8C8C8C'])

        Text('折叠屏 保护壳')
          .fontSize(this.vs(12.5))
          .fontColor('#8C8C8C')
          .maxLines(1)

        Blank()

        SymbolGlyph($r('sys.symbol.camera'))
          .fontSize(this.vs(15))
          .fontColor(['#8C8C8C'])
      }
      .layoutWeight(1)
      .height(this.vs(28))
      .padding({ left: this.vs(12), right: this.vs(12) })
      .backgroundColor(Color.White)
      .borderRadius(this.vs(JH_SEARCH_RADIUS / 2 + 2))
      .alignItems(VerticalAlign.Center)

      this.searchEntry($r('sys.symbol.message'), '消息')
    }
    .width('100%')
    .height(this.vs(JH_SEARCH_ROW))
    .padding({ left: this.vs(JH_HEADER_SIDE), right: this.vs(JH_HEADER_SIDE) })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  bannerDots() {
    Row({ space: this.vs(4) }) {
      Row()
        .width(this.vs(10))
        .height(this.vs(3))
        .borderRadius(this.vs(1.5))
        .backgroundColor('#FFFFFF')

      Row()
        .width(this.vs(3))
        .height(this.vs(3))
        .borderRadius(this.vs(1.5))
        .backgroundColor('#80FFFFFF')

      Row()
        .width(this.vs(3))
        .height(this.vs(3))
        .borderRadius(this.vs(1.5))
        .backgroundColor('#80FFFFFF')
    }
    .margin({ bottom: this.vs(8) })
  }

  @Builder
  bannerBlock() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        Text('限时直降 · 跨店每满299减50')
          .fontSize(this.vs(18))
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .maxLines(1)

        Text('10月20日 20:00 开抢 · 抢先加购')
          .fontSize(this.vs(11))
          .fontColor('#E8FFFFFF')
          .maxLines(1)
          .margin({ top: this.vs(5) })
      }
      .width('100%')
      .padding({ left: this.vs(14), top: this.vs(12) })
      .alignItems(HorizontalAlign.Start)

      this.bannerDots()
    }
    .width('100%')
    .height(this.vs(JH_BANNER_HEIGHT))
    .margin({ left: this.vs(JH_HEADER_SIDE), right: this.vs(JH_HEADER_SIDE) })
    .borderRadius(this.vs(JH_BANNER_RADIUS))
    .linearGradient({ angle: 135, colors: [[JH_BANNER_TOP, 0.0], [JH_BANNER_BOTTOM, 1.0]] })
  }

  @Builder
  topBand() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        this.searchRow()

        Row()
          .height(this.vs(JH_SEARCH_GAP))

        this.bannerBlock()
      }
      .width('100%')
    }
    .width('100%')
    .height(JH_TOP_BAND)
    .linearGradient({ angle: 135, colors: [[JH_HEADER_RED_TOP, 0.0], [JH_HEADER_RED_BOTTOM, 1.0]] })
  }

  // ------------------------------------------------------------------
  // 金刚区
  // ------------------------------------------------------------------

  @Builder
  categoryIconCell(cat: JdHomeCategoryIcon) {
    Column({ space: this.vs(8) }) {
      SymbolGlyph(cat.iconSymbol)
        .fontSize(this.vs(JH_CATEGORY_ICON))
        .fontColor([cat.iconTint])

      Text(cat.iconLabel)
        .fontSize(this.vs(JH_CATEGORY_FONT))
        .fontColor(JH_TEXT)
        .maxLines(1)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  categoryCard() {
    Column() {
      ForEach(this.categoryRows, (catRow: JdHomeCategoryRow) => {
        Row() {
          ForEach(catRow.rowIcons, (cat: JdHomeCategoryIcon) => {
            this.categoryIconCell(cat)
          }, (cat: JdHomeCategoryIcon) => cat.iconKey)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)

        if (catRow.rowKey === 'jd-cat-row-1') {
          Row()
            .height(this.vs(JH_CATEGORY_ROW_GAP))
        }
      }, (catRow: JdHomeCategoryRow) => catRow.rowKey)
    }
    .width(this.vs(JH_BASE_WIDTH - JH_CARD_SIDE * 2))
    .height(this.vs(JH_CATEGORY_CARD_HEIGHT))
    .padding({ left: this.vs(JH_CATEGORY_PAD), right: this.vs(JH_CATEGORY_PAD), top: this.vs(JH_CATEGORY_PAD) })
    .backgroundColor(Color.White)
    .borderRadius(this.vs(JH_CARD_RADIUS))
    .margin({ bottom: this.vs(JH_CARD_GAP) })
  }

  // ------------------------------------------------------------------
  // 京东秒杀
  // ------------------------------------------------------------------

  @Builder
  seckillTimeChip(chipText: string, chipActive: boolean) {
    Text(chipText)
      .fontSize(this.vs(10))
      .fontColor(chipActive ? Color.White : '#666666')
      .height(this.vs(18))
      .padding({ left: this.vs(7), right: this.vs(7) })
      .borderRadius(this.vs(9))
      .backgroundColor(chipActive ? JH_SECKILL_RED : '#F2F2F2')
      .textAlign(TextAlign.Center)
  }

  @Builder
  seckillItem(item: JdSeckillItem) {
    Column({ space: this.vs(6) }) {
      Stack({ alignContent: Alignment.TopStart }) {
        Row()
          .width(this.vs(JH_SECKILL_THUMB))
          .height(this.vs(JH_SECKILL_THUMB))
          .borderRadius(this.vs(8))
          .linearGradient({ angle: 135, colors: [[item.itemTopColor, 0.0], [item.itemBottomColor, 1.0]] })

        Text(item.itemTag)
          .fontSize(this.vs(9))
          .fontColor(Color.White)
          .padding({ left: this.vs(5), right: this.vs(5), top: this.vs(2), bottom: this.vs(2) })
          .borderRadius(this.vs(8))
          .backgroundColor('#E84C3D')
          .margin({ left: this.vs(4), top: this.vs(4) })
      }
      .width(this.vs(JH_SECKILL_THUMB))
      .height(this.vs(JH_SECKILL_THUMB))

      Text(item.itemPrice)
        .fontSize(this.vs(15))
        .fontWeight(FontWeight.Bold)
        .fontColor(JH_SECKILL_RED)
        .maxLines(1)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  seckillCard() {
    Column() {
      Row({ space: this.vs(6) }) {
        SymbolGlyph($r('sys.symbol.flame'))
          .fontSize(this.vs(18))
          .fontColor([JH_SECKILL_RED])

        Text('京东秒杀')
          .fontSize(this.vs(15))
          .fontWeight(FontWeight.Bold)
          .fontColor(JH_TEXT)

        Row({ space: this.vs(4) }) {
          this.seckillTimeChip('12:00 已开抢', true)
          this.seckillTimeChip('14:00', false)
          this.seckillTimeChip('16:00', false)
        }
        .alignItems(VerticalAlign.Center)
        .margin({ left: this.vs(4) })

        Blank()

        Row({ space: this.vs(1) }) {
          Text('更多')
            .fontSize(this.vs(11))
            .fontColor(JH_SUBTEXT)

          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontSize(this.vs(11))
            .fontColor([JH_SUBTEXT])
        }
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height(this.vs(JH_SECKILL_HEAD))
      .alignItems(VerticalAlign.Center)

      Row() {
        ForEach(this.seckillItems, (item: JdSeckillItem) => {
          this.seckillItem(item)
        }, (item: JdSeckillItem) => item.itemKey)
      }
      .width('100%')
      .height(this.vs(JH_SECKILL_AREA))
      .padding({ left: this.vs(6), right: this.vs(6) })
      .alignItems(VerticalAlign.Top)
    }
    .width(this.vs(JH_BASE_WIDTH - JH_CARD_SIDE * 2))
    .height(this.vs(JH_SECKILL_HEAD + JH_SECKILL_AREA))
    .padding({ left: this.vs(12), right: this.vs(12), top: this.vs(2) })
    .backgroundColor(Color.White)
    .borderRadius(this.vs(JH_CARD_RADIUS))
    .margin({ bottom: this.vs(JH_CARD_GAP) })
  }

  // ------------------------------------------------------------------
  // 商品卡片
  // ------------------------------------------------------------------

  @Builder
  productCard(card: JdProductCard) {
    Column() {
      Row()
        .width('100%')
        .height(this.vs(JH_PRODUCT_IMAGE))
        .borderRadius({ topLeft: this.vs(JH_CARD_RADIUS), topRight: this.vs(JH_CARD_RADIUS) })
        .linearGradient({ angle: 160, colors: [[card.cardTopColor, 0.0], [card.cardBottomColor, 1.0]] })

      Text(card.cardTitle)
        .fontSize(this.vs(13.5))
        .fontColor(JH_TEXT)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .lineHeight(this.vs(19))
        .margin({ top: this.vs(8), left: this.vs(9), right: this.vs(9) })
        .alignSelf(ItemAlign.Stretch)

      Row() {
        Text(card.cardPrice)
          .fontSize(this.vs(17))
          .fontWeight(FontWeight.Bold)
          .fontColor(JH_PRICE_RED)

        Blank()

        Text(card.cardSold)
          .fontSize(this.vs(10.5))
          .fontColor(JH_SUBTEXT)
      }
      .width('100%')
      .margin({ top: this.vs(7), left: this.vs(9), right: this.vs(9), bottom: this.vs(10) })
      .alignItems(VerticalAlign.Bottom)
    }
    .width(this.vs(JH_PRODUCT_WIDTH))
    .backgroundColor(Color.White)
    .borderRadius(this.vs(JH_CARD_RADIUS))
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: this.vs(JH_CARD_GAP) })
  }

  @Builder
  productGrid() {
    Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Start }) {
      ForEach(this.productCards, (card: JdProductCard) => {
        this.productCard(card)
      }, (card: JdProductCard) => card.cardKey)
    }
    .width(this.vs(JH_BASE_WIDTH - JH_CARD_SIDE * 2))
  }

  // ------------------------------------------------------------------
  // 底部页签（固定尺寸）
  // ------------------------------------------------------------------

  @Builder
  tabItem(tab: JdHomeTab) {
    Column({ space: 3 }) {
      SymbolGlyph(tab.tabSymbol)
        .fontSize(22)
        .fontColor([tab.tabActive ? JH_SECKILL_RED : '#333333'])

      Text(tab.tabLabel)
        .fontSize(10)
        .fontColor(tab.tabActive ? JH_SECKILL_RED : '#333333')
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  tabBar() {
    Row() {
      ForEach(this.homeTabs, (tab: JdHomeTab) => {
        this.tabItem(tab)
      }, (tab: JdHomeTab) => tab.tabKey)
    }
    .width('100%')
    .height(JH_TAB_BAR_HEIGHT)
    .backgroundColor(Color.White)
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        Column() {
          this.topBand()

          Scroll(this.contentScroller) {
            Column() {
              this.categoryCard()
              this.seckillCard()
              this.productGrid()

              Row()
                .height(JH_TAB_BAR_HEIGHT)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.None)
          .align(Alignment.Top)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(JH_PAGE_BG)

        Column() {
          this.tabBar()
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.End)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(JH_PAGE_BG)
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
