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
 * 反例：截断 / 京东用券规则弹窗截断（弹窗截断）
 *
 * 反例主题：用券规则弹窗最后一行规则与「知道了」按钮被弹窗下沿裁掉。
 *
 * 复刻对象：京东「订单详情」页 + 用券规则弹窗 —— 红色渐变头部（返回 + 订单详情 +
 *   客服）、「已支付 · 商家拣货中」状态条、白色订单卡（自营红标 + 商品占位图 +
 *   iPhone 商品行 + 商品金额 / 白条优惠 / 实付款）、「用券规则」入口；
 *   弹窗：标题「用券规则」+ 关闭叉、红色优惠券卡（¥40 / 满300可用 / 全品类通用 /
 *   有效期）、8 条规则行、底部红色「知道了」按钮；背后订单页被半透明遮罩压暗。
 *
 * 设计基准：以单屏折叠态窗口宽 459.6vp 为基准：
 *   弹窗宽 340vp（随窗口等比放大）、圆角 20vp、内边距 22vp；
 *   标题 18vp、优惠券卡高 84vp、券额 30vp；规则行文字 13vp、行高 19vp、行距 7vp；
 *   「知道了」按钮高 42vp、文字 15vp；订单卡头部 48vp、商品图 74vp。
 *
 * 三态实测：
 *   单屏态        459.6×672vp   —— 弹窗 340×500vp，内容高约 431vp，
 *                                 8 条规则与「知道了」按钮完整可见；
 *   双屏态竖屏    664.7×939.6vp —— 弹窗宽度放大到 491.6vp，但弹窗高度仍写死 500vp，
 *                                 规则行随窗口放大后内容高约 623vp，
 *                                 最后两条规则与「知道了」按钮被弹窗下沿裁掉；
 *   双屏态横屏    939.6×664.7vp —— 弹窗宽度放大到 695vp、高度仍是 500vp，
 *                                 内容高约 881vp，只剩标题、券卡与前两条规则，
 *                                 「知道了」按钮完全出框。
 *
 * 问题表现：
 *   弹窗高度按单屏基准写死（500vp），内部券卡、规则行、按钮却全部按窗口宽度
 *   等比放大；窗口一宽，内容总高远超弹窗高度，弹窗又开了 clip(true)，
 *   于是最后一行规则只剩半截、「知道了」按钮整体消失，用户无法关闭弹窗。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 缩放基准：单屏折叠态窗口宽度（1264px / 2.75） */
const JDC_BASE_WIDTH: number = 459.6;

/** 状态栏兜底高度（vp） */
const JDC_STATUS_BAR_FALLBACK: number = 32;

const JDC_PAGE_BG: string = '#F4F4F4';
const JDC_HEADER_START: string = '#F23030';
const JDC_HEADER_END: string = '#E93B3D';
const JDC_RED: string = '#E1251B';
const JDC_RED_LIGHT: string = '#FFF1F0';
const JDC_TEXT_MAIN: string = '#111111';
const JDC_TEXT_SUB: string = '#888888';
const JDC_TEXT_LIGHT: string = '#BBBBBB';

/** 头部：标题行 44vp、标题 18vp、返回箭头 24vp、状态条高 52vp */
const JDC_TITLE_ROW_HEIGHT: number = 44;
const JDC_TITLE_FONT: number = 18;
const JDC_BACK_FONT: number = 24;
const JDC_STATUS_STRIP_HEIGHT: number = 52;

/** 订单卡：留白 12vp、圆角 14vp、内边距 14vp、商品图 74vp */
const JDC_CARD_INSET: number = 12;
const JDC_CARD_RADIUS: number = 14;
const JDC_CARD_PAD: number = 14;
const JDC_GOODS_PIC: number = 74;

/** 弹窗：宽 340vp（随窗口放大）、高 500vp（写死，反例根源）、圆角 20vp、内边距 22vp */
const JDC_DIALOG_WIDTH: number = 340;
const JDC_DIALOG_HEIGHT: number = 500;
const JDC_DIALOG_RADIUS: number = 20;
const JDC_DIALOG_PAD: number = 22;

/** 弹窗内：标题 18vp、关闭叉 18vp、券卡高 84vp、券额 30vp、券名 15vp */
const JDC_DIALOG_TITLE_FONT: number = 18;
const JDC_CLOSE_FONT: number = 18;
const JDC_COUPON_CARD_HEIGHT: number = 84;
const JDC_COUPON_AMOUNT_FONT: number = 30;
const JDC_COUPON_NAME_FONT: number = 15;

/** 规则行：文字 13vp、行高 19vp、行距 7vp；按钮高 42vp、文字 15vp */
const JDC_RULE_FONT: number = 13;
const JDC_RULE_LINE_HEIGHT: number = 19;
const JDC_RULE_GAP: number = 7;
const JDC_BUTTON_HEIGHT: number = 42;
const JDC_BUTTON_FONT: number = 15;

/** 底部 TabBar 高度（固定，不随窗口放大） */
const JDC_TAB_BAR_HEIGHT: number = 56;

/** 用券规则行数据 */
interface JdCouponRuleItem {
  ruleText: string;
}

const JDC_RULE_LIST: JdCouponRuleItem[] = [
  { ruleText: '1. 本券仅限在京东APP下单购买实物商品时使用' },
  { ruleText: '2. 单笔订单仅可使用一张优惠券，不可拆分使用' },
  { ruleText: '3. 优惠券不可抵扣运费、保价费及上门服务费' },
  { ruleText: '4. 使用优惠券的订单若发生退款，券不予退还' },
  { ruleText: '5. 本券不可与秒杀、拼购及预售活动叠加使用' },
  { ruleText: '6. 同一账号每月最多可领取5张同类型优惠券' },
  { ruleText: '7. 优惠券请在有效期内使用，过期自动作废' },
  { ruleText: '8. 券使用规则以京东平台页面展示为准' }
];

/** 订单金额行 */
interface JdOrderPriceItem {
  priceLabel: string;
  priceValue: string;
  priceEmphasis: boolean;
}

const JDC_ORDER_PRICES: JdOrderPriceItem[] = [
  { priceLabel: '商品金额', priceValue: '¥8999.00', priceEmphasis: false },
  { priceLabel: '白条优惠', priceValue: '-¥100.00', priceEmphasis: false },
  { priceLabel: '实付款', priceValue: '¥8899.00', priceEmphasis: true }
];

@Component
export struct JdCouponDialogTruncationPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = JDC_BASE_WIDTH;
  @State winHeightVp: number = 672;
  /** 沉浸式下的状态栏高度（vp） */
  @State statusBarHeightVp: number = JDC_STATUS_BAR_FALLBACK;

  /** 用券规则弹窗是否展示 */
  @State rulesDialogVisible: boolean = false;

  private pageActive: boolean = false;
  private windowToken: number = 0;

  aboutToAppear(): void {
    this.pageActive = true;
    this.enterImmersiveMode();
    // 进入页面即拉起用券规则弹窗
    setTimeout(() => {
      this.rulesDialogVisible = true;
    }, 600);
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
      this.windowToken = WindowModeController.acquire(win, JDC_HEADER_START);
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  /** 场景缩放比：当前窗口宽 / 单屏折叠态基准宽 */
  private sceneScale(): number {
    return this.winWidthVp / JDC_BASE_WIDTH;
  }

  /** 把基准宽下的设计值换算到当前窗口宽度 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  /** 头部标题行：返回 + 订单详情 + 客服 */
  @Builder
  orderTitleBar() {
    Stack({ alignContent: Alignment.Center }) {
      Text('订单详情')
        .fontSize(this.vs(JDC_TITLE_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)

      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(this.vs(JDC_BACK_FONT))
          .fontColor([Color.White])
          .onClick(() => {
            this.pageStack.pop();
          })

        Blank()

        SymbolGlyph($r('sys.symbol.headphones'))
          .fontSize(this.vs(20))
          .fontColor([Color.White])
      }
      .width('100%')
      .padding({ left: this.vs(12), right: this.vs(12) })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(this.vs(JDC_TITLE_ROW_HEIGHT))
  }

  /** 状态条 */
  @Builder
  orderStatusStrip() {
    Row() {
      Column() {
        SymbolGlyph($r('sys.symbol.doc_text'))
          .fontSize(this.vs(16))
          .fontColor([Color.White])
      }
      .width(this.vs(28))
      .height(this.vs(28))
      .justifyContent(FlexAlign.Center)
      .backgroundColor('rgba(255,255,255,0.25)')
      .borderRadius(this.vs(14))

      Column() {
        Text('已支付 · 商家拣货中')
          .fontSize(this.vs(16))
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)

        Text('您的商品由京东仓配一体服务发出，请耐心等待')
          .fontSize(this.vs(12))
          .fontColor('rgba(255,255,255,0.9)')
          .maxLines(1)
          .margin({ top: this.vs(3) })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: this.vs(10) })
    }
    .width('100%')
    .height(this.vs(JDC_STATUS_STRIP_HEIGHT))
    .padding({ left: this.vs(14), right: this.vs(14) })
    .alignItems(VerticalAlign.Center)
  }

  /** 商品占位图：红色渐变块 + 手机图标（无图片资源） */
  @Builder
  goodsPic() {
    Column() {
      SymbolGlyph($r('sys.symbol.creditcard'))
        .fontSize(this.vs(26))
        .fontColor(['rgba(255,255,255,0.85)'])
    }
    .width(this.vs(JDC_GOODS_PIC))
    .height(this.vs(JDC_GOODS_PIC))
    .justifyContent(FlexAlign.Center)
    .linearGradient({ angle: 135, colors: [['#FF7A6B', 0], [JDC_RED, 1]] })
    .borderRadius(this.vs(8))
  }

  @Builder
  orderPriceRow(price: JdOrderPriceItem) {
    Row() {
      Text(price.priceLabel)
        .fontSize(this.vs(13))
        .fontColor(JDC_TEXT_SUB)

      Blank()

      Text(price.priceValue)
        .fontSize(this.vs(price.priceEmphasis ? 17 : 14))
        .fontWeight(price.priceEmphasis ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(price.priceEmphasis ? JDC_RED : JDC_TEXT_MAIN)
    }
    .width('100%')
    .height(this.vs(price.priceEmphasis ? 30 : 26))
    .alignItems(VerticalAlign.Center)
  }

  /** 订单卡：自营标 + 商品行 + 金额行 + 用券规则入口 */
  @Builder
  orderCard() {
    Column() {
      Row() {
        Text('自营')
          .fontSize(this.vs(10))
          .fontColor(Color.White)
          .backgroundColor(JDC_RED)
          .borderRadius(this.vs(3))
          .padding({ left: this.vs(4), right: this.vs(4), top: this.vs(1), bottom: this.vs(1) })

        Text('京东自营 · 妥投无忧')
          .fontSize(this.vs(13))
          .fontWeight(FontWeight.Bold)
          .fontColor(JDC_TEXT_MAIN)
          .margin({ left: this.vs(6) })

        Blank()

        Text('用券规则')
          .fontSize(this.vs(12))
          .fontColor(JDC_RED)
          .onClick(() => {
            // 重新拉起规则弹窗，便于反复观察截断
            this.rulesDialogVisible = true;
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Row() {
        this.goodsPic()

        Column() {
          Text('Apple iPhone 17 Pro 256GB 原色钛金属 全网通5G双卡双待手机')
            .fontSize(this.vs(14))
            .fontColor(JDC_TEXT_MAIN)
            .maxLines(2)
            .lineHeight(this.vs(19))

          Text('原色钛金属 / 256GB / 官方标配')
            .fontSize(this.vs(12))
            .fontColor(JDC_TEXT_LIGHT)
            .backgroundColor('#F5F5F5')
            .borderRadius(this.vs(3))
            .padding({ left: this.vs(6), right: this.vs(6), top: this.vs(2), bottom: this.vs(2) })
            .margin({ top: this.vs(6) })
            .alignSelf(ItemAlign.Start)

          Row() {
            Text('¥8999.00')
              .fontSize(this.vs(16))
              .fontWeight(FontWeight.Bold)
              .fontColor(JDC_TEXT_MAIN)

            Blank()

            Text('x1')
              .fontSize(this.vs(12))
              .fontColor(JDC_TEXT_SUB)
          }
          .width('100%')
          .margin({ top: this.vs(8) })
          .alignItems(VerticalAlign.Center)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: this.vs(10) })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
      .margin({ top: this.vs(12) })

      Column() {
        ForEach(JDC_ORDER_PRICES, (price: JdOrderPriceItem) => {
          this.orderPriceRow(price)
        }, (price: JdOrderPriceItem) => price.priceLabel)
      }
      .width('100%')
      .margin({ top: this.vs(10) })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(this.vs(JDC_CARD_PAD))
    .backgroundColor(Color.White)
    .borderRadius(this.vs(JDC_CARD_RADIUS))
    .margin({ left: this.vs(JDC_CARD_INSET), right: this.vs(JDC_CARD_INSET), top: this.vs(12), bottom: this.vs(12) })
    .alignItems(HorizontalAlign.Start)
  }

  /** 底部 TabBar（固定高度，不随窗口放大） */
  @Builder
  tabBar() {
    Row() {
      Column() {
        SymbolGlyph($r('sys.symbol.house'))
          .fontSize(this.vs(22))
          .fontColor(['#4A4A4A'])

        Text('首页')
          .fontSize(this.vs(11))
          .fontColor('#4A4A4A')
          .margin({ top: this.vs(3) })
      }
      .layoutWeight(1)
      .height('100%')
      .justifyContent(FlexAlign.Center)

      Column() {
        SymbolGlyph($r('sys.symbol.square_grid_2x2'))
          .fontSize(this.vs(22))
          .fontColor(['#4A4A4A'])

        Text('分类')
          .fontSize(this.vs(11))
          .fontColor('#4A4A4A')
          .margin({ top: this.vs(3) })
      }
      .layoutWeight(1)
      .height('100%')
      .justifyContent(FlexAlign.Center)

      Column() {
        SymbolGlyph($r('sys.symbol.cart'))
          .fontSize(this.vs(22))
          .fontColor(['#4A4A4A'])

        Text('购物车')
          .fontSize(this.vs(11))
          .fontColor('#4A4A4A')
          .margin({ top: this.vs(3) })
      }
      .layoutWeight(1)
      .height('100%')
      .justifyContent(FlexAlign.Center)

      Column() {
        SymbolGlyph($r('sys.symbol.person'))
          .fontSize(this.vs(22))
          .fontColor(['#4A4A4A'])

        Text('我的')
          .fontSize(this.vs(11))
          .fontColor('#4A4A4A')
          .margin({ top: this.vs(3) })
      }
      .layoutWeight(1)
      .height('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height(JDC_TAB_BAR_HEIGHT)
    .backgroundColor(Color.White)
    .position({ x: 0, y: this.winHeightVp - JDC_TAB_BAR_HEIGHT })
  }

  /** 弹窗内的优惠券卡：红底券额 + 券名 / 有效期 */
  @Builder
  dialogCouponCard() {
    Row() {
      Column() {
        Row({ space: this.vs(2) }) {
          Text('¥')
            .fontSize(this.vs(16))
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .margin({ top: this.vs(8) })

          Text('40')
            .fontSize(this.vs(JDC_COUPON_AMOUNT_FONT))
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
        }
        .alignItems(VerticalAlign.Top)

        Text('满300可用')
          .fontSize(this.vs(11))
          .fontColor('rgba(255,255,255,0.9)')
          .margin({ top: this.vs(2) })
      }
      .justifyContent(FlexAlign.Center)
      .layoutWeight(1)
      .height('100%')

      Column() {
        Text('全品类通用优惠券')
          .fontSize(this.vs(JDC_COUPON_NAME_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(JDC_TEXT_MAIN)

        Text('有效期 2026.10.22 - 2026.11.11')
          .fontSize(this.vs(11))
          .fontColor(JDC_TEXT_SUB)
          .margin({ top: this.vs(5) })

        Text('全品类实物商品可用（不含运费）')
          .fontSize(this.vs(10))
          .fontColor(JDC_TEXT_LIGHT)
          .margin({ top: this.vs(3) })
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
      .layoutWeight(1.6)
      .height('100%')
    }
    .width('100%')
    .height(this.vs(JDC_COUPON_CARD_HEIGHT))
    .borderRadius(this.vs(10))
    .backgroundColor(JDC_RED_LIGHT)
    .border({ width: this.vs(1), color: JDC_RED })
    .clip(false)
  }

  @Builder
  dialogRuleRow(rule: JdCouponRuleItem) {
    Row() {
      Row()
        .width(this.vs(4))
        .height(this.vs(4))
        .borderRadius(this.vs(2))
        .backgroundColor(JDC_RED)
        .margin({ top: this.vs(JDC_RULE_LINE_HEIGHT / 2 - 2), right: this.vs(8) })

      Text(rule.ruleText)
        .fontSize(this.vs(JDC_RULE_FONT))
        .lineHeight(this.vs(JDC_RULE_LINE_HEIGHT))
        .fontColor('#444444')
        .maxLines(1)
        .layoutWeight(1)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
    .margin({ top: this.vs(JDC_RULE_GAP) })
  }

  /** 用券规则弹窗：宽度随窗口放大、高度写死 500vp（反例核心） */
  @Builder
  rulesDialog() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column() {
        Text('用券规则')
          .fontSize(this.vs(JDC_DIALOG_TITLE_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(JDC_TEXT_MAIN)
          .height(this.vs(26))
          .margin({ top: this.vs(16) })
          .alignSelf(ItemAlign.Center)

        this.dialogCouponCard()

        Column() {
          ForEach(JDC_RULE_LIST, (rule: JdCouponRuleItem) => {
            this.dialogRuleRow(rule)
          }, (rule: JdCouponRuleItem) => rule.ruleText)
        }
        .width('100%')
        .margin({ top: this.vs(14) })
        .alignItems(HorizontalAlign.Start)

        Row() {
          Text('知道了')
            .fontSize(this.vs(JDC_BUTTON_FONT))
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
        }
        .width('100%')
        .height(this.vs(JDC_BUTTON_HEIGHT))
        .justifyContent(FlexAlign.Center)
        .backgroundColor(JDC_RED)
        .borderRadius(this.vs(JDC_BUTTON_HEIGHT / 2))
        .margin({ top: this.vs(16) })
        .onClick(() => {
          this.rulesDialogVisible = false;
        })
      }
      .width('100%')
      .height(JDC_DIALOG_HEIGHT)
      .padding({ left: this.vs(JDC_DIALOG_PAD), right: this.vs(JDC_DIALOG_PAD) })
      .backgroundColor(Color.White)
      .borderRadius(this.vs(JDC_DIALOG_RADIUS))
      .clip(true)
      .alignItems(HorizontalAlign.Start)

      SymbolGlyph($r('sys.symbol.xmark'))
        .fontSize(this.vs(JDC_CLOSE_FONT))
        .fontColor(['#999999'])
        .margin({ top: this.vs(16), right: this.vs(16) })
        .onClick(() => {
          this.rulesDialogVisible = false;
        })
    }
    .width(this.vs(JDC_DIALOG_WIDTH))
    .height(JDC_DIALOG_HEIGHT)
  }

  /** 遮罩 + 弹窗 */
  @Builder
  rulesOverlay() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#000000')
        .opacity(0.55)
        .onClick(() => {
          this.rulesDialogVisible = false;
        })

      this.rulesDialog()
    }
    .width('100%')
    .height('100%')
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        Column() {
          Column() {
            this.orderTitleBar()
            this.orderStatusStrip()
          }
          .width('100%')
          .linearGradient({ angle: 180, colors: [[JDC_HEADER_START, 0], [JDC_HEADER_END, 1]] })
          .padding({ top: this.statusBarHeightVp })

          Scroll() {
            Column() {
              this.orderCard()
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .align(Alignment.Top)
          .backgroundColor(JDC_PAGE_BG)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(JDC_PAGE_BG)

        if (this.rulesDialogVisible) {
          this.rulesOverlay()
        }

        this.tabBar()
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
