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
 * 「截断重叠」分类页。
 *
 * 首页（pages/Index）只负责问题分类，本文件负责截断分类内部的案例列表、
 * 案例页面构建函数与 caseRoute -> 页面 的解析。Navigation 只有首页一处，
 * 因此这里把 caseRoute 压入同一个 NavPathStack 即可，页面由首页的
 * navDestination 统一构建。
 */

import { FilterDialogTruncationPage } from './FilterDialogTruncation';
import { HemaTaskSheetTruncationPage } from './HemaTaskSheetTruncation';
import { HemaMyMenuTruncationPage } from './HemaMyMenuTruncation';
import { VipRenewalSheetTruncationPage } from './VipRenewalSheetTruncation';
import { BikeGiftDialogTruncationPage } from './BikeGiftDialogTruncation';
import { CouponRulesDialogTruncationPage } from './CouponRulesDialogTruncation';

interface TruncationCaseEntry {
  caseRoute: string;
  caseTitle: string;
  /** 案例类型标签（如「弹窗截断」） */
  caseTag: string;
  /** 卡片左侧的单字图标 */
  caseIcon: string;
  /** 该案例的页面构建函数 */
  casePage: WrappedBuilder<[NavPathStack]>;
}

/** 案例页面构建函数：统一只传入导航栈 */
@Builder
function filterDialogCasePage(pageStack: NavPathStack) {
  FilterDialogTruncationPage({ pageStack: pageStack })
}

@Builder
function vipRenewalCasePage(pageStack: NavPathStack) {
  VipRenewalSheetTruncationPage({ pageStack: pageStack })
}

@Builder
function hemaTaskSheetCasePage(pageStack: NavPathStack) {
  HemaTaskSheetTruncationPage({ pageStack: pageStack })
}

@Builder
function hemaMyMenuCasePage(pageStack: NavPathStack) {
  HemaMyMenuTruncationPage({ pageStack: pageStack })
}

@Builder
function bikeGiftCasePage(pageStack: NavPathStack) {
  BikeGiftDialogTruncationPage({ pageStack: pageStack })
}

@Builder
function couponRulesCasePage(pageStack: NavPathStack) {
  CouponRulesDialogTruncationPage({ pageStack: pageStack })
}

/** 截断重叠分类下的全部案例，新增案例时在这里追加一条 */
const TRUNCATION_CASES: TruncationCaseEntry[] = [
  {
    caseRoute: 'truncation/filter-dialog',
    caseTitle: '购票场景文字截断',
    caseTag: '弹窗截断',
    caseIcon: '票',
    casePage: wrapBuilder(filterDialogCasePage)
  },
  {
    caseRoute: 'truncation/vip-renewal-sheet',
    caseTitle: '会员续费弹层截断',
    caseTag: '弹窗截断',
    caseIcon: '会',
    casePage: wrapBuilder(vipRenewalCasePage)
  },
  {
    caseRoute: 'truncation/hema-task-sheet',
    caseTitle: '盒马签到弹层截断',
    caseTag: '弹窗截断',
    caseIcon: '签',
    casePage: wrapBuilder(hemaTaskSheetCasePage)
  },
  {
    caseRoute: 'truncation/hema-my-menu',
    caseTitle: '盒马我的菜单截断',
    caseTag: '弹窗截断',
    caseIcon: '单',
    casePage: wrapBuilder(hemaMyMenuCasePage)
  },
  {
    caseRoute: 'truncation/bike-card-gift',
    caseTitle: '美团骑行卡赠送弹窗截断',
    caseTag: '弹窗截断',
    caseIcon: '骑',
    casePage: wrapBuilder(bikeGiftCasePage)
  },
  {
    caseRoute: 'truncation/coupon-rules-dialog',
    caseTitle: '美团神券规则弹窗截断',
    caseTag: '弹窗截断',
    caseIcon: '券',
    casePage: wrapBuilder(couponRulesCasePage)
  }
];

export const TRUNCATION_CASE_COUNT: number = TRUNCATION_CASES.length;

/** 按 caseRoute 找案例页面，找不到返回 undefined，由首页兜底 */
export function resolveTruncationCasePage(routeName: string): WrappedBuilder<[NavPathStack]> | undefined {
  for (const caseEntry of TRUNCATION_CASES) {
    if (caseEntry.caseRoute === routeName) {
      return caseEntry.casePage;
    }
  }
  return undefined;
}

@Builder
function truncationCaseListPage(pageStack: NavPathStack) {
  TruncationCaseListPage({ pageStack: pageStack })
}

/** 首页「截断重叠」分类卡片的跳转目标 */
export const TRUNCATION_CATEGORY_PAGE: WrappedBuilder<[NavPathStack]> = wrapBuilder(truncationCaseListPage);

@Component
export struct TruncationCaseListPage {
  pageStack: NavPathStack = new NavPathStack();

  @Builder
  caseCard(caseEntry: TruncationCaseEntry) {
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

      Row() {
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
          .margin({ left: 8 })
      }
      .layoutWeight(1)
      .alignItems(VerticalAlign.Center)
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

          Text('截断重叠')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#14161A')
            .margin({ left: 2 })

          Blank()

          Text(TRUNCATION_CASE_COUNT.toString() + ' 个案例')
            .fontSize(11)
            .fontColor('#8A857A')
        }
        .width('100%')
        .height(54)
        .alignItems(VerticalAlign.Center)

        Text('文字 / 内容被父容器裁切、显示不全')
          .fontSize(12)
          .fontColor('#7A756B')
          .width('100%')

        Divider()
          .strokeWidth(1)
          .color('#DAD4C6')
          .margin({ top: 14, bottom: 16 })

        Scroll() {
          Column() {
            ForEach(TRUNCATION_CASES, (caseEntry: TruncationCaseEntry) => {
              this.caseCard(caseEntry)
            }, (caseEntry: TruncationCaseEntry) => caseEntry.caseRoute)
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
