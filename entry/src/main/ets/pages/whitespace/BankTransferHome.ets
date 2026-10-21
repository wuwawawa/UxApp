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
 * 反例：留白过多 / 转账首页「常用转账」下方大片空白
 *
 * 复刻对象：手机银行「转账汇款」首页，双屏横屏。状态栏下方一行：左上返回箭头、居中标题
 *   「转账汇款」、右上「···」；下面一张横向蓝色渐变圆角大卡片，内部三列等分
 *   （银行卡转账 / 手机号转账 / 预约转账），三个白色线框图标（银行卡、手机、时钟），
 *   中间那列的图标右上角挂一个白底蓝字小气泡「免密」；再下一行四个入口等分
 *   （限额管理 / 转账历史 / 主动收款 / 跨境通），蓝色线框图标（列表、票券、人像、地球）
 *   加黑色小字；再下一行居中一个灰色「展开 ⌄」；再往下左对齐「常用转账」标题、旁边浅蓝底
 *   小标签「一点即转」，右端贴边灰色「全部收款人 ›」。这一行之后直到窗口底边没有任何内容。
 *
 * 设计基准：截图 3184×2232px（这里用的是 984×692 的等比缩小版，比例一致），密度 2.75，
 *   vp = px / 2.75，参考窗口 1157.8×811.6vp。括号内是在缩小版上量到的 px，
 *   换算系数 1.17664（= 3184 / 984 / 2.75）：
 *   标题行：状态栏下沿 32px（37.6vp），行高 44.4vp；标题字 19.4vp（「转账汇款」4 字宽 66px、
 *          ink y 44～58px）；返回箭头 11.8×18.8vp（10×16px、笔画 2.4vp、左缘 31.8vp）；
 *           「···」3 个 3.5vp 圆点、总宽 21.2vp、右缘距窗口 17.6vp（15px）；
 *   蓝色卡片：上边 100.7vp（85.6px）、高 108.2vp（91.9px）、左右各 17.6vp（15px）、
 *           圆角 10.6vp（9px）、横向渐变 #61A6F8 → #508AEB；
 *           卡内上内边距 30vp、图标 32vp（量到 29×21 / 24×31 / 29×27px）、
 *           图标到标签 8vp、标签字 14.4vp（「银行卡转账」5 字宽 61px，ink y 148～161px）；
 *           三列等分，列中心间距 315.5px（371.3vp）；
 *           免密气泡约 34×16.5vp（29×14px，ink x 499～531px、y 97～110px）、字 9.5vp，
 *           挂在中间列图标中心右上 26.5vp / −24.9vp 处；
 *   四个入口：距卡片 20.6vp（17.5px）；四列等分（列中心 128 / 371 / 615 / 858px，
 *           间距 243.3px）；图标 26vp（21～24px）、图标到标签 13vp、标签字 13.2vp
 *           （「限额管理」4 字宽 45px，ink y 228～238px）；
 *   展开行：距入口 9.7vp、行高 14vp、字 10.6vp（「展开」2 字宽 18px）；
 *           整块 ink x 429～456px，比窗口中线（492px）偏左 58.2vp；
 *   常用转账行：距展开 30.4vp；标题 17.4vp 粗体（4 字宽 59px、ink y 288～301px、左缘 18.8vp）；
 *           标签 54.1×17.6vp（46×15px）、字 11.2vp、与标题间距 10.6vp（9px）；
 *           右端「全部收款人」13.2vp（5 字宽 56px）+ ›，右缘 18.8vp（16px）。
 *   以上数值固定排版，卡片与两行入口都按 width('100%') 铺满当前窗口。
 *
 * 三态实测（同一套设计值，内容底边固定在 358.6vp = 37.6 + 44.4 + 18.7 + 108.2 + 20.6
 *   + 55 + 9.7 + 14 + 30.4 + 20）：
 *   单屏态      459.6×672vp   —— 卡片宽 424.4vp、三列各 141.5vp；下方留白 313.4vp，约占高度 47%
 *   双屏态竖屏  664.7×939.6vp —— 卡片宽 629.5vp、三列各 209.8vp；下方留白 581.0vp，约占高度 62%
 *   双屏态横屏  939.6×664.7vp —— 卡片宽 904.4vp、三列各 301.5vp；下方留白 306.1vp，约占高度 46%
 *   参考窗口    1157.8×811.6vp —— 卡片宽 1122.6vp、三列各 374.2vp；下方留白 453.0vp，
 *                                约占高度 56%（截图量到的就是这一态）
 *
 * 问题表现：
 *   「常用转账」这一行之下直到窗口底边是一整片空白，看不到任何收款人条目；
 *   卡片里三列各 301.5vp 宽，而图标只有 32vp、标签只有 14.4vp，一列里左右各空出 130vp 以上，
 *   三个图标之间隔着两百多 vp 的空蓝；四个入口同样散在整行四等分的位置上；
 *   「展开 ⌄」既不在窗口中线也不贴左，和上面四列、下面「全部收款人」都连不上；
 *   窗口越宽这一行内容越往两侧散，竖屏态下面的空白占到窗口高度的六成。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 配色：纯白页面、近黑标题、蓝色线框图标、灰色辅助文字 */
const WSBT_PAGE_BG: string = '#FFFFFF';
const WSBT_TITLE_COLOR: string = '#333333';
const WSBT_GLYPH_ON_CARD: string = '#FFFFFF';
const WSBT_GLYPH_BLUE: string = '#3B7FE8';
const WSBT_ENTRY_LABEL_COLOR: string = '#333333';
const WSBT_COMMON_TITLE_COLOR: string = '#333333';
const WSBT_MORE_COLOR: string = '#999999';
const WSBT_EXPAND_COLOR: string = '#B2B2B2';
const WSBT_TAG_BG: string = '#E7F1FE';
const WSBT_TAG_TEXT: string = '#2F6FD9';
const WSBT_BADGE_TEXT: string = '#2E6FD6';

/** 状态栏占位（沉浸式下系统状态栏压在上面，量到状态栏下沿 32px） */
const WSBT_STATUS_BAR_HEIGHT: number = 37.6;

/** 标题行：行高 44.4vp、标题字 19.4vp、左右内边距 */
const WSBT_HEADER_HEIGHT: number = 44.4;
const WSBT_TITLE_FONT: number = 19.4;
const WSBT_HEADER_PAD_LEFT: number = 31.8;
const WSBT_HEADER_PAD_RIGHT: number = 17.6;

/** 返回箭头：外接 11.8×18.8vp、笔画 2.4vp、两条斜笔画长 15.1vp、倾角 38.5°、上下各偏 4.7vp */
const WSBT_BACK_SPAN_W: number = 11.8;
const WSBT_BACK_SPAN_H: number = 18.8;
const WSBT_BACK_BAR_LEN: number = 15.1;
const WSBT_BACK_BAR_ANGLE: number = 38.5;
const WSBT_BACK_BAR_GAP: number = 4.7;
const WSBT_BACK_STROKE: number = 2.4;

/** 右上「···」：3 个 3.5vp 圆点、点距 5.3vp */
const WSBT_MORE_DOT_SIZE: number = 3.5;
const WSBT_MORE_DOT_GAP: number = 5.3;

/** 蓝色大卡片：上边距 18.7vp、左右 17.6vp、高 108.2vp、圆角 10.6vp */
const WSBT_CARD_TOP_GAP: number = 18.7;
const WSBT_CARD_SIDE: number = 17.6;
const WSBT_CARD_HEIGHT: number = 108.2;
const WSBT_CARD_RADIUS: number = 10.6;

/** 卡内：上内边距 30vp、图标 32vp、图标到标签 8vp、标签行高 20vp、下内边距 18.2vp */
const WSBT_CARD_PAD_TOP: number = 30;
const WSBT_CARD_PAD_BOTTOM: number = 18.2;
const WSBT_CARD_ICON_SIZE: number = 32;
const WSBT_CARD_ICON_LABEL_GAP: number = 8;
const WSBT_CARD_LABEL_HEIGHT: number = 20;
const WSBT_CARD_LABEL_FONT: number = 14.4;

/** 卡内线框笔画 */
const WSBT_CARD_STROKE: number = 2.2;

/** 免密气泡：高 16.5vp、字 9.5vp、左右内边距 7.5vp，挂在中间列图标中心的右上 */
const WSBT_BADGE_HEIGHT: number = 16.5;
const WSBT_BADGE_FONT: number = 9.5;
const WSBT_BADGE_PAD: number = 7.5;
const WSBT_BADGE_OFFSET_X: number = 26.5;
const WSBT_BADGE_OFFSET_Y: number = -24.9;

/** 四个入口：距卡片 20.6vp、图标 26vp、图标到标签 13vp、标签字 13.2vp / 行高 16vp */
const WSBT_SHORTCUT_TOP_GAP: number = 20.6;
const WSBT_SHORTCUT_ICON_SIZE: number = 26;
const WSBT_SHORTCUT_ICON_LABEL_GAP: number = 13;
const WSBT_SHORTCUT_LABEL_HEIGHT: number = 16;
const WSBT_SHORTCUT_LABEL_FONT: number = 13.2;

/** 入口线框笔画、票券里的符号字号 */
const WSBT_SHORTCUT_STROKE: number = 2;
const WSBT_TICKET_FONT: number = 11;

/** 展开行：距入口 9.7vp、行高 14vp、字 10.6vp、整块比窗口中线偏左 58.2vp、字到箭头 5.9vp */
const WSBT_EXPAND_TOP_GAP: number = 9.7;
const WSBT_EXPAND_HEIGHT: number = 14;
const WSBT_EXPAND_FONT: number = 10.6;
const WSBT_EXPAND_SHIFT_X: number = 58.2;
const WSBT_EXPAND_CHEVRON_GAP: number = 5.9;

/** 展开箭头：两条 4.4vp 斜线，倾角 36.3°，拼成 6.9×3.5vp 的 ⌄ */
const WSBT_EXPAND_BAR_LEN: number = 4.4;
const WSBT_EXPAND_BAR_ANGLE: number = 36.3;
const WSBT_CHEVRON_STROKE: number = 1.6;

/** 常用转账行：距展开 30.4vp、行高 20vp、标题 17.4vp、左右内边距 18.8vp */
const WSBT_COMMON_TOP_GAP: number = 30.4;
const WSBT_COMMON_ROW_HEIGHT: number = 20;
const WSBT_COMMON_TITLE_FONT: number = 17.4;
const WSBT_COMMON_PAD_SIDE: number = 18.8;

/** 「一点即转」标签：54.1×17.6vp、字 11.2vp、圆角 4vp、与标题间距 10.6vp、左右内边距 4.7vp */
const WSBT_TAG_HEIGHT: number = 17.6;
const WSBT_TAG_FONT: number = 11.2;
const WSBT_TAG_RADIUS: number = 4;
const WSBT_TAG_GAP: number = 10.6;
const WSBT_TAG_PAD: number = 4.7;

/** 右端「全部收款人」：字 13.2vp，其后 › 与外接尺寸 */
const WSBT_MORE_FONT: number = 13.2;
const WSBT_MORE_CHEVRON_GAP: number = 4.7;
const WSBT_MORE_CHEVRON_W: number = 5.9;
const WSBT_MORE_CHEVRON_H: number = 3.5;
const WSBT_MORE_CHEVRON_BAR: number = 6.1;
const WSBT_MORE_CHEVRON_ANGLE: number = 16.5;
const WSBT_MORE_CHEVRON_BAR_GAP: number = 0.9;

/** 卡片里三个图标的类型 */
const WSBT_GLYPH_BANK: string = 'bank';
const WSBT_GLYPH_PHONE: string = 'phone';
const WSBT_GLYPH_CLOCK: string = 'clock';

/** 四个入口图标的类型 */
const WSBT_GLYPH_LIMIT: string = 'limit';
const WSBT_GLYPH_TICKET: string = 'ticket';
const WSBT_GLYPH_PERSON: string = 'person';
const WSBT_GLYPH_GLOBE: string = 'globe';

/** 卡片里的三列 */
interface WSBT_CardAction {
  /** 列唯一键 */
  cardKey: string;
  cardLabel: string;
  /** 线框图标的类型 */
  cardGlyph: string;
  /** 图标右上角的气泡文案，空串表示没有气泡 */
  cardBadge: string;
}

/** 四个入口 */
interface WSBT_ShortcutAction {
  /** 入口唯一键 */
  shortcutKey: string;
  shortcutLabel: string;
  shortcutGlyph: string;
}

const WSBT_CARD_ACTIONS: WSBT_CardAction[] = [
  {
    cardKey: 'card-bank',
    cardLabel: '银行卡转账',
    cardGlyph: WSBT_GLYPH_BANK,
    cardBadge: ''
  },
  {
    cardKey: 'card-phone',
    cardLabel: '手机号转账',
    cardGlyph: WSBT_GLYPH_PHONE,
    cardBadge: '免密'
  },
  {
    cardKey: 'card-book',
    cardLabel: '预约转账',
    cardGlyph: WSBT_GLYPH_CLOCK,
    cardBadge: ''
  }
];

const WSBT_SHORTCUT_ACTIONS: WSBT_ShortcutAction[] = [
  { shortcutKey: 'shortcut-limit', shortcutLabel: '限额管理', shortcutGlyph: WSBT_GLYPH_LIMIT },
  { shortcutKey: 'shortcut-history', shortcutLabel: '转账历史', shortcutGlyph: WSBT_GLYPH_TICKET },
  { shortcutKey: 'shortcut-receive', shortcutLabel: '主动收款', shortcutGlyph: WSBT_GLYPH_PERSON },
  { shortcutKey: 'shortcut-global', shortcutLabel: '跨境通', shortcutGlyph: WSBT_GLYPH_GLOBE }
];

@Component
export struct BankTransferHomePage {
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
      this.windowToken = WindowModeController.acquire(win, '#000000');
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  // ------------------------------------------------------------------
  // 顶部：返回箭头 + 居中标题 + 更多
  // ------------------------------------------------------------------

  @Builder
  backChevron() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(WSBT_BACK_BAR_LEN)
        .height(WSBT_BACK_STROKE)
        .backgroundColor(WSBT_TITLE_COLOR)
        .rotate({ angle: -WSBT_BACK_BAR_ANGLE })
        .offset({ y: -WSBT_BACK_BAR_GAP })

      Row()
        .width(WSBT_BACK_BAR_LEN)
        .height(WSBT_BACK_STROKE)
        .backgroundColor(WSBT_TITLE_COLOR)
        .rotate({ angle: WSBT_BACK_BAR_ANGLE })
        .offset({ y: WSBT_BACK_BAR_GAP })
    }
    .width(WSBT_BACK_SPAN_W)
    .height(WSBT_BACK_SPAN_H)
    .onClick(() => {
      this.pageStack.pop();
    })
  }

  @Builder
  moreDots() {
    Row({ space: WSBT_MORE_DOT_GAP }) {
      Circle()
        .width(WSBT_MORE_DOT_SIZE)
        .height(WSBT_MORE_DOT_SIZE)
        .fill(WSBT_TITLE_COLOR)

      Circle()
        .width(WSBT_MORE_DOT_SIZE)
        .height(WSBT_MORE_DOT_SIZE)
        .fill(WSBT_TITLE_COLOR)

      Circle()
        .width(WSBT_MORE_DOT_SIZE)
        .height(WSBT_MORE_DOT_SIZE)
        .fill(WSBT_TITLE_COLOR)
    }
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  headerBar() {
    Stack({ alignContent: Alignment.Center }) {
      Text('转账汇款')
        .fontSize(WSBT_TITLE_FONT)
        .fontWeight(FontWeight.Medium)
        .fontColor(WSBT_TITLE_COLOR)
        .maxLines(1)

      Row() {
        this.backChevron()

        Blank()

        this.moreDots()
      }
      .width('100%')
      .height('100%')
      .padding({
        left: WSBT_HEADER_PAD_LEFT,
        right: WSBT_HEADER_PAD_RIGHT
      })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(WSBT_HEADER_HEIGHT)
    .margin({ top: WSBT_STATUS_BAR_HEIGHT })
  }

  // ------------------------------------------------------------------
  // 蓝色卡片里的三个白色线框图标
  // ------------------------------------------------------------------

  @Builder
  bankCardGlyph() {
    Stack({ alignContent: Alignment.Center }) {
      Rect()
        .width(28)
        .height(20)
        .radiusWidth(3.6)
        .radiusHeight(3.6)
        .fill(Color.Transparent)
        .stroke(WSBT_GLYPH_ON_CARD)
        .strokeWidth(WSBT_CARD_STROKE)

      Row()
        .width(28)
        .height(WSBT_CARD_STROKE)
        .backgroundColor(WSBT_GLYPH_ON_CARD)
        .offset({ y: -3.4 })
    }
    .width(WSBT_CARD_ICON_SIZE)
    .height(WSBT_CARD_ICON_SIZE)
  }

  @Builder
  phoneGlyph() {
    Stack({ alignContent: Alignment.Center }) {
      Rect()
        .width(22)
        .height(30)
        .radiusWidth(5.5)
        .radiusHeight(5.5)
        .fill(Color.Transparent)
        .stroke(WSBT_GLYPH_ON_CARD)
        .strokeWidth(WSBT_CARD_STROKE)

      Row()
        .width(7)
        .height(2)
        .backgroundColor(WSBT_GLYPH_ON_CARD)
        .offset({ x: -2, y: -9 })
    }
    .width(WSBT_CARD_ICON_SIZE)
    .height(WSBT_CARD_ICON_SIZE)
  }

  @Builder
  clockGlyph() {
    Stack({ alignContent: Alignment.Center }) {
      Circle()
        .width(25)
        .height(25)
        .fill(Color.Transparent)
        .stroke(WSBT_GLYPH_ON_CARD)
        .strokeWidth(WSBT_CARD_STROKE)

      Row()
        .width(WSBT_CARD_STROKE)
        .height(8)
        .backgroundColor(WSBT_GLYPH_ON_CARD)
        .offset({ y: -4 })

      Row()
        .width(8)
        .height(WSBT_CARD_STROKE)
        .backgroundColor(WSBT_GLYPH_ON_CARD)
        .offset({ x: 4 })

      Row()
        .width(6)
        .height(1.8)
        .backgroundColor(WSBT_GLYPH_ON_CARD)
        .rotate({ angle: -45 })
        .offset({ x: -11, y: -11 })

      Row()
        .width(6)
        .height(1.8)
        .backgroundColor(WSBT_GLYPH_ON_CARD)
        .rotate({ angle: -45 })
        .offset({ x: 11, y: -11 })
    }
    .width(WSBT_CARD_ICON_SIZE)
    .height(WSBT_CARD_ICON_SIZE)
  }

  @Builder
  cardGlyph(glyphKind: string) {
    if (glyphKind === WSBT_GLYPH_BANK) {
      this.bankCardGlyph()
    } else if (glyphKind === WSBT_GLYPH_PHONE) {
      this.phoneGlyph()
    } else {
      this.clockGlyph()
    }
  }

  // ------------------------------------------------------------------
  // 蓝色卡片
  // ------------------------------------------------------------------

  @Builder
  cardCell(action: WSBT_CardAction) {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        this.cardGlyph(action.cardGlyph)

        if (action.cardBadge.length > 0) {
          Text(action.cardBadge)
            .fontSize(WSBT_BADGE_FONT)
            .fontColor(WSBT_BADGE_TEXT)
            .backgroundColor(Color.White)
            .width(34)
            .height(WSBT_BADGE_HEIGHT)
            .textAlign(TextAlign.Center)
            .padding({
              left: WSBT_BADGE_PAD,
              right: WSBT_BADGE_PAD
            })
            .borderRadius(WSBT_BADGE_HEIGHT / 2)
            .maxLines(1)
            .offset({
              x: WSBT_BADGE_OFFSET_X,
              y: WSBT_BADGE_OFFSET_Y
            })
        }
      }
      .width(WSBT_CARD_ICON_SIZE)
      .height(WSBT_CARD_ICON_SIZE)

      Text(action.cardLabel)
        .fontSize(WSBT_CARD_LABEL_FONT)
        .fontColor(WSBT_GLYPH_ON_CARD)
        .height(WSBT_CARD_LABEL_HEIGHT)
        .maxLines(1)
        .margin({ top: WSBT_CARD_ICON_LABEL_GAP })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  transferCard() {
    Column() {
      Row() {
        ForEach(WSBT_CARD_ACTIONS, (action: WSBT_CardAction) => {
          this.cardCell(action)
        }, (action: WSBT_CardAction) => action.cardKey)
      }
      .width('100%')
      .height(WSBT_CARD_HEIGHT)
      .padding({
        top: WSBT_CARD_PAD_TOP,
        bottom: WSBT_CARD_PAD_BOTTOM
      })
      .borderRadius(WSBT_CARD_RADIUS)
      .linearGradient({
        angle: 90,
        colors: [['#61A6F8', 0.0], ['#508AEB', 1.0]]
      })
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .padding({
      left: WSBT_CARD_SIDE,
      right: WSBT_CARD_SIDE,
      top: WSBT_CARD_TOP_GAP
    })
  }

  // ------------------------------------------------------------------
  // 四个入口的蓝色线框图标
  // ------------------------------------------------------------------

  @Builder
  limitGlyph() {
    Stack({ alignContent: Alignment.Center }) {
      Rect()
        .width(22)
        .height(22)
        .radiusWidth(4)
        .radiusHeight(4)
        .fill(Color.Transparent)
        .stroke(WSBT_GLYPH_BLUE)
        .strokeWidth(WSBT_SHORTCUT_STROKE)

      Row()
        .width(13)
        .height(1.8)
        .backgroundColor(WSBT_GLYPH_BLUE)
        .offset({ y: -4.4 })

      Row()
        .width(13)
        .height(1.8)
        .backgroundColor(WSBT_GLYPH_BLUE)

      Row()
        .width(13)
        .height(1.8)
        .backgroundColor(WSBT_GLYPH_BLUE)
        .offset({ y: 4.4 })

      Row()
        .width(2)
        .height(5)
        .backgroundColor(WSBT_GLYPH_BLUE)
        .offset({ x: -3.4, y: -4.4 })

      Row()
        .width(2)
        .height(5)
        .backgroundColor(WSBT_GLYPH_BLUE)
        .offset({ x: 2.6 })

      Row()
        .width(2)
        .height(5)
        .backgroundColor(WSBT_GLYPH_BLUE)
        .offset({ x: -2.2, y: 4.4 })
    }
    .width(WSBT_SHORTCUT_ICON_SIZE)
    .height(WSBT_SHORTCUT_ICON_SIZE)
  }

  @Builder
  ticketGlyph() {
    Stack({ alignContent: Alignment.Center }) {
      Rect()
        .width(21)
        .height(20)
        .radiusWidth(3)
        .radiusHeight(3)
        .fill(Color.Transparent)
        .stroke(WSBT_GLYPH_BLUE)
        .strokeWidth(WSBT_SHORTCUT_STROKE)

      Text('¥')
        .fontSize(WSBT_TICKET_FONT)
        .fontWeight(FontWeight.Medium)
        .fontColor(WSBT_GLYPH_BLUE)
        .maxLines(1)
    }
    .width(WSBT_SHORTCUT_ICON_SIZE)
    .height(WSBT_SHORTCUT_ICON_SIZE)
  }

  @Builder
  personGlyph() {
    Stack({ alignContent: Alignment.Center }) {
      Circle()
        .width(10)
        .height(10)
        .fill(Color.Transparent)
        .stroke(WSBT_GLYPH_BLUE)
        .strokeWidth(WSBT_SHORTCUT_STROKE)
        .offset({ y: -6 })

      Circle()
        .width(18)
        .height(18)
        .fill(Color.Transparent)
        .stroke(WSBT_GLYPH_BLUE)
        .strokeWidth(WSBT_SHORTCUT_STROKE)
        .offset({ y: 9 })

      Rect()
        .width(20)
        .height(12)
        .fill(WSBT_PAGE_BG)
        .offset({ y: 15 })

      Row()
        .width(9)
        .height(2)
        .backgroundColor(WSBT_GLYPH_BLUE)
        .offset({ x: 7, y: 8 })

      Row()
        .width(5)
        .height(2)
        .backgroundColor(WSBT_GLYPH_BLUE)
        .rotate({ angle: 45 })
        .offset({ x: 4.3, y: 6.2 })

      Row()
        .width(5)
        .height(2)
        .backgroundColor(WSBT_GLYPH_BLUE)
        .rotate({ angle: -45 })
        .offset({ x: 4.3, y: 9.8 })
    }
    .width(WSBT_SHORTCUT_ICON_SIZE)
    .height(WSBT_SHORTCUT_ICON_SIZE)
    .clip(true)
  }

  @Builder
  globeGlyph() {
    Stack({ alignContent: Alignment.Center }) {
      Circle()
        .width(23)
        .height(23)
        .fill(Color.Transparent)
        .stroke(WSBT_GLYPH_BLUE)
        .strokeWidth(WSBT_SHORTCUT_STROKE)

      Row()
        .width(14)
        .height(1.8)
        .backgroundColor(WSBT_GLYPH_BLUE)
        .offset({ y: -3 })

      Row()
        .width(14)
        .height(1.8)
        .backgroundColor(WSBT_GLYPH_BLUE)
        .offset({ y: 3 })

      Row()
        .width(1.8)
        .height(4.5)
        .backgroundColor(WSBT_GLYPH_BLUE)
        .offset({ x: 6, y: -5 })

      Row()
        .width(1.8)
        .height(4.5)
        .backgroundColor(WSBT_GLYPH_BLUE)
        .offset({ x: -6, y: 5 })
    }
    .width(WSBT_SHORTCUT_ICON_SIZE)
    .height(WSBT_SHORTCUT_ICON_SIZE)
  }

  @Builder
  shortcutGlyph(glyphKind: string) {
    if (glyphKind === WSBT_GLYPH_LIMIT) {
      this.limitGlyph()
    } else if (glyphKind === WSBT_GLYPH_TICKET) {
      this.ticketGlyph()
    } else if (glyphKind === WSBT_GLYPH_PERSON) {
      this.personGlyph()
    } else {
      this.globeGlyph()
    }
  }

  // ------------------------------------------------------------------
  // 四个入口
  // ------------------------------------------------------------------

  @Builder
  shortcutCell(action: WSBT_ShortcutAction) {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        this.shortcutGlyph(action.shortcutGlyph)
      }
      .width(WSBT_SHORTCUT_ICON_SIZE)
      .height(WSBT_SHORTCUT_ICON_SIZE)

      Text(action.shortcutLabel)
        .fontSize(WSBT_SHORTCUT_LABEL_FONT)
        .fontColor(WSBT_ENTRY_LABEL_COLOR)
        .height(WSBT_SHORTCUT_LABEL_HEIGHT)
        .maxLines(1)
        .margin({ top: WSBT_SHORTCUT_ICON_LABEL_GAP })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  shortcutRow() {
    Row() {
      ForEach(WSBT_SHORTCUT_ACTIONS, (action: WSBT_ShortcutAction) => {
        this.shortcutCell(action)
      }, (action: WSBT_ShortcutAction) => action.shortcutKey)
    }
    .width('100%')
    .padding({ top: WSBT_SHORTCUT_TOP_GAP })
    .alignItems(VerticalAlign.Top)
  }

  // ------------------------------------------------------------------
  // 展开
  // ------------------------------------------------------------------

  @Builder
  downChevron() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(WSBT_EXPAND_BAR_LEN)
        .height(WSBT_CHEVRON_STROKE)
        .backgroundColor(WSBT_EXPAND_COLOR)
        .rotate({ angle: WSBT_EXPAND_BAR_ANGLE })
        .offset({ x: -1.7 })

      Row()
        .width(WSBT_EXPAND_BAR_LEN)
        .height(WSBT_CHEVRON_STROKE)
        .backgroundColor(WSBT_EXPAND_COLOR)
        .rotate({ angle: -WSBT_EXPAND_BAR_ANGLE })
        .offset({ x: 1.7 })
    }
    .width(8)
    .height(4)
  }

  @Builder
  expandRow() {
    Row() {
      Row({ space: WSBT_EXPAND_CHEVRON_GAP }) {
        Text('展开')
          .fontSize(WSBT_EXPAND_FONT)
          .fontColor(WSBT_EXPAND_COLOR)
          .maxLines(1)

        this.downChevron()
      }
      .alignItems(VerticalAlign.Center)
      .offset({ x: -WSBT_EXPAND_SHIFT_X })
    }
    .width('100%')
    .height(WSBT_EXPAND_HEIGHT)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .margin({ top: WSBT_EXPAND_TOP_GAP })
  }

  // ------------------------------------------------------------------
  // 常用转账行
  // ------------------------------------------------------------------

  @Builder
  rightChevron() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(WSBT_MORE_CHEVRON_BAR)
        .height(WSBT_CHEVRON_STROKE)
        .backgroundColor(WSBT_MORE_COLOR)
        .rotate({ angle: WSBT_MORE_CHEVRON_ANGLE })
        .offset({ y: -WSBT_MORE_CHEVRON_BAR_GAP })

      Row()
        .width(WSBT_MORE_CHEVRON_BAR)
        .height(WSBT_CHEVRON_STROKE)
        .backgroundColor(WSBT_MORE_COLOR)
        .rotate({ angle: -WSBT_MORE_CHEVRON_ANGLE })
        .offset({ y: WSBT_MORE_CHEVRON_BAR_GAP })
    }
    .width(WSBT_MORE_CHEVRON_W)
    .height(WSBT_MORE_CHEVRON_H)
  }

  @Builder
  commonHeader() {
    Row() {
      Text('常用转账')
        .fontSize(WSBT_COMMON_TITLE_FONT)
        .fontWeight(FontWeight.Bold)
        .fontColor(WSBT_COMMON_TITLE_COLOR)
        .maxLines(1)

      Text('一点即转')
        .fontSize(WSBT_TAG_FONT)
        .fontColor(WSBT_TAG_TEXT)
        .backgroundColor(WSBT_TAG_BG)
        .height(WSBT_TAG_HEIGHT)
        .padding({
          left: WSBT_TAG_PAD,
          right: WSBT_TAG_PAD
        })
        .borderRadius(WSBT_TAG_RADIUS)
        .maxLines(1)
        .margin({ left: WSBT_TAG_GAP })

      Blank()

      Text('全部收款人')
        .fontSize(WSBT_MORE_FONT)
        .fontColor(WSBT_MORE_COLOR)
        .maxLines(1)

      Row() {
        this.rightChevron()
      }
      .margin({ left: WSBT_MORE_CHEVRON_GAP })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(WSBT_COMMON_ROW_HEIGHT)
    .padding({
      left: WSBT_COMMON_PAD_SIDE,
      right: WSBT_COMMON_PAD_SIDE
    })
    .margin({ top: WSBT_COMMON_TOP_GAP })
    .alignItems(VerticalAlign.Center)
  }

  build() {
    NavDestination() {
      Column() {
        this.headerBar()

        this.transferCard()

        this.shortcutRow()

        this.expandRow()

        this.commonHeader()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(WSBT_PAGE_BG)
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
