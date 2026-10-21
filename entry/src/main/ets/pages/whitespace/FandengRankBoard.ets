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
 * 反例：留白过多 / 帆书「黑马榜」榜单页右侧整列空白
 *
 * 复刻对象：帆书（樊登读书）「黑马榜」榜单页，双屏横屏截图。顶部左侧返回箭头、居中标题
 *   「黑马榜」（两侧金色饰纹）、右上编辑图标，标题下方一行灰色小字「根据近期热听飙升指数
 *   排行」；主体左边是竖排榜单分类（热听榜 / 经典榜 / 黑马榜 / 热搜榜 / 心灵榜 /
 *   个人成长榜 / 亲子家庭榜 / 人文历史榜 / 热听周榜 / 热听月榜），其中「黑马榜」加粗、
 *   两侧带金色饰纹；右边内容区先是两行筛选「全部 樊登讲书 非凡精读馆 李蕾讲经典 课程」
 *   与「全部 未读 已读」，再往下是单列书目：左侧排名数字 1~6、方形彩色书封（裁自截图）、
 *   右侧书名与灰色「播放量…万」，最后一条被窗口底边裁掉。
 *
 * 设计基准：截图 3184×2232px（这里用的是 984×694 的等比缩小版，比例一致），密度 2.75，
 *   vp = px / 2.75，参考窗口 1157.8×811.6vp。括号内是缩小版上量到的 px 值，
 *   换算系数 1.17664（= 3184 / 984 / 2.75）：
 *   顶部区：整块高 116.5vp（99px，截图上是自上而下渐隐到白的浅灰带）；
 *           标题行 30.6vp（26px）、标题字 19vp（「黑马榜」3 字宽 46px）、标题行距页顶 50.6vp
 *           （43px）、两侧饰纹字 20vp（左右各 15px 宽，贴住标题）；
 *           副标题 12.5vp（12 字宽 129px，字顶 80px）、标题到副标题 7.7vp；
 *           返回箭头 9.4×18.8vp（8×16px、笔画 1.9vp、左缘在 24.7vp、竖中心 65.3vp）；
 *           编辑图标 17.6×16.5vp（15×14px、笔画 1.8vp、圆角 3.5vp），右缘距窗口右边 16.4vp；
 *   分类栏：宽 109.4vp（93px，右缘 1vp 分隔线）；条目高 62.4vp（53px，首条字顶 121px）、
 *           字 14.2vp（3 字宽 35px）、文字左缘 42.4vp（36px）、行高 20vp（两行条目行距 17px）、
 *           选中项两侧饰纹 4.7vp 宽（4px），饰纹与文字间距 9.5vp；
 *   内容区：左内边距 12vp（筛选与书目文字左缘 104px=122.4vp）；
 *           筛选行高 37.6vp（32px）、字 14.3vp（「全部 未读 已读」6 字+2 间距共 101px）、
 *           词间距 18.1vp（15.4px）、首行距内容区顶 6.5vp、第二行距第一行 37.6vp；
 *   书目列：首条封面顶 215.3vp（183px，即筛选行下方留 17vp）；行高 104vp（88.4px）；
 *           排名数字 13vp、排名列宽 15.3vp（数字左缘 122.4vp）；
 *           封面 62.3×84.7vp（53×72px、圆角 2vp）；封面到文字 12.9vp（11px）；
 *           书名 14.8vp（5 字宽 61px、字高 12px）、播放量 11.4vp、两行间距 2.5vp；
 *           整列内容右缘停在 301.2vp（最长一行「播放量1734.7万」右缘 256px）。
 *
 * 三态实测（上表 vp 值固定排版，只有整行宽的行跟着窗口拉长；留白 = 窗口宽 − 301.2vp）：
 *   单屏态      459.6×672vp    —— 留白 158.4vp，约占宽度的 34%
 *   双屏态竖屏  664.7×939.6vp  —— 留白 363.5vp，约占宽度的 55%
 *   双屏态横屏  939.6×664.7vp  —— 留白 638.4vp，约占宽度的 68%
 *   参考窗口    1157.8×811.6vp —— 留白 856.6vp，约占宽度的 74%（截图量到的就是这一态）
 *
 * 问题表现：
 *   筛选行、分隔线、每条书目都是整窗宽的行，但真正有内容的部分全挤在左边一条：
 *   分类栏 + 排名 + 封面 + 书名 + 播放量，最宽的一行右缘也只到窗口宽度的三成左右。
 *   从这一条往右直到窗口右缘是一整片没有任何内容的白色，横跨窗口七成以上宽度；
 *   书目始终只有一列，宽屏下没有并成两列，右半屏整列空着；
 *   两行筛选词的右侧同样一路空到窗口右缘。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 配色：白底页面、浅灰顶带、近黑标题、金色饰纹与选中筛选词、灰色次要文字 */
const WSFD_PAGE_BG: string = '#FFFFFF';
const WSFD_HEADER_BG: string = '#EDECEA';
const WSFD_TITLE_TEXT: string = '#262626';
const WSFD_ICON_COLOR: string = '#3A3A3A';
const WSFD_GOLD: string = '#C8A96B';
const WSFD_GOLD_TEXT: string = '#C2A26C';
const WSFD_SUBTITLE_TEXT: string = '#8E8E8E';
const WSFD_SIDE_TEXT: string = '#8A8A8A';
const WSFD_SIDE_ACTIVE: string = '#262626';
const WSFD_FILTER_IDLE: string = '#8B8B8B';
const WSFD_BOOK_TITLE_TEXT: string = '#1A1A1A';
const WSFD_BOOK_PLAY_TEXT: string = '#8C8C8C';
const WSFD_RANK_TEXT: string = '#5A5A5A';
const WSFD_DIVIDER_COLOR: string = '#ECECEC';

/** 顶部区：整块 116.5vp、上内边距 50.6vp、标题行 30.6vp、标题字 19vp、饰纹字 20vp */
const WSFD_HEADER_HEIGHT: number = 116.5;
const WSFD_HEADER_PAD_TOP: number = 50.6;
const WSFD_TITLE_ROW_HEIGHT: number = 30.6;
const WSFD_TITLE_FONT: number = 19;
const WSFD_TITLE_ORN_FONT: number = 20;
const WSFD_TITLE_ORN_GAP: number = 1;

/** 副标题：12.5vp，字顶距标题行底 7.7vp，行高 17.6vp */
const WSFD_SUBTITLE_FONT: number = 12.5;
const WSFD_SUBTITLE_HEIGHT: number = 17.6;
const WSFD_SUBTITLE_GAP: number = 7.7;

/** 返回箭头：外接 9.4×18.8vp、笔画 1.9vp、左缘 24.7vp；44vp 触摸区左内边距 7.5vp */
const WSFD_BACK_TOUCH: number = 44;
const WSFD_BACK_PAD_LEFT: number = 7.5;
const WSFD_BACK_W: number = 9.4;
const WSFD_BACK_H: number = 18.8;
const WSFD_BACK_STROKE: number = 1.9;
const WSFD_BACK_BAR_LEN: number = 13.3;
const WSFD_BACK_BAR_ANGLE: number = 46;
const WSFD_BACK_BAR_GAP: number = 4.7;

/** 编辑图标：外接 17.6×16.5vp、笔画 1.8vp、圆角 3.5vp、右边距 16.4vp */
const WSFD_EDIT_W: number = 17.6;
const WSFD_EDIT_H: number = 16.5;
const WSFD_EDIT_STROKE: number = 1.8;
const WSFD_EDIT_RADIUS: number = 3.5;
const WSFD_EDIT_BAR_LEN: number = 11;
const WSFD_EDIT_BAR_OFFSET: number = 4.6;
const WSFD_EDIT_PAD_RIGHT: number = 16.4;

/** 分类栏：宽 109.4vp、右侧 1vp 分隔线、条目高 62.4vp、字 14.2vp、文字左缘 42.4vp */
const WSFD_SIDE_WIDTH: number = 109.4;
const WSFD_DIVIDER_WIDTH: number = 1;
const WSFD_SIDE_ITEM_HEIGHT: number = 62.4;
const WSFD_SIDE_FONT: number = 14.2;
const WSFD_SIDE_LINE_HEIGHT: number = 20;
const WSFD_SIDE_PAD_LEFT: number = 28.2;
const WSFD_SIDE_ORN_W: number = 4.7;
const WSFD_SIDE_ORN_H: number = 13;
const WSFD_SIDE_ORN_BAR_W: number = 1.6;
const WSFD_SIDE_ORN_BAR_H: number = 6;
const WSFD_SIDE_ORN_BAR_GAP: number = 3.2;
const WSFD_SIDE_ORN_BAR_ANGLE: number = 18;
const WSFD_SIDE_ORN_GAP: number = 9.5;

/** 内容区：左内边距 12vp、筛选行高 37.6vp、字 14.3vp、词间距 18.1vp、首行上留 6.5vp */
const WSFD_CONTENT_PAD_LEFT: number = 12;
const WSFD_FILTER_TOP: number = 6.5;
const WSFD_FILTER_ROW_HEIGHT: number = 37.6;
const WSFD_FILTER_FONT: number = 14.3;
const WSFD_FILTER_GAP: number = 18.1;

/** 书目列：首条距筛选区 17vp、行高 104vp、排名列 15.3vp、封面 62.3×84.7vp */
const WSFD_LIST_TOP: number = 17;
const WSFD_ROW_HEIGHT: number = 104;
const WSFD_RANK_WIDTH: number = 15.3;
const WSFD_RANK_FONT: number = 13;
const WSFD_COVER_W: number = 62.3;
const WSFD_COVER_H: number = 84.7;
const WSFD_COVER_RADIUS: number = 2;
const WSFD_COVER_TEXT_GAP: number = 12.9;
const WSFD_BOOK_TITLE_FONT: number = 14.8;
const WSFD_BOOK_PLAY_FONT: number = 11.4;
const WSFD_BOOK_TEXT_GAP: number = 2.5;

/** 榜单分类：条目来自这张表，选中的一项加粗并在两侧画饰纹 */
interface WSFD_RankTab {
  tabKey: string;
  tabLabel: string;
  tabActive: boolean;
}

const WSFD_RANK_TABS: WSFD_RankTab[] = [
  { tabKey: 'fd-rank-hoting', tabLabel: '热听榜', tabActive: false },
  { tabKey: 'fd-rank-classic', tabLabel: '经典榜', tabActive: false },
  { tabKey: 'fd-rank-darkhorse', tabLabel: '黑马榜', tabActive: true },
  { tabKey: 'fd-rank-search', tabLabel: '热搜榜', tabActive: false },
  { tabKey: 'fd-rank-mind', tabLabel: '心灵榜', tabActive: false },
  { tabKey: 'fd-rank-growth', tabLabel: '个人\n成长榜', tabActive: false },
  { tabKey: 'fd-rank-family', tabLabel: '亲子\n家庭榜', tabActive: false },
  { tabKey: 'fd-rank-humanity', tabLabel: '人文\n历史榜', tabActive: false },
  { tabKey: 'fd-rank-week', tabLabel: '热听\n周榜', tabActive: false },
  { tabKey: 'fd-rank-month', tabLabel: '热听\n月榜', tabActive: false }
];

/** 筛选词：第一行是内容来源，第二行是阅读状态，各行第一个「全部」为选中态 */
interface WSFD_FilterWord {
  wordKey: string;
  wordLabel: string;
  wordActive: boolean;
}

const WSFD_PUBLISHER_WORDS: WSFD_FilterWord[] = [
  { wordKey: 'fd-pub-all', wordLabel: '全部', wordActive: true },
  { wordKey: 'fd-pub-fandeng', wordLabel: '樊登讲书', wordActive: false },
  { wordKey: 'fd-pub-feifan', wordLabel: '非凡精读馆', wordActive: false },
  { wordKey: 'fd-pub-lilei', wordLabel: '李蕾讲经典', wordActive: false },
  { wordKey: 'fd-pub-course', wordLabel: '课程', wordActive: false }
];

const WSFD_READ_WORDS: WSFD_FilterWord[] = [
  { wordKey: 'fd-read-all', wordLabel: '全部', wordActive: true },
  { wordKey: 'fd-read-unread', wordLabel: '未读', wordActive: false },
  { wordKey: 'fd-read-done', wordLabel: '已读', wordActive: false }
];

/** 榜单条目：封面裁自截图，存于 media/ws_fd_cover_* */
interface WSFD_BookEntry {
  bookKey: string;
  bookRank: string;
  bookTitle: string;
  bookPlay: string;
  bookCover: Resource;
}

@Component
export struct FandengRankBoardPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽度（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = 939.6;

  /** 窗口高度（vp），随折叠 / 旋转实时更新 */
  @State winHeightVp: number = 664.7;

  private contentScroller: Scroller = new Scroller();
  private sideScroller: Scroller = new Scroller();
  private bookEntries: WSFD_BookEntry[] = [];
  private pageActive: boolean = false;
  private windowToken: number = 0;

  aboutToAppear(): void {
    this.pageActive = true;
    this.buildBookData();
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

  private buildBookData(): void {
    this.bookEntries = [
      {
        bookKey: 'fd-book-franklin',
        bookRank: '1',
        bookTitle: '富兰克林传',
        bookPlay: '播放量100.4万',
        bookCover: $r('app.media.ws_fd_cover_franklin')
      },
      {
        bookKey: 'fd-book-yiche',
        bookRank: '2',
        bookTitle: '一澈到底',
        bookPlay: '播放量50.7万',
        bookCover: $r('app.media.ws_fd_cover_yiche')
      },
      {
        bookKey: 'fd-book-tangchao',
        bookRank: '3',
        bookTitle: '她们的唐朝',
        bookPlay: '播放量75.9万',
        bookCover: $r('app.media.ws_fd_cover_tangchao')
      },
      {
        bookKey: 'fd-book-tianxing',
        bookRank: '4',
        bookTitle: '天生不同',
        bookPlay: '播放量157.8万',
        bookCover: $r('app.media.ws_fd_cover_tianxing')
      },
      {
        bookKey: 'fd-book-philosophy',
        bookRank: '5',
        bookTitle: '生活的哲学',
        bookPlay: '播放量1734.7万',
        bookCover: $r('app.media.ws_fd_cover_shenghuo')
      },
      {
        bookKey: 'fd-book-method',
        bookRank: '6',
        bookTitle: '谈谈方法',
        bookPlay: '播放量92.6万',
        bookCover: $r('app.media.ws_fd_cover_tantan')
      }
    ];
  }

  // ------------------------------------------------------------------
  // 顶部：返回箭头 + 居中标题 + 编辑图标 + 副标题
  // ------------------------------------------------------------------

  /** 返回箭头：两条斜向笔画在左侧交成一个「‹」 */
  @Builder
  backArrow() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(WSFD_BACK_BAR_LEN)
        .height(WSFD_BACK_STROKE)
        .backgroundColor(WSFD_ICON_COLOR)
        .borderRadius(WSFD_BACK_STROKE / 2)
        .rotate({ angle: -WSFD_BACK_BAR_ANGLE })
        .offset({ y: -WSFD_BACK_BAR_GAP })

      Row()
        .width(WSFD_BACK_BAR_LEN)
        .height(WSFD_BACK_STROKE)
        .backgroundColor(WSFD_ICON_COLOR)
        .borderRadius(WSFD_BACK_STROKE / 2)
        .rotate({ angle: WSFD_BACK_BAR_ANGLE })
        .offset({ y: WSFD_BACK_BAR_GAP })
    }
    .width(WSFD_BACK_W)
    .height(WSFD_BACK_H)
  }

  /** 编辑图标：圆角方框 + 一条斜穿的笔杆，笔杆探出方框右上角 */
  @Builder
  editIcon() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(WSFD_EDIT_W)
        .height(WSFD_EDIT_H)
        .border({ width: WSFD_EDIT_STROKE, color: WSFD_ICON_COLOR, radius: WSFD_EDIT_RADIUS })

      Row()
        .width(WSFD_EDIT_BAR_LEN)
        .height(WSFD_EDIT_STROKE)
        .backgroundColor(WSFD_ICON_COLOR)
        .rotate({ angle: -45 })
        .offset({ x: WSFD_EDIT_BAR_OFFSET, y: -WSFD_EDIT_BAR_OFFSET })
    }
    .width(WSFD_EDIT_W)
    .height(WSFD_EDIT_H)
  }

  @Builder
  headerBar() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        Row({ space: WSFD_TITLE_ORN_GAP }) {
          Text('“')
            .fontSize(WSFD_TITLE_ORN_FONT)
            .fontColor(WSFD_GOLD)
            .maxLines(1)

          Text('黑马榜')
            .fontSize(WSFD_TITLE_FONT)
            .fontWeight(FontWeight.Bold)
            .fontColor(WSFD_TITLE_TEXT)
            .maxLines(1)

          Text('”')
            .fontSize(WSFD_TITLE_ORN_FONT)
            .fontColor(WSFD_GOLD)
            .maxLines(1)
        }
        .alignItems(VerticalAlign.Center)

        Row() {
          Stack({ alignContent: Alignment.Center }) {
            this.backArrow()
          }
          .width(WSFD_BACK_TOUCH)
          .height(WSFD_TITLE_ROW_HEIGHT)
          .onClick(() => {
            this.pageStack.pop();
          })

          Blank()
        }
        .width('100%')
        .height(WSFD_TITLE_ROW_HEIGHT)
        .padding({ left: WSFD_BACK_PAD_LEFT })
        .alignItems(VerticalAlign.Center)

        Row() {
          Blank()

          Stack({ alignContent: Alignment.Center }) {
            this.editIcon()
          }
          .width(WSFD_EDIT_W)
          .height(WSFD_TITLE_ROW_HEIGHT)
        }
        .width('100%')
        .height(WSFD_TITLE_ROW_HEIGHT)
        .padding({ right: WSFD_EDIT_PAD_RIGHT })
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height(WSFD_TITLE_ROW_HEIGHT)

      Text('根据近期热听飙升指数排行')
        .fontSize(WSFD_SUBTITLE_FONT)
        .fontColor(WSFD_SUBTITLE_TEXT)
        .height(WSFD_SUBTITLE_HEIGHT)
        .maxLines(1)
        .margin({ top: WSFD_SUBTITLE_GAP })
    }
    .width('100%')
    .height(WSFD_HEADER_HEIGHT)
    .padding({ top: WSFD_HEADER_PAD_TOP })
    .backgroundColor(WSFD_HEADER_BG)
    .alignItems(HorizontalAlign.Center)
  }

  // ------------------------------------------------------------------
  // 左侧榜单分类栏
  // ------------------------------------------------------------------

  /** 选中项两侧的金色饰纹：两根短笔画斜着叠成一束，外接 4.7×13vp */
  @Builder
  sideMark(flip: boolean) {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(WSFD_SIDE_ORN_BAR_W)
        .height(WSFD_SIDE_ORN_BAR_H)
        .backgroundColor(WSFD_GOLD)
        .borderRadius(WSFD_SIDE_ORN_BAR_W / 2)
        .rotate({ angle: flip ? WSFD_SIDE_ORN_BAR_ANGLE : -WSFD_SIDE_ORN_BAR_ANGLE })
        .offset({ y: -WSFD_SIDE_ORN_BAR_GAP })

      Row()
        .width(WSFD_SIDE_ORN_BAR_W)
        .height(WSFD_SIDE_ORN_BAR_H)
        .backgroundColor(WSFD_GOLD)
        .borderRadius(WSFD_SIDE_ORN_BAR_W / 2)
        .rotate({ angle: flip ? -WSFD_SIDE_ORN_BAR_ANGLE : WSFD_SIDE_ORN_BAR_ANGLE })
        .offset({ y: WSFD_SIDE_ORN_BAR_GAP })
    }
    .width(WSFD_SIDE_ORN_W)
    .height(WSFD_SIDE_ORN_H)
  }

  /** 一个分类：选中项加粗、两侧各一个金色饰纹；其余项为灰色单/双行文字 */
  @Builder
  sideTabRow(tab: WSFD_RankTab) {
    Row() {
      if (tab.tabActive) {
        this.sideMark(false)
      } else {
        Row()
          .width(WSFD_SIDE_ORN_W)
      }

      Text(tab.tabLabel)
        .fontSize(WSFD_SIDE_FONT)
        .fontWeight(tab.tabActive ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(tab.tabActive ? WSFD_SIDE_ACTIVE : WSFD_SIDE_TEXT)
        .lineHeight(WSFD_SIDE_LINE_HEIGHT)
        .maxLines(2)
        .margin({ left: WSFD_SIDE_ORN_GAP })

      if (tab.tabActive) {
        Stack({ alignContent: Alignment.Center }) {
          this.sideMark(true)
        }
        .width(WSFD_SIDE_ORN_W)
        .height(WSFD_SIDE_ORN_H)
        .margin({ left: WSFD_SIDE_ORN_GAP })
      }
    }
    .width('100%')
    .height(WSFD_SIDE_ITEM_HEIGHT)
    .padding({ left: WSFD_SIDE_PAD_LEFT })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  sideColumn() {
    Scroll(this.sideScroller) {
      Column() {
        ForEach(WSFD_RANK_TABS, (tab: WSFD_RankTab) => {
          this.sideTabRow(tab)
        }, (tab: WSFD_RankTab) => tab.tabKey)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width(WSFD_SIDE_WIDTH)
    .height('100%')
    .scrollBar(BarState.Off)
    .align(Alignment.Top)
  }

  @Builder
  sideDivider() {
    Row()
      .width(WSFD_DIVIDER_WIDTH)
      .height('100%')
      .backgroundColor(WSFD_DIVIDER_COLOR)
  }

  // ------------------------------------------------------------------
  // 右侧内容区：两行筛选 + 单列书目
  // ------------------------------------------------------------------

  @Builder
  filterWord(word: WSFD_FilterWord) {
    Text(word.wordLabel)
      .fontSize(WSFD_FILTER_FONT)
      .fontWeight(word.wordActive ? FontWeight.Medium : FontWeight.Normal)
      .fontColor(word.wordActive ? WSFD_GOLD_TEXT : WSFD_FILTER_IDLE)
      .maxLines(1)
  }

  @Builder
  filterRow(words: WSFD_FilterWord[]) {
    Row({ space: WSFD_FILTER_GAP }) {
      ForEach(words, (word: WSFD_FilterWord) => {
        this.filterWord(word)
      }, (word: WSFD_FilterWord) => word.wordKey)
    }
    .width('100%')
    .height(WSFD_FILTER_ROW_HEIGHT)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  bookRow(book: WSFD_BookEntry) {
    Row() {
      Column() {
        Text(book.bookRank)
          .fontSize(WSFD_RANK_FONT)
          .fontColor(WSFD_RANK_TEXT)
          .maxLines(1)
      }
      .width(WSFD_RANK_WIDTH)
      .height(WSFD_COVER_H)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      Image(book.bookCover)
        .width(WSFD_COVER_W)
        .height(WSFD_COVER_H)
        .objectFit(ImageFit.Cover)
        .borderRadius(WSFD_COVER_RADIUS)
        .clip(true)

      Column({ space: WSFD_BOOK_TEXT_GAP }) {
        Text(book.bookTitle)
          .fontSize(WSFD_BOOK_TITLE_FONT)
          .fontWeight(FontWeight.Medium)
          .fontColor(WSFD_BOOK_TITLE_TEXT)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(book.bookPlay)
          .fontSize(WSFD_BOOK_PLAY_FONT)
          .fontColor(WSFD_BOOK_PLAY_TEXT)
          .maxLines(1)
      }
      .height(WSFD_COVER_H)
      .margin({ left: WSFD_COVER_TEXT_GAP })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(WSFD_ROW_HEIGHT)
    .padding({ left: WSFD_CONTENT_PAD_LEFT })
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  bookList() {
    List({ scroller: this.contentScroller }) {
      ForEach(this.bookEntries, (book: WSFD_BookEntry) => {
        ListItem() {
          this.bookRow(book)
        }
      }, (book: WSFD_BookEntry) => book.bookKey)
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ top: WSFD_LIST_TOP })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.None)
  }

  @Builder
  contentArea() {
    Column() {
      Column() {
        this.filterRow(WSFD_PUBLISHER_WORDS)

        this.filterRow(WSFD_READ_WORDS)
      }
      .width('100%')
      .padding({ left: WSFD_CONTENT_PAD_LEFT, top: WSFD_FILTER_TOP })
      .alignItems(HorizontalAlign.Start)

      this.bookList()
    }
    .layoutWeight(1)
    .height('100%')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    NavDestination() {
      Column() {
        this.headerBar()

        Row() {
          this.sideColumn()

          this.sideDivider()

          this.contentArea()
        }
        .width('100%')
        .layoutWeight(1)
        .alignItems(VerticalAlign.Top)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(WSFD_PAGE_BG)
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
