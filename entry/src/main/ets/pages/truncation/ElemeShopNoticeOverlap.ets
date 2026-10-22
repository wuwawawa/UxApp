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
 * 反例：截断 / 饿了么店铺公告压字（文字重叠）
 *
 * 反例主题：店铺公告长文与「30分钟达」配送信息叠在一起。
 *
 * 复刻对象：饿了么店铺页 —— 蓝色渐变头部（返回 + 白色搜索条「找菜品/店铺」）、
 *   白色店铺卡（渐变头像「香」+ 店名「香他乡煲仔饭（西二旗店）」+ 评分 4.8 /
 *   月售1.2万 + 关注胶囊、橙色「公告」标签 + 长公告文字、配送信息行
 *   「30分钟达 | 月售9999 | 距离1.2km」）、频道行（点菜 / 评价 / 商家）、
 *   左侧分类栏（热销 / 招牌煲仔 / 经典小炒 / 主食小吃 / 饮品甜品）与右侧菜品列表
 *   （渐变占位图 + 菜名 + 描述 + 月售 + 红色价格 + 加号按钮）、底部购物栏。
 *
 * 设计基准：以单屏折叠态窗口宽 459.6vp 为基准：
 *   搜索条高 30vp、店名 16vp、头像 54vp；公告条高写死 40vp（反例根源）、
 *   公告文字 13vp、行高 17vp、公告栏文字宽写死 290vp（反例根源）；
 *   配送行文字 12vp；频道行高 40vp；分类栏宽 88vp；
 *   菜品图 64vp、菜名 14vp、描述 11vp、价格 16vp；底部购物栏高 50vp。
 *
 * 三态实测：
 *   单屏态        459.6×672vp   —— 公告栏宽 290vp、字 13vp，约 22 字/行，
 *                                 38 字公告折成 2 行（高 34vp）刚好放进 40vp 公告条；
 *   双屏态竖屏    664.7×939.6vp —— 公告字号放大到 18.8vp 而栏宽仍是 290vp，
 *                                 只剩约 15 字/行，公告折成 3 行（高 74vp），
 *                                 第 3 行冲出 40vp 公告条，与下方
 *                                 「30分钟达 | 月售9999 | 距离1.2km」配送行叠字；
 *   双屏态横屏    939.6×664.7vp —— 字号放大到 26.6vp、约 10 字/行，公告折成 4 行
 *                                 （高 139vp），配送行与频道行被整段公告盖住。
 *
 * 问题表现：
 *   公告条的行高（40vp）与文字栏宽（290vp）都按单屏基准写死，公告文字却按窗口
 *   宽度等比放大；窗口一宽，每行容纳的字数变少、公告折出更多行，多出来的行
 *   从写死的公告条里溢出（条未开裁剪），直接压在下方的配送信息行上，
 *   「30分钟达」等文字与公告文字互相叠字。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 缩放基准：单屏折叠态窗口宽度（1264px / 2.75） */
const ELM_BASE_WIDTH: number = 459.6;

/** 状态栏 / 底部手势区兜底高度（vp） */
const ELM_STATUS_BAR_FALLBACK: number = 32;
const ELM_BOTTOM_INSET_FALLBACK: number = 8;

const ELM_PAGE_BG: string = '#F5F5F5';
const ELM_HEADER_START: string = '#0097FF';
const ELM_HEADER_END: string = '#0071E0';
const ELM_BLUE: string = '#0097FF';
const ELM_TEXT_MAIN: string = '#1A1A1A';
const ELM_TEXT_SUB: string = '#8C8C8C';
const ELM_TEXT_LIGHT: string = '#B9BFC8';
const ELM_PRICE_RED: string = '#FF4B1F';
const ELM_NOTICE_TAG_BG: string = '#FF7A00';
const ELM_RAIL_BG: string = '#F0F1F3';

/** 头部：搜索条高 30vp、搜索文字 13vp */
const ELM_SEARCH_ROW_HEIGHT: number = 30;
const ELM_SEARCH_FONT: number = 13;

/** 店铺卡：内边距 12vp、圆角 12vp、头像 54vp、店名 16vp、副信息 11vp */
const ELM_SHOP_CARD_PAD: number = 12;
const ELM_SHOP_CARD_RADIUS: number = 12;
const ELM_AVATAR_SIZE: number = 54;
const ELM_SHOP_NAME_FONT: number = 16;
const ELM_SHOP_META_FONT: number = 11;

/** 公告条：条高写死 40vp（反例根源）、公告文字 13vp、行高 17vp、文字栏宽写死 290vp（反例根源） */
const ELM_NOTICE_BAR_HEIGHT: number = 40;
const ELM_NOTICE_FONT: number = 13;
const ELM_NOTICE_LINE_HEIGHT: number = 17;
const ELM_NOTICE_TEXT_WIDTH: number = 290;

/** 配送行：文字 12vp */
const ELM_DELIVERY_FONT: number = 12;

/** 频道行：高 40vp、文字 15vp */
const ELM_CHANNEL_ROW_HEIGHT: number = 40;
const ELM_CHANNEL_FONT: number = 15;

/** 分类栏：宽 88vp、条目高 46vp、文字 13vp */
const ELM_RAIL_WIDTH: number = 88;
const ELM_RAIL_ITEM_HEIGHT: number = 46;
const ELM_RAIL_FONT: number = 13;

/** 菜品行：图 64vp、菜名 14vp、描述 11vp、月售 10vp、价格 16vp */
const ELM_FOOD_PIC: number = 64;
const ELM_FOOD_NAME_FONT: number = 14;
const ELM_FOOD_DESC_FONT: number = 11;
const ELM_FOOD_SALES_FONT: number = 10;
const ELM_FOOD_PRICE_FONT: number = 16;

/** 底部购物栏：高 50vp */
const ELM_CART_BAR_HEIGHT: number = 50;

/** 店铺公告长文：38 字，单屏态下折 2 行刚好放进 40vp 公告条 */
const ELM_NOTICE_TEXT: string = '本店食材当日新鲜采购现炒现做，高峰期出餐约30分钟，忌口备注请提前填写，谢谢惠顾！';

/** 分类栏条目 */
const ELM_CATEGORY_LABELS: string[] = ['热销', '招牌煲仔', '经典小炒', '主食小吃', '饮品甜品'];

/** 菜品数据 */
interface ElemeFoodItem {
  foodName: string;
  foodDesc: string;
  foodSales: string;
  foodPrice: string;
  foodTintStart: string;
  foodTintEnd: string;
}

const ELM_FOODS: ElemeFoodItem[] = [
  {
    foodName: '招牌黄焖鸡煲仔饭',
    foodDesc: '大份慢煨现焖，含例汤一份',
    foodSales: '月售1200',
    foodPrice: '¥26.8',
    foodTintStart: '#FFC46B',
    foodTintEnd: '#F2700E'
  },
  {
    foodName: '香菇滑鸡煲仔饭',
    foodDesc: '香菇滑鸡+秘制酱汁，锅巴香脆',
    foodSales: '月售860',
    foodPrice: '¥24.0',
    foodTintStart: '#FFAD9B',
    foodTintEnd: '#E8543F'
  },
  {
    foodName: '湘西小炒黄牛肉',
    foodDesc: '嫩牛肉爆炒，微辣下饭',
    foodSales: '月售432',
    foodPrice: '¥38.5',
    foodTintStart: '#B7E38B',
    foodTintEnd: '#5FA83C'
  },
  {
    foodName: '手撕包菜',
    foodDesc: '下饭神器，酸辣开胃',
    foodSales: '月售210',
    foodPrice: '¥16.0',
    foodTintStart: '#9BE0C8',
    foodTintEnd: '#3FAE8C'
  },
  {
    foodName: '冰镇酸梅汤',
    foodDesc: '解腻标配，500ml',
    foodSales: '月售198',
    foodPrice: '¥6.5',
    foodTintStart: '#C3B1F0',
    foodTintEnd: '#7A5FD0'
  }
];

@Component
export struct ElemeShopNoticeOverlapPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = ELM_BASE_WIDTH;
  @State winHeightVp: number = 672;
  /** 沉浸式下的状态栏 / 底部手势区高度（vp） */
  @State statusBarHeightVp: number = ELM_STATUS_BAR_FALLBACK;
  @State bottomInsetVp: number = ELM_BOTTOM_INSET_FALLBACK;

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
      this.windowToken = WindowModeController.acquire(win, ELM_HEADER_START);
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  /** 场景缩放比：当前窗口宽 / 单屏折叠态基准宽 */
  private sceneScale(): number {
    return this.winWidthVp / ELM_BASE_WIDTH;
  }

  /** 把基准宽下的设计值换算到当前窗口宽度 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  /** 头部搜索行 */
  @Builder
  searchRow() {
    Row() {
      SymbolGlyph($r('sys.symbol.chevron_left'))
        .fontSize(this.vs(24))
        .fontColor([Color.White])
        .onClick(() => {
          this.pageStack.pop();
        })

      Row({ space: this.vs(6) }) {
        SymbolGlyph($r('sys.symbol.magnifyingglass'))
          .fontSize(this.vs(14))
          .fontColor(['#8FA8C4'])

        Text('找菜品 / 店铺')
          .fontSize(this.vs(ELM_SEARCH_FONT))
          .fontColor('#8FA8C4')
      }
      .height(this.vs(ELM_SEARCH_ROW_HEIGHT))
      .padding({ left: this.vs(12), right: this.vs(12) })
      .backgroundColor('rgba(255,255,255,0.92)')
      .borderRadius(this.vs(ELM_SEARCH_ROW_HEIGHT / 2))
      .alignItems(VerticalAlign.Center)
      .layoutWeight(1)
      .margin({ left: this.vs(10) })

      SymbolGlyph($r('sys.symbol.star'))
        .fontSize(this.vs(20))
        .fontColor([Color.White])
        .margin({ left: this.vs(10) })
    }
    .width('100%')
    .height(this.vs(44))
    .padding({ left: this.vs(12), right: this.vs(12) })
    .alignItems(VerticalAlign.Center)
  }

  /** 店铺头像：渐变圆 + 店名首字 */
  @Builder
  shopAvatar() {
    Column() {
      Text('香')
        .fontSize(this.vs(24))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
    }
    .width(this.vs(ELM_AVATAR_SIZE))
    .height(this.vs(ELM_AVATAR_SIZE))
    .justifyContent(FlexAlign.Center)
    .linearGradient({ angle: 135, colors: [['#FFB100', 0], ['#FF7A00', 1]] })
    .borderRadius(this.vs(10))
  }

  /** 店名行：头像 + 店名 / 评分月售 + 关注 */
  @Builder
  shopNameRow() {
    Row() {
      this.shopAvatar()

      Column() {
        Text('香他乡煲仔饭（西二旗店）')
          .fontSize(this.vs(ELM_SHOP_NAME_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(ELM_TEXT_MAIN)
          .maxLines(1)

        Row({ space: this.vs(6) }) {
          SymbolGlyph($r('sys.symbol.star'))
            .fontSize(this.vs(11))
            .fontColor(['#FF7A00'])

          Text('4.8')
            .fontSize(this.vs(ELM_SHOP_META_FONT))
            .fontWeight(FontWeight.Medium)
            .fontColor('#FF7A00')

          Text('月售1.2万')
            .fontSize(this.vs(ELM_SHOP_META_FONT))
            .fontColor(ELM_TEXT_SUB)
        }
        .alignItems(VerticalAlign.Center)
        .margin({ top: this.vs(6) })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: this.vs(10) })

      Text('关注')
        .fontSize(this.vs(ELM_SHOP_META_FONT))
        .fontColor(ELM_BLUE)
        .border({ width: this.vs(1), color: ELM_BLUE })
        .borderRadius(this.vs(12))
        .padding({ left: this.vs(10), right: this.vs(10), top: this.vs(3), bottom: this.vs(3) })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  /**
   * 公告条（反例核心）：条高写死 40vp、文字栏宽写死 290vp。
   * 窗口变宽后公告字数放大、每行容纳字数变少，折出的行数冲出 40vp 条高，
   * 压住下方的配送信息行。
   */
  @Builder
  noticeBar() {
    Row({ space: this.vs(8) }) {
      Text('公告')
        .fontSize(this.vs(10))
        .fontColor(Color.White)
        .backgroundColor(ELM_NOTICE_TAG_BG)
        .borderRadius(this.vs(3))
        .padding({ left: this.vs(4), right: this.vs(4), top: this.vs(2), bottom: this.vs(2) })
        .margin({ top: this.vs(3) })

      Text(ELM_NOTICE_TEXT)
        .fontSize(this.vs(ELM_NOTICE_FONT))
        .lineHeight(this.vs(ELM_NOTICE_LINE_HEIGHT))
        .fontColor('#666666')
        .maxLines(4)
        .width(ELM_NOTICE_TEXT_WIDTH)
    }
    .width('100%')
    .height(ELM_NOTICE_BAR_HEIGHT)
    .alignItems(VerticalAlign.Top)
    .margin({ top: this.vs(10) })
    .clip(false)
  }

  /** 配送信息行：被放大后的公告文字压盖 */
  @Builder
  deliveryRow() {
    Row({ space: this.vs(8) }) {
      SymbolGlyph($r('sys.symbol.clock'))
        .fontSize(this.vs(13))
        .fontColor([ELM_BLUE])

      Text('30分钟达')
        .fontSize(this.vs(ELM_DELIVERY_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(ELM_BLUE)

      Text('|')
        .fontSize(this.vs(ELM_DELIVERY_FONT))
        .fontColor(ELM_TEXT_LIGHT)

      Text('月售9999')
        .fontSize(this.vs(ELM_DELIVERY_FONT))
        .fontColor(ELM_TEXT_SUB)

      Text('|')
        .fontSize(this.vs(ELM_DELIVERY_FONT))
        .fontColor(ELM_TEXT_LIGHT)

      Text('距离1.2km')
        .fontSize(this.vs(ELM_DELIVERY_FONT))
        .fontColor(ELM_TEXT_SUB)

      Blank()

      Text('免配送费')
        .fontSize(this.vs(ELM_DELIVERY_FONT))
        .fontColor(ELM_BLUE)
    }
    .width('100%')
    .margin({ top: this.vs(6) })
    .alignItems(VerticalAlign.Center)
  }

  /** 店铺卡：店名行 + 公告条 + 配送行 */
  @Builder
  shopCard() {
    Column() {
      this.shopNameRow()
      this.noticeBar()
      this.deliveryRow()
    }
    .width('100%')
    .padding(this.vs(ELM_SHOP_CARD_PAD))
    .backgroundColor(Color.White)
    .borderRadius(this.vs(ELM_SHOP_CARD_RADIUS))
    .margin({ left: this.vs(10), right: this.vs(10), top: this.vs(10) })
    .alignItems(HorizontalAlign.Start)
    .clip(false)
  }

  @Builder
  channelTab(channelLabel: string, channelActive: boolean) {
    Column() {
      Text(channelLabel)
        .fontSize(this.vs(ELM_CHANNEL_FONT))
        .fontWeight(channelActive ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(channelActive ? ELM_TEXT_MAIN : ELM_TEXT_SUB)

      Row()
        .width(this.vs(channelActive ? 20 : 0))
        .height(this.vs(2.5))
        .backgroundColor(ELM_BLUE)
        .borderRadius(this.vs(1.25))
        .margin({ top: this.vs(4) })
    }
    .alignItems(HorizontalAlign.Center)
  }

  /** 频道行：点菜 / 评价 / 商家 */
  @Builder
  channelRow() {
    Row({ space: this.vs(30) }) {
      this.channelTab('点菜', true)
      this.channelTab('评价', false)
      this.channelTab('商家', false)
    }
    .width('100%')
    .height(this.vs(ELM_CHANNEL_ROW_HEIGHT))
    .padding({ left: this.vs(16) })
    .backgroundColor(Color.White)
    .alignItems(VerticalAlign.Center)
    .margin({ top: this.vs(10) })
  }

  /** 菜品占位图：渐变块 + 购物袋图标 */
  @Builder
  foodPic(food: ElemeFoodItem) {
    Column() {
      SymbolGlyph($r('sys.symbol.bag_fill'))
        .fontSize(this.vs(22))
        .fontColor(['rgba(255,255,255,0.85)'])
    }
    .width(this.vs(ELM_FOOD_PIC))
    .height(this.vs(ELM_FOOD_PIC))
    .justifyContent(FlexAlign.Center)
    .linearGradient({ angle: 135, colors: [[food.foodTintStart, 0], [food.foodTintEnd, 1]] })
    .borderRadius(this.vs(8))
  }

  @Builder
  foodRow(food: ElemeFoodItem) {
    Row() {
      this.foodPic(food)

      Column() {
        Text(food.foodName)
          .fontSize(this.vs(ELM_FOOD_NAME_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(ELM_TEXT_MAIN)
          .maxLines(1)

        Text(food.foodDesc)
          .fontSize(this.vs(ELM_FOOD_DESC_FONT))
          .fontColor(ELM_TEXT_SUB)
          .maxLines(1)
          .margin({ top: this.vs(4) })

        Row() {
          Text(food.foodSales)
            .fontSize(this.vs(ELM_FOOD_SALES_FONT))
            .fontColor(ELM_TEXT_LIGHT)

          Blank()

          Row({ space: this.vs(6) }) {
            Text(food.foodPrice)
              .fontSize(this.vs(ELM_FOOD_PRICE_FONT))
              .fontWeight(FontWeight.Bold)
              .fontColor(ELM_PRICE_RED)

            Text('+')
              .fontSize(this.vs(16))
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .width(this.vs(20))
              .height(this.vs(20))
              .textAlign(TextAlign.Center)
              .backgroundColor(ELM_BLUE)
              .borderRadius(this.vs(10))
          }
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .margin({ top: this.vs(6) })
        .alignItems(VerticalAlign.Center)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: this.vs(10) })
    }
    .width('100%')
    .padding({
      left: this.vs(10),
      right: this.vs(10),
      top: this.vs(10),
      bottom: this.vs(10)
    })
    .backgroundColor(Color.White)
    .borderRadius(this.vs(10))
    .margin({ bottom: this.vs(10) })
    .alignItems(VerticalAlign.Top)
  }

  /** 分类栏条目 */
  @Builder
  railItem(railLabel: string, railActive: boolean) {
    Column() {
      Text(railLabel)
        .fontSize(this.vs(ELM_RAIL_FONT))
        .fontWeight(railActive ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(railActive ? ELM_TEXT_MAIN : ELM_TEXT_SUB)
    }
    .width('100%')
    .height(this.vs(ELM_RAIL_ITEM_HEIGHT))
    .justifyContent(FlexAlign.Center)
    .backgroundColor(railActive ? Color.White : ELM_RAIL_BG)
  }

  /** 底部购物栏 */
  @Builder
  cartBar() {
    Row({ space: this.vs(8) }) {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width(this.vs(38))
          .height(this.vs(38))
          .borderRadius(this.vs(19))
          .backgroundColor(ELM_BLUE)

        SymbolGlyph($r('sys.symbol.cart'))
          .fontSize(this.vs(20))
          .fontColor([Color.White])
      }
      .margin({ left: this.vs(12) })

      Column() {
        Text('¥0 未选购商品')
          .fontSize(this.vs(13))
          .fontWeight(FontWeight.Medium)
          .fontColor(ELM_TEXT_MAIN)

        Text('配送费 ¥0，满30免配送费')
          .fontSize(this.vs(10))
          .fontColor(ELM_TEXT_LIGHT)
          .margin({ top: this.vs(2) })
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Text('去结算')
        .fontSize(this.vs(15))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .height(this.vs(36))
        .padding({ left: this.vs(24), right: this.vs(24) })
        .backgroundColor('#DDDDDD')
        .borderRadius(this.vs(18))
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height(this.vs(ELM_CART_BAR_HEIGHT) + this.bottomInsetVp)
    .padding({ right: this.vs(12), bottom: this.bottomInsetVp })
    .backgroundColor(Color.White)
    .alignItems(VerticalAlign.Center)
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          this.searchRow()
          this.shopCard()
        }
        .width('100%')
        .linearGradient({ angle: 180, colors: [[ELM_HEADER_START, 0], [ELM_HEADER_END, 1]] })
        .padding({ top: this.statusBarHeightVp })

        this.channelRow()

        Row() {
          Column() {
            ForEach(ELM_CATEGORY_LABELS, (railLabel: string) => {
              this.railItem(railLabel, railLabel === '热销')
            }, (railLabel: string) => railLabel)
          }
          .width(this.vs(ELM_RAIL_WIDTH))
          .backgroundColor(ELM_RAIL_BG)

          Scroll() {
            Column() {
              ForEach(ELM_FOODS, (food: ElemeFoodItem) => {
                this.foodRow(food)
              }, (food: ElemeFoodItem) => food.foodName)

              Row()
                .width('100%')
                .height(this.vs(12))
            }
            .width('100%')
            .padding({ left: this.vs(8), right: this.vs(8) })
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .align(Alignment.Top)
        }
        .width('100%')
        .layoutWeight(1)
        .alignItems(VerticalAlign.Top)

        this.cartBar()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(ELM_PAGE_BG)
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
