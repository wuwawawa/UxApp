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
 * 反例：未避让安全区 / 我的页手机号压状态栏（状态栏）
 *
 * 复刻滴滴出行「我的」页：顶部大号脱敏手机号 + 「消息 / 设置」，下面是会员卡
 * （V4 会员、成长值进度、会员中心按钮、四个权益入口），再往下是订单入口、钱包数据、
 * 服务入口、活动入口、两张活动卡片，以及底部四页签。
 *
 * 设计基准：单屏态 459.6×672vp（1264×1848px，密度 2.75），vp = px / 2.75。
 *   顶部条：高 82vp（= 会员卡顶边），手机号与「消息 / 设置」在条内贴着卡片往上排：
 *           行高 24vp、行底到卡片 16.2vp、左右留白 26.2vp、字号 20vp；
 *   会员卡：宽 434.2vp（左右各 12.7vp）、单屏态高 64vp、圆角 10vp；
 *           卡内内容高 156vp：顶部 V4 行 26vp、间距 24vp、四个权益入口 88vp（图标 43vp、
 *           标题 15vp、副标题 12vp、条目宽 110vp）、底部留白 15vp；
 *   其余卡片：左右 12.7vp、间距 11vp、圆角 10vp；订单卡 90vp、钱包卡 77vp、
 *           服务卡 75vp、活动卡 87vp、玩法卡 60vp；
 *   底部页签：固定 74vp，三态都不缩放。
 *   除顶部条高度、会员卡高度与页签外，所有尺寸按 sceneScale = 窗口宽 / 459.6 等比放大。
 *
 * 三态实测（同一套设计值，按窗口宽度换算）：
 *   单屏态      459.6×672vp   —— ×1.000：手机号 y 46.9～62.2vp，在状态栏下方
 *   双屏态竖屏  664.7×939.6vp —— ×1.446：手机号 y 30.9～53.1vp，距状态栏下沿 1.4vp
 *   双屏态横屏  939.6×664.7vp —— ×2.044：手机号 y 9.5～41.1vp，压住状态栏
 *
 * 问题表现（双屏态横屏）：
 *   「182****2818」的 1、8 两个数字与状态栏时间叠在一起，「消息 / 设置」压住电池、
 *   信号图标；双屏态竖屏时手机号也已顶到状态栏下沿；单屏态正常显示在状态栏下方。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 单屏态窗口宽度（1264px / 密度 2.75），整页横向尺寸的基准 */
const PH_BASE_WIDTH: number = 459.6;

/** 配色 */
const PH_PAGE_BG: string = '#F6F7F9';
const PH_TEXT: string = '#1A1A1A';
const PH_SUBTEXT: string = '#8C8C8C';
const PH_MEMBER_TITLE: string = '#4B3A8F';
const PH_MEMBER_SUB: string = '#8B80B8';
const PH_MEMBER_BRAND: string = '#6A4CC8';
const PH_MEMBER_PROGRESS: string = '#CFC7E8';
const PH_ORANGE: string = '#FF6A00';

/** 顶部条：高度 = 会员卡顶边，固定不随窗口宽度变化 */
const PH_TOP_BAND: number = 82;
const PH_HEADER_SIDE: number = 26.2;
const PH_HEADER_ROW_HEIGHT: number = 24;
const PH_HEADER_ROW_GAP: number = 16.2;
const PH_HEADER_FONT: number = 20;

/** 卡片：左右留白、卡片间距、圆角 */
const PH_CARD_SIDE: number = 12.7;
const PH_CARD_GAP: number = 11;
const PH_CARD_RADIUS: number = 10;
const PH_CARD_WIDTH: number = PH_BASE_WIDTH - PH_CARD_SIDE * 2;

/** 会员卡：单屏态高 64vp；卡内内容 156vp，底对齐后顶部超出部分被裁掉 */
const PH_MEMBER_MIN_HEIGHT: number = 64;
const PH_MEMBER_CONTENT_HEIGHT: number = 156;
/** 三态实测 64 / 172.5 / 317.9vp，按窗口宽度每增加 1vp 卡高增加 0.529vp */
const PH_MEMBER_GROWTH: number = 0.529;

/** 底部页签固定高度（三态一致） */
const PH_TAB_BAR_HEIGHT: number = 74;

/** 会员卡权益入口 */
interface DidiMemberEntry {
  entryKey: string;
  entryTitle: string;
  entrySubtitle: string;
  /** 图标：长隆权益用截图裁出的徽章图 */
  entryImage: Resource | undefined;
  /** 图标：其余入口用系统符号 */
  entrySymbol: Resource | undefined;
  /** 最右一条在卡片边缘渐隐 */
  entryFaded: boolean;
}

/** 通用图标入口（订单 / 服务 / 活动） */
interface DidiIconEntry {
  entryKey: string;
  entryLabel: string;
  entrySymbol: Resource | undefined;
  entryImage: Resource | undefined;
}

/** 钱包数据 */
interface DidiWalletEntry {
  walletKey: string;
  walletValue: string;
  walletUnit: string;
  walletLabel: string;
  walletPill: string;
}

/** 底部页签 */
interface DidiTabEntry {
  tabKey: string;
  tabLabel: string;
  tabSymbol: Resource;
  tabActive: boolean;
}

@Component
export struct ProfileHeaderStatusBarPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽度（vp），随折叠 / 旋转实时更新；整页缩放比由它算出 */
  @State winWidthVp: number = PH_BASE_WIDTH;

  /** 窗口高度（vp） */
  @State winHeightVp: number = 672;

  private contentScroller: Scroller = new Scroller();
  private pageActive: boolean = false;
  private windowToken: number = 0;

  private memberEntries: DidiMemberEntry[] = [];
  private orderEntries: DidiIconEntry[] = [];
  private walletEntries: DidiWalletEntry[] = [];
  private serviceEntries: DidiIconEntry[] = [];
  private promoEntries: DidiIconEntry[] = [];
  private tabEntries: DidiTabEntry[] = [];

  aboutToAppear(): void {
    this.pageActive = true;
    this.buildPageData();
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

  private buildPageData(): void {
    this.memberEntries = [
      {
        entryKey: 'member-changlong',
        entryTitle: '领长隆好礼',
        entrySubtitle: '免费双人套票 ›',
        entryImage: $r('app.media.didi_changlong_badge'),
        entrySymbol: undefined,
        entryFaded: false
      },
      {
        entryKey: 'member-coupon',
        entryTitle: '月月领券',
        entrySubtitle: '最高省40元 ›',
        entryImage: undefined,
        entrySymbol: $r('sys.symbol.ticket_fill'),
        entryFaded: false
      },
      {
        entryKey: 'member-wanhao',
        entryTitle: '直通万豪',
        entrySubtitle: '领银卡挑战 ›',
        entryImage: undefined,
        entrySymbol: $r('sys.symbol.building'),
        entryFaded: false
      },
      {
        entryKey: 'member-changlong-card',
        entryTitle: '直通长隆',
        entrySubtitle: '领金卡 ›',
        entryImage: undefined,
        entrySymbol: $r('sys.symbol.doc_text'),
        entryFaded: true
      }
    ];

    this.orderEntries = [
      { entryKey: 'order-all', entryLabel: '全部订单', entrySymbol: $r('sys.symbol.doc_text'), entryImage: undefined },
      { entryKey: 'order-depart', entryLabel: '待出发', entrySymbol: $r('sys.symbol.clock'), entryImage: undefined },
      { entryKey: 'order-pay', entryLabel: '待支付', entrySymbol: $r('sys.symbol.creditcard'), entryImage: undefined },
      { entryKey: 'order-invoice', entryLabel: '开发票', entrySymbol: $r('sys.symbol.ticket_fill'), entryImage: undefined },
      { entryKey: 'order-service', entryLabel: '客服', entrySymbol: $r('sys.symbol.headphones'), entryImage: undefined }
    ];

    this.walletEntries = [
      { walletKey: 'wallet-coupon', walletValue: '6', walletUnit: '张', walletLabel: '优惠卡券', walletPill: '' },
      { walletKey: 'wallet-return', walletValue: '66', walletUnit: '元', walletLabel: '单单返现', walletPill: '' },
      { walletKey: 'wallet-bill', walletValue: '1000', walletUnit: '元', walletLabel: '账单月结', walletPill: '待领取' },
      { walletKey: 'wallet-credit', walletValue: '20', walletUnit: '万', walletLabel: '预估可借', walletPill: '' }
    ];

    this.serviceEntries = [
      { entryKey: 'service-driver', entryLabel: '成为司机', entrySymbol: $r('sys.symbol.person'), entryImage: undefined },
      { entryKey: 'service-company', entryLabel: '企业权益', entrySymbol: $r('sys.symbol.star_rosette'), entryImage: undefined },
      { entryKey: 'service-green', entryLabel: '绿色出行', entrySymbol: $r('sys.symbol.leaf'), entryImage: undefined },
      { entryKey: 'service-pay', entryLabel: '滴滴支付', entrySymbol: $r('sys.symbol.creditcard'), entryImage: undefined },
      { entryKey: 'service-map', entryLabel: '地图反馈', entrySymbol: $r('sys.symbol.map'), entryImage: undefined }
    ];

    this.promoEntries = [
      {
        entryKey: 'promo-saver',
        entryLabel: '省钱套餐',
        entrySymbol: undefined,
        entryImage: $r('app.media.didi_promo_saver')
      },
      {
        entryKey: 'promo-student',
        entryLabel: '学生专区',
        entrySymbol: undefined,
        entryImage: $r('app.media.didi_promo_student')
      },
      {
        entryKey: 'promo-graduate',
        entryLabel: '毕业生',
        entrySymbol: undefined,
        entryImage: $r('app.media.didi_promo_graduate')
      },
      {
        entryKey: 'promo-welfare',
        entryLabel: '福利群',
        entrySymbol: undefined,
        entryImage: $r('app.media.didi_promo_welfare')
      },
      {
        entryKey: 'promo-points',
        entryLabel: '积分商城',
        entrySymbol: undefined,
        entryImage: $r('app.media.didi_promo_points')
      }
    ];

    this.tabEntries = [
      { tabKey: 'tab-home', tabLabel: '首页', tabSymbol: $r('sys.symbol.house'), tabActive: false },
      { tabKey: 'tab-message', tabLabel: '消息', tabSymbol: $r('sys.symbol.message'), tabActive: false },
      { tabKey: 'tab-trip', tabLabel: '行程', tabSymbol: $r('sys.symbol.calendar'), tabActive: false },
      { tabKey: 'tab-mine', tabLabel: '我的', tabSymbol: $r('sys.symbol.person_fill'), tabActive: true }
    ];
  }

  /** 整页缩放比：窗口宽度 / 单屏态宽度（459.6vp） */
  private sceneScale(): number {
    if (this.winWidthVp <= 0) {
      return 1;
    }
    return this.winWidthVp / PH_BASE_WIDTH;
  }

  /** 把按单屏态量出的设计值换算到当前窗口 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  /** 会员卡高度：三态实测值随窗口宽度线性增长 */
  private memberCardHeightVp(): number {
    const measured: number = PH_MEMBER_MIN_HEIGHT + (this.winWidthVp - PH_BASE_WIDTH) * PH_MEMBER_GROWTH;
    return Math.max(PH_MEMBER_MIN_HEIGHT, measured);
  }

  // ------------------------------------------------------------------
  // 顶部条：手机号 + 消息 / 设置
  // ------------------------------------------------------------------

  @Builder
  topBand() {
    Stack({ alignContent: Alignment.Bottom }) {
      Row() {
        Text('182****2818')
          .fontSize(this.vs(PH_HEADER_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor('#111111')
          .maxLines(1)

        Blank()

        Row({ space: this.vs(10) }) {
          Text('消息')
            .fontSize(this.vs(19))
            .fontWeight(FontWeight.Bold)
            .fontColor('#111111')

          Text('设置')
            .fontSize(this.vs(19))
            .fontWeight(FontWeight.Bold)
            .fontColor('#111111')
        }
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height(this.vs(PH_HEADER_ROW_HEIGHT))
      .padding({ left: this.vs(PH_HEADER_SIDE), right: this.vs(PH_HEADER_SIDE) })
      .margin({ bottom: this.vs(PH_HEADER_ROW_GAP) })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(PH_TOP_BAND)
    .backgroundColor(PH_PAGE_BG)
  }

  // ------------------------------------------------------------------
  // 会员卡
  // ------------------------------------------------------------------

  @Builder
  memberTopRow() {
    Row() {
      Text('V4会员')
        .fontSize(this.vs(21))
        .fontWeight(FontWeight.Bold)
        .fontColor('#5C47A8')
        .maxLines(1)

      Column() {
        Text('1041 / 2000 (升级V5)')
          .fontSize(this.vs(10.5))
          .fontColor('#6B57AE')
          .maxLines(1)

        Stack({ alignContent: Alignment.Start }) {
          Row()
            .width(this.vs(130))
            .height(this.vs(3.4))
            .backgroundColor(PH_MEMBER_PROGRESS)
            .borderRadius(this.vs(2))

          Row()
            .width(this.vs(68))
            .height(this.vs(3.4))
            .backgroundColor('#7A66C9')
            .borderRadius(this.vs(2))
        }
        .width(this.vs(130))
        .height(this.vs(3.4))
        .margin({ top: this.vs(5) })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: this.vs(9) })

      Blank()

      Row({ space: this.vs(2) }) {
        Text('会员中心')
          .fontSize(this.vs(12))
          .fontColor(Color.White)

        Text('›')
          .fontSize(this.vs(13))
          .fontColor(Color.White)
      }
      .height(this.vs(26))
      .padding({ left: this.vs(13), right: this.vs(11) })
      .backgroundColor(PH_MEMBER_BRAND)
      .borderRadius(this.vs(13))
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(this.vs(26))
    .padding({ left: this.vs(14), right: this.vs(12) })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  memberEntry(entry: DidiMemberEntry) {
    Column() {
      if (entry.entryImage !== undefined) {
        Image(entry.entryImage)
          .width(this.vs(43))
          .height(this.vs(43))
          .objectFit(ImageFit.Contain)
      } else {
        Stack({ alignContent: Alignment.Center }) {
          Row()
            .width(this.vs(43))
            .height(this.vs(43))
            .backgroundColor('#FBF9FF')
            .borderRadius(this.vs(11))

          SymbolGlyph(entry.entrySymbol)
            .fontSize(this.vs(20))
            .fontColor(['#6B57AE'])
        }
        .width(this.vs(43))
        .height(this.vs(43))
      }

      Text(entry.entryTitle)
        .fontSize(this.vs(15))
        .fontWeight(FontWeight.Medium)
        .fontColor(PH_MEMBER_TITLE)
        .maxLines(1)
        .height(this.vs(18))
        .margin({ top: this.vs(10) })

      Text(entry.entrySubtitle)
        .fontSize(this.vs(12))
        .fontColor(PH_MEMBER_SUB)
        .maxLines(1)
        .height(this.vs(15))
        .margin({ top: this.vs(2) })
    }
    .width(this.vs(110))
    .alignItems(HorizontalAlign.Center)
    .opacity(entry.entryFaded ? 0.5 : 1)
  }

  @Builder
  memberCard() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        this.memberTopRow()

        Row() {
          ForEach(this.memberEntries, (entry: DidiMemberEntry) => {
            this.memberEntry(entry)
          }, (entry: DidiMemberEntry) => entry.entryKey)
        }
        .width(this.vs(442))
        .padding({ left: this.vs(2) })
        .margin({ top: this.vs(24) })
        .alignItems(VerticalAlign.Top)
      }
      .width('100%')
      .height(this.vs(PH_MEMBER_CONTENT_HEIGHT))
      .padding({ top: this.vs(3), bottom: this.vs(15) })
      .alignItems(HorizontalAlign.Start)
    }
    .width(this.vs(PH_CARD_WIDTH))
    .height(this.memberCardHeightVp())
    .clip(true)
    .borderRadius(this.vs(PH_CARD_RADIUS))
    .linearGradient({ angle: 180, colors: [['#F5F1FE', 0.0], ['#DFD9F3', 1.0]] })
    .margin({ bottom: this.vs(PH_CARD_GAP) })
  }

  // ------------------------------------------------------------------
  // 订单入口
  // ------------------------------------------------------------------

  @Builder
  orderCard() {
    Row() {
      ForEach(this.orderEntries, (entry: DidiIconEntry) => {
        Column({ space: this.vs(7) }) {
          SymbolGlyph(entry.entrySymbol)
            .fontSize(this.vs(25))
            .fontColor(['#1A1A1A'])

          Text(entry.entryLabel)
            .fontSize(this.vs(11.5))
            .fontColor('#1A1A1A')
            .maxLines(1)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }, (entry: DidiIconEntry) => entry.entryKey)
    }
    .width(this.vs(PH_CARD_WIDTH))
    .height(this.vs(90))
    .padding({ left: this.vs(8), right: this.vs(8) })
    .backgroundColor(Color.White)
    .borderRadius(this.vs(PH_CARD_RADIUS))
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: this.vs(PH_CARD_GAP) })
  }

  // ------------------------------------------------------------------
  // 钱包数据
  // ------------------------------------------------------------------

  @Builder
  walletStat(entry: DidiWalletEntry) {
    Column() {
      if (entry.walletPill.length > 0) {
        Text(entry.walletPill)
          .fontSize(this.vs(9))
          .fontColor(Color.White)
          .backgroundColor('#F26B45')
          .borderRadius(this.vs(7))
          .padding({ left: this.vs(5), right: this.vs(5), top: this.vs(1), bottom: this.vs(1) })
          .margin({ bottom: this.vs(3) })
      }

      Row({ space: this.vs(1) }) {
        Text(entry.walletValue)
          .fontSize(this.vs(18))
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')

        Text(entry.walletUnit)
          .fontSize(this.vs(10))
          .fontColor('#1A1A1A')
      }
      .alignItems(VerticalAlign.Bottom)

      Text(entry.walletLabel)
        .fontSize(this.vs(10.5))
        .fontColor('#333333')
        .maxLines(1)
        .margin({ top: this.vs(3) })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.End)
  }

  @Builder
  walletCard() {
    Row() {
      Column({ space: this.vs(4) }) {
        SymbolGlyph($r('sys.symbol.wallet'))
          .fontSize(this.vs(22))
          .fontColor(['#1A1A1A'])

        Text('我的钱包')
          .fontSize(this.vs(11))
          .fontColor('#1A1A1A')
          .maxLines(1)
      }
      .width(this.vs(82))
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)

      Divider()
        .vertical(true)
        .height(this.vs(42))
        .strokeWidth(this.vs(0.7))
        .color('#EDEDED')

      Row() {
        ForEach(this.walletEntries, (entry: DidiWalletEntry) => {
          this.walletStat(entry)
        }, (entry: DidiWalletEntry) => entry.walletKey)
      }
      .layoutWeight(1)
      .height('100%')
    }
    .width(this.vs(PH_CARD_WIDTH))
    .height(this.vs(77))
    .padding({ left: this.vs(6), right: this.vs(6), top: this.vs(11), bottom: this.vs(11) })
    .backgroundColor(Color.White)
    .borderRadius(this.vs(PH_CARD_RADIUS))
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: this.vs(PH_CARD_GAP) })
  }

  // ------------------------------------------------------------------
  // 服务入口
  // ------------------------------------------------------------------

  @Builder
  serviceEntry(entry: DidiIconEntry) {
    Column({ space: this.vs(7) }) {
      SymbolGlyph(entry.entrySymbol)
        .fontSize(this.vs(24))
        .fontColor(['#1A1A1A'])

      Text(entry.entryLabel)
        .fontSize(this.vs(11.5))
        .fontColor('#1A1A1A')
        .maxLines(1)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  serviceCard() {
    Row() {
      ForEach(this.serviceEntries, (entry: DidiIconEntry) => {
        this.serviceEntry(entry)
      }, (entry: DidiIconEntry) => entry.entryKey)
    }
    .width(this.vs(PH_CARD_WIDTH))
    .height(this.vs(75))
    .padding({ left: this.vs(8), right: this.vs(8) })
    .backgroundColor(Color.White)
    .borderRadius(this.vs(PH_CARD_RADIUS))
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: this.vs(PH_CARD_GAP) })
  }

  // ------------------------------------------------------------------
  // 活动入口
  // ------------------------------------------------------------------

  @Builder
  promoEntry(entry: DidiIconEntry) {
    Column({ space: this.vs(8) }) {
      Image(entry.entryImage)
        .width(this.vs(34))
        .height(this.vs(34))
        .objectFit(ImageFit.Contain)

      Text(entry.entryLabel)
        .fontSize(this.vs(11))
        .fontColor('#1A1A1A')
        .maxLines(1)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  promoCard() {
    Row() {
      ForEach(this.promoEntries, (entry: DidiIconEntry) => {
        this.promoEntry(entry)
      }, (entry: DidiIconEntry) => entry.entryKey)
    }
    .width(this.vs(PH_CARD_WIDTH))
    .height(this.vs(87))
    .padding({ left: this.vs(8), right: this.vs(8), top: this.vs(12) })
    .backgroundColor(Color.White)
    .borderRadius(this.vs(PH_CARD_RADIUS))
    .alignItems(VerticalAlign.Top)
    .margin({ bottom: this.vs(PH_CARD_GAP) })
  }

  // ------------------------------------------------------------------
  // 底部两张活动卡
  // ------------------------------------------------------------------

  @Builder
  featureRow() {
    Row({ space: this.vs(PH_CARD_GAP) }) {
      Column({ space: this.vs(6) }) {
        Row() {
          Text('租车')
            .fontSize(this.vs(18))
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF5A1F')

          Text('趣秋游')
            .fontSize(this.vs(18))
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A')
            .margin({ left: this.vs(2) })
        }
        .alignItems(VerticalAlign.Bottom)

        Text('领券最高减200元')
          .fontSize(this.vs(11.5))
          .fontColor('#4A3A24')
          .maxLines(1)
      }
      .layoutWeight(1)
      .height('100%')
      .padding({ left: this.vs(12), right: this.vs(8) })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)
      .borderRadius(this.vs(PH_CARD_RADIUS))
      .linearGradient({ angle: 135, colors: [['#FFF6E4', 0.0], ['#FFEAC4', 1.0]] })

      Column({ space: this.vs(6) }) {
        Text('车主服务')
          .fontSize(this.vs(18))
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')

        Text('有车的人就用TA')
          .fontSize(this.vs(11.5))
          .fontColor('#8C8C8C')
          .maxLines(1)
      }
      .layoutWeight(1)
      .height('100%')
      .padding({ left: this.vs(12), right: this.vs(8) })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)
      .backgroundColor(Color.White)
      .borderRadius(this.vs(PH_CARD_RADIUS))
    }
    .width(this.vs(PH_CARD_WIDTH))
    .height(this.vs(60))
    .alignItems(VerticalAlign.Center)
  }

  // ------------------------------------------------------------------
  // 底部页签（固定尺寸）
  // ------------------------------------------------------------------

  @Builder
  tabItem(tab: DidiTabEntry) {
    Column({ space: 3 }) {
      SymbolGlyph(tab.tabSymbol)
        .fontSize(24)
        .fontColor([tab.tabActive ? PH_ORANGE : '#1A1A1A'])

      Text(tab.tabLabel)
        .fontSize(10.5)
        .fontColor(tab.tabActive ? PH_ORANGE : '#1A1A1A')
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  tabBar() {
    Row() {
      ForEach(this.tabEntries, (tab: DidiTabEntry) => {
        this.tabItem(tab)
      }, (tab: DidiTabEntry) => tab.tabKey)
    }
    .width('100%')
    .height(PH_TAB_BAR_HEIGHT)
    .backgroundColor(Color.White)
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        Column() {
          this.topBand()

          Scroll(this.contentScroller) {
            Column() {
              this.memberCard()
              this.orderCard()
              this.walletCard()
              this.serviceCard()
              this.promoCard()
              this.featureRow()

              Row()
                .height(PH_TAB_BAR_HEIGHT)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.None)
          .align(Alignment.Top)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(PH_PAGE_BG)

        Column() {
          this.tabBar()
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.End)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(PH_PAGE_BG)
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
