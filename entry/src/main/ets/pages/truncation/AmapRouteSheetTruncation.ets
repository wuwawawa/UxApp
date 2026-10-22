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
 * 反例：截断 / 高德路线方案弹层截断（弹窗截断）
 *
 * 复刻对象：高德地图「路线规划」页 —— 上半屏浅蓝绿渐变地图占位（白色 / 土黄色道路、
 *   蓝色路线条、起点绿点与终点红标）、悬浮搜索卡（南山科技园 ⇄ 宝安国际机场 + 换向按钮）、
 *   「驾车 / 公交 / 步行」方式标签；下半屏白色圆角路线弹层：拖拽把手、
 *   「驾车路线 (3条方案)」标题行 + 「时间优先 ▾」、3 张路线卡
 *   （35分钟 方案一 / 41分钟 方案二 / 32分钟 推荐方案 —— 时间、里程、打车价、红绿灯标签）。
 *
 * 设计基准（vp，按单屏态 459.6vp 宽绘制）：弹层定高 290vp（设计稿照抄的固定值）；
 *   把手 36×4vp、标题行 24vp、路线卡定高 64vp（首行 34vp + 标签行 22vp）、间距 6~8vp；
 *   搜索卡高 40vp、方式标签高 34vp、字号 10~16vp。
 *
 * 三态实测：
 *   单屏态        459.6vp 宽 —— sceneScale 1.00，3 张路线卡合计约 272vp，装进 290vp 定高弹层，完整显示；
 *   双屏态竖屏    664.7vp 宽 —— sceneScale 1.45，路线卡放大到约 93vp 高，第 3 张「推荐方案」
 *                              只剩上沿 13vp，红绿灯标签行与「打车约¥46」被弹层下沿整行裁掉；
 *   双屏态横屏    939.6vp 宽 —— sceneScale 2.04，推荐方案整张消失，第 2 张方案的红绿灯标签行也被裁掉。
 *
 * 问题表现：
 *   路线弹层高度是设计稿定值 290vp，不随窗口放大；弹层内的标题行、路线卡全部按
 *   sceneScale 放大 —— 宽窗口下内容总高远超 290vp，推荐方案（32分钟 · 打车约¥46 · 红绿灯12个）
 *   恰好排在最后，它的红绿灯标签行和打车价被弹层下沿裁掉，用户看不到推荐方案的关键信息。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 单屏态折叠屏基准宽度（vp），sceneScale 以它为 1.0 */
const AMR_ROUTE_BASE_WIDTH: number = 459.6;

/** 状态栏 / 底部手势区兜底高度（vp） */
const AMR_STATUS_BAR_FALLBACK: number = 34;
const AMR_BOTTOM_INSET_FALLBACK: number = 8;

/** 路线弹层定高：设计稿照抄的固定值（vp），不随窗口放大 —— 反例根源 */
const AMR_SHEET_FIXED_HEIGHT: number = 290;
/** 路线卡定高（vp） */
const AMR_ROUTE_CARD_HEIGHT: number = 64;

const AMR_MAP_TOP: string = '#CBE8D6';
const AMR_MAP_MID: string = '#E6F2EA';
const AMR_MAP_BOTTOM: string = '#F4F7F5';
const AMR_ROAD_WHITE: string = '#FFFFFF';
const AMR_ROAD_YELLOW: string = '#F8DCA0';
const AMR_ROUTE_BLUE: string = '#4A82E8';
const AMR_PAGE_WHITE: string = '#FFFFFF';
const AMR_TEXT_MAIN: string = '#1A1A1A';
const AMR_TEXT_SUB: string = '#777777';
const AMR_TEXT_LIGHT: string = '#A6A6A6';
const AMR_BADGE_RED: string = '#E8593C';
const AMR_BADGE_BG: string = '#FDEEE9';
const AMR_CHIP_GREEN: string = '#2E9E5B';
const AMR_CHIP_GREEN_BG: string = '#E8F6EC';
const AMR_CHIP_BLUE: string = '#3B72E8';
const AMR_CHIP_BLUE_BG: string = '#EAF1FF';
const AMR_CARD_BG: string = '#F7F8FA';
const AMR_TAB_ACTIVE: string = '#1D6FE8';
const AMR_TAB_ACTIVE_BG: string = '#EAF2FF';
const AMR_HANDLE_GRAY: string = '#DDDDDD';

/** 路线方案卡：时间 / 里程 / 打车价 / 红绿灯标签，isRecommended 标记推荐方案 */
interface AmapRoutePlan {
  planKey: string;
  planBadge: string;
  isRecommended: boolean;
  timeText: string;
  distText: string;
  taxiText: string;
  lightText: string;
  extraChip: string;
}

/** 推荐方案排在最后：宽窗口下最先被弹层定高裁掉 */
const AMR_ROUTE_PLANS: AmapRoutePlan[] = [
  {
    planKey: 'amr-plan-1', planBadge: '', isRecommended: false,
    timeText: '35分钟', distText: '20.1公里', taxiText: '打车约¥52',
    lightText: '红绿灯8个', extraChip: '红绿灯少'
  },
  {
    planKey: 'amr-plan-2', planBadge: '', isRecommended: false,
    timeText: '41分钟', distText: '17.2公里', taxiText: '打车约¥48',
    lightText: '红绿灯15个', extraChip: '躲避拥堵'
  },
  {
    planKey: 'amr-plan-3', planBadge: '推荐', isRecommended: true,
    timeText: '32分钟', distText: '18.5公里', taxiText: '打车约¥46',
    lightText: '红绿灯12个', extraChip: '时间最短'
  }
];

@Component
export struct AmapRouteSheetTruncationPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = AMR_ROUTE_BASE_WIDTH;
  @State winHeightVp: number = 672;
  /** 沉浸式下的状态栏 / 底部手势区高度（vp） */
  @State statusBarHeightVp: number = AMR_STATUS_BAR_FALLBACK;
  @State bottomInsetVp: number = AMR_BOTTOM_INSET_FALLBACK;

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
      this.windowToken = WindowModeController.acquire(win, AMR_MAP_TOP);
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  /** 场景缩放比：窗口越宽，页面整体放大越多（单屏态为 1.0） */
  private sceneScale(): number {
    const widthRatio: number = this.winWidthVp / AMR_ROUTE_BASE_WIDTH;
    return widthRatio < 1 ? 1 : widthRatio;
  }

  /** 把设计基准值（vp）换算到当前窗口宽度 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  // ------------------------------------------------------------------
  // 地图占位：渐变底 + 道路 + 路线 + 起终点
  // ------------------------------------------------------------------

  @Builder
  mapRoadLine(roadLeft: number, roadTop: number, roadWidth: number, roadAngle: number, roadColor: string) {
    Row()
      .width(this.vs(roadWidth))
      .height(this.vs(7))
      .backgroundColor(roadColor)
      .borderRadius(this.vs(3.5))
      .rotate({ angle: roadAngle })
      .position({ x: this.vs(roadLeft), y: this.vs(roadTop) })
  }

  @Builder
  mapRouteLine() {
    Stack({ alignContent: Alignment.TopStart }) {
      Row()
        .width(this.vs(150))
        .height(this.vs(9))
        .backgroundColor(AMR_ROUTE_BLUE)
        .borderRadius(this.vs(4.5))
        .rotate({ angle: 32 })
        .position({ x: this.vs(60), y: this.vs(120) })

      Row()
        .width(this.vs(90))
        .height(this.vs(9))
        .backgroundColor(AMR_ROUTE_BLUE)
        .borderRadius(this.vs(4.5))
        .rotate({ angle: -18 })
        .position({ x: this.vs(168), y: this.vs(178) })
    }
    .width('100%')
    .height('100%')
    .clip(false)
  }

  @Builder
  mapMarkerLayer() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 起点：绿色圆点
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width(this.vs(14))
          .height(this.vs(14))
          .borderRadius(this.vs(7))
          .backgroundColor('#2E9E5B')
          .border({ width: this.vs(3), color: Color.White })
      }
      .width(this.vs(14))
      .height(this.vs(14))
      .position({ x: this.vs(56), y: this.vs(116) })

      // 终点：红色定位标
      Stack({ alignContent: Alignment.TopStart }) {
        SymbolGlyph($r('sys.symbol.pin'))
          .fontSize(this.vs(26))
          .fontColor([AMR_BADGE_RED])
      }
      .width(this.vs(26))
      .height(this.vs(26))
      .position({ x: this.vs(246), y: this.vs(206) })
    }
    .width('100%')
    .height('100%')
    .clip(false)
  }

  @Builder
  mapArea() {
    Stack({ alignContent: Alignment.Top }) {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 180,
          colors: [[AMR_MAP_TOP, 0.0], [AMR_MAP_MID, 0.55], [AMR_MAP_BOTTOM, 1.0]]
        })

      this.mapRoadLine(-30, 60, 300, 18, AMR_ROAD_WHITE)
      this.mapRoadLine(40, 200, 280, -12, AMR_ROAD_WHITE)
      this.mapRoadLine(180, 40, 220, 26, AMR_ROAD_YELLOW)
      this.mapRoadLine(-20, 300, 360, 8, AMR_ROAD_WHITE)

      this.mapRouteLine()
      this.mapMarkerLayer()

      this.searchCard()
      this.modeTabRow()
    }
    .width('100%')
    .height(this.winHeightVp - AMR_SHEET_FIXED_HEIGHT)
    .clip(true)
  }

  // ------------------------------------------------------------------
  // 搜索卡与方式标签
  // ------------------------------------------------------------------

  @Builder
  searchCard() {
    Row({ space: this.vs(6) }) {
      SymbolGlyph($r('sys.symbol.pin'))
        .fontSize(this.vs(12))
        .fontColor(['#2E9E5B'])

      Text('南山科技园')
        .fontSize(this.vs(12))
        .fontColor(AMR_TEXT_MAIN)
        .maxLines(1)

      Divider()
        .vertical(true)
        .height(this.vs(16))
        .strokeWidth(this.vs(1))
        .color('#E0E0E0')

      SymbolGlyph($r('sys.symbol.pin'))
        .fontSize(this.vs(12))
        .fontColor([AMR_BADGE_RED])

      Text('宝安国际机场')
        .fontSize(this.vs(12))
        .fontColor(AMR_TEXT_MAIN)
        .maxLines(1)
        .layoutWeight(1)

      Stack({ alignContent: Alignment.Center }) {
        SymbolGlyph($r('sys.symbol.arrow_down_left'))
          .fontSize(this.vs(10))
          .fontColor([AMR_TEXT_SUB])
          .position({ x: this.vs(4), y: 0 })

        SymbolGlyph($r('sys.symbol.arrow_up_left'))
          .fontSize(this.vs(10))
          .fontColor([AMR_TEXT_SUB])
          .position({ x: 0, y: this.vs(10) })
      }
      .width(this.vs(22))
      .height(this.vs(22))
    }
    .width('92%')
    .height(this.vs(40))
    .padding({ left: this.vs(12), right: this.vs(10) })
    .alignItems(VerticalAlign.Center)
    .backgroundColor(AMR_PAGE_WHITE)
    .borderRadius(this.vs(10))
    .shadow({ radius: this.vs(8), color: '#22000000', offsetX: 0, offsetY: this.vs(2) })
    .margin({ top: this.statusBarHeightVp + this.vs(8) })
  }

  @Builder
  modeTabLabel(tabIcon: Resource, tabText: string, tabActive: boolean) {
    Row({ space: this.vs(4) }) {
      SymbolGlyph(tabIcon)
        .fontSize(this.vs(14))
        .fontColor([tabActive ? AMR_TAB_ACTIVE : AMR_TEXT_SUB])

      Text(tabText)
        .fontSize(this.vs(12))
        .fontWeight(tabActive ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(tabActive ? AMR_TAB_ACTIVE : AMR_TEXT_SUB)
    }
    .height(this.vs(30))
    .padding({ left: this.vs(12), right: this.vs(12) })
    .alignItems(VerticalAlign.Center)
    .backgroundColor(tabActive ? AMR_TAB_ACTIVE_BG : Color.Transparent)
    .borderRadius(this.vs(15))
  }

  @Builder
  modeTabRow() {
    Row({ space: this.vs(4) }) {
      this.modeTabLabel($r('sys.symbol.car_fill'), '驾车', true)
      this.modeTabLabel($r('sys.symbol.navigation'), '公交', false)
      this.modeTabLabel($r('sys.symbol.figure_walk'), '步行', false)
    }
    .width('92%')
    .height(this.vs(34))
    .padding({ left: this.vs(4), right: this.vs(4) })
    .alignItems(VerticalAlign.Center)
    .backgroundColor(AMR_PAGE_WHITE)
    .borderRadius(this.vs(17))
    .shadow({ radius: this.vs(8), color: '#22000000', offsetX: 0, offsetY: this.vs(2) })
    .margin({ top: this.vs(8) })
  }

  // ------------------------------------------------------------------
  // 路线弹层（定高 290vp，内容按 sceneScale 放大 —— 反例核心）
  // ------------------------------------------------------------------

  @Builder
  routeChip(chipText: string, chipColor: string, chipBg: string) {
    Text(chipText)
      .fontSize(this.vs(10))
      .fontColor(chipColor)
      .padding({ left: this.vs(6), right: this.vs(6), top: this.vs(2), bottom: this.vs(2) })
      .backgroundColor(chipBg)
      .borderRadius(this.vs(4))
      .maxLines(1)
  }

  @Builder
  routeCard(planItem: AmapRoutePlan) {
    Column() {
      Row() {
        if (planItem.isRecommended) {
          Text(planItem.planBadge)
            .fontSize(this.vs(9))
            .fontColor(AMR_BADGE_RED)
            .backgroundColor(AMR_BADGE_BG)
            .borderRadius(this.vs(4))
            .padding({ left: this.vs(5), right: this.vs(5), top: this.vs(1), bottom: this.vs(1) })
            .margin({ right: this.vs(6) })
        }

        Text(planItem.timeText)
          .fontSize(this.vs(16))
          .fontWeight(FontWeight.Bold)
          .fontColor(AMR_TEXT_MAIN)

        Text(planItem.distText + ' · ' + planItem.taxiText)
          .fontSize(this.vs(11))
          .fontColor(AMR_TEXT_SUB)
          .margin({ left: this.vs(8) })
          .maxLines(1)
          .layoutWeight(1)

        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(this.vs(12))
          .fontColor([AMR_TEXT_LIGHT])
      }
      .width('100%')
      .height(this.vs(34))
      .padding({ top: this.vs(8) })
      .alignItems(VerticalAlign.Center)

      Row({ space: this.vs(6) }) {
        this.routeChip(planItem.lightText, AMR_CHIP_GREEN, AMR_CHIP_GREEN_BG)
        this.routeChip(planItem.extraChip, AMR_CHIP_BLUE, AMR_CHIP_BLUE_BG)
      }
      .width('100%')
      .height(this.vs(22))
      .margin({ top: this.vs(2) })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(this.vs(AMR_ROUTE_CARD_HEIGHT))
    .padding({ left: this.vs(10), right: this.vs(10) })
    .backgroundColor(AMR_CARD_BG)
    .borderRadius(this.vs(8))
    .clip(false)
  }

  @Builder
  routeSheet() {
    Column() {
      // 拖拽把手
      Row()
        .width(this.vs(36))
        .height(this.vs(4))
        .backgroundColor(AMR_HANDLE_GRAY)
        .borderRadius(this.vs(2))
        .margin({ top: this.vs(8) })

      // 标题行
      Row() {
        Text('驾车路线 (3条方案)')
          .fontSize(this.vs(13))
          .fontWeight(FontWeight.Medium)
          .fontColor(AMR_TEXT_MAIN)

        Blank()

        Text('时间优先 ▾')
          .fontSize(this.vs(10))
          .fontColor(AMR_TEXT_SUB)
      }
      .width('100%')
      .height(this.vs(24))
      .margin({ top: this.vs(8) })
      .alignItems(VerticalAlign.Center)

      // 3 张路线卡：全部按 sceneScale 放大，推荐方案排在最后
      ForEach(AMR_ROUTE_PLANS, (planItem: AmapRoutePlan) => {
        Column() {
          this.routeCard(planItem)
        }
        .width('100%')
        .margin({ top: this.vs(8) })
      }, (planItem: AmapRoutePlan) => planItem.planKey)
    }
    .width('100%')
    .height(AMR_SHEET_FIXED_HEIGHT)
    .padding({ left: this.vs(12), right: this.vs(12) })
    .backgroundColor(AMR_PAGE_WHITE)
    .borderRadius({ topLeft: this.vs(16), topRight: this.vs(16) })
    .shadow({ radius: this.vs(14), color: '#26000000', offsetX: 0, offsetY: -this.vs(3) })
    .clip(true)
    .position({ x: 0, y: this.winHeightVp - AMR_SHEET_FIXED_HEIGHT - this.bottomInsetVp })
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        this.mapArea()
        this.routeSheet()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(AMR_MAP_BOTTOM)
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
