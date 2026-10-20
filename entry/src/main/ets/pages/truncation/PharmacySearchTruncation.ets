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
 * 反例：截断 / 看病买药搜索框截断（文字截断）
 *
 * 复刻美团「看病买药」首页：黄色渐变头部（返回 + 看病买药 + 定位 + 购物车）、
 * 白底搜索框、频道栏（推荐 / 问医生 / 做检测 / 成人情趣 / 器械 / 滋补保健），
 * 下面是「24h服务」九宫格、「秒问医生」、「新人专享特惠」、商品横排、美团补贴广告位
 * 以及底部 TabBar。
 *
 * 头部与卡片尺寸都按单屏态截图（459.6×672vp，密度 2.75）量出的设计值摆放：
 *   单屏态        459.6×672vp  —— 正常
 *   双屏态竖屏    664.7×939.6vp —— 正常
 *   双屏态横屏    939.6×664.7vp —— 搜索框上面一半被裁掉
 *
 * 问题表现（双屏态横屏）：
 *   贴着「看病买药」标题行下沿露出白色，占位文字、相机图标、「搜索」
 *   都只剩下半截，看起来像是搜索框被上面的黄色标题区压掉了一半。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 单屏态窗口宽度（1264px / 密度 2.75），用于把设计稿 vp 对齐到当前窗口 */
const PHARMACY_REFERENCE_WIDTH: number = 459.6;

/** 头部各段高度（vp）：标题行 / 搜索框 / 频道栏 */
const PHARMACY_TITLE_BAR_HEIGHT: number = 49;
const PHARMACY_SEARCH_BAR_HEIGHT: number = 35;
const PHARMACY_CHANNEL_BAR_HEIGHT: number = 49;

/** 搜索框、频道栏的左右留白（vp） */
const PHARMACY_SEARCH_SIDE_INSET: number = 8.5;

/** 频道栏选中态胶囊高度（vp） */
const PHARMACY_CHANNEL_PILL_HEIGHT: number = 27;

/** 横屏紧凑态下搜索区的上提量：搜索框高度的一半 */
const PHARMACY_COMPACT_LIFT: number = PHARMACY_SEARCH_BAR_HEIGHT / 2;

/** 九宫格每列宽度占窗口宽度的比例：6 列合计 105%，第 6 列露出一半（与原图一致） */
const PHARMACY_QUICK_CELL_RATIO: number = 0.175;

/** 状态栏 / 底部手势区兜底高度（vp），拿不到避让区时使用 */
const PHARMACY_STATUS_BAR_FALLBACK: number = 32;
const PHARMACY_BOTTOM_INSET_FALLBACK: number = 8;

/** 页面底色与黄色渐变 */
const PHARMACY_PAGE_BG: string = '#F6F6F7';

interface PharmacyQuickEntry {
  entryLabel: string;
  entryIcon: Resource;
  entryTint: string;
}

/** 「24h服务」九宫格条目，两行各 6 个 */
const PHARMACY_QUICK_ENTRIES: PharmacyQuickEntry[] = [
  { entryLabel: '感冒发烧', entryIcon: $r('sys.symbol.cross_case_fill'), entryTint: '#3FAE6A' },
  { entryLabel: '儿童用药', entryIcon: $r('sys.symbol.person_2'), entryTint: '#E8663F' },
  { entryLabel: '妇科用药', entryIcon: $r('sys.symbol.heart'), entryTint: '#3E8FE8' },
  { entryLabel: '避孕测孕', entryIcon: $r('sys.symbol.checkmark_circle'), entryTint: '#E8A13F' },
  { entryLabel: '肠胃消化', entryIcon: $r('sys.symbol.leaf'), entryTint: '#3FAE6A' },
  { entryLabel: '咳嗽咳痰', entryIcon: $r('sys.symbol.thermometer'), entryTint: '#D64545' },
  { entryLabel: '医保买药', entryIcon: $r('sys.symbol.star_circle'), entryTint: '#3E8FE8' },
  { entryLabel: '原研药', entryIcon: $r('sys.symbol.doc_text'), entryTint: '#3E8FE8' },
  { entryLabel: '自营大药房', entryIcon: $r('sys.symbol.house_fill'), entryTint: '#E8A13F' },
  { entryLabel: '口腔/看牙', entryIcon: $r('sys.symbol.face_smiling'), entryTint: '#3E8FE8' },
  { entryLabel: '妇儿医院', entryIcon: $r('sys.symbol.hospital'), entryTint: '#E8628A' },
  { entryLabel: '眼科/配镜', entryIcon: $r('sys.symbol.eye'), entryTint: '#7A6FE8' }
];

/** 频道栏：第一项「推荐」是选中态（白底胶囊），其余为普通文字 */
const PHARMACY_CHANNEL_TABS: string[] = ['问医生', '做检测', '成人情趣', '器械', '滋补保健'];

interface PharmacyTabEntry {
  tabLabel: string;
  tabIcon: Resource;
  tabActive: boolean;
}

/** 底部 TabBar */
const PHARMACY_TAB_ENTRIES: PharmacyTabEntry[] = [
  { tabLabel: '买药', tabIcon: $r('sys.symbol.cross_case_fill'), tabActive: true },
  { tabLabel: '健康档案', tabIcon: $r('sys.symbol.house'), tabActive: false },
  { tabLabel: '小团健康管家', tabIcon: $r('sys.symbol.face_smiling'), tabActive: false },
  { tabLabel: '订单', tabIcon: $r('sys.symbol.doc_text'), tabActive: false },
  { tabLabel: '我的', tabIcon: $r('sys.symbol.person'), tabActive: false }
];

interface PharmacyProductEntry {
  productBrand: string;
  productName: string;
  productDiscount: string;
  productPrice: string;
}

/** 新人专区下方的「抢」商品横排 */
const PHARMACY_PRODUCTS: PharmacyProductEntry[] = [
  {
    productBrand: '999',
    productName: '感冒灵颗粒',
    productDiscount: '减¥4.2',
    productPrice: '10.8'
  },
  {
    productBrand: '江中',
    productName: '健胃消食片',
    productDiscount: '减¥4.59',
    productPrice: '6.4'
  },
  {
    productBrand: '999',
    productName: '小儿氨酚黄那敏颗粒',
    productDiscount: '减¥20.8',
    productPrice: '8.2'
  }
];

@Component
export struct PharmacySearchTruncationPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = PHARMACY_REFERENCE_WIDTH;
  @State winHeightVp: number = 672;
  /** 沉浸式下的状态栏 / 底部手势区高度（vp） */
  @State statusBarHeightVp: number = PHARMACY_STATUS_BAR_FALLBACK;
  @State bottomInsetVp: number = PHARMACY_BOTTOM_INSET_FALLBACK;

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
      this.windowToken = WindowModeController.acquire(win, '#000000');
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  /** 搜索区整体上提量：横屏（窗口宽 > 高）上提半个搜索框，竖屏不上提 */
  private searchZoneLiftVp(): number {
    if (this.winWidthVp > this.winHeightVp) {
      return PHARMACY_COMPACT_LIFT;
    }
    return 0;
  }

  /** 搜索区（搜索框 + 频道栏）容器高度 */
  private searchZoneHeightVp(): number {
    return PHARMACY_SEARCH_BAR_HEIGHT + PHARMACY_CHANNEL_BAR_HEIGHT - this.searchZoneLiftVp();
  }

  /** 头部总高度（不含状态栏） */
  private headerHeightVp(): number {
    return PHARMACY_TITLE_BAR_HEIGHT + this.searchZoneHeightVp();
  }

  /** 黄色渐变背景高度：头部 + 向下渐隐的一段，与原图渐变范围一致 */
  private gradientHeightVp(): number {
    return this.statusBarHeightVp + this.headerHeightVp() + 150;
  }

  /** 九宫格单列宽度：按窗口宽度百分比排布，6 列合计超出卡片，第 6 列被裁一半 */
  private quickCellWidthVp(): number {
    return this.winWidthVp * PHARMACY_QUICK_CELL_RATIO;
  }

  // ------------------------------------------------------------------
  // 头部
  // ------------------------------------------------------------------

  @Builder
  titleBar() {
    Row({ space: 4 }) {
      SymbolGlyph($r('sys.symbol.chevron_left'))
        .fontSize(22)
        .fontColor(['#1A1A1A'])
        .onClick(() => {
          this.pageStack.pop();
        })

      Text('看病买药')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')
        .maxLines(1)

      SymbolGlyph($r('sys.symbol.pin'))
        .fontSize(13)
        .fontColor(['#1A1A1A'])
        .margin({ left: 8 })

      Text('华为练秋湖研发中心G区')
        .fontSize(17)
        .fontColor('#1A1A1A')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(13)
        .fontColor(['#1A1A1A'])

      SymbolGlyph($r('sys.symbol.cart'))
        .fontSize(23)
        .fontColor(['#1A1A1A'])
        .margin({ left: 8 })
    }
    .width('100%')
    .height(PHARMACY_TITLE_BAR_HEIGHT)
    .padding({ left: 6, right: 12 })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  searchBar() {
    Row({ space: 6 }) {
      SymbolGlyph($r('sys.symbol.magnifyingglass'))
        .fontSize(18)
        .fontColor(['#5C5C5C'])

      Text('头孢')
        .fontSize(19)
        .fontWeight(FontWeight.Medium)
        .fontColor('#3A3A3A')
        .maxLines(1)
        .layoutWeight(1)

      SymbolGlyph($r('sys.symbol.camera'))
        .fontSize(20)
        .fontColor(['#3A3A3A'])

      Divider()
        .vertical(true)
        .height(20)
        .strokeWidth(0.5)
        .color('#DCDCDC')
        .margin({ left: 2, right: 2 })

      Text('搜索')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1A1A')
    }
    .width('100%')
    .height(PHARMACY_SEARCH_BAR_HEIGHT)
    .padding({ left: 12, right: 12 })
    .backgroundColor(Color.White)
    .borderRadius(PHARMACY_SEARCH_BAR_HEIGHT / 2)
    .alignItems(VerticalAlign.Center)
  }

  /** 频道栏选中态：白底胶囊 + 指向下方的小尖角 */
  @Builder
  channelActivePill() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Row({ space: 4 }) {
        SymbolGlyph($r('sys.symbol.face_smiling'))
          .fontSize(15)
          .fontColor(['#1A1A1A'])

        Text('推荐')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
      }
      .height(PHARMACY_CHANNEL_PILL_HEIGHT)
      .padding({ left: 10, right: 12 })
      .backgroundColor(Color.White)
      .borderRadius(PHARMACY_CHANNEL_PILL_HEIGHT / 2)
      .alignItems(VerticalAlign.Center)

      Row()
        .width(9)
        .height(9)
        .backgroundColor(Color.White)
        .rotate({ angle: 45 })
        .offset({ x: 8, y: 3 })
    }
    .height(PHARMACY_CHANNEL_PILL_HEIGHT + 4)
  }

  @Builder
  channelBar() {
    Row({ space: 18 }) {
      this.channelActivePill()

      ForEach(PHARMACY_CHANNEL_TABS, (tabLabel: string) => {
        Text(tabLabel)
          .fontSize(17)
          .fontColor('#1A1A1A')
          .maxLines(1)
      }, (tabLabel: string) => tabLabel)
    }
    .width('100%')
    .height(PHARMACY_CHANNEL_BAR_HEIGHT)
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
  }

  /**
   * 搜索区：搜索框 + 频道栏。
   * 容器开了 clip，内容整体按 searchZoneLiftVp() 上提——
   * 横屏时上提半个搜索框、容器又少一半高度，搜索框上半截就被上沿切掉。
   */
  @Builder
  searchZone() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        this.searchBar()
        this.channelBar()
      }
      .width('100%')
      .padding({ left: PHARMACY_SEARCH_SIDE_INSET, right: PHARMACY_SEARCH_SIDE_INSET })
      .offset({ y: -this.searchZoneLiftVp() })
    }
    .width('100%')
    .height(this.searchZoneHeightVp())
    .clip(true)
  }

  // ------------------------------------------------------------------
  // 内容卡片
  // ------------------------------------------------------------------

  @Builder
  quickEntryCell(entry: PharmacyQuickEntry) {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width(38)
          .height(38)
          .backgroundColor('#F7F7F8')
          .borderRadius(12)

        SymbolGlyph(entry.entryIcon)
          .fontSize(20)
          .fontColor([entry.entryTint])
      }
      .width(38)
      .height(38)

      Text(entry.entryLabel)
        .fontSize(12.5)
        .fontColor('#1A1A1A')
        .maxLines(1)
        .margin({ top: 6 })
    }
    .width(this.quickCellWidthVp())
    .alignItems(HorizontalAlign.Center)
    .padding({ bottom: 10 })
  }

  @Builder
  quickEntryRow(entries: PharmacyQuickEntry[]) {
    Row() {
      ForEach(entries, (entry: PharmacyQuickEntry) => {
        this.quickEntryCell(entry)
      }, (entry: PharmacyQuickEntry) => entry.entryLabel)
    }
    .width('100%')
  }

  @Builder
  serviceCard() {
    Column() {
      Row() {
        Row({ space: 2 }) {
          SymbolGlyph($r('sys.symbol.arrow_clockwise'))
            .fontSize(19)
            .fontColor(['#F2A93B'])

          Text('24h服务')
            .fontSize(21)
            .fontWeight(FontWeight.Bold)
            .fontStyle(FontStyle.Italic)
            .fontColor('#1A1A1A')
        }
        .alignItems(VerticalAlign.Center)

        Blank()

        Row({ space: 2 }) {
          Text('上海市·健康防护指引')
            .fontSize(13)
            .fontColor('#8C8C8C')

          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontSize(11)
            .fontColor(['#8C8C8C'])
        }
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height(34)
      .padding({ left: 4, right: 4 })

      this.quickEntryRow(PHARMACY_QUICK_ENTRIES.slice(0, 6))
      this.quickEntryRow(PHARMACY_QUICK_ENTRIES.slice(6, 12))

      Row({ space: 4 }) {
        Row()
          .width(14)
          .height(3)
          .backgroundColor('#F2C230')
          .borderRadius(2)

        Row()
          .width(5)
          .height(5)
          .backgroundColor('#E4E4E4')
          .borderRadius(3)
      }
      .width('100%')
      .height(12)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 10, bottom: 6 })
    .backgroundColor(Color.White)
    .borderRadius(14)
    .clip(true)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  askDoctorCard() {
    Row() {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width(42)
          .height(42)
          .backgroundColor('#E8F4F0')
          .borderRadius(21)

        SymbolGlyph($r('sys.symbol.person'))
          .fontSize(24)
          .fontColor(['#3E9C86'])
      }
      .width(42)
      .height(42)

      Column({ space: 4 }) {
        Row({ space: 6 }) {
          Text('秒问医生')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A')

          Text('⚡9秒接诊')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#F08A24')
        }
        .alignItems(VerticalAlign.Center)

        Row({ space: 2 }) {
          Text('您有')
            .fontSize(13)
            .fontColor('#8C8C8C')

          Text('15元')
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor('#E2452B')

          Text('问诊补贴待使用')
            .fontSize(13)
            .fontColor('#8C8C8C')

          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontSize(10)
            .fontColor(['#B0B0B0'])
        }
        .alignItems(VerticalAlign.Center)
      }
      .layoutWeight(1)
      .margin({ left: 10 })
      .alignItems(HorizontalAlign.Start)

      Text('去问诊')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .height(34)
        .padding({ left: 18, right: 18 })
        .backgroundColor('#25C3A4')
        .borderRadius(17)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 12, bottom: 12 })
    .backgroundColor(Color.White)
    .borderRadius(14)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  newUserCard() {
    Column() {
      Row() {
        Text('新人专享特惠')
          .fontSize(19)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)

        Text('全场0元起送 配送费减免')
          .fontSize(19)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ left: 8 })
          .layoutWeight(1)

        Text('更多')
          .fontSize(13)
          .fontColor(Color.White)

        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(11)
          .fontColor([Color.White])
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Row() {
        Row() {
          Text('¥')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#E2452B')

          Text('6')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor('#E2452B')
            .margin({ right: 8 })
        }
        .alignItems(VerticalAlign.Bottom)

        Column({ space: 2 }) {
          Text('医药新客专享红包')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#E2452B')

          Text('无门槛')
            .fontSize(12)
            .fontColor('#8C8C8C')
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Column({ space: 6 }) {
          Text('6元券包')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#E2452B')

          Text('一键领取')
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .height(26)
            .padding({ left: 12, right: 12 })
            .backgroundColor('#F26550')
            .borderRadius(13)
            .textAlign(TextAlign.Center)
        }
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 10, bottom: 10 })
      .backgroundColor('#FFF8F6')
      .borderRadius(10)
      .margin({ top: 10 })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 12, bottom: 12 })
    .linearGradient({ angle: 90, colors: [['#FF7A6B', 0.0], ['#FF9C86', 1.0]] })
    .borderRadius(14)
    .clip(true)
    .alignItems(HorizontalAlign.Start)
  }

  /** 商品图：没有图片资源，用浅灰底 + 药盒示意图代替 */
  @Builder
  productArt(product: PharmacyProductEntry) {
    Stack({ alignContent: Alignment.BottomStart }) {
      Column()
        .width('100%')
        .height(92)
        .backgroundColor('#F4F6F5')
        .borderRadius(8)

      Column({ space: 3 }) {
        Text(product.productBrand)
          .fontSize(9)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')

        Text(product.productName)
          .fontSize(8)
          .fontColor('#6B6B6B')
          .maxLines(2)
          .textAlign(TextAlign.Center)
          .padding({ left: 4, right: 4 })
      }
      .width('66%')
      .height(56)
      .backgroundColor(Color.White)
      .borderRadius(4)
      .border({ width: 0.5, color: '#E2E5E3' })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .position({ x: '17%', y: 18 })

      Text(product.productDiscount)
        .fontSize(10)
        .fontColor('#E2452B')
        .height(15)
        .padding({ left: 4, right: 4 })
        .backgroundColor('#FDEBE7')
        .borderRadius(3)
        .margin({ left: 4, bottom: 4 })
    }
    .width('100%')
    .height(92)
  }

  @Builder
  productCard(product: PharmacyProductEntry) {
    Column() {
      this.productArt(product)

      Text(product.productName)
        .fontSize(13)
        .fontColor('#1A1A1A')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .margin({ top: 6 })

      Row() {
        Text('¥')
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')

        Text(product.productPrice)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .layoutWeight(1)

        Text('抢')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
          .width(24)
          .height(24)
          .backgroundColor('#FFD93B')
          .borderRadius(12)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .margin({ top: 2 })
      .alignItems(VerticalAlign.Bottom)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  productRow() {
    Row({ space: 10 }) {
      ForEach(PHARMACY_PRODUCTS, (product: PharmacyProductEntry) => {
        this.productCard(product)
      }, (product: PharmacyProductEntry) => product.productName)
    }
    .width('100%')
    .padding({ left: 10, right: 10, top: 10, bottom: 10 })
    .backgroundColor(Color.White)
    .borderRadius(14)
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  tabBarItem(entry: PharmacyTabEntry) {
    Column() {
      if (entry.tabActive) {
        Text(entry.tabLabel)
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .width(32)
          .height(32)
          .backgroundColor('#FFD93B')
          .borderRadius(16)
          .textAlign(TextAlign.Center)
      } else {
        SymbolGlyph(entry.tabIcon)
          .fontSize(23)
          .fontColor(['#3A3A3A'])
          .width(32)
          .height(32)

        Text(entry.tabLabel)
          .fontSize(11)
          .fontColor('#1A1A1A')
          .maxLines(1)
          .margin({ top: 3 })
      }
    }
    .layoutWeight(1)
    .height(52)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  /** 底部「美团补贴」广告位 */
  @Builder
  subsidyBanner() {
    Row() {
      Column({ space: 8 }) {
        Row({ space: 6 }) {
          Text('美团补贴')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A')

          Text('抢大额券')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .height(26)
            .padding({ left: 10, right: 10 })
            .backgroundColor('#FF4B33')
            .borderRadius(6)
            .textAlign(TextAlign.Center)
        }
        .alignItems(VerticalAlign.Center)

        Text('每日10点开抢 · 领券买药更省')
          .fontSize(12)
          .fontColor('#8C8C8C')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 14 })

      Stack({ alignContent: Alignment.TopEnd }) {
        Column()
          .width(150)
          .height(96)
          .linearGradient({ angle: 135, colors: [['#F6EEDF', 0.0], ['#E7D9C2', 1.0]] })

        Text('广告')
          .fontSize(9)
          .fontColor('#8C8C8C')
          .height(14)
          .padding({ left: 4, right: 4 })
          .backgroundColor('#F2F2F2')
          .borderRadius(2)
          .margin({ top: 6, right: 6 })
      }
      .width(150)
      .height(96)
    }
    .width('100%')
    .height(96)
    .backgroundColor(Color.White)
    .borderRadius(14)
    .clip(true)
  }

  @Builder
  bottomTabBar() {
    Row() {
      ForEach(PHARMACY_TAB_ENTRIES, (entry: PharmacyTabEntry) => {
        this.tabBarItem(entry)
      }, (entry: PharmacyTabEntry) => entry.tabLabel)
    }
    .width('100%')
    .height(56)
    .padding({ left: 6, right: 6 })
    .backgroundColor(Color.White)
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        // ① 黄色渐变背景：盖住状态栏与整个头部，向下渐隐到页面底色
        Column()
          .width('100%')
          .height(this.gradientHeightVp())
          .linearGradient({
            angle: 180,
            colors: [['#FBF58C', 0.0], ['#FBF294', 0.62], [PHARMACY_PAGE_BG, 1.0]]
          })

        Column() {
          // ② 头部：标题行 + 搜索区（搜索框 + 频道栏）
          //    注意 height 含 padding，所以要把状态栏高度加进去
          Column() {
            this.titleBar()
            this.searchZone()
          }
          .width('100%')
          .height(this.statusBarHeightVp + this.headerHeightVp())
          .padding({ top: this.statusBarHeightVp })

          // ③ 内容区
          Scroll() {
            Column({ space: 8 }) {
              this.serviceCard()
              this.askDoctorCard()
              this.newUserCard()
              this.productRow()
              this.subsidyBanner()
            }
            .width('100%')
            .padding({ left: PHARMACY_SEARCH_SIDE_INSET, right: PHARMACY_SEARCH_SIDE_INSET, top: 4, bottom: 8 })
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .align(Alignment.Top)

          // ④ 底部 TabBar + 手势区避让
          Column() {
            this.bottomTabBar()
          }
          .width('100%')
          .padding({ bottom: this.bottomInsetVp })
          .backgroundColor(Color.White)
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor(PHARMACY_PAGE_BG)
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
