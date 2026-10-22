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
 * 「留白过多」分类页。
 *
 * 结构与另外三个分类一致：首页只管问题分类，本文件管该分类的案例表、搜索框 / 标签筛选、
 * 案例页面构建函数与 caseRoute -> 页面 的解析。Navigation 只有首页一处，这里把 caseRoute
 * 压入同一个 NavPathStack 即可，页面由首页的 navDestination 统一构建。
 *
 * 本分类下 14 个案例：宽窗口下内容挤在一侧、上下之间空出一大块，或者整页缩成中间一列
 * 而两侧露出大片底色；后者单列为「边距」标签，其余仍是「留白」。
 */

import { GameCenterListPage } from './GameCenterList';
import { PodcastCatalogSheetPage } from './PodcastCatalogSheet';
import { JobSearchCardsPage } from './JobSearchCards';
import { BankTransferHomePage } from './BankTransferHome';
import { FandengRankBoardPage } from './FandengRankBoard';
import { FlightStatusDetailPage } from './FlightStatusDetail';
import { CarSpecComparePage } from './CarSpecCompare';
import { BaiduSearchHotPage } from './BaiduSearchHot';
import { LuckinSearchResultPage } from './LuckinSearchResult';
import { QidianBrowseHistoryPage } from './QidianBrowseHistory';
import { QidianMonthRankPage } from './QidianMonthRank';
import { BookshelfHistoryPage } from './BookshelfHistory';
import { GalaxyNewsFavoritePage } from './GalaxyNewsFavorite';
import { WeiboUserCenterMarginsPage } from './WeiboUserCenterMargins';
import { VipShopHomeBlankPage } from './VipShopHomeBlank';
import { SamClubDetailBlankPage } from './SamClubDetailBlank';
import { SuningHomeBlankPage } from './SuningHomeBlank';
import { MafengwoGuideBlankPage } from './MafengwoGuideBlank';
import { QunarHotelListBlankPage } from './QunarHotelListBlank';
import { NetEaseNewsDetailBlankPage } from './NetEaseNewsDetailBlank';

interface WhitespaceCaseEntry {
  caseRoute: string;
  caseTitle: string;
  /** 案例类型标签，本分类统一为「留白」 */
  caseTag: string;
  /** 卡片左侧的单字图标 */
  caseIcon: string;
  /** 卡片右侧的一句话问题描述 */
  caseSummary: string;
  /** 该案例的页面构建函数 */
  casePage: WrappedBuilder<[NavPathStack]>;
}

@Builder
function gameCenterCasePage(pageStack: NavPathStack) {
  GameCenterListPage({ pageStack: pageStack })
}

@Builder
function podcastCatalogCasePage(pageStack: NavPathStack) {
  PodcastCatalogSheetPage({ pageStack: pageStack })
}

@Builder
function jobSearchCasePage(pageStack: NavPathStack) {
  JobSearchCardsPage({ pageStack: pageStack })
}

@Builder
function bankTransferCasePage(pageStack: NavPathStack) {
  BankTransferHomePage({ pageStack: pageStack })
}

@Builder
function fandengRankCasePage(pageStack: NavPathStack) {
  FandengRankBoardPage({ pageStack: pageStack })
}

@Builder
function flightStatusCasePage(pageStack: NavPathStack) {
  FlightStatusDetailPage({ pageStack: pageStack })
}

@Builder
function carSpecCasePage(pageStack: NavPathStack) {
  CarSpecComparePage({ pageStack: pageStack })
}

@Builder
function baiduHotCasePage(pageStack: NavPathStack) {
  BaiduSearchHotPage({ pageStack: pageStack })
}

@Builder
function luckinSearchCasePage(pageStack: NavPathStack) {
  LuckinSearchResultPage({ pageStack: pageStack })
}

@Builder
function qidianHistoryCasePage(pageStack: NavPathStack) {
  QidianBrowseHistoryPage({ pageStack: pageStack })
}

@Builder
function qidianRankCasePage(pageStack: NavPathStack) {
  QidianMonthRankPage({ pageStack: pageStack })
}

@Builder
function bookshelfHistoryCasePage(pageStack: NavPathStack) {
  BookshelfHistoryPage({ pageStack: pageStack })
}

@Builder
function galaxyNewsCasePage(pageStack: NavPathStack) {
  GalaxyNewsFavoritePage({ pageStack: pageStack })
}

@Builder
function weiboStageCasePage(pageStack: NavPathStack) {
  WeiboUserCenterMarginsPage({ pageStack: pageStack })
}

@Builder
function vipShopHomeCasePage(pageStack: NavPathStack) {
  VipShopHomeBlankPage({ pageStack: pageStack })
}

@Builder
function samClubDetailCasePage(pageStack: NavPathStack) {
  SamClubDetailBlankPage({ pageStack: pageStack })
}

@Builder
function suningHomeCasePage(pageStack: NavPathStack) {
  SuningHomeBlankPage({ pageStack: pageStack })
}

@Builder
function mafengwoGuideCasePage(pageStack: NavPathStack) {
  MafengwoGuideBlankPage({ pageStack: pageStack })
}

@Builder
function qunarHotelCasePage(pageStack: NavPathStack) {
  QunarHotelListBlankPage({ pageStack: pageStack })
}

@Builder
function neteaseNewsCasePage(pageStack: NavPathStack) {
  NetEaseNewsDetailBlankPage({ pageStack: pageStack })
}

/** 「留白过多」分类下的全部案例，新增案例时在这里追加一条 */
const WHITESPACE_CASES: WhitespaceCaseEntry[] = [
  {
    caseRoute: 'whitespace/game-center-list',
    caseTitle: '游戏中心列表右侧空白',
    caseTag: '留白',
    caseIcon: '游',
    caseSummary: '图标与文案挤在最左，「进入」钉在右边缘，中间空出大半屏',
    casePage: wrapBuilder(gameCenterCasePage)
  },
  {
    caseRoute: 'whitespace/podcast-catalog',
    caseTitle: '播客目录弹层首集前空白',
    caseTag: '留白',
    caseIcon: '目',
    caseSummary: '「播放」按钮到第 1 集之间空出面板一半高度',
    casePage: wrapBuilder(podcastCatalogCasePage)
  },
  {
    caseRoute: 'whitespace/job-cards',
    caseTitle: '招聘结果卡片右侧空白',
    caseTag: '留白',
    caseIcon: '聘',
    caseSummary: '岗位内容全挤在左侧四成，右侧整片空着',
    casePage: wrapBuilder(jobSearchCasePage)
  },
  {
    caseRoute: 'whitespace/bank-transfer',
    caseTitle: '转账首页常用转账下方空白',
    caseTag: '留白',
    caseIcon: '汇',
    caseSummary: '「常用转账」标题之后直到屏底空无一人',
    casePage: wrapBuilder(bankTransferCasePage)
  },
  {
    caseRoute: 'whitespace/fandeng-rank',
    caseTitle: '榜单页右侧整列空白',
    caseTag: '留白',
    caseIcon: '榜',
    caseSummary: '书单只铺到左半屏，右侧整列空着',
    casePage: wrapBuilder(fandengRankCasePage)
  },
  {
    caseRoute: 'whitespace/flight-status',
    caseTitle: '航班动态页整屏空白',
    caseTag: '留白',
    caseIcon: '航',
    caseSummary: '一张航班卡之后，下面整屏没有任何内容',
    casePage: wrapBuilder(flightStatusCasePage)
  },
  {
    caseRoute: 'whitespace/car-spec-compare',
    caseTitle: '配置对比表右侧空白',
    caseTag: '留白',
    caseIcon: '车',
    caseSummary: '对比表只占左侧六成，右侧整块留白',
    casePage: wrapBuilder(carSpecCasePage)
  },
  {
    caseRoute: 'whitespace/baidu-hot',
    caseTitle: '百度热搜榜大面积留白',
    caseTag: '留白',
    caseIcon: '热',
    caseSummary: '红色头部与热搜单列都空出大片白',
    casePage: wrapBuilder(baiduHotCasePage)
  },
  {
    caseRoute: 'whitespace/luckin-search',
    caseTitle: '咖啡搜索结果右侧空白',
    caseTag: '留白',
    caseIcon: '杯',
    caseSummary: '结果单列靠左，「＋」钉最右，中间整片空',
    casePage: wrapBuilder(luckinSearchCasePage)
  },
  {
    caseRoute: 'whitespace/qidian-history',
    caseTitle: '浏览历史右侧空白',
    caseTag: '留白',
    caseIcon: '史',
    caseSummary: '书目单列靠左，「书架」钉最右，中间整列空',
    casePage: wrapBuilder(qidianHistoryCasePage)
  },
  {
    caseRoute: 'whitespace/qidian-rank',
    caseTitle: '月票榜右侧空白',
    caseTag: '留白',
    caseIcon: '票',
    caseSummary: '榜单只占左半屏，右侧整列空着',
    casePage: wrapBuilder(qidianRankCasePage)
  },
  {
    caseRoute: 'whitespace/bookshelf-history',
    caseTitle: '书架历史右侧空白',
    caseTag: '留白',
    caseIcon: '架',
    caseSummary: '书名与「已在书架」之间整片空白',
    casePage: wrapBuilder(bookshelfHistoryCasePage)
  },
  {
    caseRoute: 'whitespace/galaxy-news',
    caseTitle: '资讯收藏页整屏空白',
    caseTag: '留白',
    caseIcon: '讯',
    caseSummary: '只剩「没有更多了」与免责声明，下面整屏空',
    casePage: wrapBuilder(galaxyNewsCasePage)
  },
  {
    caseRoute: 'whitespace/weibo-stage-margin',
    caseTitle: '用户中心展开态两侧边距',
    caseTag: '边距',
    caseIcon: '边',
    caseSummary: '整页缩在正中一条手机宽度里，左右各空出一大片底灰',
    casePage: wrapBuilder(weiboStageCasePage)
  },
  {
    caseRoute: 'whitespace/vipshop-home',
    caseTitle: '唯品会首页内容挤左侧',
    caseTag: '留白',
    caseIcon: '唯',
    caseSummary: '横屏时瀑布流只占左半屏，右侧一整块空着',
    casePage: wrapBuilder(vipShopHomeCasePage)
  },
  {
    caseRoute: 'whitespace/samclub-detail',
    caseTitle: '山姆商品详情大片留白',
    caseTag: '留白',
    caseIcon: '山',
    caseSummary: '双屏态商品图与信息挤在左侧，右侧到屏幕边缘全空',
    casePage: wrapBuilder(samClubDetailCasePage)
  },
  {
    caseRoute: 'whitespace/suning-home',
    caseTitle: '苏宁首页右侧留白',
    caseTag: '留白',
    caseIcon: '苏',
    caseSummary: '首页楼层卡片固定窄宽，横屏右半屏空无一物',
    casePage: wrapBuilder(suningHomeCasePage)
  },
  {
    caseRoute: 'whitespace/maofengwo-guide',
    caseTitle: '马蜂窝攻略上下空档',
    caseTag: '留白',
    caseIcon: '蜂',
    caseSummary: '展开态攻略正文与评论区之间空出一大段，版面稀稀拉拉',
    casePage: wrapBuilder(mafengwoGuideCasePage)
  },
  {
    caseRoute: 'whitespace/qunar-hotel-list',
    caseTitle: '去哪儿酒店列表挤一侧',
    caseTag: '留白',
    caseIcon: '店',
    caseSummary: '横屏时酒店卡片只占左侧一列，右半屏全是空白',
    casePage: wrapBuilder(qunarHotelCasePage)
  },
  {
    caseRoute: 'whitespace/netease-news-detail',
    caseTitle: '网易新闻正文两侧空档',
    caseTag: '留白',
    caseIcon: '闻',
    caseSummary: '双屏态正文窄窄一条贴左边，右边大片空白像没加载完',
    casePage: wrapBuilder(neteaseNewsCasePage)
  }
];

export const WHITESPACE_CASE_COUNT: number = WHITESPACE_CASES.length;

/** 「不限标签」的筛选值 */
const WHITESPACE_ALL_TAG: string = '全部';

interface WhitespaceTagChip {
  tagLabel: string;
  /** 该标签下的案例数，直接显示在筛选项上 */
  tagCount: number;
}

/** 从案例表里收集出现过的标签（去重、保持首次出现顺序） */
function collectWhitespaceTags(): string[] {
  const tagLabels: string[] = [];
  for (const caseEntry of WHITESPACE_CASES) {
    if (tagLabels.indexOf(caseEntry.caseTag) < 0) {
      tagLabels.push(caseEntry.caseTag);
    }
  }
  return tagLabels;
}

function countWhitespaceCases(tagLabel: string): number {
  let caseCount: number = 0;
  for (const caseEntry of WHITESPACE_CASES) {
    if (tagLabel === WHITESPACE_ALL_TAG || caseEntry.caseTag === tagLabel) {
      caseCount += 1;
    }
  }
  return caseCount;
}

/** 筛选栏数据：第一项「全部」，其余按案例表里出现的标签生成 */
function buildWhitespaceTagChips(): WhitespaceTagChip[] {
  const chips: WhitespaceTagChip[] = [
    { tagLabel: WHITESPACE_ALL_TAG, tagCount: WHITESPACE_CASES.length }
  ];
  const tagLabels: string[] = collectWhitespaceTags();
  for (const tagLabel of tagLabels) {
    chips.push({ tagLabel: tagLabel, tagCount: countWhitespaceCases(tagLabel) });
  }
  return chips;
}

const WHITESPACE_TAG_CHIPS: WhitespaceTagChip[] = buildWhitespaceTagChips();

/** 按 caseRoute 找案例页面，找不到返回 undefined，由首页兜底 */
export function resolveWhitespaceCasePage(routeName: string): WrappedBuilder<[NavPathStack]> | undefined {
  for (const caseEntry of WHITESPACE_CASES) {
    if (caseEntry.caseRoute === routeName) {
      return caseEntry.casePage;
    }
  }
  return undefined;
}

@Builder
function whitespaceCaseListPage(pageStack: NavPathStack) {
  WhitespaceCaseListPage({ pageStack: pageStack })
}

/** 首页「留白过多」分类卡片的跳转目标 */
export const WHITESPACE_CATEGORY_PAGE: WrappedBuilder<[NavPathStack]> = wrapBuilder(whitespaceCaseListPage);

@Component
export struct WhitespaceCaseListPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 当前选中的标签，默认「全部」 */
  @State activeTag: string = WHITESPACE_ALL_TAG;

  /** 搜索关键词：匹配案例标题、标签与问题描述 */
  @State searchKeyword: string = '';

  private listScroller: Scroller = new Scroller();

  /** 标签 + 关键词双重过滤后的案例 */
  private visibleCases(): WhitespaceCaseEntry[] {
    const keyword: string = this.searchKeyword.trim();
    return WHITESPACE_CASES.filter((caseEntry: WhitespaceCaseEntry) => {
      if (this.activeTag !== WHITESPACE_ALL_TAG && caseEntry.caseTag !== this.activeTag) {
        return false;
      }
      if (keyword.length === 0) {
        return true;
      }
      return caseEntry.caseTitle.indexOf(keyword) >= 0 ||
        caseEntry.caseTag.indexOf(keyword) >= 0 ||
        caseEntry.caseSummary.indexOf(keyword) >= 0;
    });
  }

  /** 有任一筛选条件生效 */
  private isFiltering(): boolean {
    return this.activeTag !== WHITESPACE_ALL_TAG || this.searchKeyword.trim().length > 0;
  }

  /** 右上角的计数：有筛选时显示「命中 / 总数」 */
  private caseCountLabel(): string {
    if (!this.isFiltering()) {
      return WHITESPACE_CASE_COUNT.toString() + ' 个案例';
    }
    return this.visibleCases().length.toString() + ' / ' + WHITESPACE_CASE_COUNT.toString() + ' 个案例';
  }

  /** 列表为空时的提示文案 */
  private emptyHintLabel(): string {
    if (this.searchKeyword.trim().length > 0) {
      return '没有匹配「' + this.searchKeyword.trim() + '」的案例';
    }
    return '该标签下暂无案例';
  }

  private resetListScroll(): void {
    this.listScroller.scrollTo({ xOffset: 0, yOffset: 0 });
  }

  /**
   * 筛选项的 key 带上选中态：
   * ForEach 在 key 不变时会复用旧节点，把选中态编进 key 才能保证切换时重绘。
   */
  private tagChipKey(chip: WhitespaceTagChip): string {
    return chip.tagLabel + (this.activeTag === chip.tagLabel ? '#on' : '#off');
  }

  @Builder
  tagChip(chip: WhitespaceTagChip) {
    Row({ space: 5 }) {
      Text(chip.tagLabel)
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.activeTag === chip.tagLabel ? '#FBF9F4' : '#14161A')

      Text(chip.tagCount.toString())
        .fontSize(10)
        .fontColor(this.activeTag === chip.tagLabel ? '#D8D2C4' : '#8A857A')
    }
    .height(30)
    .padding({ left: 12, right: 12 })
    .backgroundColor(this.activeTag === chip.tagLabel ? '#14161A' : '#FFFFFF')
    .border({
      width: 1,
      color: this.activeTag === chip.tagLabel ? '#14161A' : '#E6E0D4'
    })
    .borderRadius(15)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      if (this.activeTag === chip.tagLabel) {
        return;
      }
      this.activeTag = chip.tagLabel;
      this.resetListScroll();
    })
  }

  /** 搜索框：按标题、标签或问题描述搜索 */
  @Builder
  searchField() {
    Row() {
      SymbolGlyph($r('sys.symbol.magnifyingglass'))
        .fontSize(15)
        .fontColor(['#8A857A'])

      TextInput({ text: this.searchKeyword, placeholder: '搜索案例标题、标签或描述' })
        .placeholderFont({ size: 13 })
        .placeholderColor('#A39D90')
        .fontSize(13)
        .fontColor('#14161A')
        .backgroundColor(Color.Transparent)
        .padding({ left: 6, right: 6 })
        .height(36)
        .layoutWeight(1)
        .enterKeyType(EnterKeyType.Search)
        .onChange((value: string) => {
          this.searchKeyword = value;
          this.resetListScroll();
        })

      if (this.searchKeyword.length > 0) {
        Text('✕')
          .fontSize(12)
          .fontColor('#8A857A')
          .width(24)
          .height(24)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.searchKeyword = '';
            this.resetListScroll();
          })
      }
    }
    .width('100%')
    .height(38)
    .padding({ left: 12, right: 8 })
    .backgroundColor('#FFFFFF')
    .border({ width: 1, color: '#E6E0D4' })
    .borderRadius(10)
    .alignItems(VerticalAlign.Center)
    .margin({ top: 12 })
  }

  /** 标签筛选栏 */
  @Builder
  tagFilterBar() {
    Scroll() {
      Row({ space: 8 }) {
        ForEach(WHITESPACE_TAG_CHIPS, (chip: WhitespaceTagChip) => {
          this.tagChip(chip)
        }, (chip: WhitespaceTagChip) => this.tagChipKey(chip))
      }
      .height(34)
    }
    .width('100%')
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .align(Alignment.Start)
    .margin({ top: 10 })
  }

  @Builder
  caseCard(caseEntry: WhitespaceCaseEntry) {
    Row() {
      Text(caseEntry.caseIcon)
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor('#E2452B')
        .width(42)
        .height(42)
        .textAlign(TextAlign.Center)
        .backgroundColor('#F8E8E2')
        .borderRadius(10)

      Column({ space: 6 }) {
        Row({ space: 8 }) {
          Text(caseEntry.caseTitle)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#14161A')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(caseEntry.caseTag)
            .fontSize(10)
            .fontColor('#E2452B')
            .backgroundColor('#FBE7E0')
            .borderRadius(3)
            .padding({ left: 5, right: 5, top: 2, bottom: 2 })
        }
        .alignItems(VerticalAlign.Center)

        Text(caseEntry.caseSummary)
          .fontSize(11.5)
          .lineHeight(17)
          .fontColor('#7A756B')
          .maxLines(2)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })

      Text('›')
        .fontSize(24)
        .fontColor('#B9B3A6')
        .margin({ left: 8 })
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#FFFFFF')
    .border({ width: 1, color: '#E6E0D4' })
    .borderRadius(12)
    .margin({ bottom: 10 })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.pageStack.pushPathByName(caseEntry.caseRoute, '');
    })
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Text('‹')
            .fontSize(28)
            .fontColor('#14161A')
            .width(36)
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.pageStack.pop();
            })

          Text('留白过多')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#14161A')
            .margin({ left: 2 })

          Blank()

          Text(this.caseCountLabel())
            .fontSize(11)
            .fontColor('#8A857A')
        }
        .width('100%')
        .height(54)
        .alignItems(VerticalAlign.Center)

        this.searchField()

        this.tagFilterBar()

        Divider()
          .strokeWidth(1)
          .color('#DAD4C6')
          .margin({ top: 14, bottom: 16 })

        Scroll(this.listScroller) {
          Column() {
            ForEach(this.visibleCases(), (caseEntry: WhitespaceCaseEntry) => {
              this.caseCard(caseEntry)
            }, (caseEntry: WhitespaceCaseEntry) => caseEntry.caseRoute)

            if (this.visibleCases().length === 0) {
              Text(this.emptyHintLabel())
                .fontSize(12)
                .fontColor('#8A857A')
                .width('100%')
                .textAlign(TextAlign.Center)
                .margin({ top: 24 })
            }
          }
          .width('100%')
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
      }
      .width('100%')
      .height('100%')
      .padding({ left: 20, right: 20, top: 6 })
      .backgroundColor('#F4F2EC')
      .alignItems(HorizontalAlign.Start)
    }
    .hideTitleBar(true)
  }
}
