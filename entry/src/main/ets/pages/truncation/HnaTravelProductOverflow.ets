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
 * 反例：截断溢出 / 海航飞出行产品页大字溢出（文字溢出）
 *
 * 复刻对象：海南航空「海航飞」出行产品页 —— 白色标题栏（返回「‹」+ 居中「海航飞」）、
 *   粉色棋盘格 + 黄色手绘高亮的头图区（三行大标题「请选择适合您的出行产品」、
 *   右侧「我的订单」浅粉胶囊）、三个圆形产品图标（飞机 / 日历 / 地球）与
 *   图标下的「国内单次卡」「国内多次卡」「国际单次卡」及「卡」字下的黄色高亮条、
 *   白色圆角底部弹层（顶部小凸起、两列竖排浅灰占位字「选择出发地」「选择日期」、
 *   右侧「价格日历」、白色「去退订」胶囊与右下角红色「去退订」胶囊）。
 *
 * 设计基准：参考截图 1080×2504px（密度 2.75，vp = px / 2.75，即 392.7×910.5vp）量出的设计值：
 *   状态栏 40vp；标题行 47.3vp（标题 20vp、返回箭头 30vp、左边距 16vp）；
 *   粉色头图高 203.6vp，棋盘格 10.2vp 一格（横 25 格、纵 9 格）；
 *   大标题字号 48.7vp / 行高 59vp / 块 205×177vp，首行上沿在粉区顶下 42vp、左边 45.5vp；
 *   「我的订单」胶囊 125.5×46.5vp，在粉区顶下 108vp、左边 258.2vp，圆角 11vp；
 *   三个产品图标直径 117.1vp，圆心距白区顶 78.5vp，圆心 x = 112.7 / 232.7 / 338.2vp；
 *   标签字号 24vp / 行高 29.5vp、列宽 100vp、行高固定 24vp（只放得下一行），
 *   三列左 61.8 / 182.9 / 288vp、顶 215.6vp（与三个图标圆心对齐）；
 *   黄色高亮条 140×14.5vp，顶 271vp、左 52.7vp；
 *   弹层从 604.7vp 起、高 305.8vp、顶部圆角 47.3vp，顶部凸起 76×34vp（左 83.6vp）；
 *   竖排占位字 36vp / 行高 48vp、单字宽 35vp，两列左 70.5 / 167.3vp、顶 26.7vp，
 *   右侧「价格日历」字号 26vp，左 254.5vp、顶 121.6vp；
 *   白色胶囊 225.5×83.6vp（左 61.8vp、顶 146.2vp）、红色胶囊 227.6×85.5vp
 *   （左 289.5vp、顶 145.1vp），胶囊字号 29vp；底部手势条 129×7.3vp。
 *   页面按参考截图量出的设计值复刻，内容列最多铺到 664.7vp（更宽窗口下居中），
 *   头图 / 弹层通栏铺满；窗口更窄时整列等比缩小。
 *
 * 三态实测：
 *   单屏态        459.6×672vp   —— 内容列 459.6vp（1.17 倍），整页 1065vp 高，一屏看到标题、
 *      粉色头图、压出粉区的三行大标题、三个图标与掉出标签行的「卡」字，弹层只露顶部；
 *   双屏态竖屏    664.7×939.6vp —— 内容列 664.7vp（1.69 倍），整页 1538vp，需下滑，
 *      右侧红色胶囊右端越过窗口右缘被切掉一截，灰字仍压在两个按钮上；
 *   双屏态横屏    939.6×664.7vp —— 内容列 664.7vp 居中（1.69 倍），窗口只有 664.7vp 高，
 *      一屏到弹层顶部为止，弹层里的按钮要下滑才见。
 *
 * 问题表现：
 *   粉色头图是固定高 203.6vp 的色块，三行大标题（177vp 高）从粉区顶下 42vp 起排，
 *   第三行「行产品」的字脚落到 298vp 附近，比粉区下沿（290.9vp）低出 7vp，
 *   直接印在下面的白色页面上；
 *   标签行是固定 24vp 高的一行，字号 24vp 的「国内单次卡」等被挤成两行，
 *   第二行「卡」与黄色高亮条一起掉到标签行外面，落在弹层上方的白区；
 *   弹层里两列浅灰占位字每行只排一个字、竖着往下长，「选择出发地」的五个字排到 823vp，
 *   第三、四个字整块被「去退订」两个按钮挡住，第五个字只剩按钮下沿的一截；
 *   白色胶囊压住「选择日期」一列的中段，红色胶囊压住右侧「价格日历」的下半截；
 *   弹层右侧的红色胶囊从 289.5vp 起、宽 227.6vp，右端越过内容列（392.7vp）与窗口右边缘，
 *   在单屏态只露出「去退」两个字，第三个字被屏幕边缘切掉，按钮右半截与圆角看不到。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 参考截图宽度：1080px / 2.75 = 392.7vp，页面按它 1:1 复刻 */
const HTP_REFERENCE_WIDTH: number = 392.7;

/** 状态栏 / 底部手势区兜底高度（vp），拿不到避让区时使用 */
const HTP_STATUS_BAR_FALLBACK: number = 40;
const HTP_BOTTOM_INSET_FALLBACK: number = 8;

const HTP_PAGE_BG: string = '#FAFAFA';
const HTP_TITLE_COLOR: string = '#141414';
const HTP_BACK_COLOR: string = '#333333';
const HTP_HEADLINE_COLOR: string = '#0D0D0D';
const HTP_LABEL_COLOR: string = '#141414';
const HTP_CHECKER_SQUARE: string = '#FFD9DD';
const HTP_STREAK_COLOR: string = '#FFF86E';
const HTP_CAPSULE_TEXT_COLOR: string = '#A81E1E';
const HTP_PLACEHOLDER_COLOR: string = '#D8D8D8';
const HTP_BUTTON_TEXT_COLOR: string = '#6E6E6E';
const HTP_RED: string = '#E33B36';
const HTP_HOME_BAR_COLOR: string = '#7E7E7E';

/** 标题行：47.3vp 高，标题 20vp、返回箭头 30vp、左边距 16vp */
const HTP_TITLE_ROW_HEIGHT: number = 47.3;
const HTP_TITLE_FONT: number = 20;
const HTP_BACK_FONT: number = 30;
const HTP_BACK_INSET: number = 16;

/** 粉色头图：203.6vp 高；棋盘格 10.2vp 一格、横 25 格纵 9 格 */
const HTP_HERO_HEIGHT: number = 203.6;
const HTP_CHECKER_CELL: number = 10.2;
const HTP_CHECKER_COLUMN_COUNT: number = 25;
const HTP_CHECKER_ROW_COUNT: number = 9;

/** 三行大标题：48.7vp / 行高 59vp / 块 199.5×177vp，左边 45.5vp、顶 42vp */
const HTP_HEADLINE_FONT: number = 48.7;
const HTP_HEADLINE_LINE_HEIGHT: number = 59;
const HTP_HEADLINE_WIDTH: number = 205;
const HTP_HEADLINE_HEIGHT: number = 177;
const HTP_HEADLINE_X: number = 45.5;
const HTP_HEADLINE_Y: number = 42;

/** 黄色手绘高亮：两段 7.3vp 粗的圆头短线，斜着从 21.5/49.4 划到 200/38.6 */
const HTP_STREAK_THICKNESS: number = 7.3;
const HTP_STREAK_ONE_WIDTH: number = 87.9;
const HTP_STREAK_ONE_X: number = 21.5;
const HTP_STREAK_ONE_Y: number = 49.4;
const HTP_STREAK_ONE_ANGLE: number = -6.7;
const HTP_STREAK_TWO_WIDTH: number = 91.6;
const HTP_STREAK_TWO_X: number = 108.7;
const HTP_STREAK_TWO_Y: number = 38.6;
const HTP_STREAK_TWO_ANGLE: number = -7.3;

/** 「我的订单」胶囊：125.5×46.5vp，左 258.2vp、顶 108vp，圆角 11vp，字 22vp */
const HTP_CAPSULE_WIDTH: number = 125.5;
const HTP_CAPSULE_HEIGHT: number = 46.5;
const HTP_CAPSULE_X: number = 258.2;
const HTP_CAPSULE_Y: number = 108;
const HTP_CAPSULE_RADIUS: number = 11;
const HTP_CAPSULE_FONT: number = 22;
const HTP_CAPSULE_PAD_LEFT: number = 11.6;
const HTP_CAPSULE_PAD_RIGHT: number = 3;
const HTP_CAPSULE_ARROW_SIZE: number = 18.2;
const HTP_CAPSULE_ARROW_FONT: number = 14;

/** 图标区：高 313.8vp；图标 117.1vp，圆心距顶 78.5vp，x = 112.7 / 232.7 / 338.2vp */
const HTP_ICON_AREA_HEIGHT: number = 313.8;
const HTP_ICON_SIZE: number = 117.1;
const HTP_ICON_TOP: number = 78.5;
const HTP_ICON_LEFT_ONE: number = 54.1;
const HTP_ICON_LEFT_TWO: number = 174.1;
const HTP_ICON_LEFT_THREE: number = 279.6;

/** 标签：24vp / 行高 29.5vp、列宽 100vp、行高固定 24vp、顶 215.6vp */
const HTP_LABEL_FONT: number = 24;
const HTP_LABEL_LINE_HEIGHT: number = 29.5;
const HTP_LABEL_COLUMN_WIDTH: number = 100;
const HTP_LABEL_ROW_HEIGHT: number = 24;
const HTP_LABEL_TEXT_HEIGHT: number = 59;
const HTP_LABEL_TOP: number = 215.6;
const HTP_LABEL_ROW_X: number = 61.8;
const HTP_LABEL_ROW_WIDTH: number = 326.2;

/** 黄色高亮条：140×14.5vp，左 52.7vp、顶 271vp */
const HTP_HIGHLIGHT_WIDTH: number = 140;
const HTP_HIGHLIGHT_HEIGHT: number = 14.5;
const HTP_HIGHLIGHT_X: number = 52.7;
const HTP_HIGHLIGHT_Y: number = 271;
const HTP_HIGHLIGHT_RADIUS: number = 4;

/** 弹层顶部凸起：76×34vp，左 83.6vp、顶 294.5vp（下半截压在弹层里） */
const HTP_NOTCH_WIDTH: number = 76;
const HTP_NOTCH_HEIGHT: number = 34;
const HTP_NOTCH_X: number = 83.6;
const HTP_NOTCH_Y: number = 294.5;
const HTP_NOTCH_RADIUS: number = 28;

/** 弹层：高 305.8vp、顶部圆角 47.3vp */
const HTP_SHEET_HEIGHT: number = 305.8;
const HTP_SHEET_RADIUS: number = 47.3;

/** 竖排占位字：36vp / 行高 48vp、单字宽 35vp；两列左 70.5 / 167.3vp、顶 26.7vp */
const HTP_PLACEHOLDER_FONT: number = 36;
const HTP_PLACEHOLDER_LINE_HEIGHT: number = 48;
const HTP_PLACEHOLDER_BOX_WIDTH: number = 35;
const HTP_PLACEHOLDER_TOP: number = 26.7;
const HTP_PLACEHOLDER_X_ONE: number = 70.5;
const HTP_PLACEHOLDER_X_TWO: number = 167.3;
const HTP_PLACEHOLDER_HEIGHT_ONE: number = 240;
const HTP_PLACEHOLDER_HEIGHT_TWO: number = 192;
const HTP_PRICE_X: number = 254.5;
const HTP_PRICE_Y: number = 121.6;
const HTP_PRICE_FONT: number = 26;
const HTP_PRICE_LINE_HEIGHT: number = 36;
const HTP_PRICE_WIDTH: number = 104;

/** 两个按钮：白色 225.5×83.6vp（左 61.8vp、顶 146.2vp）、红色 227.6×85.5vp（左 289.5vp、顶 145.1vp） */
const HTP_WHITE_BUTTON_WIDTH: number = 225.5;
const HTP_WHITE_BUTTON_HEIGHT: number = 83.6;
const HTP_WHITE_BUTTON_X: number = 61.8;
const HTP_WHITE_BUTTON_Y: number = 146.2;
const HTP_RED_BUTTON_WIDTH: number = 227.6;
const HTP_RED_BUTTON_HEIGHT: number = 85.5;
const HTP_RED_BUTTON_X: number = 289.5;
const HTP_RED_BUTTON_Y: number = 145.1;
const HTP_BUTTON_FONT: number = 29;

/** 底部手势条：129×7.3vp，顶 284.4vp、左 131.9vp */
const HTP_HOME_BAR_WIDTH: number = 129;
const HTP_HOME_BAR_HEIGHT: number = 7.3;
const HTP_HOME_BAR_X: number = 131.9;
const HTP_HOME_BAR_Y: number = 284.4;

/** 图标下的一行标签：文字 + 在标签行里的左边距（同一行放三列，各自固定宽 100vp） */
interface HtpProductLabel {
  labelText: string;
  labelX: number;
}

const HTP_PRODUCT_LABELS: HtpProductLabel[] = [
  { labelText: '国内单次卡', labelX: 0 },
  { labelText: '国内多次卡', labelX: 121.1 },
  { labelText: '国际单次卡', labelX: 226.2 }
];

const HTP_CHECKER_ROW_IDS: number[] = [0, 1, 2, 3, 4, 5, 6, 7, 8];

const HTP_CHECKER_COLUMN_IDS: number[] = [
  0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
  12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24
];

@Component
export struct HnaTravelProductOverflowPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = 459.6;
  @State winHeightVp: number = 672;
  /** 沉浸式下的状态栏 / 底部手势区高度（vp） */
  @State statusBarHeightVp: number = HTP_STATUS_BAR_FALLBACK;
  @State bottomInsetVp: number = HTP_BOTTOM_INSET_FALLBACK;

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
    return baseVp * this.pageWidth() / HTP_REFERENCE_WIDTH;
  }

  /** 棋盘格越往右下越淡，靠边角的格子几乎看不见 */
  private checkerCellOpacity(colIdx: number, rowIdx: number): number {
    const colRatio: number = colIdx / (HTP_CHECKER_COLUMN_COUNT - 1);
    const rowRatio: number = rowIdx / (HTP_CHECKER_ROW_COUNT - 1);
    const fade: number = 1 - colRatio * 0.72 - rowRatio * 0.6;
    return Math.max(0.04, fade);
  }

  @Builder
  titleBar() {
    Stack({ alignContent: Alignment.Center }) {
      Text('海航飞')
        .fontSize(this.s(HTP_TITLE_FONT))
        .fontWeight(FontWeight.Medium)
        .fontColor(HTP_TITLE_COLOR)

      Row() {
        Text('‹')
          .fontSize(this.s(HTP_BACK_FONT))
          .fontColor(HTP_BACK_COLOR)
      }
      .width('100%')
      .padding({ left: this.s(HTP_BACK_INSET) })
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        this.pageStack.pop();
      })
    }
    .width('100%')
    .height(this.statusBarHeightVp + this.s(HTP_TITLE_ROW_HEIGHT))
    .padding({ top: this.statusBarHeightVp })
  }

  @Builder
  checkerGrid() {
    Stack({ alignContent: Alignment.TopStart }) {
      ForEach(HTP_CHECKER_ROW_IDS, (rowIdx: number) => {
        ForEach(HTP_CHECKER_COLUMN_IDS, (colIdx: number) => {
          if ((rowIdx + colIdx) % 2 === 1) {
            Row()
              .width(this.s(HTP_CHECKER_CELL))
              .height(this.s(HTP_CHECKER_CELL))
              .backgroundColor(HTP_CHECKER_SQUARE)
              .opacity(this.checkerCellOpacity(colIdx, rowIdx))
              .position({
                x: this.s(colIdx * HTP_CHECKER_CELL),
                y: this.s(rowIdx * HTP_CHECKER_CELL + 2)
              })
          }
        }, (colIdx: number): string => `htp-cell-${rowIdx}-${colIdx}`)
      }, (rowIdx: number): string => `htp-row-${rowIdx}`)
    }
    .width(this.s(HTP_CHECKER_CELL * HTP_CHECKER_COLUMN_COUNT))
    .height(this.s(HTP_CHECKER_CELL * HTP_CHECKER_ROW_COUNT))
    .clip(false)
  }

  @Builder
  handStreak() {
    Stack({ alignContent: Alignment.TopStart }) {
      Row()
        .width(this.s(HTP_STREAK_ONE_WIDTH))
        .height(this.s(HTP_STREAK_THICKNESS))
        .borderRadius(this.s(HTP_STREAK_THICKNESS / 2))
        .backgroundColor(HTP_STREAK_COLOR)
        .rotate({ angle: HTP_STREAK_ONE_ANGLE })
        .position({ x: this.s(HTP_STREAK_ONE_X), y: this.s(HTP_STREAK_ONE_Y) })

      Row()
        .width(this.s(HTP_STREAK_TWO_WIDTH))
        .height(this.s(HTP_STREAK_THICKNESS))
        .borderRadius(this.s(HTP_STREAK_THICKNESS / 2))
        .backgroundColor(HTP_STREAK_COLOR)
        .rotate({ angle: HTP_STREAK_TWO_ANGLE })
        .position({ x: this.s(HTP_STREAK_TWO_X), y: this.s(HTP_STREAK_TWO_Y) })
    }
    .width(this.pageWidth())
    .height(this.s(HTP_HERO_HEIGHT))
    .clip(false)
  }

  @Builder
  orderCapsule() {
    Row() {
      Text('我的订单')
        .fontSize(this.s(HTP_CAPSULE_FONT))
        .fontWeight(FontWeight.Medium)
        .fontColor(HTP_CAPSULE_TEXT_COLOR)
        .maxLines(1)

      Blank()

      Stack({ alignContent: Alignment.Center }) {
        Text('›')
          .fontSize(this.s(HTP_CAPSULE_ARROW_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(HTP_CAPSULE_TEXT_COLOR)
      }
      .width(this.s(HTP_CAPSULE_ARROW_SIZE))
      .height(this.s(HTP_CAPSULE_ARROW_SIZE))
      .borderRadius(this.s(HTP_CAPSULE_ARROW_SIZE / 2))
      .backgroundColor('#FFDCE1')
    }
    .width(this.s(HTP_CAPSULE_WIDTH))
    .height(this.s(HTP_CAPSULE_HEIGHT))
    .padding({ left: this.s(HTP_CAPSULE_PAD_LEFT), right: this.s(HTP_CAPSULE_PAD_RIGHT) })
    .borderRadius(this.s(HTP_CAPSULE_RADIUS))
    .linearGradient({
      angle: 100,
      colors: [['#FFF1F1', 0], ['#FFDDE2', 1]]
    })
    .position({ x: this.s(HTP_CAPSULE_X), y: this.s(HTP_CAPSULE_Y) })
  }

  @Builder
  heroBand() {
    Stack({ alignContent: Alignment.TopStart }) {
      this.checkerGrid()
      this.handStreak()

      Text('请选择适合您的出行产品')
        .fontSize(this.s(HTP_HEADLINE_FONT))
        .lineHeight(this.s(HTP_HEADLINE_LINE_HEIGHT))
        .fontWeight(FontWeight.Bold)
        .fontColor(HTP_HEADLINE_COLOR)
        .width(this.s(HTP_HEADLINE_WIDTH))
        .height(this.s(HTP_HEADLINE_HEIGHT))
        .position({ x: this.s(HTP_HEADLINE_X), y: this.s(HTP_HEADLINE_Y) })

      this.orderCapsule()
    }
    .width(this.pageWidth())
    .height(this.s(HTP_HERO_HEIGHT))
    .clip(false)
  }

  @Builder
  planeIcon() {
    Stack({ alignContent: Alignment.TopStart }) {
      Row()
        .width('100%')
        .height('100%')
        .borderRadius(this.s(HTP_ICON_SIZE / 2))
        .backgroundColor('#F9DBDE')
        .border({ width: this.s(5), color: Color.White })

      Row()
        .width(this.s(74))
        .height(this.s(10))
        .borderRadius(this.s(5))
        .backgroundColor('#F1585C')
        .rotate({ angle: -24 })
        .position({ x: this.s(21.5), y: this.s(50) })

      Row()
        .width(this.s(42))
        .height(this.s(9))
        .borderRadius(this.s(4.5))
        .backgroundColor('#FB7E86')
        .rotate({ angle: 30 })
        .position({ x: this.s(30), y: this.s(58) })

      Row()
        .width(this.s(50))
        .height(this.s(4.4))
        .borderRadius(this.s(2.2))
        .backgroundColor('#F7808A')
        .position({ x: this.s(33), y: this.s(90) })
    }
    .width(this.s(HTP_ICON_SIZE))
    .height(this.s(HTP_ICON_SIZE))
  }

  @Builder
  calendarIcon() {
    Stack({ alignContent: Alignment.TopStart }) {
      Row()
        .width('100%')
        .height('100%')
        .borderRadius(this.s(HTP_ICON_SIZE / 2))
        .backgroundColor('#FFEDC7')

      Stack({ alignContent: Alignment.TopStart }) {
        Column() {
          Row()
            .width('100%')
            .height(this.s(20))
            .backgroundColor('#FF6B4A')
            .borderRadius({ topLeft: this.s(8), topRight: this.s(8) })

          Blank()

          Row()
            .width('70%')
            .height(this.s(3))
            .borderRadius(this.s(1.5))
            .backgroundColor('#F3DCD2')
            .margin({ left: this.s(10), bottom: this.s(8) })
        }
        .width('100%')
        .height('100%')
      }
      .width(this.s(66))
      .height(this.s(56))
      .backgroundColor(Color.White)
      .borderRadius(this.s(8))
      .rotate({ angle: -5 })
      .position({ x: this.s(26), y: this.s(34) })

      Stack({ alignContent: Alignment.Center }) {
        Row()
          .width(this.s(5))
          .height(this.s(5))
          .borderRadius(this.s(2.5))
          .backgroundColor(Color.White)

        Row()
          .width(this.s(9))
          .height(this.s(2))
          .borderRadius(this.s(1))
          .backgroundColor('#6FD3A4')
          .position({ x: this.s(7), y: this.s(3) })
      }
      .width(this.s(16))
      .height(this.s(16))
      .borderRadius(this.s(8))
      .backgroundColor('#6FD3A4')
      .position({ x: this.s(36), y: this.s(72) })

      Row()
        .width(this.s(9))
        .height(this.s(9))
        .borderRadius(this.s(4.5))
        .border({ width: this.s(2.2), color: '#F0A0A0' })
        .position({ x: this.s(44), y: this.s(30) })

      Row()
        .width(this.s(9))
        .height(this.s(9))
        .borderRadius(this.s(4.5))
        .border({ width: this.s(2.2), color: '#F0A0A0' })
        .position({ x: this.s(66), y: this.s(28) })
    }
    .width(this.s(HTP_ICON_SIZE))
    .height(this.s(HTP_ICON_SIZE))
  }

  @Builder
  globeIcon() {
    Stack({ alignContent: Alignment.TopStart }) {
      Row()
        .width('100%')
        .height('100%')
        .borderRadius(this.s(HTP_ICON_SIZE / 2))
        .backgroundColor('#FFD6D7')

      Row()
        .width(this.s(50))
        .height(this.s(56))
        .borderRadius(this.s(7))
        .linearGradient({
          angle: 160,
          colors: [['#FF7B7B', 0], ['#EE4B4F', 1]]
        })
        .rotate({ angle: -4 })
        .position({ x: this.s(33), y: this.s(30) })

      Row()
        .width(this.s(30))
        .height(this.s(30))
        .borderRadius(this.s(15))
        .border({ width: this.s(2.2), color: Color.White })
        .position({ x: this.s(43), y: this.s(45) })

      Row()
        .width(this.s(26))
        .height(this.s(1.8))
        .backgroundColor(Color.White)
        .position({ x: this.s(45), y: this.s(54) })

      Row()
        .width(this.s(26))
        .height(this.s(1.8))
        .backgroundColor(Color.White)
        .position({ x: this.s(45), y: this.s(64) })

      Row()
        .width(this.s(1.8))
        .height(this.s(26))
        .backgroundColor(Color.White)
        .position({ x: this.s(56.5), y: this.s(47) })
    }
    .width(this.s(HTP_ICON_SIZE))
    .height(this.s(HTP_ICON_SIZE))
  }

  @Builder
  productIcons() {
    Stack({ alignContent: Alignment.TopStart }) {
      Stack({ alignContent: Alignment.TopStart }) {
        this.planeIcon()
      }
      .width(this.s(HTP_ICON_SIZE))
      .height(this.s(HTP_ICON_SIZE))
      .position({ x: this.s(HTP_ICON_LEFT_ONE), y: this.s(HTP_ICON_TOP) })

      Stack({ alignContent: Alignment.TopStart }) {
        this.calendarIcon()
      }
      .width(this.s(HTP_ICON_SIZE))
      .height(this.s(HTP_ICON_SIZE))
      .position({ x: this.s(HTP_ICON_LEFT_TWO), y: this.s(HTP_ICON_TOP) })

      Stack({ alignContent: Alignment.TopStart }) {
        this.globeIcon()
      }
      .width(this.s(HTP_ICON_SIZE))
      .height(this.s(HTP_ICON_SIZE))
      .position({ x: this.s(HTP_ICON_LEFT_THREE), y: this.s(HTP_ICON_TOP) })

      Row()
        .width(this.s(HTP_HIGHLIGHT_WIDTH))
        .height(this.s(HTP_HIGHLIGHT_HEIGHT))
        .borderRadius(this.s(HTP_HIGHLIGHT_RADIUS))
        .backgroundColor(HTP_STREAK_COLOR)
        .opacity(0.9)
        .position({ x: this.s(HTP_HIGHLIGHT_X), y: this.s(HTP_HIGHLIGHT_Y) })

      Stack({ alignContent: Alignment.TopStart }) {
        ForEach(HTP_PRODUCT_LABELS, (label: HtpProductLabel) => {
          Text(label.labelText)
            .fontSize(this.s(HTP_LABEL_FONT))
            .lineHeight(this.s(HTP_LABEL_LINE_HEIGHT))
            .fontColor(HTP_LABEL_COLOR)
            .textAlign(TextAlign.Center)
            .width(this.s(HTP_LABEL_COLUMN_WIDTH))
            .height(this.s(HTP_LABEL_TEXT_HEIGHT))
            .position({ x: this.s(label.labelX), y: 0 })
        }, (label: HtpProductLabel): string => label.labelText)
      }
      .width(this.s(HTP_LABEL_ROW_WIDTH))
      .height(this.s(HTP_LABEL_ROW_HEIGHT))
      .position({ x: this.s(HTP_LABEL_ROW_X), y: this.s(HTP_LABEL_TOP) })
      .clip(false)

      Row()
        .width(this.s(HTP_NOTCH_WIDTH))
        .height(this.s(HTP_NOTCH_HEIGHT))
        .backgroundColor(Color.White)
        .borderRadius({ topLeft: this.s(HTP_NOTCH_RADIUS), topRight: this.s(HTP_NOTCH_RADIUS) })
        .position({ x: this.s(HTP_NOTCH_X), y: this.s(HTP_NOTCH_Y) })
    }
    .width(this.pageWidth())
    .height(this.s(HTP_ICON_AREA_HEIGHT))
    .clip(false)
  }

  @Builder
  sheetPlaceholders() {
    Stack({ alignContent: Alignment.TopStart }) {
      Text('选择出发地')
        .fontSize(this.s(HTP_PLACEHOLDER_FONT))
        .lineHeight(this.s(HTP_PLACEHOLDER_LINE_HEIGHT))
        .fontColor(HTP_PLACEHOLDER_COLOR)
        .width(this.s(HTP_PLACEHOLDER_BOX_WIDTH))
        .height(this.s(HTP_PLACEHOLDER_HEIGHT_ONE))
        .position({ x: this.s(HTP_PLACEHOLDER_X_ONE), y: this.s(HTP_PLACEHOLDER_TOP) })

      Text('选择日期')
        .fontSize(this.s(HTP_PLACEHOLDER_FONT))
        .lineHeight(this.s(HTP_PLACEHOLDER_LINE_HEIGHT))
        .fontColor(HTP_PLACEHOLDER_COLOR)
        .width(this.s(HTP_PLACEHOLDER_BOX_WIDTH))
        .height(this.s(HTP_PLACEHOLDER_HEIGHT_TWO))
        .position({ x: this.s(HTP_PLACEHOLDER_X_TWO), y: this.s(HTP_PLACEHOLDER_TOP) })

      Text('价格日历')
        .fontSize(this.s(HTP_PRICE_FONT))
        .lineHeight(this.s(HTP_PRICE_LINE_HEIGHT))
        .fontColor(HTP_PLACEHOLDER_COLOR)
        .width(this.s(HTP_PRICE_WIDTH))
        .height(this.s(HTP_PRICE_LINE_HEIGHT))
        .position({ x: this.s(HTP_PRICE_X), y: this.s(HTP_PRICE_Y) })
    }
    .width(this.pageWidth())
    .height(this.s(HTP_SHEET_HEIGHT))
    .clip(false)
  }

  @Builder
  sheetButtons() {
    Stack({ alignContent: Alignment.TopStart }) {
      Stack({ alignContent: Alignment.Center }) {
        Text('去退订')
          .fontSize(this.s(HTP_BUTTON_FONT))
          .fontColor(HTP_BUTTON_TEXT_COLOR)
      }
      .width(this.s(HTP_WHITE_BUTTON_WIDTH))
      .height(this.s(HTP_WHITE_BUTTON_HEIGHT))
      .backgroundColor(Color.White)
      .borderRadius(this.s(HTP_WHITE_BUTTON_HEIGHT / 2))
      .shadow({ radius: this.s(10), color: '#14000000', offsetX: 0, offsetY: this.s(2) })
      .position({ x: this.s(HTP_WHITE_BUTTON_X), y: this.s(HTP_WHITE_BUTTON_Y) })

      Stack({ alignContent: Alignment.Center }) {
        Text('去退订')
          .fontSize(this.s(HTP_BUTTON_FONT))
          .fontColor(Color.White)
      }
      .width(this.s(HTP_RED_BUTTON_WIDTH))
      .height(this.s(HTP_RED_BUTTON_HEIGHT))
      .backgroundColor(HTP_RED)
      .borderRadius(this.s(HTP_RED_BUTTON_HEIGHT / 2))
      .position({ x: this.s(HTP_RED_BUTTON_X), y: this.s(HTP_RED_BUTTON_Y) })

      Row()
        .width(this.s(HTP_HOME_BAR_WIDTH))
        .height(this.s(HTP_HOME_BAR_HEIGHT))
        .borderRadius(this.s(HTP_HOME_BAR_HEIGHT / 2))
        .backgroundColor(HTP_HOME_BAR_COLOR)
        .position({
          x: this.s(HTP_HOME_BAR_X),
          y: this.s(HTP_HOME_BAR_Y) - (this.bottomInsetVp - HTP_BOTTOM_INSET_FALLBACK)
        })
    }
    .width(this.pageWidth())
    .height(this.s(HTP_SHEET_HEIGHT))
    .clip(false)
  }

  @Builder
  bottomSheet() {
    Stack({ alignContent: Alignment.Top }) {
      Stack({ alignContent: Alignment.TopStart }) {
        this.sheetPlaceholders()
        this.sheetButtons()
      }
      .width(this.pageWidth())
      .height(this.s(HTP_SHEET_HEIGHT))
      .clip(false)
    }
    .width('100%')
    .height(this.s(HTP_SHEET_HEIGHT))
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: this.s(HTP_SHEET_RADIUS), topRight: this.s(HTP_SHEET_RADIUS) })
    .clip(false)
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          // 白色标题栏：通栏白底，内容列居中
          Stack({ alignContent: Alignment.Top }) {
            Stack({ alignContent: Alignment.TopStart }) {
              this.titleBar()
            }
            .width(this.pageWidth())
            .height(this.statusBarHeightVp + this.s(HTP_TITLE_ROW_HEIGHT))
          }
          .width('100%')
          .height(this.statusBarHeightVp + this.s(HTP_TITLE_ROW_HEIGHT))
          .backgroundColor(Color.White)

          // 粉色头图：通栏渐变底，棋盘格 / 高亮 / 大标题 / 胶囊都放在内容列里
          Stack({ alignContent: Alignment.Top }) {
            this.heroBand()
          }
          .width('100%')
          .height(this.s(HTP_HERO_HEIGHT))
          .linearGradient({
            angle: 150,
            colors: [['#FCE3E1', 0], ['#FBE9ED', 0.55], ['#F4F0F5', 1]]
          })

          // 白色页面：图标 + 标签 + 弹层顶部凸起
          Stack({ alignContent: Alignment.Top }) {
            this.productIcons()
          }
          .width('100%')
          .height(this.s(HTP_ICON_AREA_HEIGHT))

          // 底部弹层：白色圆角面板，通栏铺满
          this.bottomSheet()
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .backgroundColor(HTP_PAGE_BG)
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
