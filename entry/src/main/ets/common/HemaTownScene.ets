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
 * 盒马小镇首页的公共底色与底部 TabBar。
 *
 * 首页的横向、纵向尺寸都以「单屏态 459.6vp 宽」为基准绘制，再按
 * sceneScale = 窗口宽度 / 459.6 等比放大，用来复现 H5 rem 适配在折叠屏展开态下的表现。
 * 多个案例页（签到弹层、我的菜单）共用这套底色，保证同一 App 的视觉一致。
 */

/** 底部原生 TabBar 高度（三种屏态下都保持在 84vp 左右） */
export const HEMA_TOWN_TAB_BAR_HEIGHT: number = 84;

@Component
export struct HemaTownScene {
  /** 窗口宽度 / 单屏态宽度（459.6vp），整页等比缩放比 */
  @Prop sceneScale: number = 1;

  /** 窗口高度（vp），用于决定展开态才出现的元素 */
  @Prop sceneHeightVp: number = 672;

  /** 大于 0 时按该高度渲染（首页 banner），0 表示铺满父容器（弹层页的整屏底色） */
  @Prop sceneViewportVp: number = 0;

  /** 是否在顶部栏里绘制「我的」按钮。首页需要让按钮固定、不随内容滚动时置 false */
  @Prop sceneMyEntryVisible: boolean = true;

  /** 点击右上角「我的」 */
  onMyTap: () => void = () => {
  };

  /** 把按单屏态（459.6vp）绘制的尺寸换算成当前窗口尺寸 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale;
  }

  private sceneHeight(): Length {
    return this.sceneViewportVp > 0 ? this.sceneViewportVp : '100%';
  }

  @Builder
  pageHeader() {
    Row() {
      Text('收盒花 得美味')
        .fontSize(this.vs(28))
        .fontWeight(FontWeight.Bold)
        .fontColor('#F4E3C5')

      Blank()

      if (this.sceneMyEntryVisible) {
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
        .onClick(() => {
          this.onMyTap();
        })
      }
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
      if (this.sceneHeightVp > 800) {
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
    .offset({ y: this.sceneHeightVp > 800 ? this.vs(145) : this.vs(120) })
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#7A96B8')

      this.heroScene()
      this.pageHeader()
    }
    .width('100%')
    .height(this.sceneHeight())
  }
}

@Component
export struct HemaTownTabBar {
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

  build() {
    Row() {
      this.tabItem($r('sys.symbol.house'), '首页', false, false)
      this.tabItem($r('sys.symbol.square_grid_2x2'), '分类', false, false)
      this.tabItem($r('sys.symbol.drop_fill'), '盒马小镇', true, false)
      this.tabItem($r('sys.symbol.cart'), '购物车', false, true)
      this.tabItem($r('sys.symbol.face_smiling'), '我的', false, false)
    }
    .width('100%')
    .height(HEMA_TOWN_TAB_BAR_HEIGHT)
    .padding({ top: 8 })
    .backgroundColor('#F4F5F7')
  }
}
