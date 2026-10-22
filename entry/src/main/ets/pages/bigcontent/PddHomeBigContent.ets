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
 * 反例：大图大字 / 拼多多首页大字大图
 *
 * 复刻拼多多首页：红色头部（搜索框 + 消息）、「百亿补贴」大 banner
 * （红金渐变色块 + 大字标题 + 补贴角标）、10 个圆形分类入口（2 行 × 5 列：
 * 多多果园 / 现金签到 / 9块9包邮 / 多多视频 / 多多买菜 / 领现金 / 多多国际 /
 * 看小说 / 充值中心 / 天天领现金）、双列百亿补贴商品卡（渐变大图 + 两行标题 +
 * 大字红色价格 + 已拼件数）与底部 TabBar。
 * banner 与商品图使用 resources/base/media 下的图片资源（bc_pdd_*）。
 *
 * 设计基准：单屏态截图 459.6×672vp（1264×1848px，密度 2.75）。
 * banner 高 132vp、分类图标圆 44vp、商品卡图高 160vp、
 * 商品标题字号 15vp、价格字号 24vp、banner 主标题字号 32vp。
 *
 * 三个屏态的实测结果（内容区所有尺寸与字号随窗口宽度等比放大）：
 *   单屏态        459.6×672vp   —— banner 高 132vp、商品图高 160vp，一屏看两行商品
 *   双屏态竖屏    664.7×939.6vp —— banner 高 192vp（×1.45）、商品图高 232vp、
 *                                 价格字号 35vp，一屏只剩一行商品
 *   双屏态横屏    939.6×664.7vp —— banner 高 270vp（×2.04）、商品图高 327vp、
 *                                 价格字号 49vp，一张商品图就占掉近半屏高，
 *                                 一屏只剩一张图；头部与 TabBar 仍是单屏态大小，
 *                                 中间巨大上下小，页面像被整体吹胀
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 单屏态窗口宽度（1264px / 密度 2.75）：内容区所有尺寸的基准宽度 */
const PDD_HOME_BASE_WIDTH: number = 459.6;
/** 单屏态窗口高度（1848px / 密度 2.75）：拿不到窗口高度时兜底 */
const PDD_HOME_BASE_HEIGHT: number = 672;

/** 头部（固定尺寸，不随内容区放大）：搜索行高 / 搜索框高 / 头部左右留白 */
const PDD_SEARCH_ROW_HEIGHT: number = 46;
const PDD_SEARCH_BAR_HEIGHT: number = 34;
const PDD_HEADER_PAD: number = 12;

/** 内容区（随窗口宽度等比放大）：左右留白 / 卡片圆角 / 楼层间距 / banner 内边距 */
const PDD_CONTENT_PAD: number = 12;
const PDD_CARD_RADIUS: number = 12;
const PDD_SECTION_GAP: number = 10;
const PDD_BANNER_PAD: number = 18;
/** banner 主标题字号（角标 12 / 副标题 15 / 图标 54 均随窗口等比放大） */
const PDD_BANNER_TITLE_FONT: number = 32;

/** 分类图标：圆底 44vp（图标 23 / 标签 12 / 行距 12 均随窗口等比放大）与列数 */
const PDD_ICON_CIRCLE: number = 44;
const PDD_ICON_GRID_COLUMNS: number = 5;

/** 商品卡：图高 160vp / 标题 15 / 价格 24 / 已拼 12 / 角标 11 / 列数，均随窗口等比放大 */
const PDD_GOODS_IMAGE_HEIGHT: number = 160;
const PDD_GOODS_TITLE_FONT: number = 15;
const PDD_GOODS_PRICE_FONT: number = 24;
const PDD_GOODS_SOLD_FONT: number = 12;
const PDD_GOODS_COLUMNS: number = 2;

/** 底部 TabBar 内容高度（不含手势区） */
const PDD_TAB_BAR_HEIGHT: number = 52;

/** 状态栏 / 底部手势区兜底高度（vp），拿不到避让区时使用 */
const PDD_STATUS_BAR_FALLBACK: number = 32;
const PDD_BOTTOM_INSET_FALLBACK: number = 8;

/** 配色 */
const PDD_PAGE_BG: string = '#F5F5F5';
const PDD_HEADER_RED: string = '#E02E24';
const PDD_HEADER_RED_DEEP: string = '#C71F1F';
const PDD_TEXT_MAIN: string = '#1A1A1A';
const PDD_TEXT_GRAY: string = '#999999';
const PDD_PRICE_RED: string = '#E02E24';
const PDD_BADGE_GOLD: string = '#FFD161';

/** 分类入口：浅色圆底 + 主题色 SymbolGlyph */
interface PddCategoryEntry {
  entryId: string;
  entryLabel: string;
  entrySymbol: Resource;
  entryBgTint: string;
  entryGlyphTint: string;
}

/** 单屏态首页金刚区：2 行 × 5 列共 10 个入口 */
const PDD_CATEGORY_ENTRIES: PddCategoryEntry[] = [
  { entryId: 'orchard', entryLabel: '多多果园', entrySymbol: $r('sys.symbol.leaf'), entryBgTint: '#D4F0E4', entryGlyphTint: '#2E9E6F' },
  { entryId: 'cash-sign', entryLabel: '现金签到', entrySymbol: $r('sys.symbol.wallet'), entryBgTint: '#FFE9C4', entryGlyphTint: '#B98A1E' },
  { entryId: 'nine-nine', entryLabel: '9块9包邮', entrySymbol: $r('sys.symbol.bag_fill'), entryBgTint: '#FFE4D6', entryGlyphTint: '#E85D2E' },
  { entryId: 'video', entryLabel: '多多视频', entrySymbol: $r('sys.symbol.camera'), entryBgTint: '#E4DFF8', entryGlyphTint: '#7A5FE8' },
  { entryId: 'maicai', entryLabel: '多多买菜', entrySymbol: $r('sys.symbol.drop_fill'), entryBgTint: '#D6F4F0', entryGlyphTint: '#1E9E94' },
  { entryId: 'cash', entryLabel: '领现金', entrySymbol: $r('sys.symbol.gift_fill'), entryBgTint: '#FFDCE0', entryGlyphTint: '#E8445E' },
  { entryId: 'global', entryLabel: '多多国际', entrySymbol: $r('sys.symbol.map'), entryBgTint: '#D6E8FF', entryGlyphTint: '#3E7FE8' },
  { entryId: 'novel', entryLabel: '看小说', entrySymbol: $r('sys.symbol.doc_plaintext_and_pencil'), entryBgTint: '#EAE2D6', entryGlyphTint: '#8A6F4D' },
  { entryId: 'recharge', entryLabel: '充值中心', entrySymbol: $r('sys.symbol.creditcard'), entryBgTint: '#D9F2D0', entryGlyphTint: '#3FA45B' },
  { entryId: 'daily-cash', entryLabel: '天天领现金', entrySymbol: $r('sys.symbol.star'), entryBgTint: '#FFF0C7', entryGlyphTint: '#C87C1E' }
];

/** 百亿补贴商品卡：商品图使用 resources/base/media 下的 bc_pdd_goods_* 图片资源 */
interface PddDealGoods {
  goodsId: string;
  goodsTitle: string;
  goodsPrice: string;
  goodsSold: string;
  goodsTag: string;
  goodsImage: Resource;
}

/** 百亿补贴楼层：双列共 4 张商品卡 */
const PDD_DEAL_GOODS: PddDealGoods[] = [
  { goodsId: 'phone-case', goodsTitle: '苹果16手机壳 磨砂防摔全包透明保护壳新品', goodsPrice: '9.9', goodsSold: '已拼10万+件', goodsTag: '百亿补贴', goodsImage: $r('app.media.bc_pdd_goods_case') },
  { goodsId: 'blueberry', goodsTitle: '云南蓝莓当季新鲜水果 125g×6盒大果装', goodsPrice: '19.9', goodsSold: '已拼5万+件', goodsTag: '万人团', goodsImage: $r('app.media.bc_pdd_goods_blueberry') },
  { goodsId: 'earphone', goodsTitle: '无线蓝牙耳机迷你隐形运动睡眠入耳式', goodsPrice: '25.9', goodsSold: '已拼8万+件', goodsTag: '百亿补贴', goodsImage: $r('app.media.bc_pdd_goods_earphone') },
  { goodsId: 'slipper', goodsTitle: '夏季居家防滑拖鞋 男女同款浴室凉拖', goodsPrice: '12.9', goodsSold: '已拼3万+件', goodsTag: '万人团', goodsImage: $r('app.media.bc_pdd_goods_slipper') }
];

/** 底部 TabBar：第一个「首页」为选中态 */
interface PddTabEntry {
  tabId: string;
  tabLabel: string;
  tabSymbol: Resource;
  tabActive: boolean;
}

const PDD_TABS: PddTabEntry[] = [
  { tabId: 'tab-home', tabLabel: '首页', tabSymbol: $r('sys.symbol.house'), tabActive: true },
  { tabId: 'tab-video', tabLabel: '多多视频', tabSymbol: $r('sys.symbol.camera'), tabActive: false },
  { tabId: 'tab-chat', tabLabel: '聊天', tabSymbol: $r('sys.symbol.message'), tabActive: false },
  { tabId: 'tab-mine', tabLabel: '个人中心', tabSymbol: $r('sys.symbol.person'), tabActive: false }
];

/** 分类入口 10 个按 5 列折行后的行序号（2 行） */
const PDD_CATEGORY_ROW_INDEXES: number[] = [0, 1];
/** 商品卡 4 张按 2 列折行后的行序号（2 行） */
const PDD_GOODS_ROW_INDEXES: number[] = [0, 1];

@Component
export struct PddHomeBigContentPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = PDD_HOME_BASE_WIDTH;
  @State winHeightVp: number = PDD_HOME_BASE_HEIGHT;
  /** 沉浸式下的状态栏 / 底部手势区高度（vp） */
  @State statusBarHeightVp: number = PDD_STATUS_BAR_FALLBACK;
  @State bottomInsetVp: number = PDD_BOTTOM_INSET_FALLBACK;

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
      this.windowToken = WindowModeController.acquire(win, PDD_HEADER_RED);
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
    return this.winWidthVp / PDD_HOME_BASE_WIDTH;
  }

  /** 把单屏态设计值放大到当前窗口宽度 */
  private vs(dimension: number): number {
    return dimension * this.sceneScale();
  }

  /** 取分类入口区第 rowIndex 行（10 个入口按 5 列折行） */
  private categoryEntriesOfRow(rowIndex: number): PddCategoryEntry[] {
    const startIndex: number = rowIndex * PDD_ICON_GRID_COLUMNS;
    return PDD_CATEGORY_ENTRIES.slice(startIndex, startIndex + PDD_ICON_GRID_COLUMNS);
  }

  /** 取商品卡区第 rowIndex 行（4 张卡按 2 列折行） */
  private goodsOfRow(rowIndex: number): PddDealGoods[] {
    const startIndex: number = rowIndex * PDD_GOODS_COLUMNS;
    return PDD_DEAL_GOODS.slice(startIndex, startIndex + PDD_GOODS_COLUMNS);
  }

  // 头部（固定尺寸，不随内容区放大）

  @Builder
  searchRow() {
    Row({ space: 10 }) {
      Row({ space: 6 }) {
        SymbolGlyph($r('sys.symbol.magnifyingglass'))
          .fontSize(16)
          .fontColor(['#5C5C5C'])

        Text('男装潮牌')
          .fontSize(15)
          .fontColor('#3A3A3A')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)

        SymbolGlyph($r('sys.symbol.camera'))
          .fontSize(17)
          .fontColor(['#3A3A3A'])
      }
      .height(PDD_SEARCH_BAR_HEIGHT)
      .padding({ left: 12, right: 12 })
      .backgroundColor(Color.White)
      .borderRadius(PDD_SEARCH_BAR_HEIGHT / 2)
      .layoutWeight(1)
      .alignItems(VerticalAlign.Center)

      SymbolGlyph($r('sys.symbol.message'))
        .fontSize(22)
        .fontColor([Color.White])
    }
    .width('100%')
    .height(PDD_SEARCH_ROW_HEIGHT)
    .padding({ left: PDD_HEADER_PAD, right: PDD_HEADER_PAD })
    .alignItems(VerticalAlign.Center)
  }

  // 百亿补贴 banner：标题、角标、图标全部随窗口宽度等比放大

  @Builder
  subsidyBanner() {
    Stack({ alignContent: Alignment.Center }) {
      Image($r('app.media.bc_pdd_banner'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .borderRadius(this.vs(16))
        .clip(true)

      Row() {
        Column({ space: this.vs(7) }) {
          Text('官方直降 · 全场包邮')
            .fontSize(this.vs(12))
            .fontColor(PDD_BADGE_GOLD)
            .padding({ left: this.vs(7), right: this.vs(7), top: this.vs(2), bottom: this.vs(2) })
            .border({ width: 1, color: '#66FFD161' })
            .borderRadius(this.vs(12))

          Text('百亿补贴')
            .fontSize(this.vs(PDD_BANNER_TITLE_FONT))
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .maxLines(1)

          Text('万人团 · 全场一折起')
            .fontSize(this.vs(15))
            .fontColor('#FFD9D5')
            .maxLines(1)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width(this.vs(78))
            .height(this.vs(78))
            .backgroundColor('#33FFFFFF')
            .borderRadius(this.vs(39))

          SymbolGlyph($r('sys.symbol.ticket_fill'))
            .fontSize(this.vs(54))
            .fontColor([PDD_BADGE_GOLD])
        }
        .width(this.vs(78))
        .height(this.vs(78))
      }
      .width('100%')
      .height(this.vs(132))
      .padding({ left: this.vs(PDD_BANNER_PAD), right: this.vs(PDD_BANNER_PAD) })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(this.vs(132))
    .borderRadius(this.vs(16))
    .clip(true)
  }

  // 分类入口区：圆底 + SymbolGlyph，圆底直径随窗口宽度放大

  @Builder
  categoryEntryCell(entryItem: PddCategoryEntry) {
    Column({ space: this.vs(6) }) {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width(this.vs(PDD_ICON_CIRCLE))
          .height(this.vs(PDD_ICON_CIRCLE))
          .backgroundColor(entryItem.entryBgTint)
          .borderRadius(this.vs(PDD_ICON_CIRCLE / 2))

        SymbolGlyph(entryItem.entrySymbol)
          .fontSize(this.vs(23))
          .fontColor([entryItem.entryGlyphTint])
      }
      .width(this.vs(PDD_ICON_CIRCLE))
      .height(this.vs(PDD_ICON_CIRCLE))

      Text(entryItem.entryLabel)
        .fontSize(this.vs(12))
        .fontColor(PDD_TEXT_MAIN)
        .maxLines(1)
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }

  /** 入口区白底卡片：2 行 × 5 列 */
  @Builder
  categoryGridCard() {
    Column({ space: this.vs(12) }) {
      ForEach(PDD_CATEGORY_ROW_INDEXES, (rowIndex: number) => {
        Row() {
          ForEach(this.categoryEntriesOfRow(rowIndex), (entryItem: PddCategoryEntry) => {
            this.categoryEntryCell(entryItem)
          }, (entryItem: PddCategoryEntry) => entryItem.entryId)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
      }, (rowIndex: number) => 'pdd-category-row-' + rowIndex.toString())
    }
    .width('100%')
    .padding(this.vs(PDD_BANNER_PAD))
    .backgroundColor(Color.White)
    .borderRadius(this.vs(PDD_CARD_RADIUS))
  }

  // 百亿补贴商品卡：大图 + 大字价格随窗口宽度放大，横屏一屏只剩一张图

  @Builder
  goodsCard(goodsItem: PddDealGoods) {
    Column() {
      Stack({ alignContent: Alignment.TopStart }) {
        Image(goodsItem.goodsImage)
          .width('100%')
          .height(this.vs(PDD_GOODS_IMAGE_HEIGHT))
          .objectFit(ImageFit.Cover)

        Text(goodsItem.goodsTag)
          .fontSize(this.vs(11))
          .fontColor(Color.White)
          .padding({ left: this.vs(7), right: this.vs(7), top: this.vs(3), bottom: this.vs(3) })
          .backgroundColor(PDD_PRICE_RED)
          .borderRadius(this.vs(9))
          .margin(this.vs(7))
      }
      .width('100%')
      .height(this.vs(PDD_GOODS_IMAGE_HEIGHT))
      .borderRadius({ topLeft: this.vs(PDD_CARD_RADIUS), topRight: this.vs(PDD_CARD_RADIUS) })
      .clip(true)

      Column({ space: this.vs(6) }) {
        Text(goodsItem.goodsTitle)
          .fontSize(this.vs(PDD_GOODS_TITLE_FONT))
          .lineHeight(this.vs(21))
          .fontColor(PDD_TEXT_MAIN)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Row() {
          Text('¥')
            .fontSize(this.vs(13))
            .fontWeight(FontWeight.Bold)
            .fontColor(PDD_PRICE_RED)

          Text(goodsItem.goodsPrice)
            .fontSize(this.vs(PDD_GOODS_PRICE_FONT))
            .fontWeight(FontWeight.Bold)
            .fontColor(PDD_PRICE_RED)

          Blank()

          Text(goodsItem.goodsSold)
            .fontSize(this.vs(PDD_GOODS_SOLD_FONT))
            .fontColor(PDD_TEXT_GRAY)
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
    .borderRadius(this.vs(PDD_CARD_RADIUS))
    .clip(true)
    .alignItems(HorizontalAlign.Start)
  }

  /** 百亿补贴楼层：双列商品卡 */
  @Builder
  goodsFloor() {
    Column({ space: this.vs(10) }) {
      ForEach(PDD_GOODS_ROW_INDEXES, (rowIndex: number) => {
        Row({ space: this.vs(10) }) {
          ForEach(this.goodsOfRow(rowIndex), (goodsItem: PddDealGoods) => {
            this.goodsCard(goodsItem)
          }, (goodsItem: PddDealGoods) => goodsItem.goodsId)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
      }, (rowIndex: number) => 'pdd-goods-row-' + rowIndex.toString())
    }
    .width('100%')
  }

  // 底部 TabBar（固定尺寸）

  @Builder
  tabBarItem(tabEntry: PddTabEntry) {
    Column({ space: 3 }) {
      SymbolGlyph(tabEntry.tabSymbol)
        .fontSize(22)
        .fontColor([tabEntry.tabActive ? PDD_HEADER_RED : '#5C5C5C'])

      Text(tabEntry.tabLabel)
        .fontSize(10.5)
        .fontColor(tabEntry.tabActive ? PDD_HEADER_RED : '#5C5C5C')
        .maxLines(1)
    }
    .layoutWeight(1)
    .height(PDD_TAB_BAR_HEIGHT)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  bottomTabBar() {
    Row() {
      ForEach(PDD_TABS, (tabEntry: PddTabEntry) => {
        this.tabBarItem(tabEntry)
      }, (tabEntry: PddTabEntry) => tabEntry.tabId)
    }
    .width('100%')
    .height(PDD_TAB_BAR_HEIGHT)
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
        .linearGradient({ angle: 180, colors: [[PDD_HEADER_RED, 0.0], [PDD_HEADER_RED_DEEP, 1.0]] })

        // ② 内容区：banner / 分类入口 / 商品卡全部随窗口宽度等比放大
        Scroll() {
          Column({ space: this.vs(PDD_SECTION_GAP) }) {
            this.subsidyBanner()

            this.categoryGridCard()

            this.goodsFloor()
          }
          .width('100%')
          .padding({
            left: this.vs(PDD_CONTENT_PAD),
            right: this.vs(PDD_CONTENT_PAD),
            top: this.vs(PDD_SECTION_GAP),
            bottom: this.vs(PDD_SECTION_GAP)
          })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .backgroundColor(PDD_PAGE_BG)

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
