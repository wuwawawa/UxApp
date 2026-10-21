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
 * 反例：截断 / 海航自营贵宾室筛选行竖排溢出（文字截断）
 *
 * 复刻对象：海南航空「自营贵宾室」列表页 —— 浅灰底 + 白色标题行（返回箭头 + 居中「自营贵宾室」）、
 *   一张筛选卡（「机场」+「⌄」/「美兰国际机场」/ 细竖分隔线 /「我的订单」）、
 *   两张商品卡（左侧商品图，右侧标题、副标题、标签胶囊与价格）。
 *
 * 设计基准：参考截图 1080×2504px（密度 2.75，vp = px / 2.75，392.7×910.5vp）量出的设计值：
 *   标题行文字 18.9vp（字身宽 52px、ink 高 51px），返回箭头 ink 27×46px，标题行高 50vp；
 *   筛选卡左右留白 25.8 / 25.1vp、宽 342.2vp、圆角 20.7vp、高 207.6vp（= 6 × 34.6vp 行高）；
 *   筛选文字 29.4vp（字身宽 80.7px = 242px / 3 字）、行高 34.6vp；
 *   单字列宽 31vp（「机场」两行、机场名六行）、「我的订单」列宽 92vp（三字 + 一字）；
 *   竖分隔线 1.8 × 69.5vp 位于「我的订单」一侧，两侧间距 25.3 / 27.2vp；
 *   商品卡左右留白 25.8vp、宽 342.2vp、圆角 20.7vp，卡一高 250.2vp、卡二高 255.6vp，
 *   卡片间距 26.2 / 26.9vp，页面底部留白 32vp；
 *   商品图 194.5 × 194.5vp（截图原位 535×535px），距卡片左 25.8vp、上 25.1vp、圆角 14.2vp；
 *   卡内文字左边 246.9vp（= 卡片左 25.8 + 221.1vp）；标题 34.5vp（字身宽 95px）、行高 40vp；
 *   副标题 26.2vp（字身宽 72px）、行高 30vp；价格 41vp（ink 高 82px）、行高 46vp、色 #DF3A2B；
 *   标签胶囊高 43.3vp、圆角 7vp、底色 #D9C2A2、文字 23.6vp（字身宽 65px）、左内边距 18.2vp。
 *   两张商品图都从参考截图裁出，未做任何绘制替代：
 *     tr_lounge_bus.jpg  ← (x 142, y 1023) 535 × 535px
 *     tr_lounge_hall.jpg ← (x 141, y 1783) 535 × 535px
 *   页面按参考截图量出的设计值复刻，内容列最多铺到 664.7vp（更宽窗口下居中）；
 *   窗口更窄时整列等比缩小。
 *
 * 三态实测：
 *   单屏态        459.6×672vp   —— 内容列 459.6vp（1.17 倍），一屏看到标题行、
 *                                 筛选卡与第一张商品卡下沿，其余部分纵向滚动；
 *   双屏态竖屏    664.7×939.6vp —— 内容列 664.7vp（1.69 倍），整页 1538vp 需纵向滚动；
 *   双屏态横屏    939.6×664.7vp —— 内容列 664.7vp 居中（1.69 倍），一屏到第二张卡顶部。
 *
 * 问题表现：
 *   筛选卡里的三处文字都被压成竖排：「机场」折成两行、右侧跟着「⌄」，
 *   「美兰国际机场」六个字一字一行把卡片撑到 207.6vp 高，「我的订单」折成「我的订 / 单」。
 *   两张商品卡的标题、副标题从卡片右边越出到灰底上，「海航自营…」「购买此产…」
 *   的字尾被屏幕右边缘切掉；第二张卡的「贵宾室休…」胶囊同样越过卡片右沿。
 *   第二张卡底部的橙色价格只剩数字顶部，被卡片下沿切掉大半行。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 参考截图宽度：1080px / 2.75 = 392.7vp，页面按它 1:1 复刻 */
const HLG_REFERENCE_WIDTH: number = 392.7;

/** 状态栏兜底高度（vp），拿不到避让区时使用 */
const HLG_STATUS_BAR_FALLBACK: number = 32;

const HLG_PAGE_BG: string = '#F8F8F8';
const HLG_TEXT_MAIN: string = '#101010';
const HLG_TEXT_SUB: string = '#505050';
const HLG_PRICE_RED: string = '#DF3A2B';
const HLG_DIVIDER: string = '#E0DFE4';
const HLG_CAPSULE_BG: string = '#D9C2A2';
const HLG_CAPSULE_TEXT: string = '#5C3A13';
const HLG_CHEVRON: string = '#333333';

/** 标题行：行高 50vp、标题字 18.9vp、返回箭头 30vp；标题行下沿到筛选卡 22.4vp */
const HLG_TITLE_ROW_HEIGHT: number = 50;
const HLG_TITLE_FONT: number = 18.9;
const HLG_BACK_FONT: number = 30;
const HLG_BACK_INSET: number = 12;
const HLG_HEADER_GAP: number = 22.4;

/** 卡片公共尺寸：宽 342.2vp、圆角 20.7vp */
const HLG_CARD_WIDTH: number = 342.2;
const HLG_CARD_RADIUS: number = 20.7;

/** 筛选卡：左内边距 26.9vp；文字 29.4vp / 行高 34.6vp；单字列 31vp、订单列 92vp */
const HLG_FILTER_PAD_LEFT: number = 26.9;
const HLG_FILTER_FONT: number = 29.4;
const HLG_FILTER_LINE: number = 34.6;
const HLG_FILTER_CELL_WIDTH: number = 31;
const HLG_FILTER_ORDER_WIDTH: number = 92;
const HLG_CHEVRON_FONT: number = 24;
const HLG_CHEVRON_GAP_LEFT: number = 15.7;
const HLG_CHEVRON_GAP_RIGHT: number = 27.6;

/** 竖分隔线：1.8 × 69.5vp */
const HLG_DIVIDER_WIDTH: number = 1.8;
const HLG_DIVIDER_HEIGHT: number = 69.5;
const HLG_DIVIDER_GAP_LEFT: number = 25.3;
const HLG_DIVIDER_GAP_RIGHT: number = 27.2;

/** 商品图：194.5vp 见方，距卡片左 25.8vp、上 25.1vp、圆角 14.2vp */
const HLG_PHOTO_SIZE: number = 194.5;
const HLG_PHOTO_LEFT: number = 25.8;
const HLG_PHOTO_TOP: number = 25.1;
const HLG_PHOTO_RADIUS: number = 14.2;

/** 卡内文字：左边 246.9vp；标题 34.5vp/40vp；副标题 26.2vp/30vp；价格 41vp/46vp */
const HLG_TEXT_LEFT: number = 246.9;
const HLG_TEXT_OVERFLOW_WIDTH: number = 260;
const HLG_ITEM_TITLE_FONT: number = 34.5;
const HLG_ITEM_TITLE_LINE: number = 40;
const HLG_ITEM_TITLE_TOP: number = 23.8;
const HLG_ITEM_SUB_FONT: number = 26.2;
const HLG_ITEM_SUB_LINE: number = 30;
const HLG_ITEM_SUB_TOP_ONE: number = 81;
const HLG_ITEM_SUB_TOP_TWO: number = 141.7;
const HLG_PRICE_FONT: number = 41;
const HLG_PRICE_LINE: number = 46;
const HLG_PRICE_TOP_ONE: number = 177.7;
const HLG_PRICE_TOP_TWO: number = 238.4;
const HLG_PRICE_LEFT_TWO: number = 262.9;
const HLG_PRICE_WIDTH: number = 200;

/** 标签胶囊：高 43.3vp、圆角 7vp、文字 23.6vp、左内边距 18.2vp、盒宽 230vp */
const HLG_CAPSULE_TOP: number = 82.5;
const HLG_CAPSULE_LEFT: number = 246.2;
const HLG_CAPSULE_WIDTH: number = 230;
const HLG_CAPSULE_HEIGHT: number = 43.3;
const HLG_CAPSULE_RADIUS: number = 7;
const HLG_CAPSULE_FONT: number = 23.6;
const HLG_CAPSULE_PAD_LEFT: number = 18.2;

/** 价格所在内容框：355.3vp 宽，比卡片右沿多出 13.1vp，价格在这一层里被切 */
const HLG_PRICE_CLIP_WIDTH: number = 355.3;

/** 卡片尺寸与间距：卡一 250.2vp、卡二 255.6vp；筛选卡 → 卡一 26.9vp、卡一 → 卡二 26.2vp */
const HLG_PRODUCT_ONE_HEIGHT: number = 250.2;
const HLG_PRODUCT_TWO_HEIGHT: number = 255.6;
const HLG_GAP_FILTER_TO_CARD: number = 26.9;
const HLG_GAP_CARD_TO_CARD: number = 26.2;
const HLG_PAGE_BOTTOM_GAP: number = 32;

@Component
export struct HnaLoungeWrapPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = 459.6;
  @State winHeightVp: number = 672;
  /** 沉浸式下的状态栏高度（vp） */
  @State statusBarHeightVp: number = HLG_STATUS_BAR_FALLBACK;

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

  /** 内容列宽度：参考设计宽 392.7vp，窗口更宽时保持原宽并居中，更窄时整体缩小 */
  private pageWidth(): number {
    return Math.min(this.winWidthVp, 664.7);
  }

  /** 把 392.7vp 参考宽下的设计值换算到当前内容列宽度 */
  private s(baseVp: number): number {
    return baseVp * this.pageWidth() / HLG_REFERENCE_WIDTH;
  }

  @Builder
  titleBar() {
    Stack({ alignContent: Alignment.Center }) {
      Text('自营贵宾室')
        .fontSize(this.s(HLG_TITLE_FONT))
        .fontWeight(FontWeight.Medium)
        .fontColor(HLG_TEXT_MAIN)

      Row() {
        Text('‹')
          .fontSize(this.s(HLG_BACK_FONT))
          .fontColor('#1A1A1A')
      }
      .width('100%')
      .padding({ left: this.s(HLG_BACK_INSET) })
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        this.pageStack.pop();
      })
    }
    .width('100%')
    .height(this.statusBarHeightVp + this.s(HLG_TITLE_ROW_HEIGHT))
    .padding({ top: this.statusBarHeightVp })
    .backgroundColor(HLG_PAGE_BG)
  }

  /** 筛选卡：「机场」+「⌄」+「美兰国际机场」+ 竖分隔线 +「我的订单」 */
  @Builder
  filterCard() {
    Row() {
      Text('机场')
        .fontSize(this.s(HLG_FILTER_FONT))
        .lineHeight(this.s(HLG_FILTER_LINE))
        .fontColor(HLG_TEXT_MAIN)
        .width(this.s(HLG_FILTER_CELL_WIDTH))

      Text('⌄')
        .fontSize(this.s(HLG_CHEVRON_FONT))
        .fontColor(HLG_CHEVRON)
        .margin({ left: this.s(HLG_CHEVRON_GAP_LEFT), right: this.s(HLG_CHEVRON_GAP_RIGHT) })

      Text('美兰国际机场')
        .fontSize(this.s(HLG_FILTER_FONT))
        .lineHeight(this.s(HLG_FILTER_LINE))
        .fontColor(HLG_TEXT_MAIN)
        .width(this.s(HLG_FILTER_CELL_WIDTH))

      Divider()
        .vertical(true)
        .height(this.s(HLG_DIVIDER_HEIGHT))
        .strokeWidth(this.s(HLG_DIVIDER_WIDTH))
        .color(HLG_DIVIDER)
        .margin({ left: this.s(HLG_DIVIDER_GAP_LEFT), right: this.s(HLG_DIVIDER_GAP_RIGHT) })

      Text('我的订单')
        .fontSize(this.s(HLG_FILTER_FONT))
        .lineHeight(this.s(HLG_FILTER_LINE))
        .fontColor(HLG_TEXT_MAIN)
        .width(this.s(HLG_FILTER_ORDER_WIDTH))
    }
    .width(this.s(HLG_CARD_WIDTH))
    .padding({ left: this.s(HLG_FILTER_PAD_LEFT) })
    .backgroundColor(Color.White)
    .borderRadius(this.s(HLG_CARD_RADIUS))
    .alignItems(VerticalAlign.Center)
    .margin({ top: this.s(HLG_HEADER_GAP) })
  }

  /** 第一张商品卡：接驳巴士图 + 标题 / 副标题 / 价格 */
  @Builder
  productCardBus() {
    Stack({ alignContent: Alignment.TopStart }) {
      Image($r('app.media.tr_lounge_bus'))
        .objectFit(ImageFit.Cover)
        .width(this.s(HLG_PHOTO_SIZE))
        .height(this.s(HLG_PHOTO_SIZE))
        .borderRadius(this.s(HLG_PHOTO_RADIUS))
        .position({ x: this.s(HLG_PHOTO_LEFT), y: this.s(HLG_PHOTO_TOP) })

      Text('海航自营贵宾室接驳车')
        .fontSize(this.s(HLG_ITEM_TITLE_FONT))
        .lineHeight(this.s(HLG_ITEM_TITLE_LINE))
        .fontWeight(FontWeight.Bold)
        .fontColor(HLG_TEXT_MAIN)
        .maxLines(1)
        .width(this.s(HLG_TEXT_OVERFLOW_WIDTH))
        .position({ x: this.s(HLG_TEXT_LEFT), y: this.s(HLG_ITEM_TITLE_TOP) })

      Text('购买此产品享贵宾室休息与接驳服务')
        .fontSize(this.s(HLG_ITEM_SUB_FONT))
        .lineHeight(this.s(HLG_ITEM_SUB_LINE))
        .fontColor(HLG_TEXT_SUB)
        .maxLines(1)
        .width(this.s(HLG_TEXT_OVERFLOW_WIDTH))
        .position({ x: this.s(HLG_TEXT_LEFT), y: this.s(HLG_ITEM_SUB_TOP_ONE) })

      Text('¥58')
        .fontSize(this.s(HLG_PRICE_FONT))
        .lineHeight(this.s(HLG_PRICE_LINE))
        .fontWeight(FontWeight.Bold)
        .fontColor(HLG_PRICE_RED)
        .maxLines(1)
        .width(this.s(HLG_PRICE_WIDTH))
        .position({ x: this.s(HLG_TEXT_LEFT), y: this.s(HLG_PRICE_TOP_ONE) })
    }
    .width(this.s(HLG_CARD_WIDTH))
    .height(this.s(HLG_PRODUCT_ONE_HEIGHT))
    .backgroundColor(Color.White)
    .borderRadius(this.s(HLG_CARD_RADIUS))
    .margin({ top: this.s(HLG_GAP_FILTER_TO_CARD) })
    .clip(false)
  }

  /** 第二张商品卡：贵宾室图 + 标题 / 标签胶囊 / 副标题 / 底部价格 */
  @Builder
  productCardLounge() {
    Stack({ alignContent: Alignment.TopStart }) {
      Image($r('app.media.tr_lounge_hall'))
        .objectFit(ImageFit.Cover)
        .width(this.s(HLG_PHOTO_SIZE))
        .height(this.s(HLG_PHOTO_SIZE))
        .borderRadius(this.s(HLG_PHOTO_RADIUS))
        .position({ x: this.s(HLG_PHOTO_LEFT), y: this.s(HLG_PHOTO_TOP) })

      // 价格内容框：宽 355.3vp（比卡片宽 13.1vp），高与卡片齐
      Column() {
        Text('¥2288')
          .fontSize(this.s(HLG_PRICE_FONT))
          .lineHeight(this.s(HLG_PRICE_LINE))
          .fontWeight(FontWeight.Bold)
          .fontColor(HLG_PRICE_RED)
          .maxLines(1)
          .width(this.s(HLG_PRICE_WIDTH))
          .position({ x: this.s(HLG_PRICE_LEFT_TWO), y: this.s(HLG_PRICE_TOP_TWO) })
      }
      .width(this.s(HLG_PRICE_CLIP_WIDTH))
      .height(this.s(HLG_PRODUCT_TWO_HEIGHT))
      .clip(true)

      Text('海航自营贵宾室休息服务')
        .fontSize(this.s(HLG_ITEM_TITLE_FONT))
        .lineHeight(this.s(HLG_ITEM_TITLE_LINE))
        .fontWeight(FontWeight.Bold)
        .fontColor(HLG_TEXT_MAIN)
        .maxLines(1)
        .width(this.s(HLG_TEXT_OVERFLOW_WIDTH))
        .position({ x: this.s(HLG_TEXT_LEFT), y: this.s(HLG_ITEM_TITLE_TOP) })

      Row() {
        Text('贵宾室休息服务')
          .fontSize(this.s(HLG_CAPSULE_FONT))
          .fontColor(HLG_CAPSULE_TEXT)
          .maxLines(1)
      }
      .width(this.s(HLG_CAPSULE_WIDTH))
      .height(this.s(HLG_CAPSULE_HEIGHT))
      .padding({ left: this.s(HLG_CAPSULE_PAD_LEFT) })
      .backgroundColor(HLG_CAPSULE_BG)
      .borderRadius(this.s(HLG_CAPSULE_RADIUS))
      .alignItems(VerticalAlign.Center)
      .position({ x: this.s(HLG_CAPSULE_LEFT), y: this.s(HLG_CAPSULE_TOP) })

      Text('优享五星航站楼贵宾室服务')
        .fontSize(this.s(HLG_ITEM_SUB_FONT))
        .lineHeight(this.s(HLG_ITEM_SUB_LINE))
        .fontColor(HLG_TEXT_SUB)
        .maxLines(1)
        .width(this.s(HLG_TEXT_OVERFLOW_WIDTH))
        .position({ x: this.s(HLG_TEXT_LEFT), y: this.s(HLG_ITEM_SUB_TOP_TWO) })
    }
    .width(this.s(HLG_CARD_WIDTH))
    .height(this.s(HLG_PRODUCT_TWO_HEIGHT))
    .backgroundColor(Color.White)
    .borderRadius(this.s(HLG_CARD_RADIUS))
    .margin({ top: this.s(HLG_GAP_CARD_TO_CARD) })
    .clip(false)
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          this.titleBar()

          Column() {
            this.filterCard()
            this.productCardBus()
            this.productCardLounge()

            Column()
              .width('100%')
              .height(this.s(HLG_PAGE_BOTTOM_GAP))
          }
          .width(this.pageWidth())
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .backgroundColor(HLG_PAGE_BG)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .backgroundColor(HLG_PAGE_BG)
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
