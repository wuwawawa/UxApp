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
 * 反例：未避让安全区 / 饿了么店铺更多按钮压挖孔（挖孔）
 *
 * 复刻对象：饿了么「麦当劳」店铺点餐页 —— 红色品牌头部（返回 + 居中店名「麦当劳」 +
 *   右侧搜索、更多两个半透明圆钮）、公告条（公告 + 欢迎光临文案）、「点餐 / 评价 /
 *   商家」页签、左侧分类栏（热销榜/折扣/早餐/汉堡类/小食类/饮品/甜品，热销榜选中）、
 *   右侧商品列表（实拍图 + 名称 + 月售9999+ 评价10万+ + 红色价格 + 选规格按钮）、
 *   底部购物车栏（购物车圆钮 + 配送¥0配送费 / 预估配送时间30分钟）。
 *
 * 设计基准：以单屏折叠态窗口宽 459.6vp 为基准（真机 Pura X Max 双屏竖屏截图
 *   1828×2584px、密度 2.75 等比折算，页面所有尺寸按窗口宽度 / 459.6 等比换算）：
 *   头部行高 19vp；店名 17vp；「更多」圆钮 15vp、距右 3.4vp（截图 x1755~1815、
 *   y95~170 量出）；「搜索」圆钮 15vp、距右 25vp；公告条高 15vp；页签行高 19vp；
 *   左侧分类栏宽 83vp；商品图 68vp 见方、价格 15vp；底部购物车栏高 33vp。
 *
 * 挖孔实测（Pura X Max，密度 2.75，hidumper DisplayManagerService BoundingRects）：
 *   单屏态        459.6×672vp   —— 挖孔圆 24vp，顶部正中（x 218~242vp，y 9.5~33.5vp）；
 *   双屏态竖屏    664.7×939.6vp —— 挖孔圆 26.2vp，右下角（距右 10.2vp、距底 15.3vp）；
 *   双屏态横屏    939.6×664.7vp —— 挖孔圆 26.2vp，右上角（距右 15.3vp、距顶 10.2vp）。
 *
 * 三态实测：
 *   单屏态        459.6×672vp   —— 头部从窗口顶边铺起，「更多」圆钮落在 x 441~456vp、
 *                                 y 2~17vp（挖孔在顶部正中，不与圆钮相交），但公告条
 *                                 （y 19~34vp）的文字从 x 218~242vp 处被顶部正中挖孔圆
 *                                 （y 9.5~33.5vp）压过上缘，状态栏图标叠在店名行上；
 *   双屏态竖屏    664.7×939.6vp —— 头部与购物车栏整体放大，购物车栏贴窗口底边铺开，
 *                                 状态栏图标压在返回键与店名上（挖孔在右下角空栏处，
 *                                 不与内容相交）；
 *   双屏态横屏    939.6×664.7vp —— 头部行放大到 y 0~38.8vp，「更多」圆钮放大到
 *                                 x 901.6~932.3vp、y 4.1~34.8vp，右上角挖孔圆
 *                                 （x 898.1~924.3vp、y 10.2~36.4vp）从圆钮中部整块
 *                                 穿透，白色「⋯」点阵被黑孔盖住两排。
 *
 * 问题表现：
 *   双屏横屏展开态右上角的前置摄像头挖孔正钉在「更多」圆钮上，黑色圆孔盖住 ⋯ 点阵的
 *   大半；单屏态顶部正中挖孔压过公告条文字上缘，状态栏时间、电量同时叠在红色头部上。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 缩放基准：单屏折叠态窗口宽度（1264px / 2.75） */
const EL_BASE_WIDTH: number = 459.6;

const EL_PAGE_BG: string = '#FFFFFF';
const EL_SIDEBAR_BG: string = '#F5F5F7';
const EL_BAR_BG: string = '#F4F0EE';
const EL_TEXT_MAIN: string = '#333333';
const EL_TEXT_SUB: string = '#999999';
const EL_PRICE_RED: string = '#FF4B33';
const EL_SPEC_ORANGE: string = '#FF6000';
const EL_HEAD_START: string = '#D2574F';
const EL_HEAD_END: string = '#B03A35';

/** 头部：行高 19vp、店名 17vp、圆钮 15vp、更多距右 3.4vp、搜索距右 25vp */
const EL_HEAD_ROW_HEIGHT: number = 19;
const EL_HEAD_ICON: number = 15;
const EL_STORE_NAME_FONT: number = 17;
const EL_MORE_RIGHT_INSET: number = 3.4;
const EL_SEARCH_RIGHT_INSET: number = 25;

/** 公告条高 15vp / 页签行高 19vp */
const EL_NOTICE_HEIGHT: number = 15;
const EL_NOTICE_FONT: number = 9.5;
const EL_TAB_ROW_HEIGHT: number = 19;
const EL_TAB_FONT: number = 12;
const EL_TAB_FONT_SUB: number = 11;

/** 左侧分类栏：宽 83vp、行高 27.5vp、文字 10.5vp */
const EL_SIDEBAR_WIDTH: number = 83;
const EL_SIDEBAR_ROW_HEIGHT: number = 27.5;
const EL_SIDEBAR_FONT: number = 10.5;

/** 商品行：图 68vp、名称 11.5vp、销量 8.5vp、价格 15vp、选规格高 17vp */
const EL_GOODS_PIC: number = 68;
const EL_GOODS_NAME_FONT: number = 11.5;
const EL_GOODS_SALES_FONT: number = 8.5;
const EL_GOODS_PRICE_FONT: number = 15;
const EL_SPEC_HEIGHT: number = 17;
const EL_SPEC_FONT: number = 9.5;

/** 底部购物车栏：高 33vp、圆钮 26vp */
const EL_CART_BAR_HEIGHT: number = 33;
const EL_CART_CIRCLE: number = 26;
const EL_CART_FONT: number = 10;
const EL_CART_SUB_FONT: number = 8.5;

/** 分类数据 */
interface EleCategoryItem {
  categoryLabel: string;
  categoryActive: boolean;
}

const EL_CATEGORY_LIST: EleCategoryItem[] = [
  { categoryLabel: '热销榜', categoryActive: true },
  { categoryLabel: '折扣', categoryActive: false },
  { categoryLabel: '早餐', categoryActive: false },
  { categoryLabel: '汉堡类', categoryActive: false },
  { categoryLabel: '小食类', categoryActive: false },
  { categoryLabel: '饮品', categoryActive: false },
  { categoryLabel: '甜品', categoryActive: false }
];

/** 商品数据 */
interface EleGoodsItem {
  goodsName: string;
  goodsSales: string;
  goodsPrice: string;
  goodsImage: Resource;
}

const EL_GOODS_LIST: EleGoodsItem[] = [
  {
    goodsName: '法式马卡龙 6枚装',
    goodsSales: '月售9999+ 评价10万+',
    goodsPrice: '8.88',
    goodsImage: $r('app.media.sa_ele_burger')
  },
  {
    goodsName: '昆仑山雪山矿泉水',
    goodsSales: '月售9999+ 评价10万+',
    goodsPrice: '13.5',
    goodsImage: $r('app.media.sa_ele_chicken')
  },
  {
    goodsName: '黑椒牛肉粒 200g',
    goodsSales: '月售9999+ 评价10万+',
    goodsPrice: '9.9',
    goodsImage: $r('app.media.sa_ele_nugget')
  },
  {
    goodsName: '抹茶蛋糕礼盒',
    goodsSales: '月售9999+ 评价10万+',
    goodsPrice: '11.5',
    goodsImage: $r('app.media.sa_ele_fries')
  }
];

/** 页签数据 */
interface EleTabItem {
  tabLabel: string;
  tabActive: boolean;
}

const EL_TAB_LIST: EleTabItem[] = [
  { tabLabel: '点餐', tabActive: true },
  { tabLabel: '评价', tabActive: false },
  { tabLabel: '商家', tabActive: false }
];

@Component
export struct ElemeStoreMoreNotchPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = EL_BASE_WIDTH;
  @State winHeightVp: number = 672;

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

  /** 场景缩放比：当前窗口宽 / 单屏折叠态基准宽 */
  private sceneScale(): number {
    return this.winWidthVp / EL_BASE_WIDTH;
  }

  /** 把基准宽下的设计值换算到当前窗口宽度 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  /** 头部行：返回 + 店名 + 搜索/更多圆钮（贴窗口顶边） */
  @Builder
  storeHeadRow() {
    Stack({ alignContent: Alignment.Center }) {
      Text('麦当劳')
        .fontSize(this.vs(EL_STORE_NAME_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)

      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(this.vs(16))
          .fontColor([Color.White])
          .onClick(() => {
            this.pageStack.pop();
          })

        Blank()

        Stack({ alignContent: Alignment.Center }) {
          SymbolGlyph($r('sys.symbol.magnifyingglass'))
            .fontSize(this.vs(11))
            .fontColor([Color.White])
        }
        .width(this.vs(EL_HEAD_ICON))
        .height(this.vs(EL_HEAD_ICON))
        .backgroundColor('rgba(255,255,255,0.22)')
        .borderRadius(this.vs(EL_HEAD_ICON / 2))
        .margin({ right: this.vs(6.5) })

        Stack({ alignContent: Alignment.Center }) {
          Column({ space: this.vs(2) }) {
            Circle()
              .width(this.vs(1.8))
              .height(this.vs(1.8))
              .fill(Color.White)
            Circle()
              .width(this.vs(1.8))
              .height(this.vs(1.8))
              .fill(Color.White)
            Circle()
              .width(this.vs(1.8))
              .height(this.vs(1.8))
              .fill(Color.White)
          }
        }
        .width(this.vs(EL_HEAD_ICON))
        .height(this.vs(EL_HEAD_ICON))
        .backgroundColor('rgba(255,255,255,0.22)')
        .borderRadius(this.vs(EL_HEAD_ICON / 2))
      }
      .width('100%')
      .height('100%')
      .padding({ left: this.vs(10), right: this.vs(EL_MORE_RIGHT_INSET) })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(this.vs(EL_HEAD_ROW_HEIGHT))
  }

  /** 公告条 */
  @Builder
  noticeRow() {
    Row() {
      Text('公告')
        .fontSize(this.vs(8))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .backgroundColor('rgba(255,255,255,0.25)')
        .borderRadius(this.vs(2))
        .padding({ left: this.vs(4), right: this.vs(4), top: this.vs(1), bottom: this.vs(1) })

      Text('欢迎光临麦当劳餐厅，饿了么专享新客立减15元，下单备注免排队取餐')
        .fontSize(this.vs(EL_NOTICE_FONT))
        .fontColor('rgba(255,255,255,0.92)')
        .maxLines(1)
        .layoutWeight(1)
        .margin({ left: this.vs(6) })
    }
    .width('100%')
    .height(this.vs(EL_NOTICE_HEIGHT))
    .padding({ left: this.vs(12), right: this.vs(12) })
    .alignItems(VerticalAlign.Center)
  }

  /** 页签行：点餐 / 评价 / 商家 */
  @Builder
  storeTabs() {
    Row() {
      ForEach(EL_TAB_LIST, (tab: EleTabItem) => {
        Column() {
          Text(tab.tabLabel)
            .fontSize(this.vs(tab.tabActive ? EL_TAB_FONT : EL_TAB_FONT_SUB))
            .fontWeight(tab.tabActive ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(tab.tabActive ? Color.White : 'rgba(255,255,255,0.75)')

          if (tab.tabActive) {
            Row()
              .width(this.vs(14))
              .height(this.vs(2.5))
              .backgroundColor(Color.White)
              .borderRadius(this.vs(1.25))
              .margin({ top: this.vs(2) })
          }
        }
        .alignItems(HorizontalAlign.Center)
        .margin({ right: this.vs(24) })
      }, (tab: EleTabItem) => tab.tabLabel)
    }
    .width('100%')
    .height(this.vs(EL_TAB_ROW_HEIGHT))
    .padding({ left: this.vs(16) })
    .alignItems(VerticalAlign.Center)
  }

  /** 左侧分类栏 */
  @Builder
  categorySidebar() {
    Column() {
      ForEach(EL_CATEGORY_LIST, (category: EleCategoryItem) => {
        Stack({ alignContent: Alignment.Start }) {
          Text(category.categoryLabel)
            .fontSize(this.vs(EL_SIDEBAR_FONT))
            .fontWeight(category.categoryActive ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(category.categoryActive ? EL_SPEC_ORANGE : EL_TEXT_SUB)
            .width('100%')
            .textAlign(TextAlign.Center)

          if (category.categoryActive) {
            Column()
              .width(this.vs(3))
              .height(this.vs(14))
              .backgroundColor(EL_SPEC_ORANGE)
              .borderRadius(this.vs(1.5))
          }
        }
        .width('100%')
        .height(this.vs(EL_SIDEBAR_ROW_HEIGHT))
        .backgroundColor(category.categoryActive ? EL_PAGE_BG : EL_SIDEBAR_BG)
      }, (category: EleCategoryItem) => category.categoryLabel)
    }
    .width(this.vs(EL_SIDEBAR_WIDTH))
    .height('100%')
    .backgroundColor(EL_SIDEBAR_BG)
  }

  @Builder
  goodsRow(goods: EleGoodsItem) {
    Row() {
      Image(goods.goodsImage)
        .width(this.vs(EL_GOODS_PIC))
        .height(this.vs(EL_GOODS_PIC))
        .objectFit(ImageFit.Cover)
        .borderRadius(this.vs(6))

      Column() {
        Text(goods.goodsName)
          .fontSize(this.vs(EL_GOODS_NAME_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(EL_TEXT_MAIN)
          .maxLines(1)

        Text(goods.goodsSales)
          .fontSize(this.vs(EL_GOODS_SALES_FONT))
          .fontColor(EL_TEXT_SUB)
          .margin({ top: this.vs(4) })

        Row() {
          Text('¥')
            .fontSize(this.vs(8.5))
            .fontWeight(FontWeight.Bold)
            .fontColor(EL_PRICE_RED)

          Text(goods.goodsPrice)
            .fontSize(this.vs(EL_GOODS_PRICE_FONT))
            .fontWeight(FontWeight.Bold)
            .fontColor(EL_PRICE_RED)

          Blank()

          Text('选规格')
            .fontSize(this.vs(EL_SPEC_FONT))
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .height(this.vs(EL_SPEC_HEIGHT))
            .padding({ left: this.vs(9), right: this.vs(9) })
            .backgroundColor(EL_SPEC_ORANGE)
            .borderRadius(this.vs(EL_SPEC_HEIGHT / 2))
        }
        .width('100%')
        .alignItems(VerticalAlign.Bottom)
        .margin({ top: this.vs(6) })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: this.vs(10) })
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
    .margin({ bottom: this.vs(14) })
  }

  /** 右侧商品列表 */
  @Builder
  goodsList() {
    Scroll() {
      Column() {
        ForEach(EL_GOODS_LIST, (goods: EleGoodsItem) => {
          this.goodsRow(goods)
        }, (goods: EleGoodsItem) => goods.goodsName)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: this.vs(10), right: this.vs(10), top: this.vs(12) })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .align(Alignment.Top)
    .backgroundColor(EL_PAGE_BG)
  }

  /** 底部购物车栏：购物车圆钮 + 配送信息（贴窗口底边） */
  @Builder
  cartBar() {
    Row() {
      Stack({ alignContent: Alignment.TopEnd }) {
        Column() {
          SymbolGlyph($r('sys.symbol.cart'))
            .fontSize(this.vs(16))
            .fontColor(['#2A6EC9'])
        }
        .width(this.vs(EL_CART_CIRCLE))
        .height(this.vs(EL_CART_CIRCLE))
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Color.White)
        .borderRadius(this.vs(EL_CART_CIRCLE / 2))
        .shadow({ radius: this.vs(6), color: 'rgba(0,0,0,0.18)', offsetY: this.vs(2) })

        Text('2')
          .fontSize(this.vs(8))
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .minFontScale(1)
          .maxFontScale(1)
          .height(this.vs(12))
          .padding({ left: this.vs(3.5), right: this.vs(3.5) })
          .backgroundColor('#FF4B33')
          .borderRadius(this.vs(6))
          .offset({ x: this.vs(2), y: this.vs(-2) })
      }
      .width(this.vs(EL_CART_CIRCLE))
      .height(this.vs(EL_CART_CIRCLE))

      Column() {
        Text('配送 ¥0配送费')
          .fontSize(this.vs(EL_CART_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(EL_TEXT_MAIN)

        Text('预估配送时间 30分钟')
          .fontSize(this.vs(EL_CART_SUB_FONT))
          .fontColor(EL_TEXT_SUB)
          .margin({ top: this.vs(2) })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: this.vs(10) })

      Blank()
    }
    .width('100%')
    .height(this.vs(EL_CART_BAR_HEIGHT) + 16)
    .padding({ left: this.vs(12), right: this.vs(12) })
    .backgroundColor(EL_BAR_BG)
    .alignItems(VerticalAlign.Center)
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          this.storeHeadRow()
          this.noticeRow()
          this.storeTabs()
        }
        .width('100%')
        .linearGradient({ angle: 180, colors: [[EL_HEAD_START, 0], [EL_HEAD_END, 1]] })

        Row() {
          this.categorySidebar()
          this.goodsList()
        }
        .width('100%')
        .layoutWeight(1)
        .alignItems(VerticalAlign.Top)

        this.cartBar()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(EL_PAGE_BG)
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
