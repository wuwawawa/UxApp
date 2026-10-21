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
 * 反例：截断 / 基金详情页大字溢出（文字溢出）
 *
 * 复刻对象：平安「基金详情」页，橙色品牌头（返回 + 基金详情）、白色产品卡
 *   （基金全称 / 中风险·指数型·起购金额 / 昨日涨幅 / 近一年涨幅·最新净值）、
 *   业绩走势（单位净值 / 累计净值切换）与「买基金上金管家」横幅，
 *   底部「加自选 / 计算 / 定投 / 立即投资」操作条。
 *
 * 设计基准：参考截图 1080×2504px（密度 2.75，vp = px / 2.75，392.7×910.5vp）量出的设计值：
 *   头部橙色区高 186.5vp、标题行高 44vp；产品卡左右留白 28.4vp、上沿 107.3vp、
 *   高 381.5vp、圆角 14.5vp；基金名 40vp / 行高 42vp；标签行在卡内 187.6vp 处；
 *   涨幅数字 54vp、「昨日涨幅」30vp；副标行 25vp；业绩走势块高 210vp；
 *   横幅高 74vp；底部操作条 157vp。
 *   页面按参考截图量出的设计值复刻，内容列最多铺到双屏态竖屏宽度 664.7vp（更宽的窗口下居中），
 *   橙色头部 / 横幅 / 操作条通栏铺满；窗口更窄时整列等比缩小。
 *
 * 三态实测：
 *   单屏态        459.6×672vp   —— 内容列铺满整宽（0.85 倍），一屏看到卡片上半部分；
 *   双屏态竖屏    664.7×939.6vp —— 内容列铺满整宽（1.23 倍），涨幅行右侧被屏幕切掉；
 *   双屏态横屏    939.6×664.7vp —— 内容列 664.7vp 居中（1.23 倍），两侧露出灰底。
 *
 * 问题表现：
 *   产品卡是固定高 381.5vp 的白卡，卡内大字不再受卡片约束：
 *   三个标签向右溢出卡沿，涨幅行整体超出卡宽；
 *   「+48.43%」「昨日涨幅」「最新净值 0.8132」压到卡片右侧的橙色与灰色底上，
 *   右侧字尾被屏幕边缘切掉。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 参考截图宽度：1080px / 2.75 = 392.7vp，页面按它量设计值 */
const FPD_REFERENCE_WIDTH: number = 392.7;
/** 单屏态基准宽度 459.6vp、双屏态竖屏宽度 664.7vp：内容列最多铺到 664.7vp，更宽时居中 */
const FPD_BASE_WIDTH: number = 664.7;

/** 状态栏 / 底部手势区兜底高度（vp），拿不到避让区时使用 */
const FPD_STATUS_BAR_FALLBACK: number = 32;
const FPD_BOTTOM_INSET_FALLBACK: number = 8;

const FPD_PAGE_BG: string = '#EDEEF0';
const FPD_BRAND: string = '#FA632E';
const FPD_TEXT_MAIN: string = '#232323';
const FPD_TEXT_SUB: string = '#9C9C9C';
const FPD_RISE: string = '#E63B2E';
const FPD_TAG_ORANGE: string = '#F2653B';
const FPD_TAG_GRAY: string = '#C8C8C8';
const FPD_LABEL_GRAY: string = '#6E6E6E';
const FPD_PANEL_BG: string = '#F2F3F5';
const FPD_CHART_RED: string = '#FDF0EE';
const FPD_PROMO_BG: string = '#FFF4F2';
const FPD_PROMO_TEXT: string = '#F5550F';
const FPD_ACTION_ICON: string = '#1B2A44';

/** 头部：橙色区 186.5vp、标题行 44vp */
const FPD_HEADER_HEIGHT: number = 186.5;
const FPD_TITLE_ROW_HEIGHT: number = 44;
const FPD_TITLE_FONT: number = 17;

/** 产品卡：左右 28.4vp、上沿 67vp（标题行下 23vp）、高 381.5vp、圆角 14.5vp */
const FPD_CARD_INSET: number = 28.4;
const FPD_CARD_TOP_GAP: number = 23;
const FPD_CARD_WIDTH: number = 336;
const FPD_CARD_HEIGHT: number = 381.5;
const FPD_CARD_RADIUS: number = 14.5;

/** 卡内文字：基金名 40vp / 行高 42vp；标签行 187.6vp；涨幅行 241.8vp；副标行 319vp */
const FPD_NAME_FONT: number = 40;
const FPD_NAME_LINE_HEIGHT: number = 42;
const FPD_TAGS_TOP: number = 187.6;
const FPD_RISE_TOP: number = 241.8;
const FPD_SUB_TOP: number = 319;
const FPD_TAG_FONT: number = 15.3;
const FPD_TAG_HEIGHT: number = 24.4;
const FPD_TAG_RADIUS: number = 3.6;
const FPD_RISE_FONT: number = 54;
const FPD_RISE_UNIT_FONT: number = 33;
const FPD_RISE_LABEL_FONT: number = 30;
const FPD_SUB_FONT: number = 25;
const FPD_NET_VALUE_FONT: number = 32;

/** 业绩走势：上间距 21.8vp、高 210vp；标题 33vp；切换面板高 43.5vp */
const FPD_TREND_GAP: number = 21.8;
const FPD_TREND_HEIGHT: number = 176;
const FPD_TREND_TITLE_FONT: number = 33;
const FPD_TREND_PANEL_HEIGHT: number = 43.5;
const FPD_TREND_PANEL_FONT: number = 19;
const FPD_TREND_CHART_TOP: number = 96;

/** 横幅：高 74vp、字 25.5vp */
const FPD_PROMO_HEIGHT: number = 74;
const FPD_PROMO_FONT: number = 25.5;

/** 底部操作条：高 157vp；图标 38vp、文字 17vp；定投 / 立即投资胶囊 58.5×92.7vp */
const FPD_ACTION_HEIGHT: number = 157;
const FPD_ACTION_ICON_SIZE: number = 38;
const FPD_ACTION_LABEL_FONT: number = 17;
const FPD_ACTION_PILL_WIDTH: number = 58.5;
const FPD_ACTION_PILL_HEIGHT: number = 92.7;
const FPD_ACTION_PILL_FONT: number = 20;

@Component
export struct FundDetailOverflowPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = 459.6;
  @State winHeightVp: number = 672;
  /** 沉浸式下的状态栏 / 底部手势区高度（vp） */
  @State statusBarHeightVp: number = FPD_STATUS_BAR_FALLBACK;
  @State bottomInsetVp: number = FPD_BOTTOM_INSET_FALLBACK;

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
      this.windowToken = WindowModeController.acquire(win, '#FFFFFF');
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  /** 内容列宽度：以单屏态 459.6vp 为上限，宽窗口下保持该宽度并居中，更窄时整体缩小 */
  private pageWidth(): number {
    return Math.min(this.winWidthVp, FPD_BASE_WIDTH);
  }

  /** 把 392.7vp 参考宽下的设计值换算到当前内容列宽度 */
  private s(baseVp: number): number {
    return baseVp * this.pageWidth() / FPD_REFERENCE_WIDTH;
  }

  @Builder
  titleBar() {
    Stack({ alignContent: Alignment.Center }) {
      Text('基金详情')
        .fontSize(this.s(FPD_TITLE_FONT))
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)

      Row() {
        Text('‹')
          .fontSize(this.s(30))
          .fontColor(Color.White)
      }
      .width('100%')
      .padding({ left: this.s(12) })
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        this.pageStack.pop();
      })
    }
    .width('100%')
    .height(this.statusBarHeightVp + this.s(FPD_TITLE_ROW_HEIGHT))
    .padding({ top: this.statusBarHeightVp })
  }

  @Builder
  riskTag(tagText: string, tagColor: string) {
    Row({ space: this.s(3) }) {
      if (tagText === '中风险') {
        Text('⚡')
          .fontSize(this.s(14))
          .fontColor(tagColor)
      }

      Text(tagText)
        .fontSize(this.s(FPD_TAG_FONT))
        .fontColor(tagColor)
        .maxLines(1)
    }
    .height(this.s(FPD_TAG_HEIGHT))
    .padding({ left: this.s(7), right: this.s(7) })
    .border({ width: this.s(1.2), color: tagText === '中风险' ? FPD_TAG_ORANGE : FPD_TAG_GRAY })
    .borderRadius(this.s(FPD_TAG_RADIUS))
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  heroCard() {
    Stack({ alignContent: Alignment.TopStart }) {
      Text('平安中证新能源汽车ETF发起联接A')
        .fontSize(this.s(FPD_NAME_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(FPD_TEXT_MAIN)
        .lineHeight(this.s(FPD_NAME_LINE_HEIGHT))
        .width(this.s(292))
        .position({ x: this.s(22.5), y: this.s(27) })

      Row({ space: this.s(8.7) }) {
        this.riskTag('中风险', FPD_TAG_ORANGE)
        this.riskTag('指数型', FPD_LABEL_GRAY)
        this.riskTag('10.00元起购', FPD_LABEL_GRAY)
      }
      .width(this.s(430))
      .position({ x: this.s(22.5), y: this.s(FPD_TAGS_TOP) })

      Row() {
        Text('+48.43')
          .fontSize(this.s(FPD_RISE_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(FPD_RISE)

        Text('%')
          .fontSize(this.s(FPD_RISE_UNIT_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(FPD_RISE)
          .margin({ left: this.s(2) })

        Text('昨日涨幅')
          .fontSize(this.s(FPD_RISE_LABEL_FONT))
          .fontColor('#3F3F3F')
          .margin({ left: this.s(6) })
      }
      .width(this.s(430))
      .alignItems(VerticalAlign.Bottom)
      .position({ x: this.s(22.5), y: this.s(FPD_RISE_TOP) })

      Row() {
        Text('近一年涨幅')
          .fontSize(this.s(FPD_SUB_FONT))
          .fontColor(FPD_TEXT_SUB)

        Text('最新净值')
          .fontSize(this.s(FPD_SUB_FONT))
          .fontColor(FPD_TEXT_SUB)
          .margin({ left: this.s(12) })

        Text('0.8132')
          .fontSize(this.s(FPD_NET_VALUE_FONT))
          .fontColor('#333333')
          .margin({ left: this.s(6) })
      }
      .width(this.s(430))
      .alignItems(VerticalAlign.Bottom)
      .position({ x: this.s(22.5), y: this.s(FPD_SUB_TOP) })
    }
    .width(this.s(FPD_CARD_WIDTH))
    .height(this.s(FPD_CARD_HEIGHT))
    .backgroundColor(Color.White)
    .borderRadius(this.s(FPD_CARD_RADIUS))
    .margin({ left: this.s(FPD_CARD_INSET), top: this.s(FPD_CARD_TOP_GAP) })
    .clip(false)
  }

  @Builder
  trendSection() {
    Stack({ alignContent: Alignment.TopStart }) {
      Text('业绩走势')
        .fontSize(this.s(FPD_TREND_TITLE_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(FPD_TEXT_MAIN)
        .lineHeight(this.s(FPD_TREND_TITLE_FONT + 4))
        .width(this.s(100))
        .position({ x: this.s(12), y: this.s(22) })

      Row() {
        Text('单位净值')
          .fontSize(this.s(FPD_TREND_PANEL_FONT))
          .fontColor(FPD_TEXT_MAIN)

        Divider()
          .vertical(true)
          .height(this.s(16))
          .strokeWidth(this.s(1))
          .color('#C9C9C9')
          .margin({ left: this.s(20), right: this.s(20) })

        Text('累计净值')
          .fontSize(this.s(FPD_TREND_PANEL_FONT))
          .fontColor(FPD_TEXT_MAIN)
      }
      .width(this.s(244))
      .height(this.s(FPD_TREND_PANEL_HEIGHT))
      .justifyContent(FlexAlign.Center)
      .backgroundColor(FPD_PANEL_BG)
      .borderRadius(this.s(8))
      .position({ x: this.s(120), y: this.s(51) })

      Column() {
        Row() {
          Text('2025/02/10')
            .fontSize(this.s(15))
            .fontColor('#3A3A3A')

          Blank()

          Row({ space: this.s(3) }) {
            Text('●')
              .fontSize(this.s(10))
              .fontColor('#2B9BE8')

            Text('本基金')
              .fontSize(this.s(13))
              .fontColor('#3A3A3A')

            Text('+3.20%')
              .fontSize(this.s(13))
              .fontColor(FPD_RISE)
          }
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .height(this.s(25))
        .padding({ left: this.s(10), right: this.s(10) })
        .backgroundColor(FPD_CHART_RED)

        Row() {
          Text('59.82%')
            .fontSize(this.s(13))
            .fontColor('#6E6E6E')

          Row()
            .width(this.s(90))
            .height(this.s(1))
            .backgroundColor('#D9D9D9')
            .margin({ left: this.s(6) })

          Blank()
        }
        .width('100%')
        .margin({ top: this.s(12) })
        .padding({ left: this.s(10) })
      }
      .width(this.s(316))
      .position({ x: this.s(11.6), y: this.s(FPD_TREND_CHART_TOP) })
    }
    .width(this.s(FPD_CARD_WIDTH))
    .height(this.s(FPD_TREND_HEIGHT))
    .backgroundColor(Color.White)
    .borderRadius(this.s(FPD_CARD_RADIUS))
    .margin({ left: this.s(FPD_CARD_INSET), top: this.s(FPD_TREND_GAP) })
    .clip(false)
  }

  @Builder
  promoBanner() {
    Column() {
      Text('买基金上金管家：申购/定投费率1折')
        .fontSize(this.s(FPD_PROMO_FONT))
        .fontColor(FPD_PROMO_TEXT)
        .textAlign(TextAlign.Center)
        .width(this.s(360))
    }
    .width('100%')
    .height(this.s(FPD_PROMO_HEIGHT))
    .backgroundColor(FPD_PROMO_BG)
    .justifyContent(FlexAlign.Center)
    .margin({ top: this.s(FPD_TREND_GAP) })
  }

  @Builder
  bookmarkIcon() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width(this.s(34))
        .height(this.s(38))
        .border({ width: this.s(2.6), color: FPD_ACTION_ICON })
        .borderRadius(this.s(4))

      Text('+')
        .fontSize(this.s(26))
        .fontWeight(FontWeight.Bold)
        .fontColor(FPD_ACTION_ICON)
    }
    .width(this.s(FPD_ACTION_ICON_SIZE))
    .height(this.s(FPD_ACTION_ICON_SIZE))
  }

  @Builder
  calculatorIcon() {
    Column() {
      Row({ space: this.s(3) }) {
        Text('×')
          .fontSize(this.s(15))
          .fontColor(FPD_ACTION_ICON)
        Text('=')
          .fontSize(this.s(15))
          .fontColor(FPD_ACTION_ICON)
      }

      Row()
        .width(this.s(18))
        .height(this.s(2))
        .backgroundColor(FPD_ACTION_ICON)
        .margin({ top: this.s(3) })
    }
    .width(this.s(34))
    .height(this.s(34))
    .justifyContent(FlexAlign.Center)
    .border({ width: this.s(2.6), color: FPD_ACTION_ICON })
    .borderRadius(this.s(4))
  }

  @Builder
  actionBar() {
    Row() {
      Column() {
        this.bookmarkIcon()
        Text('加自选')
          .fontSize(this.s(FPD_ACTION_LABEL_FONT))
          .fontColor('#666666')
          .margin({ top: this.s(6) })
      }
      .width(this.s(90))
      .alignItems(HorizontalAlign.Center)

      Column() {
        this.calculatorIcon()
        Text('计算')
          .fontSize(this.s(FPD_ACTION_LABEL_FONT))
          .fontColor('#666666')
          .margin({ top: this.s(8) })
      }
      .width(this.s(90))
      .alignItems(HorizontalAlign.Center)

      Row() {
        Text('定投')
          .fontSize(this.s(FPD_ACTION_PILL_FONT))
          .fontColor(FPD_BRAND)
          .width(this.s(FPD_ACTION_PILL_WIDTH))
          .height(this.s(FPD_ACTION_PILL_HEIGHT))
          .textAlign(TextAlign.Center)
          .border({ width: this.s(2), color: FPD_BRAND })
          .borderRadius(this.s(FPD_ACTION_PILL_WIDTH / 2))

        Text('立即\n投资')
          .fontSize(this.s(FPD_ACTION_PILL_FONT))
          .fontColor(Color.White)
          .width(this.s(FPD_ACTION_PILL_WIDTH))
          .height(this.s(FPD_ACTION_PILL_HEIGHT))
          .textAlign(TextAlign.Center)
          .backgroundColor(FPD_BRAND)
          .borderRadius(this.s(FPD_ACTION_PILL_WIDTH / 2))
          .margin({ left: this.s(24) })
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.End)
      .layoutWeight(1)
    }
    .width('100%')
    .height(this.s(FPD_ACTION_HEIGHT))
    .padding({ left: this.s(12), right: this.s(16), bottom: this.bottomInsetVp })
    .backgroundColor(Color.White)
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Stack({ alignContent: Alignment.Top }) {
            // 橙色头部底色：通栏铺到标题行下方，产品卡压在它上面
            Row()
              .width('100%')
              .height(this.statusBarHeightVp + this.s(FPD_HEADER_HEIGHT - FPD_TITLE_ROW_HEIGHT))
              .backgroundColor(FPD_BRAND)

            Column() {
              this.titleBar()
              this.heroCard()
            }
            .width(this.pageWidth())
          }
          .width('100%')

          Column() {
            this.trendSection()
          }
          .width(this.pageWidth())

          this.promoBanner()

          Column() {
            this.actionBar()
          }
          .width(this.pageWidth())
        }
        .width('100%')
        .backgroundColor(FPD_PAGE_BG)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .backgroundColor(FPD_PAGE_BG)
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
