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

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { CategoryPlaceholderPage } from './CategoryPlaceholder';
import {
  TRUNCATION_CASE_COUNT,
  TRUNCATION_CATEGORY_PAGE,
  resolveTruncationCasePage
} from './truncation/TruncationCaseList';
import {
  BIG_CONTENT_CASE_COUNT,
  BIG_CONTENT_CATEGORY_PAGE,
  resolveBigContentCasePage
} from './bigcontent/BigContentCaseList';

/**
 * 反例目录首页：按问题类型分类。
 *
 * 路由分两层：
 *   1. 首页只负责「问题分类」，每个分类对应一个分类页；
 *   2. 分类页内部再列出具体案例（如 pages/truncation/TruncationCaseList）。
 * 两层都往同一个 NavPathStack 压栈，案例页面统一由首页的 navDestination 构建：
 * resolvePage 先查分类表，再交给各分类的案例解析函数。
 *
 * 新增分类：在 HOME_CATEGORIES 追加一项，并补一个分类页 @Builder。
 * 新增案例：在对应分类文件里追加 CaseEntry 即可，首页无需改动。
 */

interface HomeCategory {
  categoryRoute: string;
  /** 卡片左上角的序号 */
  categoryIndex: string;
  categoryTitle: string;
  categoryDesc: string;
  /** 已有案例数；0 表示分类还在整理，进入占位页 */
  categoryCaseCount: number;
  categoryPage: WrappedBuilder<[NavPathStack]>;
}

@Builder
function safeAreaCategoryPage(pageStack: NavPathStack) {
  CategoryPlaceholderPage({ pageStack: pageStack, categoryTitle: '未避让安全区' })
}

@Builder
function marginCategoryPage(pageStack: NavPathStack) {
  CategoryPlaceholderPage({ pageStack: pageStack, categoryTitle: '边距过大' })
}

/** 路由未登记时的兜底页，避免白屏 */
@Builder
function routeNotFoundPage(pageStack: NavPathStack) {
  NavDestination() {
    Column({ space: 10 }) {
      Text('页面不存在')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#14161A')

      Text('该路由未在首页分类表或案例表中登记')
        .fontSize(12)
        .fontColor('#7A756B')

      Button('返回')
        .fontSize(14)
        .height(36)
        .margin({ top: 6 })
        .onClick(() => {
          pageStack.pop();
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F2EC')
    .justifyContent(FlexAlign.Center)
  }
  .hideTitleBar(true)
}

const ROUTE_NOT_FOUND_PAGE: WrappedBuilder<[NavPathStack]> = wrapBuilder(routeNotFoundPage);

/** 首页分类表：顺序即展示顺序，两列排布 */
const HOME_CATEGORIES: HomeCategory[] = [
  {
    categoryRoute: 'truncation',
    categoryIndex: '01',
    categoryTitle: '截断重叠',
    categoryDesc: '弹窗、弹层的文字被父容器裁切，显示不全',
    categoryCaseCount: TRUNCATION_CASE_COUNT,
    categoryPage: TRUNCATION_CATEGORY_PAGE
  },
  {
    categoryRoute: 'category/safe-area',
    categoryIndex: '02',
    categoryTitle: '未避让安全区',
    categoryDesc: '内容压到状态栏、导航条、挖孔区域',
    categoryCaseCount: 0,
    categoryPage: wrapBuilder(safeAreaCategoryPage)
  },
  {
    categoryRoute: 'category/margin',
    categoryIndex: '03',
    categoryTitle: '边距过大',
    categoryDesc: '折叠态 / 展开态间距失衡，留白明显过多',
    categoryCaseCount: 0,
    categoryPage: wrapBuilder(marginCategoryPage)
  },
  {
    categoryRoute: 'category/big-content',
    categoryIndex: '04',
    categoryTitle: '大图大字',
    categoryDesc: '商品图跟着列宽等比放大，横屏一屏只剩一行',
    categoryCaseCount: BIG_CONTENT_CASE_COUNT,
    categoryPage: BIG_CONTENT_CATEGORY_PAGE
  }
];

/** 分类页 + 各分类下的案例页，统一在这里解析 */
function resolvePage(routeName: string): WrappedBuilder<[NavPathStack]> {
  for (const category of HOME_CATEGORIES) {
    if (category.categoryRoute === routeName) {
      return category.categoryPage;
    }
  }
  const casePage: WrappedBuilder<[NavPathStack]> | undefined = resolveTruncationCasePage(routeName);
  if (casePage !== undefined) {
    return casePage;
  }
  const bigContentCasePage: WrappedBuilder<[NavPathStack]> | undefined = resolveBigContentCasePage(routeName);
  if (bigContentCasePage !== undefined) {
    return bigContentCasePage;
  }
  return ROUTE_NOT_FOUND_PAGE;
}

@Entry
@Component
struct Index {
  private navStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    // 让状态栏、导航条区域与纸色页面背景一致，避免顶部出现一条白边
    const hostContext = this.getUIContext().getHostContext();
    if (hostContext === undefined) {
      return;
    }
    window.getLastWindow(hostContext).then((win: window.Window) => {
      win.setWindowBackgroundColor('#F4F2EC');
    }).catch((error: BusinessError) => {
      console.error(`setWindowBackgroundColor failed, code=${error.code}`);
    });
  }

  @Builder
  categoryDestination(routeName: string) {
    resolvePage(routeName).builder(this.navStack);
  }

  /** 两列网格的总高度：每行 172vp，行间距 12vp */
  private categoryGridHeight(): number {
    const rows: number = Math.ceil(HOME_CATEGORIES.length / 2);
    return rows * 172 + (rows - 1) * 12;
  }

  @Builder
  pageHeader() {
    Column() {
      Row() {
        Text('UX / ANTIPATTERN')
          .fontSize(10)
          .letterSpacing(3)
          .fontColor('#8A857A')

        Blank()

        Text('折叠屏 · 大屏')
          .fontSize(10)
          .letterSpacing(1)
          .fontColor('#8A857A')
      }
      .width('100%')

      Text('问题分类')
        .fontSize(44)
        .fontWeight(FontWeight.Bold)
        .fontColor('#14161A')
        .margin({ top: 12 })

      Text('按问题类型归档的适配反例，进入分类查看具体案例')
        .fontSize(12)
        .fontColor('#6B665C')
        .margin({ top: 8 })

      Row()
        .width(56)
        .height(4)
        .backgroundColor('#E2452B')
        .margin({ top: 16 })
    }
    .width('100%')
    .padding({ top: 18, bottom: 24 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  categoryTile(category: HomeCategory) {
    Column() {
      Row() {
        Text(category.categoryIndex)
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontStyle(FontStyle.Italic)
          .fontColor(category.categoryCaseCount > 0 ? '#14161A' : '#C6C0B2')

        Blank()

        if (category.categoryCaseCount > 0) {
          Text(category.categoryCaseCount.toString() + ' 案例')
            .fontSize(9)
            .fontColor('#E2452B')
            .border({ width: 1, color: '#E2452B' })
            .borderRadius(8)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
        } else {
          Text('整理中')
            .fontSize(9)
            .fontColor('#9A958A')
            .border({ width: 1, color: '#D8D2C4' })
            .borderRadius(8)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
        }
      }
      .width('100%')

      Blank()

      Text(category.categoryTitle)
        .fontSize(21)
        .fontWeight(FontWeight.Bold)
        .fontColor(category.categoryCaseCount > 0 ? '#14161A' : '#8A857A')

      Text(category.categoryDesc)
        .fontSize(10.5)
        .lineHeight(16)
        .fontColor('#7A756B')
        .maxLines(2)
        .margin({ top: 6 })
    }
    .width('100%')
    .height(172)
    .padding(15)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor('#FBF9F4')
    .border({ width: 1.5, color: category.categoryCaseCount > 0 ? '#14161A' : '#D8D2C4' })
    .borderRadius(6)
    .onClick(() => {
      this.navStack.pushPathByName(category.categoryRoute, '');
    })
  }

  @Builder
  pageFooter() {
    Text('共 4 个分类 · 案例持续补充中')
      .fontSize(10)
      .lineHeight(16)
      .fontColor('#A39D90')
      .width('100%')
      .margin({ top: 22 })
  }

  build() {
    Navigation(this.navStack) {
      Scroll() {
        Column() {
          Column() {
            this.pageHeader()

            Grid() {
              ForEach(HOME_CATEGORIES, (category: HomeCategory) => {
                GridItem() {
                  this.categoryTile(category)
                }
              }, (category: HomeCategory) => category.categoryRoute)
            }
            .width('100%')
            .height(this.categoryGridHeight())
            .columnsTemplate('1fr 1fr')
            .columnsGap(12)
            .rowsGap(12)
            .scrollBar(BarState.Off)

            this.pageFooter()
          }
          .width('100%')
          .constraintSize({ maxWidth: 760 })
          .padding({ left: 20, right: 20, bottom: 24 })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .backgroundColor('#F4F2EC')
    }
    .navDestination(this.categoryDestination)
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .backgroundColor('#F4F2EC')
  }
}
