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
 * 反例：留白过多 / 阅读 App「书架 · 浏览历史」页右侧大半屏空白
 *
 * 复刻对象：阅读 App 的「书架 / 浏览历史」页，双屏横屏截图。顶部左侧「书架」（灰字）与
 *   「浏览历史」（黑色粗字）两个 tab，右上角一枚放大镜；下面一行「今天」分组小标题；
 *   再往下是单列书目：方形彩色书封（5 张都裁自截图）、书名、灰色小字
 *   「最近打开:2025-11-19 18:23:43」，每条最右侧贴边一枚极浅的「已在书架」；
 *   底部四等分 tab 栏（书架 / 书城 / 分类 / 我的），首项图标是浅黄填充的书本。
 *
 * 设计基准：截图 3184×2232px（这里用的是 990×697 的等比缩小版，比例一致），密度 2.75，
 *   vp = px / 2.75，参考窗口 1157.8×811.6vp；括号内 px 值量自缩小版，
 *   换算系数 1.16952（= 3184 / 990 / 2.75）：
 *   顶部：两个 tab 距窗口顶 51vp（43.6px）起排，行高 44vp（37.6px）；
 *         「书架」字 19vp（2 字宽 28px、字顶 57px、左缘 25px），
 *         「浏览历史」字 22vp 粗体（4 字宽 70px、字顶 54px），两 tab 间距 15.8vp（13.5px）；
 *         放大镜外接 20vp（17×17px、笔画 2vp、镜圈 13.4vp），右缘距窗口右边 29.1vp（24.9px）；
 *   「今天」：字 19vp（2 字宽 31px、字顶 101px），行高 26vp，距顶部行底 19vp（16.3px）；
 *   书目：首条书封顶 155.5vp（133px）；行高 95.9vp（82px 封面高）、行距 16.4vp（96−82px）；
 *         书封 71.3×95.9vp（61×82px、圆角 5vp）、左内边距 25.7vp（22px）；
 *         书封到书名 10vp（8.6px）；书名 16vp（2 字宽 24px）、字顶距封面顶 25.3vp（21.6px）；
 *         「最近打开:…」13vp（2 字宽 21px）、距书名 14vp（12px）；
 *         「已在书架」13vp（4 字宽 42px）、右缘距窗口右边 38.6vp（33px）、竖着落在封面中线；
 *   底栏：顶边 729.8vp（624px）处一条 1vp 浅灰线，栏高 81.8vp（69.9px）；
 *         图标 22×19vp（书架图标 18×16px）、距栏顶 10.5vp；图标到文字 4.5vp；
 *         文字 11vp（2 字宽 18px）；四等分（每格 289.4vp，四个图标中心相距 289vp）。
 *
 * 三态实测（设计值写死，只有整窗宽的行跟着窗口拉长；内容右界 = 25.7 + 71.3 + 10 +
 *   最长书名 17 字 × 16vp = 379vp；「已在书架」左界 = 窗口宽 − 90.6vp）：
 *   单屏态      459.6×672vp   —— 书名只剩 262vp 可用，「千亿前妻带崽归来，把沈总踢出户口本」
 *                                被截断；书名与「已在书架」之间空白 0，约占宽度的 0%
 *   双屏态竖屏  664.7×939.6vp —— 空白 195.1vp，约占宽度的 29%；书单 5 条全部露完
 *   双屏态横屏  939.6×664.7vp —— 空白 470vp，约占宽度的 50%；纵向只剩 427.4vp 可排，
 *                                每行 112.3vp，第 4 条下沿被底部 tab 栏裁掉
 *   参考窗口    1157.8×811.6vp —— 空白 688.2vp，约占宽度的 59%（截图量到的就是这一态）
 *
 * 问题表现：
 *   书封 + 书名这一条只排到窗口宽度的四成左右，书名右边一直到「已在书架」都是空白；
 *   「已在书架」贴着窗口右缘，两者之间空出大半屏，右侧约三分之二的宽度没有任何内容；
 *   每条书的书名长短不同，右边空白却越拉越宽，整列像被左对齐钉死在窗口左边缘；
 *   「今天」这行小标题的右侧同样一路空到窗口右缘；
 *   底部 tab 栏反倒按整窗四等分铺满，上下两块的行宽不一致，右侧的空白更加显眼；
 *   939.6×664.7vp 这一态只露出三条多书目，第 4 条的下沿被 tab 栏盖住，剩下的要滚动才看得到。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 配色：白底页面、近黑书名与 tab、「已在书架」是极浅的灰 */
const WSBS_PAGE_BG: string = '#FFFFFF';
const WSBS_TAB_IDLE_TEXT: string = '#333333';
const WSBS_TAB_ACTIVE_TEXT: string = '#000000';
const WSBS_TODAY_TEXT: string = '#1A1A1A';
const WSBS_BOOK_TITLE_TEXT: string = '#1A1A1A';
const WSBS_BOOK_TIME_TEXT: string = '#A5A5A5';
const WSBS_ADDED_LABEL_TEXT: string = '#E2E2E2';
const WSBS_BAR_DIVIDER: string = '#F2F2F2';
const WSBS_BAR_LABEL_ACTIVE: string = '#1A1A1A';
const WSBS_BAR_LABEL_IDLE: string = '#A6A6A6';
const WSBS_ICON_DARK: string = '#1A1A1A';
const WSBS_ICON_GRAY: string = '#6E6E6E';
const WSBS_ICON_BOOK_FILL: string = '#FCE190';

/** 顶部：距窗口顶 51vp 起排、行高 44vp、左内边距 25.7vp（「书架」左缘 25px） */
const WSBS_HEADER_TOP: number = 51;
const WSBS_HEADER_HEIGHT: number = 44;
const WSBS_PAGE_PAD_LEFT: number = 25.7;

/** 两个 tab：「书架」19vp 常规灰字（2 字宽 28px）、「浏览历史」22vp 粗黑（4 字宽 70px）、间距 15.8vp */
const WSBS_TAB_IDLE_FONT: number = 19;
const WSBS_TAB_ACTIVE_FONT: number = 22;
const WSBS_TAB_GAP: number = 15.8;

/** 放大镜：外接 20vp（17×17px）、笔画 2vp、镜圈 13.4vp、手柄 7.2vp、右边距 29.1vp（24.9px） */
const WSBS_SEARCH_SIZE: number = 20;
const WSBS_SEARCH_STROKE: number = 2;
const WSBS_SEARCH_RING: number = 13.4;
const WSBS_SEARCH_HANDLE: number = 7.2;
const WSBS_SEARCH_PAD_RIGHT: number = 29.1;

/** 「今天」：字 19vp（2 字宽 31px）、行高 26vp、距顶部行底 19vp（16.3px） */
const WSBS_TODAY_TOP: number = 19;
const WSBS_TODAY_HEIGHT: number = 26;
const WSBS_TODAY_FONT: number = 19;

/** 书目：首条封面顶 155.5vp（133px）、行高 95.9vp（82px）、行距 16.4vp（96−82px） */
const WSBS_LIST_TOP: number = 15.5;
const WSBS_ROW_HEIGHT: number = 95.9;
const WSBS_ROW_GAP: number = 16.4;

/** 书封 71.3×95.9vp（61×82px）、圆角 5vp；书封到书名 10vp（8.6px） */
const WSBS_COVER_W: number = 71.3;
const WSBS_COVER_H: number = 95.9;
const WSBS_COVER_RADIUS: number = 5;
const WSBS_COVER_TEXT_GAP: number = 10;

/** 书名 16vp（2 字宽 24px）、字顶距封面顶 25.3vp（21.6px）；时间 13vp、距书名 14vp（12px） */
const WSBS_TITLE_FONT: number = 16;
const WSBS_TITLE_PAD_TOP: number = 25.3;
const WSBS_TIME_FONT: number = 13;
const WSBS_TIME_GAP: number = 14;

/** 「已在书架」13vp（4 字宽 42px）、右缘距窗口右边 38.6vp（33px） */
const WSBS_ADDED_FONT: number = 13;
const WSBS_ADDED_PAD_RIGHT: number = 38.6;

/** 底部 tab 栏：高 81.8vp（69.9px）、顶边 1vp 浅灰线、图标距栏顶 10.5vp、图标到文字 4.5vp、文字 11vp */
const WSBS_BAR_HEIGHT: number = 81.8;
const WSBS_BAR_DIVIDER_H: number = 1;
const WSBS_BAR_PAD_TOP: number = 10.5;
const WSBS_BAR_LABEL_GAP: number = 4.5;
const WSBS_BAR_LABEL_FONT: number = 11;

/** 图标占位盒 22×19vp（图标实测 16~19px 见方） */
const WSBS_ICON_BOX_W: number = 22;
const WSBS_ICON_BOX_H: number = 19;

/** 书架图标：书本 21×17vp、圆角 4.6vp、边框 2.4vp、浅黄填充，中间一道 3.2×9.6vp 的竖条 */
const WSBS_BOOK_W: number = 21;
const WSBS_BOOK_H: number = 17;
const WSBS_BOOK_RADIUS: number = 4.6;
const WSBS_BOOK_STROKE: number = 2.4;
const WSBS_BOOK_MARK_W: number = 3.2;
const WSBS_BOOK_MARK_H: number = 9.6;

/** 书城图标：房屋 19×13vp、屋脊两道 11.2vp 斜边（与水平夹角 32.3°）、边线 2vp */
const WSBS_HOUSE_W: number = 19;
const WSBS_HOUSE_H: number = 13;
const WSBS_HOUSE_STROKE: number = 2;
const WSBS_HOUSE_ROOF_LEN: number = 11.2;
const WSBS_HOUSE_ROOF_ANGLE: number = 32.3;

/** 分类图标：2×2 四格，格子 8.2vp、间距 2.3vp、边线 2.1vp，右下角那格是圆 */
const WSBS_GRID_CELL: number = 8.2;
const WSBS_GRID_GAP: number = 2.3;
const WSBS_GRID_STROKE: number = 2.1;

/** 我的图标：外圈 20vp、边线 2.1vp，圈内一道 8×2.2vp 的短横 */
const WSBS_PERSON_RING: number = 20;
const WSBS_PERSON_STROKE: number = 2.1;
const WSBS_PERSON_DASH_W: number = 8;
const WSBS_PERSON_DASH_H: number = 2.2;

/** 一条浏览记录：书封裁自截图，书名 / 最近打开时间照截图抄 */
interface WSBS_BookItem {
  bookKey: string;
  bookTitle: string;
  bookLastOpen: string;
  bookCover: Resource;
}

const WSBS_BOOKS: WSBS_BookItem[] = [
  {
    bookKey: 'mengzu',
    bookTitle: '猛卒',
    bookLastOpen: '最近打开:2025-11-19 18:23:43',
    bookCover: $r('app.media.ws_bs_cover_mengzu')
  },
  {
    bookKey: 'hunjun',
    bookTitle: '朕只想做个昏君',
    bookLastOpen: '最近打开:2025-11-19 18:23:40',
    bookCover: $r('app.media.ws_bs_cover_hunjun')
  },
  {
    bookKey: 'shijie',
    bookTitle: '师姐，我真的无敌了',
    bookLastOpen: '最近打开:2025-11-19 18:23:37',
    bookCover: $r('app.media.ws_bs_cover_shijie')
  },
  {
    bookKey: 'qianyi',
    bookTitle: '千亿前妻带崽归来，把沈总踢出户口本',
    bookLastOpen: '最近打开:2025-11-19 18:23:34',
    bookCover: $r('app.media.ws_bs_cover_qianyi')
  },
  {
    bookKey: 'wanbei',
    bookTitle: '万倍返还：徒弟筑基我直接成仙',
    bookLastOpen: '最近打开:2025-11-19 18:23:32',
    bookCover: $r('app.media.ws_bs_cover_wanbei')
  }
];

@Component
export struct BookshelfHistoryPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽度（vp），随折叠 / 旋转实时更新，只做记录，不参与排版换算 */
  @State winWidthVp: number = 939.6;

  /** 窗口高度（vp），随折叠 / 旋转实时更新 */
  @State winHeightVp: number = 664.7;

  private listScroller: Scroller = new Scroller();
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
  // 顶部：两个 tab + 放大镜
  // ------------------------------------------------------------------

  /** 放大镜：一个圆环 + 一根 45° 的手柄 */
  @Builder
  searchIcon() {
    Stack({ alignContent: Alignment.TopStart }) {
      Row()
        .width(WSBS_SEARCH_RING)
        .height(WSBS_SEARCH_RING)
        .borderRadius(WSBS_SEARCH_RING / 2)
        .border({ width: WSBS_SEARCH_STROKE, color: WSBS_ICON_DARK })
        .offset({ x: 0.4, y: 0.4 })

      Row()
        .width(WSBS_SEARCH_HANDLE)
        .height(WSBS_SEARCH_STROKE)
        .borderRadius(WSBS_SEARCH_STROKE / 2)
        .backgroundColor(WSBS_ICON_DARK)
        .rotate({ angle: 45 })
        .offset({ x: 11.4, y: 15.2 })
    }
    .width(WSBS_SEARCH_SIZE)
    .height(WSBS_SEARCH_SIZE)
  }

  @Builder
  headerBar() {
    Row() {
      Text('书架')
        .fontSize(WSBS_TAB_IDLE_FONT)
        .fontColor(WSBS_TAB_IDLE_TEXT)
        .maxLines(1)

      Text('浏览历史')
        .fontSize(WSBS_TAB_ACTIVE_FONT)
        .fontWeight(FontWeight.Bold)
        .fontColor(WSBS_TAB_ACTIVE_TEXT)
        .maxLines(1)
        .margin({ left: WSBS_TAB_GAP })

      Blank()

      this.searchIcon()
    }
    .width('100%')
    .height(WSBS_HEADER_HEIGHT)
    .margin({ top: WSBS_HEADER_TOP })
    .padding({ left: WSBS_PAGE_PAD_LEFT, right: WSBS_SEARCH_PAD_RIGHT })
    .alignItems(VerticalAlign.Center)
  }

  // ------------------------------------------------------------------
  // 「今天」分组小标题
  // ------------------------------------------------------------------

  @Builder
  todayRow() {
    Row() {
      Text('今天')
        .fontSize(WSBS_TODAY_FONT)
        .fontWeight(FontWeight.Medium)
        .fontColor(WSBS_TODAY_TEXT)
        .maxLines(1)
    }
    .width('100%')
    .height(WSBS_TODAY_HEIGHT)
    .margin({ top: WSBS_TODAY_TOP })
    .padding({ left: WSBS_PAGE_PAD_LEFT })
    .alignItems(VerticalAlign.Center)
  }

  // ------------------------------------------------------------------
  // 书目：书封 + 书名 + 时间 + 贴右的「已在书架」
  // ------------------------------------------------------------------

  @Builder
  bookRow(book: WSBS_BookItem) {
    Row() {
      Image(book.bookCover)
        .width(WSBS_COVER_W)
        .height(WSBS_COVER_H)
        .objectFit(ImageFit.Cover)
        .borderRadius(WSBS_COVER_RADIUS)
        .clip(true)

      Column() {
        Text(book.bookTitle)
          .fontSize(WSBS_TITLE_FONT)
          .fontWeight(FontWeight.Medium)
          .fontColor(WSBS_BOOK_TITLE_TEXT)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(book.bookLastOpen)
          .fontSize(WSBS_TIME_FONT)
          .fontColor(WSBS_BOOK_TIME_TEXT)
          .maxLines(1)
          .margin({ top: WSBS_TIME_GAP })
      }
      .height(WSBS_ROW_HEIGHT)
      .layoutWeight(1)
      .margin({ left: WSBS_COVER_TEXT_GAP })
      .padding({ top: WSBS_TITLE_PAD_TOP })
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)

      Column() {
        Text('已在书架')
          .fontSize(WSBS_ADDED_FONT)
          .fontColor(WSBS_ADDED_LABEL_TEXT)
          .maxLines(1)
      }
      .height(WSBS_ROW_HEIGHT)
      .padding({ right: WSBS_ADDED_PAD_RIGHT })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .height(WSBS_ROW_HEIGHT)
    .padding({ left: WSBS_PAGE_PAD_LEFT })
    .margin({ bottom: WSBS_ROW_GAP })
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  bookList() {
    List({ scroller: this.listScroller }) {
      ForEach(WSBS_BOOKS, (book: WSBS_BookItem) => {
        ListItem() {
          this.bookRow(book)
        }
      }, (book: WSBS_BookItem) => book.bookKey)
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ top: WSBS_LIST_TOP })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.None)
  }

  // ------------------------------------------------------------------
  // 底部四等分 tab 栏
  // ------------------------------------------------------------------

  /** 书架：浅黄填充的书本 + 中间一道竖条 */
  @Builder
  iconBookshelf() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(WSBS_BOOK_W)
        .height(WSBS_BOOK_H)
        .backgroundColor(WSBS_ICON_BOOK_FILL)
        .borderRadius(WSBS_BOOK_RADIUS)
        .border({ width: WSBS_BOOK_STROKE, color: WSBS_ICON_DARK })

      Row()
        .width(WSBS_BOOK_MARK_W)
        .height(WSBS_BOOK_MARK_H)
        .backgroundColor(WSBS_ICON_DARK)
        .offset({ y: -1.5 })
    }
    .width(WSBS_ICON_BOX_W)
    .height(WSBS_ICON_BOX_H)
  }

  /** 书城：房屋轮廓，屋脊由左右两道斜边在顶部相接 */
  @Builder
  iconStore() {
    Stack({ alignContent: Alignment.TopStart }) {
      Row()
        .width(WSBS_HOUSE_W)
        .height(WSBS_HOUSE_H)
        .border({
          width: {
            left: WSBS_HOUSE_STROKE,
            right: WSBS_HOUSE_STROKE,
            bottom: WSBS_HOUSE_STROKE,
            top: 0
          },
          color: WSBS_ICON_GRAY
        })
        .borderRadius({ bottomLeft: 4.6, bottomRight: 4.6 })
        .offset({ x: 1.5, y: 6 })

      Row()
        .width(WSBS_HOUSE_ROOF_LEN)
        .height(WSBS_HOUSE_STROKE)
        .backgroundColor(WSBS_ICON_GRAY)
        .rotate({ angle: -WSBS_HOUSE_ROOF_ANGLE })
        .offset({ x: 0.65, y: 2 })

      Row()
        .width(WSBS_HOUSE_ROOF_LEN)
        .height(WSBS_HOUSE_STROKE)
        .backgroundColor(WSBS_ICON_GRAY)
        .rotate({ angle: WSBS_HOUSE_ROOF_ANGLE })
        .offset({ x: 10.15, y: 2 })
    }
    .width(WSBS_ICON_BOX_W)
    .height(WSBS_ICON_BOX_H)
  }

  /** 分类：2×2 四格，前三格方形、右下角一格圆形 */
  @Builder
  iconCategory() {
    Column({ space: WSBS_GRID_GAP }) {
      Row({ space: WSBS_GRID_GAP }) {
        Row()
          .width(WSBS_GRID_CELL)
          .height(WSBS_GRID_CELL)
          .borderRadius(1.6)
          .border({ width: WSBS_GRID_STROKE, color: WSBS_ICON_GRAY })

        Row()
          .width(WSBS_GRID_CELL)
          .height(WSBS_GRID_CELL)
          .borderRadius(1.6)
          .border({ width: WSBS_GRID_STROKE, color: WSBS_ICON_GRAY })
      }

      Row({ space: WSBS_GRID_GAP }) {
        Row()
          .width(WSBS_GRID_CELL)
          .height(WSBS_GRID_CELL)
          .borderRadius(1.6)
          .border({ width: WSBS_GRID_STROKE, color: WSBS_ICON_GRAY })

        Row()
          .width(WSBS_GRID_CELL)
          .height(WSBS_GRID_CELL)
          .borderRadius(WSBS_GRID_CELL / 2)
          .border({ width: WSBS_GRID_STROKE, color: WSBS_ICON_GRAY })
      }
    }
    .width(WSBS_ICON_BOX_W)
    .height(WSBS_ICON_BOX_H)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  /** 我的：一个圆环 + 圈内一道短横 */
  @Builder
  iconPerson() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(WSBS_PERSON_RING)
        .height(WSBS_PERSON_RING)
        .borderRadius(WSBS_PERSON_RING / 2)
        .border({ width: WSBS_PERSON_STROKE, color: WSBS_ICON_GRAY })

      Row()
        .width(WSBS_PERSON_DASH_W)
        .height(WSBS_PERSON_DASH_H)
        .borderRadius(WSBS_PERSON_DASH_H / 2)
        .backgroundColor(WSBS_ICON_GRAY)
        .offset({ y: 5 })
    }
    .width(WSBS_ICON_BOX_W)
    .height(WSBS_ICON_BOX_H)
  }

  @Builder
  tabIcon(tabIndex: number) {
    if (tabIndex === 0) {
      this.iconBookshelf()
    } else if (tabIndex === 1) {
      this.iconStore()
    } else if (tabIndex === 2) {
      this.iconCategory()
    } else {
      this.iconPerson()
    }
  }

  @Builder
  tabItem(tabIndex: number, tabLabel: string, tabSelected: boolean) {
    Column() {
      this.tabIcon(tabIndex)

      Text(tabLabel)
        .fontSize(WSBS_BAR_LABEL_FONT)
        .fontColor(tabSelected ? WSBS_BAR_LABEL_ACTIVE : WSBS_BAR_LABEL_IDLE)
        .maxLines(1)
        .margin({ top: WSBS_BAR_LABEL_GAP })
    }
    .layoutWeight(1)
    .height('100%')
    .padding({ top: WSBS_BAR_PAD_TOP })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  bottomTabBar() {
    Row() {
      this.tabItem(0, '书架', true)
      this.tabItem(1, '书城', false)
      this.tabItem(2, '分类', false)
      this.tabItem(3, '我的', false)
    }
    .width('100%')
    .height(WSBS_BAR_HEIGHT)
    .backgroundColor(WSBS_PAGE_BG)
    .border({ width: { top: WSBS_BAR_DIVIDER_H }, color: WSBS_BAR_DIVIDER })
    .alignItems(VerticalAlign.Top)
  }

  build() {
    NavDestination() {
      Column() {
        this.headerBar()
        this.todayRow()
        this.bookList()
        this.bottomTabBar()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(WSBS_PAGE_BG)
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
