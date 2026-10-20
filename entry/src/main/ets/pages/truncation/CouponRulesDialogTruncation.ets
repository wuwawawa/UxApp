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
 * 反例：截断 / 美团神券「活动规则」弹窗截断
 *
 * 复刻美团神券页的活动规则弹窗：白色圆角弹窗里是「活动规则」标题、可滚动规则正文
 * 和底部粉红渐变「知道了」按钮，背后是深红色活动页（巨大「神券」水印、神券包 banner、
 * 神券包卡片、底部神券商品）和原生底部 TabBar。
 *
 * 弹窗尺寸按「窗口宽度 / 459.6vp」换算，背景页的卡片随窗口变宽：
 *   单屏态 459.6×672vp：弹窗 381×558vp，距顶部 24vp，完整显示；
 *   双屏态竖屏 664.7×939.6vp：弹窗 551×807vp，仍能完整显示；
 *   双屏态横屏 939.6×664.7vp：弹窗放大到 779×1140vp，比窗口高 475vp，
 *     顶部标题和底部按钮整体移出窗口，只剩正文中间一截，首行被窗口上沿切掉约 1/3 字高。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 弹窗缩放基准：单屏态窗口宽度（1264px / 2.75）；背景页按窗口宽度自适应，不做缩放 */
const COUPON_DIALOG_REFERENCE_WIDTH: number = 459.6;

/** 底部原生 TabBar 高度，三种屏态下都固定不变 */
const COUPON_TAB_BAR_HEIGHT: number = 77;

/** 弹窗内部设计尺寸（vp），均按 459.6vp 宽绘制 */
const COUPON_DIALOG_WIDTH: number = 381;
const COUPON_DIALOG_RADIUS: number = 16;
const COUPON_DIALOG_PADDING_X: number = 22;
const COUPON_TITLE_TOP: number = 15;
const COUPON_TITLE_LINE: number = 30;
const COUPON_TITLE_FONT: number = 22;
const COUPON_TITLE_TO_BODY: number = 33;
const COUPON_BODY_HEIGHT: number = 386;
const COUPON_BODY_FONT: number = 15;
const COUPON_BODY_LINE_HEIGHT: number = 24.7;
const COUPON_BODY_TO_BUTTON: number = 30;
const COUPON_BUTTON_HEIGHT: number = 48;
const COUPON_BUTTON_FONT: number = 17;
const COUPON_DIALOG_BOTTOM: number = 16;

/** 弹窗总高度：标题区 + 正文区 + 按钮 + 底部留白 = 558vp */
const COUPON_DIALOG_HEIGHT: number = COUPON_TITLE_TOP + COUPON_TITLE_LINE + COUPON_TITLE_TO_BODY +
  COUPON_BODY_HEIGHT + COUPON_BODY_TO_BUTTON + COUPON_BUTTON_HEIGHT + COUPON_DIALOG_BOTTOM;

/** 弹窗能完整放进窗口时，距离窗口顶部的间距 */
const COUPON_DIALOG_TOP: number = 24;

/**
 * 横屏溢出时，窗口上沿切在正文首行内的位置（按行高比例）。
 * 行盒内文字垂直居中，切掉 0.44 行 ≈ 切掉首行字高的 1/3。
 */
const COUPON_LANDSCAPE_CUT_LINE_RATIO: number = 0.44;

/** 活动规则正文（与截图一致的段落与缩进） */
const COUPON_RULES_TEXT: string = `1.活动时间：2026年10月1日00:00:00-2026年10月31日23:59:59，活动期间内每日均可参与，具体活动时间以活动页面展示为准。
2.活动城市：本活动仅限部分城市参与，具体活动城市、门店范围等以活动页面展示为准。若您无法看到相关活动，则证明您所在的区域不在活动区域内或您所在区域的活动已经结束。
3.参与方式：
　（1）每次膨胀需要消耗1张未膨胀的神券包红包，当存在多个不同有效期的神券包时，默认使用剩余有效期更短的神券包进行膨胀；（3）免费神券不支持参与该玩法
4.神券包规格与适用范围　（1）不同规格的神券包包含不同的红包张数和适用范围，对应的神券包售价也不同，具体神券包规格、实际售卖价格以购买界面展示为准；购买后系统自动发放，即刻到账；　（2）神券包根据类型不同可以在外卖餐饮商家、水果超市、美食团购、酒店（含出境酒店）、景点游玩、旅游度假、民宿、医美、休闲玩乐、丽人美发、医疗、生活服务、拍照写真、学习培训、结婚摄影、母婴服务、家居百货、数码电器等场景使用
5.其他说明：神券包内红包不可转赠、不可提现，逾期未使用自动失效；如发生退款，红包按原支付路径退回，有效期不变；活动过程中，如出现作弊、恶意刷单等违规行为，美团有权取消用户的参与资格并追回已发放的权益。`;

@Component
export struct CouponRulesDialogTruncationPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = COUPON_DIALOG_REFERENCE_WIDTH;
  @State winHeightVp: number = 672;

  /** 活动规则弹窗是否展示 */
  @State rulesDialogVisible: boolean = false;

  private pageActive: boolean = false;
  private windowToken: number = 0;

  aboutToAppear(): void {
    this.pageActive = true;
    this.enterImmersiveMode();
    // 进入页面即拉起弹窗
    setTimeout(() => {
      this.rulesDialogVisible = true;
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
      // 深红色活动页上用深色系统栏图标
      this.windowToken = WindowModeController.acquire(win, '#000000');
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  /** 弹窗等比放大比：窗口宽度 / 单屏态宽度 */
  private uiScale(): number {
    const widthRatio: number = this.winWidthVp / COUPON_DIALOG_REFERENCE_WIDTH;
    return widthRatio < 0.9 ? 0.9 : widthRatio;
  }

  /** 弹窗尺寸换算 */
  private ds(baseVp: number): number {
    return baseVp * this.uiScale();
  }

  private dialogLeftVp(): number {
    return (this.winWidthVp - this.ds(COUPON_DIALOG_WIDTH)) / 2;
  }

  /**
   * 弹窗顶部位置。
   * 高度没超出窗口时与顶部保持 24vp，完整露出标题与按钮；
   * 超出窗口时按正文首行位置摆放，顶部文字落在窗口上沿附近。
   */
  private dialogTopVp(): number {
    const dialogHeight: number = this.ds(COUPON_DIALOG_HEIGHT);
    if (dialogHeight + COUPON_DIALOG_TOP <= this.winHeightVp) {
      return COUPON_DIALOG_TOP;
    }
    const titleBlockHeight: number = COUPON_TITLE_TOP + COUPON_TITLE_LINE + COUPON_TITLE_TO_BODY;
    return -(this.ds(titleBlockHeight + COUPON_BODY_LINE_HEIGHT * COUPON_LANDSCAPE_CUT_LINE_RATIO));
  }

  @Builder
  heroWatermarks() {
    Text('神券')
      .fontSize(150)
      .fontWeight(FontWeight.Bold)
      .fontColor('#C0334F')
      .opacity(0.62)
      .rotate({ angle: -7 })
      .position({ x: -26, y: 4 })

    Text('神券')
      .fontSize(120)
      .fontWeight(FontWeight.Bold)
      .fontColor('#C0334F')
      .opacity(0.38)
      .rotate({ angle: 5 })
      .position({ x: 250, y: 84 })
  }

  @Builder
  promoBanner() {
    Row() {
      Column() {
        Row({ space: 6 }) {
          Text('神券包')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#3A1C0E')

          Text('膨胀')
            .fontSize(9)
            .fontColor('#7A3E12')
            .backgroundColor('#FFE2B8')
            .borderRadius(4)
            .padding({ left: 4, right: 4, top: 1, bottom: 1 })
        }
        .alignItems(VerticalAlign.Center)

        Text('每次膨胀随机得红包，越用越省')
          .fontSize(11)
          .fontColor('#9A6B4A')
          .margin({ top: 6 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text('›')
        .fontSize(24)
        .fontColor('#B08A6A')
    }
    .width(this.winWidthVp - 32)
    .height(116)
    .padding({ left: 18, right: 18 })
    .backgroundColor('#FFF7EC')
    .borderRadius(20)
    .position({ x: 16, y: 85 })
  }

  @Builder
  heroSection() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column()
        .width('100%')
        .height(210)
        .linearGradient({ angle: 180, colors: [['#FF1F45', 0], ['#D20E2C', 1]] })

      this.heroWatermarks()
      this.promoBanner()

      Text('•••')
        .fontSize(18)
        .fontColor(Color.White)
        .position({ x: this.winWidthVp - 46, y: 56 })
    }
    .width('100%')
    .height(210)
    .clip(true)
  }

  @Builder
  packageCard() {
    Column() {
      Row() {
        Text('神券包')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2A1408')

        Text('限时')
          .fontSize(9)
          .fontColor(Color.White)
          .backgroundColor('#FF3A5E')
          .borderRadius(4)
          .padding({ left: 5, right: 5, top: 1, bottom: 1 })
          .margin({ left: 6 })

        Blank()

        Text('规则')
          .fontSize(11)
          .fontColor('#9A7B62')
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Row({ space: 2 }) {
        Text('¥')
          .fontSize(15)
          .fontColor('#E23A2E')
          .margin({ top: 12 })

        Text('22')
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor('#E23A2E')

        Text('.8')
          .fontSize(15)
          .fontColor('#E23A2E')
          .margin({ top: 12 })

        Text('起')
          .fontSize(11)
          .fontColor('#9A7B62')
          .margin({ top: 14 })
      }
      .margin({ top: 6 })
      .alignItems(VerticalAlign.Top)

      Text('含 20 张红包，单张最高可膨胀至 40 元')
        .fontSize(10.5)
        .fontColor('#9A7B62')
        .margin({ top: 4 })

      Row() {
        Text('用券更省')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2A1408')

        Blank()

        Text('立即膨胀')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .backgroundColor('#FF1F4B')
          .borderRadius(16)
          .padding({ left: 14, right: 14, top: 7, bottom: 7 })
      }
      .width('100%')
      .margin({ top: 16 })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(18)
    .backgroundColor(Color.White)
    .borderRadius(20)
    .alignItems(HorizontalAlign.Start)
    .margin({ top: 40 })
  }

  @Builder
  couponCard(thresholdText: string) {
    Column() {
      Row() {
        Row({ space: 2 }) {
          Text('¥')
            .fontSize(11)
            .fontColor('#FF1F4B')
            .margin({ top: 6 })

          Text('20')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF1F4B')
        }
        .alignItems(VerticalAlign.Top)

        Blank()

        Text('神券')
          .fontSize(9)
          .fontColor(Color.White)
          .backgroundColor('#FF1F4B')
          .borderRadius(3)
          .padding({ left: 4, right: 4, top: 1, bottom: 1 })
      }
      .width('100%')

      Text('外卖 / 到店可用')
        .fontSize(10)
        .fontColor('#9A7B62')
        .margin({ top: 6 })

      Blank()

      Text(thresholdText)
        .fontSize(11)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FF3A6E')
        .width('100%')
        .textAlign(TextAlign.Center)
    }
    .layoutWeight(1)
    .height(110)
    .padding({ left: 14, right: 14, top: 14, bottom: 12 })
    .backgroundColor(Color.White)
    .borderRadius(16)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  couponEntryRow(entryTitle: string, entryDesc: string) {
    Row() {
      Row() {
        Text('神')
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
      }
      .width(34)
      .height(34)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#FFD400')
      .borderRadius(10)

      Column() {
        Text(entryTitle)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2A1408')

        Text(entryDesc)
          .fontSize(10.5)
          .fontColor('#9A7B62')
          .margin({ top: 3 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 10 })

      Text('领取')
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .backgroundColor('#FF1F4B')
        .borderRadius(14)
        .padding({ left: 12, right: 12, top: 5, bottom: 5 })
    }
    .width('100%')
    .height(58)
    .padding({ left: 12, right: 12 })
    .backgroundColor(Color.White)
    .borderRadius(14)
    .margin({ bottom: 10 })
  }

  @Builder
  moreCoupons() {
    Column() {
      Row() {
        Text('更多神券')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2A1408')

        Blank()

        Text('全部')
          .fontSize(11)
          .fontColor('#9A7B62')
      }
      .width('100%')
      .margin({ top: 26, bottom: 12 })

      this.couponEntryRow('外卖神券', '满30减8，限外卖商家使用')
      this.couponEntryRow('到店神券', '满100减15，限到店核销使用')
      this.couponEntryRow('酒店神券', '满300减30，限酒店预订使用')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  couponScene() {
    Column() {
      this.heroSection()

      Column() {
        this.packageCard()

        Row({ space: 12 }) {
          this.couponCard('满38可用')
          this.couponCard('满67可用')
        }
        .width('100%')
        .margin({ top: 20 })

        this.moreCoupons()
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 26 })
      .backgroundColor('#F6F1E8')
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F6F1E8')
    .alignItems(HorizontalAlign.Start)
    .clip(true)
  }

  @Builder
  tabIconHome() {
    SymbolGlyph($r('sys.symbol.house'))
      .fontSize(25)
      .fontColor(['#4A4A4A'])
  }

  @Builder
  tabIconTicket() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(26)
        .height(22)
        .borderRadius(5)
        .backgroundColor('#FFD400')
        .border({ width: 2, color: '#1A1A1A' })
        .rotate({ angle: -4 })

      Text('神')
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')
        .rotate({ angle: -4 })
    }
    .width(28)
    .height(24)
  }

  @Builder
  tabIconOrder() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(20)
        .height(20)
        .borderRadius(6)
        .border({ width: 1.6, color: '#4A4A4A' })

      Column({ space: 3 }) {
        Row()
          .width(10)
          .height(1.6)
          .backgroundColor('#4A4A4A')

        Row()
          .width(10)
          .height(1.6)
          .backgroundColor('#4A4A4A')
      }
    }
    .width(26)
    .height(24)
  }

  @Builder
  tabIconMine() {
    SymbolGlyph($r('sys.symbol.face_smiling'))
      .fontSize(25)
      .fontColor(['#4A4A4A'])
  }

  @Builder
  tabBar() {
    Row() {
      Column() {
        this.tabIconHome()
        Text('首页')
          .fontSize(11)
          .fontColor('#4A4A4A')
          .margin({ top: 3 })
      }
      .layoutWeight(1)
      .height('100%')
      .justifyContent(FlexAlign.Center)

      Column() {
        this.tabIconTicket()
        Text('神券')
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .margin({ top: 3 })
      }
      .layoutWeight(1)
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        // 关闭弹窗后再次点击「神券」页签即可重新拉起
        this.rulesDialogVisible = true;
      })

      Column() {
        this.tabIconOrder()
        Text('订单')
          .fontSize(11)
          .fontColor('#4A4A4A')
          .margin({ top: 3 })
      }
      .layoutWeight(1)
      .height('100%')
      .justifyContent(FlexAlign.Center)

      Column() {
        this.tabIconMine()
        Text('我的')
          .fontSize(11)
          .fontColor('#4A4A4A')
          .margin({ top: 3 })
      }
      .layoutWeight(1)
      .height('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height(COUPON_TAB_BAR_HEIGHT)
    .padding({ top: 7, bottom: 14 })
    .backgroundColor(Color.White)
    .position({ x: 0, y: this.winHeightVp - COUPON_TAB_BAR_HEIGHT })
  }

  @Builder
  homeIndicator() {
    Row()
      .width(134)
      .height(5)
      .borderRadius(2.5)
      .backgroundColor('#C9C9C9')
      .position({ x: (this.winWidthVp - 134) / 2, y: this.winHeightVp - 9 })
  }

  @Builder
  rulesDialog() {
    Column() {
      Text('活动规则')
        .fontSize(this.ds(COUPON_TITLE_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')
        .height(this.ds(COUPON_TITLE_LINE))
        .margin({ top: this.ds(COUPON_TITLE_TOP) })

      Scroll() {
        Text(COUPON_RULES_TEXT)
          .fontSize(this.ds(COUPON_BODY_FONT))
          .lineHeight(this.ds(COUPON_BODY_LINE_HEIGHT))
          .fontColor('#333333')
          .width('100%')
      }
      .width('100%')
      .height(this.ds(COUPON_BODY_HEIGHT))
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .margin({ top: this.ds(COUPON_TITLE_TO_BODY) })

      Row() {
        Text('知道了')
          .fontSize(this.ds(COUPON_BUTTON_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
      }
      .width('100%')
      .height(this.ds(COUPON_BUTTON_HEIGHT))
      .justifyContent(FlexAlign.Center)
      .linearGradient({ angle: 90, colors: [['#FF2E63', 0], ['#FF0B7E', 1]] })
      .borderRadius(this.ds(COUPON_BUTTON_HEIGHT / 2))
      .margin({ top: this.ds(COUPON_BODY_TO_BUTTON) })
      .onClick(() => {
        this.rulesDialogVisible = false;
      })
    }
    .width(this.ds(COUPON_DIALOG_WIDTH))
    .height(this.ds(COUPON_DIALOG_HEIGHT))
    .padding({ left: this.ds(COUPON_DIALOG_PADDING_X), right: this.ds(COUPON_DIALOG_PADDING_X) })
    .backgroundColor(Color.White)
    .borderRadius(this.ds(COUPON_DIALOG_RADIUS))
    .clip(true)
    .alignItems(HorizontalAlign.Center)
    .position({ x: this.dialogLeftVp(), y: this.dialogTopVp() })
  }

  @Builder
  rulesOverlay() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#000000')
        .opacity(0.8)

      this.rulesDialog()
    }
    .width('100%')
    .height('100%')
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        this.couponScene()

        if (this.rulesDialogVisible) {
          this.rulesOverlay()
        }

        // 原生 TabBar 固定在底部，压在遮罩之上，不随弹窗变暗
        this.tabBar()
        this.homeIndicator()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F6F1E8')
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
