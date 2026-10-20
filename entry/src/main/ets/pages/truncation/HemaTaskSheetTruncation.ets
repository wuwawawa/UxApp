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
 * 反例：截断 / 盒马「做任务 攒盒花」弹层截断
 *
 * 复刻盒马 App 首页的签到任务弹层：整页按窗口宽度做等比缩放（H5 rem 适配），
 * 弹层宽度撑满窗口，高度 = 窗口宽度 × 0.742，贴底摆放在 84vp 高的底部 TabBar 之上，
 * 自身高度不随窗口高度收敛，也不可滚动。
 *
 * 当前 Pura X Max 上（密度 2.75）：
 * 单屏态 459.6×672vp：弹层高 340vp，顶部在 248vp，完整可见；
 * 双屏态竖屏 664.7×939.6vp：弹层高 492vp，顶部在 364vp，完整可见；
 * 双屏态横屏 939.6×664.7vp：弹层高 695vp，但 TabBar 之上只剩 580.7vp，
 * 弹层顶部被窗口裁掉约 115vp：顶部的「做任务 攒盒花」标题、
 * 「每日签到」文案整体移出屏幕，右上角的「去签到」按钮只剩下半截。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';
import { HemaTownScene, HemaTownTabBar, HEMA_TOWN_TAB_BAR_HEIGHT } from '../../common/HemaTownScene';

/** 缩放基准：单屏态窗口宽度（1264px / 2.75） */
const HEMA_REFERENCE_WIDTH: number = 459.6;

/** 弹层高度 / 窗口宽度。单屏 340vp、双屏竖屏 492vp、双屏横屏 695vp */
const HEMA_SHEET_HEIGHT_RATIO: number = 0.74;

/** 签到进度条上的 7 档奖励 */
const HEMA_REWARDS: string[] = ['+500', '+1000', '+1500', '+2000', '+2500', '+3000', '+3500'];

@Component
export struct HemaTaskSheetTruncationPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠/旋转实时更新 */
  @State winWidthVp: number = HEMA_REFERENCE_WIDTH;
  @State winHeightVp: number = 672;

  /** 签到提醒开关状态，仅用于让弹层可交互 */
  @State reminderOn: boolean = false;

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

  /** 整页等比缩放比：窗口宽度 / 单屏态宽度 */
  private uiScale(): number {
    const widthRatio: number = this.winWidthVp / HEMA_REFERENCE_WIDTH;
    return widthRatio < 0.8 ? 0.8 : widthRatio;
  }

  /** 把按单屏态（459.6vp）绘制的尺寸换算成当前窗口尺寸 */
  private vs(baseVp: number): number {
    return baseVp * this.uiScale();
  }

  /** 弹层高度只跟窗口宽度走，不跟窗口高度收敛 */
  private sheetHeightVp(): number {
    return this.winWidthVp * HEMA_SHEET_HEIGHT_RATIO;
  }

  @Builder
  dimLayer() {
    Column()
      .width('100%')
      .height(this.winHeightVp - HEMA_TOWN_TAB_BAR_HEIGHT)
      .backgroundColor('#000000')
      .opacity(0.3)
      .offset({ y: -HEMA_TOWN_TAB_BAR_HEIGHT })
      .hitTestBehavior(HitTestMode.None)
  }

  @Builder
  sheetBanner() {
    Row() {
      Text('做任务 攒盒花')
        .fontSize(this.vs(24))
        .fontWeight(FontWeight.Bold)
        .fontColor('#6B3E1E')
    }
    .width(this.vs(275))
    .height(this.vs(40))
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F8E1BB')
    .borderRadius(this.vs(12))
    .offset({ y: -this.vs(10) })
  }

  @Builder
  reminderSwitch() {
    Stack({ alignContent: Alignment.Start }) {
      Row()
        .width(this.vs(30))
        .height(this.vs(18))
        .backgroundColor(this.reminderOn ? '#F3B45F' : '#E5E5E5')
        .borderRadius(this.vs(9))
      Row()
        .width(this.vs(14))
        .height(this.vs(14))
        .backgroundColor(Color.White)
        .borderRadius(this.vs(7))
        .offset({ x: this.reminderOn ? this.vs(14) : this.vs(2), y: this.vs(2) })
    }
    .width(this.vs(30))
    .height(this.vs(18))
    .onClick(() => {
      this.reminderOn = !this.reminderOn;
    })
  }

  @Builder
  actionButton(label: string, showDot: boolean) {
    Stack({ alignContent: Alignment.TopEnd }) {
      Row() {
        Text(label)
          .fontSize(this.vs(20))
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
      }
      .width(this.vs(101))
      .height(this.vs(41))
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#12C4F3')
      .borderRadius(this.vs(20.5))

      if (showDot) {
        Row()
          .width(this.vs(10))
          .height(this.vs(10))
          .backgroundColor('#F5122E')
          .borderRadius(this.vs(5))
          .border({ width: this.vs(2), color: '#FDFCF7' })
          .offset({ x: this.vs(4), y: -this.vs(3) })
      }
    }
    .width(this.vs(101))
    .height(this.vs(41))
  }

  @Builder
  signInRow() {
    Row() {
      Stack({ alignContent: Alignment.Center }) {
        Row()
          .width(this.vs(51))
          .height(this.vs(51))
          .backgroundColor('#FFE7C1')
          .borderRadius(this.vs(25.5))
        SymbolGlyph($r('sys.symbol.calendar_badge_checkmark'))
          .fontSize(this.vs(30))
          .fontColor(['#F5A623'])
      }
      .width(this.vs(51))
      .height(this.vs(51))

      Column() {
        Row() {
          Text('每日签到')
            .fontSize(this.vs(17.5))
            .fontWeight(FontWeight.Bold)
            .fontColor('#7C3D18')

          Text('已连续签到0天')
            .fontSize(this.vs(14))
            .fontColor('#D98A3B')
            .margin({ left: this.vs(4) })
            .maxLines(1)
        }
        .alignItems(VerticalAlign.Bottom)

        Row() {
          this.reminderSwitch()
          Text('签到提醒')
            .fontSize(this.vs(16))
            .fontColor('#8A5A2B')
            .margin({ left: this.vs(7) })
        }
        .margin({ top: this.vs(6) })
        .alignItems(VerticalAlign.Center)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: this.vs(7) })

      this.actionButton('去签到', true)
    }
    .width('100%')
    .height(this.vs(52))
    .padding({ left: this.vs(24), right: this.vs(24) })
    .alignItems(VerticalAlign.Center)
    .margin({ top: this.vs(35) })
  }

  @Builder
  bubbleTea(size: number) {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(this.vs(size))
        .height(this.vs(size))
        .backgroundColor('#FFEFD8')
        .borderRadius(this.vs(size / 2))

      Row()
        .width(this.vs(size * 0.55))
        .height(this.vs(size * 0.42))
        .backgroundColor('#F0423A')
        .borderRadius({
          topLeft: this.vs(size * 0.12),
          topRight: this.vs(size * 0.12),
          bottomLeft: this.vs(size * 0.2),
          bottomRight: this.vs(size * 0.2)
        })
        .offset({ y: this.vs(size * 0.08) })

      Row()
        .width(this.vs(size * 0.62))
        .height(this.vs(size * 0.26))
        .backgroundColor('#FFF9EE')
        .borderRadius(this.vs(size * 0.12))
        .offset({ y: -this.vs(size * 0.12) })

      Row()
        .width(this.vs(size * 0.06))
        .height(this.vs(size * 0.26))
        .backgroundColor('#E9C79A')
        .borderRadius(this.vs(size * 0.03))
        .rotate({ angle: 16 })
        .offset({ x: this.vs(size * 0.16), y: -this.vs(size * 0.28) })
    }
    .width(this.vs(size))
    .height(this.vs(size))
  }

  @Builder
  rewardTimeline() {
    Stack({ alignContent: Alignment.Top }) {
      Row()
        .width(this.vs(367.3))
        .height(this.vs(6))
        .backgroundColor('#FBE4BF')
        .borderRadius(this.vs(3))
        .margin({ top: this.vs(15) })

      Row() {
        ForEach(HEMA_REWARDS, (label: string) => {
          Column() {
            this.bubbleTea(36)
            Text(label)
              .fontSize(this.vs(13.5))
              .fontColor('#B47C4E')
              .maxLines(1)
              .margin({ top: this.vs(3) })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
        }, (label: string) => label)
      }
      .width('100%')
      .padding({ left: this.vs(14.5), right: this.vs(16.6) })
    }
    .width('100%')
    .height(this.vs(60))
    .margin({ top: this.vs(14) })
  }

  @Builder
  orderTaskRow() {
    Row() {
      Stack({ alignContent: Alignment.Center }) {
        Row()
          .width(this.vs(51))
          .height(this.vs(51))
          .backgroundColor('#DDF4FF')
          .borderRadius(this.vs(25.5))
        SymbolGlyph($r('sys.symbol.bag_fill'))
          .fontSize(this.vs(30))
          .fontColor(['#45B7E8'])
      }
      .width(this.vs(51))
      .height(this.vs(51))

      Column() {
        Text('每日线上下单任务')
          .fontSize(this.vs(17.5))
          .fontWeight(FontWeight.Bold)
          .fontColor('#7C3D18')
          .maxLines(1)

        Row() {
          Text('每日首次任意消费')
            .fontSize(this.vs(14))
            .fontColor('#C68A3C')
            .maxLines(1)

          this.bubbleTea(16)

          Text('+1500')
            .fontSize(this.vs(14))
            .fontColor('#C68A3C')
            .maxLines(1)
        }
        .margin({ top: this.vs(4) })
        .alignItems(VerticalAlign.Center)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: this.vs(7) })

      this.actionButton('去下单', false)
    }
    .width('100%')
    .height(this.vs(57))
    .padding({ left: this.vs(24), right: this.vs(24) })
    .alignItems(VerticalAlign.Center)
    .margin({ top: this.vs(25) })
  }

  @Builder
  taskSheet() {
    Stack({ alignContent: Alignment.Top }) {
      // 橙色描边层：内容不参与边框内缩，保证弹层内容按整窗宽度等比排布
      Row()
        .width('100%')
        .height('100%')
        .backgroundColor('#D79156')
        .borderRadius({ topLeft: this.vs(9), topRight: this.vs(9) })

      Column()
        .width(this.winWidthVp - this.vs(14.6))
        .height(this.sheetHeightVp() - this.vs(14.6))
        .backgroundColor('#FDFCF7')
        .borderRadius({ topLeft: this.vs(4), topRight: this.vs(4) })
        .margin({ top: this.vs(7.3) })

      Column() {
        this.signInRow()
        this.rewardTimeline()
        this.orderTaskRow()
        Divider()
          .strokeWidth(this.vs(1))
          .color('#F4E8D6')
          .width(this.winWidthVp - this.vs(106))
          .margin({ left: this.vs(82) })
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Start)

      this.sheetBanner()
    }
    .width('100%')
    .height(this.sheetHeightVp())
  }

  @Builder
  closeButton() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(this.vs(31))
        .height(this.vs(31))
        .backgroundColor('#22000000')
        .border({ width: this.vs(1.5), color: Color.White })
        .borderRadius(this.vs(15.5))
      Text('✕')
        .fontSize(this.vs(17))
        .fontColor(Color.White)
    }
    .width(this.vs(31))
    .height(this.vs(31))
    .margin({ right: this.vs(21) })
    .offset({ y: -this.vs(63.5) })
  }

  @Builder
  popupLayer() {
    Stack({ alignContent: Alignment.TopEnd }) {
      this.taskSheet()
      this.closeButton()
    }
    .width('100%')
    .height(this.sheetHeightVp())
    .margin({ bottom: HEMA_TOWN_TAB_BAR_HEIGHT })
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        HemaTownScene({ sceneScale: this.uiScale(), sceneHeightVp: this.winHeightVp })
        this.dimLayer()
        HemaTownTabBar()
        this.popupLayer()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#7A96B8')
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
