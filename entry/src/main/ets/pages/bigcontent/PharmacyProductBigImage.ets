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
 * 反例：大图 / 看病买药商品图放大
 *
 * 复刻美团「看病买药」搜索结果页：白色搜索头部（返回 + 搜索框 + 购物车）、
 * 频道栏（推荐 / 问医生 / 做检测 / 成人情趣 / 器械 / 滋补保健）、
 * 两列商品卡片（商品图 + 标题 + 月售 + 价格 + 送达时间）、底部 TabBar
 * 以及浮在 TabBar 上方的「小团健康管家」气泡。
 *
 * 商品图取自截图裁出的真实商品图，卡片尺寸按单屏态截图
 * （459.6×672vp，1264×1848px，密度 2.75）量出的设计值摆放。
 *
 * 三个屏态的实测结果：
 *   单屏态        459.6×672vp   —— 列宽 217vp，商品图 217×217vp
 *   双屏态竖屏    664.7×939.6vp —— 列宽 320vp，商品图 320×320vp
 *   双屏态横屏    939.6×664.7vp —— 商品图 457×399vp，占掉六成屏高，
 *                                 一屏只放得下一行商品，标题被压到 TabBar 上沿，
 *                                 价格被裁掉，字号却还是单屏态大小
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 单屏态窗口宽度（1264px / 密度 2.75），商品卡的设计值都以它为基准 */
const BIG_REFERENCE_WIDTH: number = 459.6;
/** 单屏态窗口高度（1848px / 密度 2.75），拿不到窗口高度时兜底 */
const BIG_REFERENCE_HEIGHT: number = 672;

/** 商品网格：左右留白 / 列间距 / 行间距 / 网格上下留白（单屏态截图 23px、24px、21px 折算） */
const BIG_GRID_SIDE_INSET: number = 8.5;
const BIG_GRID_COLUMN_GAP: number = 8.5;
const BIG_GRID_ROW_GAP: number = 7.5;
const BIG_GRID_TOP_GAP: number = 7.5;
const BIG_GRID_BOTTOM_GAP: number = 8;

/** 商品网格列数：单屏态设计为两列 */
const BIG_GRID_COLUMNS: number = 2;

/** 商品图最大高度占窗口高度的比例 */
const BIG_IMAGE_MAX_HEIGHT_RATIO: number = 0.6;

/** 头部：搜索行高 / 搜索框高 / 频道栏高 / 频道胶囊高（单屏态截图折算） */
const BIG_SEARCH_ROW_HEIGHT: number = 46.5;
const BIG_SEARCH_BAR_HEIGHT: number = 36;
const BIG_CHANNEL_BAR_HEIGHT: number = 51.5;
const BIG_CHANNEL_PILL_HEIGHT: number = 30;

/** 底部 TabBar 内容高度（不含手势区） */
const BIG_TAB_BAR_HEIGHT: number = 54;

/** 状态栏 / 底部手势区兜底高度（vp），拿不到避让区时使用 */
const BIG_STATUS_BAR_FALLBACK: number = 32;
const BIG_BOTTOM_INSET_FALLBACK: number = 8;

/** 页面底色：商品网格的缝隙色 */
const BIG_PAGE_BG: string = '#F6F6F7';

interface BigProductItem {
  productId: string;
  /** 商品主图：从单屏态 / 双屏态竖屏截图里裁出来的真实商品图 */
  productImage: Resource;
  productTitle: string;
  productSales: string;
  productPrice: string;
  productDelivery: string;
}

const BIG_PRODUCTS: BigProductItem[] = [
  {
    productId: 'runjie',
    productImage: $r('app.media.product_runjie'),
    productTitle: '[润洁]萘敏维滴眼液',
    productSales: '月售20万+',
    productPrice: '8.3',
    productDelivery: '3天达'
  },
  {
    productId: 'suchun',
    productImage: $r('app.media.product_suchun'),
    productTitle: '[苏春]珍珠明目滴眼液',
    productSales: '月售7000+',
    productPrice: '20',
    productDelivery: '25分钟'
  },
  {
    productId: 'xinledun',
    productImage: $r('app.media.product_xinledun'),
    productTitle: '[新乐敦]复方门冬维甘滴眼液',
    productSales: '月售20万+',
    productPrice: '20.6',
    productDelivery: '后天达'
  },
  {
    productId: 'sanjin',
    productImage: $r('app.media.product_sanjin'),
    productTitle: '[三金]桂林西瓜霜',
    productSales: '月售40万+',
    productPrice: '18.89',
    productDelivery: '25分钟'
  }
];

interface BigTabEntry {
  tabLabel: string;
  tabIcon: Resource;
  /** 「小团健康管家」这一栏是多出来的那个大图标 */
  tabHighlight: boolean;
}

const BIG_TABS: BigTabEntry[] = [
  { tabLabel: '健康档案', tabIcon: $r('sys.symbol.house'), tabHighlight: false },
  { tabLabel: '小团健康管家', tabIcon: $r('sys.symbol.face_smiling'), tabHighlight: true },
  { tabLabel: '订单', tabIcon: $r('sys.symbol.doc_text'), tabHighlight: false },
  { tabLabel: '我的', tabIcon: $r('sys.symbol.person'), tabHighlight: false }
];

/** 频道栏：第一项「推荐」是选中态（白底胶囊），其余为普通文字 */
const BIG_CHANNEL_TABS: string[] = ['问医生', '做检测', '成人情趣', '器械', '滋补保健'];

@Component
export struct PharmacyProductBigImagePage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = BIG_REFERENCE_WIDTH;
  @State winHeightVp: number = BIG_REFERENCE_HEIGHT;
  /** 沉浸式下的状态栏 / 底部手势区高度（vp） */
  @State statusBarHeightVp: number = BIG_STATUS_BAR_FALLBACK;
  @State bottomInsetVp: number = BIG_BOTTOM_INSET_FALLBACK;

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
      this.windowToken = WindowModeController.acquire(win, '#000000');
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  // ------------------------------------------------------------------
  // 尺寸计算：商品卡与商品图的大小全部由窗口宽高推出来
  // ------------------------------------------------------------------

  /** 卡片宽度 = 可用宽度按列数均分 */
  private cardWidthVp(): number {
    const usableWidth: number = this.winWidthVp - BIG_GRID_SIDE_INSET * 2 -
      BIG_GRID_COLUMN_GAP * (BIG_GRID_COLUMNS - 1);
    return usableWidth / BIG_GRID_COLUMNS;
  }

  /** 商品图高度：与列宽一致（正方形），最高不超过窗口高度的 60% */
  private productImageHeightVp(): number {
    const squareHeight: number = this.cardWidthVp();
    const cappedHeight: number = this.winHeightVp * BIG_IMAGE_MAX_HEIGHT_RATIO;
    return Math.min(squareHeight, cappedHeight);
  }

  // ------------------------------------------------------------------
  // 头部
  // ------------------------------------------------------------------

  @Builder
  searchRow() {
    Row({ space: 4 }) {
      SymbolGlyph($r('sys.symbol.chevron_left'))
        .fontSize(22)
        .fontColor(['#1A1A1A'])
        .width(26)
        .onClick(() => {
          this.pageStack.pop();
        })

      Row({ space: 6 }) {
        SymbolGlyph($r('sys.symbol.magnifyingglass'))
          .fontSize(17)
          .fontColor(['#5C5C5C'])

        Text('氯雷他定')
          .fontSize(16)
          .fontColor('#3A3A3A')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)

        SymbolGlyph($r('sys.symbol.camera'))
          .fontSize(18)
          .fontColor(['#3A3A3A'])

        Divider()
          .vertical(true)
          .height(16)
          .strokeWidth(0.5)
          .color('#DCDCDC')
          .margin({ left: 1, right: 1 })

        Text('搜索')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
      }
      .height(BIG_SEARCH_BAR_HEIGHT)
      .padding({ left: 12, right: 12 })
      .backgroundColor('#F2F3F5')
      .borderRadius(BIG_SEARCH_BAR_HEIGHT / 2)
      .layoutWeight(1)
      .alignItems(VerticalAlign.Center)

      SymbolGlyph($r('sys.symbol.cart'))
        .fontSize(22)
        .fontColor(['#1A1A1A'])
        .margin({ left: 2, right: 4 })
    }
    .width('100%')
    .height(BIG_SEARCH_ROW_HEIGHT)
    .padding({ left: 4, right: 8 })
    .alignItems(VerticalAlign.Center)
  }

  /** 频道栏选中态：白底胶囊 + 指向下方的小尖角，靠阴影和白色背景区分 */
  @Builder
  activeChannelPill() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Row({ space: 5 }) {
        Stack() {
          Column()
            .width(18)
            .height(18)
            .backgroundColor('#FFD93B')
            .borderRadius(5)

          SymbolGlyph($r('sys.symbol.face_smiling'))
            .fontSize(12)
            .fontColor(['#1A1A1A'])
        }
        .width(18)
        .height(18)

        Text('推荐')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
      }
      .height(BIG_CHANNEL_PILL_HEIGHT)
      .padding({ left: 8, right: 12 })
      .backgroundColor(Color.White)
      .borderRadius(BIG_CHANNEL_PILL_HEIGHT / 2)
      .shadow({ radius: 6, color: '#14000000', offsetY: 2 })
      .alignItems(VerticalAlign.Center)

      Row()
        .width(9)
        .height(9)
        .backgroundColor(Color.White)
        .rotate({ angle: 45 })
        .offset({ x: 8, y: 3 })
    }
    .height(BIG_CHANNEL_PILL_HEIGHT + 4)
  }

  @Builder
  channelBar() {
    Row({ space: 18 }) {
      this.activeChannelPill()

      ForEach(BIG_CHANNEL_TABS, (tabLabel: string) => {
        Text(tabLabel)
          .fontSize(15)
          .fontColor('#1A1A1A')
          .maxLines(1)
      }, (tabLabel: string) => tabLabel)
    }
    .width('100%')
    .height(BIG_CHANNEL_BAR_HEIGHT)
    .padding({ left: 12, right: 12 })
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
  }

  // ------------------------------------------------------------------
  // 商品卡
  // ------------------------------------------------------------------

  @Builder
  productCard(product: BigProductItem) {
    Column() {
      // 商品图：铺满卡片宽度
      Image(product.productImage)
        .width('100%')
        .height(this.productImageHeightVp())
        .objectFit(ImageFit.Cover)
        .interpolation(ImageInterpolation.High)
        .draggable(false)

      Column({ space: 4 }) {
        Text(product.productTitle)
          .fontSize(17)
          .lineHeight(23)
          .fontColor('#1A1A1A')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Text(product.productSales)
          .fontSize(13)
          .fontColor('#9A9A9A')
          .maxLines(1)
          .width('100%')

        Row() {
          Text('¥')
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor('#E2452B')

          Text(product.productPrice)
            .fontSize(23)
            .fontWeight(FontWeight.Bold)
            .fontColor('#E2452B')
            .layoutWeight(1)

          Text(product.productDelivery)
            .fontSize(13)
            .fontColor('#333333')
            .maxLines(1)
        }
        .width('100%')
        .margin({ top: 2 })
        .alignItems(VerticalAlign.Bottom)
      }
      .width('100%')
      .padding({ left: 10, right: 10, top: 8, bottom: 10 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(10)
    .clip(true)
    .alignItems(HorizontalAlign.Start)
  }

  // ------------------------------------------------------------------
  // 底部 TabBar
  // ------------------------------------------------------------------

  /** 第一个 Tab：黄色圆形入口 */
  @Builder
  homeTabSlot() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width(44)
          .height(44)
          .backgroundColor('#FFD93B')
          .borderRadius(22)

        Text('不')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
      }
      .width(44)
      .height(44)
    }
    .layoutWeight(1)
    .height(BIG_TAB_BAR_HEIGHT)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  tabBarItem(entry: BigTabEntry) {
    Column({ space: 3 }) {
      if (entry.tabHighlight) {
        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width(40)
            .height(40)
            .backgroundColor('#FFF7E3')
            .borderRadius(12)
            .border({ width: 1, color: '#F6E7C4' })

          SymbolGlyph(entry.tabIcon)
            .fontSize(26)
            .fontColor(['#F4B62C'])
        }
        .width(40)
        .height(40)
        .margin({ top: -8 })
      } else {
        SymbolGlyph(entry.tabIcon)
          .fontSize(22)
          .fontColor(['#3A3A3A'])
          .width(26)
          .height(26)
      }

      Text(entry.tabLabel)
        .fontSize(10.5)
        .fontColor('#1A1A1A')
        .maxLines(1)
    }
    .layoutWeight(1)
    .height(BIG_TAB_BAR_HEIGHT)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  bottomTabBar() {
    Row() {
      this.homeTabSlot()

      ForEach(BIG_TABS, (entry: BigTabEntry) => {
        this.tabBarItem(entry)
      }, (entry: BigTabEntry) => entry.tabLabel)
    }
    .width('100%')
    .height(BIG_TAB_BAR_HEIGHT)
    .alignItems(VerticalAlign.Center)
  }

  /** 浮在 TabBar 上方的「小团健康管家」推荐气泡 */
  @Builder
  assistantBubble() {
    Text('小孩发烧用什么药？')
      .fontSize(13.5)
      .fontColor(Color.White)
      .padding({ left: 14, right: 14, top: 9, bottom: 9 })
      .backgroundColor('#12C2A0')
      .borderRadius(19)
      .margin({ bottom: this.bottomInsetVp + BIG_TAB_BAR_HEIGHT + 4 })
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column() {
          // ① 白色头部：搜索行 + 频道栏（padding.top 让出状态栏，背景一并盖住）
          Column() {
            this.searchRow()
            this.channelBar()
          }
          .width('100%')
          .padding({ top: this.statusBarHeightVp })
          .backgroundColor(Color.White)

          // ② 商品网格：列宽决定商品图宽度，横屏时一起被放大
          Grid() {
            ForEach(BIG_PRODUCTS, (product: BigProductItem) => {
              GridItem() {
                this.productCard(product)
              }
            }, (product: BigProductItem) => product.productId)
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(BIG_GRID_COLUMN_GAP)
          .rowsGap(BIG_GRID_ROW_GAP)
          .padding({
            left: BIG_GRID_SIDE_INSET,
            right: BIG_GRID_SIDE_INSET,
            top: BIG_GRID_TOP_GAP,
            bottom: BIG_GRID_BOTTOM_GAP
          })
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)

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

        // ④ 浮层气泡
        this.assistantBubble()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(BIG_PAGE_BG)
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
