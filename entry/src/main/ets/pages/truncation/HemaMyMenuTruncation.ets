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
 * 反例：截断 / 盒马「我的」菜单截断
 *
 * 复刻盒马首页：顶部「收盒花 得美味」banner + 下方「下单返盒花」双列商品区，
 * 整页按「窗口宽度 / 459.6vp」等比放大（H5 rem 适配）；内容可上下滚动，
 * 右上角「我的」入口固定在窗口上，点开后是白色下拉菜单。
 *
 * 菜单卡片挂在「我的」按钮下方、贴右侧摆放，宽度 / 图标 / 字号 / 行高同样按
 * 宽度等比放大。菜单高度只跟窗口宽度走，不随窗口高度收敛，自身也不可滚动，
 * 底部直接由内容区（底部 TabBar 之上）硬裁切。
 *
 * 当前 Pura X Max 上（密度 2.75）：
 * 单屏态 459.6×672vp：菜单 206vp 高、距顶 104vp，完整可见；
 * 双屏态竖屏 664.7×939.6vp：菜单底部仍在 TabBar 之上，完整可见；
 * 双屏态横屏 939.6×664.7vp：菜单顶到 212.6vp、高 421vp，TabBar 之上只剩 580.7vp，
 * 最后一项「小镇客服」正好在 TabBar 上沿被裁掉一半——图标和文字都只剩上半截。
 *
 * 真实截图里被裁掉的是整行图标，为了让问题一眼可见，这里把裁切线对准了
 * 最后一项文字的中线；上下挪动 HEMA_MENU_TOP 即可移动裁切位置。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';
import { HemaTownScene, HemaTownTabBar, HEMA_TOWN_TAB_BAR_HEIGHT } from '../../common/HemaTownScene';

/** 缩放基准：单屏态窗口宽度（1264px / 2.75） */
const HEMA_MENU_REFERENCE_WIDTH: number = 459.6;

/**
 * 菜单卡片距内容区顶部（设计基准 vp）。
 * 双屏态横屏下第 5 行文字中心会落在 TabBar 上沿，正好被裁掉一半。
 */
const HEMA_MENU_TOP: number = 104;

/** 菜单卡片宽度（设计基准 vp） */
const HEMA_MENU_WIDTH: number = 122;

/** 菜单卡片距窗口右侧的留白，与顶部「我的」按钮右留白对齐（设计基准 vp） */
const HEMA_MENU_RIGHT_INSET: number = 22;

/** 顶部「我的」按钮距右侧的留白与按钮宽度，用来把气泡尖角对准按钮中心 */
const HEMA_MY_PILL_RIGHT_INSET: number = 22;
const HEMA_MY_PILL_WIDTH: number = 82;

/** 菜单行高 / 左右内边距 / 上下内边距（设计基准 vp） */
const HEMA_MENU_ROW_HEIGHT: number = 38;
const HEMA_MENU_PADDING_TOP: number = 7;
const HEMA_MENU_PADDING_BOTTOM: number = 7;

/** 气泡尖角（旋转 45° 的方块）边长 */
const HEMA_MENU_NOTCH_SIZE: number = 8;

/** 尖角中心距卡片右边缘：按钮右留白 + 按钮半宽 - 卡片右留白 */
const HEMA_MENU_NOTCH_FROM_RIGHT: number =
  HEMA_MY_PILL_RIGHT_INSET + HEMA_MY_PILL_WIDTH / 2 - HEMA_MENU_RIGHT_INSET;

interface HemaMyMenuEntry {
  entryLabel: string;
  entryIcon: Resource;
  entryIconBg: string;
}

const HEMA_MY_MENU_ENTRIES: HemaMyMenuEntry[] = [
  { entryLabel: '盒花明细', entryIcon: $r('sys.symbol.doc_plaintext_and_checkmark'), entryIconBg: '#3CB4E9' },
  { entryLabel: '我的背包', entryIcon: $r('sys.symbol.bag_fill'), entryIconBg: '#F5A93F' },
  { entryLabel: '规则攻略', entryIcon: $r('sys.symbol.doc_plaintext_and_pencil'), entryIconBg: '#8CC152' },
  { entryLabel: '消息通知', entryIcon: $r('sys.symbol.ellipsis_message_fill'), entryIconBg: '#8E7CF5' },
  { entryLabel: '小镇客服', entryIcon: $r('sys.symbol.headphones_fill'), entryIconBg: '#6FC6F2' }
];

/** 首页 banner 的设计高度（vp），超过部分由下方「下单返盒花」白底承接 */
const HEMA_HERO_HEIGHT: number = 340;

/** 商品图类型：0 = 防晒口罩，1 = 橙汁 */
const HEMA_PRODUCT_MASK: number = 0;
const HEMA_PRODUCT_JUICE: number = 1;

/** 「下单得盒花」按钮上的文案 */
const HEMA_PRODUCT_REWARD_TEXT: string = '下单得1888盒花';

interface HemaProductTag {
  tagLabel: string;
  tagColor: string;
}

interface HemaProductEntry {
  productName: string;
  productDesc: string;
  productPrice: string;
  productUnit: string;
  productOriginPrice: string;
  productTags: HemaProductTag[];
  productKind: number;
}

const HEMA_PRODUCTS: HemaProductEntry[] = [
  {
    productName: '蕉下 轻凉防晒口罩 AL218 漫暮黑 均码',
    productDesc: '原纱防晒UPF50+、防晒…',
    productPrice: '38',
    productUnit: '/个',
    productOriginPrice: '¥49',
    productTags: [
      { tagLabel: '快递配送', tagColor: '#3B82C4' },
      { tagLabel: '省 11元', tagColor: '#D64545' }
    ],
    productKind: HEMA_PRODUCT_MASK
  },
  {
    productName: '盒马 NFC赣南橙汁 300ml*15',
    productDesc: '一瓶约等于4个橙子原果…',
    productPrice: '83.9',
    productUnit: '/箱',
    productOriginPrice: '',
    productTags: [
      { tagLabel: '快递配送', tagColor: '#3B82C4' }
    ],
    productKind: HEMA_PRODUCT_JUICE
  }
];

@Component
export struct HemaMyMenuTruncationPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = HEMA_MENU_REFERENCE_WIDTH;
  @State winHeightVp: number = 672;

  /** 进入页面就展开菜单，方便直接观察裁切 */
  @State menuOpen: boolean = true;

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
      this.windowToken = WindowModeController.acquire(win, '#000000');
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  /** 整页等比缩放比：窗口宽度 / 单屏态宽度 */
  private uiScale(): number {
    const widthRatio: number = this.winWidthVp / HEMA_MENU_REFERENCE_WIDTH;
    return widthRatio < 1 ? 1 : widthRatio;
  }

  /** 把按单屏态（459.6vp）绘制的尺寸换算成当前窗口尺寸 */
  private vs(baseVp: number): number {
    return baseVp * this.uiScale();
  }

  /** 菜单卡片总高度：行高之和 + 上下内边距 + 行间分割线 */
  private menuHeightVp(): number {
    return HEMA_MENU_PADDING_TOP + HEMA_MENU_PADDING_BOTTOM +
      HEMA_MENU_ROW_HEIGHT * HEMA_MY_MENU_ENTRIES.length +
      (HEMA_MY_MENU_ENTRIES.length - 1) * 0.5;
  }

  @Builder
  menuEntryRow(entry: HemaMyMenuEntry, showDivider: boolean) {
    Column() {
      Row() {
        Stack({ alignContent: Alignment.Center }) {
          Row()
            .width(this.vs(22))
            .height(this.vs(22))
            .backgroundColor(entry.entryIconBg)
            .borderRadius(this.vs(11))

          SymbolGlyph(entry.entryIcon)
            .fontSize(this.vs(12))
            .fontColor([Color.White])
        }
        .width(this.vs(22))
        .height(this.vs(22))

        Text(entry.entryLabel)
          .fontSize(this.vs(16))
          .fontColor('#2B2F33')
          .maxLines(1)
          .margin({ left: this.vs(8) })
      }
      .width('100%')
      .height(this.vs(HEMA_MENU_ROW_HEIGHT))
      .padding({ left: this.vs(10) })
      .alignItems(VerticalAlign.Center)

      if (showDivider) {
        Divider()
          .strokeWidth(this.vs(0.5))
          .color('#F1EEE8')
          .margin({ left: this.vs(40), right: this.vs(10) })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  myMenu() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column() {
        ForEach(HEMA_MY_MENU_ENTRIES, (entry: HemaMyMenuEntry, index: number) => {
          this.menuEntryRow(entry, index < HEMA_MY_MENU_ENTRIES.length - 1)
        }, (entry: HemaMyMenuEntry) => entry.entryLabel)
      }
      .width(this.vs(HEMA_MENU_WIDTH))
      .padding({ top: this.vs(HEMA_MENU_PADDING_TOP), bottom: this.vs(HEMA_MENU_PADDING_BOTTOM) })
      .backgroundColor('#FFFDFB')
      .borderRadius(this.vs(14))
      .alignItems(HorizontalAlign.Start)

      // 指向「我的」按钮的气泡尖角
      Row()
        .width(this.vs(HEMA_MENU_NOTCH_SIZE))
        .height(this.vs(HEMA_MENU_NOTCH_SIZE))
        .backgroundColor('#FFFDFB')
        .rotate({ angle: 45 })
        .offset({
          x: -this.vs(HEMA_MENU_NOTCH_FROM_RIGHT - HEMA_MENU_NOTCH_SIZE / 2),
          y: -this.vs(HEMA_MENU_NOTCH_SIZE / 2)
        })
    }
    .width(this.vs(HEMA_MENU_WIDTH))
    .height(this.vs(this.menuHeightVp()))
    .position({
      x: this.winWidthVp - this.vs(HEMA_MENU_RIGHT_INSET + HEMA_MENU_WIDTH),
      y: this.vs(HEMA_MENU_TOP)
    })
  }

  @Builder
  productTagChip(tag: HemaProductTag) {
    Text(tag.tagLabel)
      .fontSize(this.vs(10))
      .fontColor(tag.tagColor)
      .height(this.vs(18))
      .padding({ left: this.vs(4), right: this.vs(4) })
      .border({ width: this.vs(0.5), color: tag.tagColor })
      .borderRadius(this.vs(3))
  }

  @Builder
  productRewardBar() {
    Row({ space: this.vs(5) }) {
      Stack({ alignContent: Alignment.Center }) {
        Row()
          .width(this.vs(20))
          .height(this.vs(20))
          .backgroundColor('#F5A93F')
          .borderRadius(this.vs(10))

        SymbolGlyph($r('sys.symbol.gift_fill'))
          .fontSize(this.vs(12))
          .fontColor([Color.White])
      }
      .width(this.vs(20))
      .height(this.vs(20))

      Text(HEMA_PRODUCT_REWARD_TEXT)
        .fontSize(this.vs(13.5))
        .fontWeight(FontWeight.Bold)
        .fontColor('#8A4A12')
        .maxLines(1)
    }
    .width('100%')
    .height(this.vs(32))
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#FFF1DE')
    .borderRadius(this.vs(16))
    .margin({ top: this.vs(10) })
  }

  /** 商品主图：本地图片资源，按卡片宽度铺满 */
  private productImage(kind: number): Resource {
    return kind === HEMA_PRODUCT_MASK ? $r('app.media.product_mask') : $r('app.media.product_juice');
  }

  @Builder
  productArt(kind: number) {
    Image(this.productImage(kind))
      .width('100%')
      .height(this.vs(190))
      .objectFit(ImageFit.Contain)
      .backgroundColor(Color.White)
      .draggable(false)
  }

  @Builder
  productCard(product: HemaProductEntry) {
    Column() {
      this.productArt(product.productKind)

      Column() {
        Text(product.productName)
          .fontSize(this.vs(15))
          .lineHeight(this.vs(20))
          .fontColor('#1F1F1F')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Text(product.productDesc)
          .fontSize(this.vs(12))
          .fontColor('#8C8C8C')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ top: this.vs(4) })

        Row({ space: this.vs(6) }) {
          ForEach(product.productTags, (tag: HemaProductTag) => {
            this.productTagChip(tag)
          }, (tag: HemaProductTag) => tag.tagLabel)
        }
        .margin({ top: this.vs(6) })

        Row({ space: this.vs(2) }) {
          Text('¥')
            .fontSize(this.vs(11))
            .fontColor('#D9302C')
          Text(product.productPrice)
            .fontSize(this.vs(22))
            .fontWeight(FontWeight.Bold)
            .fontColor('#D9302C')
          Text(product.productUnit)
            .fontSize(this.vs(11))
            .fontColor('#9A9A9A')

          if (product.productOriginPrice.length > 0) {
            Text(product.productOriginPrice)
              .fontSize(this.vs(11))
              .fontColor('#B0B0B0')
              .decoration({ type: TextDecorationType.LineThrough, color: '#B0B0B0' })
              .margin({ left: this.vs(4) })
          }
        }
        .margin({ top: this.vs(6) })
        .alignItems(VerticalAlign.Bottom)

        this.productRewardBar()
      }
      .width('100%')
      .padding({ left: this.vs(10), right: this.vs(10), top: this.vs(8), bottom: this.vs(10) })
      .alignItems(HorizontalAlign.Start)
    }
    .layoutWeight(1)
    .backgroundColor(Color.White)
    .borderRadius(this.vs(10))
    .clip(true)
  }

  /** 首页下方「下单返盒花」商品区 */
  @Builder
  productSheet() {
    Column() {
      Text('下单返盒花')
        .fontSize(this.vs(22))
        .fontWeight(FontWeight.Bold)
        .fontColor('#4A2C10')
        .margin({ left: this.vs(4), top: this.vs(18), bottom: this.vs(14) })

      Row({ space: this.vs(12) }) {
        ForEach(HEMA_PRODUCTS, (product: HemaProductEntry) => {
          this.productCard(product)
        }, (product: HemaProductEntry) => product.productName)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .padding({ left: this.vs(16), right: this.vs(16), bottom: this.vs(24) })
    .backgroundColor('#F3F3F4')
    .borderRadius({ topLeft: this.vs(16), topRight: this.vs(16) })
    .alignItems(HorizontalAlign.Start)
  }

  /** 固定在窗口右上角的「我的」入口，不随首页内容滚动 */
  @Builder
  fixedMyEntry() {
    Row({ space: this.vs(6) }) {
      SymbolGlyph($r('sys.symbol.person'))
        .fontSize(this.vs(18))
        .fontColor(['#F1E4D0'])
      Text('我的')
        .fontSize(this.vs(14))
        .fontColor('#F1E4D0')
    }
    .width(this.vs(HEMA_MY_PILL_WIDTH))
    .height(this.vs(36))
    .padding({ left: this.vs(14), right: this.vs(16) })
    .border({ width: this.vs(1), color: '#A9BAC7' })
    .borderRadius(this.vs(18))
    .backgroundColor('#40566B')
    .position({
      x: this.winWidthVp - this.vs(HEMA_MY_PILL_RIGHT_INSET + HEMA_MY_PILL_WIDTH),
      y: this.vs(58)
    })
    .onClick(() => {
      this.menuOpen = true;
    })
  }

  build() {
    NavDestination() {
      Column() {
        Stack({ alignContent: Alignment.TopStart }) {
          Scroll() {
            Column() {
              HemaTownScene({
                sceneScale: this.uiScale(),
                sceneHeightVp: this.winHeightVp,
                sceneViewportVp: this.vs(HEMA_HERO_HEIGHT),
                sceneMyEntryVisible: false
              })

              this.productSheet()
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .height('100%')
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)

          this.fixedMyEntry()

          // 点空白处收起菜单
          if (this.menuOpen) {
            Column()
              .width('100%')
              .height('100%')
              .onClick(() => {
                this.menuOpen = false;
              })
          }

          if (this.menuOpen) {
            this.myMenu()
          }
        }
        .width('100%')
        .layoutWeight(1)
        .clip(true)

        HemaTownTabBar()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#7A96B8')
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
