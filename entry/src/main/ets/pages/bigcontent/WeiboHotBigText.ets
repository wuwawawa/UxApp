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
 * 反例：大图大字 / 微博热搜大字排行
 *
 * 复刻微博「热搜榜」页：深色头部（扫一扫 + 搜一搜搜索框 + 消息入口）、
 * 榜单头卡（火焰图标 + 微博热搜榜 / 更新时间 + 换一换）、热搜词条列表
 * （前 3 名彩色序号、置顶行、热 / 爆 / 沸 / 新角标、阅读量）、
 * 底部 TabBar（热搜 / 文娱 / 政务，可切换三张榜单）。
 *
 * 设计基准：单屏态 459.6×672vp（1264×1848px，密度 2.75）。词条字号 16.5vp、
 * 序号宽 30vp、行内边距上下 13vp，一屏约放 9 条词条。
 *
 * 三个屏态：
 *   单屏态        459.6×672vp   —— 词条字号 16.5vp，一屏约 9 条
 *   双屏态竖屏    664.7×939.6vp —— 整体 ×1.45：词条字号 23.9vp、行高 69vp，
 *                                  长词条折成两行，一屏只剩 5 条
 *   双屏态横屏    939.6×664.7vp —— 整体 ×2.04：词条字号 33.7vp（翻倍）、
 *                                  序号 61vp、角标字号 20.4vp，一行只能放下
 *                                  十来个字，长词条折成两行占 120vp，一屏只剩 3 条
 *
 * 问题表现（双屏态竖屏 / 横屏）：榜单头卡、词条、序号、角标与阅读量的字号随
 * 窗口宽度整体等比放大，词条字号翻倍后一行只能放下几个字，行高膨胀、一屏可见
 * 词条从 9 条掉到 3 条，排行榜变成「大字报」；头部搜索框与底部 Tab 却还是
 * 单屏态大小，上下小而中间巨大。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 单屏态窗口宽度（1264px / 密度 2.75）：榜单区所有尺寸的基准宽度 */
const WEIBO_BASE_WIDTH: number = 459.6;
/** 单屏态窗口高度，拿不到窗口高度时兜底 */
const WEIBO_BASE_HEIGHT: number = 672;
/** 状态栏 / 底部手势区兜底高度（vp） */
const WEIBO_STATUS_BAR_FALLBACK: number = 32; const WEIBO_BOTTOM_INSET_FALLBACK: number = 8;
/** 配色：深色模式 */
const WEIBO_PAGE_BG: string = '#0E0E12';
const WEIBO_HEADER_BG: string = '#17171C';
const WEIBO_HAIRLINE: string = '#232329';
const WEIBO_TEXT_MAIN: string = '#F5F5F7';
const WEIBO_TEXT_GRAY: string = '#8A8A93';
const WEIBO_ACCENT: string = '#FF8200';
/** 头部搜索行（固定尺寸，不随榜单区放大） */
const WEIBO_SEARCH_ROW_HEIGHT: number = 46;
const WEIBO_SEARCH_BAR_HEIGHT: number = 32;
const WEIBO_SEARCH_BAR_RADIUS: number = 16;
const WEIBO_SEARCH_FONT: number = 13.5;
const WEIBO_HEADER_PAD: number = 12;
/** 榜单头卡：圆角 12vp、标题 17vp（随窗口放大） */
const WEIBO_BOARD_CARD_RADIUS: number = 12;
const WEIBO_BOARD_CARD_PAD: number = 12;
const WEIBO_BOARD_TITLE_FONT: number = 17;
const WEIBO_BOARD_SUB_FONT: number = 10.5;
const WEIBO_BOARD_REFRESH_FONT: number = 12;
const WEIBO_BOARD_CARD_GAP_ABOVE: number = 10;
const WEIBO_BOARD_CARD_GAP_BELOW: number = 8;
/** 热搜词条行：序号宽 30vp、词条字号 16.5vp、上下内边距 13vp（随窗口放大） */
const WEIBO_RANK_WIDTH: number = 30;
const WEIBO_RANK_FONT: number = 17;
const WEIBO_TOPIC_FONT: number = 16.5;
const WEIBO_TOPIC_LINE_HEIGHT: number = 23;
const WEIBO_ROW_PAD_X: number = 16;
const WEIBO_ROW_PAD_Y: number = 13;
const WEIBO_VIEW_FONT: number = 12;
const WEIBO_VIEW_GAP_RIGHT: number = 12;
/** 热 / 爆 / 沸 / 新角标 */
const WEIBO_BADGE_FONT: number = 10;
const WEIBO_BADGE_RADIUS: number = 4;
/** 底部榜单 TabBar（固定尺寸） */
const WEIBO_FOOTER_HEIGHT: number = 50;
const WEIBO_FOOTER_ICON: number = 20;
const WEIBO_FOOTER_LABEL_FONT: number = 10;
/** 前 3 名序号颜色（1 红 / 2 橙 / 3 黄），其余灰色 */
const WEIBO_RANK_FIRST: string = '#FF4E4E';
const WEIBO_RANK_SECOND: string = '#FF8A3D';
const WEIBO_RANK_THIRD: string = '#FFB300';
const WEIBO_RANK_NORMAL: string = '#6E6E78';

/** 热搜词条行数据 */
interface WeiboHotRow {
  rowKey: string;
  rankLabel: string;
  /** 前 3 名使用彩色序号 */
  rankTop: boolean;
  /** 置顶行用图钉代替序号 */
  rowPinned: boolean;
  topicText: string;
  /** 空字符串表示无角标 */
  badgeLabel: string;
  badgeTint: string;
  viewCount: string;
}

const WEIBO_HOT_ROWS: WeiboHotRow[] = [
  { rowKey: 'pin', rankLabel: '', rankTop: false, rowPinned: true,
    topicText: '微博热搜榜上线社区文明公约', badgeLabel: '', badgeTint: '', viewCount: '置顶' },
  { rowKey: 'h1', rankLabel: '1', rankTop: true, rowPinned: false,
    topicText: '全国多地发布高温橙色预警 局地气温将超40℃', badgeLabel: '爆', badgeTint: '#FF3B30',
    viewCount: '4593843' },
  { rowKey: 'h2', rankLabel: '2', rankTop: true, rowPinned: false,
    topicText: '原来这些水果的热量比米饭还高', badgeLabel: '热', badgeTint: '#FF6A00',
    viewCount: '3287662' },
  { rowKey: 'h3', rankLabel: '3', rankTop: true, rowPinned: false,
    topicText: '高考录取通知书陆续送达', badgeLabel: '沸', badgeTint: '#F5A623', viewCount: '2974518' },
  { rowKey: 'h4', rankLabel: '4', rankTop: false, rowPinned: false,
    topicText: '多所高校官宣校园开放预约参观', badgeLabel: '', badgeTint: '', viewCount: '2453890' },
  { rowKey: 'h5', rankLabel: '5', rankTop: false, rowPinned: false,
    topicText: '这届年轻人开始去菜市场淘花', badgeLabel: '新', badgeTint: '#3B7CFF', viewCount: '2338760' },
  { rowKey: 'h6', rankLabel: '6', rankTop: false, rowPinned: false,
    topicText: '官方通报景区索道故障游客被困', badgeLabel: '', badgeTint: '', viewCount: '2104553' },
  { rowKey: 'h7', rankLabel: '7', rankTop: false, rowPinned: false,
    topicText: '猫咪第一次见到扫地机器人的反应', badgeLabel: '', badgeTint: '', viewCount: '1876420' },
  { rowKey: 'h8', rankLabel: '8', rankTop: false, rowPinned: false,
    topicText: '夜市摆摊月入过万是真的吗', badgeLabel: '新', badgeTint: '#3B7CFF', viewCount: '1698235' },
  { rowKey: 'h9', rankLabel: '9', rankTop: false, rowPinned: false,
    topicText: '男生地铁上用电脑帮陌生女生改论文', badgeLabel: '', badgeTint: '', viewCount: '1420118' },
  { rowKey: 'h10', rankLabel: '10', rankTop: false, rowPinned: false,
    topicText: '建议将假期凑成完整休息日', badgeLabel: '', badgeTint: '', viewCount: '1130667' }
];

const WEIBO_ENT_ROWS: WeiboHotRow[] = [
  { rowKey: 'e1', rankLabel: '1', rankTop: true, rowPinned: false,
    topicText: '这个夏天的演唱会官宣了', badgeLabel: '热', badgeTint: '#FF6A00', viewCount: '1298340' },
  { rowKey: 'e2', rankLabel: '2', rankTop: true, rowPinned: false,
    topicText: '电影票房暑期档破30亿', badgeLabel: '', badgeTint: '', viewCount: '1105623' },
  { rowKey: 'e3', rankLabel: '3', rankTop: true, rowPinned: false,
    topicText: '综艺名场面大盘点', badgeLabel: '新', badgeTint: '#3B7CFF', viewCount: '984210' },
  { rowKey: 'e4', rankLabel: '4', rankTop: false, rowPinned: false,
    topicText: '电视剧大结局太意难平了', badgeLabel: '', badgeTint: '', viewCount: '876540' },
  { rowKey: 'e5', rankLabel: '5', rankTop: false, rowPinned: false,
    topicText: '老牌歌手回归舞台', badgeLabel: '沸', badgeTint: '#F5A623', viewCount: '765432' },
  { rowKey: 'e6', rankLabel: '6', rankTop: false, rowPinned: false,
    topicText: '偶像剧OST回忆杀', badgeLabel: '', badgeTint: '', viewCount: '654321' },
  { rowKey: 'e7', rankLabel: '7', rankTop: false, rowPinned: false,
    topicText: '音乐节抢票攻略来了', badgeLabel: '', badgeTint: '', viewCount: '543210' }
];

const WEIBO_GOV_ROWS: WeiboHotRow[] = [
  { rowKey: 'g1', rankLabel: '1', rankTop: true, rowPinned: false,
    topicText: '这些新规明起正式施行', badgeLabel: '热', badgeTint: '#FF6A00', viewCount: '998877' },
  { rowKey: 'g2', rankLabel: '2', rankTop: true, rowPinned: false,
    topicText: '一图读懂最新政策要点', badgeLabel: '', badgeTint: '', viewCount: '887766' },
  { rowKey: 'g3', rankLabel: '3', rankTop: true, rowPinned: false,
    topicText: '政务服务跨省通办再扩围', badgeLabel: '新', badgeTint: '#3B7CFF', viewCount: '776655' },
  { rowKey: 'g4', rankLabel: '4', rankTop: false, rowPinned: false,
    topicText: '电子社保卡新增功能上线', badgeLabel: '', badgeTint: '', viewCount: '665544' },
  { rowKey: 'g5', rankLabel: '5', rankTop: false, rowPinned: false,
    topicText: '这份反诈指南请收好', badgeLabel: '', badgeTint: '', viewCount: '554433' },
  { rowKey: 'g6', rankLabel: '6', rankTop: false, rowPinned: false,
    topicText: '助企纾困政策问答', badgeLabel: '', badgeTint: '', viewCount: '443322' }
];

/** 底部榜单 Tab 数据 */
interface WeiboBoardTab {
  boardKey: string;
  boardLabel: string;
  boardSymbol: Resource;
}

const WEIBO_BOARD_TABS: WeiboBoardTab[] = [
  { boardKey: 'hot', boardLabel: '热搜', boardSymbol: $r('sys.symbol.flame') },
  { boardKey: 'ent', boardLabel: '文娱', boardSymbol: $r('sys.symbol.music') },
  { boardKey: 'gov', boardLabel: '政务', boardSymbol: $r('sys.symbol.building') }
];

@Component
export struct WeiboHotBigTextPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = WEIBO_BASE_WIDTH;
  @State winHeightVp: number = WEIBO_BASE_HEIGHT;
  /** 沉浸式下的状态栏 / 底部手势区高度（vp） */
  @State statusBarHeightVp: number = WEIBO_STATUS_BAR_FALLBACK;
  @State bottomInsetVp: number = WEIBO_BOTTOM_INSET_FALLBACK;
  /** 当前榜单：hot / ent / gov */
  @State activeBoard: string = 'hot';

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
      // 头部是深色背景，系统栏内容用白色
      this.windowToken = WindowModeController.acquire(win, '#FFFFFF');
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  // ---------- 尺寸与数据：榜单区每一处尺寸由窗口宽度推出 ----------

  /** 场景缩放比：窗口宽度 / 单屏态宽度（459.6vp），展开态约 ×1.45 / ×2.04 */
  private sceneScale(): number {
    if (this.winWidthVp <= 0) {
      return 1;
    }
    return this.winWidthVp / WEIBO_BASE_WIDTH;
  }

  /** 按场景缩放比放大单屏态设计值 */
  private vs(designValue: number): number {
    return designValue * this.sceneScale();
  }

  /** 当前榜单的词条列表 */
  private rowsOfBoard(): WeiboHotRow[] {
    if (this.activeBoard === 'ent') {
      return WEIBO_ENT_ROWS;
    }
    if (this.activeBoard === 'gov') {
      return WEIBO_GOV_ROWS;
    }
    return WEIBO_HOT_ROWS;
  }

  /** 当前榜单标题（头卡使用） */
  private boardTitle(): string {
    if (this.activeBoard === 'ent') {
      return '文娱榜';
    }
    if (this.activeBoard === 'gov') {
      return '政务榜';
    }
    return '微博热搜榜';
  }

  /** 序号颜色：1 红 / 2 橙 / 3 黄，其余灰 */
  private rankColorOf(row: WeiboHotRow): string {
    if (row.rankLabel === '1') {
      return WEIBO_RANK_FIRST;
    }
    if (row.rankLabel === '2') {
      return WEIBO_RANK_SECOND;
    }
    if (row.rankLabel === '3') {
      return WEIBO_RANK_THIRD;
    }
    return WEIBO_RANK_NORMAL;
  }

  // ---------- 头部：扫一扫 + 搜一搜 + 消息（固定尺寸） ----------

  @Builder
  searchHeader() {
    Row() {
      SymbolGlyph($r('sys.symbol.qrcode')).fontSize(21).fontColor([WEIBO_TEXT_MAIN])
        .margin({ right: 10 })
      Row({ space: 6 }) {
        SymbolGlyph($r('sys.symbol.magnifyingglass')).fontSize(14).fontColor([WEIBO_TEXT_GRAY])
        Text('搜一搜').fontSize(WEIBO_SEARCH_FONT).fontColor(WEIBO_TEXT_GRAY)
          .maxLines(1).layoutWeight(1)
        SymbolGlyph($r('sys.symbol.camera')).fontSize(16).fontColor([WEIBO_TEXT_GRAY])
      }
      .height(WEIBO_SEARCH_BAR_HEIGHT)
      .padding({ left: 12, right: 12 })
      .backgroundColor('#232329')
      .borderRadius(WEIBO_SEARCH_BAR_RADIUS)
      .layoutWeight(1)
      .alignItems(VerticalAlign.Center)
      SymbolGlyph($r('sys.symbol.message')).fontSize(21).fontColor([WEIBO_TEXT_MAIN])
        .margin({ left: 10 })
    }
    .width('100%')
    .height(WEIBO_SEARCH_ROW_HEIGHT)
    .padding({ left: WEIBO_HEADER_PAD, right: WEIBO_HEADER_PAD })
    .alignItems(VerticalAlign.Center)
  }

  // ---------- 榜单头卡：标题 / 更新时间 / 换一换（随窗口放大） ----------

  @Builder
  boardHeaderCard() {
    Row({ space: this.vs(8) }) {
      SymbolGlyph($r('sys.symbol.flame_fill'))
        .fontSize(this.vs(WEIBO_BOARD_TITLE_FONT)).fontColor(['#FF4E4E'])
      Column({ space: 2 }) {
        Text(this.boardTitle()).fontSize(this.vs(WEIBO_BOARD_TITLE_FONT))
          .fontWeight(FontWeight.Bold).fontColor(WEIBO_TEXT_MAIN).maxLines(1)
        Text('更新于 今天 09:00').fontSize(this.vs(WEIBO_BOARD_SUB_FONT))
          .fontColor(WEIBO_TEXT_GRAY).maxLines(1)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Row({ space: this.vs(3) }) {
        Text('换一换').fontSize(this.vs(WEIBO_BOARD_REFRESH_FONT)).fontColor(WEIBO_TEXT_GRAY)
        SymbolGlyph($r('sys.symbol.arrow_clockwise'))
          .fontSize(this.vs(WEIBO_BOARD_REFRESH_FONT)).fontColor([WEIBO_TEXT_GRAY])
      }
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(this.vs(WEIBO_BOARD_CARD_PAD))
    .backgroundColor(WEIBO_HEADER_BG)
    .borderRadius(this.vs(WEIBO_BOARD_CARD_RADIUS))
    .margin({ top: this.vs(WEIBO_BOARD_CARD_GAP_ABOVE), bottom: this.vs(WEIBO_BOARD_CARD_GAP_BELOW) })
  }

  // ---------- 热搜词条行：序号 / 词条 / 角标 / 阅读量（随窗口放大） ----------

  @Builder
  hotRow(row: WeiboHotRow) {
    Row() {
      // 序号：置顶行显示图钉，前 3 名彩色加粗
      if (row.rowPinned) {
        SymbolGlyph($r('sys.symbol.pin'))
          .fontSize(this.vs(WEIBO_RANK_FONT) * 0.8).fontColor([WEIBO_TEXT_GRAY])
          .width(this.vs(WEIBO_RANK_WIDTH))
      } else {
        Text(row.rankLabel)
          .fontSize(this.vs(WEIBO_RANK_FONT))
          .fontWeight(row.rankTop ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.rankColorOf(row))
          .maxLines(1)
          .width(this.vs(WEIBO_RANK_WIDTH))
          .textAlign(TextAlign.Center)
      }
      // 词条 + 角标：字号随窗口翻倍，展开态一行只能放下几个字
      Row({ space: this.vs(6) }) {
        Text(row.topicText)
          .fontSize(this.vs(WEIBO_TOPIC_FONT))
          .lineHeight(this.vs(WEIBO_TOPIC_LINE_HEIGHT))
          .fontWeight(FontWeight.Medium)
          .fontColor(WEIBO_TEXT_MAIN)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
        if (row.badgeLabel !== '') {
          Text(row.badgeLabel)
            .fontSize(this.vs(WEIBO_BADGE_FONT))
            .fontColor(Color.White)
            .padding({ left: this.vs(4), right: this.vs(4), top: this.vs(2), bottom: this.vs(2) })
            .backgroundColor(row.badgeTint)
            .borderRadius(this.vs(WEIBO_BADGE_RADIUS))
            .margin({ top: this.vs(2) })
        }
      }
      .layoutWeight(1)
      .alignItems(VerticalAlign.Top)
      // 阅读量
      Row({ space: this.vs(3) }) {
        SymbolGlyph($r('sys.symbol.eye'))
          .fontSize(this.vs(WEIBO_VIEW_FONT)).fontColor([WEIBO_TEXT_GRAY])
        Text(row.viewCount)
          .fontSize(this.vs(WEIBO_VIEW_FONT)).fontColor(WEIBO_TEXT_GRAY).maxLines(1)
      }
      .alignItems(VerticalAlign.Center)
      .margin({ left: this.vs(WEIBO_VIEW_GAP_RIGHT) })
    }
    .width('100%')
    .padding({ left: this.vs(WEIBO_ROW_PAD_X), right: this.vs(WEIBO_ROW_PAD_X),
      top: this.vs(WEIBO_ROW_PAD_Y), bottom: this.vs(WEIBO_ROW_PAD_Y) })
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  hotList() {
    Column() {
      ForEach(this.rowsOfBoard(), (row: WeiboHotRow) => {
        Column() {
          this.hotRow(row)
          Divider().strokeWidth(0.5).color(WEIBO_HAIRLINE)
        }
        .width('100%')
      }, (row: WeiboHotRow) => this.activeBoard + '-' + row.rowKey)
    }
    .width('100%')
    .backgroundColor(WEIBO_HEADER_BG)
    .borderRadius(this.vs(WEIBO_BOARD_CARD_RADIUS))
    .margin({ bottom: this.vs(WEIBO_BOARD_CARD_GAP_BELOW) })
  }

  // ---------- 底部榜单 TabBar（固定尺寸，可切换榜单） ----------

  @Builder
  boardTabBar() {
    Row() {
      ForEach(WEIBO_BOARD_TABS, (boardTab: WeiboBoardTab) => {
        Column({ space: 3 }) {
          SymbolGlyph(boardTab.boardSymbol).fontSize(WEIBO_FOOTER_ICON)
            .fontColor([this.activeBoard === boardTab.boardKey ? WEIBO_ACCENT : WEIBO_TEXT_GRAY])
          Text(boardTab.boardLabel).fontSize(WEIBO_FOOTER_LABEL_FONT)
            .fontWeight(this.activeBoard === boardTab.boardKey ? FontWeight.Medium : FontWeight.Normal)
            .fontColor(this.activeBoard === boardTab.boardKey ? WEIBO_ACCENT : WEIBO_TEXT_GRAY)
            .maxLines(1)
        }
        .layoutWeight(1)
        .height(WEIBO_FOOTER_HEIGHT)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          this.activeBoard = boardTab.boardKey;
        })
      }, (boardTab: WeiboBoardTab) => boardTab.boardKey)
    }
    .width('100%')
    .height(WEIBO_FOOTER_HEIGHT)
    .alignItems(VerticalAlign.Center)
  }

  build() {
    NavDestination() {
      Column() {
        // ① 深色头部：搜一搜（固定尺寸）
        Column() {
          this.searchHeader()
        }
        .width('100%')
        .padding({ top: this.statusBarHeightVp })
        .backgroundColor(WEIBO_HEADER_BG)
        // ② 榜单区：头卡 + 词条列表全部随窗口宽度等比放大
        Scroll() {
          Column() {
            this.boardHeaderCard()
            this.hotList()
          }
          .width('100%')
          .padding({ left: this.vs(WEIBO_HEADER_PAD), right: this.vs(WEIBO_HEADER_PAD) })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .backgroundColor(WEIBO_PAGE_BG)
        // ③ 底部榜单 TabBar + 手势区避让（固定尺寸）
        Column() {
          this.boardTabBar()
        }
        .width('100%')
        .padding({ bottom: this.bottomInsetVp })
        .backgroundColor(WEIBO_HEADER_BG)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(WEIBO_PAGE_BG)
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
