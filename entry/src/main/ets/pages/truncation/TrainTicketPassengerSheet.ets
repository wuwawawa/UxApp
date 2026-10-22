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
 * 反例：截断 / 12306乘车人弹层截断（弹窗截断）
 *
 * 反例主题：乘车人列表最后一行与「完成」按钮被弹层下沿裁掉。
 *
 * 复刻对象：铁路12306「确认订单」页 + 乘车人选择半屏弹层 —— 蓝色渐变头部
 *   （返回 + 确认订单）、白色车次卡（G107 次 + 日期、北京南 08:32 → 上海虹桥 12:31、
 *   历时 3小时59分、二等座 05车12F）、席位票价行（二等座 ¥553.00 x2）、
 *   提交订单按钮；半屏弹层：顶部拖拽条、「已选乘车人 · 已选2人」标题 + 关闭叉、
 *   6 个乘车人行（勾选圈 + 姓名 + 证件号打码 + 票种胶囊：成人票 / 学生票 / 儿童票）、
 *   底部「完成」按钮；弹层背后订单页被半透明遮罩压暗。
 *
 * 设计基准：以单屏折叠态窗口宽 459.6vp 为基准：
 *   弹层高度写死 430vp（≈ 单屏窗口高 672vp 的 64%，反例根源）；
 *   弹层圆角 16vp、拖拽条 36x4vp、标题 16vp；乘车人行高 48vp、姓名 15vp、
 *   证件号 12vp、勾选圈 20vp；「完成」按钮高 44vp、文字 15vp；
 *   车次卡内车次号 22vp、站名 18vp、时刻 22vp、票价行 13vp。
 *
 * 三态实测：
 *   单屏态        459.6×672vp   —— 弹层 459.6×430vp，内容高约 420vp，
 *                                 6 个乘车人与「完成」按钮刚好完整可见；
 *   双屏态竖屏    664.7×939.6vp —— 弹层高度仍写死 430vp，行高随窗口放大到 69.4vp，
 *                                 内容高约 607vp，最后 3 个乘车人被弹层下沿裁掉，
 *                                 「完成」按钮整体出框不可点；
 *   双屏态横屏    939.6×664.7vp —— 弹层高度仍是 430vp，内容高约 858vp，
 *                                 只剩标题与前 1 个乘车人，列表与按钮全部被裁。
 *
 * 问题表现：
 *   半屏弹层高度按单屏窗口比例写死（430vp），弹层内的标题行、乘车人列表、
 *   完成按钮却全部按窗口宽度等比放大；窗口一宽，内容总高远超 430vp，
 *   弹层开了 clip(true)，最后一行乘车人只剩上半截、「完成」按钮完全消失，
 *   用户无法确认选人。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 缩放基准：单屏折叠态窗口宽度（1264px / 2.75） */
const TPS_BASE_WIDTH: number = 459.6;

/** 状态栏兜底高度（vp） */
const TPS_STATUS_BAR_FALLBACK: number = 32;

const TPS_PAGE_BG: string = '#F4F6F9';
const TPS_HEADER_START: string = '#3B7CFF';
const TPS_HEADER_END: string = '#2C68FF';
const TPS_BLUE: string = '#3B7CFF';
const TPS_BLUE_LIGHT: string = '#EAF1FF';
const TPS_TEXT_MAIN: string = '#1A1A1A';
const TPS_TEXT_SUB: string = '#8C8C8C';
const TPS_TEXT_LIGHT: string = '#B9BFC8';
const TPS_ORANGE: string = '#FF7A45';
const TPS_GREEN: string = '#22B573';

/** 头部：标题行 44vp、标题 18vp、返回箭头 24vp */
const TPS_TITLE_ROW_HEIGHT: number = 44;
const TPS_TITLE_FONT: number = 18;
const TPS_BACK_FONT: number = 24;

/** 车次卡：留白 12vp、圆角 14vp、内边距 14vp */
const TPS_CARD_INSET: number = 12;
const TPS_CARD_RADIUS: number = 14;
const TPS_CARD_PAD: number = 14;

/** 车次卡文字：车次号 22vp、日期 12vp、站名 18vp、时刻 22vp、历时 12vp、票价 13vp */
const TPS_TRAIN_NO_FONT: number = 22;
const TPS_DATE_FONT: number = 12;
const TPS_STATION_FONT: number = 18;
const TPS_TIME_FONT: number = 22;
const TPS_DURATION_FONT: number = 12;
const TPS_FARE_FONT: number = 13;

/** 弹层：高度写死 430vp（反例根源）、圆角 16vp、拖拽条 36x4vp、标题 16vp、副标题 13vp */
const TPS_SHEET_HEIGHT: number = 430;
const TPS_SHEET_RADIUS: number = 16;
const TPS_GRABBER_WIDTH: number = 36;
const TPS_GRABBER_HEIGHT: number = 4;
const TPS_SHEET_TITLE_FONT: number = 16;
const TPS_SHEET_COUNT_FONT: number = 13;
const TPS_CLOSE_FONT: number = 18;

/** 乘车人行：高 48vp、姓名 15vp、证件号 12vp、勾选圈 20vp、票种胶囊 11vp */
const TPS_PASSENGER_ROW_HEIGHT: number = 48;
const TPS_NAME_FONT: number = 15;
const TPS_ID_FONT: number = 12;
const TPS_CHECK_SIZE: number = 20;
const TPS_TICKET_TAG_FONT: number = 11;

/** 「完成」按钮：高 44vp、文字 15vp */
const TPS_DONE_HEIGHT: number = 44;
const TPS_DONE_FONT: number = 15;

/** 乘车人数据 */
interface TrainPassengerItem {
  passengerName: string;
  passengerId: string;
  ticketType: string;
  ticketTint: string;
  passengerSelected: boolean;
}

const TPS_PASSENGERS: TrainPassengerItem[] = [
  {
    passengerName: '王建国',
    passengerId: '1302**********1234',
    ticketType: '成人票',
    ticketTint: TPS_BLUE,
    passengerSelected: true
  },
  {
    passengerName: '李秀兰',
    passengerId: '1101**********0038',
    ticketType: '成人票',
    ticketTint: TPS_BLUE,
    passengerSelected: true
  },
  {
    passengerName: '王小萌',
    passengerId: '1101**********0042',
    ticketType: '学生票',
    ticketTint: TPS_ORANGE,
    passengerSelected: false
  },
  {
    passengerName: '张伟',
    passengerId: '3101**********7726',
    ticketType: '成人票',
    ticketTint: TPS_BLUE,
    passengerSelected: false
  },
  {
    passengerName: '陈静',
    passengerId: '4201**********1183',
    ticketType: '儿童票',
    ticketTint: TPS_GREEN,
    passengerSelected: false
  },
  {
    passengerName: '刘洋',
    passengerId: '3201**********9517',
    ticketType: '成人票',
    ticketTint: TPS_BLUE,
    passengerSelected: false
  }
];

@Component
export struct TrainTicketPassengerSheetPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = TPS_BASE_WIDTH;
  @State winHeightVp: number = 672;
  /** 沉浸式下的状态栏高度（vp） */
  @State statusBarHeightVp: number = TPS_STATUS_BAR_FALLBACK;

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
      this.windowToken = WindowModeController.acquire(win, TPS_HEADER_START);
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  /** 场景缩放比：当前窗口宽 / 单屏折叠态基准宽 */
  private sceneScale(): number {
    return this.winWidthVp / TPS_BASE_WIDTH;
  }

  /** 把基准宽下的设计值换算到当前窗口宽度 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  /** 头部标题行：返回 + 确认订单 */
  @Builder
  orderTitleBar() {
    Stack({ alignContent: Alignment.Center }) {
      Text('确认订单')
        .fontSize(this.vs(TPS_TITLE_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)

      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(this.vs(TPS_BACK_FONT))
          .fontColor([Color.White])
          .onClick(() => {
            this.pageStack.pop();
          })
      }
      .width('100%')
      .padding({ left: this.vs(12) })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(this.vs(TPS_TITLE_ROW_HEIGHT))
  }

  /** 车次卡：G107 + 站名时刻 + 席位票价 */
  @Builder
  trainCard() {
    Column() {
      Row() {
        Text('G107')
          .fontSize(this.vs(TPS_TRAIN_NO_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(TPS_BLUE)

        Text('2026年10月23日')
          .fontSize(this.vs(TPS_DATE_FONT))
          .fontColor(TPS_TEXT_SUB)
          .margin({ left: this.vs(10) })

        Blank()

        Text('改签')
          .fontSize(this.vs(TPS_FARE_FONT))
          .fontColor(TPS_BLUE)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Row() {
        Column() {
          Text('08:32')
            .fontSize(this.vs(TPS_TIME_FONT))
            .fontWeight(FontWeight.Bold)
            .fontColor(TPS_TEXT_MAIN)

          Text('北京南')
            .fontSize(this.vs(TPS_STATION_FONT))
            .fontColor(TPS_TEXT_MAIN)
            .margin({ top: this.vs(4) })
        }
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('3小时59分')
            .fontSize(this.vs(TPS_DURATION_FONT))
            .fontColor(TPS_TEXT_LIGHT)

          Row() {
            Row()
              .width(this.vs(30))
              .height(this.vs(1.5))
              .backgroundColor('#D5DBE3')

            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontSize(this.vs(12))
              .fontColor([TPS_TEXT_LIGHT])

            Row()
              .width(this.vs(30))
              .height(this.vs(1.5))
              .backgroundColor('#D5DBE3')
          }
          .alignItems(VerticalAlign.Center)
          .margin({ top: this.vs(4) })
        }
        .alignItems(HorizontalAlign.Center)
        .layoutWeight(1)

        Column() {
          Text('12:31')
            .fontSize(this.vs(TPS_TIME_FONT))
            .fontWeight(FontWeight.Bold)
            .fontColor(TPS_TEXT_MAIN)

          Text('上海虹桥')
            .fontSize(this.vs(TPS_STATION_FONT))
            .fontColor(TPS_TEXT_MAIN)
            .margin({ top: this.vs(4) })
        }
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ top: this.vs(14) })

      Divider()
        .strokeWidth(this.vs(0.5))
        .color('#EDF0F4')
        .margin({ top: this.vs(12), bottom: this.vs(10) })

      Row() {
        Text('二等座 · 05车12F号 · 无餐车')
          .fontSize(this.vs(TPS_FARE_FONT))
          .fontColor(TPS_TEXT_SUB)

        Blank()

        Text('¥553.00')
          .fontSize(this.vs(15))
          .fontWeight(FontWeight.Bold)
          .fontColor(TPS_ORANGE)

        Text('x2')
          .fontSize(this.vs(TPS_FARE_FONT))
          .fontColor(TPS_TEXT_SUB)
          .margin({ left: this.vs(6) })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(this.vs(TPS_CARD_PAD))
    .backgroundColor(Color.White)
    .borderRadius(this.vs(TPS_CARD_RADIUS))
    .margin({ left: this.vs(TPS_CARD_INSET), right: this.vs(TPS_CARD_INSET), top: this.vs(10), bottom: this.vs(12) })
    .alignItems(HorizontalAlign.Start)
  }

  /** 订单页底部的提交按钮（被弹层遮住大半） */
  @Builder
  submitBar() {
    Row() {
      Column() {
        Text('合计')
          .fontSize(this.vs(TPS_FARE_FONT))
          .fontColor(TPS_TEXT_SUB)

        Row({ space: this.vs(2) }) {
          Text('¥')
            .fontSize(this.vs(12))
            .fontColor(TPS_ORANGE)

          Text('1106.00')
            .fontSize(this.vs(20))
            .fontWeight(FontWeight.Bold)
            .fontColor(TPS_ORANGE)
        }
        .alignItems(VerticalAlign.Bottom)
        .margin({ top: this.vs(2) })
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Text('提交订单')
        .fontSize(this.vs(TPS_DONE_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .height(this.vs(TPS_DONE_HEIGHT))
        .padding({ left: this.vs(30), right: this.vs(30) })
        .backgroundColor(TPS_BLUE)
        .borderRadius(this.vs(TPS_DONE_HEIGHT / 2))
    }
    .width('100%')
    .padding({ left: this.vs(TPS_CARD_PAD), right: this.vs(TPS_CARD_PAD) })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  passengerRow(passenger: TrainPassengerItem) {
    Row() {
      SymbolGlyph($r('sys.symbol.checkmark_circle'))
        .fontSize(this.vs(TPS_CHECK_SIZE))
        .fontColor([passenger.passengerSelected ? TPS_BLUE : '#D9DEE5'])

      Column() {
        Text(passenger.passengerName)
          .fontSize(this.vs(TPS_NAME_FONT))
          .fontWeight(FontWeight.Medium)
          .fontColor(TPS_TEXT_MAIN)

        Text(passenger.passengerId)
          .fontSize(this.vs(TPS_ID_FONT))
          .fontColor(TPS_TEXT_LIGHT)
          .margin({ top: this.vs(3) })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: this.vs(10) })

      Text(passenger.ticketType)
        .fontSize(this.vs(TPS_TICKET_TAG_FONT))
        .fontColor(passenger.ticketTint)
        .border({ width: this.vs(1), color: passenger.ticketTint })
        .borderRadius(this.vs(3))
        .padding({ left: this.vs(6), right: this.vs(6), top: this.vs(2), bottom: this.vs(2) })
    }
    .width('100%')
    .height(this.vs(TPS_PASSENGER_ROW_HEIGHT))
    .padding({ left: this.vs(16), right: this.vs(16) })
    .alignItems(VerticalAlign.Center)
  }

  /** 乘车人半屏弹层：高度写死 430vp（反例核心），内容随窗口放大后被下沿裁掉 */
  @Builder
  passengerSheet() {
    Column() {
      Row()
        .width(this.vs(TPS_GRABBER_WIDTH))
        .height(this.vs(TPS_GRABBER_HEIGHT))
        .borderRadius(this.vs(TPS_GRABBER_HEIGHT / 2))
        .backgroundColor('#DDE2E9')
        .margin({ top: this.vs(8) })

      Stack({ alignContent: Alignment.End }) {
        Row({ space: this.vs(8) }) {
          Text('已选乘车人')
            .fontSize(this.vs(TPS_SHEET_TITLE_FONT))
            .fontWeight(FontWeight.Bold)
            .fontColor(TPS_TEXT_MAIN)

          Text('已选2人')
            .fontSize(this.vs(TPS_SHEET_COUNT_FONT))
            .fontColor(TPS_BLUE)
        }
        .alignItems(VerticalAlign.Center)
        .width('100%')

        SymbolGlyph($r('sys.symbol.xmark'))
          .fontSize(this.vs(TPS_CLOSE_FONT))
          .fontColor(['#999999'])
          .margin({ right: this.vs(16) })
          .onClick(() => {
            this.pageStack.pop();
          })
      }
      .width('100%')
      .height(this.vs(40))
      .padding({ left: this.vs(16) })
      .margin({ top: this.vs(4) })

      Column() {
        ForEach(TPS_PASSENGERS, (passenger: TrainPassengerItem) => {
          this.passengerRow(passenger)
        }, (passenger: TrainPassengerItem) => passenger.passengerName + passenger.passengerId)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      Text('完成')
        .fontSize(this.vs(TPS_DONE_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .width('100%')
        .height(this.vs(TPS_DONE_HEIGHT))
        .textAlign(TextAlign.Center)
        .backgroundColor(TPS_BLUE)
        .borderRadius(this.vs(TPS_DONE_HEIGHT / 2))
        .margin({ top: this.vs(12), bottom: this.vs(12) })
    }
    .width('100%')
    .height(TPS_SHEET_HEIGHT)
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: this.vs(TPS_SHEET_RADIUS), topRight: this.vs(TPS_SHEET_RADIUS) })
    .clip(true)
    .alignItems(HorizontalAlign.Start)
    .position({ x: 0, y: this.winHeightVp - TPS_SHEET_HEIGHT })
  }

  /** 弹层背后的半透明遮罩 */
  @Builder
  sheetDim() {
    Column()
      .width('100%')
      .height('100%')
      .backgroundColor('#000000')
      .opacity(0.35)
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        Column() {
          Column() {
            this.orderTitleBar()
          }
          .width('100%')
          .linearGradient({ angle: 180, colors: [[TPS_HEADER_START, 0], [TPS_HEADER_END, 1]] })
          .padding({ top: this.statusBarHeightVp })

          Scroll() {
            Column() {
              this.trainCard()
              this.submitBar()
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .align(Alignment.Top)
          .backgroundColor(TPS_PAGE_BG)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(TPS_PAGE_BG)

        this.sheetDim()
        this.passengerSheet()
      }
      .width('100%')
      .height('100%')
      .clip(true)
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
