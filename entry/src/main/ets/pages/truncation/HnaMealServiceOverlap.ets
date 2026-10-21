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
 * 反例：截断 / 海航「餐食服务简介」卡片文字压盖（文字溢出卡片）
 *
 * 复刻对象：海南航空「餐食服务简介」页：返回箭头 + 居中标题「餐食服务简介」，自上而下一列
 *   淡渐变白卡（左上淡绿光斑 / 右上奶油色光斑，末段一张纯白卡），绿色标题「餐食兑换积分」+ 黑色副标题
 *   「助力绿色环保 鼓励按需用餐」+ 灰色正文，棕色标题「餐食升级」+ 棕色副标题
 *   「“味”你而来 不负“食”光」+ 灰色正文，「▤ 餐食订单 ▶」胶囊，底部红色「查看可选航班」按钮。
 *
 * 设计基准：参考截图 1080×2504px（密度 2.75，vp = px / 2.75，392.7×910.5vp）逐像素量出的设计值：
 *   标题栏（含 36vp 状态栏）高 91.6vp，标题字 20vp，返回箭头起点 x 16vp；
 *   内容区 91.6 → 750.9vp（视口 659.3vp），底部白色操作栏 750.9 → 910.5vp（高 159.6vp）；
 *   卡片左右各留 17.5vp、宽 357.7vp、圆角 10vp；五块卡片相对内容区顶的位置依次为
 *   9.5 / 151.3 / 292.4 / 339.6 / 469.1vp，高度依次为 140.4 / 139.6 / 21.1 / 65.5 / 230vp；
 *   绿色标题 (42.2, 25.1) 字号 30vp；黑色副标题 (74.2, 109.1) 字号 30vp、行高 34.5vp、宽 228vp；
 *   第一段灰色正文 (74.9, 187.1) 字号 25.4vp、行高 34.5vp、宽 233vp；
 *   棕色标题 (78.2, 354.9) 字号 30vp；棕色副标题 (53.5, 425.1) 字号 30vp、宽 300vp；
 *   第二段灰色正文 (53.1, 466.2) 字号 25.6vp、行高 30.8vp、宽 285vp；
 *   「餐食订单」胶囊 206.5×78.9vp、圆角 39.5vp，位于 (0.4, 536.7)，订单图标 31×33vp；
 *   底部灰卡上沿 (48, 641.1)、宽 291.6vp，被视口下沿切在 659.3vp 处；
 *   红色按钮 323.7×95.3vp、圆角 40.7vp、距操作栏上沿 17.1vp、字 30vp。
 *   页面按参考截图量出的设计值复刻，内容列最多铺到 664.7vp（更宽窗口下居中），
 *   标题栏与底部操作栏通栏铺满；窗口更窄时整列等比缩小。
 *
 * 三态实测（按本页布局推算三种窗口尺寸下的表现）：
 *   单屏态        459.6×672vp   —— 内容列 459.6vp（1.17 倍），视口 672vp，
 *                                 只看到标题栏、第一张卡片和第二张卡片上半部分；
 *   双屏态竖屏    664.7×939.6vp —— 内容列 664.7vp（1.69 倍），视口 939.6vp，压盖位置不变；
 *   双屏态横屏    939.6×664.7vp —— 内容列 664.7vp 居中（1.69 倍），视口 664.7vp，
 *                                 卡片与文字的压盖关系和单屏态一致。
 *
 * 问题表现：
 *   卡片高度只有 140.4vp，卡内的标题 / 副标题 / 正文明显超出卡片下沿：
 *   第一张卡片的黑色副标题第二行「励按需用餐」压在第二张卡片的淡绿光斑上，
 *   第一段灰色正文从第一张卡片一路压到第二张、第三张卡片上，
 *   棕色标题「餐食升级」与第一段正文的「餐券兑换、机票、升」那一行互相叠印，
 *   棕色副标题「“味”你而来 不负“食”光」又压在自己的灰色正文上；
 *   「餐食订单」胶囊骑在两行正文中间，胶囊里的半透明白底把下面的正文冲淡；
 *   底部红色按钮上方只露出灰卡的一条上沿，灰卡下沿被视口切掉。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 参考截图宽度：1080px / 2.75 = 392.7vp，页面按它 1:1 复刻 */
const HMS_REFERENCE_WIDTH: number = 392.7;

/** 状态栏 / 底部手势区兜底高度（vp），拿不到避让区时使用 */
const HMS_STATUS_BAR_FALLBACK: number = 36;
const HMS_BOTTOM_INSET_FALLBACK: number = 28;

const HMS_HEADER_BG: string = '#FAFAFA';
const HMS_PAGE_BG: string = '#F6F6F6';
const HMS_TITLE_TEXT: string = '#000000';
const HMS_BACK_TEXT: string = '#333333';
const HMS_HEADING_GREEN: string = '#6A9414';
const HMS_HEADING_BROWN: string = '#9A6829';
const HMS_SUB_DARK: string = '#454C52';
const HMS_BODY_GRAY: string = '#9B9B9B';
const HMS_GLOW_GREEN: string = '#EFF7DF';
const HMS_GLOW_CREAM: string = '#FBF7EB';
const HMS_GLOW_PEACH: string = '#F5EEDC';
const HMS_CAPSULE_BORDER: string = '#E7DCC6';
const HMS_CAPSULE_TEXT: string = '#1A1A1A';
const HMS_ICON_ORANGE: string = '#D98E45';
const HMS_BUTTON_RED: string = '#E0514B';
const HMS_CUT_CARD_TOP: string = '#E4E4E4';
const HMS_CUT_CARD_BOTTOM: string = '#B4B4B4';

/** 标题栏：标题行 55.6vp、标题字 20vp、返回箭头 34vp */
const HMS_TITLE_ROW_HEIGHT: number = 55.6;
const HMS_TITLE_FONT: number = 20;
const HMS_BACK_FONT: number = 34;
const HMS_BACK_INSET: number = 11;

/** 内容层总高（设计值 720vp，大于 659.3vp 的视口，所以内容可以上下滚） */
const HMS_CONTENT_HEIGHT: number = 720;

/** 卡片：左右各 17.5vp、宽 357.7vp、圆角 10vp */
const HMS_CARD_INSET: number = 17.5;
const HMS_CARD_WIDTH: number = 357.7;
const HMS_CARD_RADIUS: number = 10;

/** 五块卡片：相对内容区顶的上间距与高度（vp） */
const HMS_BAND_ONE_TOP: number = 9.5;
const HMS_BAND_ONE_HEIGHT: number = 140.4;
const HMS_BAND_TWO_TOP: number = 1.5;
const HMS_BAND_TWO_HEIGHT: number = 139.6;
const HMS_BAND_THREE_TOP: number = 1.5;
const HMS_BAND_THREE_HEIGHT: number = 21.1;
const HMS_BAND_FOUR_TOP: number = 26.2;
const HMS_BAND_FOUR_HEIGHT: number = 65.5;
const HMS_BAND_FIVE_TOP: number = 64;
const HMS_BAND_FIVE_HEIGHT: number = 230;

/** 标题字：30vp / 行高 34.5vp */
const HMS_HEADING_FONT: number = 30;
const HMS_HEADING_LINE: number = 34.5;

/** 黑色副标题：30vp / 行高 34.5vp / 宽 228vp */
const HMS_SUB_FONT: number = 30;
const HMS_SUB_LINE: number = 34.5;
const HMS_SUB_WIDTH: number = 228;

/** 第一段灰色正文：25.4vp / 行高 34.5vp / 宽 233vp */
const HMS_BODY_FONT: number = 25.4;
const HMS_BODY_LINE: number = 34.5;
const HMS_BODY_WIDTH: number = 233;

/** 棕色副标题：30vp / 宽 300vp（单行） */
const HMS_SUB_TWO_FONT: number = 30;
const HMS_SUB_TWO_WIDTH: number = 300;

/** 第二段灰色正文：25.6vp / 行高 30.8vp / 宽 285vp */
const HMS_BODY_TWO_FONT: number = 25.6;
const HMS_BODY_TWO_LINE: number = 30.8;
const HMS_BODY_TWO_WIDTH: number = 285;

/** 文字块在设计宽下的左上角坐标（vp） */
const HMS_HEADING_ONE_X: number = 42.2;
const HMS_HEADING_ONE_Y: number = 25.1;
const HMS_SUB_ONE_X: number = 74.2;
const HMS_SUB_ONE_Y: number = 109.1;
const HMS_BODY_ONE_X: number = 74.9;
const HMS_BODY_ONE_Y: number = 187.1;
const HMS_HEADING_TWO_X: number = 78.2;
const HMS_HEADING_TWO_Y: number = 354.9;
const HMS_SUB_TWO_X: number = 53.5;
const HMS_SUB_TWO_Y: number = 425.1;
const HMS_BODY_TWO_X: number = 53.1;
const HMS_BODY_TWO_Y: number = 466.2;

/** 「餐食订单」胶囊：206.5×78.9vp、圆角 39.5vp，位于 (0.4, 536.7) */
const HMS_CAPSULE_X: number = 0.4;
const HMS_CAPSULE_Y: number = 536.7;
const HMS_CAPSULE_WIDTH: number = 206.5;
const HMS_CAPSULE_HEIGHT: number = 78.9;
const HMS_CAPSULE_RADIUS: number = 39.5;
const HMS_CAPSULE_FONT: number = 25;
const HMS_CAPSULE_LINE: number = 30;
const HMS_CAPSULE_TEXT_X: number = 67.6;
const HMS_CAPSULE_TEXT_Y: number = 23.5;
const HMS_ICON_X: number = 30.2;
const HMS_ICON_Y: number = 23.6;
const HMS_ICON_WIDTH: number = 31;
const HMS_ICON_HEIGHT: number = 33;
const HMS_ARROW_X: number = 171;
const HMS_ARROW_Y: number = 29;
const HMS_ARROW_FONT: number = 18;

/** 底部被视口切掉的灰卡：上沿 (48, 641.1)、宽 291.6vp、圆角 11vp */
const HMS_CUT_CARD_X: number = 48;
const HMS_CUT_CARD_Y: number = 641.1;
const HMS_CUT_CARD_WIDTH: number = 291.6;
const HMS_CUT_CARD_HEIGHT: number = 60;
const HMS_CUT_CARD_RADIUS: number = 11;

/** 底部操作栏：内容高 131.6vp（另加手势区），红色按钮 323.7×95.3vp、圆角 40.7vp */
const HMS_BOTTOM_BAR_HEIGHT: number = 131.6;
const HMS_BUTTON_TOP_GAP: number = 17.1;
const HMS_BUTTON_SIDE: number = 34.5;
const HMS_BUTTON_HEIGHT: number = 95.3;
const HMS_BUTTON_RADIUS: number = 40.7;
const HMS_BUTTON_FONT: number = 30;

const HMS_HEADING_ONE_TEXT: string = '餐食兑换积分';
const HMS_HEADING_TWO_TEXT: string = '餐食升级';
const HMS_SUB_ONE_TEXT: string = '助力绿色环保 鼓励按需用餐';
const HMS_SUB_TWO_TEXT: string = '“味”你而来 不负“食”光';
const HMS_BODY_ONE_TEXT: string = '主动取消机上免费餐食，获取等价值积分奖励，可用于为您和您指定的亲朋好友免费兑换奖励品，' +
  '奖励餐券兑换、机票、升舱、金鹏商城奖励';
const HMS_BODY_TWO_TEXT: string = '本服务加购餐食，如航班配备免费餐食，免费餐食继续提供，您也可以选择“餐食，' +
  '您也可以取消免费餐食，获取等价值积分奖励';
const HMS_BUTTON_TEXT: string = '查看可选航班';
const HMS_CAPSULE_TEXT_STR: string = '餐食订单';

@Component
export struct HnaMealServiceOverlapPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = 459.6;
  @State winHeightVp: number = 672;
  /** 沉浸式下的状态栏 / 底部手势区高度（vp） */
  @State statusBarHeightVp: number = HMS_STATUS_BAR_FALLBACK;
  @State bottomInsetVp: number = HMS_BOTTOM_INSET_FALLBACK;

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

  /** 内容列宽度：参考设计宽 392.7vp，窗口更宽时保持原宽并居中，更窄时整体缩小 */
  private pageWidth(): number {
    return Math.min(this.winWidthVp, 664.7);
  }

  /** 把 392.7vp 参考宽下的设计值换算到当前内容列宽度 */
  private s(baseVp: number): number {
    return baseVp * this.pageWidth() / HMS_REFERENCE_WIDTH;
  }

  /** 卡片底板：白底 + 左上淡绿光斑 + 右上奶油色光斑 */
  @Builder
  paleCard(cardHeight: number, topGap: number, glowWidth: number, glowHeight: number,
    warmWidth: number, warmHeight: number) {
    Stack({ alignContent: Alignment.TopStart }) {
      Row()
        .width('100%')
        .height('100%')
        .backgroundColor(Color.White)
        .borderRadius(this.s(HMS_CARD_RADIUS))

      Row()
        .width(this.s(glowWidth))
        .height(this.s(glowHeight))
        .backgroundColor(HMS_GLOW_GREEN)
        .borderRadius(this.s(glowHeight / 2))
        .position({ x: this.s(1.8), y: this.s(2.5) })

      Row()
        .width(this.s(warmWidth))
        .height(this.s(warmHeight))
        .backgroundColor(HMS_GLOW_CREAM)
        .borderRadius(this.s(warmHeight / 2))
        .position({ x: this.s(HMS_CARD_WIDTH - warmWidth - 1), y: this.s(1.5) })
    }
    .width(this.s(HMS_CARD_WIDTH))
    .height(this.s(cardHeight))
    .margin({ top: this.s(topGap), left: this.s(HMS_CARD_INSET) })
  }

  /** 卡片底板：白底 + 左侧蜜桃色光斑 */
  @Builder
  warmCard(cardHeight: number, topGap: number, warmWidth: number, warmHeight: number) {
    Stack({ alignContent: Alignment.TopStart }) {
      Row()
        .width('100%')
        .height('100%')
        .backgroundColor(Color.White)
        .borderRadius(this.s(HMS_CARD_RADIUS))

      Row()
        .width(this.s(warmWidth))
        .height(this.s(warmHeight))
        .backgroundColor(HMS_GLOW_PEACH)
        .borderRadius(this.s(warmHeight / 2))
        .position({ x: this.s(1.8), y: this.s(1.5) })
    }
    .width(this.s(HMS_CARD_WIDTH))
    .height(this.s(cardHeight))
    .margin({ top: this.s(topGap), left: this.s(HMS_CARD_INSET) })
  }

  /** 卡片底板：纯白底 */
  @Builder
  plainCard(cardHeight: number, topGap: number) {
    Stack({ alignContent: Alignment.TopStart }) {
      Row()
        .width('100%')
        .height('100%')
        .backgroundColor(Color.White)
        .borderRadius(this.s(HMS_CARD_RADIUS))
    }
    .width(this.s(HMS_CARD_WIDTH))
    .height(this.s(cardHeight))
    .margin({ top: this.s(topGap), left: this.s(HMS_CARD_INSET) })
  }

  /** 五块卡片底板按量出的位置自上而下排开 */
  @Builder
  cardBackdrop() {
    Column() {
      this.paleCard(HMS_BAND_ONE_HEIGHT, HMS_BAND_ONE_TOP, 202, 45, 190, 48)
      this.paleCard(HMS_BAND_TWO_HEIGHT, HMS_BAND_TWO_TOP, 118, 33, 200, 52)
      this.paleCard(HMS_BAND_THREE_HEIGHT, HMS_BAND_THREE_TOP, 118, 17, 190, 16)
      this.warmCard(HMS_BAND_FOUR_HEIGHT, HMS_BAND_FOUR_TOP, 179, 49)
      this.plainCard(HMS_BAND_FIVE_HEIGHT, HMS_BAND_FIVE_TOP)
    }
    .width(this.pageWidth())
    .alignItems(HorizontalAlign.Start)
  }

  /** 文字层：四段标题 / 副标题 / 正文按量出的坐标铺在卡片之上，卡片高度不够时文字直接压到下一张卡片 */
  @Builder
  textLayer() {
    Stack({ alignContent: Alignment.TopStart }) {
      Text(HMS_HEADING_ONE_TEXT)
        .fontSize(this.s(HMS_HEADING_FONT))
        .fontWeight(FontWeight.Medium)
        .fontColor(HMS_HEADING_GREEN)
        .lineHeight(this.s(HMS_HEADING_LINE))
        .width(this.s(200))
        .position({ x: this.s(HMS_HEADING_ONE_X), y: this.s(HMS_HEADING_ONE_Y) })

      Text(HMS_SUB_ONE_TEXT)
        .fontSize(this.s(HMS_SUB_FONT))
        .fontWeight(FontWeight.Medium)
        .fontColor(HMS_SUB_DARK)
        .lineHeight(this.s(HMS_SUB_LINE))
        .width(this.s(HMS_SUB_WIDTH))
        .position({ x: this.s(HMS_SUB_ONE_X), y: this.s(HMS_SUB_ONE_Y) })

      Text(HMS_BODY_ONE_TEXT)
        .fontSize(this.s(HMS_BODY_FONT))
        .fontColor(HMS_BODY_GRAY)
        .lineHeight(this.s(HMS_BODY_LINE))
        .width(this.s(HMS_BODY_WIDTH))
        .position({ x: this.s(HMS_BODY_ONE_X), y: this.s(HMS_BODY_ONE_Y) })

      Text(HMS_HEADING_TWO_TEXT)
        .fontSize(this.s(HMS_HEADING_FONT))
        .fontWeight(FontWeight.Medium)
        .fontColor(HMS_HEADING_BROWN)
        .lineHeight(this.s(HMS_HEADING_LINE))
        .width(this.s(170))
        .position({ x: this.s(HMS_HEADING_TWO_X), y: this.s(HMS_HEADING_TWO_Y) })

      Text(HMS_SUB_TWO_TEXT)
        .fontSize(this.s(HMS_SUB_TWO_FONT))
        .fontWeight(FontWeight.Medium)
        .fontColor(HMS_HEADING_BROWN)
        .lineHeight(this.s(HMS_SUB_LINE))
        .width(this.s(HMS_SUB_TWO_WIDTH))
        .position({ x: this.s(HMS_SUB_TWO_X), y: this.s(HMS_SUB_TWO_Y) })

      Text(HMS_BODY_TWO_TEXT)
        .fontSize(this.s(HMS_BODY_TWO_FONT))
        .fontColor(HMS_BODY_GRAY)
        .lineHeight(this.s(HMS_BODY_TWO_LINE))
        .width(this.s(HMS_BODY_TWO_WIDTH))
        .position({ x: this.s(HMS_BODY_TWO_X), y: this.s(HMS_BODY_TWO_Y) })
    }
    .width(this.pageWidth())
    .height(this.s(HMS_CONTENT_HEIGHT))
  }

  /** 胶囊里的订单图标：文件 + 时钟 */
  @Builder
  mealOrderIcon() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        Row()
          .width(this.s(9))
          .height(this.s(1.4))
          .backgroundColor(HMS_ICON_ORANGE)

        Row()
          .width(this.s(9))
          .height(this.s(1.4))
          .backgroundColor(HMS_ICON_ORANGE)
          .margin({ top: this.s(2.6) })

        Row()
          .width(this.s(6))
          .height(this.s(1.4))
          .backgroundColor(HMS_ICON_ORANGE)
          .margin({ top: this.s(2.6) })
      }
      .width(this.s(20))
      .height(this.s(25))
      .padding({ top: this.s(5), left: this.s(4) })
      .border({ width: this.s(1.4), color: HMS_ICON_ORANGE })
      .borderRadius(this.s(2.5))
      .position({ x: this.s(11), y: this.s(0) })

      Row()
        .width(this.s(13.5))
        .height(this.s(13.5))
        .backgroundColor(Color.White)
        .border({ width: this.s(1.4), color: HMS_ICON_ORANGE })
        .borderRadius(this.s(6.75))
        .position({ x: this.s(0), y: this.s(19) })
    }
    .width(this.s(HMS_ICON_WIDTH))
    .height(this.s(HMS_ICON_HEIGHT))
    .position({ x: this.s(HMS_ICON_X), y: this.s(HMS_ICON_Y) })
  }

  /** 「餐食订单 ▶」胶囊：骑在两行正文中间，半透明白底把下面的正文冲淡 */
  @Builder
  orderCapsule() {
    Stack({ alignContent: Alignment.TopStart }) {
      Row()
        .width('100%')
        .height('100%')
        .backgroundColor(Color.White)
        .borderRadius(this.s(HMS_CAPSULE_RADIUS))
        .opacity(0.62)

      Row()
        .width('100%')
        .height('100%')
        .border({ width: this.s(1.2), color: HMS_CAPSULE_BORDER })
        .borderRadius(this.s(HMS_CAPSULE_RADIUS))

      this.mealOrderIcon()

      Text(HMS_CAPSULE_TEXT_STR)
        .fontSize(this.s(HMS_CAPSULE_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(HMS_CAPSULE_TEXT)
        .lineHeight(this.s(HMS_CAPSULE_LINE))
        .width(this.s(110))
        .position({ x: this.s(HMS_CAPSULE_TEXT_X), y: this.s(HMS_CAPSULE_TEXT_Y) })

      Text('▶')
        .fontSize(this.s(HMS_ARROW_FONT))
        .fontColor(HMS_CAPSULE_TEXT)
        .position({ x: this.s(HMS_ARROW_X), y: this.s(HMS_ARROW_Y) })
    }
    .width(this.s(HMS_CAPSULE_WIDTH))
    .height(this.s(HMS_CAPSULE_HEIGHT))
    .position({ x: this.s(HMS_CAPSULE_X), y: this.s(HMS_CAPSULE_Y) })
  }

  /** 红色按钮上方的灰卡，只有上沿露在视口里 */
  @Builder
  bottomGrayCard() {
    Row()
      .width(this.s(HMS_CUT_CARD_WIDTH))
      .height(this.s(HMS_CUT_CARD_HEIGHT))
      .linearGradient({
        angle: 180,
        colors: [[HMS_CUT_CARD_TOP, 0.0], [HMS_CUT_CARD_BOTTOM, 1.0]]
      })
      .borderRadius(this.s(HMS_CUT_CARD_RADIUS))
      .position({ x: this.s(HMS_CUT_CARD_X), y: this.s(HMS_CUT_CARD_Y) })
  }

  /** 标题行：返回箭头 + 居中标题 */
  @Builder
  titleRow() {
    Stack({ alignContent: Alignment.Center }) {
      Text('餐食服务简介')
        .fontSize(this.s(HMS_TITLE_FONT))
        .fontWeight(FontWeight.Medium)
        .fontColor(HMS_TITLE_TEXT)

      Row() {
        Text('‹')
          .fontSize(this.s(HMS_BACK_FONT))
          .fontColor(HMS_BACK_TEXT)
      }
      .width('100%')
      .padding({ left: this.s(HMS_BACK_INSET) })
      .justifyContent(FlexAlign.Start)
      .onClick(() => {
        this.pageStack.pop();
      })
    }
    .width('100%')
    .height(this.statusBarHeightVp + this.s(HMS_TITLE_ROW_HEIGHT))
    .padding({ top: this.statusBarHeightVp })
  }

  /** 标题栏：浅灰通栏底 + 居中内容列 */
  @Builder
  pageHeader() {
    Stack({ alignContent: Alignment.Top }) {
      Row()
        .width('100%')
        .height(this.statusBarHeightVp + this.s(HMS_TITLE_ROW_HEIGHT))
        .backgroundColor(HMS_HEADER_BG)

      Column() {
        this.titleRow()
      }
      .width(this.pageWidth())
    }
    .width('100%')
    .height(this.statusBarHeightVp + this.s(HMS_TITLE_ROW_HEIGHT))
  }

  /** 底部白色操作栏：红色「查看可选航班」按钮 */
  @Builder
  bottomActionBar() {
    Row() {
      Row() {
        Text(HMS_BUTTON_TEXT)
          .fontSize(this.s(HMS_BUTTON_FONT))
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
      }
      .width(this.pageWidth() - this.s(HMS_BUTTON_SIDE * 2))
      .height(this.s(HMS_BUTTON_HEIGHT))
      .backgroundColor(HMS_BUTTON_RED)
      .borderRadius(this.s(HMS_BUTTON_RADIUS))
      .justifyContent(FlexAlign.Center)
      .margin({ top: this.s(HMS_BUTTON_TOP_GAP) })
    }
    .width('100%')
    .height(this.s(HMS_BOTTOM_BAR_HEIGHT) + this.bottomInsetVp)
    .backgroundColor(Color.White)
    .alignItems(VerticalAlign.Top)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    NavDestination() {
      Column() {
        this.pageHeader()

        Scroll() {
          Stack({ alignContent: Alignment.TopStart }) {
            this.cardBackdrop()
            this.textLayer()
            this.orderCapsule()
            this.bottomGrayCard()
          }
          .width(this.pageWidth())
          .height(this.s(HMS_CONTENT_HEIGHT))
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .backgroundColor(HMS_PAGE_BG)

        this.bottomActionBar()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(HMS_PAGE_BG)
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
