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
 * 反例：大图大字 / 携程首页卡片放大
 *
 * 复刻携程旅行首页：蓝色渐变头部（「携程旅行」+ 客服/消息入口）、白色搜索卡
 * （目的地 上海 | 日期 3月8日 周六 | 搜索按钮）、「特价机票」促销大 banner
 * （渐变色块 + 飞机图标）、金刚区图标网格（酒店 / 机票 / 火车票 / 用车 /
 * 门票 / 攻略）、「今日特价·爆款推荐」特价大卡列表（整宽渐变卡：航线 / 房型 +
 * 价格），底部 TabBar（首页 / 订单 / 客服 / 我的）。「图片」均以渐变色块 +
 * SymbolGlyph 绘制，不使用任何媒体资源。
 *
 * 设计基准：单屏态 459.6×672vp（1264×1848px，密度 2.75）。banner 高 132vp、
 * 金刚区图标圆 44vp、特价卡高为卡宽 × 0.33（约 435×144vp）、价格字号 26vp。
 *
 * 三个屏态：
 *   单屏态        459.6×672vp   —— banner 132vp、特价卡 435×144vp，一屏 2 张卡
 *   双屏态竖屏    664.7×939.6vp —— 全部 ×1.45：banner 191vp、特价卡 630×208vp，
 *                                  banner + 金刚区占满首屏
 *   双屏态横屏    939.6×664.7vp —— 全部 ×2.04：banner 269vp、特价卡 890×294vp，
 *                                  一张特价大卡就占近半屏高，首屏只放得下一张卡
 *
 * 问题表现（双屏态竖屏 / 横屏）：促销 banner、金刚区图标与特价大卡随窗口宽度
 * 整体等比放大：横屏下 banner 269vp 高、一张特价机票大卡 890×294vp，一行只有
 * 一张卡且一屏只放得下一张，价格字号放大到 53vp；头部搜索卡与底部 Tab 却还是
 * 单屏态大小，页面上下小而中间巨大、留白失衡。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 单屏态窗口宽度（1264px / 密度 2.75）：banner 与卡片区所有尺寸的基准宽度 */
const CTRIP_BASE_WIDTH: number = 459.6;
/** 单屏态窗口高度，拿不到窗口高度时兜底 */
const CTRIP_BASE_HEIGHT: number = 672;
/** 状态栏 / 底部手势区兜底高度（vp） */
const CTRIP_STATUS_BAR_FALLBACK: number = 32; const CTRIP_BOTTOM_INSET_FALLBACK: number = 8;
/** 配色 */
const CTRIP_PAGE_BG: string = '#F4F6F9';
const CTRIP_BLUE_TOP: string = '#1FA9FF';
const CTRIP_BLUE_BOTTOM: string = '#0C7CF6';
const CTRIP_BRAND_BLUE: string = '#0C7CF6';
const CTRIP_TEXT_MAIN: string = '#1A1A1A';
const CTRIP_TEXT_GRAY: string = '#8A8A8A';
const CTRIP_PRICE_RED: string = '#FF4E3D';
/** 头部（固定尺寸，不随卡片区放大，形成「上小下大」的失衡对比） */
const CTRIP_TOP_ROW_HEIGHT: number = 40;
const CTRIP_LOGO_FONT: number = 17;
const CTRIP_SEARCH_CARD_HEIGHT: number = 52;
const CTRIP_SEARCH_CARD_RADIUS: number = 26;
const CTRIP_SEARCH_FIELD_FONT: number = 15;
const CTRIP_SEARCH_HINT_FONT: number = 10;
const CTRIP_SEARCH_BUTTON: number = 32;
const CTRIP_HEADER_PAD: number = 12;
/** 促销 banner：高 132vp、圆角 16vp（随窗口放大） */
const CTRIP_BANNER_HEIGHT: number = 132;
const CTRIP_BANNER_RADIUS: number = 16;
const CTRIP_BANNER_TITLE_FONT: number = 19;
const CTRIP_BANNER_SUB_FONT: number = 12;
const CTRIP_BANNER_TAG_FONT: number = 10;
const CTRIP_BANNER_GLYPH: number = 52;
const CTRIP_BANNER_GAP_BELOW: number = 10;
/** 金刚区：白卡圆角 16vp、图标圆 44vp、两行三列（随窗口放大） */
const CTRIP_ICON_CARD_RADIUS: number = 16;
const CTRIP_ICON_CARD_PAD: number = 16;
const CTRIP_ICON_CIRCLE: number = 44;
const CTRIP_ICON_GLYPH: number = 22;
const CTRIP_ICON_LABEL_FONT: number = 12.5;
const CTRIP_ICON_ROW_GAP: number = 14;
const CTRIP_ICON_CELL_HEIGHT: number = 76;
const CTRIP_ICON_COLUMNS: number = 3;
/** 特价大卡：整宽卡、高 = 卡宽 × 0.33（随窗口放大） */
const CTRIP_DEAL_SIDE_INSET: number = 12;
const CTRIP_DEAL_HEIGHT_RATIO: number = 0.33;
const CTRIP_DEAL_RADIUS: number = 16;
const CTRIP_DEAL_TAG_FONT: number = 10;
const CTRIP_DEAL_TITLE_FONT: number = 17;
const CTRIP_DEAL_SUB_FONT: number = 11.5;
const CTRIP_DEAL_PRICE_FONT: number = 26;
const CTRIP_DEAL_CURRENCY_FONT: number = 13;
const CTRIP_DEAL_UNIT_FONT: number = 11;
const CTRIP_DEAL_GLYPH: number = 56;
const CTRIP_DEAL_ROW_GAP: number = 10;
const CTRIP_SECTION_TITLE_FONT: number = 16;
const CTRIP_SECTION_GAP_ABOVE: number = 14;
/** 底部 TabBar（固定尺寸） */
const CTRIP_TAB_BAR_HEIGHT: number = 52;
const CTRIP_TAB_ICON: number = 22;
const CTRIP_TAB_LABEL_FONT: number = 10;

/** 金刚区入口数据 */
interface CtripIconEntry {
  iconKey: string;
  iconLabel: string;
  iconSymbol: Resource;
  /** 图标圆的渐变色 */
  iconTintFrom: string;
  iconTintTo: string;
}

const CTRIP_ICONS: CtripIconEntry[] = [
  { iconKey: 'hotel', iconLabel: '酒店', iconSymbol: $r('sys.symbol.house_fill'),
    iconTintFrom: '#5AB8FF', iconTintTo: '#1E6FFF' },
  { iconKey: 'flight', iconLabel: '机票', iconSymbol: $r('sys.symbol.airplane'),
    iconTintFrom: '#63C7FF', iconTintTo: '#0C7CF6' },
  { iconKey: 'train', iconLabel: '火车票', iconSymbol: $r('sys.symbol.train_ticket'),
    iconTintFrom: '#84FAB0', iconTintTo: '#29B26B' },
  { iconKey: 'car', iconLabel: '用车', iconSymbol: $r('sys.symbol.car'),
    iconTintFrom: '#FFD3A5', iconTintTo: '#FD6585' },
  { iconKey: 'ticket', iconLabel: '门票', iconSymbol: $r('sys.symbol.ticket_fill'),
    iconTintFrom: '#FFB6D5', iconTintTo: '#F76B8A' },
  { iconKey: 'guide', iconLabel: '攻略', iconSymbol: $r('sys.symbol.compass'),
    iconTintFrom: '#C7F464', iconTintTo: '#56AB2F' }
];

/** 特价大卡数据：封面用渐变色块 + SymbolGlyph 绘制 */
interface CtripDealCard {
  dealId: string;
  dealTag: string;
  dealTitle: string;
  dealSub: string;
  dealPrice: string;
  dealUnit: string;
  dealSymbol: Resource;
  dealCoverFrom: string;
  dealCoverTo: string;
}

const CTRIP_DEALS: CtripDealCard[] = [
  {
    dealId: 'flight-deal', dealTag: '限时特惠', dealTitle: '上海 → 成都 单程含税',
    dealSub: '3-4月出行 · 直飞 · 送机酒券', dealPrice: '390', dealUnit: '起',
    dealSymbol: $r('sys.symbol.airplane_departure'),
    dealCoverFrom: '#2E7BFF', dealCoverTo: '#5AB8FF'
  },
  {
    dealId: 'hotel-deal', dealTag: '连住优惠', dealTitle: '三亚湾海景大床房',
    dealSub: '3晚连住 · 含双早 · 免费取消', dealPrice: '329', dealUnit: '起',
    dealSymbol: $r('sys.symbol.house_fill'),
    dealCoverFrom: '#FF9966', dealCoverTo: '#FF5E62'
  },
  {
    dealId: 'weekend-deal', dealTag: '周末特惠', dealTitle: '迪士尼亲子 2日1晚',
    dealSub: '亲子房 · 含双园门票', dealPrice: '699', dealUnit: '起',
    dealSymbol: $r('sys.symbol.compass'),
    dealCoverFrom: '#35C3A2', dealCoverTo: '#1E9E8A'
  }
];

/** 底部 TabBar 数据 */
interface CtripBottomTabEntry {
  ctabKey: string;
  ctabLabel: string;
  ctabSymbol: Resource;
  ctabActive: boolean;
}

const CTRIP_BOTTOM_TABS: CtripBottomTabEntry[] = [
  { ctabKey: 'home', ctabLabel: '首页', ctabSymbol: $r('sys.symbol.house'), ctabActive: true },
  { ctabKey: 'order', ctabLabel: '订单', ctabSymbol: $r('sys.symbol.doc_text'), ctabActive: false },
  { ctabKey: 'service', ctabLabel: '客服', ctabSymbol: $r('sys.symbol.headphones'), ctabActive: false },
  { ctabKey: 'mine', ctabLabel: '我的', ctabSymbol: $r('sys.symbol.person'), ctabActive: false }
];

@Component
export struct CtripHomeBigBannerPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = CTRIP_BASE_WIDTH;
  @State winHeightVp: number = CTRIP_BASE_HEIGHT;
  /** 沉浸式下的状态栏 / 底部手势区高度（vp） */
  @State statusBarHeightVp: number = CTRIP_STATUS_BAR_FALLBACK;
  @State bottomInsetVp: number = CTRIP_BOTTOM_INSET_FALLBACK;

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
      // 头部是蓝色渐变，系统栏内容用白色
      this.windowToken = WindowModeController.acquire(win, '#FFFFFF');
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  // ---------- 尺寸与数据：banner / 金刚区 / 特价卡尺寸全部由窗口宽度推出 ----------

  /** 场景缩放比：窗口宽度 / 单屏态宽度（459.6vp），展开态约 ×1.45 / ×2.04 */
  private sceneScale(): number {
    if (this.winWidthVp <= 0) {
      return 1;
    }
    return this.winWidthVp / CTRIP_BASE_WIDTH;
  }

  /** 按场景缩放比放大单屏态设计值 */
  private vs(designValue: number): number {
    return designValue * this.sceneScale();
  }

  /** 特价大卡宽 = 窗口宽度 - 左右留白，高 = 卡宽 × 0.33 */
  private dealCardWidthVp(): number {
    return this.winWidthVp - this.vs(CTRIP_DEAL_SIDE_INSET) * 2;
  }

  private dealCardHeightVp(): number {
    return this.dealCardWidthVp() * CTRIP_DEAL_HEIGHT_RATIO;
  }

  /** 行序号数组，交给 ForEach 逐行渲染 */
  private rowIndexesOf(rowTotal: number): number[] {
    const rowIndexes: number[] = [];
    for (let rowIndex: number = 0; rowIndex < rowTotal; rowIndex++) {
      rowIndexes.push(rowIndex);
    }
    return rowIndexes;
  }

  /** 取金刚区第 rowIndex 行的入口 */
  private iconsOfRow(rowIndex: number): CtripIconEntry[] {
    const startIndex: number = rowIndex * CTRIP_ICON_COLUMNS;
    return CTRIP_ICONS.slice(startIndex, startIndex + CTRIP_ICON_COLUMNS);
  }

  // ---------- 头部：Logo 行 + 目的地/日期搜索卡（固定尺寸） ----------

  @Builder
  headerTopRow() {
    Row() {
      Text('携程旅行').fontSize(CTRIP_LOGO_FONT).fontWeight(FontWeight.Bold)
        .fontColor(Color.White).maxLines(1)
      Blank()
      SymbolGlyph($r('sys.symbol.headphones')).fontSize(20).fontColor([Color.White])
      SymbolGlyph($r('sys.symbol.bell')).fontSize(20).fontColor([Color.White])
        .margin({ left: 14 })
    }
    .width('100%')
    .height(CTRIP_TOP_ROW_HEIGHT)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  searchCard() {
    Row() {
      Row({ space: 5 }) {
        SymbolGlyph($r('sys.symbol.pin')).fontSize(16).fontColor([CTRIP_BRAND_BLUE])
        Column({ space: 1 }) {
          Text('目的地/城市').fontSize(CTRIP_SEARCH_HINT_FONT).fontColor(CTRIP_TEXT_GRAY).maxLines(1)
          Text('上海').fontSize(CTRIP_SEARCH_FIELD_FONT).fontWeight(FontWeight.Medium)
            .fontColor(CTRIP_TEXT_MAIN).maxLines(1)
        }
        .alignItems(HorizontalAlign.Start)
        SymbolGlyph($r('sys.symbol.chevron_down')).fontSize(10).fontColor([CTRIP_TEXT_GRAY])
      }
      .alignItems(VerticalAlign.Center)
      .layoutWeight(1)
      Divider().vertical(true).height(24).strokeWidth(0.5).color('#DCDCDC')
      Row({ space: 5 }) {
        SymbolGlyph($r('sys.symbol.calendar')).fontSize(16).fontColor([CTRIP_BRAND_BLUE])
        Column({ space: 1 }) {
          Text('日期').fontSize(CTRIP_SEARCH_HINT_FONT).fontColor(CTRIP_TEXT_GRAY).maxLines(1)
          Text('3月8日 周六').fontSize(CTRIP_SEARCH_FIELD_FONT).fontWeight(FontWeight.Medium)
            .fontColor(CTRIP_TEXT_MAIN).maxLines(1)
        }
        .alignItems(HorizontalAlign.Start)
      }
      .alignItems(VerticalAlign.Center)
      .layoutWeight(1)
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width(CTRIP_SEARCH_BUTTON).height(CTRIP_SEARCH_BUTTON)
          .backgroundColor(CTRIP_BRAND_BLUE)
          .borderRadius(CTRIP_SEARCH_BUTTON / 2)
        SymbolGlyph($r('sys.symbol.magnifyingglass')).fontSize(15).fontColor([Color.White])
      }
      .width(CTRIP_SEARCH_BUTTON).height(CTRIP_SEARCH_BUTTON)
      .margin({ left: 8 })
    }
    .width('100%')
    .height(CTRIP_SEARCH_CARD_HEIGHT)
    .padding({ left: 16, right: 12 })
    .backgroundColor(Color.White)
    .borderRadius(CTRIP_SEARCH_CARD_RADIUS)
    .alignItems(VerticalAlign.Center)
    .shadow({ radius: 8, color: '#14000000', offsetY: 3 })
  }

  // ---------- 促销 banner：特价机票渐变大卡（随窗口放大） ----------

  @Builder
  promoBanner() {
    Row() {
      Column({ space: this.vs(5) }) {
        Text('特价机票').fontSize(this.vs(CTRIP_BANNER_TAG_FONT)).fontColor(Color.White)
          .padding({ left: this.vs(6), right: this.vs(6), top: this.vs(2), bottom: this.vs(2) })
          .backgroundColor('#33FFFFFF').borderRadius(this.vs(8))
        Text('上海 → 成都 269元起').fontSize(this.vs(CTRIP_BANNER_TITLE_FONT))
          .fontWeight(FontWeight.Bold).fontColor(Color.White).maxLines(1)
        Text('春日出游 · 每日整点抢票').fontSize(this.vs(CTRIP_BANNER_SUB_FONT))
          .fontColor('#E6FFFFFF').maxLines(1)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      SymbolGlyph($r('sys.symbol.airplane_fill'))
        .fontSize(this.vs(CTRIP_BANNER_GLYPH)).fontColor([Color.White]).opacity(0.9)
    }
    .width('100%')
    .height(this.vs(CTRIP_BANNER_HEIGHT))
    .padding({ left: this.vs(18), right: this.vs(18) })
    .alignItems(VerticalAlign.Center)
    .linearGradient({ angle: 135, colors: [['#2E7BFF', 0.0], ['#5AB8FF', 1.0]] })
    .borderRadius(this.vs(CTRIP_BANNER_RADIUS))
    .shadow({ radius: this.vs(8), color: '#140072D9', offsetY: this.vs(3) })
  }

  // ---------- 金刚区图标网格：两行三列（随窗口放大） ----------

  @Builder
  iconCell(entry: CtripIconEntry) {
    Column({ space: this.vs(6) }) {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width(this.vs(CTRIP_ICON_CIRCLE)).height(this.vs(CTRIP_ICON_CIRCLE))
          .linearGradient({ angle: 135, colors: [[entry.iconTintFrom, 0.0], [entry.iconTintTo, 1.0]] })
          .borderRadius(this.vs(CTRIP_ICON_CIRCLE) / 2)
        SymbolGlyph(entry.iconSymbol)
          .fontSize(this.vs(CTRIP_ICON_GLYPH)).fontColor([Color.White])
      }
      .width(this.vs(CTRIP_ICON_CIRCLE)).height(this.vs(CTRIP_ICON_CIRCLE))
      Text(entry.iconLabel).fontSize(this.vs(CTRIP_ICON_LABEL_FONT))
        .fontColor(CTRIP_TEXT_MAIN).maxLines(1)
    }
    .layoutWeight(1)
    .height(this.vs(CTRIP_ICON_CELL_HEIGHT))
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  iconGridCard() {
    Column({ space: this.vs(CTRIP_ICON_ROW_GAP) }) {
      ForEach(this.rowIndexesOf(Math.ceil(CTRIP_ICONS.length / CTRIP_ICON_COLUMNS)),
        (rowIndex: number) => {
          Row() {
            ForEach(this.iconsOfRow(rowIndex), (entry: CtripIconEntry) => {
              this.iconCell(entry)
            }, (entry: CtripIconEntry) => entry.iconKey)
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
        }, (rowIndex: number) => 'ctrip-icon-row-' + rowIndex.toString())
    }
    .width('100%')
    .padding(this.vs(CTRIP_ICON_CARD_PAD))
    .backgroundColor(Color.White)
    .borderRadius(this.vs(CTRIP_ICON_CARD_RADIUS))
    .margin({ top: this.vs(CTRIP_BANNER_GAP_BELOW) })
  }

  // ---------- 特价大卡：整宽渐变卡，一行只有一张（随窗口放大） ----------

  @Builder
  dealCard(deal: CtripDealCard) {
    Row() {
      Column({ space: this.vs(5) }) {
        Text(deal.dealTag).fontSize(this.vs(CTRIP_DEAL_TAG_FONT)).fontColor(Color.White)
          .padding({ left: this.vs(6), right: this.vs(6), top: this.vs(2), bottom: this.vs(2) })
          .backgroundColor('#33FFFFFF').borderRadius(this.vs(8))
        Text(deal.dealTitle).fontSize(this.vs(CTRIP_DEAL_TITLE_FONT))
          .fontWeight(FontWeight.Bold).fontColor(Color.White).maxLines(1)
        Text(deal.dealSub).fontSize(this.vs(CTRIP_DEAL_SUB_FONT))
          .fontColor('#E6FFFFFF').maxLines(1)
        Row({ space: this.vs(2) }) {
          Text('¥').fontSize(this.vs(CTRIP_DEAL_CURRENCY_FONT)).fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
          Text(deal.dealPrice).fontSize(this.vs(CTRIP_DEAL_PRICE_FONT)).fontWeight(FontWeight.Bold)
            .fontColor(Color.White).maxLines(1)
          Text(deal.dealUnit).fontSize(this.vs(CTRIP_DEAL_UNIT_FONT)).fontColor('#E6FFFFFF')
        }
        .alignItems(VerticalAlign.Bottom)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      SymbolGlyph(deal.dealSymbol)
        .fontSize(this.vs(CTRIP_DEAL_GLYPH)).fontColor([Color.White]).opacity(0.9)
    }
    .width('100%')
    .height(this.dealCardHeightVp())
    .padding({ left: this.vs(18), right: this.vs(18) })
    .alignItems(VerticalAlign.Center)
    .linearGradient({ angle: 135, colors: [[deal.dealCoverFrom, 0.0], [deal.dealCoverTo, 1.0]] })
    .borderRadius(this.vs(CTRIP_DEAL_RADIUS))
  }

  @Builder
  dealSection() {
    Column() {
      Row({ space: this.vs(5) }) {
        SymbolGlyph($r('sys.symbol.bolt_fill'))
          .fontSize(this.vs(CTRIP_SECTION_TITLE_FONT)).fontColor(['#FF6A00'])
        Text('今日特价 · 爆款推荐').fontSize(this.vs(CTRIP_SECTION_TITLE_FONT))
          .fontWeight(FontWeight.Bold).fontColor(CTRIP_TEXT_MAIN).maxLines(1)
        Blank()
        Text('更多').fontSize(this.vs(CTRIP_DEAL_SUB_FONT))
          .fontColor(CTRIP_TEXT_GRAY).maxLines(1)
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(this.vs(CTRIP_DEAL_SUB_FONT)).fontColor([CTRIP_TEXT_GRAY])
      }
      .width('100%')
      .margin({ top: this.vs(CTRIP_SECTION_GAP_ABOVE), bottom: this.vs(CTRIP_SECTION_GAP_ABOVE) })
      .alignItems(VerticalAlign.Center)
      Column({ space: this.vs(CTRIP_DEAL_ROW_GAP) }) {
        ForEach(CTRIP_DEALS, (deal: CtripDealCard) => {
          this.dealCard(deal)
        }, (deal: CtripDealCard) => deal.dealId)
      }
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  // ---------- 底部 TabBar（固定尺寸） ----------

  @Builder
  bottomTabBar() {
    Row() {
      ForEach(CTRIP_BOTTOM_TABS, (entry: CtripBottomTabEntry) => {
        Column({ space: 3 }) {
          SymbolGlyph(entry.ctabSymbol).fontSize(CTRIP_TAB_ICON)
            .fontColor([entry.ctabActive ? '#0C7CF6' : '#6E6E73'])
          Text(entry.ctabLabel).fontSize(CTRIP_TAB_LABEL_FONT)
            .fontWeight(entry.ctabActive ? FontWeight.Medium : FontWeight.Normal)
            .fontColor(entry.ctabActive ? '#0C7CF6' : '#6E6E73').maxLines(1)
        }
        .layoutWeight(1)
        .height(CTRIP_TAB_BAR_HEIGHT)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }, (entry: CtripBottomTabEntry) => entry.ctabKey)
    }
    .width('100%')
    .height(CTRIP_TAB_BAR_HEIGHT)
    .alignItems(VerticalAlign.Center)
  }

  build() {
    NavDestination() {
      Column() {
        // ① 蓝色渐变头部：Logo 行 + 搜索卡（固定尺寸）
        Column() {
          this.headerTopRow()
          this.searchCard()
        }
        .width('100%')
        .padding({ top: this.statusBarHeightVp, left: CTRIP_HEADER_PAD, right: CTRIP_HEADER_PAD,
          bottom: 12 })
        .linearGradient({ angle: 160, colors: [[CTRIP_BLUE_TOP, 0.0], [CTRIP_BLUE_BOTTOM, 1.0]] })
        // ② 卡片区：banner / 金刚区 / 特价大卡全部随窗口宽度等比放大
        Scroll() {
          Column() {
            this.promoBanner()
            this.iconGridCard()
            this.dealSection()
          }
          .width('100%')
          .padding({ left: this.vs(CTRIP_DEAL_SIDE_INSET), right: this.vs(CTRIP_DEAL_SIDE_INSET),
            bottom: this.vs(CTRIP_DEAL_ROW_GAP) })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .backgroundColor(CTRIP_PAGE_BG)
        // ③ 底部 TabBar + 手势区避让（固定尺寸）
        Column() {
          this.bottomTabBar()
        }
        .width('100%')
        .padding({ bottom: this.bottomInsetVp })
        .backgroundColor(Color.White)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(CTRIP_PAGE_BG)
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
