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
 * 反例：截断 / 美团骑行卡「赠送亲友」弹窗截断
 *
 * 复刻美团骑车首页上的骑行卡赠送弹窗：暖色海报（第一行「骑行卡免费赠送亲友」、
 * 第二行「一人购卡 亲友同骑」、女儿给妈妈递礼盒、礼盒里插着「美团骑行卡」卡片），
 * 海报下沿压着「立即购卡」按钮（按钮一半在海报内、一半露在海报外），
 * 海报下方是圆形灰色关闭按钮。
 *
 * 弹窗由海报（303vp 高）、露在海报外的「立即购卡」按钮（23vp）和下方关闭按钮
 * （间隔 14vp、36vp 见方）组成，竖直居中摆放，顶部至少保留 44vp。
 *
 * 当前 Pura X Max 上（密度 2.75）：
 * 单屏态 459.6×672vp：弹窗 377×376vp，居中完整显示；
 * 双屏态竖屏 664.7×939.6vp：弹窗 545×544vp，居中完整显示；
 * 双屏态横屏 939.6×664.7vp：弹窗放大到 771×769vp，顶部固定在 44vp，
 * 底部超出窗口约 148vp：「立即购卡」只剩上半截，下面的圆形灰色关闭按钮整体被裁掉。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';
import {
  MeituanBikeScene,
  MeituanBikeTabBar,
  MEITUAN_BIKE_TAB_BAR_HEIGHT
} from '../../common/MeituanBikeScene';

/** 缩放基准：单屏态窗口宽度（1264px / 2.75） */
const BIKE_GIFT_REFERENCE_WIDTH: number = 459.6;

/** 弹窗海报的设计尺寸（vp，按 459.6vp 宽绘制） */
const BIKE_GIFT_POSTER_WIDTH: number = 377;
const BIKE_GIFT_POSTER_HEIGHT: number = 303;

/** 「立即购卡」按钮：一半压在海报上，一半露在海报外 */
const BIKE_GIFT_BUTTON_WIDTH: number = 286;
const BIKE_GIFT_BUTTON_HEIGHT: number = 46;
const BIKE_GIFT_BUTTON_OVERLAP: number = 23;

/** 圆形灰色关闭按钮：按钮下方留 14vp */
const BIKE_GIFT_CLOSE_SIZE: number = 36;
const BIKE_GIFT_CLOSE_GAP: number = 14;

/** 弹窗总高度 = 海报 + 按钮露出的半截 + 间距 + 关闭按钮 */
const BIKE_GIFT_DIALOG_HEIGHT: number =
  BIKE_GIFT_POSTER_HEIGHT + BIKE_GIFT_BUTTON_OVERLAP + BIKE_GIFT_CLOSE_GAP + BIKE_GIFT_CLOSE_SIZE;

/** 弹窗垂直居中时，顶部至少保留的间距（避免被状态栏压住，但不约束底部） */
const BIKE_GIFT_MIN_TOP: number = 44;

/** 海报底部插画区（女儿 / 妈妈 / 礼盒 / 卡片）的设计高度 */
const BIKE_GIFT_ILLUSTRATION_HEIGHT: number = 200;

const BIKE_GIFT_POSTER_COLORS: Array<[ResourceColor, number]> = [
  ['#FFFCF4', 0],
  ['#FFF0D8', 0.55],
  ['#FFE3BB', 1]
];

@Component
export struct BikeGiftDialogTruncationPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = BIKE_GIFT_REFERENCE_WIDTH;
  @State winHeightVp: number = 672;
  @State statusBarHeightVp: number = 34;

  /** 骑行卡弹窗是否展示 */
  @State giftDialogVisible: boolean = false;

  private pageActive: boolean = false;
  private windowToken: number = 0;

  aboutToAppear(): void {
    this.pageActive = true;
    this.enterImmersiveMode();
    // 进入页面即拉起弹窗
    setTimeout(() => {
      this.giftDialogVisible = true;
    }, 800);
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
      this.windowToken = WindowModeController.acquire(win, '#FFFFFF');
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  /** 首页等比缩放比：窗口宽度 / 单屏态宽度 */
  private uiScale(): number {
    const widthRatio: number = this.winWidthVp / BIKE_GIFT_REFERENCE_WIDTH;
    return widthRatio < 0.8 ? 0.8 : widthRatio;
  }

  /** 首页与弹窗共用的尺寸换算（与首页同一比例，通篇 rem 适配） */
  private gs(baseVp: number): number {
    return baseVp * this.uiScale();
  }

  private giftDialogWidthVp(): number {
    return this.gs(BIKE_GIFT_POSTER_WIDTH);
  }

  private giftDialogHeightVp(): number {
    return this.gs(BIKE_GIFT_DIALOG_HEIGHT);
  }

  /** 居中摆放；顶部不进入状态栏 */
  private giftDialogTopVp(): number {
    const centeredTop: number = (this.winHeightVp - this.giftDialogHeightVp()) / 2;
    return centeredTop < BIKE_GIFT_MIN_TOP ? BIKE_GIFT_MIN_TOP : centeredTop;
  }

  private giftDialogLeftVp(): number {
    return (this.winWidthVp - this.giftDialogWidthVp()) / 2;
  }

  @Builder
  giftConfetti() {
    Stack({ alignContent: Alignment.TopStart }) {
      Row()
        .width(this.gs(6))
        .height(this.gs(6))
        .borderRadius(this.gs(3))
        .backgroundColor('#FFCE6B')
        .position({ x: this.gs(18), y: this.gs(94) })
      Row()
        .width(this.gs(5))
        .height(this.gs(12))
        .borderRadius(this.gs(2.5))
        .backgroundColor('#F9A26B')
        .rotate({ angle: 28 })
        .position({ x: this.gs(352), y: this.gs(82) })
      Row()
        .width(this.gs(5))
        .height(this.gs(5))
        .borderRadius(this.gs(2.5))
        .backgroundColor('#FFC93C')
        .position({ x: this.gs(332), y: this.gs(248) })
      Row()
        .width(this.gs(4))
        .height(this.gs(10))
        .borderRadius(this.gs(2))
        .backgroundColor('#F58C6B')
        .rotate({ angle: -24 })
        .position({ x: this.gs(22), y: this.gs(252) })
      Row()
        .width(this.gs(4))
        .height(this.gs(4))
        .borderRadius(this.gs(2))
        .backgroundColor('#FFCE6B')
        .position({ x: this.gs(348), y: this.gs(48) })
    }
    .width('100%')
    .height(this.gs(BIKE_GIFT_POSTER_HEIGHT))
  }

  @Builder
  giftTitle() {
    Column({ space: this.gs(6) }) {
      Text() {
        Span('骑行卡')
          .fontColor('#3A2418')
        Span('免费')
          .fontColor('#F0482F')
        Span('赠送亲友')
          .fontColor('#3A2418')
      }
      .fontSize(this.gs(21.5))
      .fontWeight(FontWeight.Bold)

      Row({ space: this.gs(6) }) {
        Row()
          .width(this.gs(14))
          .height(this.gs(1.2))
          .backgroundColor('#DCA35D')
        Text('一人购卡 亲友同骑')
          .fontSize(this.gs(13))
          .fontColor('#9A6224')
          .letterSpacing(this.gs(1))
        Row()
          .width(this.gs(14))
          .height(this.gs(1.2))
          .backgroundColor('#DCA35D')
      }
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .margin({ top: this.gs(15) })
  }

  @Builder
  giftMother() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 发髻、头发、脸
      Row()
        .width(this.gs(22))
        .height(this.gs(22))
        .borderRadius(this.gs(11))
        .backgroundColor('#4A3026')
        .position({ x: this.gs(66), y: this.gs(6) })
      Row()
        .width(this.gs(64))
        .height(this.gs(64))
        .borderRadius(this.gs(32))
        .backgroundColor('#4A3026')
        .position({ x: this.gs(70), y: this.gs(20) })
      Row()
        .width(this.gs(50))
        .height(this.gs(50))
        .borderRadius(this.gs(25))
        .backgroundColor('#F6D2B2')
        .position({ x: this.gs(77), y: this.gs(30) })

      // 刘海与两侧头发
      Row()
        .width(this.gs(56))
        .height(this.gs(24))
        .borderRadius(this.gs(12))
        .backgroundColor('#4A3026')
        .position({ x: this.gs(74), y: this.gs(22) })
      Row()
        .width(this.gs(12))
        .height(this.gs(32))
        .borderRadius(this.gs(6))
        .backgroundColor('#4A3026')
        .position({ x: this.gs(71), y: this.gs(40) })
      Row()
        .width(this.gs(12))
        .height(this.gs(32))
        .borderRadius(this.gs(6))
        .backgroundColor('#4A3026')
        .position({ x: this.gs(124), y: this.gs(40) })

      // 眼睛、腮红、笑
      Row()
        .width(this.gs(5))
        .height(this.gs(7))
        .borderRadius(this.gs(2.5))
        .backgroundColor('#3A2418')
        .position({ x: this.gs(93), y: this.gs(50) })
      Row()
        .width(this.gs(5))
        .height(this.gs(7))
        .borderRadius(this.gs(2.5))
        .backgroundColor('#3A2418')
        .position({ x: this.gs(111), y: this.gs(50) })
      Row()
        .width(this.gs(9))
        .height(this.gs(6))
        .borderRadius(this.gs(3))
        .backgroundColor('#F4AF95')
        .opacity(0.75)
        .position({ x: this.gs(86), y: this.gs(59) })
      Row()
        .width(this.gs(9))
        .height(this.gs(6))
        .borderRadius(this.gs(3))
        .backgroundColor('#F4AF95')
        .opacity(0.75)
        .position({ x: this.gs(114), y: this.gs(59) })
      Row()
        .width(this.gs(10))
        .height(this.gs(4))
        .borderRadius(this.gs(2))
        .backgroundColor('#C9705A')
        .position({ x: this.gs(99), y: this.gs(64) })

      // 身体与腿
      Row()
        .width(this.gs(78))
        .height(this.gs(92))
        .borderRadius({ topLeft: this.gs(30), topRight: this.gs(30), bottomLeft: this.gs(14), bottomRight: this.gs(14) })
        .backgroundColor('#E9AE4C')
        .position({ x: this.gs(64), y: this.gs(78) })
      Row()
        .width(this.gs(24))
        .height(this.gs(10))
        .borderRadius(this.gs(5))
        .backgroundColor('#D99A33')
        .position({ x: this.gs(91), y: this.gs(78) })
      Row()
        .width(this.gs(15))
        .height(this.gs(22))
        .backgroundColor('#6B4A3A')
        .position({ x: this.gs(78), y: this.gs(168) })
      Row()
        .width(this.gs(15))
        .height(this.gs(22))
        .backgroundColor('#6B4A3A')
        .position({ x: this.gs(112), y: this.gs(168) })
      Row()
        .width(this.gs(24))
        .height(this.gs(10))
        .borderRadius(this.gs(5))
        .backgroundColor('#4A3428')
        .position({ x: this.gs(75), y: this.gs(188) })
      Row()
        .width(this.gs(24))
        .height(this.gs(10))
        .borderRadius(this.gs(5))
        .backgroundColor('#4A3428')
        .position({ x: this.gs(109), y: this.gs(188) })

      // 手臂
      Row()
        .width(this.gs(15))
        .height(this.gs(38))
        .borderRadius(this.gs(7.5))
        .backgroundColor('#E9AE4C')
        .rotate({ angle: 8 })
        .position({ x: this.gs(60), y: this.gs(98) })
      Row()
        .width(this.gs(16))
        .height(this.gs(16))
        .borderRadius(this.gs(8))
        .backgroundColor('#F6D2B2')
        .position({ x: this.gs(56), y: this.gs(132) })
      Row()
        .width(this.gs(46))
        .height(this.gs(15))
        .borderRadius(this.gs(7.5))
        .backgroundColor('#E9AE4C')
        .rotate({ angle: 14 })
        .position({ x: this.gs(128), y: this.gs(116) })
    }
    .width('100%')
    .height(this.gs(BIKE_GIFT_ILLUSTRATION_HEIGHT))
  }

  @Builder
  giftDaughter() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 丸子头与头发
      Row()
        .width(this.gs(18))
        .height(this.gs(18))
        .borderRadius(this.gs(9))
        .backgroundColor('#3A2418')
        .position({ x: this.gs(252), y: this.gs(44) })
      Row()
        .width(this.gs(18))
        .height(this.gs(18))
        .borderRadius(this.gs(9))
        .backgroundColor('#3A2418')
        .position({ x: this.gs(300), y: this.gs(44) })
      Row()
        .width(this.gs(54))
        .height(this.gs(54))
        .borderRadius(this.gs(27))
        .backgroundColor('#3A2418')
        .position({ x: this.gs(258), y: this.gs(56) })
      Row()
        .width(this.gs(44))
        .height(this.gs(44))
        .borderRadius(this.gs(22))
        .backgroundColor('#F8DCC0')
        .position({ x: this.gs(263), y: this.gs(64) })
      Row()
        .width(this.gs(50))
        .height(this.gs(22))
        .borderRadius(this.gs(11))
        .backgroundColor('#3A2418')
        .position({ x: this.gs(260), y: this.gs(58) })
      Row()
        .width(this.gs(10))
        .height(this.gs(26))
        .borderRadius(this.gs(5))
        .backgroundColor('#3A2418')
        .position({ x: this.gs(258), y: this.gs(74) })
      Row()
        .width(this.gs(10))
        .height(this.gs(26))
        .borderRadius(this.gs(5))
        .backgroundColor('#3A2418')
        .position({ x: this.gs(312), y: this.gs(74) })

      // 眼睛、腮红、笑
      Row()
        .width(this.gs(5))
        .height(this.gs(6))
        .borderRadius(this.gs(2.5))
        .backgroundColor('#3A2418')
        .position({ x: this.gs(278), y: this.gs(80) })
      Row()
        .width(this.gs(5))
        .height(this.gs(6))
        .borderRadius(this.gs(2.5))
        .backgroundColor('#3A2418')
        .position({ x: this.gs(294), y: this.gs(80) })
      Row()
        .width(this.gs(8))
        .height(this.gs(5))
        .borderRadius(this.gs(2.5))
        .backgroundColor('#F4AF95')
        .opacity(0.75)
        .position({ x: this.gs(272), y: this.gs(88) })
      Row()
        .width(this.gs(8))
        .height(this.gs(5))
        .borderRadius(this.gs(2.5))
        .backgroundColor('#F4AF95')
        .opacity(0.75)
        .position({ x: this.gs(298), y: this.gs(88) })
      Row()
        .width(this.gs(9))
        .height(this.gs(4))
        .borderRadius(this.gs(2))
        .backgroundColor('#C9705A')
        .position({ x: this.gs(283), y: this.gs(92) })

      // 黄色卫衣与腿
      Row()
        .width(this.gs(62))
        .height(this.gs(78))
        .borderRadius({ topLeft: this.gs(24), topRight: this.gs(24), bottomLeft: this.gs(12), bottomRight: this.gs(12) })
        .backgroundColor('#FFD84D')
        .position({ x: this.gs(256), y: this.gs(104) })
      Row()
        .width(this.gs(26))
        .height(this.gs(16))
        .borderRadius(this.gs(8))
        .backgroundColor('#F7C400')
        .position({ x: this.gs(274), y: this.gs(142) })
      Row()
        .width(this.gs(13))
        .height(this.gs(16))
        .backgroundColor('#6B4A3A')
        .position({ x: this.gs(266), y: this.gs(180) })
      Row()
        .width(this.gs(13))
        .height(this.gs(16))
        .backgroundColor('#6B4A3A')
        .position({ x: this.gs(292), y: this.gs(180) })
      Row()
        .width(this.gs(20))
        .height(this.gs(9))
        .borderRadius(this.gs(4.5))
        .backgroundColor('#4A3428')
        .position({ x: this.gs(263), y: this.gs(191) })
      Row()
        .width(this.gs(20))
        .height(this.gs(9))
        .borderRadius(this.gs(4.5))
        .backgroundColor('#4A3428')
        .position({ x: this.gs(289), y: this.gs(191) })

      // 递向礼盒的手臂
      Row()
        .width(this.gs(34))
        .height(this.gs(13))
        .borderRadius(this.gs(6.5))
        .backgroundColor('#FFD84D')
        .rotate({ angle: -12 })
        .position({ x: this.gs(232), y: this.gs(128) })
    }
    .width('100%')
    .height(this.gs(BIKE_GIFT_ILLUSTRATION_HEIGHT))
  }

  /** 礼盒：卡片从盒中露出，盒盖压在卡片下沿 */
  @Builder
  giftBox() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 卡片
      Column({ space: this.gs(3) }) {
        SymbolGlyph($r('sys.symbol.bicycle'))
          .fontSize(this.gs(13))
          .fontColor(['#FFB800'])
        Text('美团骑行卡')
          .fontSize(this.gs(12))
          .fontWeight(FontWeight.Bold)
          .fontColor('#3A2418')
          .maxLines(1)
      }
      .width(this.gs(86))
      .height(this.gs(68))
      .padding({ top: this.gs(12) })
      .justifyContent(FlexAlign.Start)
      .backgroundColor(Color.White)
      .border({ width: this.gs(2), color: '#FFC93C' })
      .borderRadius(this.gs(7))
      .shadow({ radius: this.gs(8), color: '#33000000', offsetX: 0, offsetY: this.gs(3) })
      .rotate({ angle: -8 })
      .position({ x: this.gs(152), y: this.gs(66) })

      // 盒体与盒盖
      Row()
        .width(this.gs(84))
        .height(this.gs(54))
        .borderRadius(this.gs(7))
        .backgroundColor('#F2685C')
        .position({ x: this.gs(150), y: this.gs(136) })
      Row()
        .width(this.gs(70))
        .height(this.gs(38))
        .borderRadius(this.gs(5))
        .backgroundColor('#FF8A7B')
        .opacity(0.5)
        .position({ x: this.gs(157), y: this.gs(144) })
      Row()
        .width(this.gs(92))
        .height(this.gs(16))
        .borderRadius(this.gs(6))
        .backgroundColor('#FF8F80')
        .position({ x: this.gs(146), y: this.gs(124) })

      // 丝带与蝴蝶结
      Row()
        .width(this.gs(10))
        .height(this.gs(54))
        .backgroundColor('#FFD24D')
        .position({ x: this.gs(187), y: this.gs(136) })
      Row()
        .width(this.gs(20))
        .height(this.gs(12))
        .borderRadius(this.gs(6))
        .backgroundColor('#FFC93C')
        .rotate({ angle: -24 })
        .position({ x: this.gs(172), y: this.gs(117) })
      Row()
        .width(this.gs(20))
        .height(this.gs(12))
        .borderRadius(this.gs(6))
        .backgroundColor('#FFC93C')
        .rotate({ angle: 24 })
        .position({ x: this.gs(194), y: this.gs(117) })
      Row()
        .width(this.gs(9))
        .height(this.gs(9))
        .borderRadius(this.gs(4.5))
        .backgroundColor('#FFB800')
        .position({ x: this.gs(187), y: this.gs(122) })
    }
    .width('100%')
    .height(this.gs(BIKE_GIFT_ILLUSTRATION_HEIGHT))
  }

  @Builder
  giftHands() {
    Stack({ alignContent: Alignment.TopStart }) {
      Row()
        .width(this.gs(16))
        .height(this.gs(16))
        .borderRadius(this.gs(8))
        .backgroundColor('#F6D2B2')
        .position({ x: this.gs(144), y: this.gs(132) })
      Row()
        .width(this.gs(15))
        .height(this.gs(15))
        .borderRadius(this.gs(7.5))
        .backgroundColor('#F8DCC0')
        .position({ x: this.gs(228), y: this.gs(128) })
    }
    .width('100%')
    .height(this.gs(BIKE_GIFT_ILLUSTRATION_HEIGHT))
  }

  @Builder
  giftIllustration() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 底部光晕与地面
      Row()
        .width(this.gs(220))
        .height(this.gs(220))
        .borderRadius(this.gs(110))
        .backgroundColor('#FFE7B0')
        .opacity(0.5)
        .position({ x: this.gs(80), y: this.gs(8) })
      Row()
        .width(this.gs(302))
        .height(this.gs(12))
        .borderRadius(this.gs(6))
        .backgroundColor('#F0D0A2')
        .opacity(0.75)
        .position({ x: this.gs(38), y: this.gs(188) })

      this.giftMother()
      this.giftDaughter()
      this.giftBox()
      this.giftHands()

      Text('✦')
        .fontSize(this.gs(9))
        .fontColor('#FFC24D')
        .position({ x: this.gs(140), y: this.gs(58) })
      Text('✦')
        .fontSize(this.gs(11))
        .fontColor('#FFC24D')
        .position({ x: this.gs(246), y: this.gs(54) })
      Text('✦')
        .fontSize(this.gs(7))
        .fontColor('#FFC24D')
        .position({ x: this.gs(262), y: this.gs(98) })
      Text('✦')
        .fontSize(this.gs(6))
        .fontColor('#FFC24D')
        .position({ x: this.gs(116), y: this.gs(52) })
    }
    .width('100%')
    .height(this.gs(BIKE_GIFT_ILLUSTRATION_HEIGHT))
    .position({ x: 0, y: this.gs(68) })
  }

  @Builder
  giftPoster() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({ angle: 170, colors: BIKE_GIFT_POSTER_COLORS })

      Row()
        .width(this.gs(240))
        .height(this.gs(240))
        .borderRadius(this.gs(120))
        .backgroundColor('#FFF0C6')
        .opacity(0.8)
        .position({ x: this.gs(160), y: this.gs(-90) })
      Row()
        .width(this.gs(180))
        .height(this.gs(180))
        .borderRadius(this.gs(90))
        .backgroundColor('#FFF8E6')
        .opacity(0.8)
        .position({ x: this.gs(-50), y: this.gs(120) })

      this.giftConfetti()
      this.giftTitle()
      this.giftIllustration()
    }
    .width('100%')
    .height(this.gs(BIKE_GIFT_POSTER_HEIGHT))
    .backgroundColor('#FFF4E1')
    .borderRadius(this.gs(22))
    .clip(true)
    .shadow({
      radius: this.gs(26),
      color: '#59000000',
      offsetX: 0,
      offsetY: this.gs(12)
    })
  }

  @Builder
  giftBuyButton() {
    Button() {
      Row({ space: this.gs(4) }) {
        Text('立即购卡')
          .fontSize(this.gs(19))
          .fontWeight(FontWeight.Bold)
          .fontColor('#3D2A0E')
      }
    }
    .width(this.gs(BIKE_GIFT_BUTTON_WIDTH))
    .height(this.gs(BIKE_GIFT_BUTTON_HEIGHT))
    .backgroundColor('#FFD400')
    .borderRadius(this.gs(BIKE_GIFT_BUTTON_HEIGHT / 2))
    .shadow({
      radius: this.gs(10),
      color: '#55D99B00',
      offsetX: 0,
      offsetY: this.gs(5)
    })
    .position({
      x: this.gs((BIKE_GIFT_POSTER_WIDTH - BIKE_GIFT_BUTTON_WIDTH) / 2),
      y: this.gs(BIKE_GIFT_POSTER_HEIGHT - BIKE_GIFT_BUTTON_OVERLAP)
    })
  }

  @Builder
  giftCloseButton() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(this.gs(BIKE_GIFT_CLOSE_SIZE))
        .height(this.gs(BIKE_GIFT_CLOSE_SIZE))
        .borderRadius(this.gs(BIKE_GIFT_CLOSE_SIZE / 2))
        .backgroundColor('#E6E3DC')
        .border({ width: this.gs(1), color: '#FFFFFF' })
        .shadow({
          radius: this.gs(8),
          color: '#33000000',
          offsetX: 0,
          offsetY: this.gs(2)
        })
      Text('✕')
        .fontSize(this.gs(17))
        .fontColor('#6E6A62')
    }
    .width(this.gs(BIKE_GIFT_CLOSE_SIZE))
    .height(this.gs(BIKE_GIFT_CLOSE_SIZE))
    .position({
      x: this.gs((BIKE_GIFT_POSTER_WIDTH - BIKE_GIFT_CLOSE_SIZE) / 2),
      y: this.gs(BIKE_GIFT_POSTER_HEIGHT + BIKE_GIFT_BUTTON_OVERLAP + BIKE_GIFT_CLOSE_GAP)
    })
    .onClick(() => {
      this.giftDialogVisible = false;
    })
  }

  @Builder
  giftDialog() {
    Stack({ alignContent: Alignment.TopStart }) {
      this.giftPoster()
      this.giftBuyButton()
      this.giftCloseButton()
    }
    .width(this.giftDialogWidthVp())
    .height(this.giftDialogHeightVp())
    .position({ x: this.giftDialogLeftVp(), y: this.giftDialogTopVp() })
    .hitTestBehavior(HitTestMode.Default)
  }

  @Builder
  giftOverlay() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#000000')
        .opacity(0.55)
        .onClick(() => {
          this.giftDialogVisible = false;
        })

      this.giftDialog()
    }
    .width('100%')
    .height('100%')
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        MeituanBikeScene({
          sceneScale: this.uiScale(),
          statusBarHeightVp: this.statusBarHeightVp,
          onBackTap: () => {
            this.pageStack.pop();
          }
        })

        Column() {
          MeituanBikeTabBar({
            onCouponTap: () => {
              this.giftDialogVisible = true;
            }
          })
        }
        .width('100%')
        .height(MEITUAN_BIKE_TAB_BAR_HEIGHT)
        .position({ x: 0, y: this.winHeightVp - MEITUAN_BIKE_TAB_BAR_HEIGHT })

        if (this.giftDialogVisible) {
          this.giftOverlay()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F7FA')
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
