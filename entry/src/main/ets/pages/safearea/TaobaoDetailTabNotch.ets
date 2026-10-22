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
 * 反例：未避让安全区 / 淘宝详情分类压挖孔（挖孔）
 *
 * 复刻淘宝商品详情页：顶部分类标签行（‹ 返回、「商品 / 评价 / 详情 / 推荐」、
 * 搜索、… 菜单点），大图占位（渐变 + 官方立减角标 + 1/5 页码），白色信息卡
 * （¥129 大红价 + 红包补贴 + 已售1000+、两行标题、包邮 / 正品 / 7天无理由保障行），
 * SKU 卡（已选行 + 曜石黑 / 远峰蓝颜色块 + 版本胶囊），评价卡
 * （评价1.2万 · 好评率99% + 标签 + 一条热评），底部操作栏
 * （店铺 / 客服 / 收藏 + 加入购物车 + 立即购买）。
 *
 * 设计基准：单屏态 459.6×672vp（1264×1848px，密度 2.75），vp = px / 2.75。
 *   顶部标签带：高 88vp 固定（不随窗口宽度变化），内容底对齐：
 *           标签行 44vp（返回键 44×44vp、标签字 16vp 加粗、选中橙色 #FF5000 带 3vp 指示条），
 *           按 sceneScale = 窗口宽 / 459.6 等比放大；
 *   大图：高 300vp（渐变 135°）；信息卡：价格行 46vp（¥ 字 17vp、数字 28vp）、
 *           标题 13.5vp 两行、保障行 32vp；
 *   SKU 卡：已选行 46vp、颜色块 44×44vp、版本胶囊 34vp 高；
 *   评价卡：头部行 40vp、标签 20vp 高、热评两行；
 *   底部操作栏：固定 56vp（三态都不缩放）。
 *
 * 三态实测（同一套设计值，按窗口宽度换算；状态栏 + 挖孔摄像头占屏幕顶部约 0～40vp）：
 *   单屏态      459.6×672vp   —— ×1.000：标签行 y 44～88，在状态栏下方正常显示
 *   双屏态竖屏  664.7×939.6vp —— ×1.446：标签行 y 24.4～88，上沿 15.6vp 压进状态栏
 *   双屏态横屏  939.6×664.7vp —— ×2.044：标签行 y -1.9～86.1，整行顶进状态栏，
 *                                最左「商品」标签被挖孔摄像头切掉一角
 *
 * 问题表现（双屏态）：
 *   顶部分类标签不避让挖孔：窗口变宽后标签行放大并顶进顶部挖孔区，横屏时
 *   第一个「商品」标签正好落在挖孔摄像头上被切掉，搜索与菜单点也压着状态栏图标。
 *   单屏态下标签行完整显示在状态栏下方。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 单屏态窗口宽度（1264px / 密度 2.75），整页横向尺寸的基准 */
const TB_BASE_WIDTH: number = 459.6;

/** 配色 */
const TB_PAGE_BG: string = '#F5F5F5';
const TB_TEXT: string = '#1A1A1A';
const TB_SUBTEXT: string = '#999999';
const TB_PRICE_RED: string = '#FF3B30';
const TB_BRAND_ORANGE: string = '#FF5000';
const TB_CART_ORANGE: string = '#FF9500';
const TB_CARD_SIDE: number = 12.7;
const TB_CARD_GAP: number = 10;
const TB_CARD_RADIUS: number = 12;

/** 顶部标签带：高度固定；条内标签行底对齐并随窗口宽度等比放大 */
const TB_TAB_BAND: number = 88;
const TB_TAB_ROW: number = 44;
const TB_TAB_FONT: number = 16;
const TB_TAB_GAP: number = 18;

/** 大图与信息卡 */
const TB_HERO_IMAGE: number = 300;
const TB_TITLE_FONT: number = 13.5;

/** 底部操作栏：固定高度（三态一致） */
const TB_BOTTOM_BAR: number = 56;

/** 顶部分类标签 */
interface TbDetailTab {
  tabKey: string;
  tabLabel: string;
  tabActive: boolean;
}

/** SKU 胶囊（颜色 / 版本） */
interface TbDetailSkuChip {
  chipKey: string;
  chipLabel: string;
  chipSelected: boolean;
}

/** 保障行条目 */
interface TbDetailGuarantee {
  gKey: string;
  gLabel: string;
  gSymbol: Resource;
}

/** 评价标签 */
interface TbDetailReviewTag {
  tagKey: string;
  tagLabel: string;
}

@Component
export struct TaobaoDetailTabNotchPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽度（vp），随折叠 / 旋转实时更新；整页缩放比由它算出 */
  @State winWidthVp: number = TB_BASE_WIDTH;

  /** 窗口高度（vp） */
  @State winHeightVp: number = 672;

  private contentScroller: Scroller = new Scroller();
  private pageActive: boolean = false;
  private windowToken: number = 0;

  private detailTabs: TbDetailTab[] = [];
  private colorChips: TbDetailSkuChip[] = [];
  private versionChips: TbDetailSkuChip[] = [];
  private guaranteeItems: TbDetailGuarantee[] = [];
  private reviewTags: TbDetailReviewTag[] = [];

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
    this.detailTabs = [
      { tabKey: 'tb-tab-goods', tabLabel: '商品', tabActive: true },
      { tabKey: 'tb-tab-review', tabLabel: '评价', tabActive: false },
      { tabKey: 'tb-tab-detail', tabLabel: '详情', tabActive: false },
      { tabKey: 'tb-tab-recommend', tabLabel: '推荐', tabActive: false }
    ];

    this.colorChips = [
      { chipKey: 'tb-color-black', chipLabel: '曜石黑', chipSelected: true },
      { chipKey: 'tb-color-blue', chipLabel: '远峰蓝', chipSelected: false }
    ];

    this.versionChips = [
      { chipKey: 'tb-ver-256', chipLabel: '12GB+256GB', chipSelected: true },
      { chipKey: 'tb-ver-512', chipLabel: '16GB+512GB', chipSelected: false }
    ];

    this.guaranteeItems = [
      { gKey: 'tb-g-free', gLabel: '极速包邮', gSymbol: $r('sys.symbol.ticket_fill') },
      { gKey: 'tb-g-auth', gLabel: '正品保障', gSymbol: $r('sys.symbol.checkmark_circle') },
      { gKey: 'tb-g-return', gLabel: '7天无理由', gSymbol: $r('sys.symbol.arrow_clockwise') }
    ];

    this.reviewTags = [
      { tagKey: 'tb-rt-screen', tagLabel: '屏幕清晰(892)' },
      { tagKey: 'tb-rt-hinge', tagLabel: '铰链顺滑(521)' },
      { tagKey: 'tb-rt-fast', tagLabel: '发货快(388)' }
    ];
  }

  /** 整页缩放比：窗口宽度 / 单屏态宽度（459.6vp） */
  private sceneScale(): number {
    if (this.winWidthVp <= 0) {
      return 1;
    }
    return this.winWidthVp / TB_BASE_WIDTH;
  }

  /** 把按单屏态量出的设计值换算到当前窗口 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  // ------------------------------------------------------------------
  // 顶部标签带：返回 + 商品/评价/详情/推荐 + 搜索 + 菜单点
  // ------------------------------------------------------------------

  @Builder
  moreDots() {
    Row({ space: this.vs(3) }) {
      Row()
        .width(this.vs(4))
        .height(this.vs(4))
        .borderRadius(this.vs(2))
        .backgroundColor('#333333')

      Row()
        .width(this.vs(4))
        .height(this.vs(4))
        .borderRadius(this.vs(2))
        .backgroundColor('#333333')

      Row()
        .width(this.vs(4))
        .height(this.vs(4))
        .borderRadius(this.vs(2))
        .backgroundColor('#333333')
    }
    .alignItems(VerticalAlign.Center)
    .margin({ right: this.vs(16) })
  }

  @Builder
  tabLabel(tab: TbDetailTab) {
    Column({ space: this.vs(3) }) {
      Text(tab.tabLabel)
        .fontSize(this.vs(TB_TAB_FONT))
        .fontWeight(tab.tabActive ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(tab.tabActive ? TB_BRAND_ORANGE : TB_TEXT)

      if (tab.tabActive) {
        Row()
          .width(this.vs(16))
          .height(this.vs(3))
          .borderRadius(this.vs(1.5))
          .backgroundColor(TB_BRAND_ORANGE)
      }
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  tabRow() {
    Row() {
      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(this.vs(24))
          .fontColor([TB_TEXT])
      }
      .width(this.vs(TB_TAB_ROW))
      .height(this.vs(TB_TAB_ROW))
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        this.pageStack.pop();
      })

      Row({ space: this.vs(TB_TAB_GAP) }) {
        ForEach(this.detailTabs, (tab: TbDetailTab) => {
          this.tabLabel(tab)
        }, (tab: TbDetailTab) => tab.tabKey)
      }
      .alignItems(VerticalAlign.Center)
      .margin({ left: this.vs(4) })

      Blank()

      SymbolGlyph($r('sys.symbol.magnifyingglass'))
        .fontSize(this.vs(19))
        .fontColor([TB_TEXT])
        .margin({ right: this.vs(16) })

      this.moreDots()
    }
    .width('100%')
    .height(this.vs(TB_TAB_ROW))
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  tabBand() {
    Stack({ alignContent: Alignment.Bottom }) {
      this.tabRow()
    }
    .width('100%')
    .height(TB_TAB_BAND)
    .backgroundColor(Color.White)
  }

  // ------------------------------------------------------------------
  // 大图占位
  // ------------------------------------------------------------------

  @Builder
  heroImage() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Text('官方立减 300')
        .fontSize(this.vs(12))
        .fontColor(Color.White)
        .padding({ left: this.vs(9), right: this.vs(9), top: this.vs(4), bottom: this.vs(4) })
        .borderRadius(this.vs(10))
        .backgroundColor('#80FF3B30')
        .position({ x: this.vs(12), y: this.vs(12) })

      Text('1/5')
        .fontSize(this.vs(10))
        .fontColor(Color.White)
        .padding({ left: this.vs(8), right: this.vs(8), top: this.vs(3), bottom: this.vs(3) })
        .borderRadius(this.vs(9))
        .backgroundColor('#4D000000')
        .margin({ right: this.vs(12), bottom: this.vs(12) })

      Text('折叠屏旗舰 · 悬停影像')
        .fontSize(this.vs(15))
        .fontWeight(FontWeight.Medium)
        .fontColor('#5C3A1E')
        .margin({ right: this.vs(12), bottom: this.vs(34) })
    }
    .width('100%')
    .height(this.vs(TB_HERO_IMAGE))
    .linearGradient({ angle: 135, colors: [['#FFC9A3', 0.0], ['#FF9C6E', 0.5], ['#F27A4E', 1.0]] })
  }

  // ------------------------------------------------------------------
  // 信息卡：价格 + 标题 + 保障
  // ------------------------------------------------------------------

  @Builder
  priceRow() {
    Row() {
      Text('¥')
        .fontSize(this.vs(17))
        .fontWeight(FontWeight.Bold)
        .fontColor(TB_PRICE_RED)

      Text('129')
        .fontSize(this.vs(28))
        .fontWeight(FontWeight.Bold)
        .fontColor(TB_PRICE_RED)
        .margin({ left: this.vs(2) })

      Text('红包补贴再省30')
        .fontSize(this.vs(10))
        .fontColor(TB_PRICE_RED)
        .padding({ left: this.vs(6), right: this.vs(6), top: this.vs(3), bottom: this.vs(3) })
        .borderRadius(this.vs(9))
        .border({ width: 0.5, color: TB_PRICE_RED })
        .margin({ left: this.vs(8) })

      Blank()

      Text('已售1000+')
        .fontSize(this.vs(11))
        .fontColor(TB_SUBTEXT)
    }
    .width('100%')
    .height(this.vs(46))
    .alignItems(VerticalAlign.Bottom)
  }

  @Builder
  guaranteeRow() {
    Row() {
      ForEach(this.guaranteeItems, (g: TbDetailGuarantee) => {
        Row({ space: this.vs(4) }) {
          SymbolGlyph(g.gSymbol)
            .fontSize(this.vs(14))
            .fontColor([TB_BRAND_ORANGE])

          Text(g.gLabel)
            .fontSize(this.vs(11.5))
            .fontColor('#666666')
        }
        .alignItems(VerticalAlign.Center)
        .margin({ right: this.vs(14) })
      }, (g: TbDetailGuarantee) => g.gKey)
    }
    .width('100%')
    .height(this.vs(32))
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  infoCard() {
    Column() {
      this.priceRow()

      Text('【旗舰直降】折叠屏手机 双屏协同 120Hz 护眼屏 悬停影像 免息分期')
        .fontSize(this.vs(TB_TITLE_FONT))
        .fontColor(TB_TEXT)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .lineHeight(this.vs(20))
        .margin({ top: this.vs(6) })

      this.guaranteeRow()
    }
    .width('100%')
    .padding({ left: this.vs(13), right: this.vs(13), top: this.vs(4), bottom: this.vs(4) })
    .backgroundColor(Color.White)
    .borderRadius(this.vs(TB_CARD_RADIUS))
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: this.vs(TB_CARD_GAP) })
  }

  // ------------------------------------------------------------------
  // SKU 卡
  // ------------------------------------------------------------------

  @Builder
  skuChip(chip: TbDetailSkuChip) {
    Text(chip.chipLabel)
      .fontSize(this.vs(12))
      .fontColor(chip.chipSelected ? TB_BRAND_ORANGE : '#333333')
      .height(this.vs(34))
      .padding({ left: this.vs(14), right: this.vs(14) })
      .borderRadius(this.vs(6))
      .backgroundColor(chip.chipSelected ? '#FFF1EA' : '#F5F5F5')
      .border({ width: chip.chipSelected ? 1 : 0, color: TB_BRAND_ORANGE })
      .textAlign(TextAlign.Center)
      .margin({ right: this.vs(10) })
  }

  @Builder
  skuRowLabel(rowLabel: string) {
    Text(rowLabel)
      .fontSize(this.vs(12))
      .fontColor(TB_SUBTEXT)
      .width(this.vs(58))
      .margin({ top: this.vs(9) })
  }

  @Builder
  skuCard() {
    Column({ space: this.vs(10) }) {
      Row() {
        Text('已选')
          .fontSize(this.vs(12))
          .fontColor(TB_SUBTEXT)
          .width(this.vs(58))

        Text('曜石黑，12GB+256GB，官方标配')
          .fontSize(this.vs(13))
          .fontWeight(FontWeight.Medium)
          .fontColor(TB_TEXT)

        Blank()

        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(this.vs(14))
          .fontColor([TB_SUBTEXT])
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Row({ space: this.vs(0) }) {
        this.skuRowLabel('颜色分类')

        ForEach(this.colorChips, (chip: TbDetailSkuChip) => {
          this.skuChip(chip)
        }, (chip: TbDetailSkuChip) => chip.chipKey)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Row({ space: this.vs(0) }) {
        this.skuRowLabel('版本')

        ForEach(this.versionChips, (chip: TbDetailSkuChip) => {
          this.skuChip(chip)
        }, (chip: TbDetailSkuChip) => chip.chipKey)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .padding({ left: this.vs(13), right: this.vs(13), top: this.vs(13), bottom: this.vs(13) })
    .backgroundColor(Color.White)
    .borderRadius(this.vs(TB_CARD_RADIUS))
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: this.vs(TB_CARD_GAP) })
  }

  // ------------------------------------------------------------------
  // 评价卡
  // ------------------------------------------------------------------

  @Builder
  reviewTagChip(tag: TbDetailReviewTag) {
    Text(tag.tagLabel)
      .fontSize(this.vs(10.5))
      .fontColor('#7A5B2E')
      .height(this.vs(22))
      .padding({ left: this.vs(8), right: this.vs(8) })
      .borderRadius(this.vs(11))
      .backgroundColor('#FBF3E4')
      .textAlign(TextAlign.Center)
      .margin({ right: this.vs(8) })
  }

  @Builder
  reviewCard() {
    Column({ space: this.vs(9) }) {
      Row() {
        Text('评价(1.2万)')
          .fontSize(this.vs(14))
          .fontWeight(FontWeight.Bold)
          .fontColor(TB_TEXT)

        Text('好评率 99%')
          .fontSize(this.vs(11))
          .fontColor(TB_SUBTEXT)
          .margin({ left: this.vs(8) })

        Blank()

        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(this.vs(14))
          .fontColor([TB_SUBTEXT])
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Row() {
        ForEach(this.reviewTags, (tag: TbDetailReviewTag) => {
          this.reviewTagChip(tag)
        }, (tag: TbDetailReviewTag) => tag.tagKey)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Text('铰链很顺滑，悬停看视频刚好，外屏折痕比上一代淡很多，值得入手。')
        .fontSize(this.vs(12))
        .fontColor('#444444')
        .maxLines(2)
        .lineHeight(this.vs(18))
    }
    .width('100%')
    .padding(this.vs(13))
    .backgroundColor(Color.White)
    .borderRadius(this.vs(TB_CARD_RADIUS))
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: this.vs(TB_CARD_GAP) })
  }

  // ------------------------------------------------------------------
  // 底部操作栏（固定尺寸）
  // ------------------------------------------------------------------

  @Builder
  bottomIconEntry(entryLabel: string, entrySymbol: Resource) {
    Column({ space: 2 }) {
      SymbolGlyph(entrySymbol)
        .fontSize(19)
        .fontColor(['#333333'])

      Text(entryLabel)
        .fontSize(9)
        .fontColor('#333333')
    }
    .width(42)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  bottomBar() {
    Row({ space: 8 }) {
      this.bottomIconEntry('店铺', $r('sys.symbol.store'))
      this.bottomIconEntry('客服', $r('sys.symbol.headphones'))
      this.bottomIconEntry('收藏', $r('sys.symbol.star'))

      Blank()

      Text('加入购物车')
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .width(96)
        .height(38)
        .borderRadius(19)
        .backgroundColor(TB_CART_ORANGE)
        .textAlign(TextAlign.Center)

      Text('立即购买')
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .width(104)
        .height(38)
        .borderRadius(19)
        .linearGradient({ angle: 90, colors: [['#FF6A00', 0.0], ['#FF2200', 1.0]] })
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height(TB_BOTTOM_BAR)
    .padding({ left: 10, right: 10 })
    .backgroundColor(Color.White)
    .alignItems(VerticalAlign.Center)
  }

  build() {
    NavDestination() {
      Column() {
        this.tabBand()

        Scroll(this.contentScroller) {
          Column() {
            this.heroImage()

            Column() {
              this.infoCard()
              this.skuCard()
              this.reviewCard()

              Row()
                .height(TB_BOTTOM_BAR)
            }
            .width('100%')
            .padding({ left: this.vs(TB_CARD_SIDE), right: this.vs(TB_CARD_SIDE) })
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

        this.bottomBar()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(TB_PAGE_BG)
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
