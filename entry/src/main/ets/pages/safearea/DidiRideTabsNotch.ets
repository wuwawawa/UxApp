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
 * 反例：未避让安全区 / 滴滴打车车型切换压挖孔（挖孔）
 *
 * 复刻对象：滴滴出行「选择车型」页 —— 橙色顶栏（返回箭头 + 居中「特惠快车 / 快车 / 出租车」
 *   三段切换 + 右侧「客服」入口）、白色行程卡（起点、终点、预估里程与时长）、
 *   车型列表（名称、描述、预估价、推荐标签、选中圆环）、底部优惠行与「呼叫快车」按钮。
 *
 * 设计基准：以单屏折叠态窗口宽 459.6vp 为基准（页面所有尺寸按窗口宽度 / 459.6 等比换算）：
 *   顶栏高 44vp、从窗口顶边铺起；三段切换文字 15vp（选中 16vp 加粗）、段间距 12vp、
 *   选中下划线宽 18vp、高 3vp；返回箭头与「客服」字 14vp；
 *   行程卡圆角 14vp、内边距 14vp、行高 26vp；车型行高 62vp、名称 17vp、描述 11.5vp、
 *   价格 18vp、标签 10vp；底部呼叫按钮高 48vp、圆角 24vp、文字 17vp。
 *
 * 挖孔实测（Pura X Max 模拟器，密度 2.75，hidumper DisplayManagerService BoundingRects）：
 *   单屏态        459.6×672vp   —— 挖孔圆 24vp，顶部正中（x 218~242vp，y 9.5~33.5vp）；
 *   双屏态竖屏    664.7×939.6vp —— 挖孔圆 26.2vp，右下角（距右 10.2vp、距底 15.3vp）；
 *   双屏态横屏    939.6×664.7vp —— 挖孔圆 26.2vp，右上角（距右 15.3vp、距顶 10.2vp）。
 *
 * 三态实测：
 *   单屏态        459.6×672vp   —— 顶栏 0~44vp，三段切换垂直居中，文字落在 y 约 10~26vp；
 *                                 「快车」两字落在 x 225~259vp，左字「快」整块落进挖孔圆
 *                                 （x 218~242vp、y 9.5~33.5vp）；
 *   双屏态竖屏    664.7×939.6vp —— 顶栏放大到 0~63.6vp，三段切换落到 x 217~447vp，
 *                                 挖孔在右下角，两者不相交；
 *   双屏态横屏    939.6×664.7vp —— 顶栏放大到 0~90vp，三段切换落到 x 307~632vp，
 *                                 挖孔在右上角（x 898~924vp），两者不相交。
 *
 * 问题表现（单屏态）：
 *   顶部居中的「快车」左字被前置摄像头挖孔整块盖住，「车」只剩贴着孔沿的一丝笔画，
 *   选中态的下划线左半段也被圆孔切断；状态栏的时间与电量图标同时叠在顶栏两端。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 缩放基准：单屏折叠态窗口宽度（1264px / 2.75） */
const DD_BASE_WIDTH: number = 459.6;

const DD_PAGE_BG: string = '#F4F4F4';
const DD_HEADER_START: string = '#FF8A1F';
const DD_HEADER_END: string = '#FF6400';
const DD_ORANGE: string = '#FF7700';
const DD_TEXT_MAIN: string = '#1A1A1A';
const DD_TEXT_SUB: string = '#8F8F8F';
const DD_TEXT_LIGHT: string = '#B5B5B5';
const DD_CARD_BG: string = '#FFFFFF';

/** 顶栏：高 44vp、切换文字 15/16vp、段间距 12vp、下划线 18×3vp、两端字 14vp */
const DD_HEADER_HEIGHT: number = 44;
const DD_TAB_FONT: number = 15;
const DD_TAB_ACTIVE_FONT: number = 16;
const DD_TAB_GAP: number = 12;
const DD_TAB_UNDERLINE_WIDTH: number = 18;
const DD_TAB_UNDERLINE_HEIGHT: number = 3;
const DD_HEADER_SIDE_FONT: number = 14;

/** 行程卡：圆角 14vp、内边距 14vp、行高 26vp、圆点 8vp */
const DD_CARD_RADIUS: number = 14;
const DD_CARD_PAD: number = 14;
const DD_TRIP_ROW_HEIGHT: number = 26;
const DD_TRIP_DOT: number = 8;

/** 车型行：高 62vp、名称 17vp、描述 11.5vp、价格 18vp、标签 10vp、选中圆环 20vp */
const DD_CAR_ROW_HEIGHT: number = 62;
const DD_CAR_NAME_FONT: number = 17;
const DD_CAR_DESC_FONT: number = 11.5;
const DD_CAR_PRICE_FONT: number = 18;
const DD_CAR_TAG_FONT: number = 10;
const DD_CAR_RADIO: number = 20;

/** 底部：优惠行高 26vp、呼叫按钮高 48vp、提示文字 11vp */
const DD_PROMO_ROW_HEIGHT: number = 26;
const DD_CALL_BUTTON_HEIGHT: number = 48;
const DD_HINT_FONT: number = 11;

/** 三段切换数据 */
interface DidiRideTabItem {
  tabKey: string;
  tabLabel: string;
  tabActive: boolean;
}

const DD_TAB_LIST: DidiRideTabItem[] = [
  { tabKey: 'tab-premium', tabLabel: '特惠快车', tabActive: false },
  { tabKey: 'tab-quick', tabLabel: '快车', tabActive: true },
  { tabKey: 'tab-taxi', tabLabel: '出租车', tabActive: false }
];

/** 车型数据 */
interface DidiCarOption {
  carKey: string;
  carName: string;
  carDesc: string;
  carPrice: string;
  carTag: string;
  carSelected: boolean;
}

const DD_CAR_LIST: DidiCarOption[] = [
  {
    carKey: 'car-premium',
    carName: '特惠快车',
    carDesc: '一口价 · 全程固定价格',
    carPrice: '¥26.8',
    carTag: '省 4 元',
    carSelected: false
  },
  {
    carKey: 'car-quick',
    carName: '快车',
    carDesc: '预计 3 分钟接驾',
    carPrice: '¥31.5',
    carTag: '最快',
    carSelected: true
  },
  {
    carKey: 'car-taxi',
    carName: '出租车',
    carDesc: '打表计价 · 路桥费另付',
    carPrice: '¥35.0',
    carTag: '扬招',
    carSelected: false
  },
  {
    carKey: 'car-share',
    carName: '拼车',
    carDesc: '与同路人共享行程',
    carPrice: '¥18.9',
    carTag: '省 12 元',
    carSelected: false
  }
];

/** 行程点数据 */
interface DidiTripPoint {
  pointKey: string;
  pointLabel: string;
  pointDetail: string;
  pointAccent: boolean;
}

const DD_TRIP_POINTS: DidiTripPoint[] = [
  { pointKey: 'point-start', pointLabel: '杭州东站 · 东广场网约车上客点', pointDetail: '现在', pointAccent: true },
  { pointKey: 'point-end', pointLabel: '西湖文化广场 · 环球中心 B 座', pointDetail: '14.2 公里', pointAccent: false }
];

@Component
export struct DidiRideTabsNotchPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = DD_BASE_WIDTH;
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
    return this.winWidthVp / DD_BASE_WIDTH;
  }

  /** 把基准宽下的设计值换算到当前窗口宽度 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  /** 顶栏：返回 + 居中三段切换 + 客服 */
  @Builder
  rideHeader() {
    Stack({ alignContent: Alignment.Center }) {
      Row({ space: this.vs(DD_TAB_GAP) }) {
        ForEach(DD_TAB_LIST, (tab: DidiRideTabItem) => {
          Column() {
            Text(tab.tabLabel)
              .fontSize(this.vs(tab.tabActive ? DD_TAB_ACTIVE_FONT : DD_TAB_FONT))
              .fontWeight(tab.tabActive ? FontWeight.Bold : FontWeight.Normal)
              .fontColor(Color.White)

            Row()
              .width(this.vs(DD_TAB_UNDERLINE_WIDTH))
              .height(this.vs(DD_TAB_UNDERLINE_HEIGHT))
              .backgroundColor(Color.White)
              .borderRadius(this.vs(DD_TAB_UNDERLINE_HEIGHT / 2))
              .margin({ top: this.vs(4) })
              .opacity(tab.tabActive ? 1 : 0)
          }
          .alignItems(HorizontalAlign.Center)
        }, (tab: DidiRideTabItem) => tab.tabKey)
      }
      .alignItems(VerticalAlign.Center)

      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(this.vs(DD_HEADER_SIDE_FONT + 4))
          .fontColor([Color.White])
          .onClick(() => {
            this.pageStack.pop();
          })

        Blank()

        Text('客服')
          .fontSize(this.vs(DD_HEADER_SIDE_FONT))
          .fontColor(Color.White)
      }
      .width('100%')
      .height('100%')
      .padding({ left: this.vs(12), right: this.vs(14) })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(this.vs(DD_HEADER_HEIGHT))
    .linearGradient({ angle: 180, colors: [[DD_HEADER_START, 0], [DD_HEADER_END, 1]] })
  }

  @Builder
  tripPointRow(point: DidiTripPoint) {
    Row() {
      Column()
        .width(this.vs(DD_TRIP_DOT))
        .height(this.vs(DD_TRIP_DOT))
        .backgroundColor(point.pointAccent ? '#22C55E' : '#FF7700')
        .borderRadius(this.vs(DD_TRIP_DOT / 2))

      Text(point.pointLabel)
        .fontSize(this.vs(DD_CAR_DESC_FONT + 1))
        .fontColor(DD_TEXT_MAIN)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)
        .margin({ left: this.vs(10) })

      Text(point.pointDetail)
        .fontSize(this.vs(DD_CAR_DESC_FONT))
        .fontColor(DD_TEXT_SUB)
        .margin({ left: this.vs(8) })
    }
    .width('100%')
    .height(this.vs(DD_TRIP_ROW_HEIGHT))
    .alignItems(VerticalAlign.Center)
  }

  /** 行程卡：起点 / 终点 / 里程时长 */
  @Builder
  tripCard() {
    Column() {
      ForEach(DD_TRIP_POINTS, (point: DidiTripPoint) => {
        this.tripPointRow(point)
      }, (point: DidiTripPoint) => point.pointKey)
    }
    .width('100%')
    .padding(this.vs(DD_CARD_PAD))
    .backgroundColor(DD_CARD_BG)
    .borderRadius(this.vs(DD_CARD_RADIUS))
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  carRow(car: DidiCarOption) {
    Row() {
      Column() {
        Row({ space: this.vs(6) }) {
          Text(car.carName)
            .fontSize(this.vs(DD_CAR_NAME_FONT))
            .fontWeight(FontWeight.Bold)
            .fontColor(DD_TEXT_MAIN)

          Text(car.carTag)
            .fontSize(this.vs(DD_CAR_TAG_FONT))
            .fontColor(DD_ORANGE)
            .backgroundColor('#FFF1E5')
            .borderRadius(this.vs(3))
            .padding({ left: this.vs(5), right: this.vs(5), top: this.vs(2), bottom: this.vs(2) })
        }
        .alignItems(VerticalAlign.Center)

        Text(car.carDesc)
          .fontSize(this.vs(DD_CAR_DESC_FONT))
          .fontColor(DD_TEXT_LIGHT)
          .margin({ top: this.vs(5) })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Column() {
        Text(car.carPrice)
          .fontSize(this.vs(DD_CAR_PRICE_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(DD_TEXT_MAIN)
      }
      .alignItems(HorizontalAlign.End)
      .margin({ right: this.vs(12) })

      Stack({ alignContent: Alignment.Center }) {
        if (car.carSelected) {
          Circle()
            .width(this.vs(DD_CAR_RADIO))
            .height(this.vs(DD_CAR_RADIO))
            .fill(DD_ORANGE)

          Text('✓')
            .fontSize(this.vs(11))
            .fontColor(Color.White)
        } else {
          Circle()
            .width(this.vs(DD_CAR_RADIO))
            .height(this.vs(DD_CAR_RADIO))
            .fill(Color.White)
            .stroke('#DDDDDD')
            .strokeWidth(this.vs(1))
        }
      }
      .width(this.vs(DD_CAR_RADIO))
      .height(this.vs(DD_CAR_RADIO))
    }
    .width('100%')
    .height(this.vs(DD_CAR_ROW_HEIGHT))
    .alignItems(VerticalAlign.Center)
  }

  /** 车型列表卡 */
  @Builder
  carCard() {
    Column() {
      Row() {
        Text('为你推荐')
          .fontSize(this.vs(DD_CAR_NAME_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(DD_TEXT_MAIN)

        Blank()

        Text('全部车型 ›')
          .fontSize(this.vs(DD_CAR_DESC_FONT))
          .fontColor(DD_TEXT_SUB)
      }
      .width('100%')
      .height(this.vs(34))
      .alignItems(VerticalAlign.Center)

      ForEach(DD_CAR_LIST, (car: DidiCarOption) => {
        this.carRow(car)
      }, (car: DidiCarOption) => car.carKey)
    }
    .width('100%')
    .padding({ left: this.vs(DD_CARD_PAD), right: this.vs(DD_CARD_PAD), top: this.vs(6), bottom: this.vs(8) })
    .backgroundColor(DD_CARD_BG)
    .borderRadius(this.vs(DD_CARD_RADIUS))
    .alignItems(HorizontalAlign.Start)
  }

  /** 底部：优惠行 + 呼叫按钮 + 提示 */
  @Builder
  callBar() {
    Column() {
      Row() {
        Text('已享优惠')
          .fontSize(this.vs(DD_CAR_DESC_FONT))
          .fontColor(DD_TEXT_SUB)

        Blank()

        Text('-¥6.00')
          .fontSize(this.vs(DD_CAR_DESC_FONT))
          .fontWeight(FontWeight.Medium)
          .fontColor(DD_ORANGE)
      }
      .width('100%')
      .height(this.vs(DD_PROMO_ROW_HEIGHT))
      .alignItems(VerticalAlign.Center)

      Row() {
        Text('呼叫快车')
          .fontSize(this.vs(DD_CAR_NAME_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
      }
      .width('100%')
      .height(this.vs(DD_CALL_BUTTON_HEIGHT))
      .justifyContent(FlexAlign.Center)
      .linearGradient({ angle: 90, colors: [[DD_HEADER_START, 0], [DD_HEADER_END, 1]] })
      .borderRadius(this.vs(DD_CALL_BUTTON_HEIGHT / 2))

      Text('点击即表示同意《滴滴出行服务协议》')
        .fontSize(this.vs(DD_HINT_FONT))
        .fontColor(DD_TEXT_LIGHT)
        .margin({ top: this.vs(8) })
    }
    .width('100%')
    .padding({ left: this.vs(DD_CARD_PAD), right: this.vs(DD_CARD_PAD), top: this.vs(8), bottom: this.vs(10) })
    .backgroundColor(DD_CARD_BG)
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    NavDestination() {
      Column() {
        this.rideHeader()

        Scroll() {
          Column() {
            this.tripCard()

            Row()
              .width('100%')
              .height(this.vs(10))

            this.carCard()

            Row()
              .width('100%')
              .height(this.vs(10))
          }
          .width('100%')
          .padding({ left: this.vs(10), right: this.vs(10), top: this.vs(10) })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .backgroundColor(DD_PAGE_BG)

        this.callBar()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(DD_PAGE_BG)
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
