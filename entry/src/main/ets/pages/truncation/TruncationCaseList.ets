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
import { PharmacySearchTruncationPage } from './PharmacySearchTruncation';
import { LoginPageOverlapTruncationPage } from './LoginPageOverlapTruncation';
import { FundDetailOverflowPage } from './FundDetailOverflow';
import { HnaTravelProductOverflowPage } from './HnaTravelProductOverflow';
import { HnaMealServiceOverlapPage } from './HnaMealServiceOverlap';
import { HnaLoungeWrapPage } from './HnaLoungeWrap';
import { StationBoardOverflowPage } from './StationBoardOverflow';
import { DisneyTicketDateOverflowPage } from './DisneyTicketDateOverflow';
import { DidiDeliveryHeaderOverflowPage } from './DidiDeliveryHeaderOverflow';
import { DidiOrderListOverflowPage } from './DidiOrderListOverflow';
import { TaobaoOrderDetailOverflowPage } from './TaobaoOrderDetailOverflow';
import { JdCouponDialogTruncationPage } from './JdCouponDialogTruncation';
import { TrainTicketPassengerSheetPage } from './TrainTicketPassengerSheet';
import { CtripFlightFilterOverlapPage } from './CtripFlightFilterOverlap';
import { ElemeShopNoticeOverlapPage } from './ElemeShopNoticeOverlap';
import { AlipayBillListOverflowPage } from './AlipayBillListOverflow';
import { DouyinCommentSheetFoldPage } from './DouyinCommentSheetFold';
import { PddGroupDialogTruncationPage } from './PddGroupDialogTruncation';
import { XhsNoteTagWrapPage } from './XhsNoteTagWrap';
import { NetEasePlaylistOverlapPage } from './NetEasePlaylistOverlap';
import { QqMusicLyricTruncationPage } from './QqMusicLyricTruncation';
import { AmapRouteSheetTruncationPage } from './AmapRouteSheetTruncation';
import { IqiyiVipDialogTruncationPage } from './IqiyiVipDialogTruncation';
import { WechatTransferNoteOverflowPage } from './WechatTransferNoteOverflow';

interface TruncationCaseEntry {
  caseRoute: string;
  caseTitle: string;
  /** 案例类型标签（如「弹窗截断」） */
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

@Builder
function pharmacySearchCasePage(pageStack: NavPathStack) {
  PharmacySearchTruncationPage({ pageStack: pageStack })
}

@Builder
function loginOverlapCasePage(pageStack: NavPathStack) {
  LoginPageOverlapTruncationPage({ pageStack: pageStack })
}

@Builder
function fundDetailCasePage(pageStack: NavPathStack) {
  FundDetailOverflowPage({ pageStack: pageStack })
}

@Builder
function hnaTravelCasePage(pageStack: NavPathStack) {
  HnaTravelProductOverflowPage({ pageStack: pageStack })
}

@Builder
function hnaMealCasePage(pageStack: NavPathStack) {
  HnaMealServiceOverlapPage({ pageStack: pageStack })
}

@Builder
function hnaLoungeCasePage(pageStack: NavPathStack) {
  HnaLoungeWrapPage({ pageStack: pageStack })
}

@Builder
function stationBoardCasePage(pageStack: NavPathStack) {
  StationBoardOverflowPage({ pageStack: pageStack })
}

@Builder
function disneyTicketCasePage(pageStack: NavPathStack) {
  DisneyTicketDateOverflowPage({ pageStack: pageStack })
}

@Builder
function didiDeliveryCasePage(pageStack: NavPathStack) {
  DidiDeliveryHeaderOverflowPage({ pageStack: pageStack })
}

@Builder
function didiOrderListCasePage(pageStack: NavPathStack) {
  DidiOrderListOverflowPage({ pageStack: pageStack })
}

@Builder
function taobaoOrderDetailCasePage(pageStack: NavPathStack) {
  TaobaoOrderDetailOverflowPage({ pageStack: pageStack })
}

@Builder
function jdCouponDialogCasePage(pageStack: NavPathStack) {
  JdCouponDialogTruncationPage({ pageStack: pageStack })
}

@Builder
function trainPassengerSheetCasePage(pageStack: NavPathStack) {
  TrainTicketPassengerSheetPage({ pageStack: pageStack })
}

@Builder
function ctripFlightFilterCasePage(pageStack: NavPathStack) {
  CtripFlightFilterOverlapPage({ pageStack: pageStack })
}

@Builder
function elemeShopNoticeCasePage(pageStack: NavPathStack) {
  ElemeShopNoticeOverlapPage({ pageStack: pageStack })
}

@Builder
function alipayBillListCasePage(pageStack: NavPathStack) {
  AlipayBillListOverflowPage({ pageStack: pageStack })
}

@Builder
function douyinCommentSheetCasePage(pageStack: NavPathStack) {
  DouyinCommentSheetFoldPage({ pageStack: pageStack })
}

@Builder
function pddGroupDialogCasePage(pageStack: NavPathStack) {
  PddGroupDialogTruncationPage({ pageStack: pageStack })
}

@Builder
function xhsNoteTagCasePage(pageStack: NavPathStack) {
  XhsNoteTagWrapPage({ pageStack: pageStack })
}

@Builder
function neteasePlaylistCasePage(pageStack: NavPathStack) {
  NetEasePlaylistOverlapPage({ pageStack: pageStack })
}

@Builder
function qqMusicLyricCasePage(pageStack: NavPathStack) {
  QqMusicLyricTruncationPage({ pageStack: pageStack })
}

@Builder
function amapRouteSheetCasePage(pageStack: NavPathStack) {
  AmapRouteSheetTruncationPage({ pageStack: pageStack })
}

@Builder
function iqiyiVipDialogCasePage(pageStack: NavPathStack) {
  IqiyiVipDialogTruncationPage({ pageStack: pageStack })
}

@Builder
function wechatTransferNoteCasePage(pageStack: NavPathStack) {
  WechatTransferNoteOverflowPage({ pageStack: pageStack })
}

/** 截断重叠分类下的全部案例，新增案例时在这里追加一条 */
const TRUNCATION_CASES: TruncationCaseEntry[] = [
  {
    caseRoute: 'truncation/filter-dialog',
    caseTitle: '购票场景文字截断',
    caseTag: '弹窗截断',
    caseIcon: '票',
    caseSummary: '确认订单弹窗里座位与价格被下沿裁掉半截',
    casePage: wrapBuilder(filterDialogCasePage)
  },
  {
    caseRoute: 'truncation/vip-renewal-sheet',
    caseTitle: '会员续费弹层截断',
    caseTag: '弹窗截断',
    caseIcon: '会',
    caseSummary: '续费弹层底部权益文字压到支付按钮上',
    casePage: wrapBuilder(vipRenewalCasePage)
  },
  {
    caseRoute: 'truncation/hema-task-sheet',
    caseTitle: '盒马签到弹层截断',
    caseTag: '弹窗截断',
    caseIcon: '签',
    caseSummary: '签到弹层的奖励文案被弹层下沿裁断',
    casePage: wrapBuilder(hemaTaskSheetCasePage)
  },
  {
    caseRoute: 'truncation/hema-my-menu',
    caseTitle: '盒马我的菜单截断',
    caseTag: '弹窗截断',
    caseIcon: '单',
    caseSummary: '菜单面板里「我的订单」等入口只剩半行',
    casePage: wrapBuilder(hemaMyMenuCasePage)
  },
  {
    caseRoute: 'truncation/bike-card-gift',
    caseTitle: '美团骑行卡赠送弹窗截断',
    caseTag: '弹窗截断',
    caseIcon: '骑',
    caseSummary: '赠送弹窗的输入框与按钮文字被裁',
    casePage: wrapBuilder(bikeGiftCasePage)
  },
  {
    caseRoute: 'truncation/coupon-rules-dialog',
    caseTitle: '美团神券规则弹窗截断',
    caseTag: '弹窗截断',
    caseIcon: '券',
    caseSummary: '规则弹窗最后一行规则与按钮看不全',
    casePage: wrapBuilder(couponRulesCasePage)
  },
  {
    caseRoute: 'truncation/pharmacy-search',
    caseTitle: '看病买药搜索框截断',
    caseTag: '文字截断',
    caseIcon: '药',
    caseSummary: '横屏时搜索框上半截被黄色标题区压掉',
    casePage: wrapBuilder(pharmacySearchCasePage)
  },
  {
    caseRoute: 'truncation/login-overlap',
    caseTitle: '美团登录页文字重叠',
    caseTag: '文字重叠',
    caseIcon: '登',
    caseSummary: '横屏时「验证码登录」与「其他登录方式」叠在一起',
    casePage: wrapBuilder(loginOverlapCasePage)
  },
  {
    caseRoute: 'truncation/fund-detail-overflow',
    caseTitle: '基金详情页大字溢出',
    caseTag: '文字溢出',
    caseIcon: '基',
    caseSummary: '涨幅行与风险标签顶出白卡，右侧半个字被屏幕切掉',
    casePage: wrapBuilder(fundDetailCasePage)
  },
  {
    caseRoute: 'truncation/hna-travel-product',
    caseTitle: '海航出行产品页标题溢出',
    caseTag: '文字溢出',
    caseIcon: '航',
    caseSummary: '「请选择适合您的出行产品」三行大字压出粉色头部',
    casePage: wrapBuilder(hnaTravelCasePage)
  },
  {
    caseRoute: 'truncation/hna-meal-service',
    caseTitle: '海航餐食页文字压字',
    caseTag: '文字重叠',
    caseIcon: '餐',
    caseSummary: '三张餐食卡片的标题与正文互相压盖',
    casePage: wrapBuilder(hnaMealCasePage)
  },
  {
    caseRoute: 'truncation/hna-lounge',
    caseTitle: '海航贵宾室机场名竖排',
    caseTag: '文字折行',
    caseIcon: '厅',
    caseSummary: '「美兰国际机场」逐字竖排，产品卡文字被右边缘切掉',
    casePage: wrapBuilder(hnaLoungeCasePage)
  },
  {
    caseRoute: 'truncation/disney-ticket',
    caseTitle: '迪士尼门票日期格溢出',
    caseTag: '文字溢出',
    caseIcon: '迪',
    caseSummary: '日期格字号撑破格子，橙色价格被下沿裁掉',
    casePage: wrapBuilder(disneyTicketCasePage)
  },
  {
    caseRoute: 'truncation/station-board',
    caseTitle: '车站大屏检票口压行',
    caseTag: '文字重叠',
    caseIcon: '站',
    caseSummary: '检票口两行字压到下一行，状态大字跨行',
    casePage: wrapBuilder(stationBoardCasePage)
  },
  {
    caseRoute: 'truncation/didi-delivery-home',
    caseTitle: '滴滴送货首页标题叠字',
    caseTag: '文字重叠',
    caseIcon: '送',
    caseSummary: '「送货」竖排字与「滴滴送货 | 武汉」叠在一起',
    casePage: wrapBuilder(didiDeliveryCasePage)
  },
  {
    caseRoute: 'truncation/didi-order-list',
    caseTitle: '滴滴我的订单地址溢出',
    caseTag: '文字溢出',
    caseIcon: '单',
    caseSummary: '订单地址冲出卡片，被屏幕右边缘切断',
    casePage: wrapBuilder(didiOrderListCasePage)
  },
  {
    caseRoute: 'truncation/taobao-order-detail',
    caseTitle: '淘宝订单详情地址溢出',
    caseTag: '文字溢出',
    caseIcon: '淘',
    caseSummary: '订单收货地址长文本冲出白卡，被屏幕右边缘切掉半个字。',
    casePage: wrapBuilder(taobaoOrderDetailCasePage)
  },
  {
    caseRoute: 'truncation/jd-coupon-dialog',
    caseTitle: '京东用券规则弹窗截断',
    caseTag: '弹窗截断',
    caseIcon: '券',
    caseSummary: '用券规则弹窗最后一行规则与「知道了」按钮被弹窗下沿裁掉。',
    casePage: wrapBuilder(jdCouponDialogCasePage)
  },
  {
    caseRoute: 'truncation/train-passenger-sheet',
    caseTitle: '12306乘车人弹层截断',
    caseTag: '弹窗截断',
    caseIcon: '车',
    caseSummary: '乘车人列表最后一行与「完成」按钮被弹层下沿裁掉。',
    casePage: wrapBuilder(trainPassengerSheetCasePage)
  },
  {
    caseRoute: 'truncation/ctrip-flight-filter',
    caseTitle: '携程机票筛选项压行',
    caseTag: '文字重叠',
    caseIcon: '航',
    caseSummary: '筛选标签行与「经济舱1.8折」起价行互相压盖。',
    casePage: wrapBuilder(ctripFlightFilterCasePage)
  },
  {
    caseRoute: 'truncation/eleme-shop-notice',
    caseTitle: '饿了么店铺公告压字',
    caseTag: '文字重叠',
    caseIcon: '饿',
    caseSummary: '店铺公告长文与「30分钟达」配送信息叠在一起。',
    casePage: wrapBuilder(elemeShopNoticeCasePage)
  },
  {
    caseRoute: 'truncation/alipay-bill-list',
    caseTitle: '支付宝账单商户名溢出',
    caseTag: '文字溢出',
    caseIcon: '账',
    caseSummary: '商户名与金额同一行冲出卡片，右侧金额被屏幕切断。',
    casePage: wrapBuilder(alipayBillListCasePage)
  },
  {
    caseRoute: 'truncation/douyin-comment-sheet',
    caseTitle: '抖音评论弹层文字折行',
    caseTag: '文字折行',
    caseIcon: '评',
    caseSummary: '评论长句逐字折行、@用户名被拆成两行错位。',
    casePage: wrapBuilder(douyinCommentSheetCasePage)
  },
  {
    caseRoute: 'truncation/pdd-group-dialog',
    caseTitle: '拼多多拼单结果弹窗截断',
    caseTag: '弹窗截断',
    caseIcon: '拼',
    caseSummary: '拼单弹窗的倒计时行与「邀请好友参团」按钮被下沿裁掉。',
    casePage: wrapBuilder(pddGroupDialogCasePage)
  },
  {
    caseRoute: 'truncation/xhs-note-tags',
    caseTitle: '小红书笔记标签竖排',
    caseTag: '文字折行',
    caseIcon: '红',
    caseSummary: '「户外露营好物推荐」等标签逐字竖排，两列标签错位重叠。',
    casePage: wrapBuilder(xhsNoteTagCasePage)
  },
  {
    caseRoute: 'truncation/netease-playlist',
    caseTitle: '网易云歌单曲名压歌手',
    caseTag: '文字重叠',
    caseIcon: '云',
    caseSummary: '歌单里长歌名与歌手名同一列互相压盖。',
    casePage: wrapBuilder(neteasePlaylistCasePage)
  },
  {
    caseRoute: 'truncation/qqmusic-lyric',
    caseTitle: 'QQ音乐歌词行被裁',
    caseTag: '文字截断',
    caseIcon: '词',
    caseSummary: '歌词长句被右侧封面图盖住，句尾丢失。',
    casePage: wrapBuilder(qqMusicLyricCasePage)
  },
  {
    caseRoute: 'truncation/amap-route-sheet',
    caseTitle: '高德路线方案弹层截断',
    caseTag: '弹窗截断',
    caseIcon: '图',
    caseSummary: '推荐方案的红绿灯与打车价被弹层下沿裁掉一行。',
    casePage: wrapBuilder(amapRouteSheetCasePage)
  },
  {
    caseRoute: 'truncation/iqiyi-vip-dialog',
    caseTitle: '爱奇艺会员弹窗权益截断',
    caseTag: '弹窗截断',
    caseIcon: '视',
    caseSummary: '会员权益第5条与「立即开通」按钮被弹窗裁掉。',
    casePage: wrapBuilder(iqiyiVipDialogCasePage)
  },
  {
    caseRoute: 'truncation/wechat-transfer-note',
    caseTitle: '微信转账留言溢出',
    caseTag: '文字溢出',
    caseIcon: '转',
    caseSummary: '转账留言与金额冲出气泡，被屏幕右边缘切断。',
    casePage: wrapBuilder(wechatTransferNoteCasePage)
  }
];

export const TRUNCATION_CASE_COUNT: number = TRUNCATION_CASES.length;

/** 「不限标签」的筛选值 */
const TRUNCATION_ALL_TAG: string = '全部';

interface TruncationTagChip {
  tagLabel: string;
  /** 该标签下的案例数，直接显示在筛选项上 */
  tagCount: number;
}

/** 从案例表里收集出现过的标签（去重、保持首次出现顺序） */
function collectTruncationTags(): string[] {
  const tagLabels: string[] = [];
  for (const caseEntry of TRUNCATION_CASES) {
    if (tagLabels.indexOf(caseEntry.caseTag) < 0) {
      tagLabels.push(caseEntry.caseTag);
    }
  }
  return tagLabels;
}

function countTruncationCases(tagLabel: string): number {
  let caseCount: number = 0;
  for (const caseEntry of TRUNCATION_CASES) {
    if (tagLabel === TRUNCATION_ALL_TAG || caseEntry.caseTag === tagLabel) {
      caseCount += 1;
    }
  }
  return caseCount;
}

/** 筛选栏数据：第一项「全部」，其余按案例表里出现的标签生成 */
function buildTruncationTagChips(): TruncationTagChip[] {
  const chips: TruncationTagChip[] = [
    { tagLabel: TRUNCATION_ALL_TAG, tagCount: TRUNCATION_CASES.length }
  ];
  const tagLabels: string[] = collectTruncationTags();
  for (const tagLabel of tagLabels) {
    chips.push({ tagLabel: tagLabel, tagCount: countTruncationCases(tagLabel) });
  }
  return chips;
}

const TRUNCATION_TAG_CHIPS: TruncationTagChip[] = buildTruncationTagChips();

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

  /** 当前选中的标签，默认「全部」 */
  @State activeTag: string = TRUNCATION_ALL_TAG;

  /** 搜索关键词：同时匹配案例标题与标签 */
  @State searchKeyword: string = '';

  private listScroller: Scroller = new Scroller();

  /** 标签 + 关键词双重过滤后的案例 */
  private visibleCases(): TruncationCaseEntry[] {
    const keyword: string = this.searchKeyword.trim();
    return TRUNCATION_CASES.filter((caseEntry: TruncationCaseEntry) => {
      if (this.activeTag !== TRUNCATION_ALL_TAG && caseEntry.caseTag !== this.activeTag) {
        return false;
      }
      if (keyword.length === 0) {
        return true;
      }
      return caseEntry.caseTitle.indexOf(keyword) >= 0 || caseEntry.caseTag.indexOf(keyword) >= 0;
    });
  }

  /** 有任一筛选条件生效 */
  private isFiltering(): boolean {
    return this.activeTag !== TRUNCATION_ALL_TAG || this.searchKeyword.trim().length > 0;
  }

  /** 右上角的计数：有筛选时显示「命中 / 总数」 */
  private caseCountLabel(): string {
    if (!this.isFiltering()) {
      return TRUNCATION_CASE_COUNT.toString() + ' 个案例';
    }
    return this.visibleCases().length.toString() + ' / ' + TRUNCATION_CASE_COUNT.toString() + ' 个案例';
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
  private tagChipKey(chip: TruncationTagChip): string {
    return chip.tagLabel + (this.activeTag === chip.tagLabel ? '#on' : '#off');
  }

  @Builder
  tagChip(chip: TruncationTagChip) {
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

  /** 搜索框：按标题或标签搜索 */
  @Builder
  searchField() {
    Row() {
      SymbolGlyph($r('sys.symbol.magnifyingglass'))
        .fontSize(15)
        .fontColor(['#8A857A'])

      TextInput({ text: this.searchKeyword, placeholder: '搜索案例标题或标签' })
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
        ForEach(TRUNCATION_TAG_CHIPS, (chip: TruncationTagChip) => {
          this.tagChip(chip)
        }, (chip: TruncationTagChip) => this.tagChipKey(chip))
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

          Text('截断重叠')
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
            ForEach(this.visibleCases(), (caseEntry: TruncationCaseEntry) => {
              this.caseCard(caseEntry)
            }, (caseEntry: TruncationCaseEntry) => caseEntry.caseRoute)

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
