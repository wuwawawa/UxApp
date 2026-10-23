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
 * 「未避让安全区」分类页。
 *
 * 与「截断重叠」「大图大字」两个分类一样的结构：首页只负责问题分类，本文件负责该分类内部的
 * 案例列表、搜索框 / 标签筛选、案例页面构建函数与 caseRoute -> 页面 的解析。Navigation 只有
 * 首页一处，因此这里把 caseRoute 压入同一个 NavPathStack 即可，页面由首页的 navDestination
 * 统一构建。
 */

import { FlightFilterStatusBarPage } from './FlightFilterStatusBar';
import { MailAddressStatusBarPage } from './MailAddressStatusBar';
import { ProfileHeaderStatusBarPage } from './ProfilePhoneStatusBar';
import { TaobaoOrderDetailNotchPage } from './TaobaoOrderDetailNotch';
import { WeiboHomeComposeNotchPage } from './WeiboHomeComposeNotch';
import { ElemeStoreMoreNotchPage } from './ElemeStoreMoreNotch';
import { DidiRideTabsNotchPage } from './DidiRideTabsNotch';
import { QqMusicLyricNotchPage } from './QqMusicLyricNotch';
import { CalendarMonthNotchPage } from './CalendarMonthNotch';
import { WechatMomentCameraNotchPage } from './WechatMomentCameraNotch';
import { MeituanOrderServiceNotchPage } from './MeituanOrderServiceNotch';
import { JdOrderConfirmNotchPage } from './JdOrderConfirmNotch';
import { CtripFloatServiceNotchPage } from './CtripFloatServiceNotch';
import { BankTransferNavBarPage } from './BankTransferNavBar';
import { GameStartNavBarPage } from './GameStartNavBar';

interface SafeAreaCaseEntry {
  caseRoute: string;
  caseTitle: string;
  /** 案例类型标签（一个案例可同时属于多个标签，如「挖孔」+「状态栏」） */
  caseTags: string[];
  /** 卡片左侧的单字图标 */
  caseIcon: string;
  /** 卡片右侧的一句话问题描述 */
  caseSummary: string;
  /** 该案例的页面构建函数 */
  casePage: WrappedBuilder<[NavPathStack]>;
}

/** 案例页面构建函数：统一只传入导航栈 */
@Builder
function flightFilterCasePage(pageStack: NavPathStack) {
  FlightFilterStatusBarPage({ pageStack: pageStack })
}

@Builder
function profileHeaderCasePage(pageStack: NavPathStack) {
  ProfileHeaderStatusBarPage({ pageStack: pageStack })
}

@Builder
function mailAddressCasePage(pageStack: NavPathStack) {
  MailAddressStatusBarPage({ pageStack: pageStack })
}

@Builder
function taobaoOrderDetailCasePage(pageStack: NavPathStack) {
  TaobaoOrderDetailNotchPage({ pageStack: pageStack })
}

@Builder
function weiboHomeComposeCasePage(pageStack: NavPathStack) {
  WeiboHomeComposeNotchPage({ pageStack: pageStack })
}

@Builder
function elemeStoreMoreCasePage(pageStack: NavPathStack) {
  ElemeStoreMoreNotchPage({ pageStack: pageStack })
}

@Builder
function didiRideTabsCasePage(pageStack: NavPathStack) {
  DidiRideTabsNotchPage({ pageStack: pageStack })
}

@Builder
function qqMusicLyricCasePage(pageStack: NavPathStack) {
  QqMusicLyricNotchPage({ pageStack: pageStack })
}

@Builder
function calendarMonthCasePage(pageStack: NavPathStack) {
  CalendarMonthNotchPage({ pageStack: pageStack })
}

@Builder
function wechatMomentCameraCasePage(pageStack: NavPathStack) {
  WechatMomentCameraNotchPage({ pageStack: pageStack })
}

@Builder
function meituanOrderServiceCasePage(pageStack: NavPathStack) {
  MeituanOrderServiceNotchPage({ pageStack: pageStack })
}

@Builder
function jdOrderConfirmCasePage(pageStack: NavPathStack) {
  JdOrderConfirmNotchPage({ pageStack: pageStack })
}

@Builder
function ctripFloatServiceCasePage(pageStack: NavPathStack) {
  CtripFloatServiceNotchPage({ pageStack: pageStack })
}

@Builder
function bankTransferCasePage(pageStack: NavPathStack) {
  BankTransferNavBarPage({ pageStack: pageStack })
}

@Builder
function gameStartCasePage(pageStack: NavPathStack) {
  GameStartNavBarPage({ pageStack: pageStack })
}

/** 「未避让安全区」分类下的全部案例，新增案例时在这里追加一条 */
const SAFE_AREA_CASES: SafeAreaCaseEntry[] = [
  {
    caseRoute: 'safearea/flight-filter-statusbar',
    caseTitle: '机票筛选面板压状态栏',
    caseTags: ['状态栏'],
    caseIcon: '筛',
    caseSummary: '单屏态「筛选」标题与右上角 × 只露出下半截，右侧选项被底部裁掉一行',
    casePage: wrapBuilder(flightFilterCasePage)
  },
  {
    caseRoute: 'safearea/profile-header-statusbar',
    caseTitle: '我的页手机号压状态栏',
    caseTags: ['状态栏'],
    caseIcon: '号',
    caseSummary: '双屏横屏时手机号、消息/设置压住状态栏的时间与电量图标',
    casePage: wrapBuilder(profileHeaderCasePage)
  },
  {
    caseRoute: 'safearea/mail-address-statusbar',
    caseTitle: '邮寄地址页拉起键盘压状态栏',
    caseTags: ['状态栏'],
    caseIcon: '址',
    caseSummary: '点「邮编号码」后标题栏滑出屏幕，表单整体上移叠在状态栏时间、电量上',
    casePage: wrapBuilder(mailAddressCasePage)
  },
  {
    caseRoute: 'safearea/taobao-order-detail',
    caseTitle: '淘宝订单详情标题压挖孔',
    caseTags: ['挖孔'],
    caseIcon: '淘',
    caseSummary: '折叠态顶部「订单详情」标题正对前置摄像头挖孔，标题文字被黑色圆孔从正中穿过',
    casePage: wrapBuilder(taobaoOrderDetailCasePage)
  },
  {
    caseRoute: 'safearea/weibo-home-compose',
    caseTitle: '微博发布按钮压挖孔',
    caseTags: ['挖孔', '状态栏'],
    caseIcon: '微',
    caseSummary: '双屏横屏展开态右上角橙色「发布」按钮被挖孔从中部穿透，白色加号被黑孔盖住一半',
    casePage: wrapBuilder(weiboHomeComposeCasePage)
  },
  {
    caseRoute: 'safearea/eleme-store-more',
    caseTitle: '饿了么店铺更多按钮压挖孔',
    caseTags: ['挖孔', '状态栏'],
    caseIcon: '饿',
    caseSummary: '双屏横屏展开态右上角「更多」圆钮被挖孔穿透，白色点阵被黑孔盖住两排',
    casePage: wrapBuilder(elemeStoreMoreCasePage)
  },
  {
    caseRoute: 'safearea/didi-ride-tabs',
    caseTitle: '滴滴打车车型切换压挖孔',
    caseTags: ['挖孔'],
    caseIcon: '滴',
    caseSummary: '折叠态顶部居中的「快车」左字被挖孔整块盖住，选中下划线也被圆孔切断',
    casePage: wrapBuilder(didiRideTabsCasePage)
  },
  {
    caseRoute: 'safearea/qqmusic-lyric',
    caseTitle: 'QQ音乐歌名压挖孔',
    caseTags: ['挖孔'],
    caseIcon: '音',
    caseSummary: '折叠态歌词页顶栏正中的歌名中间一字被挖孔吃掉，两侧也各缺一角',
    casePage: wrapBuilder(qqMusicLyricCasePage)
  },
  {
    caseRoute: 'safearea/calendar-month',
    caseTitle: '日历月份压挖孔',
    caseTags: ['挖孔'],
    caseIcon: '历',
    caseSummary: '折叠态月视图顶栏「2026年10月」的「年」与半个「1」被挖孔盖住',
    casePage: wrapBuilder(calendarMonthCasePage)
  },
  {
    caseRoute: 'safearea/wechat-moment-camera',
    caseTitle: '朋友圈相机按钮压挖孔',
    caseTags: ['挖孔', '状态栏'],
    caseIcon: '朋',
    caseSummary: '双屏横屏右上角相机图标被挖孔压成左侧一条残边，状态栏图标也叠在同一行',
    casePage: wrapBuilder(wechatMomentCameraCasePage)
  },
  {
    caseRoute: 'safearea/meituan-order-service',
    caseTitle: '美团外卖客服按钮压挖孔',
    caseTags: ['挖孔', '状态栏'],
    caseIcon: '美',
    caseSummary: '双屏横屏右上角「客服」胶囊的「服」字与右侧描边被挖孔整块盖住',
    casePage: wrapBuilder(meituanOrderServiceCasePage)
  },
  {
    caseRoute: 'safearea/jd-order-confirm',
    caseTitle: '京东确认订单标题压挖孔',
    caseTags: ['挖孔', '状态栏'],
    caseIcon: '京',
    caseSummary: '折叠态顶部居中的「确认订单」被挖孔从正中穿过，中间两字只剩两侧半截',
    casePage: wrapBuilder(jdOrderConfirmCasePage)
  },
  {
    caseRoute: 'safearea/ctrip-float-service',
    caseTitle: '携程我的订单标题压挖孔',
    caseTags: ['挖孔', '状态栏'],
    caseIcon: '携',
    caseSummary: '折叠态顶部居中的「我的订单」被挖孔整块盖住「的订」，只剩两侧残边',
    casePage: wrapBuilder(ctripFloatServiceCasePage)
  },
  {
    caseRoute: 'safearea/bank-transfer-navbar',
    caseTitle: '银行转账按钮压导航条',
    caseTags: ['导航条'],
    caseIcon: '银',
    caseSummary: '底部「确认转账」沉到导航条下方，一半按钮被小白条挡住',
    casePage: wrapBuilder(bankTransferCasePage)
  },
  {
    caseRoute: 'safearea/game-start-navbar',
    caseTitle: '游戏登录开始键压导航条',
    caseTags: ['导航条'],
    caseIcon: '游',
    caseSummary: '开始游戏按钮贴着屏幕底边，被导航条小白条盖住一半',
    casePage: wrapBuilder(gameStartCasePage)
  }
];

export const SAFE_AREA_CASE_COUNT: number = SAFE_AREA_CASES.length;

/** 「不限标签」的筛选值 */
const SAFE_AREA_ALL_TAG: string = '全部';

interface SafeAreaTagChip {
  tagLabel: string;
  /** 该标签下的案例数，直接显示在筛选项上 */
  tagCount: number;
}

/** 从案例表里收集出现过的标签（去重、保持首次出现顺序） */
function collectSafeAreaTags(): string[] {
  const tagLabels: string[] = [];
  for (const caseEntry of SAFE_AREA_CASES) {
    for (const caseTag of caseEntry.caseTags) {
      if (tagLabels.indexOf(caseTag) < 0) {
        tagLabels.push(caseTag);
      }
    }
  }
  return tagLabels;
}

function countSafeAreaCases(tagLabel: string): number {
  let caseCount: number = 0;
  for (const caseEntry of SAFE_AREA_CASES) {
    if (tagLabel === SAFE_AREA_ALL_TAG || caseEntry.caseTags.indexOf(tagLabel) >= 0) {
      caseCount += 1;
    }
  }
  return caseCount;
}

/** 筛选栏数据：第一项「全部」，其余按案例表里出现的标签生成 */
function buildSafeAreaTagChips(): SafeAreaTagChip[] {
  const chips: SafeAreaTagChip[] = [
    { tagLabel: SAFE_AREA_ALL_TAG, tagCount: SAFE_AREA_CASES.length }
  ];
  const tagLabels: string[] = collectSafeAreaTags();
  for (const tagLabel of tagLabels) {
    chips.push({ tagLabel: tagLabel, tagCount: countSafeAreaCases(tagLabel) });
  }
  return chips;
}

const SAFE_AREA_TAG_CHIPS: SafeAreaTagChip[] = buildSafeAreaTagChips();

/** 按 caseRoute 找案例页面，找不到返回 undefined，由首页兜底 */
export function resolveSafeAreaCasePage(routeName: string): WrappedBuilder<[NavPathStack]> | undefined {
  for (const caseEntry of SAFE_AREA_CASES) {
    if (caseEntry.caseRoute === routeName) {
      return caseEntry.casePage;
    }
  }
  return undefined;
}

@Builder
function safeAreaCaseListPage(pageStack: NavPathStack) {
  SafeAreaCaseListPage({ pageStack: pageStack })
}

/** 首页「未避让安全区」分类卡片的跳转目标 */
export const SAFE_AREA_CATEGORY_PAGE: WrappedBuilder<[NavPathStack]> = wrapBuilder(safeAreaCaseListPage);

@Component
export struct SafeAreaCaseListPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 当前选中的标签，默认「全部」 */
  @State activeTag: string = SAFE_AREA_ALL_TAG;

  /** 搜索关键词：匹配案例标题、标签与问题描述 */
  @State searchKeyword: string = '';

  private listScroller: Scroller = new Scroller();

  /** 标签 + 关键词双重过滤后的案例 */
  private visibleCases(): SafeAreaCaseEntry[] {
    const keyword: string = this.searchKeyword.trim();
    return SAFE_AREA_CASES.filter((caseEntry: SafeAreaCaseEntry) => {
      if (this.activeTag !== SAFE_AREA_ALL_TAG && caseEntry.caseTags.indexOf(this.activeTag) < 0) {
        return false;
      }
      if (keyword.length === 0) {
        return true;
      }
      return caseEntry.caseTitle.indexOf(keyword) >= 0 ||
        caseEntry.caseTags.join(' ').indexOf(keyword) >= 0 ||
        caseEntry.caseSummary.indexOf(keyword) >= 0;
    });
  }

  /** 有任一筛选条件生效 */
  private isFiltering(): boolean {
    return this.activeTag !== SAFE_AREA_ALL_TAG || this.searchKeyword.trim().length > 0;
  }

  /** 右上角的计数：有筛选时显示「命中 / 总数」 */
  private caseCountLabel(): string {
    if (!this.isFiltering()) {
      return SAFE_AREA_CASE_COUNT.toString() + ' 个案例';
    }
    return this.visibleCases().length.toString() + ' / ' + SAFE_AREA_CASE_COUNT.toString() + ' 个案例';
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
  private tagChipKey(chip: SafeAreaTagChip): string {
    return chip.tagLabel + (this.activeTag === chip.tagLabel ? '#on' : '#off');
  }

  @Builder
  tagChip(chip: SafeAreaTagChip) {
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
        ForEach(SAFE_AREA_TAG_CHIPS, (chip: SafeAreaTagChip) => {
          this.tagChip(chip)
        }, (chip: SafeAreaTagChip) => this.tagChipKey(chip))
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
  caseCard(caseEntry: SafeAreaCaseEntry) {
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

          ForEach(caseEntry.caseTags, (caseTag: string) => {
            Text(caseTag)
              .fontSize(10)
              .fontColor('#E2452B')
              .backgroundColor('#FBE7E0')
              .borderRadius(3)
              .padding({ left: 5, right: 5, top: 2, bottom: 2 })
          }, (caseTag: string) => caseTag)
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

          Text('未避让安全区')
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
            ForEach(this.visibleCases(), (caseEntry: SafeAreaCaseEntry) => {
              this.caseCard(caseEntry)
            }, (caseEntry: SafeAreaCaseEntry) => caseEntry.caseRoute)

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
