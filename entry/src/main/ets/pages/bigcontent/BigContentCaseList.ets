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
 * 「大图大字」分类页。
 *
 * 与「截断重叠」分类一样的结构：首页只负责问题分类，本文件负责该分类内部的案例列表、
 * 搜索框 / 标签筛选、案例页面构建函数与 caseRoute -> 页面 的解析。Navigation 只有首页一处，
 * 因此这里把 caseRoute 压入同一个 NavPathStack 即可，页面由首页的 navDestination 统一构建。
 */

import { PharmacyProductBigImagePage } from './PharmacyProductBigImage';
import { HemaMatchGridBigContentPage } from './HemaMatchGridBigContent';

interface BigContentCaseEntry {
  caseRoute: string;
  caseTitle: string;
  /** 案例类型标签（如「大图」） */
  caseTag: string;
  /** 卡片左侧的单字图标 */
  caseIcon: string;
  /** 卡片右侧的一句话问题描述 */
  caseSummary: string;
  /** 该案例的页面构建函数 */
  casePage: WrappedBuilder<[NavPathStack]>;
}

/** 案例页面构建函数：统一只传入导航栈 */
@Builder
function pharmacyProductBigImageCasePage(pageStack: NavPathStack) {
  PharmacyProductBigImagePage({ pageStack: pageStack })
}

@Builder
function hemaMatchGridCasePage(pageStack: NavPathStack) {
  HemaMatchGridBigContentPage({ pageStack: pageStack })
}

/** 「大图大字」分类下的全部案例，新增案例时在这里追加一条 */
const BIG_CONTENT_CASES: BigContentCaseEntry[] = [
  {
    caseRoute: 'bigcontent/pharmacy-big-image',
    caseTitle: '看病买药商品图',
    caseTag: '大图',
    caseIcon: '图',
    caseSummary: '横屏下一屏只剩一行商品，商品图占满屏幕',
    casePage: wrapBuilder(pharmacyProductBigImageCasePage)
  },
  {
    caseRoute: 'bigcontent/hema-match-grid',
    caseTitle: '盒马搭配商品网格',
    caseTag: '大字',
    caseIcon: '字',
    caseSummary: '双屏态下商品图与字号一起放大 1.45～2 倍',
    casePage: wrapBuilder(hemaMatchGridCasePage)
  }
];

export const BIG_CONTENT_CASE_COUNT: number = BIG_CONTENT_CASES.length;

/** 「不限标签」的筛选值 */
const BIG_CONTENT_ALL_TAG: string = '全部';

interface BigContentTagChip {
  tagLabel: string;
  /** 该标签下的案例数，直接显示在筛选项上 */
  tagCount: number;
}

/** 从案例表里收集出现过的标签（去重、保持首次出现顺序） */
function collectBigContentTags(): string[] {
  const tagLabels: string[] = [];
  for (const caseEntry of BIG_CONTENT_CASES) {
    if (tagLabels.indexOf(caseEntry.caseTag) < 0) {
      tagLabels.push(caseEntry.caseTag);
    }
  }
  return tagLabels;
}

function countBigContentCases(tagLabel: string): number {
  let caseCount: number = 0;
  for (const caseEntry of BIG_CONTENT_CASES) {
    if (tagLabel === BIG_CONTENT_ALL_TAG || caseEntry.caseTag === tagLabel) {
      caseCount += 1;
    }
  }
  return caseCount;
}

/** 筛选栏数据：第一项「全部」，其余按案例表里出现的标签生成 */
function buildBigContentTagChips(): BigContentTagChip[] {
  const chips: BigContentTagChip[] = [
    { tagLabel: BIG_CONTENT_ALL_TAG, tagCount: BIG_CONTENT_CASES.length }
  ];
  const tagLabels: string[] = collectBigContentTags();
  for (const tagLabel of tagLabels) {
    chips.push({ tagLabel: tagLabel, tagCount: countBigContentCases(tagLabel) });
  }
  return chips;
}

const BIG_CONTENT_TAG_CHIPS: BigContentTagChip[] = buildBigContentTagChips();

/** 按 caseRoute 找案例页面，找不到返回 undefined，由首页兜底 */
export function resolveBigContentCasePage(routeName: string): WrappedBuilder<[NavPathStack]> | undefined {
  for (const caseEntry of BIG_CONTENT_CASES) {
    if (caseEntry.caseRoute === routeName) {
      return caseEntry.casePage;
    }
  }
  return undefined;
}

@Builder
function bigContentCaseListPage(pageStack: NavPathStack) {
  BigContentCaseListPage({ pageStack: pageStack })
}

/** 首页「大图大字」分类卡片的跳转目标 */
export const BIG_CONTENT_CATEGORY_PAGE: WrappedBuilder<[NavPathStack]> = wrapBuilder(bigContentCaseListPage);

@Component
export struct BigContentCaseListPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 当前选中的标签，默认「全部」 */
  @State activeTag: string = BIG_CONTENT_ALL_TAG;

  /** 搜索关键词：匹配案例标题、标签与问题描述 */
  @State searchKeyword: string = '';

  private listScroller: Scroller = new Scroller();

  /** 标签 + 关键词双重过滤后的案例 */
  private visibleCases(): BigContentCaseEntry[] {
    const keyword: string = this.searchKeyword.trim();
    return BIG_CONTENT_CASES.filter((caseEntry: BigContentCaseEntry) => {
      if (this.activeTag !== BIG_CONTENT_ALL_TAG && caseEntry.caseTag !== this.activeTag) {
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
    return this.activeTag !== BIG_CONTENT_ALL_TAG || this.searchKeyword.trim().length > 0;
  }

  /** 右上角的计数：有筛选时显示「命中 / 总数」 */
  private caseCountLabel(): string {
    if (!this.isFiltering()) {
      return BIG_CONTENT_CASE_COUNT.toString() + ' 个案例';
    }
    return this.visibleCases().length.toString() + ' / ' + BIG_CONTENT_CASE_COUNT.toString() + ' 个案例';
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
  private tagChipKey(chip: BigContentTagChip): string {
    return chip.tagLabel + (this.activeTag === chip.tagLabel ? '#on' : '#off');
  }

  @Builder
  tagChip(chip: BigContentTagChip) {
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

  /** 标签筛选栏，标签多时可横向滑动 */
  @Builder
  tagFilterBar() {
    Scroll() {
      Row({ space: 8 }) {
        ForEach(BIG_CONTENT_TAG_CHIPS, (chip: BigContentTagChip) => {
          this.tagChip(chip)
        }, (chip: BigContentTagChip) => this.tagChipKey(chip))
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
  caseCard(caseEntry: BigContentCaseEntry) {
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

          Text('大图大字')
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
            ForEach(this.visibleCases(), (caseEntry: BigContentCaseEntry) => {
              this.caseCard(caseEntry)
            }, (caseEntry: BigContentCaseEntry) => caseEntry.caseRoute)

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
