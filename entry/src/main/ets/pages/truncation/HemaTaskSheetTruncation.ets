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

/** 缩放基准：单屏态窗口宽度（1264px / 2.75） */
const HEMA_REFERENCE_WIDTH: number = 459.6;

/** 弹层高度 / 窗口宽度。单屏 340vp、双屏竖屏 492vp、双屏横屏 695vp */
const HEMA_SHEET_HEIGHT_RATIO: number = 0.74;

/** 底部原生 TabBar 高度（三种屏态下都保持在 84vp 左右） */
const HEMA_TAB_BAR_HEIGHT: number = 84;

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

  private hostWindow: window.Window | undefined = undefined;

  aboutToAppear(): void {
    this.enableFullScreen();
  }

  aboutToDisappear(): void {
    this.restoreWindowMode();
  }

  private enableFullScreen(): void {
    const hostContext = this.getUIContext().getHostContext();
    if (hostContext === undefined) {
      return;
    }
    window.getLastWindow(hostContext).then((win: window.Window) => {
      this.hostWindow = win;
      win.setWindowLayoutFullScreen(true).catch((error: BusinessError) => {
        console.error(`setWindowLayoutFullScreen failed, code=${error.code}`);
      });
      win.setWindowSystemBarProperties({
        statusBarContentColor: '#000000',
        navigationBarContentColor: '#000000'
      }).catch((error: BusinessError) => {
        console.error(`setWindowSystemBarProperties failed, code=${error.code}`);
      });
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  private restoreWindowMode(): void {
    const win: window.Window | undefined = this.hostWindow;
    if (win === undefined) {
      return;
    }
    win.setWindowLayoutFullScreen(false).catch((error: BusinessError) => {
      console.error(`setWindowLayoutFullScreen failed, code=${error.code}`);
    });
    win.setWindowSystemBarProperties({
      statusBarContentColor: '#000000',
      navigationBarContentColor: '#000000'
    }).catch((error: BusinessError) => {
      console.error(`setWindowSystemBarProperties failed, code=${error.code}`);
    });
    this.hostWindow = undefined;
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
  pageHeader() {
    Row() {
      Text('收盒花 得美味')
        .fontSize(this.vs(28))
        .fontWeight(FontWeight.Bold)
        .fontColor('#F4E3C5')

      Blank()

      Row({ space: this.vs(6) }) {
        SymbolGlyph($r('sys.symbol.person'))
          .fontSize(this.vs(18))
          .fontColor(['#F1E4D0'])
        Text('我的')
          .fontSize(this.vs(14))
          .fontColor('#F1E4D0')
      }
      .height(this.vs(36))
      .padding({ left: this.vs(14), right: this.vs(16) })
      .border({ width: this.vs(1), color: '#A9BAC7' })
      .borderRadius(this.vs(18))
      .backgroundColor('#40566B')
    }
    .width('100%')
    .padding({ left: this.vs(22), right: this.vs(22) })
    .margin({ top: this.vs(58) })
  }

  /** 木牌 + 河马场景，整页同样按宽度等比放大 */
  @Builder
  heroScene() {
    Stack({ alignContent: Alignment.Top }) {
      Row()
        .width('150%')
        .height(this.vs(230))
        .backgroundColor('#69889E')
        .borderRadius(this.vs(115))
        .offset({ y: this.vs(300) })

      Row()
        .width('150%')
        .height(this.vs(180))
        .backgroundColor('#7D9BAF')
        .borderRadius(this.vs(90))
        .offset({ y: this.vs(250) })

      // 展开态窗口更高时才会露出的「选择美味」木牌
      if (this.winHeightVp > 800) {
        Stack({ alignContent: Alignment.Center }) {
          Row()
            .width(this.vs(300))
            .height(this.vs(62))
            .backgroundColor('#9A6A3F')
            .borderRadius(this.vs(10))
          Row() {
            Text('选择美味')
              .fontSize(this.vs(24))
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFE9C8')
          }
          .width(this.vs(170))
          .height(this.vs(40))
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#7D3A24')
          .borderRadius(this.vs(20))
        }
        .width(this.vs(300))
        .height(this.vs(62))
        .offset({ y: this.vs(96) })
      }

      this.mascot()
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  mascot() {
    Stack({ alignContent: Alignment.Top }) {
      // 叶子
      Row()
        .width(this.vs(86))
        .height(this.vs(30))
        .backgroundColor('#5A9E46')
        .borderRadius(this.vs(15))
        .rotate({ angle: -18 })
        .offset({ x: -this.vs(72), y: this.vs(190) })
      Row()
        .width(this.vs(76))
        .height(this.vs(28))
        .backgroundColor('#6CB354')
        .borderRadius(this.vs(14))
        .rotate({ angle: 14 })
        .offset({ x: this.vs(78), y: this.vs(196) })
      Row()
        .width(this.vs(64))
        .height(this.vs(24))
        .backgroundColor('#4E8F3C')
        .borderRadius(this.vs(12))
        .offset({ y: this.vs(204) })

      // 草帽
      Row()
        .width(this.vs(156))
        .height(this.vs(44))
        .backgroundColor('#E3AF5C')
        .borderRadius(this.vs(22))
        .offset({ y: this.vs(2) })
      Row()
        .width(this.vs(112))
        .height(this.vs(26))
        .backgroundColor('#F2C877')
        .borderRadius(this.vs(13))
        .offset({ y: this.vs(0) })

      // 耳朵
      Row()
        .width(this.vs(26))
        .height(this.vs(30))
        .backgroundColor('#2F8FD9')
        .borderRadius(this.vs(13))
        .offset({ x: -this.vs(62), y: this.vs(36) })
      Row()
        .width(this.vs(26))
        .height(this.vs(30))
        .backgroundColor('#2F8FD9')
        .borderRadius(this.vs(13))
        .offset({ x: this.vs(62), y: this.vs(36) })

      // 身体
      Row()
        .width(this.vs(148))
        .height(this.vs(140))
        .backgroundColor('#2F8FD9')
        .borderRadius(this.vs(70))
        .offset({ y: this.vs(28) })

      // 眼睛
      Row({ space: this.vs(26) }) {
        Row()
          .width(this.vs(9))
          .height(this.vs(14))
          .backgroundColor('#1E4F86')
          .borderRadius(this.vs(4.5))
        Row()
          .width(this.vs(9))
          .height(this.vs(14))
          .backgroundColor('#1E4F86')
          .borderRadius(this.vs(4.5))
      }
      .offset({ y: this.vs(52) })

      // 白色大口鼻
      Stack({ alignContent: Alignment.Top }) {
        Row()
          .width(this.vs(64))
          .height(this.vs(54))
          .backgroundColor('#E4F6FD')
          .borderRadius(this.vs(27))
          .offset({ x: -this.vs(20) })
        Row()
          .width(this.vs(64))
          .height(this.vs(54))
          .backgroundColor('#D9F0FA')
          .borderRadius(this.vs(27))
          .offset({ x: this.vs(20) })
      }
      .width(this.vs(108))
      .height(this.vs(54))
      .offset({ y: this.vs(72) })

      // 红色蝴蝶结
      Stack({ alignContent: Alignment.Top }) {
        Row()
          .width(this.vs(22))
          .height(this.vs(18))
          .backgroundColor('#E0303F')
          .borderRadius(this.vs(9))
          .offset({ x: -this.vs(10) })
        Row()
          .width(this.vs(22))
          .height(this.vs(18))
          .backgroundColor('#E0303F')
          .borderRadius(this.vs(9))
          .offset({ x: this.vs(10) })
      }
      .width(this.vs(44))
      .height(this.vs(18))
      .offset({ y: this.vs(146) })

      // 手里的小礼花
      Column() {
        Row()
          .width(this.vs(26))
          .height(this.vs(10))
          .backgroundColor('#F2A03C')
          .borderRadius(this.vs(5))
        Row()
          .width(this.vs(20))
          .height(this.vs(40))
          .backgroundColor('#EE4A45')
          .borderRadius(this.vs(4))
          .margin({ top: this.vs(2) })
      }
      .rotate({ angle: -18 })
      .offset({ x: -this.vs(82), y: this.vs(84) })

      Text('✦')
        .fontSize(this.vs(16))
        .fontColor('#FFE58A')
        .offset({ x: -this.vs(70), y: this.vs(62) })
      Text('✦')
        .fontSize(this.vs(11))
        .fontColor('#FFE58A')
        .offset({ x: -this.vs(94), y: this.vs(80) })
    }
    .width(this.vs(280))
    .height(this.vs(232))
    .offset({ y: this.winHeightVp > 800 ? this.vs(145) : this.vs(120) })
  }

  @Builder
  pageBackdrop() {
    Stack({ alignContent: Alignment.Top }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#7A96B8')

      this.heroScene()
      this.pageHeader()
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  dimLayer() {
    Column()
      .width('100%')
      .height(this.winHeightVp - HEMA_TAB_BAR_HEIGHT)
      .backgroundColor('#000000')
      .opacity(0.3)
      .offset({ y: -HEMA_TAB_BAR_HEIGHT })
      .hitTestBehavior(HitTestMode.None)
  }

  @Builder
  tabItem(symbol: Resource, label: string, active: boolean, showBadge: boolean) {
    Column() {
      Stack({ alignContent: Alignment.TopEnd }) {
        SymbolGlyph(symbol)
          .fontSize(25)
          .fontColor([active ? '#14A7E0' : '#2F3237'])

        if (showBadge) {
          Text('12')
            .fontSize(9)
            .fontColor(Color.White)
            .backgroundColor('#F5222D')
            .borderRadius(7)
            .padding({ left: 4, right: 4, top: 0, bottom: 0 })
            .offset({ x: 9, y: -6 })
        }
      }
      .width(30)
      .height(24)

      Text(label)
        .fontSize(11)
        .fontColor(active ? '#14A7E0' : '#2F3237')
        .margin({ top: 3 })
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  bottomTabBar() {
    Row() {
      this.tabItem($r('sys.symbol.house'), '首页', false, false)
      this.tabItem($r('sys.symbol.square_grid_2x2'), '分类', false, false)
      this.tabItem($r('sys.symbol.drop_fill'), '盒马小镇', true, false)
      this.tabItem($r('sys.symbol.cart'), '购物车', false, true)
      this.tabItem($r('sys.symbol.face_smiling'), '我的', false, false)
    }
    .width('100%')
    .height(HEMA_TAB_BAR_HEIGHT)
    .padding({ top: 8 })
    .backgroundColor('#F4F5F7')
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
    .margin({ bottom: HEMA_TAB_BAR_HEIGHT })
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        this.pageBackdrop()
        this.dimLayer()
        this.bottomTabBar()
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
