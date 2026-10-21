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
 * 反例：留白过多 / 微博用户中心展开态两侧边距
 *
 * 复刻对象：微博「用户中心」页（莉莉丝梦境 · 稀缺装扮）：顶部粉色装扮横幅、蓝色「微博等级」
 *   卡片（用户名 / 立即解锁 / 专属标识徽章）、0.01 元会员条、「我的资产」三张横滑卡、
 *   「微博等级用户特权」2×2 卡片，底部「幸运制造局」横幅。
 *
 * 设计基准：参考截图 1264×1848px（单屏态）、1828×2584px（双屏态竖屏）、
 *   2584×1828px（双屏态横屏），密度 2.75，vp = px / 2.75。
 *   展开态下整页只有一列 1200px 宽（436.4vp）：横幅 571px → 207.6vp；
 *   蓝色卡片 581～1148px（高 206.2vp、圆角 8.7vp、左右各缩进 57px → 20.7vp）；
 *   专属标识面板 310×450px → 112.7×163.6vp；0.01 元条 120px → 43.6vp；
 *   资产卡 463×255px → 168.4×92.7vp、间距 20px → 7.3vp；
 *   特权卡 518×210px → 188.3×76.4vp、横向间距 35px → 12.7vp、纵向 45px → 16.4vp；
 *   底部横幅 189px → 68.7vp。展开态整列高度正好 2584px → 939.6vp。
 *
 * 三态实测：
 *   单屏态      459.6×672vp   —— 横幅与卡片铺满整宽，左右没有底色；
 *   双屏态竖屏  664.7×939.6vp —— 内容列 436.4vp 居中，左右各露出 114.2vp 的 #E2E2E2；
 *   双屏态横屏  939.6×664.7vp —— 内容列 436.4vp 居中，左右各露出 251.6vp 的 #E2E2E2。
 *
 * 问题表现：
 *   展开后横幅、等级卡、资产卡、特权卡全部缩在屏幕正中的一条窄列里，左右两侧是整条纯灰；
 *   竖屏时两侧空白合计 228.4vp（窗口宽的 34%），横屏时合计 503.2vp（窗口宽的 54%）；
 *   返回「‹」与右上「···」贴着窗口左右边缘，页面主体却停在中间，两段空白里没有任何内容。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 展开态下整页缩成的一列：实测 1200px → 436.4vp；单屏态窗口 1264px → 459.6vp */
const WSUC_STAGE_WIDTH: number = 436.4;
const WSUC_SINGLE_WIDTH: number = 459.6;

/** 两侧露出的系统底灰、页面白底 */
const WSUC_GUTTER_BG: string = '#E2E2E2';
const WSUC_PAGE_BG: string = '#FFFFFF';

/** 内容左右缩进 57px → 20.7vp */
const WSUC_CONTENT_PAD: number = 20.7;

/** 装扮横幅 571px → 207.6vp；横幅到等级卡 10px → 3.6vp */
const WSUC_BANNER_HEIGHT: number = 207.6;
const WSUC_CARD_GAP: number = 3.6;

/** 等级卡 567px → 206.2vp、圆角 24px → 8.7vp */
const WSUC_CARD_HEIGHT: number = 206.2;
const WSUC_CARD_RADIUS: number = 8.7;
const WSUC_CARD_TOP: string = '#1C6FA2';
const WSUC_CARD_BOTTOM: string = '#166697';
const WSUC_PANEL_BG: string = '#1C70A4';

/** 等级卡内：面板 310×450px → 112.7×163.6vp，距卡顶 59px → 21.5vp、距卡右 50px → 18.2vp */
const WSUC_PANEL_WIDTH: number = 112.7;
const WSUC_PANEL_HEIGHT: number = 163.6;
const WSUC_PANEL_TOP: number = 21.5;
const WSUC_PANEL_RIGHT: number = 18.2;

/** 卡内文案：用户名距卡顶 156px → 56.5vp 居中；按钮 545×115px → 198.2×41.8vp，距卡左 58px → 21.1vp */
const WSUC_NAME_TOP: number = 56.5;
const WSUC_BUTTON_WIDTH: number = 198.2;
const WSUC_BUTTON_HEIGHT: number = 41.8;
const WSUC_BUTTON_LEFT: number = 21.1;

/** 0.01 元条 120px → 43.6vp，距等级卡 29px → 10.5vp */
const WSUC_CREAM_HEIGHT: number = 43.6;
const WSUC_CREAM_GAP: number = 10.5;
const WSUC_CREAM_BG: string = '#FFEFDF';

/** 区块标题行：字 18vp、行高 26vp */
const WSUC_SECTION_TITLE_FONT: number = 18;
const WSUC_SECTION_TITLE_HEIGHT: number = 26;
const WSUC_TEXT_MAIN: string = '#1A1A1A';

/** 资产卡 463×255px → 168.4×92.7vp、间距 20px → 7.3vp、圆角 18px → 6.5vp */
const WSUC_ASSET_WIDTH: number = 168.4;
const WSUC_ASSET_HEIGHT: number = 92.7;
const WSUC_ASSET_GAP: number = 7.3;
const WSUC_ASSET_RADIUS: number = 6.5;
const WSUC_ASSET_BG: string = '#F8F8F8';

/** 特权卡 518×210px → 188.3×76.4vp、横向 35px → 12.7vp、纵向 45px → 16.4vp */
const WSUC_PRIV_HEIGHT: number = 76.4;
const WSUC_PRIV_GAP_H: number = 12.7;
const WSUC_PRIV_GAP_V: number = 16.4;

/** 底部「幸运制造局」横幅 189px → 68.7vp，距特权卡 35px → 12.7vp */
const WSUC_LUCKY_HEIGHT: number = 68.7;
const WSUC_LUCKY_GAP: number = 12.7;

/** 资产卡数据：图标位置按截图里卡片内的偏移量摆放 */
interface WSUC_AssetSpec {
  assetKey: string;
  assetTitle: string;
  assetUnit: string;
  assetIcon: Resource;
  assetIconW: number;
  assetIconH: number;
  assetIconX: number;
  assetIconY: number;
  assetChevron: boolean;
}

const WSUC_ASSETS: WSUC_AssetSpec[] = [
  {
    assetKey: 'ws-wb-asset-allowance',
    assetTitle: '我的津贴',
    assetUnit: '个',
    assetIcon: $r('app.media.ws_wb_sticker'),
    assetIconW: 85,
    assetIconH: 56,
    assetIconX: 76,
    assetIconY: 35,
    assetChevron: false
  },
  {
    assetKey: 'ws-wb-asset-makeup',
    assetTitle: '补签卡',
    assetUnit: '张',
    assetIcon: $r('app.media.ws_wb_coupon_blue'),
    assetIconW: 38,
    assetIconH: 42,
    assetIconX: 120,
    assetIconY: 46,
    assetChevron: true
  },
  {
    assetKey: 'ws-wb-asset-supertopic',
    assetTitle: '超话经验卡',
    assetUnit: '张',
    assetIcon: $r('app.media.ws_wb_coupon_green'),
    assetIconW: 18.2,
    assetIconH: 44.4,
    assetIconX: 46.2,
    assetIconY: 46,
    assetChevron: true
  }
];

/** 特权卡数据 */
interface WSUC_PrivSpec {
  privKey: string;
  privTitle: string;
  privDesc: string;
  privIcon: Resource;
}

const WSUC_PRIV_ROW_ONE: WSUC_PrivSpec[] = [
  {
    privKey: 'ws-wb-priv-badge',
    privTitle: '专属标识',
    privDesc: '高质用户标识外显',
    privIcon: $r('app.media.ws_wb_priv_badge')
  },
  {
    privKey: 'ws-wb-priv-activity',
    privTitle: '专属活动',
    privDesc: '专属活动抽奖机会',
    privIcon: $r('app.media.ws_wb_priv_star')
  }
];

const WSUC_PRIV_ROW_TWO: WSUC_PrivSpec[] = [
  {
    privKey: 'ws-wb-priv-trial',
    privTitle: '特权体验',
    privDesc: '优先特权体验卡',
    privIcon: $r('app.media.ws_wb_priv_plus')
  },
  {
    privKey: 'ws-wb-priv-coupon',
    privTitle: '优惠券包',
    privDesc: '领取购物券享实惠',
    privIcon: $r('app.media.ws_wb_priv_coupon')
  }
];

@Component
export struct WeiboUserCenterMarginsPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽度（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = 939.6;

  /** 窗口高度（vp），随折叠 / 旋转实时更新 */
  @State winHeightVp: number = 664.7;

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
      this.windowToken = WindowModeController.acquire(win, '#1A1A1A');
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  /** 页面主体的宽度：窗口比单屏更宽时，整页仍只占一列手机宽度 */
  private stageWidthVp(): number {
    return this.winWidthVp > WSUC_SINGLE_WIDTH + 0.5 ? WSUC_STAGE_WIDTH : this.winWidthVp;
  }

  // ------------------------------------------------------------------
  // 窗口级标题栏：右上「···」贴窗口右边
  // ------------------------------------------------------------------

  @Builder
  navOverlay() {
    Row() {
      Blank()

      Text('•••')
        .fontSize(14)
        .fontColor('#3B3B3B')
        .letterSpacing(3)
    }
    .width('100%')
    .height(34)
    .padding({ left: 11, right: 12 })
    .alignItems(VerticalAlign.Center)
    .margin({ top: 38 })
  }

  // ------------------------------------------------------------------
  // 顶部装扮横幅：单屏态页面标题压在横幅上，随页面一起滚走
  // ------------------------------------------------------------------

  @Builder
  bannerBlock() {
    Stack({ alignContent: Alignment.Top }) {
      Image($r('app.media.ws_wb_banner'))
        .width('100%')
        .height(WSUC_BANNER_HEIGHT)
        .objectFit(ImageFit.Cover)

      Text('用户中心')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor('#3A2B27')
        .maxLines(1)
        .margin({ top: 41 })
        .visibility(this.winWidthVp <= WSUC_SINGLE_WIDTH + 0.5 ? Visibility.Visible : Visibility.None)
    }
    .width('100%')
    .height(WSUC_BANNER_HEIGHT)
  }

  // ------------------------------------------------------------------
  // 蓝色「微博等级」卡
  // ------------------------------------------------------------------

  @Builder
  levelCard() {
    Stack({ alignContent: Alignment.TopStart }) {
      Row() {
        Column() {
          Text('用户8496601291')
            .fontSize(19)
            .lineHeight(30)
            .fontColor('#FFFFFF')
            .maxLines(1)
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ top: WSUC_NAME_TOP })

          Text('您还不是微博等级用户')
            .fontSize(12.5)
            .lineHeight(20)
            .fontColor('#C8E1F1')
            .maxLines(1)
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ top: 2 })

          Row() {
            Text('立即解锁')
              .fontSize(15)
              .fontColor('#1F3F52')
              .maxLines(1)
          }
          .width(WSUC_BUTTON_WIDTH)
          .height(WSUC_BUTTON_HEIGHT)
          .backgroundColor('#DFEFFE')
          .borderRadius(WSUC_BUTTON_HEIGHT / 2)
          .justifyContent(FlexAlign.Center)
          .margin({ left: WSUC_BUTTON_LEFT, top: 38 })
        }
        .layoutWeight(1)
        .height('100%')
        .alignItems(HorizontalAlign.Start)

        Stack({ alignContent: Alignment.Top }) {
          Column() {
            Image($r('app.media.ws_wb_badge'))
              .width(56)
              .height(58.2)
              .borderRadius(13)
              .margin({ top: 12, left: -9 })

            Text('专属标识')
              .fontSize(13)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .maxLines(1)
              .margin({ top: 4 })

            Text('点亮专属小徽章\n身份一眼就闪亮')
              .fontSize(11.5)
              .lineHeight(16)
              .fontColor('#D6E7F3')
              .textAlign(TextAlign.Center)
              .margin({ top: 14 })
          }
          .width('100%')
          .height('100%')
          .backgroundColor(WSUC_PANEL_BG)
          .borderRadius(6)
          .alignItems(HorizontalAlign.Center)

          Path()
            .width(33)
            .height(14.5)
            .commands('M0 40 L90 40 L45 0 Z')
            .fill('#166697')
            .strokeWidth(0)
            .margin({ top: WSUC_PANEL_HEIGHT - 14.5 })
        }
        .width(WSUC_PANEL_WIDTH)
        .height(WSUC_PANEL_HEIGHT)
        .margin({ top: WSUC_PANEL_TOP, right: WSUC_PANEL_RIGHT })
      }
      .width('100%')
      .height('100%')
      .alignItems(VerticalAlign.Top)

      Row() {
        Text('微博等级')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#22303A')
          .maxLines(1)

        Text('ⓘ')
          .fontSize(11)
          .fontColor('#8FA3B0')
          .margin({ left: 4 })
      }
      .width(84.7)
      .height(23)
      .padding({ left: 15.3 })
      .backgroundColor('#DAF0FE')
      .borderRadius({ topLeft: 8.7, topRight: 8.7, bottomLeft: 0, bottomRight: 8.7 })
      .alignItems(VerticalAlign.Center)
      .margin({ top: 3 })
    }
    .width('100%')
    .height(WSUC_CARD_HEIGHT)
    .borderRadius(WSUC_CARD_RADIUS)
    .linearGradient({ angle: 180, colors: [[WSUC_CARD_TOP, 0], [WSUC_CARD_BOTTOM, 1]] })
    .margin({ top: WSUC_CARD_GAP })
  }

  // ------------------------------------------------------------------
  // 0.01 元会员条
  // ------------------------------------------------------------------

  @Builder
  creamBanner() {
    Row() {
      Image($r('app.media.ws_wb_speaker'))
        .width(25.5)
        .height(24)
        .margin({ left: 13.8 })

      Text('0.01元领会员，额外送流量>>')
        .fontSize(15)
        .fontColor('#2E2E2E')
        .maxLines(1)
        .margin({ left: 12.7 })

      Blank()

      Image($r('app.media.ws_wb_arrow'))
        .width(21.8)
        .height(21.8)
        .margin({ right: 11.3 })
    }
    .width('100%')
    .height(WSUC_CREAM_HEIGHT)
    .backgroundColor(WSUC_CREAM_BG)
    .borderRadius(7)
    .alignItems(VerticalAlign.Center)
    .margin({ top: WSUC_CREAM_GAP })
  }

  // ------------------------------------------------------------------
  // 我的资产
  // ------------------------------------------------------------------

  @Builder
  assetCard(asset: WSUC_AssetSpec) {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        Row({ space: 2 }) {
          Text(asset.assetTitle)
            .fontSize(14.5)
            .fontColor(WSUC_TEXT_MAIN)
            .maxLines(1)

          if (asset.assetChevron) {
            Text('›')
              .fontSize(14.5)
              .fontColor('#6B6B6B')
          }
        }
        .alignItems(VerticalAlign.Center)

        Row({ space: 2 }) {
          Text('0')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(WSUC_TEXT_MAIN)

          Text(asset.assetUnit)
            .fontSize(11)
            .fontColor(WSUC_TEXT_MAIN)
            .margin({ bottom: 4 })
        }
        .alignItems(VerticalAlign.Bottom)
        .margin({ top: 4 })
      }
      .width('100%')
      .height('100%')
      .padding({ left: 12, top: 7.6 })
      .alignItems(HorizontalAlign.Start)

      Image(asset.assetIcon)
        .width(asset.assetIconW)
        .height(asset.assetIconH)
        .position({ x: asset.assetIconX, y: asset.assetIconY })
    }
    .width(WSUC_ASSET_WIDTH)
    .height(WSUC_ASSET_HEIGHT)
    .backgroundColor(WSUC_ASSET_BG)
    .borderRadius(WSUC_ASSET_RADIUS)
    .clip(true)
  }

  @Builder
  assetsTitle() {
    Text('我的资产')
      .fontSize(WSUC_SECTION_TITLE_FONT)
      .fontWeight(FontWeight.Bold)
      .fontColor(WSUC_TEXT_MAIN)
      .height(WSUC_SECTION_TITLE_HEIGHT)
      .margin({ top: 14.7 })
  }

  /** 资产卡横滑：从内容左缩进一直排到窗口右边，第三张卡被右边缘裁掉 */
  @Builder
  assetsScroller() {
    Scroll() {
      Row({ space: WSUC_ASSET_GAP }) {
        ForEach(WSUC_ASSETS, (asset: WSUC_AssetSpec) => {
          this.assetCard(asset)
        }, (asset: WSUC_AssetSpec) => asset.assetKey)
      }
      .height(WSUC_ASSET_HEIGHT)
    }
    .width('100%')
    .height(WSUC_ASSET_HEIGHT)
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .align(Alignment.Start)
    .padding({ left: WSUC_CONTENT_PAD })
    .margin({ top: 16.6 })
  }

  // ------------------------------------------------------------------
  // 微博等级用户特权
  // ------------------------------------------------------------------

  @Builder
  privCard(spec: WSUC_PrivSpec) {
    Row() {
      Image(spec.privIcon)
        .width(27.3)
        .height(27.3)
        .objectFit(ImageFit.Contain)

      Column({ space: 4 }) {
        Text(spec.privTitle)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(WSUC_TEXT_MAIN)
          .maxLines(1)

        Text(spec.privDesc)
          .fontSize(11)
          .fontColor('#8A8A8A')
          .maxLines(1)
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 6 })
    }
    .layoutWeight(1)
    .height(WSUC_PRIV_HEIGHT)
    .backgroundColor(WSUC_ASSET_BG)
    .borderRadius(6)
    .padding({ left: 16.4 })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  privilegeSection() {
    Row() {
      Text('微博等级用户特权')
        .fontSize(WSUC_SECTION_TITLE_FONT)
        .fontWeight(FontWeight.Bold)
        .fontColor(WSUC_TEXT_MAIN)
        .maxLines(1)

      Blank()

      Text('权益说明 ›')
        .fontSize(11)
        .fontColor('#7A7A7A')
        .maxLines(1)
    }
    .width('100%')
    .height(WSUC_SECTION_TITLE_HEIGHT)
    .alignItems(VerticalAlign.Center)
    .margin({ top: 28.5 })

    Row({ space: WSUC_PRIV_GAP_H }) {
      ForEach(WSUC_PRIV_ROW_ONE, (spec: WSUC_PrivSpec) => {
        this.privCard(spec)
      }, (spec: WSUC_PrivSpec) => spec.privKey)
    }
    .width('100%')
    .margin({ top: 12.8 })

    Row({ space: WSUC_PRIV_GAP_H }) {
      ForEach(WSUC_PRIV_ROW_TWO, (spec: WSUC_PrivSpec) => {
        this.privCard(spec)
      }, (spec: WSUC_PrivSpec) => spec.privKey)
    }
    .width('100%')
    .margin({ top: WSUC_PRIV_GAP_V })
  }

  // ------------------------------------------------------------------
  // 页面
  // ------------------------------------------------------------------

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        Row()
          .width('100%')
          .height('100%')
          .backgroundColor(WSUC_GUTTER_BG)

        Column() {
          Scroll() {
            Stack({ alignContent: Alignment.TopEnd }) {
              Column() {
                this.bannerBlock()

                Column() {
                  this.levelCard()

                  this.creamBanner()

                  this.assetsTitle()
                }
                .width('100%')
                .padding({ left: WSUC_CONTENT_PAD, right: WSUC_CONTENT_PAD })
                .alignItems(HorizontalAlign.Start)

                this.assetsScroller()

                Column() {
                  this.privilegeSection()
                }
                .width('100%')
                .padding({ left: WSUC_CONTENT_PAD, right: WSUC_CONTENT_PAD })
                .alignItems(HorizontalAlign.Start)

                Image($r('app.media.ws_wb_lucky'))
                  .width('100%')
                  .height(WSUC_LUCKY_HEIGHT)
                  .objectFit(ImageFit.Cover)
                  .margin({ top: WSUC_LUCKY_GAP })
              }
              .width('100%')

              /** 右侧橙色侧边条：钉在等级卡右侧的页面上，跟着页面一起滚走 */
              Row()
                .width(20)
                .height(120)
                .backgroundColor('#FFAC6A')
                .borderRadius({ topLeft: 10, bottomLeft: 10 })
                .margin({ top: 247.3 })
            }
            .width('100%')
          }
          .width('100%')
          .height('100%')
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.None)
          .align(Alignment.Top)
        }
        .width(this.stageWidthVp())
        .height('100%')
        .backgroundColor(WSUC_PAGE_BG)
        .clip(true)

        this.navOverlay()
      }
      .width('100%')
      .height('100%')
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
