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
 * 反例：留白过多 / 配置对比表右侧整块空白
 *
 * 复刻对象：汽车之家式「配置对比」页，双屏横屏。顶部左上返回箭头「‹」、窗口居中标题
 *   「配置对比」，标题下一条蓝色短下划线。标题下方是一张配置对比表：最左固定列
 *   （「共2款」+ 关闭态开关 + 「只看差异」）、两列车款头（「帕萨特 2026款 出众款
 *   280TSI 商务版」「奥迪A3 2026款 Sportback 35 TFSI 飞驰悦享型」，每列顶部一行
 *   「✧ 钉在左侧」灰底块 + 右侧浅灰 ×，下面车名、价格「16.45万」「16.59万」+ 右侧
 *   蓝字「换车」、红色「查成交价」按钮）、第三列灰字「＋ 选择车款」。再往下浅灰分组条
 *   「基本信息 ▾」；然后一行行参数（上海参考价、厂商、级别、能源类型、环保标准、
 *   上市时间、发动机、最大功率[kW]、最大扭矩[N·m]、变速箱），取值不同的行在车款列
 *   铺浅蓝底，行间有细横线。窗口右上角一枚白色圆形「横屏」浮标。表格只占窗口左侧一条。
 *
 * 设计基准：截图 3184×2232px（读的是等比缩小版 2445×1714，比例一致），密度 2.75，
 *   vp = px / 2.75，换算得到参考窗口 1157.8×811.6vp。下列 px 均为原图坐标：
 *   标题区：高 235px（85.5vp）；返回箭头 27×48px（9.8×17.5vp）、左缘距窗口 54px（19.6vp）、
 *           箭头中心 y 173px（62.9vp）；标题 ink 高 44px（字号 18vp）、水平居中于窗口；
 *           蓝色下划线 34×8px（12.4×2.9vp）、距标题 ink 下沿 11px（4vp）。
 *   表格：总宽 1304px（474.2vp）；最左列 252px（91.6vp）、两列车款列 348/350px
 *         （两者按剩余宽度均分，各 126.9vp）、「选择车款」列 350px（127.3vp）；
 *         列间竖线 1px（0.4vp）。
 *   表头：高 377px（137.1vp）；「钉在左侧」灰底块 200×59px（72.7×21.5vp，底 #F7F8FA）、
 *         距表头顶 4px（1.5vp）、块内左内边距 12px（4.4vp）；车名 3 行、行距 40px
 *         （14.5vp）、字号 12.2vp 粗体、左内边距 25px（9.1vp）；价格字 12.5vp、右端
 *         「换车」12.2vp 蓝字；「查成交价」按钮 308×58px（112×21.1vp）、圆角 5px（2vp）、
 *         底色 #FD4A43；左列「共2款」「只看差异」12.2vp、开关 136×68px（49.5×24.7vp）。
 *   分组条：高 96px（34.9vp）、字 14.5vp、左内边距 35px（12.7vp）、下端小三角 6×3.6vp。
 *   参数行：行高 160px（58.2vp）、行间横线 1px（0.4vp）；左列底色 #FCFCFC、标签 12.2vp、
 *         左内边距 18px（6.5vp）；取值 12.2vp、左内边距 25px（9.1vp）；
 *         差异行车款列底色 #F4F8FF，非差异行纯白。
 *   浮标：直径 156px（56.7vp），圆心距窗口右缘 41.4vp、距底边 151.4vp，即右边距 13vp、
 *         底边距 123vp；圈内 20×17.5vp 双线框图标 + 10.5vp「横屏」。
 *
 * 三态实测（表格宽度写死 474.2vp，右侧不做任何填充）：
 *   单屏态      459.6×672vp   —— 474.2 / 459.6 = 103%，比窗口还宽 14.6vp，右侧没有留白，
 *                                末列「选择车款」被窗口右缘裁掉 14.6vp
 *   双屏态竖屏  664.7×939.6vp —— 474.2 / 664.7 = 71%，右侧空白 190.5vp，约占宽度 29%
 *   双屏态横屏  939.6×664.7vp —— 474.2 / 939.6 = 50%，右侧空白 465.4vp，约占宽度 50%
 *   纵向：标题 85.5 + 表头 137.1 + 分组条 34.9 + 10 行 × 58.2 = 839.5vp，比 664.7vp 的窗口
 *        还高，表格下沿不会露白，只能滚动看后面的参数行。
 *
 * 问题表现：
 *   整张对比表贴在窗口最左边，右半边从标题行一直到底边是连成一片的纯白；
 *   两辆车的信息都挤在左边 50% 的宽度里，行高 58.2vp 里只落一行 12.2vp 的小字；
 *   「横屏」浮标单独挂在右侧空白中，与表格右缘隔着 400vp 以上的白。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 配色：白底、近黑正文、浅灰分隔线、品牌红按钮、蓝色链接 */
const WSCS_PAGE_BG: string = '#FFFFFF';
const WSCS_TEXT_MAIN: string = '#1A1A1A';
const WSCS_TEXT_VALUE: string = '#2E2E2E';
const WSCS_TEXT_GRAY: string = '#8A8A8A';
const WSCS_CELL_LINE: string = '#E9E9E9';
const WSCS_ROW_LINE: string = '#EFEFEF';
const WSCS_LEFT_COL_BG: string = '#FCFCFC';
const WSCS_DIFF_CELL_BG: string = '#F4F8FF';
const WSCS_GROUP_BG: string = '#FAFAFA';
const WSCS_CHIP_BG: string = '#F7F8FA';
const WSCS_PRICE_RED: string = '#E93B37';
const WSCS_DOWN_GREEN: string = '#00A05E';
const WSCS_LINK_BLUE: string = '#2F6FE8';
const WSCS_UNDERLINE_BLUE: string = '#3278F8';
const WSCS_BUTTON_RED: string = '#FD4A43';
const WSCS_SWITCH_TRACK: string = '#EDEDED';
const WSCS_PLUS_COLOR: string = '#9E9E9E';
const WSCS_CLOSE_COLOR: string = '#C0C0C0';
const WSCS_FAB_ICON: string = '#333333';

/** 标题区：高 85.5vp；标题字 18vp；蓝色下划线 12.4×2.9vp、距标题 4vp */
const WSCS_TITLE_BAR_HEIGHT: number = 85.5;
const WSCS_TITLE_FONT: number = 18;
const WSCS_UNDERLINE_W: number = 12.4;
const WSCS_UNDERLINE_H: number = 2.9;
const WSCS_UNDERLINE_GAP: number = 4;
const WSCS_TITLE_PAD_BOTTOM: number = 3;

/** 返回箭头：外接 9.8×17.5vp、笔画 2.2vp、左缘距窗口 19.6vp、底边距标题栏底 13.9vp */
const WSCS_BACK_SPAN_W: number = 9.8;
const WSCS_BACK_SPAN_H: number = 17.5;
const WSCS_BACK_STROKE: number = 2.2;
const WSCS_BACK_PAD_LEFT: number = 19.6;
const WSCS_BACK_PAD_BOTTOM: number = 13.9;

/** 表格：总宽 474.2vp、最左列 91.6vp、「选择车款」列 127.3vp、列间竖线 0.4vp */
const WSCS_TABLE_WIDTH: number = 474.2;
const WSCS_LEFT_COL_WIDTH: number = 91.6;
const WSCS_ADD_COL_WIDTH: number = 127.3;
const WSCS_CELL_DIVIDER: number = 0.4;
const WSCS_LINE_HEIGHT: number = 0.4;

/** 表头 137.1vp、分组条 34.9vp、参数行高 58.2vp */
const WSCS_HEADER_HEIGHT: number = 137.1;
const WSCS_GROUP_BAR_HEIGHT: number = 34.9;
const WSCS_ROW_HEIGHT: number = 58.2;

/** 表头「钉在左侧」灰底块：72.7×21.5vp、距表头顶 1.5vp、块内左内边距 4.4vp */
const WSCS_CHIP_W: number = 72.7;
const WSCS_CHIP_H: number = 21.5;
const WSCS_CHIP_TOP: number = 1.5;
const WSCS_CHIP_PAD_LEFT: number = 4.4;
const WSCS_CHIP_GAP: number = 2.4;
const WSCS_PIN_SIZE: number = 5.2;
const WSCS_PIN_SPAN: number = 8;
const WSCS_PIN_STROKE: number = 1.1;
const WSCS_PIN_FONT: number = 12;

/** 车款头上的浅灰 ×：外接 10.9vp、笔画 1.1vp */
const WSCS_CLOSE_SPAN: number = 10.9;
const WSCS_CLOSE_STROKE: number = 1.1;

/** 车款头内容：左右内边距 9.1/5.5vp；车名 3 行、行距 14.5vp、字 12.2vp */
const WSCS_CELL_PAD_LEFT: number = 9.1;
const WSCS_CELL_PAD_RIGHT: number = 5.5;
const WSCS_NAME_TOP: number = 7;
const WSCS_NAME_LINE: number = 14.5;
const WSCS_CAR_NAME_FONT: number = 12.2;
const WSCS_NAME_ARROW_W: number = 3.3;
const WSCS_NAME_ARROW_H: number = 5.2;
const WSCS_PRICE_TOP: number = 10.5;
const WSCS_PRICE_FONT: number = 12.5;
const WSCS_BUTTON_TOP: number = 9.1;
const WSCS_BUTTON_HEIGHT: number = 21.1;
const WSCS_BUTTON_RADIUS: number = 2;
const WSCS_BUTTON_FONT: number = 13;

/** 最左列表头：左内边距 12.7vp、首行距顶 18vp、开关 49.5×24.7vp、圆点 20.5vp */
const WSCS_LEFT_PAD: number = 12.7;
const WSCS_LEFT_HEAD_TOP: number = 18;
const WSCS_LEFT_FONT: number = 12.2;
const WSCS_SWITCH_W: number = 49.5;
const WSCS_SWITCH_H: number = 24.7;
const WSCS_SWITCH_TOP_GAP: number = 9.7;
const WSCS_SWITCH_LABEL_GAP: number = 4.1;
const WSCS_SWITCH_KNOB: number = 20.5;
const WSCS_SWITCH_KNOB_GAP: number = 2;

/** 分组条：字 14.5vp、左内边距 12.7vp、下端三角 6×3.6vp */
const WSCS_GROUP_FONT: number = 14.5;
const WSCS_GROUP_PAD_LEFT: number = 12.7;
const WSCS_GROUP_ARROW_W: number = 6;
const WSCS_GROUP_ARROW_H: number = 3.6;
const WSCS_GROUP_ARROW_GAP: number = 3.5;

/** 「＋ 选择车款」：加号 24vp、笔画 1.5vp、字 12.5vp、加号到字 4vp */
const WSCS_PLUS_SIZE: number = 24;
const WSCS_PLUS_STROKE: number = 1.5;
const WSCS_ADD_FONT: number = 12.5;
const WSCS_ADD_GAP: number = 4;

/** 参数行：标签 12.2vp、左内边距 6.5vp；取值 12.2vp、左内边距 9.1vp；降价小字 11.8vp */
const WSCS_BODY_FONT: number = 12.2;
const WSCS_SUB_FONT: number = 11.8;
const WSCS_LABEL_PAD_LEFT: number = 6.5;
const WSCS_VALUE_PAD_LEFT: number = 9.1;

/** 右上角「横屏」浮标：直径 56.7vp、右边距 13vp、底边距 123vp */
const WSCS_FAB_SIZE: number = 56.7;
const WSCS_FAB_RIGHT: number = 13;
const WSCS_FAB_BOTTOM: number = 123;
const WSCS_FAB_ICON_W: number = 11;
const WSCS_FAB_ICON_H: number = 17.5;
const WSCS_FAB_ICON_SMALL_W: number = 7.5;
const WSCS_FAB_ICON_SMALL_H: number = 11;
const WSCS_FAB_ICON_STROKE: number = 1.2;
const WSCS_FAB_FONT: number = 10.5;

/** 车款头：车名三行 + 价格 + 「换车」按钮 */
interface WSCS_CarSeed {
  seedKey: string;
  /** 车名按截图断成三行；第三行为空串时箭头单独占行首 */
  seedLines: string[];
  seedPrice: string;
}

/** 参数行里的一格取值 */
interface WSCS_SpecCell {
  cellText: string;
  cellSubText: string;
  cellTextColor: string;
  cellBgColor: string;
}

/** 参数行：行名 + 两车取值 */
interface WSCS_SpecRow {
  rowKey: string;
  rowLabel: string;
  rowDiff: boolean;
  leftCell: WSCS_SpecCell;
  rightCell: WSCS_SpecCell;
}

const WSCS_CAR_SEEDS: WSCS_CarSeed[] = [
  {
    seedKey: 'passat',
    seedLines: ['帕萨特 2026款 出', '众款 280TSI 商务版', ''],
    seedPrice: '16.45万'
  },
  {
    seedKey: 'a3',
    seedLines: ['奥迪A3 2026款', 'Sportback 35 TFSI', '飞驰悦享型'],
    seedPrice: '16.59万'
  }
];

/** 取值不同的行在车款列铺浅蓝底 */
function WSCS_makeCell(cellText: string, cellSubText: string, cellTextColor: string, rowDiff: boolean): WSCS_SpecCell {
  let cellBgColor: string = '#FFFFFF';
  if (rowDiff) {
    cellBgColor = WSCS_DIFF_CELL_BG;
  }
  return {
    cellText: cellText,
    cellSubText: cellSubText,
    cellTextColor: cellTextColor,
    cellBgColor: cellBgColor
  };
}

const WSCS_SPEC_ROWS: WSCS_SpecRow[] = [
  {
    rowKey: 'ref-price',
    rowLabel: '上海参考价',
    rowDiff: true,
    leftCell: WSCS_makeCell('13.23万起', '↓3.22', WSCS_PRICE_RED, true),
    rightCell: WSCS_makeCell('11.59万起', '↓5.0', WSCS_PRICE_RED, true)
  },
  {
    rowKey: 'maker',
    rowLabel: '厂商',
    rowDiff: true,
    leftCell: WSCS_makeCell('上汽大众', '', WSCS_TEXT_VALUE, true),
    rightCell: WSCS_makeCell('一汽奥迪', '', WSCS_TEXT_VALUE, true)
  },
  {
    rowKey: 'level',
    rowLabel: '级别',
    rowDiff: true,
    leftCell: WSCS_makeCell('中型车', '', WSCS_TEXT_VALUE, true),
    rightCell: WSCS_makeCell('紧凑型车', '', WSCS_TEXT_VALUE, true)
  },
  {
    rowKey: 'energy',
    rowLabel: '能源类型',
    rowDiff: false,
    leftCell: WSCS_makeCell('汽油', '', WSCS_TEXT_VALUE, false),
    rightCell: WSCS_makeCell('汽油', '', WSCS_TEXT_VALUE, false)
  },
  {
    rowKey: 'emission',
    rowLabel: '环保标准',
    rowDiff: false,
    leftCell: WSCS_makeCell('国六', '', WSCS_TEXT_VALUE, false),
    rightCell: WSCS_makeCell('国六', '', WSCS_TEXT_VALUE, false)
  },
  {
    rowKey: 'launch',
    rowLabel: '上市时间',
    rowDiff: true,
    leftCell: WSCS_makeCell('2025-09-29', '', WSCS_TEXT_VALUE, true),
    rightCell: WSCS_makeCell('2025-10-11', '', WSCS_TEXT_VALUE, true)
  },
  {
    rowKey: 'engine',
    rowLabel: '发动机',
    rowDiff: true,
    leftCell: WSCS_makeCell('1.4T 150马力 L4', '', WSCS_TEXT_VALUE, true),
    rightCell: WSCS_makeCell('1.5T 160马力 L4', '', WSCS_TEXT_VALUE, true)
  },
  {
    rowKey: 'power',
    rowLabel: '最大功率[kW]',
    rowDiff: true,
    leftCell: WSCS_makeCell('110', '', WSCS_TEXT_VALUE, true),
    rightCell: WSCS_makeCell('118', '', WSCS_TEXT_VALUE, true)
  },
  {
    rowKey: 'torque',
    rowLabel: '最大扭矩[N·m]',
    rowDiff: false,
    leftCell: WSCS_makeCell('250', '', WSCS_TEXT_VALUE, false),
    rightCell: WSCS_makeCell('250', '', WSCS_TEXT_VALUE, false)
  },
  {
    rowKey: 'gearbox',
    rowLabel: '变速箱',
    rowDiff: false,
    leftCell: WSCS_makeCell('7挡 干式双离合', '', WSCS_TEXT_VALUE, false),
    rightCell: WSCS_makeCell('7挡 干式双离合', '', WSCS_TEXT_VALUE, false)
  }
];

@Component
export struct CarSpecComparePage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽度（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = 939.6;

  /** 窗口高度（vp），用于给「横屏」浮标定位 */
  @State winHeightVp: number = 664.7;

  /** 「只看差异」开关：开启后只留取值不同的参数行 */
  @State diffOnly: boolean = false;

  private tableScroller: Scroller = new Scroller();
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
      this.windowToken = WindowModeController.acquire(win, '#000000');
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  // ------------------------------------------------------------------
  // 数据
  // ------------------------------------------------------------------

  private visibleRows(): WSCS_SpecRow[] {
    if (!this.diffOnly) {
      return WSCS_SPEC_ROWS;
    }
    const rows: WSCS_SpecRow[] = [];
    for (const specRow of WSCS_SPEC_ROWS) {
      if (specRow.rowDiff) {
        rows.push(specRow);
      }
    }
    return rows;
  }

  private switchKnobOffset(): number {
    if (this.diffOnly) {
      return WSCS_SWITCH_W - WSCS_SWITCH_KNOB - WSCS_SWITCH_KNOB_GAP;
    }
    return WSCS_SWITCH_KNOB_GAP;
  }

  private switchTrackColor(): string {
    if (this.diffOnly) {
      return WSCS_BUTTON_RED;
    }
    return WSCS_SWITCH_TRACK;
  }

  private fabLeft(): number {
    if (this.winWidthVp <= WSCS_FAB_SIZE) {
      return 0;
    }
    return this.winWidthVp - WSCS_FAB_RIGHT - WSCS_FAB_SIZE;
  }

  private fabTop(): number {
    if (this.winHeightVp <= WSCS_FAB_SIZE) {
      return 0;
    }
    return this.winHeightVp - WSCS_FAB_BOTTOM - WSCS_FAB_SIZE;
  }

  // ------------------------------------------------------------------
  // 顶部：返回箭头 + 居中标题 + 蓝色下划线
  // ------------------------------------------------------------------

  @Builder
  backChevron() {
    Shape() {
      Path()
        .commands('M8.7 1.1 L1.1 8.75 L8.7 16.4')
        .fill(Color.Transparent)
        .stroke(WSCS_TEXT_MAIN)
        .strokeWidth(WSCS_BACK_STROKE)
    }
    .width(WSCS_BACK_SPAN_W)
    .height(WSCS_BACK_SPAN_H)
    .onClick(() => {
      this.pageStack.pop();
    })
  }

  @Builder
  titleBar() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Column() {
        Text('配置对比')
          .fontSize(WSCS_TITLE_FONT)
          .fontWeight(FontWeight.Medium)
          .fontColor(WSCS_TEXT_MAIN)
          .maxLines(1)

        Row()
          .width(WSCS_UNDERLINE_W)
          .height(WSCS_UNDERLINE_H)
          .backgroundColor(WSCS_UNDERLINE_BLUE)
          .borderRadius(WSCS_UNDERLINE_H / 2)
          .margin({ top: WSCS_UNDERLINE_GAP })
      }
      .width('100%')
      .padding({ bottom: WSCS_TITLE_PAD_BOTTOM })
      .alignItems(HorizontalAlign.Center)

      Row() {
        this.backChevron()
      }
      .padding({ left: WSCS_BACK_PAD_LEFT, bottom: WSCS_BACK_PAD_BOTTOM })
    }
    .width('100%')
    .height(WSCS_TITLE_BAR_HEIGHT)
    .backgroundColor(WSCS_PAGE_BG)
  }

  // ------------------------------------------------------------------
  // 表格：竖线、横线
  // ------------------------------------------------------------------

  @Builder
  cellDivider() {
    Row()
      .width(WSCS_CELL_DIVIDER)
      .height('100%')
      .backgroundColor(WSCS_CELL_LINE)
  }

  @Builder
  cellLine() {
    Row()
      .width('100%')
      .height(WSCS_LINE_HEIGHT)
      .backgroundColor(WSCS_ROW_LINE)
  }

  @Builder
  headerTopLine() {
    Row()
      .width('100%')
      .height(WSCS_LINE_HEIGHT)
      .backgroundColor(WSCS_CELL_LINE)
  }

  // ------------------------------------------------------------------
  // 表头：最左列 / 两个车款列 / 选择车款列
  // ------------------------------------------------------------------

  @Builder
  pinIcon() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(WSCS_PIN_SIZE)
        .height(WSCS_PIN_SIZE)
        .border({ width: WSCS_PIN_STROKE, color: WSCS_TEXT_MAIN })
        .rotate({ angle: 45 })
    }
    .width(WSCS_PIN_SPAN)
    .height(WSCS_PIN_SPAN)
  }

  @Builder
  closeCross() {
    Shape() {
      Path()
        .commands('M0.55 0.55 L10.35 10.35 M10.35 0.55 L0.55 10.35')
        .fill(Color.Transparent)
        .stroke(WSCS_CLOSE_COLOR)
        .strokeWidth(WSCS_CLOSE_STROKE)
    }
    .width(WSCS_CLOSE_SPAN)
    .height(WSCS_CLOSE_SPAN)
  }

  @Builder
  nameArrow() {
    Shape() {
      Path()
        .commands('M0 0 L3.3 2.6 L0 5.2 Z')
        .fill(WSCS_TEXT_MAIN)
    }
    .width(WSCS_NAME_ARROW_W)
    .height(WSCS_NAME_ARROW_H)
    .margin({ left: 2 })
  }

  @Builder
  leftHeaderCell() {
    Column() {
      Text('共2款')
        .fontSize(WSCS_LEFT_FONT)
        .fontColor(WSCS_TEXT_MAIN)
        .maxLines(1)

      Stack({ alignContent: Alignment.Start }) {
        Row()
          .width(WSCS_SWITCH_W)
          .height(WSCS_SWITCH_H)
          .backgroundColor(this.switchTrackColor())
          .borderRadius(WSCS_SWITCH_H / 2)

        Row()
          .width(WSCS_SWITCH_KNOB)
          .height(WSCS_SWITCH_KNOB)
          .backgroundColor(Color.White)
          .borderRadius(WSCS_SWITCH_KNOB / 2)
          .shadow({ radius: 3, color: '#1A000000' })
          .offset({ x: this.switchKnobOffset() })
      }
      .width(WSCS_SWITCH_W)
      .height(WSCS_SWITCH_H)
      .margin({ top: WSCS_SWITCH_TOP_GAP })
      .onClick(() => {
        this.diffOnly = !this.diffOnly;
      })

      Text('只看差异')
        .fontSize(WSCS_LEFT_FONT)
        .fontColor(WSCS_TEXT_MAIN)
        .maxLines(1)
        .margin({ top: WSCS_SWITCH_LABEL_GAP })
    }
    .width(WSCS_LEFT_COL_WIDTH)
    .height(WSCS_HEADER_HEIGHT)
    .padding({ left: WSCS_LEFT_PAD, top: WSCS_LEFT_HEAD_TOP })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  carHeaderCell(seed: WSCS_CarSeed) {
    Column() {
      Row() {
        Row() {
          this.pinIcon()

          Text('钉在左侧')
            .fontSize(WSCS_PIN_FONT)
            .fontColor(WSCS_TEXT_MAIN)
            .maxLines(1)
            .margin({ left: WSCS_CHIP_GAP })
        }
        .width(WSCS_CHIP_W)
        .height(WSCS_CHIP_H)
        .padding({ left: WSCS_CHIP_PAD_LEFT })
        .backgroundColor(WSCS_CHIP_BG)
        .alignItems(VerticalAlign.Center)

        Blank()

        this.closeCross()
      }
      .width('100%')
      .height(WSCS_CHIP_H)
      .margin({ top: WSCS_CHIP_TOP })
      .padding({ right: WSCS_CELL_PAD_RIGHT })
      .alignItems(VerticalAlign.Center)

      Column() {
        Column() {
          Text(seed.seedLines[0])
            .fontSize(WSCS_CAR_NAME_FONT)
            .fontWeight(FontWeight.Bold)
            .fontColor(WSCS_TEXT_MAIN)
            .height(WSCS_NAME_LINE)
            .maxLines(1)

          Text(seed.seedLines[1])
            .fontSize(WSCS_CAR_NAME_FONT)
            .fontWeight(FontWeight.Bold)
            .fontColor(WSCS_TEXT_MAIN)
            .height(WSCS_NAME_LINE)
            .maxLines(1)

          Row() {
            Text(seed.seedLines[2])
              .fontSize(WSCS_CAR_NAME_FONT)
              .fontWeight(FontWeight.Bold)
              .fontColor(WSCS_TEXT_MAIN)
              .height(WSCS_NAME_LINE)
              .maxLines(1)

            this.nameArrow()
          }
          .height(WSCS_NAME_LINE)
          .alignItems(VerticalAlign.Center)
        }
        .alignItems(HorizontalAlign.Start)

        Row() {
          Text(seed.seedPrice)
            .fontSize(WSCS_PRICE_FONT)
            .fontWeight(FontWeight.Medium)
            .fontColor(WSCS_PRICE_RED)
            .maxLines(1)

          Blank()

          Text('换车')
            .fontSize(WSCS_BODY_FONT)
            .fontColor(WSCS_LINK_BLUE)
            .maxLines(1)
        }
        .width('100%')
        .height(WSCS_NAME_LINE)
        .margin({ top: WSCS_PRICE_TOP })
        .alignItems(VerticalAlign.Center)

        Row() {
          Text('查成交价')
            .fontSize(WSCS_BUTTON_FONT)
            .fontColor(Color.White)
            .maxLines(1)
        }
        .width('100%')
        .height(WSCS_BUTTON_HEIGHT)
        .margin({ top: WSCS_BUTTON_TOP })
        .justifyContent(FlexAlign.Center)
        .backgroundColor(WSCS_BUTTON_RED)
        .borderRadius(WSCS_BUTTON_RADIUS)
      }
      .width('100%')
      .margin({ top: WSCS_NAME_TOP })
      .padding({ left: WSCS_CELL_PAD_LEFT, right: WSCS_CELL_PAD_RIGHT })
      .alignItems(HorizontalAlign.Start)
    }
    .layoutWeight(1)
    .height(WSCS_HEADER_HEIGHT)
    .backgroundColor(WSCS_PAGE_BG)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  addCarCell() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        Row()
          .width(WSCS_PLUS_SIZE)
          .height(WSCS_PLUS_STROKE)
          .backgroundColor(WSCS_PLUS_COLOR)

        Row()
          .width(WSCS_PLUS_STROKE)
          .height(WSCS_PLUS_SIZE)
          .backgroundColor(WSCS_PLUS_COLOR)
      }
      .width(WSCS_PLUS_SIZE)
      .height(WSCS_PLUS_SIZE)

      Text('选择车款')
        .fontSize(WSCS_ADD_FONT)
        .fontColor(WSCS_TEXT_GRAY)
        .maxLines(1)
        .margin({ top: WSCS_ADD_GAP })
    }
    .width(WSCS_ADD_COL_WIDTH)
    .height(WSCS_HEADER_HEIGHT)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  headerRow() {
    Row() {
      this.leftHeaderCell()

      this.cellDivider()

      this.carHeaderCell(WSCS_CAR_SEEDS[0])

      this.cellDivider()

      this.carHeaderCell(WSCS_CAR_SEEDS[1])

      this.cellDivider()

      this.addCarCell()

      this.cellDivider()
    }
    .width('100%')
    .height(WSCS_HEADER_HEIGHT)
    .backgroundColor(WSCS_PAGE_BG)
    .alignItems(VerticalAlign.Top)
  }

  // ------------------------------------------------------------------
  // 分组条 / 参数行
  // ------------------------------------------------------------------

  @Builder
  groupBar() {
    Row() {
      Text('基本信息')
        .fontSize(WSCS_GROUP_FONT)
        .fontColor(WSCS_TEXT_MAIN)
        .maxLines(1)

      Shape() {
        Path()
          .commands('M0 0 L6 0 L3 3.6 Z')
          .fill(WSCS_TEXT_MAIN)
      }
      .width(WSCS_GROUP_ARROW_W)
      .height(WSCS_GROUP_ARROW_H)
      .margin({ left: WSCS_GROUP_ARROW_GAP })
    }
    .width('100%')
    .height(WSCS_GROUP_BAR_HEIGHT)
    .padding({ left: WSCS_GROUP_PAD_LEFT })
    .backgroundColor(WSCS_GROUP_BG)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  valueCell(cell: WSCS_SpecCell) {
    Column() {
      Text(cell.cellText)
        .fontSize(WSCS_BODY_FONT)
        .fontColor(cell.cellTextColor)
        .maxLines(1)

      if (cell.cellSubText.length > 0) {
        Text(cell.cellSubText)
          .fontSize(WSCS_SUB_FONT)
          .fontColor(WSCS_DOWN_GREEN)
          .maxLines(1)
          .margin({ top: 2 })
      }
    }
    .layoutWeight(1)
    .height('100%')
    .padding({ left: WSCS_VALUE_PAD_LEFT, right: 4 })
    .backgroundColor(cell.cellBgColor)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  specRowBlock(rowItem: WSCS_SpecRow) {
    Column() {
      Row() {
        Row() {
          Text(rowItem.rowLabel)
            .fontSize(WSCS_BODY_FONT)
            .fontColor(WSCS_TEXT_MAIN)
            .maxLines(2)
        }
        .width(WSCS_LEFT_COL_WIDTH)
        .height('100%')
        .padding({ left: WSCS_LABEL_PAD_LEFT, right: 4 })
        .backgroundColor(WSCS_LEFT_COL_BG)
        .alignItems(VerticalAlign.Center)

        this.cellDivider()

        this.valueCell(rowItem.leftCell)

        this.cellDivider()

        this.valueCell(rowItem.rightCell)

        this.cellDivider()

        Row()
          .width(WSCS_ADD_COL_WIDTH)
          .height('100%')
          .backgroundColor(WSCS_PAGE_BG)
      }
      .width('100%')
      .height(WSCS_ROW_HEIGHT)
      .alignItems(VerticalAlign.Center)

      this.cellLine()
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  // ------------------------------------------------------------------
  // 右上角「横屏」浮标
  // ------------------------------------------------------------------

  @Builder
  landscapeFab() {
    Column() {
      Row({ space: 1.6 }) {
        Row()
          .width(WSCS_FAB_ICON_W)
          .height(WSCS_FAB_ICON_H)
          .border({ width: WSCS_FAB_ICON_STROKE, color: WSCS_FAB_ICON })
          .borderRadius(2.4)

        Row()
          .width(WSCS_FAB_ICON_SMALL_W)
          .height(WSCS_FAB_ICON_SMALL_H)
          .border({ width: WSCS_FAB_ICON_STROKE, color: WSCS_FAB_ICON })
          .borderRadius(2.4)
      }
      .height(WSCS_FAB_ICON_H)
      .alignItems(VerticalAlign.Center)

      Text('横屏')
        .fontSize(WSCS_FAB_FONT)
        .fontColor(WSCS_FAB_ICON)
        .maxLines(1)
        .margin({ top: 2 })
    }
    .width(WSCS_FAB_SIZE)
    .height(WSCS_FAB_SIZE)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(Color.White)
    .borderRadius(WSCS_FAB_SIZE / 2)
    .shadow({ radius: 12, color: '#1A000000' })
    .position({ x: this.fabLeft(), y: this.fabTop() })
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        Column() {
          this.titleBar()

          Scroll(this.tableScroller) {
            Column() {
              this.headerTopLine()

              this.headerRow()

              this.cellLine()

              this.groupBar()

              this.cellLine()

              ForEach(this.visibleRows(), (rowItem: WSCS_SpecRow) => {
                this.specRowBlock(rowItem)
              }, (rowItem: WSCS_SpecRow) => rowItem.rowKey)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }
          .width(WSCS_TABLE_WIDTH)
          .layoutWeight(1)
          .align(Alignment.Top)
          .scrollBar(BarState.Off)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(WSCS_PAGE_BG)
        .alignItems(HorizontalAlign.Start)
        .onAreaChange((oldArea: Area, newArea: Area) => {
          if (typeof newArea.width === 'number' && newArea.width > 0) {
            this.winWidthVp = newArea.width;
          }
          if (typeof newArea.height === 'number' && newArea.height > 0) {
            this.winHeightVp = newArea.height;
          }
        })

        this.landscapeFab()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(WSCS_PAGE_BG)
    }
    .hideTitleBar(true)
  }
}
