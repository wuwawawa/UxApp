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
 * 反例：截断 / 支付宝账单商户名溢出（文字溢出）
 *
 * 反例主题：商户名与金额同一行冲出卡片，右侧金额被屏幕切断。
 *
 * 复刻对象：支付宝「账单」页 —— 蓝色渐变头部（返回 + 账单 + 搜索图标）、
 *   「10月 ▾」月度汇总卡（支出 ¥3,286.50 / 收入 ¥8,420.00）、
 *   「全部 / 支出 / 收入」筛选行，下面按日分组列出账单卡：
 *   日期头（10月22日 星期三）+ 白卡里每行「彩色圆标 + 商户名长文本 + 分类标签 +
 *   交易金额」，如 肯德基宅急送、叮当快药、花呗、哈啰单车、链家地产、余额宝。
 *
 * 设计基准：以单屏折叠态窗口宽 459.6vp 为基准：
 *   头部标题行 44vp、标题 18vp；月度卡内边距 16vp、月份 20vp、金额 22vp；
 *   账单卡留白 12vp、圆角 14vp、内边距 12vp；行内圆标 36vp、商户名 15vp、
 *   标签 10vp、金额 16vp；行高 56vp。
 *
 * 三态实测（商户名栏宽按基准 330vp 随窗口放大，金额跟在商户名后面）：
 *   单屏态        459.6×672vp   —— 商户名栏 330vp，行总宽约 480vp，
 *                                 超出窗口 20vp，「-¥178.00」末位数字被屏幕右沿切掉；
 *   双屏态竖屏    664.7×939.6vp —— 商户名栏放大到 477.2vp，行总宽约 694vp，
 *                                 冲出卡片右沿 53vp，金额后半段整串出屏；
 *   双屏态横屏    939.6×664.7vp —— 商户名栏放大到 674.5vp，行总宽约 981vp，
 *                                 冲出卡片右沿 65.5vp，金额完全落在屏幕外，整行不可读。
 *
 * 问题表现：
 *   账单行里「商户名 + 金额」排在一行，商户名栏宽写死为基准 330vp 再随窗口放大，
 *   而金额固定跟在商户名后面、不做右对齐；窗口一宽，整行宽度远超卡片可用宽度，
 *   白卡又开了 clip(false)，于是商户名冲出卡片右沿、金额被屏幕右边缘切断，
 *   「-¥178.00」只剩「-¥17…」甚至完全看不见。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 缩放基准：单屏折叠态窗口宽度（1264px / 2.75） */
const ALB_BASE_WIDTH: number = 459.6;

/** 状态栏 / 底部手势区兜底高度（vp） */
const ALB_STATUS_BAR_FALLBACK: number = 32;
const ALB_BOTTOM_INSET_FALLBACK: number = 8;

const ALB_PAGE_BG: string = '#F5F6F8';
const ALB_HEADER_START: string = '#1677FF';
const ALB_HEADER_END: string = '#0E5FD8';
const ALB_BLUE: string = '#1677FF';
const ALB_BLUE_LIGHT: string = '#E8F1FF';
const ALB_TEXT_MAIN: string = '#1A1A1A';
const ALB_TEXT_SUB: string = '#8C8C8C';
const ALB_TEXT_LIGHT: string = '#B9BFC8';
const ALB_EXPENSE_TEXT: string = '#1A1A1A';
const ALB_INCOME_TEXT: string = '#FF8F1F';

/** 头部：标题行 44vp、标题 18vp、返回箭头 24vp */
const ALB_TITLE_ROW_HEIGHT: number = 44;
const ALB_TITLE_FONT: number = 18;
const ALB_BACK_FONT: number = 24;

/** 月度汇总卡：内边距 16vp、月份 20vp、金额 22vp、副文字 11vp */
const ALB_MONTH_PAD: number = 16;
const ALB_MONTH_FONT: number = 20;
const ALB_AMOUNT_FONT: number = 22;
const ALB_MONTH_SUB_FONT: number = 11;

/** 筛选行：高 36vp、文字 13vp */
const ALB_FILTER_ROW_HEIGHT: number = 36;
const ALB_FILTER_FONT: number = 13;

/** 账单卡：留白 12vp、圆角 14vp、内边距 12vp、行高 56vp */
const ALB_CARD_INSET: number = 12;
const ALB_CARD_RADIUS: number = 14;
const ALB_CARD_PAD: number = 12;
const ALB_ROW_HEIGHT: number = 56;

/** 行内：圆标 36vp、商户名 15vp、标签 10vp、金额 16vp */
const ALB_ICON_SIZE: number = 36;
const ALB_MERCHANT_FONT: number = 15;
const ALB_TAG_FONT: number = 10;
const ALB_AMOUNT_ROW_FONT: number = 16;

/** 商户名栏宽（基准值）：随窗口放大后行总宽远超卡片与屏幕，金额被切断（反例根源） */
const ALB_MERCHANT_WIDTH: number = 330;

/** 账单条目 */
interface AlipayBillEntry {
  billMerchant: string;
  billTag: string;
  billIcon: Resource;
  billTint: string;
  billAmount: string;
  billIncome: boolean;
}

/** 按日分组的账单 */
interface AlipayBillGroup {
  groupDate: string;
  groupBills: AlipayBillEntry[];
}

const ALB_BILL_GROUPS: AlipayBillGroup[] = [
  {
    groupDate: '10月22日 星期三',
    groupBills: [
      {
        billMerchant: '天猫超市（杭州市西湖区西溪园区生鲜仓发货）',
        billTag: '网络购物',
        billIcon: $r('sys.symbol.bag_fill'),
        billTint: '#E8A13F',
        billAmount: '-¥178.00',
        billIncome: false
      },
      {
        billMerchant: '叮当快药（文一西路店）',
        billTag: '医疗健康',
        billIcon: $r('sys.symbol.cross_case_fill'),
        billTint: '#3FAE6A',
        billAmount: '-¥45.60',
        billIncome: false
      }
    ]
  },
  {
    groupDate: '10月21日 星期二',
    groupBills: [
      {
        billMerchant: '花呗-中国联通浙江分公司通信费自动扣款',
        billTag: '缴费还款',
        billIcon: $r('sys.symbol.creditcard'),
        billTint: '#3E8FE8',
        billAmount: '-¥99.00',
        billIncome: false
      },
      {
        billMerchant: '哈啰单车（西湖区骑行卡自动续费）',
        billTag: '交通出行',
        billIcon: $r('sys.symbol.bicycle'),
        billTint: '#3E8FE8',
        billAmount: '-¥15.00',
        billIncome: false
      }
    ]
  },
  {
    groupDate: '10月20日 星期一',
    groupBills: [
      {
        billMerchant: '链家地产（文三路店）租房押金及服务费',
        billTag: '住房物业',
        billIcon: $r('sys.symbol.house'),
        billTint: '#E8663F',
        billAmount: '-¥3200.00',
        billIncome: false
      },
      {
        billMerchant: '余额宝-2026年10月20日收益发放',
        billTag: '投资理财',
        billIcon: $r('sys.symbol.leaf'),
        billTint: '#3FAE6A',
        billAmount: '+¥12.34',
        billIncome: true
      }
    ]
  }
];

/** 筛选标签 */
const ALB_FILTER_LABELS: string[] = ['全部', '支出', '收入', '爱心捐赠'];

@Component
export struct AlipayBillListOverflowPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = ALB_BASE_WIDTH;
  @State winHeightVp: number = 672;
  /** 沉浸式下的状态栏 / 底部手势区高度（vp） */
  @State statusBarHeightVp: number = ALB_STATUS_BAR_FALLBACK;
  @State bottomInsetVp: number = ALB_BOTTOM_INSET_FALLBACK;

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
      this.windowToken = WindowModeController.acquire(win, ALB_HEADER_START);
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  /** 场景缩放比：当前窗口宽 / 单屏折叠态基准宽 */
  private sceneScale(): number {
    return this.winWidthVp / ALB_BASE_WIDTH;
  }

  /** 把基准宽下的设计值换算到当前窗口宽度 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  /** 头部标题行：返回 + 账单 + 搜索 */
  @Builder
  billTitleBar() {
    Stack({ alignContent: Alignment.Center }) {
      Text('账单')
        .fontSize(this.vs(ALB_TITLE_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)

      Row() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(this.vs(ALB_BACK_FONT))
          .fontColor([Color.White])
          .onClick(() => {
            this.pageStack.pop();
          })

        Blank()

        SymbolGlyph($r('sys.symbol.magnifyingglass'))
          .fontSize(this.vs(20))
          .fontColor([Color.White])
      }
      .width('100%')
      .padding({ left: this.vs(12), right: this.vs(12) })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(this.vs(ALB_TITLE_ROW_HEIGHT))
  }

  /** 月度汇总：10月 支出/收入 */
  @Builder
  monthSummary() {
    Row() {
      Column() {
        Row({ space: this.vs(4) }) {
          Text('10月')
            .fontSize(this.vs(ALB_MONTH_FONT))
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)

          Text('▾')
            .fontSize(this.vs(ALB_MONTH_FONT))
            .fontColor(Color.White)
        }
        .alignItems(VerticalAlign.Center)

        Row({ space: this.vs(16) }) {
          Column() {
            Text('支出')
              .fontSize(this.vs(ALB_MONTH_SUB_FONT))
              .fontColor('rgba(255,255,255,0.75)')

            Text('¥3,286.50')
              .fontSize(this.vs(ALB_AMOUNT_FONT))
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .margin({ top: this.vs(3) })
          }
          .alignItems(HorizontalAlign.Start)

          Column() {
            Text('收入')
              .fontSize(this.vs(ALB_MONTH_SUB_FONT))
              .fontColor('rgba(255,255,255,0.75)')

            Text('¥8,420.00')
              .fontSize(this.vs(ALB_AMOUNT_FONT))
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .margin({ top: this.vs(3) })
          }
          .alignItems(HorizontalAlign.Start)
        }
        .alignItems(VerticalAlign.Bottom)
        .margin({ top: this.vs(10) })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Column() {
        SymbolGlyph($r('sys.symbol.doc_text'))
          .fontSize(this.vs(22))
          .fontColor([Color.White])
      }
      .width(this.vs(44))
      .height(this.vs(44))
      .justifyContent(FlexAlign.Center)
      .backgroundColor('rgba(255,255,255,0.18)')
      .borderRadius(this.vs(22))
    }
    .width('100%')
    .padding(this.vs(ALB_MONTH_PAD))
    .alignItems(VerticalAlign.Center)
  }

  /** 筛选行：全部 / 支出 / 收入 / 爱心捐赠 */
  @Builder
  filterRow() {
    Row({ space: this.vs(22) }) {
      ForEach(ALB_FILTER_LABELS, (filterLabel: string) => {
        Text(filterLabel)
          .fontSize(this.vs(ALB_FILTER_FONT))
          .fontWeight(filterLabel === '全部' ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(filterLabel === '全部' ? ALB_BLUE : ALB_TEXT_SUB)
      }, (filterLabel: string) => filterLabel)
    }
    .width('100%')
    .height(this.vs(ALB_FILTER_ROW_HEIGHT))
    .padding({ left: this.vs(ALB_CARD_INSET + ALB_CARD_PAD) })
    .backgroundColor(Color.White)
    .alignItems(VerticalAlign.Center)
  }

  /** 彩色圆标 */
  @Builder
  billIconCircle(bill: AlipayBillEntry) {
    Column() {
      SymbolGlyph(bill.billIcon)
        .fontSize(this.vs(18))
        .fontColor([Color.White])
    }
    .width(this.vs(ALB_ICON_SIZE))
    .height(this.vs(ALB_ICON_SIZE))
    .justifyContent(FlexAlign.Center)
    .backgroundColor(bill.billTint)
    .borderRadius(this.vs(ALB_ICON_SIZE / 2))
  }

  /**
   * 账单行（反例核心）：商户名栏宽按基准 330vp 随窗口放大，
   * 金额跟在后面不右对齐，行总宽冲出卡片与屏幕右沿。
   */
  @Builder
  billRow(bill: AlipayBillEntry) {
    Row() {
      this.billIconCircle(bill)

      Column() {
        Text(bill.billMerchant)
          .fontSize(this.vs(ALB_MERCHANT_FONT))
          .fontColor(ALB_TEXT_MAIN)
          .maxLines(1)
          .width(this.vs(ALB_MERCHANT_WIDTH))

        Text(bill.billTag)
          .fontSize(this.vs(ALB_TAG_FONT))
          .fontColor(ALB_TEXT_SUB)
          .backgroundColor('#F1F3F6')
          .borderRadius(this.vs(3))
          .padding({ left: this.vs(5), right: this.vs(5), top: this.vs(2), bottom: this.vs(2) })
          .margin({ top: this.vs(4) })
          .alignSelf(ItemAlign.Start)
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: this.vs(10) })

      Text(bill.billAmount)
        .fontSize(this.vs(ALB_AMOUNT_ROW_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(bill.billIncome ? ALB_INCOME_TEXT : ALB_EXPENSE_TEXT)
        .margin({ left: this.vs(10) })
    }
    .width('100%')
    .height(this.vs(ALB_ROW_HEIGHT))
    .alignItems(VerticalAlign.Center)
    .clip(false)
  }

  /** 账单分组卡：日期头 + 白卡行 */
  @Builder
  billGroup(group: AlipayBillGroup) {
    Column() {
      Text(group.groupDate)
        .fontSize(this.vs(12))
        .fontColor(ALB_TEXT_SUB)
        .margin({ bottom: this.vs(8) })

      Column() {
        ForEach(group.groupBills, (bill: AlipayBillEntry) => {
          this.billRow(bill)
        }, (bill: AlipayBillEntry) => bill.billMerchant + bill.billAmount)
      }
      .width('100%')
      .padding({ left: this.vs(ALB_CARD_PAD), right: this.vs(ALB_CARD_PAD) })
      .backgroundColor(Color.White)
      .borderRadius(this.vs(ALB_CARD_RADIUS))
      .alignItems(HorizontalAlign.Start)
      .clip(false)
    }
    .width('100%')
    .margin({ bottom: this.vs(12) })
    .alignItems(HorizontalAlign.Start)
    .clip(false)
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          this.billTitleBar()
          this.monthSummary()
        }
        .width('100%')
        .linearGradient({ angle: 180, colors: [[ALB_HEADER_START, 0], [ALB_HEADER_END, 1]] })
        .padding({ top: this.statusBarHeightVp, bottom: this.vs(14) })

        this.filterRow()

        Scroll() {
          Column() {
            ForEach(ALB_BILL_GROUPS, (group: AlipayBillGroup) => {
              this.billGroup(group)
            }, (group: AlipayBillGroup) => group.groupDate)

            Row()
              .width('100%')
              .height(this.bottomInsetVp + this.vs(20))
          }
          .width('100%')
          .padding({
            left: this.vs(ALB_CARD_INSET),
            right: this.vs(ALB_CARD_INSET),
            top: this.vs(12)
          })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .backgroundColor(ALB_PAGE_BG)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(ALB_PAGE_BG)
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
