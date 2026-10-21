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
 * 反例：留白过多 / 百度热搜榜（双屏横屏）
 *
 * 复刻对象：百度 App「新闻资讯」综合搜索结果页。顶部红色渐变大头部：白色圆角搜索框
 *   （左侧蓝色百度爪印图标 + 黑字「新闻资讯」+ 右侧麦克风、相机线框图标）；下面一排
 *   「Ai+ / 综合 / 笔记 / 视频 / 图片 / 筛选」，选中项白色加粗并带白色短下划线；
 *   再下面只有居中的白色大字「百度热搜」。头部下方白色大圆角卡片：一排 5 个等分入口
 *   （彩色圆底图标 + 一行黑字 热搜榜 / 小说榜 / 电影榜 / 电视剧榜 / 更多榜单）、
 *   「热搜榜 ›」、9 条热搜行（彩色名次 + 标题 + 右侧橙色「热」或粉色「新」角标，
 *   行间 1vp 细线）；底部白色导航栏（返回、菜单、紫色 Ai+ 按钮、「1」方框、爪印图标、
 *   灰色手势条），导航栏压住第 9 条热搜的下半截。
 *
 * 设计基准：双屏横屏截图 3184×2232px，密度 2.75，vp = px / 2.75 → 1157.8×811.6vp。
 *   头部高 205.5vp（565px）：搜索框距顶 46.5vp（128px）、高 40vp（110px）、
 *     左右各 16.8vp（46px）、圆角 12vp（33px）；框内爪印 21.8×24.7vp、
 *     「新闻资讯」16.5vp（每字 45px）、麦克风 13.8×17.5vp、相机 18.5×17.5vp、
 *     两图标间距 13.5vp、框右内边距 14.2vp；
 *   tab 行 38.5vp（86.5～125vp）：tab 字 15vp（每字 40px），tab 中心距 219.7vp；
 *     选中项下划线 19×2vp（52×5px）、距 tab 字底 6vp；
 *   「百度热搜」47vp（每字 130px），字块 173.5×41.5vp、水平居中、距 tab 行顶 13.5vp；
 *   卡片顶 205.5vp、上圆角 11vp（30px）；入口区上内边距 16.4vp（45px）、
 *     图标 30vp（82px）、图标到文字 10.2vp（28px）、文字 14.5vp（每字 39px）、
 *     入口区左右内边距 14.5vp（40px）；
 *   「热搜榜」18vp（每字 50px）粗体 + 右侧 13×14vp 折角；
 *   热搜行行高 48.8vp（134.3px）、左右内边距 17.5vp（48px）、名次 17.5vp（x 17.5～44vp）、
 *     标题 16.5vp（x 44vp 起）、角标 16.7vp 方块（46px）圆角 3vp；
 *   分隔线 1vp #F3F3F3、两端各缩进 17.5vp（48px）；
 *   底部导航栏 72.7vp（200px）= 图标行 45vp + 手势区 27.7vp；Ai+ 按钮 39.3vp 方块
 *     圆角 11vp，手势条 239×4.4vp、距底 6.5vp。
 *
 * 三态实测（同一套写死的 vp 设计值，行 / 卡片宽度取 100%）：
 *   单屏态 459.6×672vp：「百度热搜」宽 173.5vp 占宽 37.7%，左右各留 143.1vp（约占宽度 31%）；
 *     头部 205.5vp 占高 30.6%；热搜行标题最右到 357vp，角标左边缘 425.4vp，
 *     单行空白 68.4vp（约占宽度 15%）
 *   双屏竖屏 664.7×939.6vp：文字占宽 26.1%，左右各留 245.6vp（约占宽度 37%）；
 *     头部占高 21.9%；单行空白 273.5vp（约占宽度 41%）
 *   双屏横屏 939.6×664.7vp：文字占宽 18.5%，左右各留 383.1vp（约占宽度 41%）；
 *     头部占高 30.9%；角标左边缘 905.4vp，单行空白 548.4vp（约占宽度 58%）
 *
 * 问题表现：红色头部 205.5vp 高，中间只有居中的一行「百度热搜」，字两侧各留下
 *   占宽度四成左右的纯红色；5 个入口横向铺满整宽，每格只有一个 30vp 图标加一行字；
 *   9 条热搜全是「名次 + 一句短标题」贴在最左边，标题到最右侧角标之间整条空着；
 *   底部导航栏 5 个图标横向等分拉满整宽，两两之间隔着一大片白色。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 顶部红色头部 */
const WSBD_HEADER_HEIGHT: number = 205.5;
const WSBD_RED_TOP: string = '#FF7159';
const WSBD_RED_BOTTOM: string = '#FB5348';

/** 搜索框 */
const WSBD_SEARCH_SIDE: number = 16.8;
const WSBD_SEARCH_TOP: number = 46.5;
const WSBD_SEARCH_HEIGHT: number = 40;
const WSBD_SEARCH_RADIUS: number = 12;
const WSBD_SEARCH_PAD_LEFT: number = 10.2;
const WSBD_SEARCH_PAD_RIGHT: number = 14.2;
const WSBD_LOGO_WIDTH: number = 21.8;
const WSBD_LOGO_HEIGHT: number = 24.7;
const WSBD_SEARCH_FONT: number = 16.5;
const WSBD_SEARCH_TEXT_GAP: number = 7.3;
const WSBD_SEARCH_TEXT: string = '#1A1A1A';

/** 搜索框内右侧线框图标 */
const WSBD_ICON_STROKE: number = 1.5;
const WSBD_ICON_COLOR: string = '#3A3B40';
const WSBD_MIC_WIDTH: number = 13.8;
const WSBD_MIC_HEIGHT: number = 17.5;
const WSBD_CAMERA_WIDTH: number = 18.5;
const WSBD_CAMERA_HEIGHT: number = 17.5;
const WSBD_ICON_GAP: number = 13.5;

/** tab 行 */
const WSBD_TAB_ROW_HEIGHT: number = 38.5;
const WSBD_TAB_PAD_LEFT: number = 18.5;
const WSBD_TAB_PAD_RIGHT: number = 21.5;
const WSBD_TAB_FONT: number = 15;
const WSBD_TAB_LINE: number = 20;
const WSBD_TAB_UNDERLINE_WIDTH: number = 19;
const WSBD_TAB_UNDERLINE_HEIGHT: number = 2;
const WSBD_TAB_UNDERLINE_GAP: number = 6;
const WSBD_TAB_UNDERLINE_BOTTOM: number = 4.6;

/** 「百度热搜」大字 */
const WSBD_HOT_WORD_FONT: number = 47;
const WSBD_HOT_WORD_BLOCK: number = 80.5;
const WSBD_HOT_WORD_TOP: number = 13.5;

/** 白色卡片 */
const WSBD_CARD_RADIUS: number = 11;

/** 5 个等分入口 */
const WSBD_ENTRY_TOP: number = 16.4;
const WSBD_ENTRY_BOTTOM: number = 8;
const WSBD_ENTRY_SIDE: number = 14.5;
const WSBD_ENTRY_ICON: number = 30;
const WSBD_ENTRY_ICON_GAP: number = 10.2;
const WSBD_ENTRY_LABEL_FONT: number = 14.5;
const WSBD_ENTRY_LABEL_LINE: number = 20;

/** 「热搜榜 ›」 */
const WSBD_SECTION_FONT: number = 18;
const WSBD_SECTION_HEIGHT: number = 24;
const WSBD_SECTION_SIDE: number = 17.5;
const WSBD_SECTION_BOTTOM: number = 10.3;
const WSBD_ARROW_WIDTH: number = 13;
const WSBD_ARROW_HEIGHT: number = 14;
const WSBD_ARROW_STROKE: number = 1.8;
const WSBD_ARROW_GAP: number = 2.5;

/** 热搜行 */
const WSBD_ROW_HEIGHT: number = 48.8;
const WSBD_ROW_SIDE: number = 17.5;
const WSBD_RANK_WIDTH: number = 26.5;
const WSBD_RANK_FONT: number = 17.5;
const WSBD_TITLE_FONT: number = 16.5;
const WSBD_BADGE_SIZE: number = 16.7;
const WSBD_BADGE_RADIUS: number = 3;
const WSBD_BADGE_FONT: number = 10;
const WSBD_BADGE_GAP: number = 8;
const WSBD_DIVIDER_COLOR: string = '#F3F3F3';

/** 文字与配色 */
const WSBD_TEXT_DARK: string = '#141420';
const WSBD_RANK_ONE: string = '#F3372A';
const WSBD_RANK_TWO: string = '#F8691A';
const WSBD_RANK_THREE: string = '#FF8A0D';
const WSBD_RANK_REST: string = '#797A80';
const WSBD_TAG_HOT: string = '#FF6A22';
const WSBD_TAG_NEW: string = '#FA457C';
const WSBD_NAV_ICON: string = '#141414';
const WSBD_NAV_PILL: string = '#9B9B9B';
const WSBD_AI_FROM: string = '#5A6CF7';
const WSBD_AI_TO: string = '#8B6CF9';

/** 底部导航栏 */
const WSBD_NAV_HEIGHT: number = 72.7;
const WSBD_NAV_ICON_ROW: number = 45;
const WSBD_NAV_AI_SIZE: number = 39.3;
const WSBD_NAV_AI_RADIUS: number = 11;
const WSBD_NAV_SMALL: number = 17.8;
const WSBD_NAV_PILL_WIDTH: number = 239;
const WSBD_NAV_PILL_HEIGHT: number = 4.4;
const WSBD_NAV_PILL_BOTTOM: number = 6.5;

/** 5 个榜单入口 */
interface WSBD_HotEntry {
  entryKey: string;
  entryLabel: string;
}

const WSBD_HOT_ENTRIES: WSBD_HotEntry[] = [
  { entryKey: 'hot', entryLabel: '热搜榜' },
  { entryKey: 'novel', entryLabel: '小说榜' },
  { entryKey: 'movie', entryLabel: '电影榜' },
  { entryKey: 'tv', entryLabel: '电视剧榜' },
  { entryKey: 'more', entryLabel: '更多榜单' }
];

/** tab 项 */
interface WSBD_Tab {
  tabKey: string;
  tabTitle: string;
}

const WSBD_TABS: WSBD_Tab[] = [
  { tabKey: 'all', tabTitle: '综合' },
  { tabKey: 'note', tabTitle: '笔记' },
  { tabKey: 'video', tabTitle: '视频' },
  { tabKey: 'image', tabTitle: '图片' }
];

/** 热搜条目 */
interface WSBD_HotItem {
  itemKey: string;
  itemRank: number;
  itemTitle: string;
  /** 角标文字：「热」/「新」，空串表示无角标 */
  itemTag: string;
}

const WSBD_HOT_ITEMS: WSBD_HotItem[] = [
  { itemKey: 'h1', itemRank: 1, itemTitle: '两部门：不允许城镇居民到农村买农房', itemTag: '热' },
  { itemKey: 'h2', itemRank: 2, itemTitle: '大场面！机器狗扛枪冲锋', itemTag: '热' },
  { itemKey: 'h3', itemRank: 3, itemTitle: '“十五五”规划《纲要》问计求策', itemTag: '' },
  { itemKey: 'h4', itemRank: 4, itemTitle: '邻居称被儿子殴打老人有4个女儿', itemTag: '' },
  { itemKey: 'h5', itemRank: 5, itemTitle: '暴雪！骤降8℃！新一股强冷空气来袭', itemTag: '' },
  { itemKey: 'h6', itemRank: 6, itemTitle: '净网：网民散布买卖儿童器官谣言被罚', itemTag: '' },
  { itemKey: 'h7', itemRank: 7, itemTitle: '百度世界2025', itemTag: '' },
  { itemKey: 'h8', itemRank: 8, itemTitle: '女童丧母冬天穿拖鞋捡食 家中没玻璃', itemTag: '新' },
  { itemKey: 'h9', itemRank: 9, itemTitle: '湖南今冬较往年偏暖 局地偏高2℃', itemTag: '' }
];

@Component
export struct BaiduSearchHotPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口尺寸（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = 939.6;
  @State winHeightVp: number = 664.7;

  /** 当前选中的 tab */
  @State activeTabKey: string = 'all';

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
  // 取值换算
  // ------------------------------------------------------------------

  /** 每个榜单入口的宽度：整宽减去左右内边距后 5 等分 */
  private entryCellWidth(): number {
    return (this.winWidthVp - WSBD_ENTRY_SIDE * 2) / WSBD_HOT_ENTRIES.length;
  }

  private entryIcon(entryKey: string): Resource {
    if (entryKey === 'hot') {
      return $r('app.media.ws_bd_icon_hot');
    }
    if (entryKey === 'novel') {
      return $r('app.media.ws_bd_icon_novel');
    }
    if (entryKey === 'movie') {
      return $r('app.media.ws_bd_icon_movie');
    }
    if (entryKey === 'tv') {
      return $r('app.media.ws_bd_icon_tv');
    }
    return $r('app.media.ws_bd_icon_more');
  }

  private rankColor(rank: number): string {
    if (rank === 1) {
      return WSBD_RANK_ONE;
    }
    if (rank === 2) {
      return WSBD_RANK_TWO;
    }
    if (rank === 3) {
      return WSBD_RANK_THREE;
    }
    return WSBD_RANK_REST;
  }

  private tagColor(tag: string): string {
    if (tag === '新') {
      return WSBD_TAG_NEW;
    }
    return WSBD_TAG_HOT;
  }

  // ------------------------------------------------------------------
  // 搜索框内线框图标
  // ------------------------------------------------------------------

  /** 麦克风：胶囊 + U 形拾音罩 + 支杆 */
  @Builder
  micIcon() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 拾音罩：整圆描边，上半圈用白色遮住，只留 U 形
      Circle()
        .width(11.4)
        .height(11.4)
        .fill(Color.Transparent)
        .stroke(WSBD_ICON_COLOR)
        .strokeWidth(WSBD_ICON_STROKE)
        .offset({ x: 1.2, y: 4.2 })

      Row()
        .width(13.2)
        .height(4.3)
        .backgroundColor(Color.White)
        .offset({ x: 0.3, y: 2.2 })

      // 胶囊：压在白色遮挡之上
      Row()
        .width(5.6)
        .height(8.8)
        .borderRadius(2.8)
        .border({ width: WSBD_ICON_STROKE, color: WSBD_ICON_COLOR })
        .offset({ x: 4.1, y: 0.4 })

      Row()
        .width(WSBD_ICON_STROKE)
        .height(2.4)
        .backgroundColor(WSBD_ICON_COLOR)
        .offset({ x: 6.15, y: 15.1 })
    }
    .width(WSBD_MIC_WIDTH)
    .height(WSBD_MIC_HEIGHT)
  }

  /** 相机：机身圆角方框 + 顶部凸起 + 镜头 */
  @Builder
  cameraIcon() {
    Stack({ alignContent: Alignment.TopStart }) {
      Row()
        .width(7.4)
        .height(3.4)
        .borderRadius(1.2)
        .border({ width: WSBD_ICON_STROKE, color: WSBD_ICON_COLOR })
        .offset({ x: 5.5, y: 1.2 })

      Row()
        .width(18.4)
        .height(13.6)
        .borderRadius(3.4)
        .backgroundColor(Color.White)
        .border({ width: WSBD_ICON_STROKE, color: WSBD_ICON_COLOR })
        .offset({ x: 0, y: 3.9 })

      Circle()
        .width(7.2)
        .height(7.2)
        .fill(Color.Transparent)
        .stroke(WSBD_ICON_COLOR)
        .strokeWidth(WSBD_ICON_STROKE)
        .offset({ x: 5.6, y: 7.1 })
    }
    .width(WSBD_CAMERA_WIDTH)
    .height(WSBD_CAMERA_HEIGHT)
    .margin({ left: WSBD_ICON_GAP })
  }

  /** 右侧筛选漏斗 */
  @Builder
  filterIcon() {
    Path()
      .width(15.6)
      .height(13.8)
      .commands('M0 0 L15.6 0 L9.7 6.6 L9.7 13.8 L5.9 10.6 L5.9 6.6 Z')
      .fill(Color.White)
      .stroke(Color.Transparent)
  }

  // ------------------------------------------------------------------
  // 头部
  // ------------------------------------------------------------------

  @Builder
  searchBar() {
    Row() {
      Image($r('app.media.ws_bd_icon_baidu'))
        .width(WSBD_LOGO_WIDTH)
        .height(WSBD_LOGO_HEIGHT)
        .objectFit(ImageFit.Contain)

      Text('新闻资讯')
        .fontSize(WSBD_SEARCH_FONT)
        .fontColor(WSBD_SEARCH_TEXT)
        .maxLines(1)
        .margin({ left: WSBD_SEARCH_TEXT_GAP })

      Blank()

      this.micIcon()

      this.cameraIcon()
    }
    .width('100%')
    .height(WSBD_SEARCH_HEIGHT)
    .padding({ left: WSBD_SEARCH_PAD_LEFT, right: WSBD_SEARCH_PAD_RIGHT })
    .backgroundColor(Color.White)
    .borderRadius(WSBD_SEARCH_RADIUS)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  tabItem(tab: WSBD_Tab) {
    Column() {
      Text(tab.tabTitle)
        .fontSize(WSBD_TAB_FONT)
        .lineHeight(WSBD_TAB_LINE)
        .fontWeight(tab.tabKey === this.activeTabKey ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(tab.tabKey === this.activeTabKey ? '#FFFFFF' : '#E6FFFFFF')
        .height(WSBD_TAB_LINE)
        .maxLines(1)

      if (tab.tabKey === this.activeTabKey) {
        Row()
          .width(WSBD_TAB_UNDERLINE_WIDTH)
          .height(WSBD_TAB_UNDERLINE_HEIGHT)
          .backgroundColor(Color.White)
          .borderRadius(WSBD_TAB_UNDERLINE_HEIGHT / 2)
          .margin({ top: WSBD_TAB_UNDERLINE_GAP })
      }
    }
    .height('100%')
    .justifyContent(FlexAlign.End)
    .padding({ bottom: WSBD_TAB_UNDERLINE_BOTTOM })
    .onClick(() => {
      this.activeTabKey = tab.tabKey;
    })
  }

  @Builder
  tabRow() {
    Row() {
      Text('Ai+')
        .fontSize(WSBD_TAB_FONT)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .maxLines(1)

      ForEach(WSBD_TABS, (tab: WSBD_Tab) => {
        this.tabItem(tab)
      }, (tab: WSBD_Tab) => tab.tabKey + (tab.tabKey === this.activeTabKey ? '#on' : '#off'))

      this.filterIcon()
    }
    .width('100%')
    .height(WSBD_TAB_ROW_HEIGHT)
    .padding({ left: WSBD_TAB_PAD_LEFT, right: WSBD_TAB_PAD_RIGHT })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  hotWord() {
    Column() {
      Text('百度热搜')
        .fontSize(WSBD_HOT_WORD_FONT)
        .lineHeight(48)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .textShadow({ radius: 26, color: '#59FFF1E4', offsetX: 0, offsetY: 0 })
        .maxLines(1)
    }
    .width('100%')
    .height(WSBD_HOT_WORD_BLOCK)
    .padding({ top: WSBD_HOT_WORD_TOP })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  headerArea() {
    Column() {
      Column() {
        this.searchBar()
      }
      .width('100%')
      .padding({ left: WSBD_SEARCH_SIDE, right: WSBD_SEARCH_SIDE })
      .margin({ top: WSBD_SEARCH_TOP })

      this.tabRow()

      this.hotWord()
    }
    .width('100%')
    .height(WSBD_HEADER_HEIGHT)
    .linearGradient({
      angle: 180,
      colors: [[WSBD_RED_TOP, 0.0], [WSBD_RED_BOTTOM, 1.0]]
    })
    .alignItems(HorizontalAlign.Start)
  }

  // ------------------------------------------------------------------
  // 卡片：5 个入口
  // ------------------------------------------------------------------

  @Builder
  entryCell(entry: WSBD_HotEntry) {
    Column() {
      Image(this.entryIcon(entry.entryKey))
        .width(WSBD_ENTRY_ICON)
        .height(WSBD_ENTRY_ICON)
        .objectFit(ImageFit.Contain)

      Text(entry.entryLabel)
        .fontSize(WSBD_ENTRY_LABEL_FONT)
        .lineHeight(WSBD_ENTRY_LABEL_LINE)
        .fontColor(WSBD_TEXT_DARK)
        .height(WSBD_ENTRY_LABEL_LINE)
        .maxLines(1)
        .margin({ top: WSBD_ENTRY_ICON_GAP })
    }
    .width(this.entryCellWidth())
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  entryRow() {
    Row() {
      ForEach(WSBD_HOT_ENTRIES, (entry: WSBD_HotEntry) => {
        this.entryCell(entry)
      }, (entry: WSBD_HotEntry) => entry.entryKey)
    }
    .width('100%')
    .padding({
      left: WSBD_ENTRY_SIDE,
      right: WSBD_ENTRY_SIDE,
      top: WSBD_ENTRY_TOP,
      bottom: WSBD_ENTRY_BOTTOM
    })
    .alignItems(VerticalAlign.Top)
  }

  // ------------------------------------------------------------------
  // 卡片：热搜榜标题行
  // ------------------------------------------------------------------

  @Builder
  sectionRow() {
    Row() {
      Text('热搜榜')
        .fontSize(WSBD_SECTION_FONT)
        .fontWeight(FontWeight.Bold)
        .fontColor(WSBD_TEXT_DARK)
        .maxLines(1)

      Path()
        .width(WSBD_ARROW_WIDTH)
        .height(WSBD_ARROW_HEIGHT)
        .commands('M1 1 L11.6 7 L1 13')
        .fill(Color.Transparent)
        .stroke(WSBD_TEXT_DARK)
        .strokeWidth(WSBD_ARROW_STROKE)
        .strokeLineCap(LineCapStyle.Round)
        .margin({ left: WSBD_ARROW_GAP })
    }
    .width('100%')
    .height(WSBD_SECTION_HEIGHT)
    .padding({ left: WSBD_SECTION_SIDE, right: WSBD_SECTION_SIDE })
    .margin({ bottom: WSBD_SECTION_BOTTOM })
    .alignItems(VerticalAlign.Center)
  }

  // ------------------------------------------------------------------
  // 卡片：热搜列表
  // ------------------------------------------------------------------

  @Builder
  hotRow(item: WSBD_HotItem) {
    Row() {
      Text(item.itemRank.toString())
        .fontSize(WSBD_RANK_FONT)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.rankColor(item.itemRank))
        .width(WSBD_RANK_WIDTH)
        .textAlign(TextAlign.Start)
        .maxLines(1)

      Text(item.itemTitle)
        .fontSize(WSBD_TITLE_FONT)
        .fontColor(WSBD_TEXT_DARK)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)

      if (item.itemTag.length > 0) {
        Stack() {
          Text(item.itemTag)
            .fontSize(WSBD_BADGE_FONT)
            .fontColor(Color.White)
            .maxLines(1)
        }
        .width(WSBD_BADGE_SIZE)
        .height(WSBD_BADGE_SIZE)
        .backgroundColor(this.tagColor(item.itemTag))
        .borderRadius(WSBD_BADGE_RADIUS)
        .margin({ left: WSBD_BADGE_GAP })
      }
    }
    .width('100%')
    .height(WSBD_ROW_HEIGHT)
    .padding({ left: WSBD_ROW_SIDE, right: WSBD_ROW_SIDE })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  hotList() {
    List() {
      ForEach(WSBD_HOT_ITEMS, (item: WSBD_HotItem) => {
        ListItem() {
          this.hotRow(item)
        }
      }, (item: WSBD_HotItem) => item.itemKey)
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .divider({
      strokeWidth: 1,
      color: WSBD_DIVIDER_COLOR,
      startMargin: WSBD_ROW_SIDE,
      endMargin: WSBD_ROW_SIDE
    })
    .padding({ bottom: WSBD_NAV_HEIGHT })
  }

  @Builder
  cardArea() {
    Column() {
      this.entryRow()

      this.sectionRow()

      this.hotList()
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: WSBD_CARD_RADIUS, topRight: WSBD_CARD_RADIUS })
    .clip(true)
    .alignItems(HorizontalAlign.Start)
  }

  // ------------------------------------------------------------------
  // 底部导航栏
  // ------------------------------------------------------------------

  @Builder
  backIcon() {
    Path()
      .width(10)
      .height(19)
      .commands('M9 1 L1.4 9.5 L9 18')
      .fill(Color.Transparent)
      .stroke(WSBD_NAV_ICON)
      .strokeWidth(2)
      .strokeLineCap(LineCapStyle.Round)
  }

  @Builder
  menuIcon() {
    Column({ space: 4.2 }) {
      Row().width(16.4).height(2.2).backgroundColor(WSBD_NAV_ICON).borderRadius(1.1)
      Row().width(16.4).height(2.2).backgroundColor(WSBD_NAV_ICON).borderRadius(1.1)
      Row().width(16.4).height(2.2).backgroundColor(WSBD_NAV_ICON).borderRadius(1.1)
    }
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  aiButton() {
    Stack({ alignContent: Alignment.Center }) {
      Text('Ai+')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .maxLines(1)
    }
    .width(WSBD_NAV_AI_SIZE)
    .height(WSBD_NAV_AI_SIZE)
    .borderRadius(WSBD_NAV_AI_RADIUS)
    .linearGradient({
      angle: 135,
      colors: [[WSBD_AI_FROM, 0.0], [WSBD_AI_TO, 1.0]]
    })
  }

  @Builder
  boxOneIcon() {
    Stack({ alignContent: Alignment.Center }) {
      Text('1')
        .fontSize(9.5)
        .fontColor(WSBD_NAV_ICON)
        .maxLines(1)
    }
    .width(WSBD_NAV_SMALL)
    .height(WSBD_NAV_SMALL)
    .borderRadius(4)
    .border({ width: 1.6, color: WSBD_NAV_ICON })
  }

  @Builder
  pawIcon() {
    Stack({ alignContent: Alignment.TopStart }) {
      Row().width(4.2).height(4.2).backgroundColor(WSBD_NAV_ICON).borderRadius(2.1).offset({ x: 1.0, y: 4.6 })
      Row().width(4.4).height(4.4).backgroundColor(WSBD_NAV_ICON).borderRadius(2.2).offset({ x: 5.0, y: 1.4 })
      Row().width(4.4).height(4.4).backgroundColor(WSBD_NAV_ICON).borderRadius(2.2).offset({ x: 9.4, y: 1.4 })
      Row().width(4.2).height(4.2).backgroundColor(WSBD_NAV_ICON).borderRadius(2.1).offset({ x: 13.4, y: 4.6 })

      Row()
        .width(11.2)
        .height(7.2)
        .backgroundColor(WSBD_NAV_ICON)
        .borderRadius({ topLeft: 5.6, topRight: 5.6, bottomLeft: 3.6, bottomRight: 3.6 })
        .offset({ x: 3.4, y: 9.2 })
    }
    .width(WSBD_NAV_SMALL)
    .height(WSBD_NAV_SMALL)
  }

  @Builder
  bottomBar() {
    Column() {
      Row() {
        Stack({ alignContent: Alignment.Center }) {
          this.backIcon()
        }
        .layoutWeight(1)
        .height('100%')

        Stack({ alignContent: Alignment.Center }) {
          this.menuIcon()
        }
        .layoutWeight(1)
        .height('100%')

        Stack({ alignContent: Alignment.Center }) {
          this.aiButton()
        }
        .layoutWeight(1)
        .height('100%')

        Stack({ alignContent: Alignment.Center }) {
          this.boxOneIcon()
        }
        .layoutWeight(1)
        .height('100%')

        Stack({ alignContent: Alignment.Center }) {
          this.pawIcon()
        }
        .layoutWeight(1)
        .height('100%')
      }
      .width('100%')
      .height(WSBD_NAV_ICON_ROW)

      Column() {
        Row()
          .width(WSBD_NAV_PILL_WIDTH)
          .height(WSBD_NAV_PILL_HEIGHT)
          .backgroundColor(WSBD_NAV_PILL)
          .borderRadius(WSBD_NAV_PILL_HEIGHT / 2)
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.End)
      .padding({ bottom: WSBD_NAV_PILL_BOTTOM })
    }
    .width('100%')
    .height(WSBD_NAV_HEIGHT)
    .backgroundColor(Color.White)
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column() {
          this.headerArea()

          this.cardArea()
        }
        .width('100%')
        .height('100%')

        this.bottomBar()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.White)
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
