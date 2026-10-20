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
 * 反例：大图大字 / 盒马商品详情「搭配」商品网格
 *
 * 复刻盒马商品详情页：返回 + 搜索框 + 分享 / 购物车头部、商品 / 评价 / 搭配 / 详情 / 推荐
 * 频道栏、三列商品卡（商品图 + 促销标签 + 标题 + 价格 + 加购按钮）、底部店铺 / 收藏 / 咨询
 * 与「加入购物车 / 立即购买」按钮、浮在右下角的「顶部」按钮。
 * 商品图从单屏态截图逐格裁出（entry/src/main/resources/base/media/hema_match_*.jpg）。
 *
 * 设计基准：单屏态截图 1264×1848px（459.6×672vp，密度 2.75），vp = px / 2.75。
 *   头部：搜索行 82px、频道栏 99px、频道栏字高 33px；
 *   商品区：卡片左右留白 40px、卡片上下内边距 44px / 90px、卡片内边距 36px、
 *         列间距 56px、行间距 51px、固定 3 列；
 *         商品图 334×290px、促销标签字高 31px、标题字高 35px / 行高 57px、价格字高 34px；
 *   底部：操作栏 129px、按钮 112px 高、按钮字高 34px。
 *
 * 三态实测（同一张截图量出的像素值）：
 *   单屏态      459.6×672vp   —— 列宽 334px，标题字高 35px，一屏 2 行
 *   双屏态竖屏  664.7×939.6vp —— 留白 58px、列间距 82px、列宽 483px、标题字高 50px（×1.45），
 *                                促销标签字高 45px，仍是 3 列
 *   双屏态横屏  939.6×664.7vp —— 留白 82px、列间距 120px、列宽 682px、标题字高 73px（×2.04），
 *                                促销标签字高 62px，一屏只剩一行商品
 *   头部（82px 搜索框 / 33px 频道栏字）、底部按钮（112px 高 / 34px 字）与卡片上下内边距
 *   （44px / 90px）三态尺寸不变。
 *
 * 问题表现（双屏态竖屏 / 横屏）：
 *   频道栏以下的整块商品区随窗口宽度等比放大：商品图涨到 1.45 / 2.04 倍，促销标签、
 *   标题、价格的字号同步涨到 1.45 / 2.04 倍，列数却始终是 3 列；横屏下一行商品就吃掉
 *   整个屏高，标题压到操作栏上沿，而头部和底部按钮还是单屏态大小，上下小而中间巨大。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 单屏态窗口宽度（1264px / 密度 2.75）：商品区所有尺寸的基准宽度 */
const HEMA_MATCH_BASE_WIDTH: number = 459.6;
/** 单屏态窗口高度（1848px / 密度 2.75）：拿不到窗口高度时兜底 */
const HEMA_MATCH_BASE_HEIGHT: number = 672;

/** 商品区：卡片左右留白 40px、卡片下方灰边 10px、卡片内边距 36px、圆角 16px（折算 vp） */
const HEMA_CARD_SIDE_MARGIN: number = 14.5;
const HEMA_CARD_BOTTOM_GAP: number = 3.6;
const HEMA_CARD_PAD_X: number = 13.1;
/** 卡片上下内边距实测三态不变：单屏 44px / 90px、横屏 49px / —（折算 vp，不随窗口放大） */
const HEMA_CARD_PAD_TOP: number = 16;
const HEMA_CARD_PAD_BOTTOM: number = 32.7;
const HEMA_CARD_RADIUS: number = 5.8;

/** 「评价」页签的分组卡：距频道栏 18px、卡高 79px、卡与网格之间 20px（折算 vp） */
const HEMA_SECTION_MARGIN_TOP: number = 6.5;
const HEMA_SECTION_MARGIN_BOTTOM: number = 7.3;
const HEMA_SECTION_HEIGHT: number = 28.7;
const HEMA_SECTION_FONT: number = 13.1;

/** 三列网格：列间距 56px、行间距 51px */
const HEMA_GRID_COLUMNS: number = 3;
const HEMA_COLUMN_GAP: number = 20.4;
const HEMA_ROW_GAP: number = 18.5;

/** 商品卡：图区占卡片宽度 290/334，卡片圆角 12px */
const HEMA_TILE_IMAGE_RATIO: number = 290 / 334;
const HEMA_TILE_RADIUS: number = 4.4;

/** 促销标签：字高 31px → 13vp，左内边距 9px */
const HEMA_PROMO_FONT: number = 13;
const HEMA_PROMO_PAD_LEFT: number = 3.3;

/** 标题：字高 35px → 15vp，行高 57px → 20.7vp，距商品图 16px */
const HEMA_TITLE_FONT: number = 15;
const HEMA_TITLE_LINE_HEIGHT: number = 20.7;
const HEMA_TITLE_MARGIN_TOP: number = 6;

/** 价格行：数字 34px 字高 → 17vp、货币符 13vp、单位 12vp，加购按钮 67px → 24.4vp，距标题 32px */
const HEMA_PRICE_FONT: number = 17;
const HEMA_CURRENCY_FONT: number = 13;
const HEMA_UNIT_FONT: number = 12;
const HEMA_CART_BUTTON: number = 24.4;
const HEMA_PRICE_ROW_MARGIN_TOP: number = 11.6;

/** 头部：搜索行 82px → 30vp、搜索框圆角 15vp、圆形按钮 56px → 20.4vp、频道栏 99px → 36vp */
const HEMA_SEARCH_ROW_HEIGHT: number = 30;
/** 搜索行顶边到窗口顶边 129px → 46.9vp（避让区之下的那一段留白由它决定） */
const HEMA_SEARCH_ROW_TOP: number = 46.9;
const HEMA_HEADER_PAD: number = 14.5;
const HEMA_ROUND_BUTTON: number = 20.4;
const HEMA_SEARCH_RADIUS: number = 15;
const HEMA_TAB_ROW_HEIGHT: number = 36;
const HEMA_TAB_CELL_WIDTH: number = 70;
const HEMA_TAB_FONT: number = 14;
const HEMA_TAB_UNDERLINE_WIDTH: number = 20;
const HEMA_TAB_UNDERLINE_HEIGHT: number = 2.9;

/** 底部操作栏：129px → 47vp、图标 50px → 18vp、标签字高 28px → 10.2vp、按钮 112px → 40vp */
const HEMA_ACTION_BAR_HEIGHT: number = 47;
const HEMA_ACTION_ICON: number = 18;
const HEMA_ACTION_LABEL_FONT: number = 10.2;
const HEMA_BUY_BUTTON_HEIGHT: number = 40;
const HEMA_BUY_BUTTON_RADIUS: number = 20;
const HEMA_BUY_FONT: number = 14.5;

/** 右下角「顶部」按钮：圆形 90px → 33vp */
const HEMA_TOP_BUTTON: number = 33;

/** 状态栏兜底高度（vp），拿不到避让区时使用；底部手势区 78px → 28.4vp（截图上沿 1770px） */
const HEMA_STATUS_BAR_FALLBACK: number = 32;
const HEMA_BOTTOM_INSET: number = 28.4;

/** 配色 */
const HEMA_PAGE_BG: string = '#F4F4F4';
const HEMA_CARD_BG: string = '#FFFFFF';
const HEMA_TILE_BG: string = '#F8F8F8';
const HEMA_TEXT_MAIN: string = '#111111';
const HEMA_TEXT_GRAY: string = '#9E9E9E';
const HEMA_UNIT_GRAY: string = '#B3B3B3';
const HEMA_HAIRLINE: string = '#EDEDED';
const HEMA_PROMO_COLOR: string = '#F0563A';
const HEMA_PRICE_COLOR: string = '#F85030';
const HEMA_BRAND_BLUE: string = '#08A8F8';
const HEMA_BRAND_NAVY: string = '#004078';

/** 频道栏：第一项「商品」起，选中项为蓝色文字 + 下划线 */
const HEMA_CHANNEL_TABS: string[] = ['商品', '评价', '搭配', '详情', '推荐'];
/** 默认选中「搭配」，与单屏 / 横屏参考截图一致 */
const HEMA_DEFAULT_CHANNEL: string = '搭配';
/** 「评价」页签下卡片顶部带分组标题 */
const HEMA_SECTION_TITLE: string = '店铺推荐';

interface HemaMatchProduct {
  productId: string;
  /** 从单屏态截图裁出的真实商品图（334×290px） */
  productImage: Resource;
  /** 压在商品图下沿的促销标签 */
  productPromo: string;
  productTitle: string;
  productPrice: string;
  productUnit: string;
}

const HEMA_MATCH_PRODUCTS: HemaMatchProduct[] = [
  {
    productId: 'kuciao',
    productImage: $r('app.media.hema_match_kuciao'),
    productPromo: '跨店每300减50',
    productTitle: '半山农 黑苦荞茶 500g',
    productPrice: '25',
    productUnit: '/罐'
  },
  {
    productId: 'huangqi',
    productImage: $r('app.media.hema_match_huangqi'),
    productPromo: '38元任选2件',
    productTitle: '半山农 苹果黄芪水 105g 苹果黄芪水',
    productPrice: '19.9',
    productUnit: '/袋'
  },
  {
    productId: 'rose',
    productImage: $r('app.media.hema_match_rose'),
    productPromo: '跨店每300减50',
    productTitle: '半山农 冻干墨红玫瑰花茶 50g',
    productPrice: '32',
    productUnit: '/罐'
  },
  {
    productId: 'jinyin',
    productImage: $r('app.media.hema_match_jinyin'),
    productPromo: '跨店每300减50',
    productTitle: '半山农 金银花菊花茶 300g',
    productPrice: '29.9',
    productUnit: '/盒'
  },
  {
    productId: 'shanzha',
    productImage: $r('app.media.hema_match_shanzha'),
    productPromo: '跨店每300减50',
    productTitle: '半山农 山楂桑葚乌梅茶 100g',
    productPrice: '19.9',
    productUnit: '/盒'
  },
  {
    productId: 'gift',
    productImage: $r('app.media.hema_match_gift'),
    productPromo: '跨店每300减50',
    productTitle: '半山农 冻干墨红玫瑰礼盒 120g',
    productPrice: '118',
    productUnit: '/盒'
  }
];

interface HemaMatchActionEntry {
  actionLabel: string;
  actionIcon: Resource;
}

/** 底部三个功能入口：店铺 / 收藏 / 咨询 */
const HEMA_MATCH_ACTIONS: HemaMatchActionEntry[] = [
  { actionLabel: '店铺', actionIcon: $r('sys.symbol.store') },
  { actionLabel: '收藏', actionIcon: $r('sys.symbol.star') },
  { actionLabel: '咨询', actionIcon: $r('sys.symbol.headphones') }
];

@Component
export struct HemaMatchGridBigContentPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = HEMA_MATCH_BASE_WIDTH;
  @State winHeightVp: number = HEMA_MATCH_BASE_HEIGHT;
  /** 沉浸式下的状态栏高度（vp）；底部手势区按设计值固定避让 */
  @State statusBarHeightVp: number = HEMA_STATUS_BAR_FALLBACK;
  @State bottomInsetVp: number = HEMA_BOTTOM_INSET;
  /** 当前频道栏选中项 */
  @State activeChannel: string = HEMA_DEFAULT_CHANNEL;

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
      this.windowToken = WindowModeController.acquire(win, '#000000');
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  // ------------------------------------------------------------------
  // 尺寸计算
  // 商品区的每一处尺寸 = 单屏态设计值 × 窗口宽度比；头部与底部操作栏用固定值
  // ------------------------------------------------------------------

  /** 商品区缩放比：窗口宽度 / 单屏态宽度（459.6vp） */
  private contentScale(): number {
    if (this.winWidthVp <= 0) {
      return 1;
    }
    return this.winWidthVp / HEMA_MATCH_BASE_WIDTH;
  }

  /** 商品卡总宽 = 窗口宽度 - 左右留白 × 2 */
  private cardWidthVp(): number {
    return this.winWidthVp - HEMA_CARD_SIDE_MARGIN * 2 * this.contentScale();
  }

  /** 单列宽度 = 卡片内可用宽度按 3 列均分 */
  private columnWidthVp(): number {
    const innerWidth: number = this.cardWidthVp() - HEMA_CARD_PAD_X * 2 * this.contentScale() -
      HEMA_COLUMN_GAP * (HEMA_GRID_COLUMNS - 1) * this.contentScale();
    return innerWidth / HEMA_GRID_COLUMNS;
  }

  /** 商品图高度：图区占卡片宽度的 290/334，剩下 44px 给促销标签 */
  private imageHeightVp(): number {
    return this.columnWidthVp() * HEMA_TILE_IMAGE_RATIO;
  }

  private promoBandHeightVp(): number {
    return this.columnWidthVp() - this.imageHeightVp();
  }

  /** 商品行的行距：相邻两行商品图的间距 */
  private columnGapVp(): number {
    return HEMA_COLUMN_GAP * this.contentScale();
  }

  private rowGapVp(): number {
    return HEMA_ROW_GAP * this.contentScale();
  }

  /** 商品卡分几行 */
  private productRowCount(): number {
    return Math.ceil(HEMA_MATCH_PRODUCTS.length / HEMA_GRID_COLUMNS);
  }

  /** 行序号数组，交给 ForEach 逐行渲染 */
  private productRowIndexes(): number[] {
    const rowIndexes: number[] = [];
    for (let rowIndex: number = 0; rowIndex < this.productRowCount(); rowIndex++) {
      rowIndexes.push(rowIndex);
    }
    return rowIndexes;
  }

  /** 取第 rowIndex 行的商品 */
  private productsOfRow(rowIndex: number): HemaMatchProduct[] {
    const startIndex: number = rowIndex * HEMA_GRID_COLUMNS;
    return HEMA_MATCH_PRODUCTS.slice(startIndex, startIndex + HEMA_GRID_COLUMNS);
  }

  // ------------------------------------------------------------------
  // 头部：固定尺寸，不随商品区放大
  // ------------------------------------------------------------------

  @Builder
  backButton() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width(HEMA_ROUND_BUTTON)
        .height(HEMA_ROUND_BUTTON)
        .backgroundColor(Color.White)
        .borderRadius(HEMA_ROUND_BUTTON / 2)
        .border({ width: 1, color: HEMA_HAIRLINE })

      SymbolGlyph($r('sys.symbol.chevron_left'))
        .fontSize(12)
        .fontColor([HEMA_TEXT_MAIN])
    }
    .width(HEMA_ROUND_BUTTON)
    .height(HEMA_ROUND_BUTTON)
    .onClick(() => {
      this.pageStack.pop();
    })
  }

  @Builder
  roundIconButton(icon: Resource) {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width(HEMA_ROUND_BUTTON)
        .height(HEMA_ROUND_BUTTON)
        .backgroundColor(Color.White)
        .borderRadius(HEMA_ROUND_BUTTON / 2)
        .border({ width: 1, color: HEMA_HAIRLINE })

      SymbolGlyph(icon)
        .fontSize(13)
        .fontColor([HEMA_TEXT_MAIN])
    }
    .width(HEMA_ROUND_BUTTON)
    .height(HEMA_ROUND_BUTTON)
  }

  /** 购物车按钮：右上角挂红色角标 */
  @Builder
  cartButton() {
    Stack({ alignContent: Alignment.TopEnd }) {
      this.roundIconButton($r('sys.symbol.cart'))

      Text('12')
        .fontSize(9)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .height(12.5)
        .padding({ left: 4, right: 4 })
        .backgroundColor(HEMA_PRICE_COLOR)
        .borderRadius(6.5)
        .border({ width: 1, color: Color.White })
        .textAlign(TextAlign.Center)
        .offset({ x: 5, y: -4 })
    }
    .width(HEMA_ROUND_BUTTON + 4)
    .height(HEMA_ROUND_BUTTON + 4)
    .alignContent(Alignment.TopEnd)
    .margin({ left: 6 })
  }

  @Builder
  searchRow() {
    Row() {
      this.backButton()

      Row({ space: 6 }) {
        SymbolGlyph($r('sys.symbol.magnifyingglass'))
          .fontSize(14)
          .fontColor([HEMA_TEXT_GRAY])

        Text('搜索商品、美食')
          .fontSize(14)
          .fontColor(HEMA_TEXT_GRAY)
          .maxLines(1)
          .layoutWeight(1)
      }
      .height(HEMA_SEARCH_ROW_HEIGHT)
      .padding({ left: 10, right: 10 })
      .backgroundColor(HEMA_PAGE_BG)
      .borderRadius(HEMA_SEARCH_RADIUS)
      .layoutWeight(1)
      .margin({ left: 10, right: 8 })
      .alignItems(VerticalAlign.Center)

      this.roundIconButton($r('sys.symbol.arrow_right_up_and_square'))

      this.cartButton()
    }
    .width('100%')
    .height(HEMA_SEARCH_ROW_HEIGHT)
    .padding({ left: HEMA_HEADER_PAD, right: HEMA_HEADER_PAD - 4 })
    .margin({ top: Math.max(HEMA_SEARCH_ROW_TOP - this.statusBarHeightVp, 0) })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  channelTab(tabLabel: string) {
    Column() {
      Text(tabLabel)
        .fontSize(HEMA_TAB_FONT)
        .fontWeight(this.activeChannel === tabLabel ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.activeChannel === tabLabel ? HEMA_BRAND_BLUE : HEMA_TEXT_MAIN)
        .maxLines(1)

      Column()
        .width(HEMA_TAB_UNDERLINE_WIDTH)
        .height(HEMA_TAB_UNDERLINE_HEIGHT)
        .backgroundColor(this.activeChannel === tabLabel ? HEMA_BRAND_BLUE : Color.Transparent)
        .borderRadius(HEMA_TAB_UNDERLINE_HEIGHT / 2)
        .margin({ top: 4 })
    }
    .width(HEMA_TAB_CELL_WIDTH)
    .height(HEMA_TAB_ROW_HEIGHT)
    .padding({ bottom: 1.1 })
    .justifyContent(FlexAlign.End)
    .onClick(() => {
      this.activeChannel = tabLabel;
    })
  }

  @Builder
  channelBar() {
    Row() {
      ForEach(HEMA_CHANNEL_TABS, (tabLabel: string) => {
        this.channelTab(tabLabel)
      }, (tabLabel: string) => tabLabel)
    }
    .width('100%')
    .height(HEMA_TAB_ROW_HEIGHT)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Top)
  }

  // ------------------------------------------------------------------
  // 商品卡
  // ------------------------------------------------------------------

  @Builder
  cartCircle() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width(HEMA_CART_BUTTON * this.contentScale())
        .height(HEMA_CART_BUTTON * this.contentScale())
        .backgroundColor(HEMA_BRAND_BLUE)
        .borderRadius(HEMA_CART_BUTTON * this.contentScale() / 2)

      SymbolGlyph($r('sys.symbol.cart'))
        .fontSize(HEMA_CART_BUTTON * 0.55 * this.contentScale())
        .fontColor([Color.White])
    }
    .width(HEMA_CART_BUTTON * this.contentScale())
    .height(HEMA_CART_BUTTON * this.contentScale())
  }

  @Builder
  productCell(product: HemaMatchProduct) {
    Column() {
      // 商品图 + 压在卡片下沿的促销标签
      Column() {
        Image(product.productImage)
          .width('100%')
          .height(this.imageHeightVp())
          .objectFit(ImageFit.Fill)
          .interpolation(ImageInterpolation.High)
          .draggable(false)

        Row() {
          Text(product.productPromo)
            .fontSize(HEMA_PROMO_FONT * this.contentScale())
            .fontColor(HEMA_PROMO_COLOR)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
        }
        .width('100%')
        .height(this.promoBandHeightVp())
        .padding({ left: HEMA_PROMO_PAD_LEFT * this.contentScale() })
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .backgroundColor(HEMA_TILE_BG)
      .borderRadius(HEMA_TILE_RADIUS * this.contentScale())
      .clip(true)

      Text(product.productTitle)
        .fontSize(HEMA_TITLE_FONT * this.contentScale())
        .lineHeight(HEMA_TITLE_LINE_HEIGHT * this.contentScale())
        .fontWeight(FontWeight.Bold)
        .fontColor(HEMA_TEXT_MAIN)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .height(HEMA_TITLE_LINE_HEIGHT * 2 * this.contentScale())
        .margin({ top: HEMA_TITLE_MARGIN_TOP * this.contentScale() })

      Row() {
        Text('¥')
          .fontSize(HEMA_CURRENCY_FONT * this.contentScale())
          .fontWeight(FontWeight.Bold)
          .fontColor(HEMA_PRICE_COLOR)
          .margin({ right: 1 })

        Text(product.productPrice)
          .fontSize(HEMA_PRICE_FONT * this.contentScale())
          .fontWeight(FontWeight.Bold)
          .fontColor(HEMA_PRICE_COLOR)

        Text(product.productUnit)
          .fontSize(HEMA_UNIT_FONT * this.contentScale())
          .fontColor(HEMA_UNIT_GRAY)
          .margin({ left: 1 })

        Blank()

        this.cartCircle()
      }
      .width('100%')
      .height(HEMA_CART_BUTTON * this.contentScale())
      .margin({ top: HEMA_PRICE_ROW_MARGIN_TOP * this.contentScale() })
      .alignItems(VerticalAlign.Bottom)
    }
    .width(this.columnWidthVp())
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  productRow(rowIndex: number) {
    Row({ space: this.columnGapVp() }) {
      ForEach(this.productsOfRow(rowIndex), (product: HemaMatchProduct) => {
        this.productCell(product)
      }, (product: HemaMatchProduct) => product.productId)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }

  /** 「评价」页签顶部的分组卡 */
  @Builder
  sectionCard() {
    Column() {
      Text(HEMA_SECTION_TITLE)
        .fontSize(HEMA_SECTION_FONT * this.contentScale())
        .fontWeight(FontWeight.Bold)
        .fontColor(HEMA_TEXT_MAIN)
    }
    .width('100%')
    .height(HEMA_SECTION_HEIGHT * this.contentScale())
    .padding({
      left: HEMA_CARD_PAD_X * this.contentScale(),
      right: HEMA_CARD_PAD_X * this.contentScale()
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(HEMA_CARD_BG)
    .borderRadius(HEMA_CARD_RADIUS * this.contentScale())
    .margin({ top: HEMA_SECTION_MARGIN_TOP, bottom: HEMA_SECTION_MARGIN_BOTTOM })
  }

  /** 商品卡片：三列网格 */
  @Builder
  productCard() {
    Column({ space: this.rowGapVp() }) {
      ForEach(this.productRowIndexes(), (rowIndex: number) => {
        this.productRow(rowIndex)
      }, (rowIndex: number) => 'hema-match-row-' + rowIndex.toString())
    }
    .width('100%')
    .padding({
      left: HEMA_CARD_PAD_X * this.contentScale(),
      right: HEMA_CARD_PAD_X * this.contentScale(),
      top: HEMA_CARD_PAD_TOP,
      bottom: HEMA_CARD_PAD_BOTTOM
    })
    .backgroundColor(HEMA_CARD_BG)
    .borderRadius(HEMA_CARD_RADIUS * this.contentScale())
    .alignItems(HorizontalAlign.Start)
  }

  // ------------------------------------------------------------------
  // 底部操作栏（固定尺寸）
  // ------------------------------------------------------------------

  @Builder
  actionEntry(entry: HemaMatchActionEntry) {
    Column({ space: 2 }) {
      SymbolGlyph(entry.actionIcon)
        .fontSize(HEMA_ACTION_ICON)
        .fontColor([HEMA_TEXT_MAIN])

      Text(entry.actionLabel)
        .fontSize(HEMA_ACTION_LABEL_FONT)
        .fontColor(HEMA_TEXT_MAIN)
        .maxLines(1)
    }
    .width(44)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  actionBar() {
    Row() {
      Row() {
        ForEach(HEMA_MATCH_ACTIONS, (entry: HemaMatchActionEntry) => {
          this.actionEntry(entry)
        }, (entry: HemaMatchActionEntry) => entry.actionLabel)
      }
      .padding({ left: 2, right: 8 })

      Row() {
        Text('加入购物车')
          .fontSize(HEMA_BUY_FONT)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .height(HEMA_BUY_BUTTON_HEIGHT)
          .backgroundColor(HEMA_BRAND_BLUE)
          .borderRadius({ topLeft: HEMA_BUY_BUTTON_RADIUS, bottomLeft: HEMA_BUY_BUTTON_RADIUS })

        Text('立即购买')
          .fontSize(HEMA_BUY_FONT)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .height(HEMA_BUY_BUTTON_HEIGHT)
          .backgroundColor(HEMA_BRAND_NAVY)
          .borderRadius({ topRight: HEMA_BUY_BUTTON_RADIUS, bottomRight: HEMA_BUY_BUTTON_RADIUS })
      }
      .layoutWeight(1)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(HEMA_ACTION_BAR_HEIGHT)
    .padding({ left: HEMA_HEADER_PAD - 2, right: HEMA_HEADER_PAD })
    .alignItems(VerticalAlign.Center)
  }

  /** 右下角「顶部」按钮 */
  @Builder
  backToTopButton() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width(HEMA_TOP_BUTTON)
        .height(HEMA_TOP_BUTTON)
        .backgroundColor(Color.White)
        .borderRadius(HEMA_TOP_BUTTON / 2)
        .shadow({ radius: 8, color: '#1A000000', offsetY: 2 })

      Column() {
        SymbolGlyph($r('sys.symbol.chevron_up'))
          .fontSize(14)
          .fontColor(['#5C5C5C'])

        Text('顶部')
          .fontSize(9.5)
          .fontColor('#5C5C5C')
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .width(HEMA_TOP_BUTTON)
    .height(HEMA_TOP_BUTTON)
    .margin({ right: 12, bottom: this.bottomInsetVp + HEMA_ACTION_BAR_HEIGHT + 20 })
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.BottomEnd }) {
        Column() {
          // ① 头部：固定尺寸，不随商品区放大
          Column() {
            this.searchRow()
            this.channelBar()
          }
          .width('100%')
          .padding({ top: this.statusBarHeightVp, bottom: 2 })
          .backgroundColor(Color.White)

          // ② 商品区：卡片内所有尺寸按窗口宽度等比放大
          Scroll() {
            Column() {
              if (this.activeChannel === '评价') {
                this.sectionCard()
              }
              this.productCard()
            }
            .width('100%')
            .padding({
              left: HEMA_CARD_SIDE_MARGIN * this.contentScale(),
              right: HEMA_CARD_SIDE_MARGIN * this.contentScale(),
              bottom: HEMA_CARD_BOTTOM_GAP * this.contentScale()
            })
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .align(Alignment.Top)
          .backgroundColor(HEMA_PAGE_BG)

          // ③ 底部操作栏：固定尺寸 + 手势区
          Column() {
            this.actionBar()
          }
          .width('100%')
          .padding({ bottom: this.bottomInsetVp })
          .backgroundColor(Color.White)
        }
        .width('100%')
        .height('100%')

        // ④ 右下角「顶部」按钮
        this.backToTopButton()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(HEMA_PAGE_BG)
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
