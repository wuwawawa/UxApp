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

import { FilterDialogTruncationPage } from './truncation/FilterDialogTruncation';
import { HemaTaskSheetTruncationPage } from './truncation/HemaTaskSheetTruncation';
import { HemaMyMenuTruncationPage } from './truncation/HemaMyMenuTruncation';
import { VipRenewalSheetTruncationPage } from './truncation/VipRenewalSheetTruncation';
import { BikeGiftDialogTruncationPage } from './truncation/BikeGiftDialogTruncation';
import { CouponRulesDialogTruncationPage } from './truncation/CouponRulesDialogTruncation';

/**
 * 反例目录首页。
 * 新增反例页面时：
 *   1. 在 pages/ 下新建页面组件（建议 NavDestination 作为根节点）；
 *   2. 在 CASE_CATALOG 里给对应分类追加一条 CaseEntry；
 *   3. 在 caseDestination 里补一个 routeName 分支。
 */

interface CaseEntry {
  caseRoute: string;
  caseTitle: string;
  /** 复现该问题的具体机型 */
  caseTag: string;
}

interface CaseCategory {
  categoryTitle: string;
  categoryHint: string;
  categoryCases: CaseEntry[];
}

const CASE_CATALOG: CaseCategory[] = [
  {
    categoryTitle: '截断',
    categoryHint: '文字 / 内容被父容器裁切、显示不全',
    categoryCases: [
      {
        caseRoute: 'truncation/filter-dialog',
        caseTitle: '购票场景文字截断',
        caseTag: 'Pura X Max'
      },
      {
        caseRoute: 'truncation/vip-renewal-sheet',
        caseTitle: '会员续费弹层截断',
        caseTag: 'Pura X Max'
      },
      {
        caseRoute: 'truncation/hema-task-sheet',
        caseTitle: '盒马签到弹层截断',
        caseTag: 'Pura X Max'
      },
      {
        caseRoute: 'truncation/hema-my-menu',
        caseTitle: '盒马我的菜单截断',
        caseTag: 'Pura X Max'
      },
      {
        caseRoute: 'truncation/bike-card-gift',
        caseTitle: '美团骑行卡赠送弹窗截断',
        caseTag: 'Pura X Max'
      },
      {
        caseRoute: 'truncation/coupon-rules-dialog',
        caseTitle: '美团神券规则弹窗截断',
        caseTag: 'Pura X Max'
      }
    ]
  }
];

@Entry
@Component
struct Index {
  private navStack: NavPathStack = new NavPathStack();

  @Builder
  caseDestination(routeName: string) {
    if (routeName === 'truncation/filter-dialog') {
      FilterDialogTruncationPage({ pageStack: this.navStack })
    } else if (routeName === 'truncation/vip-renewal-sheet') {
      VipRenewalSheetTruncationPage({ pageStack: this.navStack })
    } else if (routeName === 'truncation/hema-task-sheet') {
      HemaTaskSheetTruncationPage({ pageStack: this.navStack })
    } else if (routeName === 'truncation/hema-my-menu') {
      HemaMyMenuTruncationPage({ pageStack: this.navStack })
    } else if (routeName === 'truncation/bike-card-gift') {
      BikeGiftDialogTruncationPage({ pageStack: this.navStack })
    } else if (routeName === 'truncation/coupon-rules-dialog') {
      CouponRulesDialogTruncationPage({ pageStack: this.navStack })
    }
  }

  @Builder
  caseCard(caseEntry: CaseEntry) {
    Row() {
      Text('✂')
        .fontSize(18)
        .width(44)
        .height(44)
        .textAlign(TextAlign.Center)
        .backgroundColor('#EAF1FF')
        .borderRadius(12)

      Row() {
        Text(caseEntry.caseTitle)
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1D21')

        Text(caseEntry.caseTag)
          .fontSize(11)
          .fontColor('#1B6FE3')
          .backgroundColor('#EAF1FF')
          .borderRadius(4)
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .margin({ left: 8 })
      }
      .layoutWeight(1)
      .alignItems(VerticalAlign.Center)
      .margin({ left: 14 })

      Text('›')
        .fontSize(26)
        .fontColor('#C4C8D0')
        .margin({ left: 8 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .margin({ bottom: 12 })
    .onClick(() => {
      this.navStack.pushPathByName(caseEntry.caseRoute, '');
    })
  }

  @Builder
  categorySection(category: CaseCategory) {
    Column() {
      Row() {
        Row()
          .width(3)
          .height(15)
          .backgroundColor('#1B6FE3')
          .borderRadius(2)

        Text(category.categoryTitle)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1D21')
          .margin({ left: 8 })

        Blank()

        Text(category.categoryCases.length.toString() + ' 个案例')
          .fontSize(11)
          .fontColor('#9AA0A6')
      }
      .width('100%')

      Text(category.categoryHint)
        .fontSize(12)
        .fontColor('#9AA0A6')
        .width('100%')
        .margin({ top: 6, bottom: 12 })

      ForEach(category.categoryCases, (caseEntry: CaseEntry) => {
        this.caseCard(caseEntry)
      }, (caseEntry: CaseEntry) => caseEntry.caseRoute)
    }
    .width('100%')
    .margin({ bottom: 12 })
  }

  build() {
    Navigation(this.navStack) {
      Scroll() {
        Column() {
          Column() {
            Column() {
              Text('UX 反例集')
                .fontSize(26)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)

              Text('折叠屏 / 大屏适配问题复现与验证')
                .fontSize(12)
                .fontColor('#D6E4FF')
                .margin({ top: 8 })
            }
            .width('100%')
            .constraintSize({ maxWidth: 760 })
            .alignItems(HorizontalAlign.Start)
            .padding({ left: 16, right: 16 })
          }
          .width('100%')
          .padding({ top: 24, bottom: 26 })
          .backgroundColor('#1B6FE3')

          Column() {
            ForEach(CASE_CATALOG, (category: CaseCategory) => {
              this.categorySection(category)
            }, (category: CaseCategory) => category.categoryTitle)

            Text('更多分类持续补充中…')
              .fontSize(11)
              .fontColor('#B0B5BD')
              .width('100%')
              .textAlign(TextAlign.Center)
              .margin({ top: 8, bottom: 16 })
          }
          .width('100%')
          .constraintSize({ maxWidth: 760 })
          .padding({ left: 16, right: 16, top: 20, bottom: 12 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .backgroundColor('#F4F5F7')
      .align(Alignment.Top)
    }
    .navDestination(this.caseDestination)
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .backgroundColor('#F4F5F7')
  }
}
