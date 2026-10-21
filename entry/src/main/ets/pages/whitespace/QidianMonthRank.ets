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
 * 反例：留白过多 / 起点读书「月票榜」榜单页右侧与行内大块空白
 *
 * 复刻对象：起点读书「月票榜」页，双屏横屏截图。顶部粉红渐变大头图：左上「男生小说排行 ⌄」
 *   半透明白胶囊，下面白色大字「起点月票榜」，右上角起点 logo（白色笔锋）与头图右侧一团
 *   白色光晕。下面一行横向 tab 铺满整宽：全部 / 玄幻 / 奇幻 / 武侠 / 仙侠 / 都市 / 现实 /
 *   历史 / 军事 / 游戏 / 体育 / 科幻 / 悬疑 / 轻小说 / 诸天无限（「全部」黑色加粗 + 下方红条）。
 *   左侧竖排分类栏：「‹ 月票榜」棕色选中项，下面灰底面板里的 畅销榜 / 新书榜 / 完结榜 /
 *   出圈榜 / 名作堂。右侧内容：第 1 名浅粉大卡片（左侧书封 +「（11/13·单日冠军）」+ 书名
 *   「捞尸人」+「纯洁滴小龙 · 6663票」）；下面一行「起点月票」/「新书月票」胶囊 + 灰色 ?
 *   + 右侧「往期 ›」；再往下单列 2~5 名：排名 + 书封 + 书名 + 作者·分类·字数，右侧「月票」
 *   与大号票数（119,712 / 76,514 / 61,839 / 54,024 / 47,996）。底部黑色四页签
 *   （书架 / 精选 / 月票榜 / 我的）。书封与头图 logo 裁自截图，存于 media/ws_qm_*。
 *
 * 设计基准：截图 3184×2232px（这里用的是 986×694 的等比缩小版，比例一致），密度 2.75，
 *   vp = px / 2.75，参考窗口 1157.8×811.6vp。括号内是缩小版上量到的 px 值，
 *   换算系数 1.174（= 3184 / 986 / 2.75）：
 *   头图：整块高 140.9vp（120px），自上而下 #FEA6A2 → #DD6464；
 *         胶囊距左 18.8vp（16px）、距顶 61vp（52px）、高 20vp（17px）、宽 105.7vp（90px）、
 *         圆角 10vp、内字 13.5vp（11.5px）；大标题字 28.4vp（24.2px 见方）、左缘 21.1vp
 *         （18px）、字顶 91.6vp（78px）；logo 118.6×68.1vp（101×58px）、左缘 858.2vp（731px）、
 *         上缘 47vp（40px）；光晕 493×305vp（420×260px），中心约在 x 786vp（670px）；
 *   分类 tab 行：高 45.8vp（39px）、15 项等分、字 18.2vp（15.5px），选中项下方红条
 *         22.3×4.7vp（19×4px），行底 1px 分隔线；
 *   左侧栏：宽 85.7vp（73px）；选中项高 45.8vp（39px）、字 14.8vp（12.6px）、文字左缘 20vp（17px）、
 *         两侧棕色饰纹 4.7×11.7vp；灰面板 #F3F3F4 顶角圆角 11.7vp（10px）、条目高 45.8vp（39px）、
 *         文字左缘 22.3vp（19px）；第 2、3 条之间一条 48.1vp（41px）宽的分隔线；
 *   内容区：左右内边距各 15.3vp（13px）；
 *   第 1 名卡片：高 82.2vp（70px）、圆角 7vp（6px）、底色 #F5ECEE；书封 61×82.2vp（52×70px）
 *         贴住卡片左边；书封到文字 11.7vp（10px）；上行字 10vp（8.5px）、书名 16.8vp（14.3px）、
 *         下行字 11.7vp（10px）；
 *   胶囊行：距卡片 15.3vp（13px）、胶囊高 29.4vp（25px）、每个宽 72.8vp（62px）、间隔 9.4vp（8px）、
 *         内字 14vp（12px）；? 圆圈 15.3vp（13px）；「往期 ›」12vp（10px），右缘距窗口右 15.3vp；
 *   榜单行：距胶囊行 17.6vp（15px）、行高 83.4vp（71px）；书封 50.5×68.1vp（43×58px）；
 *         书封到文字 17.6vp（15px）；书名 15.3vp（13px）、作者行 13vp（11.1px）；
 *         右侧「月票」12.5vp（10.5px）、票数 13.2vp（11.2px），两者右缘距窗口右 15.3vp（13px）；
 *   底部页签：高 71.6vp（61px）、图标 18.8vp（16px）、页签字 13vp（11px），下方再留
 *         18.8vp（16px）手势区。
 *   以上数值按 sceneScale = 窗口宽 / 1157.8 等比换算，宽窗口下不拉伸。
 *
 * 三态实测（同一套设计值 × sceneScale；行内空白 = 书名行右缘（第 272px）到右侧票数左缘
 *   （第 932px）的 774.8vp 空档，卡片空白 = 卡片内容右缘到卡片右缘的 852.3vp 空档，
 *   分别为窗口宽的 66.9% / 卡片宽的 82.2%）：
 *   单屏态      459.6×672vp   —— ×0.397：行内空白 307.6vp（约占宽度 66.9%），
 *                                卡片空白 338.4vp（约占卡片宽度 82.2%），
 *                                第 5 行之下还空 335.8vp（约占高度 50.0%）
 *   双屏态竖屏  664.7×939.6vp —— ×0.574：行内空白 444.7vp（约占宽度 66.9%），
 *                                卡片空白 489.3vp（约占卡片宽度 82.2%），
 *                                第 5 行之下还空 453.4vp（约占高度 48.3%）
 *   双屏态横屏  939.6×664.7vp —— ×0.812：行内空白 628.8vp（约占宽度 66.9%），
 *                                卡片空白 691.6vp（约占卡片宽度 82.2%），
 *                                第 5 行被底部页签裁掉 22.5vp，行下方无空白
 *
 * 问题表现：
 *   第 1 名粉色卡片横跨整个内容区，但书封、书名、票数全挤在左边，卡片右侧八成以上
 *   是没有任何内容的粉色底；2~5 名每一行也是整窗宽的一条，左边排名 + 书封 + 书名 +
 *   作者·分类·字数到窗口宽度三成左右就结束，「月票」与大号票数被推到窗口最右边，
 *   两段内容之间空出约占宽度三分之二的一整片白，中间没有分隔线、没有次级信息；
 *   榜单始终只有一列，宽窗口下也没有并成两列或把卡片拆成多块；
 *   窗口越宽，这块行内空白与卡片空白越大，内容始终贴着左右两端不铺开。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 基准窗口宽度（3184px / 密度 2.75）：所有设计值都以它为基准等比换算 */
const WSQM_BASE_WIDTH: number = 1157.8;

/** 配色：粉红头图、白底内容、棕金选中态、粉色榜首卡片、红色选中页签 */
const WSQM_PAGE_BG: string = '#FFFFFF';
const WSQM_HERO_TOP: string = '#FEA6A2';
const WSQM_HERO_MID: string = '#F08480';
const WSQM_HERO_BOTTOM: string = '#DD6464';
const WSQM_PILL_BG: string = '#73FFFFFF';
const WSQM_HERO_TEXT: string = '#FFFFFF';
const WSQM_TAB_IDLE: string = '#8A8A8A';
const WSQM_TAB_ACTIVE: string = '#1A1A1A';
const WSQM_TAB_LINE: string = '#F4707A';
const WSQM_TAB_DIVIDER: string = '#F2F2F2';
const WSQM_SIDE_BG: string = '#F3F3F4';
const WSQM_SIDE_TEXT: string = '#757575';
const WSQM_SIDE_ACTIVE: string = '#A87C4E';
const WSQM_SIDE_DIVIDER: string = '#E4E4E4';
const WSQM_CARD_BG: string = '#F5ECEE';
const WSQM_CARD_KICKER: string = '#B08F6B';
const WSQM_CARD_TITLE: string = '#262626';
const WSQM_CARD_SUB: string = '#9A9A9A';
const WSQM_PILL_ON_BG: string = '#FDE7E9';
const WSQM_PILL_ON_TEXT: string = '#E2545B';
const WSQM_PILL_OFF_BG: string = '#F2F1F1';
const WSQM_PILL_OFF_TEXT: string = '#8C8C8C';
const WSQM_HELP_LINE: string = '#C8C8C8';
const WSQM_PAST_TEXT: string = '#8C8C8C';
const WSQM_RANK_NUM: string = '#8A8A8A';
const WSQM_BOOK_TITLE: string = '#1E1E1E';
const WSQM_BOOK_META: string = '#999999';
const WSQM_VOTE_LABEL: string = '#6A6A6A';
const WSQM_VOTE_NUM: string = '#9A9A9A';
const WSQM_BAR_TEXT: string = '#333333';
const WSQM_BAR_ACTIVE: string = '#E0353F';

/** 头图渐变：自上而下 */
const WSQM_HERO_COLORS: Array<[ResourceColor, number]> = [
  [WSQM_HERO_TOP, 0.0],
  [WSQM_HERO_MID, 0.55],
  [WSQM_HERO_BOTTOM, 1.0]
];

/** 头图：高 140.9vp；胶囊、大标题、logo、光晕的位置 */
const WSQM_HERO_HEIGHT: number = 140.9;
const WSQM_HERO_PILL_LEFT: number = 18.8;
const WSQM_HERO_PILL_TOP: number = 61;
const WSQM_HERO_PILL_HEIGHT: number = 20;
const WSQM_HERO_PILL_RADIUS: number = 10;
const WSQM_HERO_PILL_FONT: number = 13.5;
const WSQM_HERO_PILL_PAD_LEFT: number = 9.4;
const WSQM_HERO_PILL_PAD_RIGHT: number = 7;
const WSQM_HERO_CHEVRON_W: number = 7;
const WSQM_HERO_CHEVRON_H: number = 1.4;
const WSQM_HERO_CHEVRON_ANGLE: number = 42;
const WSQM_HERO_CHEVRON_GAP: number = 5.9;
const WSQM_HERO_CHEVRON_OFFSET: number = 1.5;
const WSQM_HERO_TITLE_LEFT: number = 21.1;
const WSQM_HERO_TITLE_TOP: number = 86;
const WSQM_HERO_TITLE_FONT: number = 28.4;
const WSQM_HERO_LOGO_LEFT: number = 858.2;
const WSQM_HERO_LOGO_TOP: number = 47;
const WSQM_HERO_LOGO_W: number = 118.6;
const WSQM_HERO_LOGO_H: number = 68.1;
const WSQM_HERO_GLOW_LEFT: number = 540;
const WSQM_HERO_GLOW_TOP: number = -60;
const WSQM_HERO_GLOW_W: number = 493;
const WSQM_HERO_GLOW_H: number = 305;

/** 分类 tab 行：高 45.8vp、字 18.2vp、选中红条 22.3×4.7vp */
const WSQM_TAB_HEIGHT: number = 45.8;
const WSQM_TAB_FONT: number = 18.2;
const WSQM_TAB_INDICATOR_W: number = 22.3;
const WSQM_TAB_INDICATOR_H: number = 4.7;
const WSQM_TAB_INDICATOR_GAP: number = 1.2;
const WSQM_TAB_DIVIDER_H: number = 1.2;

/** 左侧栏：宽 85.7vp、选中项 45.8vp、灰面板顶角圆角 11.7vp、条目 45.8vp */
const WSQM_SIDE_WIDTH: number = 85.7;
const WSQM_SIDE_SELECT_HEIGHT: number = 45.8;
const WSQM_SIDE_FONT: number = 14.8;
const WSQM_SIDE_SELECT_PAD: number = 20;
const WSQM_SIDE_ITEM_HEIGHT: number = 45.8;
const WSQM_SIDE_PAD_LEFT: number = 22.3;
const WSQM_SIDE_PANEL_RADIUS: number = 11.7;
const WSQM_SIDE_DIVIDER_W: number = 48.1;
const WSQM_SIDE_DIVIDER_H: number = 1.2;
const WSQM_SIDE_MARK_W: number = 4.7;
const WSQM_SIDE_MARK_H: number = 11.7;
const WSQM_SIDE_MARK_BAR_W: number = 1.8;
const WSQM_SIDE_MARK_BAR_H: number = 7;
const WSQM_SIDE_MARK_BAR_GAP: number = 2.3;
const WSQM_SIDE_MARK_BAR_ANGLE: number = 16;
const WSQM_SIDE_MARK_GAP: number = 4.7;

/** 内容区：左右内边距 15.3vp；榜首卡片高 82.2vp、圆角 7vp、书封 61×82.2vp */
const WSQM_CONTENT_PAD: number = 15.3;
const WSQM_CARD_TOP: number = 8.2;
const WSQM_CARD_HEIGHT: number = 82.2;
const WSQM_CARD_RADIUS: number = 7;
const WSQM_CARD_COVER_W: number = 61;
const WSQM_CARD_TEXT_GAP: number = 11.7;
const WSQM_CARD_KICKER_FONT: number = 10;
const WSQM_CARD_TITLE_FONT: number = 16.8;
const WSQM_CARD_SUB_FONT: number = 11.7;
const WSQM_CARD_LINE_GAP: number = 3.5;

/** 胶囊行：距卡片 15.3vp、胶囊高 29.4vp、宽 72.8vp、间隔 9.4vp、内字 14vp */
const WSQM_PILL_ROW_TOP: number = 15.3;
const WSQM_PILL_HEIGHT: number = 29.4;
const WSQM_PILL_WIDTH: number = 72.8;
const WSQM_PILL_GAP: number = 9.4;
const WSQM_PILL_FONT: number = 14;
const WSQM_HELP_SIZE: number = 15.3;
const WSQM_HELP_FONT: number = 10;
const WSQM_HELP_GAP: number = 11.7;
const WSQM_PAST_FONT: number = 12;

/** 榜单行：距胶囊行 17.6vp、行高 83.4vp、书封 50.5×68.1vp、书封到文字 17.6vp */
const WSQM_LIST_TOP: number = 17.6;
const WSQM_ROW_HEIGHT: number = 83.4;
const WSQM_COVER_W: number = 50.5;
const WSQM_COVER_H: number = 68.1;
const WSQM_COVER_RADIUS: number = 1.2;
const WSQM_ROW_TEXT_GAP: number = 17.6;
const WSQM_ROW_TITLE_FONT: number = 15.3;
const WSQM_ROW_META_FONT: number = 13;
const WSQM_ROW_LINE_GAP: number = 2.3;
const WSQM_VOTE_LABEL_FONT: number = 12.5;
const WSQM_VOTE_NUM_FONT: number = 13.2;
const WSQM_VOTE_LINE_GAP: number = 2.3;

/** 底部页签：高 71.6vp、图标 18.8vp、字 13vp；下方手势区 18.8vp */
const WSQM_BAR_HEIGHT: number = 71.6;
const WSQM_BAR_ICON: number = 18.8;
const WSQM_BAR_FONT: number = 13;
const WSQM_BAR_ICON_GAP: number = 4.7;
const WSQM_BAR_DIVIDER_H: number = 1.2;
const WSQM_BAR_SAFE: number = 18.8;

/** 分类 tab：15 项，当前只高亮第一项「全部」，其余为灰字 */
interface WSQM_CatTab {
  tabKey: string;
  tabLabel: string;
}

const WSQM_CAT_TABS: WSQM_CatTab[] = [
  { tabKey: 'qm-cat-all', tabLabel: '全部' },
  { tabKey: 'qm-cat-xuanhuan', tabLabel: '玄幻' },
  { tabKey: 'qm-cat-qihuan', tabLabel: '奇幻' },
  { tabKey: 'qm-cat-wuxia', tabLabel: '武侠' },
  { tabKey: 'qm-cat-xianxia', tabLabel: '仙侠' },
  { tabKey: 'qm-cat-dushi', tabLabel: '都市' },
  { tabKey: 'qm-cat-xianshi', tabLabel: '现实' },
  { tabKey: 'qm-cat-lishi', tabLabel: '历史' },
  { tabKey: 'qm-cat-junshi', tabLabel: '军事' },
  { tabKey: 'qm-cat-youxi', tabLabel: '游戏' },
  { tabKey: 'qm-cat-tiyu', tabLabel: '体育' },
  { tabKey: 'qm-cat-kehuan', tabLabel: '科幻' },
  { tabKey: 'qm-cat-xuanyi', tabLabel: '悬疑' },
  { tabKey: 'qm-cat-qingxiaoshuo', tabLabel: '轻小说' },
  { tabKey: 'qm-cat-zhutian', tabLabel: '诸天无限' }
];

/** 左侧灰面板里的竖排分类：第 2 条后面跟一条分隔线 */
interface WSQM_SideItem {
  sideKey: string;
  sideLabel: string;
  sideDivider: boolean;
}

const WSQM_SIDE_ITEMS: WSQM_SideItem[] = [
  { sideKey: 'qm-side-sale', sideLabel: '畅销榜', sideDivider: false },
  { sideKey: 'qm-side-new', sideLabel: '新书榜', sideDivider: true },
  { sideKey: 'qm-side-done', sideLabel: '完结榜', sideDivider: false },
  { sideKey: 'qm-side-circle', sideLabel: '出圈榜', sideDivider: false },
  { sideKey: 'qm-side-master', sideLabel: '名作堂', sideDivider: false }
];

/** 榜单条目：书封裁自截图，存于 media/ws_qm_cover_* */
interface WSQM_BookItem {
  bookKey: string;
  bookRank: string;
  bookTitle: string;
  bookMeta: string;
  bookVote: string;
  bookCover: Resource;
}

/** 底部页签类型：shape 用图形画，symbol 用系统符号 */
interface WSQM_BarItem {
  barKey: string;
  barLabel: string;
  barActive: boolean;
}

const WSQM_BAR_ITEMS: WSQM_BarItem[] = [
  { barKey: 'qm-bar-shelf', barLabel: '书架', barActive: false },
  { barKey: 'qm-bar-pick', barLabel: '精选', barActive: false },
  { barKey: 'qm-bar-rank', barLabel: '月票榜', barActive: true },
  { barKey: 'qm-bar-mine', barLabel: '我的', barActive: false }
];

@Component
export struct QidianMonthRankPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽度（vp），随折叠 / 旋转实时更新；整页缩放比由它算出 */
  @State winWidthVp: number = 939.6;

  /** 窗口高度（vp），随折叠 / 旋转实时更新 */
  @State winHeightVp: number = 664.7;

  /** 当前选中的分类 tab */
  @State activeTabKey: string = 'qm-cat-all';

  /** 当前选中的票种：起点月票 / 新书月票 */
  @State activeVoteKey: string = 'qm-vote-qidian';

  private contentScroller: Scroller = new Scroller();
  private bookItems: WSQM_BookItem[] = [];
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
    this.bookItems = [
      {
        bookKey: 'qm-book-laoshiren',
        bookRank: '1.',
        bookTitle: '捞尸人',
        bookMeta: '纯洁滴小龙 · 都市 · 436万字',
        bookVote: '119,712',
        bookCover: $r('app.media.ws_qm_cover_laoshiren')
      },
      {
        bookKey: 'qm-book-shengmo',
        bookRank: '2.',
        bookTitle: '苟在初圣魔门当人材',
        bookMeta: '鹤守月满池 · 玄幻 · 268万字',
        bookVote: '76,514',
        bookCover: $r('app.media.ws_qm_cover_shengmo')
      },
      {
        bookKey: 'qm-book-xuanjian',
        bookRank: '3.',
        bookTitle: '玄鉴仙族',
        bookMeta: '季越人 · 仙侠 · 493万字',
        bookVote: '61,839',
        bookCover: $r('app.media.ws_qm_cover_xuanjian')
      },
      {
        bookKey: 'qm-book-meiqian',
        bookRank: '4.',
        bookTitle: '没钱修什么仙?',
        bookMeta: '熊狼狗 · 仙侠 · 250万字',
        bookVote: '54,024',
        bookCover: $r('app.media.ws_qm_cover_meiqian')
      },
      {
        bookKey: 'qm-book-yewujiang',
        bookRank: '5.',
        bookTitle: '夜无疆',
        bookMeta: '辰东 · 玄幻 · 241万字',
        bookVote: '47,996',
        bookCover: $r('app.media.ws_qm_cover_yewujiang')
      }
    ];
  }

  /** 整页缩放比：窗口宽度 / 基准窗口宽度（1157.8vp） */
  private sceneScale(): number {
    if (this.winWidthVp <= 0) {
      return 1;
    }
    return this.winWidthVp / WSQM_BASE_WIDTH;
  }

  /** 把按基准窗口量出的设计值换算到当前窗口 */
  private sc(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  // ------------------------------------------------------------------
  // 顶部粉红头图
  // ------------------------------------------------------------------

  /** 胶囊里的向下箭头：两条斜线交成一个「⌄」 */
  @Builder
  heroChevron() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(this.sc(WSQM_HERO_CHEVRON_W))
        .height(this.sc(WSQM_HERO_CHEVRON_H))
        .backgroundColor(WSQM_HERO_TEXT)
        .rotate({ angle: WSQM_HERO_CHEVRON_ANGLE })
        .offset({ x: -this.sc(WSQM_HERO_CHEVRON_OFFSET), y: this.sc(WSQM_HERO_CHEVRON_OFFSET) / 2 })

      Row()
        .width(this.sc(WSQM_HERO_CHEVRON_W))
        .height(this.sc(WSQM_HERO_CHEVRON_H))
        .backgroundColor(WSQM_HERO_TEXT)
        .rotate({ angle: -WSQM_HERO_CHEVRON_ANGLE })
        .offset({ x: this.sc(WSQM_HERO_CHEVRON_OFFSET), y: this.sc(WSQM_HERO_CHEVRON_OFFSET) / 2 })
    }
    .width(this.sc(WSQM_HERO_CHEVRON_GAP))
    .height(this.sc(WSQM_HERO_CHEVRON_GAP))
    .margin({ left: this.sc(2.3) })
  }

  @Builder
  heroPill() {
    Row() {
      Text('男生小说排行')
        .fontSize(this.sc(WSQM_HERO_PILL_FONT))
        .fontColor(WSQM_HERO_TEXT)
        .maxLines(1)

      this.heroChevron()
    }
    .height(this.sc(WSQM_HERO_PILL_HEIGHT))
    .padding({
      left: this.sc(WSQM_HERO_PILL_PAD_LEFT),
      right: this.sc(WSQM_HERO_PILL_PAD_RIGHT)
    })
    .backgroundColor(WSQM_PILL_BG)
    .borderRadius(this.sc(WSQM_HERO_PILL_RADIUS))
    .alignItems(VerticalAlign.Center)
    .offset({ x: this.sc(WSQM_HERO_PILL_LEFT), y: this.sc(WSQM_HERO_PILL_TOP) })
  }

  @Builder
  heroBand() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 头图右侧那团白色光晕
      Image($r('app.media.ws_qm_hero_glow'))
        .width(this.sc(WSQM_HERO_GLOW_W))
        .height(this.sc(WSQM_HERO_GLOW_H))
        .objectFit(ImageFit.Fill)
        .offset({ x: this.sc(WSQM_HERO_GLOW_LEFT), y: this.sc(WSQM_HERO_GLOW_TOP) })

      // 右上角起点 logo（白色笔锋，裁自截图）
      Image($r('app.media.ws_qm_logo_qidian'))
        .width(this.sc(WSQM_HERO_LOGO_W))
        .height(this.sc(WSQM_HERO_LOGO_H))
        .objectFit(ImageFit.Contain)
        .offset({ x: this.sc(WSQM_HERO_LOGO_LEFT), y: this.sc(WSQM_HERO_LOGO_TOP) })

      this.heroPill()

      Text('起点月票榜')
        .fontSize(this.sc(WSQM_HERO_TITLE_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(WSQM_HERO_TEXT)
        .maxLines(1)
        .offset({ x: this.sc(WSQM_HERO_TITLE_LEFT), y: this.sc(WSQM_HERO_TITLE_TOP) })
    }
    .width('100%')
    .height(this.sc(WSQM_HERO_HEIGHT))
    .linearGradient({ angle: 180, colors: WSQM_HERO_COLORS })
    .clip(true)
  }

  // ------------------------------------------------------------------
  // 分类 tab 行
  // ------------------------------------------------------------------

  @Builder
  catTabCell(tab: WSQM_CatTab) {
    Column() {
      Text(tab.tabLabel)
        .fontSize(this.sc(WSQM_TAB_FONT))
        .fontWeight(this.activeTabKey === tab.tabKey ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.activeTabKey === tab.tabKey ? WSQM_TAB_ACTIVE : WSQM_TAB_IDLE)
        .maxLines(1)

      if (this.activeTabKey === tab.tabKey) {
        Row()
          .width(this.sc(WSQM_TAB_INDICATOR_W))
          .height(this.sc(WSQM_TAB_INDICATOR_H))
          .backgroundColor(WSQM_TAB_LINE)
          .borderRadius(this.sc(WSQM_TAB_INDICATOR_H / 2))
          .margin({ top: this.sc(WSQM_TAB_INDICATOR_GAP) })
      }
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.activeTabKey = tab.tabKey;
    })
  }

  @Builder
  catTabRow() {
    Column() {
      Row() {
        ForEach(WSQM_CAT_TABS, (tab: WSQM_CatTab) => {
          this.catTabCell(tab)
        }, (tab: WSQM_CatTab) => tab.tabKey + (this.activeTabKey === tab.tabKey ? '#on' : '#off'))
      }
      .width('100%')
      .layoutWeight(1)

      Row()
        .width('100%')
        .height(this.sc(WSQM_TAB_DIVIDER_H))
        .backgroundColor(WSQM_TAB_DIVIDER)
    }
    .width('100%')
    .height(this.sc(WSQM_TAB_HEIGHT))
  }

  // ------------------------------------------------------------------
  // 左侧竖排分类栏
  // ------------------------------------------------------------------

  /** 选中项两侧的棕色饰纹：两根短斜线叠成一束 */
  @Builder
  sideMark(flip: boolean) {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(this.sc(WSQM_SIDE_MARK_BAR_W))
        .height(this.sc(WSQM_SIDE_MARK_BAR_H))
        .backgroundColor(WSQM_SIDE_ACTIVE)
        .borderRadius(this.sc(WSQM_SIDE_MARK_BAR_W / 2))
        .rotate({ angle: flip ? -WSQM_SIDE_MARK_BAR_ANGLE : WSQM_SIDE_MARK_BAR_ANGLE })
        .offset({ y: -this.sc(WSQM_SIDE_MARK_BAR_GAP) })

      Row()
        .width(this.sc(WSQM_SIDE_MARK_BAR_W))
        .height(this.sc(WSQM_SIDE_MARK_BAR_H))
        .backgroundColor(WSQM_SIDE_ACTIVE)
        .borderRadius(this.sc(WSQM_SIDE_MARK_BAR_W / 2))
        .rotate({ angle: flip ? WSQM_SIDE_MARK_BAR_ANGLE : -WSQM_SIDE_MARK_BAR_ANGLE })
        .offset({ y: this.sc(WSQM_SIDE_MARK_BAR_GAP) })
    }
    .width(this.sc(WSQM_SIDE_MARK_W))
    .height(this.sc(WSQM_SIDE_MARK_H))
  }

  @Builder
  sideSelectedRow() {
    Row() {
      this.sideMark(false)

      Text('月票榜')
        .fontSize(this.sc(WSQM_SIDE_FONT))
        .fontColor(WSQM_SIDE_ACTIVE)
        .maxLines(1)
        .margin({
          left: this.sc(WSQM_SIDE_MARK_GAP),
          right: this.sc(WSQM_SIDE_MARK_GAP)
        })

      this.sideMark(true)
    }
    .width('100%')
    .height(this.sc(WSQM_SIDE_SELECT_HEIGHT))
    .padding({ left: this.sc(WSQM_SIDE_SELECT_PAD) })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  sideItemRow(item: WSQM_SideItem) {
    Column() {
      Row() {
        Text(item.sideLabel)
          .fontSize(this.sc(WSQM_SIDE_FONT))
          .fontColor(WSQM_SIDE_TEXT)
          .maxLines(1)
      }
      .width('100%')
      .height(this.sc(WSQM_SIDE_ITEM_HEIGHT))
      .padding({ left: this.sc(WSQM_SIDE_PAD_LEFT) })
      .alignItems(VerticalAlign.Center)

      if (item.sideDivider) {
        Row()
          .width(this.sc(WSQM_SIDE_DIVIDER_W))
          .height(this.sc(WSQM_SIDE_DIVIDER_H))
          .backgroundColor(WSQM_SIDE_DIVIDER)
          .margin({ left: this.sc(WSQM_SIDE_PAD_LEFT) })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  sideColumn() {
    Column() {
      this.sideSelectedRow()

      Column() {
        ForEach(WSQM_SIDE_ITEMS, (item: WSQM_SideItem) => {
          this.sideItemRow(item)
        }, (item: WSQM_SideItem) => item.sideKey)
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor(WSQM_SIDE_BG)
      .borderRadius({
        topLeft: this.sc(WSQM_SIDE_PANEL_RADIUS),
        topRight: this.sc(WSQM_SIDE_PANEL_RADIUS)
      })
      .alignItems(HorizontalAlign.Start)
    }
    .width(this.sc(WSQM_SIDE_WIDTH))
    .height('100%')
  }

  // ------------------------------------------------------------------
  // 第 1 名大卡片
  // ------------------------------------------------------------------

  @Builder
  championCard() {
    Row() {
      Image($r('app.media.ws_qm_cover_laoshiren_big'))
        .width(this.sc(WSQM_CARD_COVER_W))
        .height(this.sc(WSQM_CARD_HEIGHT))
        .objectFit(ImageFit.Cover)

      Column({ space: this.sc(WSQM_CARD_LINE_GAP) }) {
        Text('（11/13·单日冠军）')
          .fontSize(this.sc(WSQM_CARD_KICKER_FONT))
          .fontColor(WSQM_CARD_KICKER)
          .maxLines(1)

        Text('捞尸人')
          .fontSize(this.sc(WSQM_CARD_TITLE_FONT))
          .fontWeight(FontWeight.Medium)
          .fontColor(WSQM_CARD_TITLE)
          .maxLines(1)

        Text('纯洁滴小龙 · 6663票')
          .fontSize(this.sc(WSQM_CARD_SUB_FONT))
          .fontColor(WSQM_CARD_SUB)
          .maxLines(1)
      }
      .height(this.sc(WSQM_CARD_HEIGHT))
      .margin({ left: this.sc(WSQM_CARD_TEXT_GAP) })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(this.sc(WSQM_CARD_HEIGHT))
    .backgroundColor(WSQM_CARD_BG)
    .borderRadius(this.sc(WSQM_CARD_RADIUS))
    .clip(true)
    .alignItems(VerticalAlign.Top)
    .margin({ top: this.sc(WSQM_CARD_TOP) })
  }

  // ------------------------------------------------------------------
  // 票种切换行
  // ------------------------------------------------------------------

  @Builder
  votePill(pillKey: string, pillLabel: string) {
    Text(pillLabel)
      .fontSize(this.sc(WSQM_PILL_FONT))
      .fontWeight(this.activeVoteKey === pillKey ? FontWeight.Medium : FontWeight.Normal)
      .fontColor(this.activeVoteKey === pillKey ? WSQM_PILL_ON_TEXT : WSQM_PILL_OFF_TEXT)
      .backgroundColor(this.activeVoteKey === pillKey ? WSQM_PILL_ON_BG : WSQM_PILL_OFF_BG)
      .width(this.sc(WSQM_PILL_WIDTH))
      .height(this.sc(WSQM_PILL_HEIGHT))
      .textAlign(TextAlign.Center)
      .maxLines(1)
      .borderRadius(this.sc(WSQM_PILL_HEIGHT / 2))
      .onClick(() => {
        this.activeVoteKey = pillKey;
      })
  }

  @Builder
  voteRow() {
    Row() {
      this.votePill('qm-vote-qidian', '起点月票')

      Row()
        .width(this.sc(WSQM_PILL_GAP))

      this.votePill('qm-vote-new', '新书月票')

      Row()
        .width(this.sc(WSQM_HELP_GAP))

      Stack({ alignContent: Alignment.Center }) {
        Row()
          .width(this.sc(WSQM_HELP_SIZE))
          .height(this.sc(WSQM_HELP_SIZE))
          .border({ width: 1, color: WSQM_HELP_LINE })
          .borderRadius(this.sc(WSQM_HELP_SIZE / 2))

        Text('?')
          .fontSize(this.sc(WSQM_HELP_FONT))
          .fontColor(WSQM_HELP_LINE)
          .maxLines(1)
      }
      .width(this.sc(WSQM_HELP_SIZE))
      .height(this.sc(WSQM_HELP_SIZE))

      Blank()

      Text('往期')
        .fontSize(this.sc(WSQM_PAST_FONT))
        .fontColor(WSQM_PAST_TEXT)
        .maxLines(1)

      Text('›')
        .fontSize(this.sc(WSQM_PAST_FONT))
        .fontColor(WSQM_PAST_TEXT)
        .maxLines(1)
        .margin({ left: this.sc(2.3) })
    }
    .width('100%')
    .height(this.sc(WSQM_PILL_HEIGHT))
    .alignItems(VerticalAlign.Center)
    .margin({ top: this.sc(WSQM_PILL_ROW_TOP) })
  }

  // ------------------------------------------------------------------
  // 2~5 名单列榜单
  // ------------------------------------------------------------------

  @Builder
  rankRow(book: WSQM_BookItem) {
    Row() {
      Image(book.bookCover)
        .width(this.sc(WSQM_COVER_W))
        .height(this.sc(WSQM_COVER_H))
        .objectFit(ImageFit.Cover)
        .borderRadius(this.sc(WSQM_COVER_RADIUS))
        .clip(true)

      Column({ space: this.sc(WSQM_ROW_LINE_GAP) }) {
        Text() {
          Span(book.bookRank)
            .fontColor(WSQM_RANK_NUM)
          Span(book.bookTitle)
            .fontColor(WSQM_BOOK_TITLE)
        }
        .fontSize(this.sc(WSQM_ROW_TITLE_FONT))
        .fontWeight(FontWeight.Medium)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(book.bookMeta)
          .fontSize(this.sc(WSQM_ROW_META_FONT))
          .fontColor(WSQM_BOOK_META)
          .maxLines(1)
      }
      .height(this.sc(WSQM_COVER_H))
      .margin({ left: this.sc(WSQM_ROW_TEXT_GAP) })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)

      Blank()

      Column({ space: this.sc(WSQM_VOTE_LINE_GAP) }) {
        Text('月票')
          .fontSize(this.sc(WSQM_VOTE_LABEL_FONT))
          .fontColor(WSQM_VOTE_LABEL)
          .maxLines(1)

        Text(book.bookVote)
          .fontSize(this.sc(WSQM_VOTE_NUM_FONT))
          .fontColor(WSQM_VOTE_NUM)
          .maxLines(1)
      }
      .height(this.sc(WSQM_COVER_H))
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .height(this.sc(WSQM_ROW_HEIGHT))
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  rankList() {
    List({ scroller: this.contentScroller }) {
      ForEach(this.bookItems, (book: WSQM_BookItem) => {
        ListItem() {
          this.rankRow(book)
        }
      }, (book: WSQM_BookItem) => book.bookKey)
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ top: this.sc(WSQM_LIST_TOP) })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.None)
  }

  @Builder
  contentColumn() {
    Column() {
      this.championCard()
      this.voteRow()
      this.rankList()
    }
    .layoutWeight(1)
    .height('100%')
    .padding({
      left: this.sc(WSQM_CONTENT_PAD),
      right: this.sc(WSQM_CONTENT_PAD)
    })
    .alignItems(HorizontalAlign.Start)
  }

  // ------------------------------------------------------------------
  // 底部页签
  // ------------------------------------------------------------------

  /** 书架图标：圆角方框 + 一条横线 */
  @Builder
  shelfIcon(color: string) {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(this.sc(WSQM_BAR_ICON))
        .height(this.sc(WSQM_BAR_ICON) * 0.8)
        .border({ width: 1.2, color: color, radius: this.sc(2.3) })

      Row()
        .width(this.sc(WSQM_BAR_ICON) * 0.62)
        .height(1.2)
        .backgroundColor(color)
        .offset({ y: -this.sc(WSQM_BAR_ICON) * 0.1 })
    }
    .width(this.sc(WSQM_BAR_ICON))
    .height(this.sc(WSQM_BAR_ICON))
  }

  /** 精选图标：菱形外框 */
  @Builder
  gemIcon(color: string) {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(this.sc(WSQM_BAR_ICON) * 0.68)
        .height(this.sc(WSQM_BAR_ICON) * 0.68)
        .border({ width: 1.2, color: color, radius: this.sc(1.2) })
        .rotate({ angle: 45 })
    }
    .width(this.sc(WSQM_BAR_ICON))
    .height(this.sc(WSQM_BAR_ICON))
  }

  @Builder
  barIcon(item: WSQM_BarItem) {
    Stack({ alignContent: Alignment.Center }) {
      if (item.barKey === 'qm-bar-shelf') {
        this.shelfIcon(item.barActive ? WSQM_BAR_ACTIVE : WSQM_BAR_TEXT)
      } else if (item.barKey === 'qm-bar-pick') {
        this.gemIcon(item.barActive ? WSQM_BAR_ACTIVE : WSQM_BAR_TEXT)
      } else if (item.barKey === 'qm-bar-rank') {
        SymbolGlyph($r('sys.symbol.ticket_fill'))
          .fontSize(this.sc(WSQM_BAR_ICON))
          .fontColor([WSQM_BAR_ACTIVE])
      } else {
        SymbolGlyph($r('sys.symbol.person'))
          .fontSize(this.sc(WSQM_BAR_ICON))
          .fontColor([WSQM_BAR_TEXT])
      }
    }
    .width(this.sc(WSQM_BAR_ICON))
    .height(this.sc(WSQM_BAR_ICON))
  }

  @Builder
  barCell(item: WSQM_BarItem) {
    Column({ space: this.sc(WSQM_BAR_ICON_GAP) }) {
      this.barIcon(item)

      Text(item.barLabel)
        .fontSize(this.sc(WSQM_BAR_FONT))
        .fontColor(item.barActive ? WSQM_BAR_ACTIVE : WSQM_BAR_TEXT)
        .maxLines(1)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  bottomBar() {
    Column() {
      Row()
        .width('100%')
        .height(this.sc(WSQM_BAR_DIVIDER_H))
        .backgroundColor(WSQM_TAB_DIVIDER)

      Row() {
        ForEach(WSQM_BAR_ITEMS, (item: WSQM_BarItem) => {
          this.barCell(item)
        }, (item: WSQM_BarItem) => item.barKey)
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height(this.sc(WSQM_BAR_HEIGHT))
    .backgroundColor(WSQM_PAGE_BG)
  }

  build() {
    NavDestination() {
      Column() {
        this.heroBand()

        this.catTabRow()

        Row() {
          this.sideColumn()

          this.contentColumn()
        }
        .width('100%')
        .layoutWeight(1)
        .alignItems(VerticalAlign.Top)

        this.bottomBar()

        Row()
          .width('100%')
          .height(this.sc(WSQM_BAR_SAFE))
          .backgroundColor(WSQM_PAGE_BG)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(WSQM_PAGE_BG)
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
