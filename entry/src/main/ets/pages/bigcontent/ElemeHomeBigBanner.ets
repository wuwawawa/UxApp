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
 * 反例：大图大字 / 饿了么首页 banner 放大
 *
 * 复刻饿了么首页：蓝色渐变头部（定位 + 搜索框 + 消息入口）、「9.9 元吃两顿」
 * 促销大 banner（右侧内嵌超级吃货豆弹窗卡）、金刚区分类网格（美食 / 甜品 /
 * 超市 / 果蔬 / 买药 / 鲜花）、超级吃货豆会员条、两列店铺卡片（门头图 +
 * 店名 + 评分月售 + 起送配送费 + 活动标签）、底部 TabBar。门头图与 banner 使用
 * resources/base/media 下的图片资源（bc_elm_*），其余装饰以渐变色块 +
 * SymbolGlyph 绘制。
 *
 * 设计基准：单屏态 459.6×672vp（1264×1848px，密度 2.75）。banner 高 112vp、
 * 吃货豆弹窗卡 96×64vp、金刚区图标圆 46vp、门头图高为列宽 × 0.56、店名字号 15.5vp。
 *
 * 三个屏态：
 *   单屏态        459.6×672vp   —— banner 112vp、门头图 209×118vp，首屏约 4 张店卡
 *   双屏态竖屏    664.7×939.6vp —— 全部 ×1.45：banner 162vp、图标圆 67vp、门头图 304×170vp
 *   双屏态横屏    939.6×664.7vp —— 全部 ×2.04：banner 229vp、吃货豆弹窗卡 196×130vp、
 *                                  门头图 427×239vp，蓝色 banner 与弹窗图放大占满首屏
 *
 * 问题表现（双屏态竖屏 / 横屏）：banner、金刚区图标、门头图与全部字号随窗口宽度
 * 整体等比放大：横屏下一张门头图 427×239vp、店名字号 31.6vp，蓝色 banner 与
 * 吃货豆弹窗卡放大到占满首屏，页面头轻脚重、留白失衡。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 单屏态窗口宽度（1264px / 密度 2.75）：banner 与内容区所有尺寸的基准宽度 */
const ELEME_BASE_WIDTH: number = 459.6;
/** 单屏态窗口高度，拿不到窗口高度时兜底 */
const ELEME_BASE_HEIGHT: number = 672;
/** 状态栏 / 底部手势区兜底高度（vp） */
const ELEME_STATUS_BAR_FALLBACK: number = 32; const ELEME_BOTTOM_INSET_FALLBACK: number = 8;
/** 配色 */
const ELEME_PAGE_BG: string = '#F5F6F7';
const ELEME_BLUE_TOP: string = '#2BB5FF'; const ELEME_BLUE_BOTTOM: string = '#0B7BF6';
const ELEME_TEXT_MAIN: string = '#1A1A1A'; const ELEME_TEXT_GRAY: string = '#8A8A8A';
const ELEME_PRICE_RED: string = '#E8372B';
/** 头部搜索行（固定尺寸，不随内容区放大，形成「上小下大」的失衡对比） */
const ELEME_SEARCH_ROW_HEIGHT: number = 44; const ELEME_HEADER_PAD: number = 12;
/** 促销 banner：高 112vp、圆角 14vp、左右留白 12vp（全部随窗口宽度放大） */
const ELEME_BANNER_HEIGHT: number = 112;
const ELEME_BANNER_RADIUS: number = 14; const ELEME_BANNER_SIDE_INSET: number = 12;
const ELEME_BANNER_BOTTOM_GAP: number = 12;
const ELEME_BANNER_TITLE_FONT: number = 23;
const ELEME_BANNER_SUB_FONT: number = 12.5; const ELEME_BANNER_TAG_FONT: number = 10;
/** banner 右侧内嵌的「超级吃货豆」弹窗卡 */
const ELEME_BEAN_CARD_WIDTH: number = 96; const ELEME_BEAN_CARD_HEIGHT: number = 64;
const ELEME_BEAN_COUNT_FONT: number = 17; const ELEME_BEAN_LABEL_FONT: number = 9.5;
/** 金刚区：白卡圆角 14vp、内边距 12vp、图标圆 46vp、两行三列 */
const ELEME_CATEGORY_CARD_RADIUS: number = 14;
const ELEME_CATEGORY_CARD_PAD: number = 12; const ELEME_CATEGORY_CARD_GAP_ABOVE: number = 12;
const ELEME_CATEGORY_ICON_SIZE: number = 46; const ELEME_CATEGORY_GLYPH: number = 24;
const ELEME_CATEGORY_LABEL_FONT: number = 12;
const ELEME_CATEGORY_ROW_GAP: number = 14; const ELEME_CATEGORY_CELL_HEIGHT: number = 78;
const ELEME_CATEGORY_COLUMNS: number = 3;
/** 超级吃货豆会员条：高 44vp、圆角 22vp（随窗口放大） */
const ELEME_MEMBER_STRIP_HEIGHT: number = 44;
const ELEME_MEMBER_STRIP_RADIUS: number = 22;
const ELEME_MEMBER_TITLE_FONT: number = 14.5;
const ELEME_MEMBER_SUB_FONT: number = 11; const ELEME_MEMBER_STRIP_GAP_ABOVE: number = 10;
/** 店铺区：左右留白 12vp、列间距 8vp、行间距 10vp、门头图高 = 列宽 × 0.56 */
const ELEME_SHOP_SIDE_INSET: number = 12;
const ELEME_SHOP_COLUMN_GAP: number = 8;
const ELEME_SHOP_ROW_GAP: number = 10;
const ELEME_SHOP_IMAGE_RATIO: number = 0.56;
const ELEME_SHOP_CARD_RADIUS: number = 10;
const ELEME_SHOP_NAME_FONT: number = 15.5;
const ELEME_SHOP_META_FONT: number = 11.5;
const ELEME_SHOP_TAG_FONT: number = 10.5;
const ELEME_SHOP_SECTION_GAP_ABOVE: number = 14; const ELEME_SHOP_SECTION_TITLE_FONT: number = 16;
const ELEME_SHOP_COLUMNS: number = 2;
/** 底部 TabBar（固定尺寸） */
const ELEME_TAB_BAR_HEIGHT: number = 52;
const ELEME_TAB_ICON: number = 22; const ELEME_TAB_LABEL_FONT: number = 10;

/** 金刚区分栏数据 */
interface ElemeCategoryEntry {
  categoryKey: string;
  categoryLabel: string;
  categorySymbol: Resource;
  /** 图标圆的渐变色 */
  categoryTintFrom: string;
  categoryTintTo: string;
}

const ELEME_CATEGORIES: ElemeCategoryEntry[] = [
  {
    categoryKey: 'food', categoryLabel: '美食', categorySymbol: $r('sys.symbol.flame_fill'),
    categoryTintFrom: '#FF9A62', categoryTintTo: '#F5484A'
  },
  {
    categoryKey: 'dessert', categoryLabel: '甜品', categorySymbol: $r('sys.symbol.gift_fill'),
    categoryTintFrom: '#FFB6D5', categoryTintTo: '#F76B8A'
  },
  {
    categoryKey: 'market', categoryLabel: '超市', categorySymbol: $r('sys.symbol.cart_fill'),
    categoryTintFrom: '#7BE495', categoryTintTo: '#29B26B'
  },
  {
    categoryKey: 'fruit', categoryLabel: '果蔬', categorySymbol: $r('sys.symbol.leaf_fill'),
    categoryTintFrom: '#C7F464', categoryTintTo: '#56AB2F'
  },
  {
    categoryKey: 'pharmacy', categoryLabel: '买药', categorySymbol: $r('sys.symbol.cross_case_fill'),
    categoryTintFrom: '#74C0FC', categoryTintTo: '#1C7ED6'
  },
  {
    categoryKey: 'flower', categoryLabel: '鲜花', categorySymbol: $r('sys.symbol.flower'),
    categoryTintFrom: '#FFD3A5', categoryTintTo: '#FD6585'
  }
];

/** 店铺卡数据：门头图使用 resources/base/media 下的图片资源（bc_elm_shop_*） */
interface ElemeShopCard {
  shopId: string;
  shopName: string;
  shopRating: string;
  shopSales: string;
  shopDelivery: string;
  shopMinOrder: string;
  shopFee: string;
  shopTagLine: string;
  shopCoverImage: Resource;
}

const ELEME_SHOPS: ElemeShopCard[] = [
  {
    shopId: 'hls', shopName: '华莱士·全鸡汉堡（科技路店）',
    shopRating: '4.6', shopSales: '月售3000+', shopDelivery: '32分钟',
    shopMinOrder: '¥20起', shopFee: '配送¥3', shopTagLine: '「满30减12」大份双人餐',
    shopCoverImage: $r('app.media.bc_elm_shop_burger')
  },
  {
    shopId: 'hsj', shopName: '张记黄焖鸡米饭（唐延路店）',
    shopRating: '4.8', shopSales: '月售5000+', shopDelivery: '28分钟',
    shopMinOrder: '¥15起', shopFee: '配送¥2.5', shopTagLine: '「满20减8」小份现炒两荤一素',
    shopCoverImage: $r('app.media.bc_elm_shop_chicken')
  },
  {
    shopId: 'mxbc', shopName: '蜜雪冰城（锦业路店）',
    shopRating: '4.7', shopSales: '月售10000+', shopDelivery: '25分钟',
    shopMinOrder: '¥10起', shopFee: '配送¥2', shopTagLine: '「第二杯半价」冰鲜柠檬水',
    shopCoverImage: $r('app.media.bc_elm_shop_tea')
  },
  {
    shopId: 'xwc', shopName: '大厨小碗菜·快餐',
    shopRating: '4.5', shopSales: '月售2000+', shopDelivery: '35分钟',
    shopMinOrder: '¥18起', shopFee: '配送¥3.5', shopTagLine: '「满25减10」每日现炒家常菜',
    shopCoverImage: $r('app.media.bc_elm_shop_bowls')
  },
  {
    shopId: 'xgq', shopName: '鲜果切·水果捞（高新店）',
    shopRating: '4.9', shopSales: '月售1500+', shopDelivery: '30分钟',
    shopMinOrder: '¥15起', shopFee: '配送¥3', shopTagLine: '「买三送一」当日鲜切果盘',
    shopCoverImage: $r('app.media.bc_elm_shop_fruit')
  },
  {
    shopId: 'gzd', shopName: '江南糕点·酥饼铺',
    shopRating: '4.8', shopSales: '月售800+', shopDelivery: '40分钟',
    shopMinOrder: '¥12起', shopFee: '配送¥4', shopTagLine: '「买五送一」现烤绿豆冰糕',
    shopCoverImage: $r('app.media.bc_elm_shop_pastry')
  }
];

/** 底部 TabBar 数据 */
interface ElemeBottomTabEntry {
  tabKey: string;
  tabLabel: string;
  tabSymbol: Resource;
  tabActive: boolean;
}

const ELEME_BOTTOM_TABS: ElemeBottomTabEntry[] = [
  { tabKey: 'home', tabLabel: '首页', tabSymbol: $r('sys.symbol.house'), tabActive: true },
  { tabKey: 'search', tabLabel: '搜索', tabSymbol: $r('sys.symbol.magnifyingglass'), tabActive: false },
  { tabKey: 'order', tabLabel: '订单', tabSymbol: $r('sys.symbol.doc_text'), tabActive: false },
  { tabKey: 'mine', tabLabel: '我的', tabSymbol: $r('sys.symbol.person'), tabActive: false }
];

@Component
export struct ElemeHomeBigBannerPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = ELEME_BASE_WIDTH;
  @State winHeightVp: number = ELEME_BASE_HEIGHT;
  /** 沉浸式下的状态栏 / 底部手势区高度（vp） */
  @State statusBarHeightVp: number = ELEME_STATUS_BAR_FALLBACK;
  @State bottomInsetVp: number = ELEME_BOTTOM_INSET_FALLBACK;

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
      // 头部是蓝色渐变，系统栏内容用白色
      this.windowToken = WindowModeController.acquire(win, '#FFFFFF');
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  /** 场景缩放比：窗口宽度 / 单屏态宽度（459.6vp），展开态约 ×1.45 / ×2.04 */
  private sceneScale(): number {
    if (this.winWidthVp <= 0) {
      return 1;
    }
    return this.winWidthVp / ELEME_BASE_WIDTH;
  }

  /** 按场景缩放比放大单屏态设计值 */
  private vs(designValue: number): number {
    return designValue * this.sceneScale();
  }

  /** 店铺卡列宽 = 可用宽度按两列均分；门头图高 = 列宽 × 0.56 */
  private shopColumnWidthVp(): number {
    const usableWidth: number = this.winWidthVp - this.vs(ELEME_SHOP_SIDE_INSET) * 2 -
      this.vs(ELEME_SHOP_COLUMN_GAP);
    return usableWidth / ELEME_SHOP_COLUMNS;
  }

  private shopCoverHeightVp(): number {
    return this.shopColumnWidthVp() * ELEME_SHOP_IMAGE_RATIO;
  }

  /** 行序号数组，交给 ForEach 逐行渲染 */
  private rowIndexesOf(rowTotal: number): number[] {
    const rowIndexes: number[] = [];
    for (let rowIndex: number = 0; rowIndex < rowTotal; rowIndex++) {
      rowIndexes.push(rowIndex);
    }
    return rowIndexes;
  }

  /** 取金刚区第 rowIndex 行的栏目 */
  private categoriesOfRow(rowIndex: number): ElemeCategoryEntry[] {
    const startIndex: number = rowIndex * ELEME_CATEGORY_COLUMNS;
    return ELEME_CATEGORIES.slice(startIndex, startIndex + ELEME_CATEGORY_COLUMNS);
  }

  /** 取店铺区第 rowIndex 行的店铺 */
  private shopsOfRow(rowIndex: number): ElemeShopCard[] {
    const startIndex: number = rowIndex * ELEME_SHOP_COLUMNS;
    return ELEME_SHOPS.slice(startIndex, startIndex + ELEME_SHOP_COLUMNS);
  }

  /** 头部：定位 + 搜索框（固定尺寸） */
  @Builder
  headerSearchRow() {
    Row() {
      Row({ space: 2 }) {
        SymbolGlyph($r('sys.symbol.pin')).fontSize(13).fontColor([Color.White])
        Text('金顶科技大厦').fontSize(13).fontWeight(FontWeight.Medium)
          .fontColor(Color.White).maxLines(1)
        SymbolGlyph($r('sys.symbol.chevron_down')).fontSize(10).fontColor([Color.White])
      }
      .alignItems(VerticalAlign.Center)
      .margin({ right: 8 })
      Row({ space: 6 }) {
        SymbolGlyph($r('sys.symbol.magnifyingglass')).fontSize(15).fontColor([Color.White])
        Text('奶酪汉堡 大份双人餐').fontSize(13.5).fontColor('#E6FFFFFF').maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis }).layoutWeight(1)
        Divider().vertical(true).height(14).strokeWidth(0.5).color('#66FFFFFF')
        Text('搜索').fontSize(13.5).fontWeight(FontWeight.Medium).fontColor(Color.White)
      }
      .height(30).padding({ left: 12, right: 12 }).backgroundColor('#33FFFFFF')
      .borderRadius(15).layoutWeight(1).alignItems(VerticalAlign.Center)
      SymbolGlyph($r('sys.symbol.message')).fontSize(21).fontColor([Color.White])
        .margin({ left: 10, right: 2 })
    }
    .width('100%')
    .height(ELEME_SEARCH_ROW_HEIGHT)
    .padding({ left: ELEME_HEADER_PAD, right: ELEME_HEADER_PAD })
    .alignItems(VerticalAlign.Center)
  }

  /** 促销 banner：右侧内嵌超级吃货豆弹窗卡（随窗口放大） */
  @Builder
  promoBanner() {
    Stack({ alignContent: Alignment.Center }) {
      // 背景大图：bc_elm_banner（media 图片资源），文字与吃货豆卡压在其上
      Image($r('app.media.bc_elm_banner'))
        .width('100%').height('100%').objectFit(ImageFit.Cover)
        .borderRadius(this.vs(ELEME_BANNER_RADIUS))
        .clip(true)
      Row() {
        Column({ space: this.vs(5) }) {
          Text('吃货节 · 限时抢').fontSize(this.vs(ELEME_BANNER_TAG_FONT)).fontColor(Color.White)
            .padding({ left: this.vs(6), right: this.vs(6), top: this.vs(2), bottom: this.vs(2) })
            .backgroundColor('#33FFFFFF').borderRadius(this.vs(8))
          Text('9.9元 两荤一素').fontSize(this.vs(ELEME_BANNER_TITLE_FONT))
            .fontWeight(FontWeight.Bold).fontColor(Color.White).maxLines(1)
          Text('大牌爆品天天领红包').fontSize(this.vs(ELEME_BANNER_SUB_FONT))
            .fontColor('#E6FFFFFF').maxLines(1)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        // 「超级吃货豆」弹窗卡：白底小卡压在 banner 右侧
        Column({ space: 2 }) {
          Text('超级吃货豆').fontSize(this.vs(ELEME_BEAN_LABEL_FONT))
            .fontColor('#8A5A00').maxLines(1)
          Row({ space: 3 }) {
            SymbolGlyph($r('sys.symbol.drop_fill'))
              .fontSize(this.vs(ELEME_BEAN_COUNT_FONT) * 0.8).fontColor(['#F5A623'])
            Text('+50').fontSize(this.vs(ELEME_BEAN_COUNT_FONT))
              .fontWeight(FontWeight.Bold).fontColor('#C77500')
          }
          .alignItems(VerticalAlign.Bottom)
          Text('下单即返').fontSize(this.vs(ELEME_BEAN_LABEL_FONT))
            .fontColor('#8A5A00').maxLines(1)
        }
        .width(this.vs(ELEME_BEAN_CARD_WIDTH)).height(this.vs(ELEME_BEAN_CARD_HEIGHT))
        .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        .backgroundColor('#F2FFFFFF').borderRadius(this.vs(12))
        .border({ width: this.vs(1), color: '#66FFFFFF' })
        .shadow({ radius: this.vs(6), color: '#1A004AA6', offsetY: this.vs(2) })
      }
      .width('100%')
      .height(this.vs(ELEME_BANNER_HEIGHT))
      .padding({ left: this.vs(16), right: this.vs(16) })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(this.vs(ELEME_BANNER_HEIGHT))
    .borderRadius(this.vs(ELEME_BANNER_RADIUS))
    .shadow({ radius: this.vs(8), color: '#1A004AA6', offsetY: this.vs(3) })
  }

  /** 金刚区分类网格：两行三列，图标圆与字号随窗口放大 */
  @Builder
  categoryCell(entry: ElemeCategoryEntry) {
    Column({ space: this.vs(6) }) {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width(this.vs(ELEME_CATEGORY_ICON_SIZE)).height(this.vs(ELEME_CATEGORY_ICON_SIZE))
          .linearGradient({ angle: 135, colors: [[entry.categoryTintFrom, 0.0], [entry.categoryTintTo, 1.0]] })
          .borderRadius(this.vs(ELEME_CATEGORY_ICON_SIZE) / 2)
        SymbolGlyph(entry.categorySymbol)
          .fontSize(this.vs(ELEME_CATEGORY_GLYPH)).fontColor([Color.White])
      }
      .width(this.vs(ELEME_CATEGORY_ICON_SIZE)).height(this.vs(ELEME_CATEGORY_ICON_SIZE))
      Text(entry.categoryLabel).fontSize(this.vs(ELEME_CATEGORY_LABEL_FONT))
        .fontColor(ELEME_TEXT_MAIN).maxLines(1)
    }
    .layoutWeight(1)
    .height(this.vs(ELEME_CATEGORY_CELL_HEIGHT))
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  categoryCard() {
    Column({ space: this.vs(ELEME_CATEGORY_ROW_GAP) }) {
      ForEach(this.rowIndexesOf(Math.ceil(ELEME_CATEGORIES.length / ELEME_CATEGORY_COLUMNS)),
        (rowIndex: number) => {
          Row() {
            ForEach(this.categoriesOfRow(rowIndex), (entry: ElemeCategoryEntry) => {
              this.categoryCell(entry)
            }, (entry: ElemeCategoryEntry) => entry.categoryKey)
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
        }, (rowIndex: number) => 'eleme-category-row-' + rowIndex.toString())
    }
    .width('100%')
    .padding(this.vs(ELEME_CATEGORY_CARD_PAD))
    .backgroundColor(Color.White)
    .borderRadius(this.vs(ELEME_CATEGORY_CARD_RADIUS))
    .margin({ top: this.vs(ELEME_CATEGORY_CARD_GAP_ABOVE) })
  }

  /** 超级吃货豆会员条（随窗口放大） */
  @Builder
  memberStrip() {
    Row({ space: this.vs(8) }) {
      SymbolGlyph($r('sys.symbol.crown_fill'))
        .fontSize(this.vs(ELEME_MEMBER_TITLE_FONT)).fontColor(['#B8860B'])
      Column({ space: 1 }) {
        Text('超级吃货豆 · 天天领现金').fontSize(this.vs(ELEME_MEMBER_TITLE_FONT))
          .fontWeight(FontWeight.Bold).fontColor('#6B4A1E').maxLines(1)
        Text('连签 7 天最高得 15 元').fontSize(this.vs(ELEME_MEMBER_SUB_FONT))
          .fontColor('#A08050').maxLines(1)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Text('去使用').fontSize(this.vs(ELEME_MEMBER_SUB_FONT)).fontWeight(FontWeight.Medium)
        .fontColor('#6B4A1E')
        .padding({ left: this.vs(10), right: this.vs(10), top: this.vs(4), bottom: this.vs(4) })
        .backgroundColor('#F2D9A0').borderRadius(this.vs(11))
      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(this.vs(ELEME_MEMBER_SUB_FONT)).fontColor(['#B8860B'])
    }
    .width('100%')
    .height(this.vs(ELEME_MEMBER_STRIP_HEIGHT))
    .padding({ left: this.vs(14), right: this.vs(12) })
    .alignItems(VerticalAlign.Center)
    .linearGradient({ angle: 90, colors: [['#FFF0C2', 0.0], ['#FFD98A', 1.0]] })
    .borderRadius(this.vs(ELEME_MEMBER_STRIP_RADIUS))
    .margin({ top: this.vs(ELEME_MEMBER_STRIP_GAP_ABOVE) })
  }

  /** 店铺卡：两列，门头图与字号随窗口放大 */
  @Builder
  shopCard(shop: ElemeShopCard) {
    Column() {
      // 门头图：resources/base/media 图片资源（bc_elm_shop_*）
      Image(shop.shopCoverImage)
        .width('100%').height(this.shopCoverHeightVp())
        .objectFit(ImageFit.Cover)
      Column({ space: this.vs(3) }) {
        Text(shop.shopName).fontSize(this.vs(ELEME_SHOP_NAME_FONT)).fontWeight(FontWeight.Medium)
          .fontColor(ELEME_TEXT_MAIN).maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis }).width('100%')
        Row({ space: this.vs(5) }) {
          SymbolGlyph($r('sys.symbol.star_fill'))
            .fontSize(this.vs(ELEME_SHOP_META_FONT) * 0.9).fontColor(['#FF9500'])
          Text(shop.shopRating).fontSize(this.vs(ELEME_SHOP_META_FONT))
            .fontWeight(FontWeight.Medium).fontColor('#FF9500').maxLines(1)
          Text(shop.shopSales).fontSize(this.vs(ELEME_SHOP_META_FONT))
            .fontColor(ELEME_TEXT_GRAY).maxLines(1)
          Blank()
          Text(shop.shopDelivery).fontSize(this.vs(ELEME_SHOP_META_FONT))
            .fontColor(ELEME_TEXT_GRAY).maxLines(1)
        }
        .width('100%').alignItems(VerticalAlign.Center)
        Text(shop.shopMinOrder + ' · ' + shop.shopFee)
          .fontSize(this.vs(ELEME_SHOP_META_FONT)).fontColor('#5A5A5A').maxLines(1)
        Text(shop.shopTagLine).fontSize(this.vs(ELEME_SHOP_TAG_FONT)).fontColor(ELEME_PRICE_RED)
          .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis }).width('100%')
      }
      .width('100%')
      .padding({ left: this.vs(8), right: this.vs(8), top: this.vs(7), bottom: this.vs(9) })
      .alignItems(HorizontalAlign.Start)
    }
    .width(this.shopColumnWidthVp())
    .backgroundColor(Color.White)
    .borderRadius(this.vs(ELEME_SHOP_CARD_RADIUS))
    .clip(true)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  shopSection() {
    Column() {
      Row({ space: this.vs(5) }) {
        SymbolGlyph($r('sys.symbol.flame_fill'))
          .fontSize(this.vs(ELEME_SHOP_SECTION_TITLE_FONT)).fontColor(['#FF6A00'])
        Text('猜你喜欢 · 为你优选').fontSize(this.vs(ELEME_SHOP_SECTION_TITLE_FONT))
          .fontWeight(FontWeight.Bold).fontColor(ELEME_TEXT_MAIN).maxLines(1)
        Blank()
        Text('更多').fontSize(this.vs(ELEME_SHOP_META_FONT)).fontColor(ELEME_TEXT_GRAY).maxLines(1)
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(this.vs(ELEME_SHOP_META_FONT)).fontColor([ELEME_TEXT_GRAY])
      }
      .width('100%')
      .margin({ top: this.vs(ELEME_SHOP_SECTION_GAP_ABOVE), bottom: this.vs(ELEME_SHOP_SECTION_GAP_ABOVE) })
      .alignItems(VerticalAlign.Center)
      Column({ space: this.vs(ELEME_SHOP_ROW_GAP) }) {
        ForEach(this.rowIndexesOf(Math.ceil(ELEME_SHOPS.length / ELEME_SHOP_COLUMNS)),
          (rowIndex: number) => {
            Row({ space: this.vs(ELEME_SHOP_COLUMN_GAP) }) {
              ForEach(this.shopsOfRow(rowIndex), (shop: ElemeShopCard) => {
                this.shopCard(shop)
              }, (shop: ElemeShopCard) => shop.shopId)
            }
            .width('100%')
            .alignItems(VerticalAlign.Top)
          }, (rowIndex: number) => 'eleme-shop-row-' + rowIndex.toString())
      }
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  /** 底部 TabBar（固定尺寸） */
  @Builder
  bottomTabBar() {
    Row() {
      ForEach(ELEME_BOTTOM_TABS, (entry: ElemeBottomTabEntry) => {
        Column({ space: 3 }) {
          SymbolGlyph(entry.tabSymbol).fontSize(ELEME_TAB_ICON)
            .fontColor([entry.tabActive ? '#0B7BF6' : '#6E6E73'])
          Text(entry.tabLabel).fontSize(ELEME_TAB_LABEL_FONT)
            .fontWeight(entry.tabActive ? FontWeight.Medium : FontWeight.Normal)
            .fontColor(entry.tabActive ? '#0B7BF6' : '#6E6E73').maxLines(1)
        }
        .layoutWeight(1)
        .height(ELEME_TAB_BAR_HEIGHT)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }, (entry: ElemeBottomTabEntry) => entry.tabKey)
    }
    .width('100%')
    .height(ELEME_TAB_BAR_HEIGHT)
    .alignItems(VerticalAlign.Center)
  }

  build() {
    NavDestination() {
      Column() {
        // ① 蓝色渐变头部：搜索行（固定）+ 促销 banner（随窗口放大）
        Column() {
          this.headerSearchRow()
          this.promoBanner()
        }
        .width('100%')
        .padding({ top: this.statusBarHeightVp,
          left: this.vs(ELEME_BANNER_SIDE_INSET), right: this.vs(ELEME_BANNER_SIDE_INSET),
          bottom: this.vs(ELEME_BANNER_BOTTOM_GAP) })
        .linearGradient({ angle: 160, colors: [[ELEME_BLUE_TOP, 0.0], [ELEME_BLUE_BOTTOM, 1.0]] })
        // ② 内容区：金刚区 / 会员条 / 店铺卡全部随窗口宽度等比放大
        Scroll() {
          Column() {
            this.categoryCard()
            this.memberStrip()
            this.shopSection()
          }
          .width('100%')
          .padding({ left: this.vs(ELEME_SHOP_SIDE_INSET), right: this.vs(ELEME_SHOP_SIDE_INSET),
            bottom: this.vs(ELEME_SHOP_ROW_GAP) })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .backgroundColor(ELEME_PAGE_BG)
        // ③ 底部 TabBar + 手势区避让（固定尺寸）
        Column() {
          this.bottomTabBar()
        }
        .width('100%')
        .padding({ bottom: this.bottomInsetVp })
        .backgroundColor(Color.White)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(ELEME_PAGE_BG)
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
