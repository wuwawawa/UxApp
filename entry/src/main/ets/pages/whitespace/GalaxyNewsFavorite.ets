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
 * 反例：留白过多 / 银河资讯收藏页整屏空白
 *
 * 复刻对象：银河证券 App「银河资讯」页的「收藏」标签，双屏横屏。顶部深紫色头部
 *   （#454CC0，高 144.4vp）一直盖到状态栏：左上白色返回箭头「‹」、居中白色标题
 *   「银河资讯」、右上白色「智能分析」；头部下半是 6 个等分铺满整宽的标签
 *   （要闻 / 自选 / 7×24 / 发现 / 投资日历 / 收藏），「收藏」白色加粗、下方一条白色
 *   短下划线，其余标签是半透明白字。标签下方浅灰底（#F4F5F7）：居中一行浅灰小字
 *   「没有更多了」；再下面一段左对齐的深灰免责声明小字（左右各缩进 18.2vp），
 *   参考窗口下排成两行；再往下直到窗口底边没有任何内容。
 *
 * 设计基准：截图 3184×2232px，密度 2.75，vp = px / 2.75（参考窗口 1157.8×811.6vp）。
 *   紫色头部：397px → 144.4vp；其中状态栏占位 33vp、标题行 73vp、标签行 38.4vp；
 *   标题行：标题字 57.5px → 21vp（4 字墨迹宽 230px），墨迹 y 164～218px → 中心 69.5vp；
 *     「智能分析」字 44.75px → 16.5vp，右缘距窗口右边 49px → 17.8vp；
 *     返回箭头 23×43px → 8.4×15.6vp，笔画 6px → 1.5vp，左缘 56px → 20.4vp；
 *   标签行：标签字 50px → 18vp，墨迹 y 305～353px → 中心 y 119.6vp；
 *     下划线 43×9px → 15.6×3.3vp，顶边 y 379px → 137.8vp，距头部底边 3.3vp；
 *   空态提示：「没有更多了」5 字墨迹宽 194px、字高 37px → 字 14vp，墨迹 y 448～484px
 *     → 162.9～176vp，水平居中，距头部底边 52px → 18.9vp；
 *   免责声明：字 38.5px → 14vp（每字横向占位 = 字号），行距 65px → 23.6vp，
 *     首行墨迹顶 585px → 212.7vp，左右墨迹距窗口边 50 / 49px → 18.2 / 17.8vp，
 *     全文 134 字，参考窗口下每行 80 字、排成 2 行。
 *
 * 三态实测（头部高度、字号、行高都按上面写死的 vp 值，不随窗口宽度缩放；
 *   免责声明每行可容纳字数 =（窗口宽 − 左右缩进 36.4vp）/ 14vp）：
 *   单屏态      459.6×672vp   —— 每行 30 字，免责声明 5 行、高 118vp，内容止于 y 325vp，
 *                                下面空 347vp，约占高度的 52%；
 *   双屏态竖屏  664.7×939.6vp —— 每行 44 字，免责声明 4 行、高 94.4vp，内容止于 y 301.4vp，
 *                                下面空 638.2vp，约占高度的 68%；
 *   双屏态横屏  939.6×664.7vp —— 每行 64 字，免责声明 3 行、高 70.8vp，内容止于 y 277.8vp，
 *                                下面空 386.9vp，约占高度的 58%。
 *   参考窗口 1157.8×811.6vp 下：每行 80 字，免责声明 2 行、高 47.2vp，内容止于 y 254.2vp，
 *   下面空 557.4vp，约占高度的 69%。
 *
 * 问题表现：
 *   「没有更多了」之后只跟着一段免责声明，这段文字底部到窗口底边之间是一整片纯浅灰，
 *   横跨整宽、没有任何卡片、分隔线或其它元素；
 *   纵向看内容只占窗口高度的一半以下（参考窗口下不足三成），其余全是背景色；
 *   横向看免责声明铺满整宽，但它上面只有一行居中小字，两段文字之间没有任何内容承接。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 配色：紫色头部 #454CC0、浅灰页面 #F4F5F7、头部白字、提示与免责声明两级灰 */
const WSGX_HEADER_BG: string = '#454CC0';
const WSGX_PAGE_BG: string = '#F4F5F7';
const WSGX_HEADER_TEXT: string = '#FFFFFF';
const WSGX_EMPTY_TEXT: string = '#7D7E80';
const WSGX_TIP_TEXT: string = '#6D6E72';
const WSGX_TAB_IDLE_OPACITY: number = 0.6;
const WSGX_TRANSPARENT: string = '#00FFFFFF';

/** 紫色头部：总高 144.4vp（397px）= 状态栏占位 33 + 标题行 73 + 标签行 38.4 */
const WSGX_HEADER_HEIGHT: number = 144.4;
const WSGX_STATUS_PAD: number = 33;
const WSGX_TITLE_ROW_HEIGHT: number = 73;
const WSGX_TAB_ROW_HEIGHT: number = 38.4;

/** 标题行：标题 21vp；「智能分析」16.5vp、右边距 17.8vp；返回箭头 8.4×15.6vp、左缘 20.4vp */
const WSGX_TITLE_FONT: number = 21;
const WSGX_ACTION_FONT: number = 16.5;
const WSGX_ACTION_PAD_RIGHT: number = 17.8;
const WSGX_BACK_PAD_LEFT: number = 20.4;
const WSGX_BACK_WIDTH: number = 8.4;
const WSGX_BACK_HEIGHT: number = 15.6;
const WSGX_BACK_STROKE: number = 1.5;
/** 箭头两段斜笔：单段长 11.46vp、倾角 42.88°，各上下偏 3.9vp 拼成「‹」 */
const WSGX_BACK_LEG: number = 11.46;
const WSGX_BACK_LEG_ANGLE: number = 42.88;
const WSGX_BACK_LEG_OFFSET: number = 3.9;

/** 标签行：标签字 18vp、文字框高 24vp、文字框顶距 1.6vp */
const WSGX_TAB_FONT: number = 18;
const WSGX_TAB_TEXT_HEIGHT: number = 24;
const WSGX_TAB_PAD_TOP: number = 1.6;

/** 选中标签的下划线：15.6×3.3vp，距文字框 6.2vp */
const WSGX_TAB_UNDERLINE_W: number = 15.6;
const WSGX_TAB_UNDERLINE_H: number = 3.3;
const WSGX_TAB_UNDERLINE_GAP: number = 6.2;

/** 空态提示「没有更多了」：14vp、行高 24vp、距头部底边 13.1vp */
const WSGX_EMPTY_FONT: number = 14;
const WSGX_EMPTY_ROW_HEIGHT: number = 24;
const WSGX_EMPTY_PAD_TOP: number = 13.1;

/** 免责声明：14vp、行高 23.6vp、与提示行隔 25.5vp、左右各缩进 18.2vp */
const WSGX_TIP_FONT: number = 14;
const WSGX_TIP_LINE_HEIGHT: number = 23.6;
const WSGX_TIP_MARGIN_TOP: number = 25.5;
const WSGX_TIP_PAD_SIDE: number = 18.2;

/** 头部标签：6 个等分铺满整宽，当前停在「收藏」 */
interface WSGX_TabItem {
  tabKey: string;
  tabLabel: string;
  tabActive: boolean;
}

const WSGX_TABS: WSGX_TabItem[] = [
  { tabKey: 'ws-gx-tab-news', tabLabel: '要闻', tabActive: false },
  { tabKey: 'ws-gx-tab-optional', tabLabel: '自选', tabActive: false },
  { tabKey: 'ws-gx-tab-live', tabLabel: '7×24', tabActive: false },
  { tabKey: 'ws-gx-tab-discover', tabLabel: '发现', tabActive: false },
  { tabKey: 'ws-gx-tab-calendar', tabLabel: '投资日历', tabActive: false },
  { tabKey: 'ws-gx-tab-favorite', tabLabel: '收藏', tabActive: true }
];

/** 免责声明正文（134 字） */
const WSGX_DISCLAIMER: string =
  '免责声明：所有展示信息仅供参考，不构成任何投资建议。银河证券对信息的准确性、完整性或可靠性、及时性不作任何保证，' +
  '并非作为买卖、认购证券或其它金融工具的邀请或保证。投资者据此操作，风险自担。投资有风险，入市需谨慎。' +
  '银河证券提示投资者请密切关注自身风险承受能力及投资目标。';

@Component
export struct GalaxyNewsFavoritePage {
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
      this.windowToken = WindowModeController.acquire(win, '#FFFFFF');
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  // ------------------------------------------------------------------
  // 紫色头部
  // ------------------------------------------------------------------

  /** 返回箭头「‹」：两段斜笔上下拼合，外接 8.4×15.6vp */
  @Builder
  backArrow() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(WSGX_BACK_LEG)
        .height(WSGX_BACK_STROKE)
        .backgroundColor(WSGX_HEADER_TEXT)
        .borderRadius(WSGX_BACK_STROKE / 2)
        .rotate({ angle: -WSGX_BACK_LEG_ANGLE })
        .offset({ y: -WSGX_BACK_LEG_OFFSET })

      Row()
        .width(WSGX_BACK_LEG)
        .height(WSGX_BACK_STROKE)
        .backgroundColor(WSGX_HEADER_TEXT)
        .borderRadius(WSGX_BACK_STROKE / 2)
        .rotate({ angle: WSGX_BACK_LEG_ANGLE })
        .offset({ y: WSGX_BACK_LEG_OFFSET })
    }
    .width(WSGX_BACK_WIDTH)
    .height(WSGX_BACK_HEIGHT)
    .onClick(() => {
      this.pageStack.pop();
    })
  }

  @Builder
  titleRow() {
    Stack({ alignContent: Alignment.Center }) {
      Text('银河资讯')
        .fontSize(WSGX_TITLE_FONT)
        .fontWeight(FontWeight.Bold)
        .fontColor(WSGX_HEADER_TEXT)
        .maxLines(1)

      Row() {
        this.backArrow()

        Blank()

        Text('智能分析')
          .fontSize(WSGX_ACTION_FONT)
          .fontColor(WSGX_HEADER_TEXT)
          .maxLines(1)
      }
      .width('100%')
      .height('100%')
      .padding({ left: WSGX_BACK_PAD_LEFT, right: WSGX_ACTION_PAD_RIGHT })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(WSGX_TITLE_ROW_HEIGHT)
  }

  /** 单个标签：文字等宽居中，选中项在下方 3.3vp 处压一条白色短下划线 */
  @Builder
  tabItem(tab: WSGX_TabItem) {
    Column() {
      Row() {
        Text(tab.tabLabel)
          .fontSize(WSGX_TAB_FONT)
          .fontWeight(tab.tabActive ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(WSGX_HEADER_TEXT)
          .opacity(tab.tabActive ? 1 : WSGX_TAB_IDLE_OPACITY)
          .maxLines(1)
      }
      .width('100%')
      .height(WSGX_TAB_TEXT_HEIGHT)
      .justifyContent(FlexAlign.Center)

      Row()
        .width(WSGX_TAB_UNDERLINE_W)
        .height(WSGX_TAB_UNDERLINE_H)
        .borderRadius(WSGX_TAB_UNDERLINE_H / 2)
        .backgroundColor(tab.tabActive ? WSGX_HEADER_TEXT : WSGX_TRANSPARENT)
        .margin({ top: WSGX_TAB_UNDERLINE_GAP })
    }
    .layoutWeight(1)
    .height('100%')
    .padding({ top: WSGX_TAB_PAD_TOP })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  tabRow() {
    Row() {
      ForEach(WSGX_TABS, (tab: WSGX_TabItem) => {
        this.tabItem(tab)
      }, (tab: WSGX_TabItem) => tab.tabKey)
    }
    .width('100%')
    .height(WSGX_TAB_ROW_HEIGHT)
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  headerBand() {
    Column() {
      this.titleRow()

      this.tabRow()
    }
    .width('100%')
    .height(WSGX_HEADER_HEIGHT)
    .padding({ top: WSGX_STATUS_PAD })
    .backgroundColor(WSGX_HEADER_BG)
    .alignItems(HorizontalAlign.Start)
  }

  // ------------------------------------------------------------------
  // 标签下方：只有一行空态提示 + 一段免责声明，其余留空
  // ------------------------------------------------------------------

  @Builder
  emptyBody() {
    Scroll() {
      Column() {
        Row() {
          Text('没有更多了')
            .fontSize(WSGX_EMPTY_FONT)
            .fontColor(WSGX_EMPTY_TEXT)
            .maxLines(1)
        }
        .width('100%')
        .height(WSGX_EMPTY_ROW_HEIGHT)
        .justifyContent(FlexAlign.Center)

        Text(WSGX_DISCLAIMER)
          .fontSize(WSGX_TIP_FONT)
          .fontColor(WSGX_TIP_TEXT)
          .lineHeight(WSGX_TIP_LINE_HEIGHT)
          .width('100%')
          .margin({ top: WSGX_TIP_MARGIN_TOP })
          .padding({ left: WSGX_TIP_PAD_SIDE, right: WSGX_TIP_PAD_SIDE })
      }
      .width('100%')
      .padding({ top: WSGX_EMPTY_PAD_TOP })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.None)
    .align(Alignment.Top)
  }

  build() {
    NavDestination() {
      Column() {
        this.headerBand()

        this.emptyBody()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(WSGX_PAGE_BG)
      .alignItems(HorizontalAlign.Start)
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
