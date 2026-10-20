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
 * 案例页面构建函数与 caseRoute -> 页面 的解析。Navigation 只有首页一处，
 * 因此这里把 caseRoute 压入同一个 NavPathStack 即可，页面由首页的 navDestination 统一构建。
 */

import { PharmacyProductBigImagePage } from './PharmacyProductBigImage';

interface BigContentCaseEntry {
  caseRoute: string;
  caseTitle: string;
  /** 屏态标签（如「双屏态横屏」） */
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

/** 「大图大字」分类下的全部案例，新增案例时在这里追加一条 */
const BIG_CONTENT_CASES: BigContentCaseEntry[] = [
  {
    caseRoute: 'bigcontent/pharmacy-big-image',
    caseTitle: '看病买药商品图',
    caseTag: '大图',
    caseIcon: '图',
    caseSummary: '横屏下一屏只剩一行商品，商品图占满屏幕',
    casePage: wrapBuilder(pharmacyProductBigImageCasePage)
  }
];

export const BIG_CONTENT_CASE_COUNT: number = BIG_CONTENT_CASES.length;

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

          Text(BIG_CONTENT_CASE_COUNT.toString() + ' 个案例')
            .fontSize(11)
            .fontColor('#8A857A')
        }
        .width('100%')
        .height(54)
        .alignItems(VerticalAlign.Center)

        Text('横屏下商品图占满屏幕，一屏只放得下一行商品')
          .fontSize(12)
          .lineHeight(18)
          .fontColor('#7A756B')
          .width('100%')
          .margin({ top: 2 })

        Divider()
          .strokeWidth(1)
          .color('#DAD4C6')
          .margin({ top: 16, bottom: 16 })

        Scroll() {
          Column() {
            ForEach(BIG_CONTENT_CASES, (caseEntry: BigContentCaseEntry) => {
              this.caseCard(caseEntry)
            }, (caseEntry: BigContentCaseEntry) => caseEntry.caseRoute)
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
