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
 * 反例：未避让安全区 / 日历月视图月份压挖孔（挖孔）
 *
 * 复刻对象：系统日历「月」视图 —— 顶栏（返回箭头 + 居中「2026年10月」+ 右侧「今天」）、
 *   星期行（日 / 一 / 二 / 三 / 四 / 五 / 六）、6×7 日期网格（本月日期黑字、上下月日期灰字、
 *   今天圆形高亮、有日程的日期带圆点）、下方「今日日程」列表（时间、标题、地点）。
 *
 * 设计基准：以单屏折叠态窗口宽 459.6vp 为基准（页面所有尺寸按窗口宽度 / 459.6 等比换算）：
 *   顶栏高 44vp、从窗口顶边铺起，月份 17vp 加粗、垂直居中，两端文字 14vp；
 *   星期行高 26vp、文字 11vp；日期格高 46vp、日期数字 14vp、圆点 4vp；
 *   日程卡圆角 14vp、内边距 14vp、时间 13vp、标题 15vp、地点 11.5vp。
 *   网格起始为 9 月 27 日（周日），10 月 1 日是周四，共 6 行 42 格。
 *
 * 挖孔实测（Pura X Max 模拟器，密度 2.75，hidumper DisplayManagerService BoundingRects）：
 *   单屏态        459.6×672vp   —— 挖孔圆 24vp，顶部正中（x 218~242vp，y 9.5~33.5vp）；
 *   双屏态竖屏    664.7×939.6vp —— 挖孔圆 26.2vp，右下角（距右 10.2vp、距底 15.3vp）；
 *   双屏态横屏    939.6×664.7vp —— 挖孔圆 26.2vp，右上角（距右 15.3vp、距顶 10.2vp）。
 *
 * 三态实测：
 *   单屏态        459.6×672vp   —— 顶栏 0~44vp，月份「2026年10月」落在 x 180~278vp、
 *                                 y 约 12.7~26vp，挖孔圆（x 218~242vp、y 9.5~33.5vp）
 *                                 正好盖住「年」字与后面「10」的「1」；
 *   双屏态竖屏    664.7×939.6vp —— 顶栏放大到 0~63.7vp、月份放大到 24.6vp、
 *                                 落在 x 261~402vp，挖孔在右下角，两者不相交；
 *   双屏态横屏    939.6×664.7vp —— 顶栏放大到 0~90vp、月份落到 x 368~568vp，
 *                                 挖孔在右上角（x 898~924vp），两者不相交。
 *
 * 问题表现（单屏态）：
 *   顶栏正中的月份被前置摄像头挖孔从中间盖住，「年」字整块消失、后面的「1」只剩半截，
 *   月份读不出来；状态栏时间、电量图标同时压在顶栏两端。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 缩放基准：单屏折叠态窗口宽度（1264px / 2.75） */
const CAL_BASE_WIDTH: number = 459.6;

const CAL_PAGE_BG: string = '#FFFFFF';
const CAL_TEXT_MAIN: string = '#1C1C1E';
const CAL_TEXT_SUB: string = '#9B9B9F';
const CAL_TEXT_DIM: string = '#C9C9CD';
const CAL_BLUE: string = '#0A6CFF';
const CAL_CARD_BG: string = '#F7F7F9';

/** 顶栏：高 44vp、月份 17vp、两端文字 14vp */
const CAL_HEADER_HEIGHT: number = 44;
const CAL_MONTH_FONT: number = 17;
const CAL_SIDE_FONT: number = 14;

/** 星期行：高 26vp、文字 11vp */
const CAL_WEEK_ROW_HEIGHT: number = 26;
const CAL_WEEK_FONT: number = 11;

/** 日期格：高 46vp、数字 14vp、圆点 4vp */
const CAL_DAY_CELL_HEIGHT: number = 46;
const CAL_DAY_FONT: number = 14;
const CAL_DAY_DOT: number = 4;

/** 日程卡：圆角 14vp、内边距 14vp、时间 13vp、标题 15vp、地点 11.5vp */
const CAL_CARD_RADIUS: number = 14;
const CAL_CARD_PAD: number = 14;
const CAL_TIME_FONT: number = 13;
const CAL_TITLE_FONT: number = 15;
const CAL_PLACE_FONT: number = 11.5;

/** 9 月 27 日 ~ 9 月 30 日共 4 格排在 10 月 1 日之前 */
const CAL_PREV_MONTH_DAYS: number = 4;
/** 10 月共 31 天 */
const CAL_CUR_MONTH_DAYS: number = 31;
/** 6 行 × 7 列 */
const CAL_TOTAL_DAYS: number = 42;
const CAL_DAYS_PER_WEEK: number = 7;

/** 日期格数据 */
interface CalendarDayCell {
  dayKey: string;
  dayLabel: string;
  dayInMonth: boolean;
  dayToday: boolean;
  dayHasSchedule: boolean;
}

/** 一周 */
interface CalendarWeekRow {
  weekKey: string;
  weekDays: CalendarDayCell[];
}

/** 星期表头 */
const CAL_WEEK_LABELS: string[] = ['日', '一', '二', '三', '四', '五', '六'];

/** 生成 42 个日期格：4 个上月日期 + 31 个本月日期 + 7 个下月日期 */
function buildCalendarCells(): CalendarDayCell[] {
  const cells: CalendarDayCell[] = [];
  for (let index = 0; index < CAL_PREV_MONTH_DAYS; index++) {
    const prevDay: number = 27 + index;
    cells.push({
      dayKey: 'cal-prev-' + prevDay.toString(),
      dayLabel: prevDay.toString(),
      dayInMonth: false,
      dayToday: false,
      dayHasSchedule: false
    });
  }
  for (let day = 1; day <= CAL_CUR_MONTH_DAYS; day++) {
    cells.push({
      dayKey: 'cal-cur-' + day.toString(),
      dayLabel: day.toString(),
      dayInMonth: true,
      dayToday: day === 23,
      dayHasSchedule: day === 23 || day === 24 || day === 27
    });
  }
  for (let index = 0; index < CAL_TOTAL_DAYS - CAL_PREV_MONTH_DAYS - CAL_CUR_MONTH_DAYS; index++) {
    const nextDay: number = 1 + index;
    cells.push({
      dayKey: 'cal-next-' + nextDay.toString(),
      dayLabel: nextDay.toString(),
      dayInMonth: false,
      dayToday: false,
      dayHasSchedule: false
    });
  }
  return cells;
}

/** 把 42 个日期格按 7 天一行切开 */
function buildCalendarWeeks(): CalendarWeekRow[] {
  const cells: CalendarDayCell[] = buildCalendarCells();
  const weeks: CalendarWeekRow[] = [];
  for (let weekIndex = 0; weekIndex < CAL_TOTAL_DAYS / CAL_DAYS_PER_WEEK; weekIndex++) {
    const weekDays: CalendarDayCell[] = [];
    for (let dayIndex = 0; dayIndex < CAL_DAYS_PER_WEEK; dayIndex++) {
      const cell: CalendarDayCell | undefined = cells[weekIndex * CAL_DAYS_PER_WEEK + dayIndex];
      if (cell !== undefined) {
        weekDays.push(cell);
      }
    }
    weeks.push({ weekKey: 'cal-week-' + weekIndex.toString(), weekDays: weekDays });
  }
  return weeks;
}

const CAL_WEEKS: CalendarWeekRow[] = buildCalendarWeeks();

/** 日程数据 */
interface CalendarScheduleItem {
  scheduleKey: string;
  scheduleTime: string;
  scheduleTitle: string;
  schedulePlace: string;
}

const CAL_SCHEDULE_LIST: CalendarScheduleItem[] = [
  {
    scheduleKey: 'sch-review',
    scheduleTime: '09:30 - 10:30',
    scheduleTitle: '折叠屏案例评测评审',
    schedulePlace: '线上 · 会议号 812 447 609'
  },
  {
    scheduleKey: 'sch-sync',
    scheduleTime: '14:00 - 15:00',
    scheduleTitle: '与大屏适配小组对齐进度',
    schedulePlace: 'B 座 12 层 · 会议室「山海」'
  }
];

@Component
export struct CalendarMonthNotchPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = CAL_BASE_WIDTH;
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
      this.windowToken = WindowModeController.acquire(win, '#000000');
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  /** 场景缩放比：当前窗口宽 / 单屏折叠态基准宽 */
  private sceneScale(): number {
    return this.winWidthVp / CAL_BASE_WIDTH;
  }

  /** 把基准宽下的设计值换算到当前窗口宽度 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  /** 顶栏：返回 + 居中月份 + 今天 */
  @Builder
  monthHeader() {
    Stack({ alignContent: Alignment.Center }) {
      Text('2026年10月')
        .fontSize(this.vs(CAL_MONTH_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(CAL_TEXT_MAIN)
        .maxLines(1)

      Row() {
        Text('‹')
          .fontSize(this.vs(CAL_SIDE_FONT + 10))
          .fontColor(CAL_BLUE)
          .onClick(() => {
            this.pageStack.pop();
          })

        Blank()

        Text('今天')
          .fontSize(this.vs(CAL_SIDE_FONT))
          .fontColor(CAL_BLUE)
      }
      .width('100%')
      .height('100%')
      .padding({ left: this.vs(12), right: this.vs(14) })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(this.vs(CAL_HEADER_HEIGHT))
  }

  /** 星期表头：日 一 二 三 四 五 六 */
  @Builder
  weekHeader() {
    Row() {
      ForEach(CAL_WEEK_LABELS, (weekLabel: string) => {
        Text(weekLabel)
          .fontSize(this.vs(CAL_WEEK_FONT))
          .fontColor(CAL_TEXT_SUB)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      }, (weekLabel: string) => 'cal-week-label-' + weekLabel)
    }
    .width('100%')
    .height(this.vs(CAL_WEEK_ROW_HEIGHT))
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  dayCell(cell: CalendarDayCell) {
    Column({ space: this.vs(3) }) {
      Stack({ alignContent: Alignment.Center }) {
        if (cell.dayToday) {
          Circle()
            .width(this.vs(30))
            .height(this.vs(30))
            .fill(CAL_BLUE)
        }

        Text(cell.dayLabel)
          .fontSize(this.vs(CAL_DAY_FONT))
          .fontWeight(cell.dayToday ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(cell.dayToday ? Color.White : (cell.dayInMonth ? CAL_TEXT_MAIN : CAL_TEXT_DIM))
      }
      .width(this.vs(30))
      .height(this.vs(30))

      Row()
        .width(this.vs(CAL_DAY_DOT))
        .height(this.vs(CAL_DAY_DOT))
        .backgroundColor(cell.dayToday ? CAL_BLUE : (cell.dayHasSchedule ? CAL_TEXT_SUB : Color.Transparent))
        .borderRadius(this.vs(CAL_DAY_DOT / 2))
    }
    .layoutWeight(1)
    .height(this.vs(CAL_DAY_CELL_HEIGHT))
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  weekRow(week: CalendarWeekRow) {
    Row() {
      ForEach(week.weekDays, (cell: CalendarDayCell) => {
        this.dayCell(cell)
      }, (cell: CalendarDayCell) => cell.dayKey)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  /** 日期网格：6 行 × 7 列 */
  @Builder
  monthGrid() {
    Column() {
      ForEach(CAL_WEEKS, (week: CalendarWeekRow) => {
        this.weekRow(week)
      }, (week: CalendarWeekRow) => week.weekKey)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  scheduleRow(item: CalendarScheduleItem) {
    Row() {
      Column()
        .width(this.vs(3))
        .height(this.vs(30))
        .backgroundColor(CAL_BLUE)
        .borderRadius(this.vs(1.5))

      Column({ space: this.vs(4) }) {
        Text(item.scheduleTime)
          .fontSize(this.vs(CAL_TIME_FONT))
          .fontColor(CAL_TEXT_SUB)

        Text(item.scheduleTitle)
          .fontSize(this.vs(CAL_TITLE_FONT))
          .fontColor(CAL_TEXT_MAIN)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(item.schedulePlace)
          .fontSize(this.vs(CAL_PLACE_FONT))
          .fontColor(CAL_TEXT_SUB)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: this.vs(10) })
    }
    .width('100%')
    .padding(this.vs(CAL_CARD_PAD))
    .backgroundColor(CAL_CARD_BG)
    .borderRadius(this.vs(CAL_CARD_RADIUS))
    .alignItems(VerticalAlign.Top)
  }

  /** 今日日程列表 */
  @Builder
  scheduleArea() {
    Column() {
      Row() {
        Text('今日日程')
          .fontSize(this.vs(CAL_TITLE_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(CAL_TEXT_MAIN)

        Blank()

        Text('共 2 项')
          .fontSize(this.vs(CAL_PLACE_FONT))
          .fontColor(CAL_TEXT_SUB)
      }
      .width('100%')
      .height(this.vs(30))
      .alignItems(VerticalAlign.Center)

      ForEach(CAL_SCHEDULE_LIST, (item: CalendarScheduleItem) => {
        this.scheduleRow(item)
      }, (item: CalendarScheduleItem) => item.scheduleKey)
    }
    .width('100%')
    .padding({ left: this.vs(14), right: this.vs(14) })
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    NavDestination() {
      Column() {
        this.monthHeader()
        this.weekHeader()
        this.monthGrid()

        Scroll() {
          Column({ space: this.vs(8) }) {
            this.scheduleArea()
          }
          .width('100%')
          .padding({ bottom: this.vs(16) })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(CAL_PAGE_BG)
      .alignItems(HorizontalAlign.Start)
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
