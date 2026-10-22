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
 * 反例：未避让安全区 / 去哪儿搜索框压状态栏（状态栏）
 *
 * 复刻去哪儿旅行首页：蓝色头部与白色搜索胶囊（定位「北京」+ 下拉箭头 + 分隔线 +
 * 放大镜 + 占位「搜目的地/酒店/机票」），白色内容区里两行三列的服务入口
 * （国内酒店 / 机票 / 火车票 / 汽车票 / 景点 / 周边游），蓝青渐变促销横幅
 * （暑期大促 · 机票×酒店 低至5折 + 立即领券），两张特惠卡片
 * （北京→三亚特价机票 ¥680 起、三亚湾海景酒店 ¥429/晚），以及底部快捷工具行
 * （接送机 / 签证服务 / 旅行保险 / 铁友会员）。
 *
 * 设计基准：单屏态 459.6×672vp（1264×1848px，密度 2.75），vp = px / 2.75。
 *   头部固定带：高 86vp（不随窗口宽度变化），蓝底 #2E7FE8，内容底对齐：
 *           搜索胶囊行 40vp（胶囊高 40vp、圆角 20vp、定位字 14vp、占位字 13.5vp），
 *           按 sceneScale = 窗口宽 / 459.6 等比放大，左右留白 12.7vp；
 *   服务入口：两行三列，圆底图标 44vp（圆角 22vp）+ 标签 12vp，行高 92vp；
 *   促销横幅：高 86vp、圆角 12vp，主标 17vp、副标 12vp、领券胶囊高 28vp；
 *   特惠卡片：高 92vp（左侧渐变方图 76vp、主标 14.5vp、副标 11.5vp、价格 17vp）；
 *   快捷工具行：图标 22vp + 标签 11.5vp。
 *
 * 三态实测（同一套设计值，按窗口宽度换算；状态栏占屏幕顶部约 0～40vp）：
 *   单屏态      459.6×672vp   —— ×1.000：搜索框 y 46～86，在状态栏下方正常显示
 *   双屏态竖屏  664.7×939.6vp —— ×1.446：搜索框 y 28.2～86.1，上沿 11.8vp 压进状态栏，
 *                                定位「北京」与状态栏时间半重叠
 *   双屏态横屏  939.6×664.7vp —— ×2.044：搜索框 y 4.2～86，几乎整框贴到屏幕顶端，
 *                                时间 / 电量图标直接叠在输入框上
 *
 * 问题表现（双屏态）：
 *   搜索框不避让状态栏：窗口变宽后搜索胶囊放大并整体上移，双屏竖屏起上沿探入
 *   状态栏，横屏时输入框几乎贴住屏幕顶边，时间、电量浮在「搜目的地/酒店/机票」
 *   占位文字上。单屏态下搜索框完整显示在状态栏下方。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 单屏态窗口宽度（1264px / 密度 2.75），整页横向尺寸的基准 */
const QS_BASE_WIDTH: number = 459.6;

/** 配色 */
const QS_BRAND_BLUE: string = '#2E7FE8';
const QS_BRAND_BLUE_DEEP: string = '#1668E8';
const QS_PAGE_BG: string = '#FFFFFF';
const QS_TEXT: string = '#1A1A1A';
const QS_SUBTEXT: string = '#999999';
const QS_PRICE_RED: string = '#FF4D3A';

/** 头部固定带：高度固定；条内搜索行底对齐并随窗口宽度等比放大 */
const QS_HEADER_BAND: number = 86;
const QS_SEARCH_ROW: number = 40;
const QS_SEARCH_PILL: number = 40;
const QS_HEADER_SIDE: number = 12.7;
const QS_CITY_FONT: number = 14;
const QS_PLACEHOLDER_FONT: number = 13.5;

/** 服务入口 */
const QS_SERVICE_ICON: number = 44;
const QS_SERVICE_FONT: number = 12;

/** 促销横幅 / 卡片 */
const QS_PROMO_HEIGHT: number = 86;
const QS_DEAL_THUMB: number = 76;
const QS_CARD_SIDE: number = 12.7;
const QS_CARD_GAP: number = 11;
const QS_CARD_RADIUS: number = 10;

/** 服务入口（两行三列） */
interface QunarServiceEntry {
  entryKey: string;
  entryLabel: string;
  entrySymbol: Resource;
  /** 图标着色 */
  entryTint: string;
  /** 圆底底色 */
  entryBg: string;
}

/** 服务入口一行 */
interface QunarServiceRow {
  rowKey: string;
  rowEntries: QunarServiceEntry[];
}

/** 特惠卡片 */
interface QunarDealCard {
  cardKey: string;
  cardTitle: string;
  cardSub: string;
  cardPrice: string;
  cardPriceUnit: string;
  cardTag: string;
  cardTopColor: string;
  cardBottomColor: string;
  cardSymbol: Resource;
}

/** 底部快捷工具 */
interface QunarToolEntry {
  toolKey: string;
  toolLabel: string;
  toolSymbol: Resource;
}

@Component
export struct QunarSearchStatusBarPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽度（vp），随折叠 / 旋转实时更新；整页缩放比由它算出 */
  @State winWidthVp: number = QS_BASE_WIDTH;

  /** 窗口高度（vp） */
  @State winHeightVp: number = 672;

  private contentScroller: Scroller = new Scroller();
  private pageActive: boolean = false;
  private windowToken: number = 0;

  private serviceRows: QunarServiceRow[] = [];
  private dealCards: QunarDealCard[] = [];
  private toolEntries: QunarToolEntry[] = [];

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
      this.windowToken = WindowModeController.acquire(win, '#FFFFFF');
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  private buildPageData(): void {
    this.serviceRows = [
      {
        rowKey: 'qs-svc-row-1',
        rowEntries: [
          {
            entryKey: 'qs-svc-hotel',
            entryLabel: '国内酒店',
            entrySymbol: $r('sys.symbol.building'),
            entryTint: '#2E7FE8',
            entryBg: '#E8F1FF'
          },
          {
            entryKey: 'qs-svc-flight',
            entryLabel: '机票',
            entrySymbol: $r('sys.symbol.airplane'),
            entryTint: '#1FA0DC',
            entryBg: '#E4F7FD'
          },
          {
            entryKey: 'qs-svc-train',
            entryLabel: '火车票',
            entrySymbol: $r('sys.symbol.ticket_fill'),
            entryTint: '#E8843F',
            entryBg: '#FFF3E4'
          }
        ]
      },
      {
        rowKey: 'qs-svc-row-2',
        rowEntries: [
          {
            entryKey: 'qs-svc-bus',
            entryLabel: '汽车票',
            entrySymbol: $r('sys.symbol.car'),
            entryTint: '#3FAE6A',
            entryBg: '#EAF9F0'
          },
          {
            entryKey: 'qs-svc-scenic',
            entryLabel: '景点',
            entrySymbol: $r('sys.symbol.camera'),
            entryTint: '#E86FA5',
            entryBg: '#FDF0F5'
          },
          {
            entryKey: 'qs-svc-around',
            entryLabel: '周边游',
            entrySymbol: $r('sys.symbol.map'),
            entryTint: '#7A6FE8',
            entryBg: '#F1EDFF'
          }
        ]
      }
    ];

    this.dealCards = [
      {
        cardKey: 'qs-deal-flight',
        cardTitle: '北京 → 三亚 特价往返',
        cardSub: '10月26日 · 直飞经济舱 · 含机建',
        cardPrice: '¥680',
        cardPriceUnit: '起',
        cardTag: '特价',
        cardTopColor: '#7FC3FF',
        cardBottomColor: QS_BRAND_BLUE,
        cardSymbol: $r('sys.symbol.airplane')
      },
      {
        cardKey: 'qs-deal-hotel',
        cardTitle: '三亚湾海景度假酒店',
        cardSub: '海景大床房 · 含双早 · 免费取消',
        cardPrice: '¥429',
        cardPriceUnit: '/晚',
        cardTag: '立减',
        cardTopColor: '#FFD591',
        cardBottomColor: '#FF9C4D',
        cardSymbol: $r('sys.symbol.building')
      }
    ];

    this.toolEntries = [
      { toolKey: 'qs-tool-pickup', toolLabel: '接送机', toolSymbol: $r('sys.symbol.car') },
      { toolKey: 'qs-tool-visa', toolLabel: '签证服务', toolSymbol: $r('sys.symbol.doc_text') },
      { toolKey: 'qs-tool-insure', toolLabel: '旅行保险', toolSymbol: $r('sys.symbol.lock') },
      { toolKey: 'qs-tool-member', toolLabel: '铁友会员', toolSymbol: $r('sys.symbol.crown') }
    ];
  }

  /** 整页缩放比：窗口宽度 / 单屏态宽度（459.6vp） */
  private sceneScale(): number {
    if (this.winWidthVp <= 0) {
      return 1;
    }
    return this.winWidthVp / QS_BASE_WIDTH;
  }

  /** 把按单屏态量出的设计值换算到当前窗口 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  // ------------------------------------------------------------------
  // 头部固定带：定位 + 搜索胶囊（底对齐，随窗口宽度整体放大）
  // ------------------------------------------------------------------

  @Builder
  searchPill() {
    Row({ space: this.vs(6) }) {
      SymbolGlyph($r('sys.symbol.pin'))
        .fontSize(this.vs(15))
        .fontColor([QS_BRAND_BLUE_DEEP])

      Text('北京')
        .fontSize(this.vs(QS_CITY_FONT))
        .fontWeight(FontWeight.Medium)
        .fontColor(QS_TEXT)
        .maxLines(1)

      SymbolGlyph($r('sys.symbol.chevron_down'))
        .fontSize(this.vs(10))
        .fontColor(['#666666'])

      Row()
        .width(this.vs(0.5))
        .height(this.vs(18))
        .backgroundColor('#E2E6EC')
        .margin({ left: this.vs(2), right: this.vs(4) })

      SymbolGlyph($r('sys.symbol.magnifyingglass'))
        .fontSize(this.vs(15))
        .fontColor(['#9AA3AE'])

      Text('搜目的地/酒店/机票')
        .fontSize(this.vs(QS_PLACEHOLDER_FONT))
        .fontColor('#9AA3AE')
        .maxLines(1)
        .layoutWeight(1)
    }
    .width('100%')
    .height(this.vs(QS_SEARCH_PILL))
    .padding({ left: this.vs(14), right: this.vs(14) })
    .borderRadius(this.vs(QS_SEARCH_PILL / 2))
    .backgroundColor(Color.White)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  headerBand() {
    Stack({ alignContent: Alignment.Bottom }) {
      this.searchPill()
    }
    .width('100%')
    .height(QS_HEADER_BAND)
    .padding({ left: this.vs(QS_HEADER_SIDE), right: this.vs(QS_HEADER_SIDE) })
    .backgroundColor(QS_BRAND_BLUE)
  }

  // ------------------------------------------------------------------
  // 服务入口：两行三列
  // ------------------------------------------------------------------

  @Builder
  serviceCell(entry: QunarServiceEntry) {
    Column({ space: this.vs(8) }) {
      Row() {
        SymbolGlyph(entry.entrySymbol)
          .fontSize(this.vs(22))
          .fontColor([entry.entryTint])
      }
      .width(this.vs(QS_SERVICE_ICON))
      .height(this.vs(QS_SERVICE_ICON))
      .borderRadius(this.vs(QS_SERVICE_ICON / 2))
      .backgroundColor(entry.entryBg)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)

      Text(entry.entryLabel)
        .fontSize(this.vs(QS_SERVICE_FONT))
        .fontColor(QS_TEXT)
        .maxLines(1)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  serviceGrid() {
    Column() {
      ForEach(this.serviceRows, (svcRow: QunarServiceRow) => {
        Row() {
          ForEach(svcRow.rowEntries, (entry: QunarServiceEntry) => {
            this.serviceCell(entry)
          }, (entry: QunarServiceEntry) => entry.entryKey)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
        .margin({ top: this.vs(svcRow.rowKey === 'qs-svc-row-1' ? 14 : 12) })
      }, (svcRow: QunarServiceRow) => svcRow.rowKey)
    }
    .width('100%')
    .backgroundColor(QS_PAGE_BG)
  }

  // ------------------------------------------------------------------
  // 促销横幅
  // ------------------------------------------------------------------

  @Builder
  promoBanner() {
    Row() {
      Column({ space: this.vs(4) }) {
        Text('暑期大促 · 双人出行立减')
          .fontSize(this.vs(17))
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .maxLines(1)

        Text('机票 × 酒店 低至 5 折')
          .fontSize(this.vs(12))
          .fontColor('#D9E9FF')
          .maxLines(1)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Row({ space: this.vs(2) }) {
        Text('立即领券')
          .fontSize(this.vs(12))
          .fontColor(QS_BRAND_BLUE_DEEP)

        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(this.vs(12))
          .fontColor([QS_BRAND_BLUE_DEEP])
      }
      .height(this.vs(28))
      .padding({ left: this.vs(12), right: this.vs(8) })
      .borderRadius(this.vs(14))
      .backgroundColor(Color.White)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(this.vs(QS_PROMO_HEIGHT))
    .padding({ left: this.vs(14), right: this.vs(10) })
    .borderRadius(this.vs(12))
    .linearGradient({ angle: 135, colors: [['#3FB6FF', 0.0], [QS_BRAND_BLUE_DEEP, 1.0]] })
    .alignItems(VerticalAlign.Center)
  }

  // ------------------------------------------------------------------
  // 特惠卡片
  // ------------------------------------------------------------------

  @Builder
  dealCard(card: QunarDealCard) {
    Row({ space: this.vs(11) }) {
      Stack({ alignContent: Alignment.Center }) {
        Row()
          .width(this.vs(QS_DEAL_THUMB))
          .height(this.vs(QS_DEAL_THUMB))
          .borderRadius(this.vs(10))
          .linearGradient({ angle: 135, colors: [[card.cardTopColor, 0.0], [card.cardBottomColor, 1.0]] })

        SymbolGlyph(card.cardSymbol)
          .fontSize(this.vs(26))
          .fontColor(['#FFFFFF'])
      }
      .width(this.vs(QS_DEAL_THUMB))
      .height(this.vs(QS_DEAL_THUMB))

      Column({ space: this.vs(5) }) {
        Text(card.cardTitle)
          .fontSize(this.vs(14.5))
          .fontWeight(FontWeight.Bold)
          .fontColor(QS_TEXT)
          .maxLines(1)

        Text(card.cardSub)
          .fontSize(this.vs(11.5))
          .fontColor(QS_SUBTEXT)
          .maxLines(1)

        Row({ space: this.vs(5) }) {
          Text(card.cardPrice)
            .fontSize(this.vs(17))
            .fontWeight(FontWeight.Bold)
            .fontColor(QS_PRICE_RED)

          Text(card.cardPriceUnit)
            .fontSize(this.vs(11))
            .fontColor(QS_SUBTEXT)

          Blank()

          Text(card.cardTag)
            .fontSize(this.vs(10))
            .fontColor(QS_PRICE_RED)
            .padding({ left: this.vs(7), right: this.vs(7), top: this.vs(2), bottom: this.vs(2) })
            .borderRadius(this.vs(9))
            .border({ width: 0.5, color: QS_PRICE_RED })
        }
        .width('100%')
        .alignItems(VerticalAlign.Bottom)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(this.vs(10))
    .borderRadius(this.vs(QS_CARD_RADIUS))
    .backgroundColor(Color.White)
    .border({ width: 0.5, color: '#EFF1F5' })
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: this.vs(QS_CARD_GAP) })
  }

  // ------------------------------------------------------------------
  // 底部快捷工具行
  // ------------------------------------------------------------------

  @Builder
  toolEntry(tool: QunarToolEntry) {
    Column({ space: this.vs(6) }) {
      SymbolGlyph(tool.toolSymbol)
        .fontSize(this.vs(22))
        .fontColor(['#4C5A6E'])

      Text(tool.toolLabel)
        .fontSize(this.vs(11.5))
        .fontColor('#4C5A6E')
        .maxLines(1)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  toolRow() {
    Row() {
      ForEach(this.toolEntries, (tool: QunarToolEntry) => {
        this.toolEntry(tool)
      }, (tool: QunarToolEntry) => tool.toolKey)
    }
    .width('100%')
    .padding({ top: this.vs(6), bottom: this.vs(14) })
    .alignItems(VerticalAlign.Top)
  }

  build() {
    NavDestination() {
      Column() {
        this.headerBand()

        Scroll(this.contentScroller) {
          Column() {
            this.serviceGrid()

            Column() {
            Column() {
              this.promoBanner()
            }
            .width('100%')
            .margin({ top: this.vs(QS_CARD_GAP) })
            .alignItems(HorizontalAlign.Start)

            Column() {
              this.dealCard(this.dealCards[0])
            }
            .width('100%')
            .margin({ top: this.vs(QS_CARD_GAP) })
            .alignItems(HorizontalAlign.Start)

            this.dealCard(this.dealCards[1])

              this.toolRow()
            }
            .width('100%')
            .padding({ left: this.vs(QS_CARD_SIDE), right: this.vs(QS_CARD_SIDE) })
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.None)
        .align(Alignment.Top)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(QS_PAGE_BG)
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
