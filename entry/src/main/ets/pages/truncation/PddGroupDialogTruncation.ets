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
 * 反例：截断 / 拼多多拼单结果弹窗截断（弹窗截断）
 *
 * 复刻对象：拼多多「商品详情」页上的拼单结果弹窗 —— 红色商品头（返回 + 商品详情 + 分享）、
 *   渐变商品图占位、红色价格行（¥39.9 · 已拼1.2万+件）、两行商品标题、服务标签行、
 *   底部「客服 / 收藏 / 购物车 + 单独购买¥59.9 / 参团购买¥39.9」操作条；
 *   弹窗内自上而下为：拼单成功横幅、商品行（缩略图 + 标题 + 价格数量）、
 *   5 个参团成员头像位（2 人已参团 + 3 个虚线空位）、
 *   倒计时行（还剩 01:23:45 结束）、「邀请好友参团」大按钮。
 *
 * 设计基准（vp，按单屏态 459.6vp 宽绘制）：弹窗宽 88%、高为设计稿照抄的定值 352vp；
 *   弹窗内横幅 50vp、商品行 72vp、成员行 70vp、倒计时行 40vp、按钮 48vp、间距 10~12vp；
 *   商品图占位高 200vp、价格 26vp 字、标题 14vp 字两行、服务标签 10vp 字；操作条高 52vp。
 *
 * 三态实测：
 *   单屏态        459.6vp 宽 —— sceneScale 1.00，弹窗内容约 348vp 刚好装进 352vp 定高，完整显示；
 *   双屏态竖屏    664.7vp 宽 —— sceneScale 1.45，内容撑到约 504vp，倒计时行只剩上沿一条缝、
 *                              「邀请好友参团」按钮整体被弹窗下沿裁掉；
 *   双屏态横屏    939.6vp 宽 —— sceneScale 2.04，内容约 711vp，成员行下半截、
 *                              倒计时行与邀请按钮全部被裁掉。
 *
 * 问题表现：
 *   弹窗高度是设计稿里的固定值 352vp，没有随窗口宽度放大；而弹窗内的横幅、商品行、
 *   成员位、倒计时行与按钮全部按 sceneScale 放大 —— 宽窗口下内容总高远超弹窗定高，
 *   倒计时行与「邀请好友参团」按钮被弹窗下沿裁掉，看不到还剩多久、也点不到邀请入口。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 单屏态折叠屏基准宽度（vp），sceneScale 以它为 1.0 */
const PDD_DIALOG_BASE_WIDTH: number = 459.6;

/** 状态栏 / 底部手势区兜底高度（vp） */
const PDD_STATUS_BAR_FALLBACK: number = 34;
const PDD_BOTTOM_INSET_FALLBACK: number = 8;

/** 弹窗定高：设计稿照抄的固定值（vp），不随窗口放大 —— 反例根源 */
const PDD_DIALOG_FIXED_HEIGHT: number = 352;

const PDD_PAGE_RED: string = '#E02E24';
const PDD_PAGE_RED_DEEP: string = '#C4251D';
const PDD_PAGE_BG: string = '#F5F5F5';
const PDD_TITLE_TEXT: string = '#333333';
const PDD_SUB_TEXT: string = '#999999';
const PDD_CARD_WHITE: string = '#FFFFFF';
const PDD_SERVICE_BG: string = '#FFF0EC';
const PDD_SERVICE_TEXT: string = '#D0503F';
const PDD_COUNTDOWN_BG: string = '#FFF1EC';
const PDD_COUNTDOWN_TEXT: string = '#E8593C';
const PDD_EMPTY_SLOT: string = '#D8D8D8';
const PDD_AVATAR_ORANGE: string = '#FF9A3C';
const PDD_TAG_BLUE: string = '#4A90D9';

/** 拼单成员：前 2 位已参团，后 3 位是虚线空位 */
interface PddGroupMember {
  memberKey: string;
  memberName: string;
  joinedFlag: boolean;
}

const PDD_GROUP_MEMBERS: PddGroupMember[] = [
  { memberKey: 'pdd-mine', memberName: '我', joinedFlag: true },
  { memberKey: 'pdd-friend-1', memberName: '水果控', joinedFlag: true },
  { memberKey: 'pdd-slot-1', memberName: '虚位以待', joinedFlag: false },
  { memberKey: 'pdd-slot-2', memberName: '虚位以待', joinedFlag: false },
  { memberKey: 'pdd-slot-3', memberName: '虚位以待', joinedFlag: false }
];

@Component
export struct PddGroupDialogTruncationPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = PDD_DIALOG_BASE_WIDTH;
  @State winHeightVp: number = 672;
  /** 沉浸式下的状态栏 / 底部手势区高度（vp） */
  @State statusBarHeightVp: number = PDD_STATUS_BAR_FALLBACK;
  @State bottomInsetVp: number = PDD_BOTTOM_INSET_FALLBACK;

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
      this.windowToken = WindowModeController.acquire(win, PDD_PAGE_RED);
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  /** 场景缩放比：窗口越宽，页面整体放大越多（单屏态为 1.0） */
  private sceneScale(): number {
    const widthRatio: number = this.winWidthVp / PDD_DIALOG_BASE_WIDTH;
    return widthRatio < 1 ? 1 : widthRatio;
  }

  /** 把设计基准值（vp）换算到当前窗口宽度 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  // ------------------------------------------------------------------
  // 底层商品页
  // ------------------------------------------------------------------

  @Builder
  productNavBar() {
    Stack({ alignContent: Alignment.Center }) {
      Text('商品详情')
        .fontSize(this.vs(16))
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)

      Row() {
        Row() {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(this.vs(20))
            .fontColor([Color.White])
        }
        .width(this.vs(32))
        .height(this.vs(32))
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.pageStack.pop();
        })

        Blank()

        SymbolGlyph($r('sys.symbol.share'))
          .fontSize(this.vs(18))
          .fontColor([Color.White])
      }
      .width('100%')
      .padding({ left: this.vs(8), right: this.vs(12) })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(this.vs(44))
    .margin({ top: this.statusBarHeightVp })
  }

  @Builder
  productImageBlock() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 135,
          colors: [['#FF8A4C', 0.0], ['#F0512E', 0.55], ['#C93A2A', 1.0]]
        })

      Text('新疆阿克苏 · 产地直发')
        .fontSize(this.vs(13))
        .fontColor(Color.White)
        .margin({ left: this.vs(14), bottom: this.vs(12) })
        .padding({ left: this.vs(8), right: this.vs(8), top: this.vs(3), bottom: this.vs(3) })
        .backgroundColor('#33000000')
        .borderRadius(this.vs(10))
    }
    .width('100%')
    .height(this.vs(200))
  }

  @Builder
  productPriceRow() {
    Row() {
      Row({ space: this.vs(2) }) {
        Text('¥')
          .fontSize(this.vs(15))
          .fontWeight(FontWeight.Bold)
          .fontColor(PDD_PAGE_RED)
          .margin({ top: this.vs(8) })

        Text('39.9')
          .fontSize(this.vs(26))
          .fontWeight(FontWeight.Bold)
          .fontColor(PDD_PAGE_RED)
      }
      .alignItems(VerticalAlign.Top)

      Text('已拼1.2万+件')
        .fontSize(this.vs(11))
        .fontColor(PDD_PAGE_RED)
        .margin({ left: this.vs(8) })
        .padding({ left: this.vs(6), right: this.vs(6), top: this.vs(2), bottom: this.vs(2) })
        .backgroundColor('#FFE9E5')
        .borderRadius(this.vs(8))

      Blank()

      Text('降价提醒')
        .fontSize(this.vs(11))
        .fontColor(PDD_SUB_TEXT)
        .padding({ left: this.vs(8), right: this.vs(8), top: this.vs(3), bottom: this.vs(3) })
        .border({ width: this.vs(1), color: '#DDDDDD', radius: this.vs(10) })
    }
    .width('100%')
    .padding({ left: this.vs(14), right: this.vs(14) })
    .margin({ top: this.vs(10) })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  productTitleBlock() {
    Text('新疆阿克苏冰糖心苹果 5斤装 脆甜多汁现摘现发高山水果礼盒')
      .fontSize(this.vs(14))
      .fontColor(PDD_TITLE_TEXT)
      .lineHeight(this.vs(20))
      .maxLines(2)
      .width('100%')
      .padding({ left: this.vs(14), right: this.vs(14) })
      .margin({ top: this.vs(8) })
  }

  @Builder
  productServiceRow() {
    Row({ space: this.vs(6) }) {
      Text('退货包运费')
        .fontSize(this.vs(10))
        .fontColor(PDD_SERVICE_TEXT)
        .padding({ left: this.vs(6), right: this.vs(6), top: this.vs(2), bottom: this.vs(2) })
        .backgroundColor(PDD_SERVICE_BG)
        .borderRadius(this.vs(6))

      Text('48小时发货')
        .fontSize(this.vs(10))
        .fontColor(PDD_SERVICE_TEXT)
        .padding({ left: this.vs(6), right: this.vs(6), top: this.vs(2), bottom: this.vs(2) })
        .backgroundColor(PDD_SERVICE_BG)
        .borderRadius(this.vs(6))

      Text('坏果包赔')
        .fontSize(this.vs(10))
        .fontColor(PDD_SERVICE_TEXT)
        .padding({ left: this.vs(6), right: this.vs(6), top: this.vs(2), bottom: this.vs(2) })
        .backgroundColor(PDD_SERVICE_BG)
        .borderRadius(this.vs(6))

      Text('拼单返现')
        .fontSize(this.vs(10))
        .fontColor(PDD_SERVICE_TEXT)
        .padding({ left: this.vs(6), right: this.vs(6), top: this.vs(2), bottom: this.vs(2) })
        .backgroundColor(PDD_SERVICE_BG)
        .borderRadius(this.vs(6))
    }
    .width('100%')
    .padding({ left: this.vs(14), right: this.vs(14) })
    .margin({ top: this.vs(8) })
  }

  @Builder
  productBottomBar() {
    Row({ space: this.vs(10) }) {
      Column() {
        SymbolGlyph($r('sys.symbol.headphones'))
          .fontSize(this.vs(18))
          .fontColor(['#555555'])

        Text('客服')
          .fontSize(this.vs(9))
          .fontColor('#777777')
          .margin({ top: this.vs(2) })
      }
      .alignItems(HorizontalAlign.Center)

      Column() {
        SymbolGlyph($r('sys.symbol.star'))
          .fontSize(this.vs(18))
          .fontColor(['#555555'])

        Text('收藏')
          .fontSize(this.vs(9))
          .fontColor('#777777')
          .margin({ top: this.vs(2) })
      }
      .alignItems(HorizontalAlign.Center)

      Column() {
        SymbolGlyph($r('sys.symbol.cart'))
          .fontSize(this.vs(18))
          .fontColor(['#555555'])

        Text('购物车')
          .fontSize(this.vs(9))
          .fontColor('#777777')
          .margin({ top: this.vs(2) })
      }
      .alignItems(HorizontalAlign.Center)

      Row() {
        Column() {
          Text('单独购买')
            .fontSize(this.vs(9))
            .fontColor(PDD_PAGE_RED_DEEP)

          Text('¥59.9')
            .fontSize(this.vs(13))
            .fontWeight(FontWeight.Bold)
            .fontColor(PDD_PAGE_RED_DEEP)
        }
        .alignItems(HorizontalAlign.Center)
        .padding({ top: this.vs(2), bottom: this.vs(2) })
      }
      .width(this.vs(92))
      .height(this.vs(40))
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#FFDFD6')
      .borderRadius({ topLeft: this.vs(20), bottomLeft: this.vs(20), topRight: this.vs(0), bottomRight: this.vs(0) })

      Row() {
        Column() {
          Text('发起拼单')
            .fontSize(this.vs(9))
            .fontColor(Color.White)

          Text('¥39.9')
            .fontSize(this.vs(13))
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
        }
        .alignItems(HorizontalAlign.Center)
        .padding({ top: this.vs(2), bottom: this.vs(2) })
      }
      .layoutWeight(1)
      .height(this.vs(40))
      .justifyContent(FlexAlign.Center)
      .backgroundColor(PDD_PAGE_RED)
      .borderRadius({ topLeft: this.vs(0), bottomLeft: this.vs(0), topRight: this.vs(20), bottomRight: this.vs(20) })
    }
    .width('100%')
    .height(this.vs(52))
    .padding({ left: this.vs(14), right: this.vs(12) })
    .alignItems(VerticalAlign.Center)
    .backgroundColor(PDD_CARD_WHITE)
    .position({ x: 0, y: this.winHeightVp - this.vs(52) - this.bottomInsetVp })
  }

  @Builder
  productLayer() {
    Column() {
      this.productNavBar()
      this.productImageBlock()
      this.productPriceRow()
      this.productTitleBlock()
      this.serviceRowSpacer()
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(PDD_PAGE_BG)
    .clip(true)
  }

  @Builder
  serviceRowSpacer() {
    Column() {
      this.productServiceRow()

      Row()
        .width(this.vs(120))
        .height(this.vs(4))
        .backgroundColor('#FFD9D2')
        .borderRadius(this.vs(2))
        .margin({ top: this.vs(14) })

      Text('· 商品评价 (2.3万) ·')
        .fontSize(this.vs(11))
        .fontColor(PDD_SUB_TEXT)
        .margin({ top: this.vs(10) })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  // ------------------------------------------------------------------
  // 拼单结果弹窗（定高 352vp，内容按 sceneScale 放大 —— 反例核心）
  // ------------------------------------------------------------------

  @Builder
  groupBanner() {
    Row({ space: this.vs(8) }) {
      SymbolGlyph($r('sys.symbol.gift_fill'))
        .fontSize(this.vs(20))
        .fontColor([Color.White])

      Text('拼单成功，等待好友参团')
        .fontSize(this.vs(15))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
    }
    .width('100%')
    .height(this.vs(50))
    .padding({ left: this.vs(14) })
    .alignItems(VerticalAlign.Center)
    .linearGradient({
      angle: 90,
      colors: [['#FF6A3C', 0.0], [PDD_PAGE_RED, 1.0]]
    })
    .borderRadius({ topLeft: this.vs(8), topRight: this.vs(8) })
  }

  @Builder
  groupProductRow() {
    Row({ space: this.vs(8) }) {
      Stack({ alignContent: Alignment.BottomEnd }) {
        Column()
          .width(this.vs(64))
          .height(this.vs(64))
          .linearGradient({
            angle: 135,
            colors: [['#FFB25C', 0.0], ['#F0613A', 1.0]]
          })
          .borderRadius(this.vs(8))

        Text('包邮')
          .fontSize(this.vs(8))
          .fontColor(Color.White)
          .backgroundColor(PDD_PAGE_RED)
          .borderRadius({ topLeft: this.vs(6), bottomRight: this.vs(6) })
          .padding({ left: this.vs(4), right: this.vs(4), top: this.vs(1), bottom: this.vs(1) })
      }

      Column({ space: this.vs(4) }) {
        Text('新疆阿克苏冰糖心苹果 5斤装 脆甜多汁')
          .fontSize(this.vs(12))
          .fontColor(PDD_TITLE_TEXT)
          .lineHeight(this.vs(16))
          .maxLines(2)

        Row({ space: this.vs(6) }) {
          Text('¥39.9')
            .fontSize(this.vs(13))
            .fontWeight(FontWeight.Bold)
            .fontColor(PDD_PAGE_RED)

          Text('已选 1件')
            .fontSize(this.vs(10))
            .fontColor(PDD_SUB_TEXT)
        }
        .alignItems(VerticalAlign.Bottom)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(this.vs(72))
    .padding({ left: this.vs(12), right: this.vs(12) })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  groupMemberSlot(memberItem: PddGroupMember) {
    Column({ space: this.vs(4) }) {
      if (memberItem.joinedFlag) {
        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width(this.vs(36))
            .height(this.vs(36))
            .borderRadius(this.vs(18))
            .linearGradient({
              angle: 135,
              colors: [['#FFB668', 0.0], ['#F27A2E', 1.0]]
            })

          SymbolGlyph($r('sys.symbol.person_fill'))
            .fontSize(this.vs(18))
            .fontColor([Color.White])
        }
        .width(this.vs(36))
        .height(this.vs(36))
      } else {
        Stack({ alignContent: Alignment.Center }) {
          SymbolGlyph($r('sys.symbol.person'))
            .fontSize(this.vs(16))
            .fontColor([PDD_EMPTY_SLOT])
        }
        .width(this.vs(36))
        .height(this.vs(36))
        .border({ width: this.vs(1), color: PDD_EMPTY_SLOT, radius: this.vs(18) })
        .borderStyle(BorderStyle.Dashed)
      }

      Text(memberItem.memberName)
        .fontSize(this.vs(9))
        .fontColor(memberItem.joinedFlag ? '#666666' : PDD_EMPTY_SLOT)
        .maxLines(1)
    }
    .width(this.vs(52))
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  groupMemberRow() {
    Column() {
      Row({ space: this.vs(8) }) {
        ForEach(PDD_GROUP_MEMBERS, (memberItem: PddGroupMember) => {
          this.groupMemberSlot(memberItem)
        }, (memberItem: PddGroupMember) => memberItem.memberKey)
      }
      .alignItems(VerticalAlign.Top)

      Text('已有 2 人参团，还差 3 人成团')
        .fontSize(this.vs(11))
        .fontColor(PDD_TAG_BLUE)
        .margin({ top: this.vs(4) })
    }
    .width('100%')
    .height(this.vs(70))
    .padding({ left: this.vs(12), right: this.vs(12) })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  groupCountdownRow() {
    Row({ space: this.vs(6) }) {
      SymbolGlyph($r('sys.symbol.clock'))
        .fontSize(this.vs(15))
        .fontColor([PDD_COUNTDOWN_TEXT])

      Text('还剩')
        .fontSize(this.vs(12))
        .fontColor(PDD_COUNTDOWN_TEXT)

      Text('01:23:45')
        .fontSize(this.vs(14))
        .fontWeight(FontWeight.Bold)
        .fontColor(PDD_COUNTDOWN_TEXT)

      Text('结束')
        .fontSize(this.vs(12))
        .fontColor(PDD_COUNTDOWN_TEXT)
    }
    .width('100%')
    .height(this.vs(40))
    .margin({ left: this.vs(12), right: this.vs(12) })
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(PDD_COUNTDOWN_BG)
    .borderRadius(this.vs(6))
  }

  @Builder
  groupInviteBtn() {
    Row({ space: this.vs(4) }) {
      Text('邀请好友参团')
        .fontSize(this.vs(16))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(this.vs(14))
        .fontColor([Color.White])
    }
    .width(this.vs(230))
    .height(this.vs(48))
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .linearGradient({
      angle: 90,
      colors: [['#FF7A3C', 0.0], [PDD_PAGE_RED, 1.0]]
    })
    .borderRadius(this.vs(24))
    .shadow({ radius: this.vs(6), color: '#33E02E24', offsetX: 0, offsetY: this.vs(2) })
  }

  @Builder
  groupDialog() {
    Stack({ alignContent: Alignment.TopEnd }) {
      // 弹窗内容：横幅 → 商品行 → 成员位 → 倒计时 → 邀请按钮，全部按 sceneScale 放大
      Column() {
        this.groupBanner()
        this.groupProductRow()
        this.groupMemberRow()
        this.groupCountdownRow()
        this.groupInviteBtn()
      }
      .width('100%')
      .padding({ left: this.vs(12), right: this.vs(12), top: this.vs(12), bottom: this.vs(12) })
      .alignItems(HorizontalAlign.Center)

      SymbolGlyph($r('sys.symbol.xmark'))
        .fontSize(this.vs(14))
        .fontColor(['#BBBBBB'])
        .margin({ top: this.vs(8), right: this.vs(8) })
        .onClick(() => {
          this.pageStack.pop();
        })
    }
    .width('88%')
    .height(PDD_DIALOG_FIXED_HEIGHT)
    .backgroundColor(PDD_CARD_WHITE)
    .borderRadius(this.vs(10))
    .shadow({ radius: this.vs(16), color: '#40000000', offsetX: 0, offsetY: this.vs(4) })
    .clip(true)
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Center }) {
        this.productLayer()

        this.productBottomBar()

        // 半透明遮罩：只挡触摸，不挡渲染
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#000000')
          .opacity(0.45)
          .hitTestBehavior(HitTestMode.None)

        this.groupDialog()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(PDD_PAGE_BG)
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
