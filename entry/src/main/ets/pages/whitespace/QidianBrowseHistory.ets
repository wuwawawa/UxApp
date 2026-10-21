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
 * 反例：留白过多 / 浏览历史页书目右侧整片空白
 *
 * 复刻对象：起点读书 App「浏览历史」页，双屏横屏。顶部一行：左上黑色返回箭头「‹」、
 *   居中黑色标题「浏览历史」、右上黑色「编辑」；下面一行日期分组标题「2025-11-14」；
 *   再往下是单列书目，每条是方形彩色书封（盘龙 / 遮天 / 吞噬星空 /
 *   斗罗：开局神位九考降临 / 斗罗：开局神位九考降临 / 诡秘之主），书名贴在封面右侧、
 *   与封面垂直居中，最右侧贴边是浅灰胶囊「✓ 书架」，其中「斗罗」第二本换成白底蓝字「加书架」。
 *   页面底色浅灰 #F6F6F7，行与行之间没有分隔线，也没有任何其它内容。
 *
 * 设计基准：截图 3184×2232px，密度 2.75，vp = px / 2.75（参考窗口 1157.8×811.6vp）；
 *   下面所有 vp 值都由截图里的 px 除以 2.75 得到（给出的图为 988×695px 的等比缩小版，
 *   1 图 px = 1.172vp）。
 *   状态栏占位 33vp；标题行 78vp：标题字 23vp（4 字墨迹 81px 宽）、「编辑」20vp
 *     （右缘距窗口 13vp）；返回箭头外接 8.2×17.6vp、笔画 1.5vp、墨迹左缘距窗口 32vp；
 *   日期行：距标题行 22vp、行高 30vp、字 20vp 加粗、左缩进 26vp；
 *   书目行：行高 118.2vp（100.8px）、封面 72×97vp（61×83px）、圆角 2vp、
 *     封面到书名 18vp（16px）、书名 19vp（每字占 16.1px）；
 *   状态胶囊：81×41vp（69×35px）、圆角 20.5vp、右缘距窗口 26vp、字 17vp、「✓」12vp；
 *   列表左右留白各 26vp。
 *
 * 三态实测（设计值写死，只随窗口宽度重排，不缩放）：
 *   最长书名「斗罗：开局神位九考降临」11 字 × 19vp = 209vp，
 *   左侧内容块到 26 + 72 + 18 + 209 = 325vp 结束；胶囊左缘 = 窗口宽 − 26 − 81。
 *   单屏态      459.6×672vp   —— 书名右侧空 27.6vp，约占宽度的 6%；
 *                                列表可视高 509vp，露出 4.3 行，第 5 行被底边裁掉；
 *   双屏态竖屏  664.7×939.6vp —— 书名右侧空 232.7vp，约占宽度的 35%；
 *                                列表可视高 776.6vp，6 条书目全部露出，底部还余 67.4vp；
 *   双屏态横屏  939.6×664.7vp —— 书名右侧空 507.6vp，约占宽度的 54%；
 *                                左侧内容块只占宽度的 35%，列表可视高 501.7vp，
 *                                露出 4.2 行，第 5 行被底边裁掉。
 *   参考窗口 1157.8×811.6vp 下：书名右侧空 725.8vp，约占宽度的 63%；
 *   左侧内容块只占宽度的 28%，列表露出 5.5 行，第 6 条只剩大半个封面。
 *
 * 问题表现：
 *   每一行都只有最左边一截有内容：书封、书名，然后是一大片纯背景色，
 *   一直到贴着窗口右边缘的「✓ 书架」胶囊才又出现东西；
 *   书名结束的位置到胶囊之间没有任何文字、图片或分隔线，整块空白横跨窗口宽度的一半以上；
 *   最下面一条书目的书封、书名、胶囊都被窗口底边切断，只露出上半截。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 配色：页面浅灰 #F6F6F7、正文近黑、胶囊浅灰底 + 浅灰字、可加书架为白底蓝字 */
const WSQD_PAGE_BG: string = '#F6F6F7';
const WSQD_TEXT_MAIN: string = '#1A1A1A';
const WSQD_PILL_BG: string = '#F1F1F1';
const WSQD_PILL_TEXT: string = '#AEAEAE';
const WSQD_ADD_PILL_BG: string = '#FFFFFF';
const WSQD_ADD_PILL_TEXT: string = '#18A5FD';

/** 顶部：状态栏占位 33vp、标题行 78vp；返回箭头墨迹左缘距窗口 32vp、「编辑」右缘距窗口 13vp */
const WSQD_STATUS_PAD: number = 33;
const WSQD_HEADER_HEIGHT: number = 78;
const WSQD_HEADER_PAD_LEFT: number = 32;
const WSQD_HEADER_PAD_RIGHT: number = 13;

/** 标题行：标题 23vp、右上「编辑」20vp */
const WSQD_TITLE_FONT: number = 23;
const WSQD_ACTION_FONT: number = 20;

/** 返回箭头「‹」：外接 8.2×17.6vp、笔画 1.5vp，两段斜笔各上下偏 4.4vp */
const WSQD_BACK_WIDTH: number = 8.2;
const WSQD_BACK_HEIGHT: number = 17.6;
const WSQD_BACK_STROKE: number = 1.5;
const WSQD_BACK_LEG: number = 12;
const WSQD_BACK_LEG_ANGLE: number = 43;
const WSQD_BACK_LEG_OFFSET: number = 4.4;

/** 日期分组标题：上间距 22vp、行高 30vp、字 20vp、左缩进 26vp */
const WSQD_DATE_MARGIN_TOP: number = 22;
const WSQD_DATE_ROW_HEIGHT: number = 30;
const WSQD_DATE_FONT: number = 20;
const WSQD_DATE_TEXT: string = '2025-11-14';

/** 列表左右留白 26vp */
const WSQD_LIST_PAD: number = 26;

/** 书目行：行高 118.2vp、封面 72×97vp、圆角 2vp、封面到书名 18vp、书名 19vp */
const WSQD_ROW_HEIGHT: number = 118.2;
const WSQD_COVER_WIDTH: number = 72;
const WSQD_COVER_HEIGHT: number = 97;
const WSQD_COVER_RADIUS: number = 2;
const WSQD_COVER_TEXT_GAP: number = 18;
const WSQD_BOOK_TITLE_FONT: number = 19;

/** 右侧状态胶囊：81×41vp、圆角 20.5vp、字 17vp、「✓」12vp、勾与字间距 4vp */
const WSQD_PILL_WIDTH: number = 81;
const WSQD_PILL_HEIGHT: number = 41;
const WSQD_PILL_RADIUS: number = 20.5;
const WSQD_PILL_FONT: number = 17;
const WSQD_PILL_CHECK_FONT: number = 12;
const WSQD_PILL_GAP: number = 4;

/** 一条浏览记录 */
interface WSQD_BookItem {
  /** 书目唯一键（同一本书重复出现时用不同键） */
  bookKey: string;
  bookTitle: string;
  bookCover: Resource;
  /** 已在书架：右侧显示浅灰胶囊「✓ 书架」；否则白底蓝字「加书架」 */
  bookOnShelf: boolean;
}

/** 截图里的 6 条记录，自上而下 */
const WSQD_BOOKS: WSQD_BookItem[] = [
  {
    bookKey: 'ws-qd-book-panlong',
    bookTitle: '盘龙',
    bookCover: $r('app.media.ws_qd_cover_panlong'),
    bookOnShelf: true
  },
  {
    bookKey: 'ws-qd-book-zhetian',
    bookTitle: '遮天',
    bookCover: $r('app.media.ws_qd_cover_zhetian'),
    bookOnShelf: true
  },
  {
    bookKey: 'ws-qd-book-tunshi',
    bookTitle: '吞噬星空',
    bookCover: $r('app.media.ws_qd_cover_tunshi'),
    bookOnShelf: true
  },
  {
    bookKey: 'ws-qd-book-douluo-a',
    bookTitle: '斗罗：开局神位九考降临',
    bookCover: $r('app.media.ws_qd_cover_douluo'),
    bookOnShelf: true
  },
  {
    bookKey: 'ws-qd-book-douluo-b',
    bookTitle: '斗罗：开局神位九考降临',
    bookCover: $r('app.media.ws_qd_cover_douluo_b'),
    bookOnShelf: false
  },
  {
    bookKey: 'ws-qd-book-guimi',
    bookTitle: '诡秘之主',
    bookCover: $r('app.media.ws_qd_cover_tail'),
    bookOnShelf: true
  }
];

@Component
export struct QidianBrowseHistoryPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽度（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = 939.6;

  /** 窗口高度（vp），随折叠 / 旋转实时更新 */
  @State winHeightVp: number = 664.7;

  /** 标题栏右上角在「编辑 / 完成」之间切换 */
  @State headerEditing: boolean = false;

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
  // 顶部标题行
  // ------------------------------------------------------------------

  /** 返回箭头「‹」：两段斜笔上下拼合，外接 8.2×17.6vp */
  @Builder
  backArrow() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(WSQD_BACK_LEG)
        .height(WSQD_BACK_STROKE)
        .backgroundColor(WSQD_TEXT_MAIN)
        .borderRadius(WSQD_BACK_STROKE / 2)
        .rotate({ angle: -WSQD_BACK_LEG_ANGLE })
        .offset({ y: -WSQD_BACK_LEG_OFFSET })

      Row()
        .width(WSQD_BACK_LEG)
        .height(WSQD_BACK_STROKE)
        .backgroundColor(WSQD_TEXT_MAIN)
        .borderRadius(WSQD_BACK_STROKE / 2)
        .rotate({ angle: WSQD_BACK_LEG_ANGLE })
        .offset({ y: WSQD_BACK_LEG_OFFSET })
    }
    .width(WSQD_BACK_WIDTH)
    .height(WSQD_BACK_HEIGHT)
    .onClick(() => {
      this.pageStack.pop();
    })
  }

  @Builder
  titleRow() {
    Stack({ alignContent: Alignment.Center }) {
      Text('浏览历史')
        .fontSize(WSQD_TITLE_FONT)
        .fontWeight(FontWeight.Bold)
        .fontColor(WSQD_TEXT_MAIN)
        .maxLines(1)

      Row() {
        this.backArrow()

        Blank()

        Text(this.headerEditing ? '完成' : '编辑')
          .fontSize(WSQD_ACTION_FONT)
          .fontColor(WSQD_TEXT_MAIN)
          .maxLines(1)
          .onClick(() => {
            this.headerEditing = !this.headerEditing;
          })
      }
      .width('100%')
      .height('100%')
      .padding({ left: WSQD_HEADER_PAD_LEFT, right: WSQD_HEADER_PAD_RIGHT })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(WSQD_HEADER_HEIGHT)
  }

  @Builder
  headerBand() {
    Column() {
      this.titleRow()
    }
    .width('100%')
    .height(WSQD_STATUS_PAD + WSQD_HEADER_HEIGHT)
    .padding({ top: WSQD_STATUS_PAD })
    .alignItems(HorizontalAlign.Start)
  }

  // ------------------------------------------------------------------
  // 日期分组标题
  // ------------------------------------------------------------------

  @Builder
  dateGroupTitle() {
    Row() {
      Text(WSQD_DATE_TEXT)
        .fontSize(WSQD_DATE_FONT)
        .fontWeight(FontWeight.Bold)
        .fontColor(WSQD_TEXT_MAIN)
        .maxLines(1)
    }
    .width('100%')
    .height(WSQD_DATE_ROW_HEIGHT)
    .margin({ top: WSQD_DATE_MARGIN_TOP })
    .padding({ left: WSQD_LIST_PAD })
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
  }

  // ------------------------------------------------------------------
  // 书目列表
  // ------------------------------------------------------------------

  /** 右侧状态胶囊：已加入书架是浅灰底浅灰字，未加入是白底蓝字 */
  @Builder
  shelfPill(item: WSQD_BookItem) {
    Row({ space: WSQD_PILL_GAP }) {
      if (item.bookOnShelf) {
        Text('✓')
          .fontSize(WSQD_PILL_CHECK_FONT)
          .fontColor(WSQD_PILL_TEXT)
          .maxLines(1)
      }

      Text(item.bookOnShelf ? '书架' : '加书架')
        .fontSize(WSQD_PILL_FONT)
        .fontColor(item.bookOnShelf ? WSQD_PILL_TEXT : WSQD_ADD_PILL_TEXT)
        .maxLines(1)
    }
    .width(WSQD_PILL_WIDTH)
    .height(WSQD_PILL_HEIGHT)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(item.bookOnShelf ? WSQD_PILL_BG : WSQD_ADD_PILL_BG)
    .borderRadius(WSQD_PILL_RADIUS)
  }

  /** 一条书目：左侧书封 + 书名，右侧胶囊由 Blank 顶到窗口右边 */
  @Builder
  bookRow(item: WSQD_BookItem) {
    Row() {
      Image(item.bookCover)
        .width(WSQD_COVER_WIDTH)
        .height(WSQD_COVER_HEIGHT)
        .objectFit(ImageFit.Cover)
        .borderRadius(WSQD_COVER_RADIUS)
        .clip(true)

      Text(item.bookTitle)
        .fontSize(WSQD_BOOK_TITLE_FONT)
        .fontColor(WSQD_TEXT_MAIN)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ left: WSQD_COVER_TEXT_GAP })

      Blank()

      this.shelfPill(item)
    }
    .width('100%')
    .height(WSQD_ROW_HEIGHT)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  bookList() {
    List() {
      ForEach(WSQD_BOOKS, (item: WSQD_BookItem) => {
        ListItem() {
          this.bookRow(item)
        }
      }, (item: WSQD_BookItem) => item.bookKey)
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: WSQD_LIST_PAD, right: WSQD_LIST_PAD })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.None)
  }

  build() {
    NavDestination() {
      Column() {
        this.headerBand()

        this.dateGroupTitle()

        this.bookList()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(WSQD_PAGE_BG)
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
