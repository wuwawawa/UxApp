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
 * 美团骑车首页的公共底色与底部 TabBar。
 *
 * 与 HemaTownScene 一样，整页按「窗口宽度 / 459.6vp」等比放大（H5 rem 适配），
 * 用来复现折叠屏展开态下页面内容被窗口裁切的表现；底部 TabBar 保持原生固定高度。
 * 骑行卡赠送弹窗案例复用这套底色。
 */

/** 底部原生 TabBar 高度（三种屏态下都保持在 90vp 左右） */
export const MEITUAN_BIKE_TAB_BAR_HEIGHT: number = 90;

/** 首页各区块的设计高度（vp），均以 459.6vp 宽为基准 */
const BIKE_BANNER_HEIGHT: number = 178;
const BIKE_TABS_HEIGHT: number = 56;
const BIKE_MAP_HEIGHT: number = 200;
const BIKE_BLUETOOTH_HEIGHT: number = 34;
const BIKE_SCAN_BLOCK_HEIGHT: number = 84;

/** 顶部 banner 的天空 / 海面 / 扫码按钮渐变 */
const BIKE_SKY_COLORS: Array<[ResourceColor, number]> = [
  ['#8AD8FA', 0],
  ['#53B3EC', 0.58],
  ['#2E96DE', 1]
];
const BIKE_SEA_COLORS: Array<[ResourceColor, number]> = [
  ['#2AA0E0', 0],
  ['#1B84CA', 1]
];
const BIKE_SCAN_COLORS: Array<[ResourceColor, number]> = [
  ['#FFE851', 0],
  ['#FFD309', 1]
];

@Component
export struct MeituanBikeScene {
  /** 窗口宽度 / 单屏态宽度（459.6vp），整页等比缩放比 */
  @Prop sceneScale: number = 1;

  /** 沉浸式下状态栏高度，顶部导航条据此下移 */
  @Prop statusBarHeightVp: number = 34;

  /** 点击左上角返回 */
  onBackTap: () => void = () => {
  };

  /** 把按单屏态（459.6vp）绘制的尺寸换算成当前窗口尺寸 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale;
  }

  @Builder
  cloudBlob(x: number, y: number, cloudScale: number) {
    Stack({ alignContent: Alignment.TopStart }) {
      Row()
        .width(this.vs(46 * cloudScale))
        .height(this.vs(20 * cloudScale))
        .borderRadius(this.vs(10 * cloudScale))
        .backgroundColor('#E8FFFFFF')
        .position({ x: 0, y: this.vs(8 * cloudScale) })

      Row()
        .width(this.vs(26 * cloudScale))
        .height(this.vs(26 * cloudScale))
        .borderRadius(this.vs(13 * cloudScale))
        .backgroundColor('#F2FFFFFF')
        .position({ x: this.vs(10 * cloudScale), y: 0 })

      Row()
        .width(this.vs(20 * cloudScale))
        .height(this.vs(20 * cloudScale))
        .borderRadius(this.vs(10 * cloudScale))
        .backgroundColor('#DCFFFFFF')
        .position({ x: this.vs(28 * cloudScale), y: this.vs(2 * cloudScale) })
    }
    .width(this.vs(50 * cloudScale))
    .height(this.vs(28 * cloudScale))
    .position({ x: this.vs(x), y: this.vs(y) })
  }

  @Builder
  pageHeader() {
    Row() {
      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(this.vs(28))
          .fontColor([Color.White])
      }
      .width(this.vs(36))
      .height(this.vs(44))
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.onBackTap();
      })

      Text('美团骑车')
        .fontSize(this.vs(26))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .textShadow({ radius: this.vs(4), color: '#40000000', offsetX: 0, offsetY: this.vs(1) })
        .margin({ left: this.vs(2) })
    }
    .height(this.vs(44))
    .alignItems(VerticalAlign.Center)
    .position({ x: this.vs(10), y: this.statusBarHeightVp + this.vs(2) })
  }

  /** banner 右侧举旗的黄色吉祥物 */
  @Builder
  bannerMascot() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 旗杆与旗面
      Row()
        .width(this.vs(3))
        .height(this.vs(104))
        .backgroundColor('#DDEBF7')
        .rotate({ angle: 9 })
        .position({ x: this.vs(150), y: this.vs(2) })
      Row()
        .width(this.vs(56))
        .height(this.vs(26))
        .borderRadius(this.vs(4))
        .backgroundColor('#8FD36A')
        .rotate({ angle: 5 })
        .position({ x: this.vs(100), y: this.vs(8) })

      // 长耳朵
      Row()
        .width(this.vs(24))
        .height(this.vs(74))
        .borderRadius(this.vs(12))
        .backgroundColor('#FFD100')
        .rotate({ angle: -18 })
        .position({ x: this.vs(52), y: this.vs(16) })
      Row()
        .width(this.vs(24))
        .height(this.vs(72))
        .borderRadius(this.vs(12))
        .backgroundColor('#FFD100')
        .rotate({ angle: 22 })
        .position({ x: this.vs(88), y: this.vs(12) })

      // 身体
      Row()
        .width(this.vs(94))
        .height(this.vs(92))
        .borderRadius(this.vs(47))
        .backgroundColor('#FFD100')
        .position({ x: this.vs(30), y: this.vs(64) })

      // 举起的右手
      Row()
        .width(this.vs(18))
        .height(this.vs(46))
        .borderRadius(this.vs(9))
        .backgroundColor('#FFD100')
        .rotate({ angle: 42 })
        .position({ x: this.vs(18), y: this.vs(58) })
      Row()
        .width(this.vs(20))
        .height(this.vs(20))
        .borderRadius(this.vs(10))
        .backgroundColor('#FFD100')
        .position({ x: this.vs(4), y: this.vs(44) })

      // 墨镜
      Row()
        .width(this.vs(26))
        .height(this.vs(24))
        .borderRadius(this.vs(12))
        .backgroundColor('#171717')
        .position({ x: this.vs(54), y: this.vs(90) })
      Row()
        .width(this.vs(26))
        .height(this.vs(24))
        .borderRadius(this.vs(12))
        .backgroundColor('#171717')
        .position({ x: this.vs(84), y: this.vs(90) })
      Row()
        .width(this.vs(10))
        .height(this.vs(4))
        .backgroundColor('#171717')
        .position({ x: this.vs(78), y: this.vs(99) })

      // 大笑
      Row()
        .width(this.vs(36))
        .height(this.vs(16))
        .borderRadius(this.vs(8))
        .backgroundColor('#EF4B3E')
        .position({ x: this.vs(64), y: this.vs(122) })
      Row()
        .width(this.vs(24))
        .height(this.vs(4))
        .borderRadius(this.vs(2))
        .backgroundColor(Color.White)
        .position({ x: this.vs(70), y: this.vs(124) })
    }
    .width(this.vs(170))
    .height(this.vs(160))
    .position({ x: this.vs(280), y: this.vs(10) })
  }

  @Builder
  banner() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column()
        .width('100%')
        .height(this.vs(BIKE_BANNER_HEIGHT))
        .linearGradient({ angle: 180, colors: BIKE_SKY_COLORS })

      Row()
        .width(this.vs(150))
        .height(this.vs(150))
        .borderRadius(this.vs(75))
        .backgroundColor('#33FFFFFF')
        .position({ x: this.vs(246), y: this.vs(-52) })

      this.cloudBlob(140, 8, 0.9)
      this.cloudBlob(60, 20, 0.55)
      this.cloudBlob(252, 4, 0.6)
      this.cloudBlob(330, 12, 0.8)

      // 海面
      Row()
        .width('100%')
        .height(this.vs(80))
        .linearGradient({ angle: 180, colors: BIKE_SEA_COLORS })
        .position({ x: 0, y: this.vs(62) })
      Row()
        .width(this.vs(110))
        .height(this.vs(2))
        .backgroundColor('#66E9FBFF')
        .position({ x: this.vs(46), y: this.vs(90) })
      Row()
        .width(this.vs(70))
        .height(this.vs(2))
        .backgroundColor('#55E9FBFF')
        .position({ x: this.vs(238), y: this.vs(106) })
      Row()
        .width(this.vs(54))
        .height(this.vs(2))
        .backgroundColor('#44E9FBFF')
        .position({ x: this.vs(176), y: this.vs(122) })

      // 帆船
      Text('⛵')
        .fontSize(this.vs(18))
        .position({ x: this.vs(318), y: this.vs(64) })

      // 右侧沿海公路
      Row()
        .width(this.vs(430))
        .height(this.vs(58))
        .backgroundColor('#C9CDD5')
        .rotate({ angle: -17 })
        .position({ x: this.vs(150), y: this.vs(140) })
      Row()
        .width(this.vs(430))
        .height(this.vs(5))
        .backgroundColor('#FFFFFF')
        .opacity(0.7)
        .rotate({ angle: -17 })
        .position({ x: this.vs(150), y: this.vs(162) })

      // 草地
      Row()
        .width(this.vs(240))
        .height(this.vs(44))
        .borderRadius(this.vs(22))
        .backgroundColor('#7CCB5F')
        .position({ x: this.vs(240), y: this.vs(158) })

      this.bannerMascot()

      // 左侧主文案
      Text('世界粮食日')
        .fontSize(this.vs(33))
        .fontWeight(FontWeight.Bold)
        .fontStyle(FontStyle.Italic)
        .fontColor(Color.White)
        .textShadow({ radius: this.vs(5), color: '#40000000', offsetX: 0, offsetY: this.vs(2) })
        .position({ x: this.vs(24), y: this.vs(74) })

      Row({ space: this.vs(2) }) {
        Text('健康骑行')
          .fontSize(this.vs(26))
          .fontWeight(FontWeight.Bold)
          .fontStyle(FontStyle.Italic)
          .fontColor(Color.White)
          .textShadow({ radius: this.vs(5), color: '#40000000', offsetX: 0, offsetY: this.vs(2) })
        Text('赢好礼')
          .fontSize(this.vs(26))
          .fontWeight(FontWeight.Bold)
          .fontStyle(FontStyle.Italic)
          .fontColor('#FFE23D')
          .textShadow({ radius: this.vs(5), color: '#40000000', offsetX: 0, offsetY: this.vs(2) })
      }
      .position({ x: this.vs(24), y: this.vs(118) })

      Text('联合国世界粮食计划署x美团 骑行挑战赛')
        .fontSize(this.vs(9.5))
        .fontColor('#E8F6FF')
        .maxLines(1)
        .position({ x: this.vs(26), y: this.vs(156) })

      // 右上角品牌 logo
      Row({ space: this.vs(4) }) {
        Row() {
          Text('美团')
            .fontSize(this.vs(8))
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A')
        }
        .width(this.vs(22))
        .height(this.vs(22))
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#FFD100')
        .borderRadius(this.vs(5))

        Text('美团')
          .fontSize(this.vs(13))
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
          .textShadow({ radius: this.vs(3), color: '#33000000', offsetX: 0, offsetY: this.vs(1) })
      }
      .position({ x: this.vs(258), y: this.statusBarHeightVp + this.vs(10) })

      this.pageHeader()
    }
    .width('100%')
    .height(this.vs(BIKE_BANNER_HEIGHT))
    .clip(true)
  }

  @Builder
  tabItem(label: string, selected: boolean) {
    Stack({ alignContent: Alignment.Center }) {
      Text(label)
        .fontSize(this.vs(20))
        .fontWeight(FontWeight.Bold)
        .fontColor(selected ? '#151515' : '#454545')

      if (selected) {
        Row()
          .width(this.vs(34))
          .height(this.vs(5))
          .borderRadius(this.vs(2.5))
          .backgroundColor('#FFD400')
          .offset({ y: this.vs(20) })
      }
    }
    .layoutWeight(1)
    .height('100%')
  }

  @Builder
  tabStrip() {
    Row() {
      this.tabItem('单车', false)
      this.tabItem('电单车', true)
    }
    .width('100%')
    .height(this.vs(BIKE_TABS_HEIGHT))
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: this.vs(22), topRight: this.vs(22) })
  }

  @Builder
  parkingMarker(x: number, y: number) {
    Stack({ alignContent: Alignment.TopStart }) {
      Row()
        .width(this.vs(20))
        .height(this.vs(20))
        .borderRadius(this.vs(7))
        .backgroundColor('#2F8FE8')
        .border({ width: this.vs(1.5), color: Color.White })
      Text('P')
        .fontSize(this.vs(12))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .width(this.vs(20))
        .height(this.vs(20))
        .textAlign(TextAlign.Center)
      Row()
        .width(this.vs(6))
        .height(this.vs(7))
        .backgroundColor('#2F8FE8')
        .position({ x: this.vs(7), y: this.vs(18) })
    }
    .width(this.vs(20))
    .height(this.vs(25))
    .position({ x: this.vs(x), y: this.vs(y) })
  }

  @Builder
  bikeCluster() {
    Stack({ alignContent: Alignment.TopStart }) {
      Row()
        .width(this.vs(62))
        .height(this.vs(24))
        .borderRadius(this.vs(12))
        .backgroundColor('#FFD400')
        .opacity(0.95)
        .position({ x: this.vs(4), y: this.vs(4) })
      Row()
        .width(this.vs(40))
        .height(this.vs(18))
        .borderRadius(this.vs(9))
        .backgroundColor('#FFC400')
        .position({ x: this.vs(-4), y: this.vs(12) })

      SymbolGlyph($r('sys.symbol.bicycle'))
        .fontSize(this.vs(13))
        .fontColor(['#1F1F1F'])
        .position({ x: this.vs(8), y: this.vs(7) })
      SymbolGlyph($r('sys.symbol.bicycle'))
        .fontSize(this.vs(12))
        .fontColor(['#1F1F1F'])
        .position({ x: this.vs(26), y: this.vs(5) })
      SymbolGlyph($r('sys.symbol.bicycle'))
        .fontSize(this.vs(11))
        .fontColor(['#1F1F1F'])
        .position({ x: this.vs(44), y: this.vs(9) })
      SymbolGlyph($r('sys.symbol.bicycle'))
        .fontSize(this.vs(12))
        .fontColor(['#1F1F1F'])
        .position({ x: this.vs(16), y: this.vs(16) })
      SymbolGlyph($r('sys.symbol.bicycle'))
        .fontSize(this.vs(10))
        .fontColor(['#1F1F1F'])
        .position({ x: this.vs(36), y: this.vs(16) })
    }
    .width(this.vs(64))
    .height(this.vs(32))
    .position({ x: this.vs(178), y: this.vs(86) })
  }

  @Builder
  mapPin() {
    Stack({ alignContent: Alignment.TopStart }) {
      Row()
        .width(this.vs(5))
        .height(this.vs(24))
        .backgroundColor('#121212')
        .position({ x: this.vs(11), y: this.vs(20) })
      Row()
        .width(this.vs(24))
        .height(this.vs(24))
        .borderRadius(this.vs(12))
        .backgroundColor('#121212')
        .position({ x: this.vs(1), y: 0 })
      Row()
        .width(this.vs(9))
        .height(this.vs(9))
        .borderRadius(this.vs(4.5))
        .backgroundColor(Color.White)
        .position({ x: this.vs(8.5), y: this.vs(8) })
      Row()
        .width(this.vs(20))
        .height(this.vs(20))
        .borderRadius(this.vs(10))
        .backgroundColor('#2F8FE8')
        .border({ width: this.vs(3), color: Color.White })
        .position({ x: this.vs(3.5), y: this.vs(38) })
    }
    .width(this.vs(27))
    .height(this.vs(58))
    .position({ x: this.vs(206), y: this.vs(60) })
  }

  @Builder
  mapExpandButton() {
    Stack({ alignContent: Alignment.Center }) {
      SymbolGlyph($r('sys.symbol.arrow_up_left'))
        .fontSize(this.vs(13))
        .fontColor(['#1A1A1A'])
        .offset({ x: -this.vs(4), y: -this.vs(4) })
      SymbolGlyph($r('sys.symbol.arrow_down_left'))
        .fontSize(this.vs(13))
        .fontColor(['#1A1A1A'])
        .offset({ x: this.vs(4), y: this.vs(4) })
    }
    .width(this.vs(38))
    .height(this.vs(38))
    .backgroundColor(Color.White)
    .borderRadius(this.vs(12))
    .position({ x: this.vs(392), y: this.vs(12) })
  }

  @Builder
  mapCard() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#EAF2FC')
        .borderRadius(this.vs(16))

      // 河道
      Row()
        .width(this.vs(90))
        .height(this.vs(280))
        .backgroundColor('#BFE5FA')
        .rotate({ angle: 24 })
        .position({ x: this.vs(348), y: this.vs(-70) })

      // 道路
      Row()
        .width('100%')
        .height(this.vs(8))
        .backgroundColor('#FFFFFF')
        .position({ x: 0, y: this.vs(58) })
      Row()
        .width(this.vs(7))
        .height(this.vs(230))
        .backgroundColor('#FFFFFF')
        .position({ x: this.vs(96), y: this.vs(-10) })
      Row()
        .width(this.vs(280))
        .height(this.vs(7))
        .backgroundColor('#FFFFFF')
        .rotate({ angle: 21 })
        .position({ x: this.vs(190), y: this.vs(30) })
      Row()
        .width(this.vs(240))
        .height(this.vs(6))
        .backgroundColor('#FFFFFF')
        .rotate({ angle: -13 })
        .position({ x: this.vs(30), y: this.vs(150) })
      Row()
        .width(this.vs(7))
        .height(this.vs(170))
        .backgroundColor('#FFFFFF')
        .rotate({ angle: 9 })
        .position({ x: this.vs(300), y: this.vs(20) })

      // 建筑块
      Row()
        .width(this.vs(52))
        .height(this.vs(34))
        .borderRadius(this.vs(4))
        .backgroundColor('#DCE7F4')
        .position({ x: this.vs(140), y: this.vs(96) })
      Row()
        .width(this.vs(40))
        .height(this.vs(46))
        .borderRadius(this.vs(4))
        .backgroundColor('#DCE7F4')
        .position({ x: this.vs(330), y: this.vs(150) })
      Row()
        .width(this.vs(46))
        .height(this.vs(26))
        .borderRadius(this.vs(4))
        .backgroundColor('#DCE7F4')
        .position({ x: this.vs(20), y: this.vs(96) })
      Row()
        .width(this.vs(36))
        .height(this.vs(30))
        .borderRadius(this.vs(4))
        .backgroundColor('#DCE7F4')
        .position({ x: this.vs(240), y: this.vs(160) })

      // 地名
      Text('育田村')
        .fontSize(this.vs(11))
        .fontColor('#9BA9B8')
        .position({ x: this.vs(52), y: this.vs(12) })
      Text('西岑支路')
        .fontSize(this.vs(9.5))
        .fontColor('#9BA9B8')
        .position({ x: this.vs(26), y: this.vs(104) })
      Text('练秋湖')
        .fontSize(this.vs(9.5))
        .fontColor('#9BA9B8')
        .position({ x: this.vs(300), y: this.vs(108) })

      this.parkingMarker(68, 70)
      this.parkingMarker(160, 128)
      this.parkingMarker(330, 72)

      this.bikeCluster()
      this.mapPin()

      // 运营区提示气泡
      Row({ space: this.vs(6) }) {
        Stack({ alignContent: Alignment.Center }) {
          Row()
            .width(this.vs(16))
            .height(this.vs(16))
            .borderRadius(this.vs(8))
            .border({ width: this.vs(1.6), color: '#E5352B' })
          Text('!')
            .fontSize(this.vs(11))
            .fontWeight(FontWeight.Bold)
            .fontColor('#E5352B')
        }
        .width(this.vs(16))
        .height(this.vs(16))

        Text('在运营区边缘')
          .fontSize(this.vs(13.5))
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F1F1F')
      }
      .height(this.vs(36))
      .padding({ left: this.vs(12), right: this.vs(14) })
      .backgroundColor('#F7FFFFFF')
      .borderRadius(this.vs(14))
      .shadow({ radius: this.vs(8), color: '#1A000000', offsetX: 0, offsetY: this.vs(3) })
      .position({ x: this.vs(134), y: this.vs(16) })

      this.mapExpandButton()
    }
    .width(this.vs(443.6))
    .height(this.vs(BIKE_MAP_HEIGHT))
    .padding(this.vs(6))
    .backgroundColor(Color.White)
    .borderRadius(this.vs(18))
    .clip(true)
    .margin({ left: this.vs(8), right: this.vs(8) })
  }

  @Builder
  bluetoothTip() {
    Row({ space: this.vs(8) }) {
      Stack({ alignContent: Alignment.Center }) {
        Row()
          .width(this.vs(22))
          .height(this.vs(22))
          .borderRadius(this.vs(6))
          .backgroundColor('#2F8FE8')
        SymbolGlyph($r('sys.symbol.bluetooth'))
          .fontSize(this.vs(14))
          .fontColor([Color.White])
      }
      .width(this.vs(22))
      .height(this.vs(22))

      Text('未开启蓝牙服务，开启蓝牙，开锁更快')
        .fontSize(this.vs(12.5))
        .fontColor('#2F6FB0')
        .layoutWeight(1)

      Text('去开启')
        .fontSize(this.vs(12.5))
        .fontColor('#2F7BE0')
      Text('›')
        .fontSize(this.vs(14))
        .fontColor('#2F7BE0')
    }
    .width(this.vs(443.6))
    .height(this.vs(BIKE_BLUETOOTH_HEIGHT))
    .padding({ left: this.vs(10), right: this.vs(10) })
    .backgroundColor('#EFF7FF')
    .borderRadius(this.vs(10))
    .margin({ top: this.vs(16), left: this.vs(8), right: this.vs(8) })
  }

  @Builder
  scanEntry() {
    Column() {
      Row({ space: this.vs(8) }) {
        SymbolGlyph($r('sys.symbol.qrcode'))
          .fontSize(this.vs(22))
          .fontColor(['#3A2A10'])
        Text('扫码用车')
          .fontSize(this.vs(22))
          .fontWeight(FontWeight.Bold)
          .fontColor('#3A2A10')
      }
      .width('100%')
      .height(this.vs(52))
      .justifyContent(FlexAlign.Center)
      .linearGradient({ angle: 180, colors: BIKE_SCAN_COLORS })
      .borderRadius(this.vs(26))
    }
    .width(this.vs(435.6))
    .height(this.vs(BIKE_SCAN_BLOCK_HEIGHT))
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.White)
    .borderRadius(this.vs(20))
    .margin({ top: this.vs(14), left: this.vs(12), right: this.vs(12) })
  }

  build() {
    Column() {
      this.banner()
      this.tabStrip()
      this.mapCard()
      this.bluetoothTip()
      this.scanEntry()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
    .alignItems(HorizontalAlign.Start)
  }
}

@Component
export struct MeituanBikeTabBar {
  /** 点击「卡券」页签，重新拉起骑行卡弹窗 */
  onCouponTap: () => void = () => {
  };

  @Builder
  navIcon(symbol: Resource, label: string) {
    Column() {
      SymbolGlyph(symbol)
        .fontSize(24)
        .fontColor(['#1F1F1F'])
      Text(label)
        .fontSize(11)
        .fontColor('#1F1F1F')
        .margin({ top: 3 })
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Row() {
      Column() {
        Row() {
          Text('骑车')
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1A1A')
        }
        .width(48)
        .height(48)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#FFD400')
        .borderRadius(24)
      }
      .layoutWeight(1)
      .height('100%')
      .justifyContent(FlexAlign.Center)

      Column() {
        this.navIcon($r('sys.symbol.ticket_fill'), '卡券')
      }
      .layoutWeight(1)
      .height('100%')
      .onClick(() => {
        this.onCouponTap();
      })

      Column() {
        this.navIcon($r('sys.symbol.doc_text'), '订单')
      }
      .layoutWeight(1)
      .height('100%')

      Column() {
        this.navIcon($r('sys.symbol.face_smiling'), '我的')
      }
      .layoutWeight(1)
      .height('100%')
    }
    .width('100%')
    .height(MEITUAN_BIKE_TAB_BAR_HEIGHT)
    .padding({ top: 6, bottom: 16 })
    .backgroundColor(Color.White)
  }
}
