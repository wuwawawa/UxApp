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
 * 反例：大图大字 / 京东首页金刚区放大
 *
 * 复刻京东首页：红色渐变头部（京东 logo + 搜索框 + 消息）、「家电焕新季」
 * banner、金刚区 10 个彩色圆角图标（2 行 × 5 列：京东超市 / 数码电器 /
 * 京东服饰 / 京东生鲜 / 京东国际 / 京东拍卖 / 充值缴费 / 京东到家 /
 * 品牌闪购 / 领券中心）、京东秒杀楼层（标题 + 场次胶囊 + 3 个秒杀商品）、
 * 双列 Feed 商品卡与底部 TabBar；banner 与商品图使用
 * resources/base/media 下的图片资源（bc_jd_*）。
 *
 * 设计基准：单屏态截图 459.6×672vp（1264×1848px，密度 2.75）。
 * banner 高 118vp、金刚区图标 48vp、秒杀图高 90vp、Feed 图高 150vp、
 * 金刚区标签字号 12vp、Feed 标题字号 15vp、价格字号 20vp。
 *
 * 三个屏态的实测结果（内容区所有尺寸与字号随窗口宽度等比放大）：
 *   单屏态        459.6×672vp   —— 金刚区图标 48vp，一屏能看全金刚区 + 秒杀行
 *   双屏态竖屏    664.7×939.6vp —— 图标 70vp（×1.45）、秒杀图高 131vp，Feed 被推到下沿
 *   双屏态横屏    939.6×664.7vp —— 图标 98vp（×2.04）被放大两倍，一屏放不下
 *                                 一组入口，秒杀与 Feed 被挤出屏幕；头部与
 *                                 TabBar 仍是单屏态大小，中间巨大上下小
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 单屏态窗口宽度（1264px / 密度 2.75）：内容区所有尺寸的基准宽度 */
const JD_ICON_BASE_WIDTH: number = 459.6;
/** 单屏态窗口高度（1848px / 密度 2.75）：拿不到窗口高度时兜底 */
const JD_ICON_BASE_HEIGHT: number = 672;

/** 头部（固定尺寸，不随内容区放大）：搜索行高 / 搜索框高 / 头部左右留白 */
const JD_SEARCH_ROW_HEIGHT: number = 46;
const JD_SEARCH_BAR_HEIGHT: number = 34;
const JD_HEADER_PAD: number = 12;

/** 内容区（随窗口宽度等比放大）：左右留白 / 卡片圆角 / 楼层间距 */
const JD_CONTENT_PAD: number = 12;
const JD_CARD_RADIUS: number = 12;
const JD_SECTION_GAP: number = 10;
/** banner 内边距（高 118 / 圆角 16 / 主标题 28 / 副标题 15 / 图标 52 均随窗口等比放大） */
const JD_BANNER_PAD: number = 18;

/** 金刚区：图标 48vp（圆角 14 / 图标字号 25 / 标签 12 / 行距 14 均随窗口等比放大）与列数 */
const JD_KINGKONG_ICON: number = 48;
const JD_KINGKONG_COLUMNS: number = 5;

/** 秒杀行：图高 90vp（标题 13 / 价格 17 / 场次胶囊字号 11 均随窗口等比放大） */
const JD_SECKILL_IMAGE_HEIGHT: number = 90;

/** Feed 楼层：图高 150vp / 列数（标题 15 / 价格 20 / 角标 11 均随窗口等比放大） */
const JD_FEED_IMAGE_HEIGHT: number = 150;
const JD_FEED_COLUMNS: number = 2;

/** 底部 TabBar 内容高度（不含手势区） */
const JD_TAB_BAR_HEIGHT: number = 52;

/** 状态栏 / 底部手势区兜底高度（vp），拿不到避让区时使用 */
const JD_STATUS_BAR_FALLBACK: number = 32;
const JD_BOTTOM_INSET_FALLBACK: number = 8;

/** 配色 */
const JD_PAGE_BG: string = '#F4F4F4';
const JD_HEADER_RED: string = '#F2270C';
const JD_TEXT_MAIN: string = '#1A1A1A';
const JD_TEXT_GRAY: string = '#999999';
const JD_PRICE_RED: string = '#E1251B';

/** 金刚区入口：渐变圆角块 + 白色 SymbolGlyph */
interface JdKingKongEntry {
  entryId: string;
  entryLabel: string;
  entrySymbol: Resource;
  entryTintFrom: string;
  entryTintTo: string;
}

/** 单屏态首页金刚区：2 行 × 5 列共 10 个入口 */
const JD_KINGKONG_ENTRIES: JdKingKongEntry[] = [
  { entryId: 'market', entryLabel: '京东超市', entrySymbol: $r('sys.symbol.bag_fill'), entryTintFrom: '#35C07E', entryTintTo: '#23A467' },
  { entryId: 'digital', entryLabel: '数码电器', entrySymbol: $r('sys.symbol.qrcode'), entryTintFrom: '#4A90E8', entryTintTo: '#3167C4' },
  { entryId: 'clothes', entryLabel: '京东服饰', entrySymbol: $r('sys.symbol.person'), entryTintFrom: '#E86FA8', entryTintTo: '#C94A85' },
  { entryId: 'fresh', entryLabel: '京东生鲜', entrySymbol: $r('sys.symbol.leaf'), entryTintFrom: '#63C7A0', entryTintTo: '#3BA37C' },
  { entryId: 'global', entryLabel: '京东国际', entrySymbol: $r('sys.symbol.map'), entryTintFrom: '#8A6FE8', entryTintTo: '#6A4FCC' },
  { entryId: 'auction', entryLabel: '京东拍卖', entrySymbol: $r('sys.symbol.star_rosette'), entryTintFrom: '#E8A13F', entryTintTo: '#C97F1E' },
  { entryId: 'recharge', entryLabel: '充值缴费', entrySymbol: $r('sys.symbol.creditcard'), entryTintFrom: '#F2B33C', entryTintTo: '#D9951F' },
  { entryId: 'daojia', entryLabel: '京东到家', entrySymbol: $r('sys.symbol.bicycle'), entryTintFrom: '#4AC0E8', entryTintTo: '#2E9BC9' },
  { entryId: 'flash', entryLabel: '品牌闪购', entrySymbol: $r('sys.symbol.clock'), entryTintFrom: '#E85D5D', entryTintTo: '#C93B3B' },
  { entryId: 'coupon', entryLabel: '领券中心', entrySymbol: $r('sys.symbol.ticket_fill'), entryTintFrom: '#6FC6A8', entryTintTo: '#4A9E80' }
];

/** 秒杀 / Feed 商品：商品图用 resources/base/media 下的 bc_jd_* 图片资源 */
interface JdPromoGoodsItem {
  goodsId: string;
  goodsTitle: string;
  goodsPrice: string;
  /** 商品卡左上角角标（自营 / 秒杀 等） */
  goodsTag: string;
  goodsImage: Resource;
}

/** 京东秒杀行：3 个秒杀商品 */
const JD_SECKILL_GOODS: JdPromoGoodsItem[] = [
  { goodsId: 'sk-phone', goodsTitle: '红米Note13 5G 全网通智能手机', goodsPrice: '899', goodsTag: '秒杀价', goodsImage: $r('app.media.bc_jd_sk_phone') },
  { goodsId: 'sk-earphone', goodsTitle: '真无线蓝牙耳机 主动降噪版', goodsPrice: '149', goodsTag: '限量', goodsImage: $r('app.media.bc_jd_sk_earphone') },
  { goodsId: 'sk-cooker', goodsTitle: '美的电饭煲 4L 智能预约', goodsPrice: '199', goodsTag: '爆款', goodsImage: $r('app.media.bc_jd_sk_cooker') }
];

/** 「为你推荐」Feed：双列共 4 张商品卡 */
const JD_FEED_GOODS: JdPromoGoodsItem[] = [
  { goodsId: 'feed-tv', goodsTitle: '海信电视 65英寸4K超高清智慧屏', goodsPrice: '2399', goodsTag: '自营', goodsImage: $r('app.media.bc_jd_feed_tv') },
  { goodsId: 'feed-fridge', goodsTitle: '海尔冰箱 501升风冷无霜双开门', goodsPrice: '3299', goodsTag: '自营', goodsImage: $r('app.media.bc_jd_feed_fridge') },
  { goodsId: 'feed-washer', goodsTitle: '小天鹅滚筒洗衣机 10公斤变频', goodsPrice: '1899', goodsTag: '秒杀', goodsImage: $r('app.media.bc_jd_feed_washer') },
  { goodsId: 'feed-ac', goodsTitle: '格力空调 大1.5匹 新一级能效', goodsPrice: '2699', goodsTag: '自营', goodsImage: $r('app.media.bc_jd_feed_ac') }
];

/** 底部 TabBar：第一个「首页」为选中态 */
interface JdTabEntry {
  tabId: string;
  tabLabel: string;
  tabSymbol: Resource;
  tabActive: boolean;
}

const JD_TABS: JdTabEntry[] = [
  { tabId: 'tab-home', tabLabel: '首页', tabSymbol: $r('sys.symbol.house'), tabActive: true },
  { tabId: 'tab-category', tabLabel: '分类', tabSymbol: $r('sys.symbol.square_grid_2x2'), tabActive: false },
  { tabId: 'tab-cart', tabLabel: '购物车', tabSymbol: $r('sys.symbol.cart'), tabActive: false },
  { tabId: 'tab-mine', tabLabel: '我的', tabSymbol: $r('sys.symbol.person'), tabActive: false }
];

/** 金刚区 10 个入口按 5 列折行后的行序号（2 行） */
const JD_KINGKONG_ROW_INDEXES: number[] = [0, 1];
/** Feed 4 张商品卡按 2 列折行后的行序号（2 行） */
const JD_FEED_ROW_INDEXES: number[] = [0, 1];

@Component
export struct JdHomeBigIconPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = JD_ICON_BASE_WIDTH;
  @State winHeightVp: number = JD_ICON_BASE_HEIGHT;
  /** 沉浸式下的状态栏 / 底部手势区高度（vp） */
  @State statusBarHeightVp: number = JD_STATUS_BAR_FALLBACK;
  @State bottomInsetVp: number = JD_BOTTOM_INSET_FALLBACK;

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
      this.windowToken = WindowModeController.acquire(win, JD_HEADER_RED);
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
    return this.winWidthVp / JD_ICON_BASE_WIDTH;
  }

  /** 把单屏态设计值放大到当前窗口宽度 */
  private vs(dimension: number): number {
    return dimension * this.sceneScale();
  }

  /** 取金刚区第 rowIndex 行（10 个入口按 5 列折行） */
  private kingkongEntriesOfRow(rowIndex: number): JdKingKongEntry[] {
    const startIndex: number = rowIndex * JD_KINGKONG_COLUMNS;
    return JD_KINGKONG_ENTRIES.slice(startIndex, startIndex + JD_KINGKONG_COLUMNS);
  }

  /** 取 Feed 第 rowIndex 行的商品（4 张卡按 2 列折行） */
  private feedsOfRow(rowIndex: number): JdPromoGoodsItem[] {
    const startIndex: number = rowIndex * JD_FEED_COLUMNS;
    return JD_FEED_GOODS.slice(startIndex, startIndex + JD_FEED_COLUMNS);
  }

  // 头部（固定尺寸，不随内容区放大）

  @Builder
  searchRow() {
    Row({ space: 10 }) {
      Text('京东')
        .fontSize(19)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)

      Row({ space: 6 }) {
        SymbolGlyph($r('sys.symbol.magnifyingglass'))
          .fontSize(16)
          .fontColor(['#5C5C5C'])

        Text('手机')
          .fontSize(15)
          .fontColor('#3A3A3A')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
      }
      .height(JD_SEARCH_BAR_HEIGHT)
      .padding({ left: 12, right: 12 })
      .backgroundColor(Color.White)
      .borderRadius(JD_SEARCH_BAR_HEIGHT / 2)
      .layoutWeight(1)
      .alignItems(VerticalAlign.Center)

      SymbolGlyph($r('sys.symbol.message'))
        .fontSize(22)
        .fontColor([Color.White])
    }
    .width('100%')
    .height(JD_SEARCH_ROW_HEIGHT)
    .padding({ left: JD_HEADER_PAD, right: JD_HEADER_PAD })
    .alignItems(VerticalAlign.Center)
  }

  // 大促 banner：标题、角标、图标全部随窗口宽度等比放大

  @Builder
  promoBanner() {
    Stack({ alignContent: Alignment.Center }) {
      Image($r('app.media.bc_jd_banner'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .borderRadius(this.vs(16))
        .clip(true)

      Row() {
        Column({ space: this.vs(8) }) {
          Text('家电焕新季')
            .fontSize(this.vs(28))
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .maxLines(1)

          Text('以旧换新 · 至高补贴20%')
            .fontSize(this.vs(15))
            .fontColor('#FFE0C7')
            .maxLines(1)

          Text('¥999起')
            .fontSize(this.vs(18))
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width(this.vs(72))
            .height(this.vs(72))
            .backgroundColor('#33FFFFFF')
            .borderRadius(this.vs(36))

          SymbolGlyph($r('sys.symbol.gift_fill'))
            .fontSize(this.vs(52))
            .fontColor([Color.White])
        }
        .width(this.vs(72))
        .height(this.vs(72))
      }
      .width('100%')
      .height(this.vs(118))
      .padding({ left: this.vs(JD_BANNER_PAD), right: this.vs(JD_BANNER_PAD) })
      .borderRadius(this.vs(16))
      .alignItems(VerticalAlign.Center)
      .clip(true)
    }
    .width('100%')
    .height(this.vs(118))
  }

  // 金刚区：渐变圆角图标随窗口宽度放大，横屏下每个图标巨大到占满首屏

  @Builder
  kingkongEntryCell(entryItem: JdKingKongEntry) {
    Column({ space: this.vs(7) }) {
      Stack({ alignContent: Alignment.Center }) {
        SymbolGlyph(entryItem.entrySymbol)
          .fontSize(this.vs(25))
          .fontColor([Color.White])
      }
      .width(this.vs(JD_KINGKONG_ICON))
      .height(this.vs(JD_KINGKONG_ICON))
      .linearGradient({ angle: 135, colors: [[entryItem.entryTintFrom, 0.0], [entryItem.entryTintTo, 1.0]] })
      .borderRadius(this.vs(14))

      Text(entryItem.entryLabel)
        .fontSize(this.vs(12))
        .fontColor(JD_TEXT_MAIN)
        .maxLines(1)
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }

  /** 金刚区白底卡片：2 行 × 5 列 */
  @Builder
  kingkongGridCard() {
    Column({ space: this.vs(14) }) {
      ForEach(JD_KINGKONG_ROW_INDEXES, (rowIndex: number) => {
        Row() {
          ForEach(this.kingkongEntriesOfRow(rowIndex), (entryItem: JdKingKongEntry) => {
            this.kingkongEntryCell(entryItem)
          }, (entryItem: JdKingKongEntry) => entryItem.entryId)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
      }, (rowIndex: number) => 'jd-kingkong-row-' + rowIndex.toString())
    }
    .width('100%')
    .padding(this.vs(JD_BANNER_PAD))
    .backgroundColor(Color.White)
    .borderRadius(this.vs(JD_CARD_RADIUS))
  }

  // 京东秒杀：标题行 + 3 个秒杀商品，图高与字号随窗口宽度放大

  @Builder
  seckillGoodsCell(goodsItem: JdPromoGoodsItem) {
    Column({ space: this.vs(5) }) {
      Image(goodsItem.goodsImage)
        .width('100%')
        .height(this.vs(JD_SECKILL_IMAGE_HEIGHT))
        .objectFit(ImageFit.Cover)
        .borderRadius(this.vs(JD_CARD_RADIUS))

      Text(goodsItem.goodsTitle)
        .fontSize(this.vs(13))
        .fontColor(JD_TEXT_MAIN)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')

      Row() {
        Text('¥')
          .fontSize(this.vs(11))
          .fontWeight(FontWeight.Bold)
          .fontColor(JD_PRICE_RED)

        Text(goodsItem.goodsPrice)
          .fontSize(this.vs(17))
          .fontWeight(FontWeight.Bold)
          .fontColor(JD_PRICE_RED)
      }
      .width('100%')
      .alignItems(VerticalAlign.Bottom)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  seckillCard() {
    Column({ space: this.vs(10) }) {
      Row({ space: this.vs(6) }) {
        Text('京东秒杀')
          .fontSize(this.vs(17))
          .fontWeight(FontWeight.Bold)
          .fontColor(JD_PRICE_RED)

        Text('12:00场 距结束 02:41:19')
          .fontSize(this.vs(11))
          .fontColor(JD_TEXT_GRAY)
          .maxLines(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Row({ space: this.vs(10) }) {
        ForEach(JD_SECKILL_GOODS, (goodsItem: JdPromoGoodsItem) => {
          this.seckillGoodsCell(goodsItem)
        }, (goodsItem: JdPromoGoodsItem) => goodsItem.goodsId)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .padding(this.vs(JD_BANNER_PAD))
    .backgroundColor(Color.White)
    .borderRadius(this.vs(JD_CARD_RADIUS))
  }

  // 「为你推荐」Feed：双列商品卡，图高与价格字号随窗口宽度放大

  @Builder
  feedGoodsCard(feedItem: JdPromoGoodsItem) {
    Column() {
      Stack({ alignContent: Alignment.TopStart }) {
        Image(feedItem.goodsImage)
          .width('100%')
          .height(this.vs(JD_FEED_IMAGE_HEIGHT))
          .objectFit(ImageFit.Cover)

        Text(feedItem.goodsTag)
          .fontSize(this.vs(11))
          .fontColor(Color.White)
          .padding({ left: this.vs(7), right: this.vs(7), top: this.vs(3), bottom: this.vs(3) })
          .backgroundColor(JD_PRICE_RED)
          .borderRadius(this.vs(9))
          .margin(this.vs(7))
      }
      .width('100%')
      .height(this.vs(JD_FEED_IMAGE_HEIGHT))
      .borderRadius({ topLeft: this.vs(JD_CARD_RADIUS), topRight: this.vs(JD_CARD_RADIUS) })
      .clip(true)

      Column({ space: this.vs(5) }) {
        Text(feedItem.goodsTitle)
          .fontSize(this.vs(15))
          .lineHeight(this.vs(21))
          .fontColor(JD_TEXT_MAIN)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Row() {
          Text('¥')
            .fontSize(this.vs(12))
            .fontWeight(FontWeight.Bold)
            .fontColor(JD_PRICE_RED)

          Text(feedItem.goodsPrice)
            .fontSize(this.vs(20))
            .fontWeight(FontWeight.Bold)
            .fontColor(JD_PRICE_RED)
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
    .borderRadius(this.vs(JD_CARD_RADIUS))
    .clip(true)
    .alignItems(HorizontalAlign.Start)
  }

  /** Feed 楼层：双列商品卡 */
  @Builder
  feedFloor() {
    Column({ space: this.vs(10) }) {
      ForEach(JD_FEED_ROW_INDEXES, (rowIndex: number) => {
        Row({ space: this.vs(10) }) {
          ForEach(this.feedsOfRow(rowIndex), (feedItem: JdPromoGoodsItem) => {
            this.feedGoodsCard(feedItem)
          }, (feedItem: JdPromoGoodsItem) => feedItem.goodsId)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
      }, (rowIndex: number) => 'jd-feed-row-' + rowIndex.toString())
    }
    .width('100%')
  }

  // 底部 TabBar（固定尺寸）

  @Builder
  tabBarItem(tabEntry: JdTabEntry) {
    Column({ space: 3 }) {
      SymbolGlyph(tabEntry.tabSymbol)
        .fontSize(22)
        .fontColor([tabEntry.tabActive ? JD_PRICE_RED : '#5C5C5C'])

      Text(tabEntry.tabLabel)
        .fontSize(10.5)
        .fontColor(tabEntry.tabActive ? JD_PRICE_RED : '#5C5C5C')
        .maxLines(1)
    }
    .layoutWeight(1)
    .height(JD_TAB_BAR_HEIGHT)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  bottomTabBar() {
    Row() {
      ForEach(JD_TABS, (tabEntry: JdTabEntry) => {
        this.tabBarItem(tabEntry)
      }, (tabEntry: JdTabEntry) => tabEntry.tabId)
    }
    .width('100%')
    .height(JD_TAB_BAR_HEIGHT)
    .backgroundColor(Color.White)
    .alignItems(VerticalAlign.Center)
  }

  build() {
    NavDestination() {
      Column() {
        // ① 红色渐变头部：固定尺寸（padding.top 让出状态栏）
        Column() {
          this.searchRow()
        }
        .width('100%')
        .padding({ top: this.statusBarHeightVp })
        .backgroundColor(JD_HEADER_RED)

        // ② 内容区：banner / 金刚区 / 秒杀 / Feed 全部随窗口宽度等比放大
        Scroll() {
          Column({ space: this.vs(JD_SECTION_GAP) }) {
            this.promoBanner()

            this.kingkongGridCard()

            this.seckillCard()

            this.feedFloor()
          }
          .width('100%')
          .padding({ left: this.vs(JD_CONTENT_PAD), right: this.vs(JD_CONTENT_PAD), top: this.vs(JD_SECTION_GAP), bottom: this.vs(JD_SECTION_GAP) })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .backgroundColor(JD_PAGE_BG)

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
