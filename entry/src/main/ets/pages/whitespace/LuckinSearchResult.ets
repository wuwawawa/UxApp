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
 * 反例：留白过多 / 咖啡搜索结果右侧大片空白
 *
 * 复刻对象：瑞幸咖啡 App 搜索结果页，双屏横屏。顶部一行返回箭头，「灰色胶囊搜索框」
 *   （放大镜 +「烤椰拿铁」+ 靠右的灰底 ⊗），最右「搜索」；下面浅灰底一行灰字
 *   「当前门店共10个相关商品」；再往下是白色圆角大卡片，里面单列 7 个商品
 *   （烤椰拿铁 / 生椰拿铁（首创）/ 生椰丝绒拿铁 / 巴拿拿拿铁 / 拿铁 / 香草拿铁 /
 *   黑糖拿铁）：每条左侧一杯裁自截图的杯装咖啡图（白底 + 米色圆衬底 + 杯身鹿头 logo），
 *   右侧商品名、灰色描述、价格行（橙色现价 + 灰色划线原价），条目最右端一个深蓝圆形
 *   「＋」；右下角一个圆形浮标（购物袋 + 蓝色小鹿 + 米色角标「0」）。
 *
 * 设计基准：截图 3184×2232px，密度 2.75，vp = px / 2.75，参考窗口 1157.8×811.6vp。
 *   搜索栏白底区：高 93.1vp（y 0～93.1vp）；
 *     返回箭头笔迹 10.9×19.6vp（笔画 1.45vp、中心 y 66.9vp、左缘 20.4vp）；
 *     灰胶囊宽 1053.8vp（左缘 53.8vp、右缘 1107.6vp）、高 31.3vp（y 51.6～82.5vp）、
 *     圆角 15.6vp；放大镜 13.8vp（距胶囊左缘 10.9vp）、胶囊内文字 14.4vp（距放大镜 12vp）；
 *     灰底 ⊗ 直径 16.7vp（叉臂 8.7vp、笔画 1.1vp），右缘距胶囊右缘 140.3vp；
 *     「搜索」字 13.5vp，右缘距窗口右边 12vp；
 *   浅灰条：高 46.2vp（y 93.1～139.3vp），文字 12.4vp、左缘 11.6vp、字顶 114.9vp；
 *   白卡片：左右各内缩 10.9vp（宽 = 窗口宽 − 21.8vp）、圆角 11vp、顶边 y 139.3vp；
 *   商品条目：行高 106.7vp（相邻「＋」圆心实测相差 293.33px）；杯图 77.8×91.6vp
 *     （即 214×252px 原图），距卡片左缘 20.7vp、距行顶 9.5vp；
 *     文字列左缘距卡片左缘 114.9vp；商品名 14.4vp（墨迹顶 21.8vp，行高 20vp）、
 *     描述 12.4vp（墨迹顶 47.3vp，行高 17.5vp）、价格行 26vp（墨迹顶 82.9vp），
 *     现价数字 18vp、¥ 13.5vp、划线原价 13.5vp（与前价间隔 4vp）；
 *   深蓝「＋」：圆 25.1vp（#0022AA），距卡片右缘 10.2vp、圆心距行顶 93.8vp；
 *     白色十字臂 9.5vp、笔画 1.1vp；
 *   右下浮标图 56.7×68.4vp（即 156×188px 原图），距窗口右边 15.3vp、距窗口底边 26.9vp。
 *
 * 三态实测（文字列右缘 = 10.9 + 114.9 + 最宽一条描述 219.6 = 345.4vp；
 *   「＋」左缘 = 窗口宽 − 10.9 − 10.2 − 25.1 = 窗口宽 − 46.2vp；
 *   卡片可视高 = 窗口高 − 139.3vp；7 条总高 7 × 106.7 = 746.9vp）：
 *   单屏态      459.6×672vp   —— 文字右缘 345.4vp、「＋」左缘 413.4vp，
 *                                中间空档 68.0vp，约占宽度的 15%；卡片可视高 532.7vp，
 *                                只放得下 4.9 条，第 5 条被窗口底边裁断；
 *   双屏态竖屏  664.7×939.6vp —— 「＋」左缘 618.5vp，空档 273.1vp，约占宽度的 41%；
 *                                卡片可视高 800.3vp，7 条全部放下后底部再空 53.4vp，
 *                                约占高度的 5.7%；
 *   双屏态横屏  939.6×664.7vp —— 「＋」左缘 893.4vp，空档 548.0vp，约占宽度的 58%；
 *                                卡片可视高 525.4vp，第 5 条被窗口底边裁断。
 *   纵向：一条 106.7vp 里只有 21.8～96.4vp 有内容（74.6vp），价格行底到下一条商品名
 *   之间空 32.1vp，约占行高的 30%。
 *
 * 问题表现：
 *   商品图、商品名、描述、价格全部挤在卡片左边缘一条窄带里，最宽的一条描述右缘只到
 *   窗口宽度的三成（参考窗口下 345.4vp / 1157.8vp）；
 *   名称与描述右侧直到贴边的深蓝「＋」之间是一整片没有任何内容的空白，参考窗口下横跨
 *   766.2vp，占窗口宽度的 66%；这片空白里没有分隔线、没有底色，也没有任何其它内容；
 *   7 条商品纵向间距很大，每条 106.7vp 里只有约 75vp 有内容，价格下方到下一个商品名
 *   之间空出 32.1vp。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 配色：浅灰页面 / 白卡片、近黑标题、灰描述、橙现价、灰划线原价、品牌深蓝「＋」 */
const WSLK_PAGE_BG: string = '#F5F5F5';
const WSLK_CARD_BG: string = '#FFFFFF';
const WSLK_NAME_COLOR: string = '#333333';
const WSLK_DESC_COLOR: string = '#999999';
const WSLK_PRICE_COLOR: string = '#DE540F';
const WSLK_STRIKE_COLOR: string = '#A9A9A9';
const WSLK_BANNER_COLOR: string = '#777777';
const WSLK_ACTION_COLOR: string = '#1A1A1A';
const WSLK_PILL_BG: string = '#F5F5F5';
const WSLK_PILL_TEXT: string = '#646464';
const WSLK_ICON_GREY: string = '#ABABAB';
const WSLK_CLEAR_BG: string = '#C5C5C5';
const WSLK_PLUS_BLUE: string = '#0022AA';

/** 顶部搜索栏：白底区高 93.1vp，内容统一落在 y 66.9vp 这条中线上 */
const WSLK_HEADER_HEIGHT: number = 93.1;
const WSLK_HEADER_PAD_TOP: number = 40.7;
const WSLK_HEADER_PAD_LEFT: number = 3.8;
const WSLK_HEADER_PAD_RIGHT: number = 12;

/** 返回箭头：笔迹 10.9×19.6vp、笔画 1.45vp；外层 44vp 触摸区 */
const WSLK_BACK_TOUCH: number = 44;
const WSLK_BACK_SPAN_W: number = 10.9;
const WSLK_BACK_SPAN_H: number = 19.6;
const WSLK_BACK_STROKE: number = 1.45;
/** 两条斜笔画：长 14.7vp、倾角 48°、中心上下各偏 4.9vp */
const WSLK_BACK_BAR_LEN: number = 14.7;
const WSLK_BACK_BAR_ANGLE: number = 48;
const WSLK_BACK_BAR_GAP: number = 4.9;

/** 灰胶囊：高 31.3vp、圆角 15.6vp，距返回触摸区 6vp；
 *  左内边距 10.9vp、右内边距 140.3vp（⊗ 与胶囊右缘的距离按截图量） */
const WSLK_PILL_HEIGHT: number = 31.3;
const WSLK_PILL_RADIUS: number = 15.6;
const WSLK_PILL_MARGIN_LEFT: number = 6;
const WSLK_PILL_PAD_LEFT: number = 10.9;
const WSLK_PILL_PAD_RIGHT: number = 140.3;

/** 放大镜：整体 13.8vp，圆环直径 9.5vp、笔画 1.1vp，斜柄长 6vp */
const WSLK_MAGNIFIER_SIZE: number = 13.8;
const WSLK_MAGNIFIER_RING: number = 9.5;
const WSLK_MAGNIFIER_STROKE: number = 1.1;
const WSLK_MAGNIFIER_HANDLE: number = 6;

/** 胶囊内文字 14.4vp，距放大镜 12vp */
const WSLK_PILL_TEXT_FONT: number = 14.4;
const WSLK_PILL_TEXT_GAP: number = 12;

/** ⊗：直径 16.7vp，白色叉臂 8.7vp、笔画 1.1vp */
const WSLK_CLEAR_SIZE: number = 16.7;
const WSLK_CLEAR_CROSS: number = 8.7;
const WSLK_CLEAR_CROSS_STROKE: number = 1.1;

/** 「搜索」字 13.5vp，距胶囊右缘 12.4vp */
const WSLK_ACTION_FONT: number = 13.5;
const WSLK_ACTION_MARGIN_LEFT: number = 12.4;

/** 浅灰条：高 46.2vp、文字 12.4vp、左内边距 11.6vp、文字上边距 8.8vp */
const WSLK_BANNER_HEIGHT: number = 46.2;
const WSLK_BANNER_FONT: number = 12.4;
const WSLK_BANNER_PAD_LEFT: number = 11.6;
const WSLK_BANNER_PAD_TOP: number = 8.8;

/** 白卡片：左右内缩 10.9vp、圆角 11vp */
const WSLK_CARD_MARGIN_SIDE: number = 10.9;
const WSLK_CARD_RADIUS: number = 11;

/** 商品条目：行高 106.7vp */
const WSLK_ROW_HEIGHT: number = 106.7;

/** 杯图：77.8×91.6vp，距卡片左缘 20.7vp、距行顶 9.5vp */
const WSLK_CUP_WIDTH: number = 77.8;
const WSLK_CUP_HEIGHT: number = 91.6;
const WSLK_CUP_MARGIN_LEFT: number = 20.7;
const WSLK_CUP_MARGIN_TOP: number = 9.5;

/** 文字列：左缘距卡片左缘 114.9vp（扣掉杯图宽度与左边距），上内边距 18.5vp */
const WSLK_TEXT_MARGIN_LEFT: number = 16.4;
const WSLK_TEXT_PAD_TOP: number = 18.5;

/** 商品名 14.4vp / 行高 20vp；描述 12.4vp / 行高 17.5vp，与商品名隔 5.7vp */
const WSLK_NAME_FONT: number = 14.4;
const WSLK_NAME_LINE: number = 20;
const WSLK_DESC_FONT: number = 12.4;
const WSLK_DESC_LINE: number = 17.5;
const WSLK_DESC_MARGIN_TOP: number = 5.7;

/** 价格行：高 26vp，与描述隔 14.7vp；现价数字 18vp、¥ 13.5vp、划线原价 13.5vp */
const WSLK_PRICE_ROW_HEIGHT: number = 26;
const WSLK_PRICE_MARGIN_TOP: number = 14.7;
const WSLK_PRICE_FONT: number = 18;
const WSLK_PRICE_LINE: number = 25;
const WSLK_PRICE_YEN_FONT: number = 13.5;
const WSLK_PRICE_YEN_LINE: number = 19;
const WSLK_PRICE_YEN_LIFT: number = 6.8;
const WSLK_STRIKE_FONT: number = 13.5;
const WSLK_STRIKE_LINE: number = 19;
const WSLK_STRIKE_LIFT: number = 3;
const WSLK_STRIKE_GAP: number = 4;

/** 深蓝「＋」：25.1vp 圆，距卡片右缘 10.2vp、距行顶 81.3vp；十字臂 9.5vp、笔画 1.1vp */
const WSLK_PLUS_SIZE: number = 25.1;
const WSLK_PLUS_MARGIN_RIGHT: number = 10.2;
const WSLK_PLUS_MARGIN_TOP: number = 81.3;
const WSLK_PLUS_ARM: number = 9.5;
const WSLK_PLUS_STROKE: number = 1.1;

/** 右下浮标：56.7×68.4vp，距窗口右边 15.3vp、距窗口底边 26.9vp */
const WSLK_FLOAT_WIDTH: number = 56.7;
const WSLK_FLOAT_HEIGHT: number = 68.4;
const WSLK_FLOAT_MARGIN_RIGHT: number = 15.3;
const WSLK_FLOAT_MARGIN_BOTTOM: number = 26.9;

interface WSLK_ProductEntry {
  /** 条目唯一键 */
  entryKey: string;
  productName: string;
  productDesc: string;
  /** 现价数字部分（不含 ¥） */
  priceNow: string;
  /** 划线原价（带 ¥） */
  priceOrigin: string;
  /** 从截图裁出的杯装咖啡图 */
  productImage: Resource;
}

@Component
export struct LuckinSearchResultPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽度（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = 939.6;

  /** 窗口高度（vp），随折叠 / 旋转实时更新 */
  @State winHeightVp: number = 664.7;

  /** 搜索框里回填的关键词 */
  @State keywordText: string = '烤椰拿铁';

  private productEntries: WSLK_ProductEntry[] = [];
  private resultScroller: Scroller = new Scroller();
  private pageActive: boolean = false;
  private windowToken: number = 0;

  aboutToAppear(): void {
    this.pageActive = true;
    this.buildProductEntries();
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
      this.windowToken = WindowModeController.acquire(win, '#000000');
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  private buildProductEntries(): void {
    this.productEntries = [
      {
        entryKey: 'lk-coconut-baked',
        productName: '烤椰拿铁',
        productDesc: '源自东南亚进口椰，135°C烤出独特焦香',
        priceNow: '21',
        priceOrigin: '¥35',
        productImage: $r('app.media.ws_lk_cup_coconut_baked')
      },
      {
        entryKey: 'lk-coconut-raw',
        productName: '生椰拿铁（首创）',
        productDesc: '累计销量超17亿杯｜IIAC金奖',
        priceNow: '13.9',
        priceOrigin: '¥32',
        productImage: $r('app.media.ws_lk_cup_coconut_raw')
      },
      {
        entryKey: 'lk-coconut-velvet',
        productName: '生椰丝绒拿铁',
        productDesc: '一口椰香一口丝滑',
        priceNow: '21',
        priceOrigin: '¥35',
        productImage: $r('app.media.ws_lk_cup_coconut_velvet')
      },
      {
        entryKey: 'lk-banana',
        productName: '巴拿拿拿铁',
        productDesc: '明媚香蕉甜邂逅咖啡坚果香',
        priceNow: '12.9',
        priceOrigin: '¥35',
        productImage: $r('app.media.ws_lk_cup_banana')
      },
      {
        entryKey: 'lk-latte',
        productName: '拿铁',
        productDesc: '意式浓缩与牛奶的经典组合',
        priceNow: '16',
        priceOrigin: '¥29',
        productImage: $r('app.media.ws_lk_cup_latte')
      },
      {
        entryKey: 'lk-vanilla',
        productName: '香草拿铁',
        productDesc: '',
        priceNow: '19',
        priceOrigin: '¥32',
        productImage: $r('app.media.ws_lk_cup_vanilla')
      },
      {
        entryKey: 'lk-brown-sugar',
        productName: '黑糖拿铁',
        productDesc: '黑糖焦香与咖啡醇厚的组合',
        priceNow: '18',
        priceOrigin: '¥30',
        productImage: $r('app.media.ws_lk_cup_latte')
      }
    ];
  }

  // ------------------------------------------------------------------
  // 顶部：返回箭头 + 胶囊搜索框 + 搜索
  // ------------------------------------------------------------------

  /** 返回箭头：两条斜向笔画在左侧交成一个「‹」 */
  @Builder
  backArrow() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(WSLK_BACK_BAR_LEN)
        .height(WSLK_BACK_STROKE)
        .backgroundColor(WSLK_NAME_COLOR)
        .borderRadius(WSLK_BACK_STROKE / 2)
        .rotate({ angle: -WSLK_BACK_BAR_ANGLE })
        .offset({ y: -WSLK_BACK_BAR_GAP })

      Row()
        .width(WSLK_BACK_BAR_LEN)
        .height(WSLK_BACK_STROKE)
        .backgroundColor(WSLK_NAME_COLOR)
        .borderRadius(WSLK_BACK_STROKE / 2)
        .rotate({ angle: WSLK_BACK_BAR_ANGLE })
        .offset({ y: WSLK_BACK_BAR_GAP })
    }
    .width(WSLK_BACK_SPAN_W)
    .height(WSLK_BACK_SPAN_H)
  }

  /** 放大镜：细边框圆环 + 右下斜柄 */
  @Builder
  magnifierIcon() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(WSLK_MAGNIFIER_RING)
        .height(WSLK_MAGNIFIER_RING)
        .border({ width: WSLK_MAGNIFIER_STROKE, color: WSLK_ICON_GREY })
        .borderRadius(WSLK_MAGNIFIER_RING / 2)
        .offset({ x: -1.9, y: -1.9 })

      Row()
        .width(WSLK_MAGNIFIER_HANDLE)
        .height(WSLK_MAGNIFIER_STROKE)
        .backgroundColor(WSLK_ICON_GREY)
        .borderRadius(WSLK_MAGNIFIER_STROKE / 2)
        .rotate({ angle: 45 })
        .offset({ x: 3.4, y: 3.4 })
    }
    .width(WSLK_MAGNIFIER_SIZE)
    .height(WSLK_MAGNIFIER_SIZE)
  }

  /** 清空 ⊗：灰底圆 + 白色叉 */
  @Builder
  clearIcon() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(WSLK_CLEAR_CROSS)
        .height(WSLK_CLEAR_CROSS_STROKE)
        .backgroundColor(Color.White)
        .rotate({ angle: 45 })

      Row()
        .width(WSLK_CLEAR_CROSS)
        .height(WSLK_CLEAR_CROSS_STROKE)
        .backgroundColor(Color.White)
        .rotate({ angle: -45 })
    }
    .width(WSLK_CLEAR_SIZE)
    .height(WSLK_CLEAR_SIZE)
    .backgroundColor(WSLK_CLEAR_BG)
    .borderRadius(WSLK_CLEAR_SIZE / 2)
    .onClick(() => {
      this.keywordText = '';
    })
  }

  @Builder
  searchPill() {
    Row() {
      this.magnifierIcon()

      Text(this.keywordText)
        .fontSize(WSLK_PILL_TEXT_FONT)
        .fontColor(WSLK_PILL_TEXT)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ left: WSLK_PILL_TEXT_GAP })

      Blank()

      this.clearIcon()
    }
    .height(WSLK_PILL_HEIGHT)
    .layoutWeight(1)
    .margin({ left: WSLK_PILL_MARGIN_LEFT })
    .padding({ left: WSLK_PILL_PAD_LEFT, right: WSLK_PILL_PAD_RIGHT })
    .backgroundColor(WSLK_PILL_BG)
    .borderRadius(WSLK_PILL_RADIUS)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  headerBar() {
    Row() {
      Stack({ alignContent: Alignment.Center }) {
        this.backArrow()
      }
      .width(WSLK_BACK_TOUCH)
      .height(WSLK_BACK_TOUCH)
      .onClick(() => {
        this.pageStack.pop();
      })

      this.searchPill()

      Text('搜索')
        .fontSize(WSLK_ACTION_FONT)
        .fontColor(WSLK_ACTION_COLOR)
        .maxLines(1)
        .margin({ left: WSLK_ACTION_MARGIN_LEFT })
    }
    .width('100%')
    .height(WSLK_HEADER_HEIGHT)
    .padding({
      left: WSLK_HEADER_PAD_LEFT,
      right: WSLK_HEADER_PAD_RIGHT,
      top: WSLK_HEADER_PAD_TOP
    })
    .backgroundColor(WSLK_CARD_BG)
    .alignItems(VerticalAlign.Center)
  }

  // ------------------------------------------------------------------
  // 浅灰统计条
  // ------------------------------------------------------------------

  @Builder
  resultBanner() {
    Row() {
      Text('当前门店共10个相关商品')
        .fontSize(WSLK_BANNER_FONT)
        .fontColor(WSLK_BANNER_COLOR)
        .maxLines(1)
    }
    .width('100%')
    .height(WSLK_BANNER_HEIGHT)
    .padding({ left: WSLK_BANNER_PAD_LEFT, top: WSLK_BANNER_PAD_TOP })
    .backgroundColor(WSLK_PAGE_BG)
    .alignItems(VerticalAlign.Center)
  }

  // ------------------------------------------------------------------
  // 商品条目
  // ------------------------------------------------------------------

  /** 价格行：橙色 ¥ + 现价数字 + 灰色划线原价 */
  @Builder
  priceRow(entry: WSLK_ProductEntry) {
    Row() {
      Text('¥')
        .fontSize(WSLK_PRICE_YEN_FONT)
        .lineHeight(WSLK_PRICE_YEN_LINE)
        .fontColor(WSLK_PRICE_COLOR)
        .maxLines(1)
        .margin({ bottom: WSLK_PRICE_YEN_LIFT })

      Text(entry.priceNow)
        .fontSize(WSLK_PRICE_FONT)
        .lineHeight(WSLK_PRICE_LINE)
        .fontColor(WSLK_PRICE_COLOR)
        .maxLines(1)

      Text(entry.priceOrigin)
        .fontSize(WSLK_STRIKE_FONT)
        .lineHeight(WSLK_STRIKE_LINE)
        .fontColor(WSLK_STRIKE_COLOR)
        .maxLines(1)
        .decoration({ type: TextDecorationType.LineThrough, color: WSLK_STRIKE_COLOR })
        .margin({ left: WSLK_STRIKE_GAP, bottom: WSLK_STRIKE_LIFT })
    }
    .height(WSLK_PRICE_ROW_HEIGHT)
    .margin({ top: WSLK_PRICE_MARGIN_TOP })
    .alignItems(VerticalAlign.Bottom)
  }

  /** 深蓝圆形「＋」：白色十字叠在圆上 */
  @Builder
  plusButton() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(WSLK_PLUS_ARM)
        .height(WSLK_PLUS_STROKE)
        .backgroundColor(Color.White)

      Row()
        .width(WSLK_PLUS_STROKE)
        .height(WSLK_PLUS_ARM)
        .backgroundColor(Color.White)
    }
    .width(WSLK_PLUS_SIZE)
    .height(WSLK_PLUS_SIZE)
    .backgroundColor(WSLK_PLUS_BLUE)
    .borderRadius(WSLK_PLUS_SIZE / 2)
    .margin({ right: WSLK_PLUS_MARGIN_RIGHT, top: WSLK_PLUS_MARGIN_TOP })
  }

  @Builder
  productRow(entry: WSLK_ProductEntry) {
    Row() {
      Image(entry.productImage)
        .width(WSLK_CUP_WIDTH)
        .height(WSLK_CUP_HEIGHT)
        .objectFit(ImageFit.Fill)
        .interpolation(ImageInterpolation.High)
        .margin({ left: WSLK_CUP_MARGIN_LEFT, top: WSLK_CUP_MARGIN_TOP })

      Column() {
        Text(entry.productName)
          .fontSize(WSLK_NAME_FONT)
          .lineHeight(WSLK_NAME_LINE)
          .height(WSLK_NAME_LINE)
          .fontWeight(FontWeight.Medium)
          .fontColor(WSLK_NAME_COLOR)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(entry.productDesc)
          .fontSize(WSLK_DESC_FONT)
          .lineHeight(WSLK_DESC_LINE)
          .height(WSLK_DESC_LINE)
          .fontColor(WSLK_DESC_COLOR)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: WSLK_DESC_MARGIN_TOP })

        this.priceRow(entry)
      }
      .margin({ left: WSLK_TEXT_MARGIN_LEFT, top: WSLK_TEXT_PAD_TOP })
      .alignItems(HorizontalAlign.Start)

      Blank()

      this.plusButton()
    }
    .width('100%')
    .height(WSLK_ROW_HEIGHT)
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  productCard() {
    Row() {
      Column() {
        List({ scroller: this.resultScroller }) {
          ForEach(this.productEntries, (entry: WSLK_ProductEntry) => {
            ListItem() {
              this.productRow(entry)
            }
          }, (entry: WSLK_ProductEntry) => entry.entryKey)
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.None)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(WSLK_CARD_BG)
      .borderRadius(WSLK_CARD_RADIUS)
      .clip(true)
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: WSLK_CARD_MARGIN_SIDE, right: WSLK_CARD_MARGIN_SIDE })
    .alignItems(VerticalAlign.Top)
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.BottomEnd }) {
        Column() {
          this.headerBar()

          this.resultBanner()

          this.productCard()
        }
        .width('100%')
        .height('100%')
        .backgroundColor(WSLK_PAGE_BG)

        Image($r('app.media.ws_lk_float_cart'))
          .width(WSLK_FLOAT_WIDTH)
          .height(WSLK_FLOAT_HEIGHT)
          .objectFit(ImageFit.Contain)
          .margin({ right: WSLK_FLOAT_MARGIN_RIGHT, bottom: WSLK_FLOAT_MARGIN_BOTTOM })
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
