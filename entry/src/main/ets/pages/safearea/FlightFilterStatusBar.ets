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
 * 反例：未避让安全区 / 机票筛选面板压状态栏（状态栏）
 *
 * 复刻机票 App 的全屏「筛选」面板：顶部「筛选」标题 + 右上角关闭 ×，左侧分类栏
 * （航程类型 / 起飞时间 / 到达时间 / 航空公司 / 机场 / 机型 / 舱位），右侧按分类竖排的
 * 选项（仅看直飞、时间段、航空公司……），底部分隔线与「清空 / 确定」两个胶囊按钮。
 *
 * 设计基准：单屏态截图 1264×1848px（459.6×672vp，密度 2.75），vp = px / 2.75。
 *   面板：宽 459.6vp（等于窗口宽）、高 709.3vp，贴住窗口底边；
 *         标题行 68vp、标题字 21vp（「筛选」两字宽 41.1vp）、
 *         × 外接 15.6vp（x 415.3～430.5vp、笔画 1.7vp、比标题低 5.5vp）；
 *   左侧栏：宽 91.6vp；选中项独占一行（高 42vp、字 16vp、x 14.2vp），
 *           灰色圆角面板 120.7～596.9vp（圆角 7vp），条目高 61.3vp、字 16vp、
 *           有选中选项的分类在 x 6.2vp 处打 3.6vp 橙点；
 *   右侧栏：距左栏 19.3vp、右边距 21.8vp；两列宽 158.9vp、列间距 9.1vp；
 *           分组标题字 16vp（行高 24vp）、标题到选项 9.4vp、选项高 36.7vp、
 *           选项行距 9.4vp、分组间距 20.7vp、选项字 16vp、圆角 4vp；
 *   底部：分隔线 1.5vp；操作栏 110.9vp；胶囊按钮高 53.8vp、左右留白 23.6vp、
 *         按钮间隔 8.4vp、按钮字 19vp。
 *   整块面板按「窗口宽度 / 459.6」等比放大后贴底摆放。
 *
 * 三态实测（同一套设计值，放大后换算到屏幕）：
 *   单屏态      459.6×672vp   —— ×1.000，面板高 709.3vp，顶部超出窗口 37.3vp，
 *                                「筛选」只露 y 0～5.6vp、× 只露 y 0～9.8vp
 *   双屏态竖屏  664.7×939.6vp —— ×1.446，面板高 1025.6vp，顶部超出窗口 86.0vp
 *   双屏态横屏  939.6×664.7vp —— ×2.044，面板高 1449.8vp，顶部超出窗口 785.1vp
 *
 * 问题表现（单屏态）：
 *   「筛选」标题只剩最下面一截（y 0～5.6vp），右上角 × 也被切掉上半部分；
 *   标题与 × 都落在状态栏范围内，时间、电池图标压在同一块区域；
 *   右侧「航空公司」第三行选项被底部分隔线裁掉一半。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 单屏态窗口宽度（1264px / 密度 2.75）：面板所有尺寸的基准宽度 */
const SF_BASE_WIDTH: number = 459.6;

/** 面板设计尺寸：宽度即单屏态窗口宽，高度 = 68 + 528.9 + 1.5 + 110.9 */
const SF_PANEL_WIDTH: number = 459.6;
const SF_HEADER_HEIGHT: number = 68;
const SF_BODY_HEIGHT: number = 528.9;
const SF_DIVIDER_HEIGHT: number = 1.5;
const SF_ACTION_BAR_HEIGHT: number = 110.9;
const SF_PANEL_HEIGHT: number = SF_HEADER_HEIGHT + SF_BODY_HEIGHT + SF_DIVIDER_HEIGHT + SF_ACTION_BAR_HEIGHT;

/** 标题行：标题字 21vp（「筛选」两字宽 41.1vp）；右上角 × 外接 15.6vp、笔画 1.7vp、
 *  距右边缘 24.9vp、比标题低 5.5vp（量出的位置） */
const SF_TITLE_FONT: number = 21;
const SF_CLOSE_SPAN: number = 15.6;
const SF_CLOSE_STROKE: number = 1.7;
const SF_CLOSE_PAD_RIGHT: number = 24.9;
const SF_CLOSE_OFFSET_Y: number = 5.5;

/** 左侧分类栏：宽 91.6vp，选中项行高 42vp，灰色面板 120.7～596.9vp */
const SF_TAB_COLUMN_WIDTH: number = 91.6;
const SF_TAB_SELECTED_HEIGHT: number = 42;
const SF_TAB_PLATE_MARGIN_TOP: number = 10.7;
const SF_TAB_PLATE_HEIGHT: number = 476.2;
const SF_TAB_PLATE_RADIUS: number = 7;
const SF_TAB_ITEM_HEIGHT: number = 61.3;
const SF_TAB_FONT: number = 16;
const SF_TAB_PAD_LEFT: number = 14.2;
const SF_TAB_DOT_SIZE: number = 3.6;
const SF_TAB_DOT_PAD_LEFT: number = 6.2;
const SF_TAB_DOT_GAP: number = 4.7;

/** 右侧选项区：距左栏 19.3vp、右边距 21.8vp、上内边距 12vp（分组标题行高 24vp） */
const SF_OPTION_PAD_LEFT: number = 19.3;
const SF_OPTION_PAD_RIGHT: number = 21.8;
const SF_OPTION_PAD_TOP: number = 12;

/** 选项网格：两列、列间距 9.1vp */
const SF_OPTION_COLUMNS: number = 2;
const SF_OPTION_COLUMN_GAP: number = 9.1;

/** 分组：标题行高 24vp、字 16vp；标题到选项 9.4vp、选项高 36.7vp、行距 9.4vp、组间距 20.7vp */
const SF_GROUP_TITLE_HEIGHT: number = 24;
const SF_GROUP_TITLE_FONT: number = 16;
const SF_GROUP_TITLE_GAP: number = 9.4;
const SF_OPTION_HEIGHT: number = 36.7;
const SF_OPTION_GAP: number = 9.4;
const SF_GROUP_GAP: number = 20.7;
const SF_OPTION_RADIUS: number = 4;
const SF_OPTION_FONT: number = 16;

/** 底部操作栏：上内边距 15.3vp、左右留白 23.6vp、按钮间隔 8.4vp、按钮字 19vp */
const SF_ACTION_PAD_TOP: number = 15.3;
const SF_ACTION_PAD_SIDE: number = 23.6;
const SF_ACTION_GAP: number = 8.4;
const SF_ACTION_BUTTON_HEIGHT: number = 53.8;
const SF_ACTION_FONT: number = 19;

/** 配色：选项 / 分类面板底色 #F2F6F9，选项文字 #4C4D4F，品牌橙 #FF6400 */
const SF_PLATE_BG: string = '#F2F6F9';
const SF_OPTION_TEXT: string = '#4C4D4F';
const SF_TITLE_TEXT: string = '#1A1A1A';
const SF_BRAND_ORANGE: string = '#FF6400';
const SF_DIVIDER_COLOR: string = '#F0F0F0';
const SF_CLEAR_BORDER: string = '#DDDDDD';

interface FlightFilterOption {
  /** 「分类/选项」唯一键：不同分类下的同名选项互不影响 */
  optionKey: string;
  optionLabel: string;
}

interface FlightFilterGroup {
  groupKey: string;
  groupTitle: string;
  groupOptions: FlightFilterOption[];
}

interface FlightFilterGroupSeed {
  groupKey: string;
  groupTitle: string;
  optionLabels: string[];
}

/** 右侧按分类竖排；左侧分类栏的条目也来自这张表 */
const FLIGHT_FILTER_SEEDS: FlightFilterGroupSeed[] = [
  {
    groupKey: 'route',
    groupTitle: '航程类型',
    optionLabels: ['仅看直飞']
  },
  {
    groupKey: 'depart-time',
    groupTitle: '起飞时间',
    optionLabels: ['00:00-06:00', '06:00-12:00', '12:00-18:00', '18:00-24:00']
  },
  {
    groupKey: 'arrive-time',
    groupTitle: '到达时间',
    optionLabels: ['00:00-06:00', '06:00-12:00', '12:00-18:00', '18:00-24:00']
  },
  {
    groupKey: 'airline',
    groupTitle: '航空公司',
    optionLabels: ['中国国航', '海航旗下金鹏航空', '中国联合航空', '海南航空', '南方航空', '厦门航空']
  },
  {
    groupKey: 'airport',
    groupTitle: '机场',
    optionLabels: ['浦东国际机场', '虹桥国际机场', '首都国际机场', '大兴国际机场']
  },
  {
    groupKey: 'aircraft',
    groupTitle: '机型',
    optionLabels: ['空客A320', '空客A330', '波音737', '波音787']
  },
  {
    groupKey: 'cabin',
    groupTitle: '舱位',
    optionLabels: ['经济舱', '公务舱', '头等舱', '超级经济舱']
  }
];

/** 把「分类 + 选项名」拼成全局唯一的选项键 */
function buildFlightFilterGroups(): FlightFilterGroup[] {
  const groups: FlightFilterGroup[] = [];
  for (const seed of FLIGHT_FILTER_SEEDS) {
    const options: FlightFilterOption[] = [];
    for (const optionLabel of seed.optionLabels) {
      options.push({
        optionKey: seed.groupKey + '/' + optionLabel,
        optionLabel: optionLabel
      });
    }
    groups.push({
      groupKey: seed.groupKey,
      groupTitle: seed.groupTitle,
      groupOptions: options
    });
  }
  return groups;
}

const FLIGHT_FILTER_GROUPS: FlightFilterGroup[] = buildFlightFilterGroups();

interface FlightFilterTab {
  tabKey: string;
  tabTitle: string;
  /** 该分类下已有选中的选项，左侧打橙点 */
  tabMarked: boolean;
}

@Component
export struct FlightFilterStatusBarPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽度（vp），随折叠 / 旋转实时更新；面板缩放比由它算出 */
  @State winWidthVp: number = SF_BASE_WIDTH;

  /** 左侧栏当前高亮的分类 */
  @State activeGroupKey: string = 'route';

  /** 已勾选的选项键（默认勾了「舱位 / 经济舱」，左侧「舱位」因此带橙点） */
  @State selectedOptions: string[] = ['cabin/经济舱'];

  private contentScroller: Scroller = new Scroller();
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
      this.windowToken = WindowModeController.acquire(win, '#000000');
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  /** 面板缩放比：窗口宽度 / 单屏态宽度（459.6vp） */
  private panelScale(): number {
    if (this.winWidthVp <= 0) {
      return 1;
    }
    return this.winWidthVp / SF_BASE_WIDTH;
  }

  /** 把按单屏态量出的设计值换算到当前窗口 */
  private sf(baseVp: number): number {
    return baseVp * this.panelScale();
  }

  // ------------------------------------------------------------------
  // 数据换算
  // ------------------------------------------------------------------

  /** 选项列宽：右侧可用宽度按两列均分 */
  private optionColumnWidthVp(): number {
    const contentWidth: number = SF_PANEL_WIDTH - SF_TAB_COLUMN_WIDTH - SF_OPTION_PAD_LEFT - SF_OPTION_PAD_RIGHT;
    return (contentWidth - SF_OPTION_COLUMN_GAP * (SF_OPTION_COLUMNS - 1)) / SF_OPTION_COLUMNS;
  }

  private groupRowCount(group: FlightFilterGroup): number {
    return Math.ceil(group.groupOptions.length / SF_OPTION_COLUMNS);
  }

  /** 一个分组连同下方间距占的高度（设计值） */
  private groupBlockHeightVp(group: FlightFilterGroup): number {
    const rows: number = this.groupRowCount(group);
    return SF_GROUP_TITLE_HEIGHT + SF_GROUP_TITLE_GAP + rows * SF_OPTION_HEIGHT +
      (rows - 1) * SF_OPTION_GAP + SF_GROUP_GAP;
  }

  /** 分组在右侧滚动区里的纵向偏移（设计值） */
  private groupOffsetVp(groupKey: string): number {
    let offset: number = SF_OPTION_PAD_TOP;
    for (const group of FLIGHT_FILTER_GROUPS) {
      if (group.groupKey === groupKey) {
        break;
      }
      offset += this.groupBlockHeightVp(group);
    }
    return offset;
  }

  private activeGroupTitle(): string {
    const activeKey: string = this.activeGroupKey;
    for (const group of FLIGHT_FILTER_GROUPS) {
      if (group.groupKey === activeKey) {
        return group.groupTitle;
      }
    }
    return FLIGHT_FILTER_GROUPS[0].groupTitle;
  }

  private hasSelectedOption(group: FlightFilterGroup): boolean {
    const selected: string[] = this.selectedOptions;
    for (const option of group.groupOptions) {
      if (selected.indexOf(option.optionKey) >= 0) {
        return true;
      }
    }
    return false;
  }

  /** 左侧灰色面板里的分类：除当前高亮项以外的全部分类 */
  private inactiveTabs(): FlightFilterTab[] {
    const activeKey: string = this.activeGroupKey;
    const tabs: FlightFilterTab[] = [];
    for (const group of FLIGHT_FILTER_GROUPS) {
      if (group.groupKey === activeKey) {
        continue;
      }
      tabs.push({
        tabKey: group.groupKey,
        tabTitle: group.groupTitle,
        tabMarked: this.hasSelectedOption(group)
      });
    }
    return tabs;
  }

  private isOptionSelected(option: FlightFilterOption): boolean {
    return this.selectedOptions.indexOf(option.optionKey) >= 0;
  }

  private selectGroup(groupKey: string): void {
    this.activeGroupKey = groupKey;
    this.contentScroller.scrollTo({
      xOffset: 0,
      yOffset: this.sf(this.groupOffsetVp(groupKey)),
      animation: { duration: 200 }
    });
  }

  private toggleOption(option: FlightFilterOption): void {
    const nextOptions: string[] = [];
    let removed: boolean = false;
    for (const optionKey of this.selectedOptions) {
      if (optionKey === option.optionKey) {
        removed = true;
      } else {
        nextOptions.push(optionKey);
      }
    }
    if (!removed) {
      nextOptions.push(option.optionKey);
    }
    this.selectedOptions = nextOptions;
  }

  // ------------------------------------------------------------------
  // 顶部标题行
  // ------------------------------------------------------------------

  /** 关闭 ×：两条斜向笔画叠成，笔画长 = 外接方框 × √2 − 笔画粗细 */
  @Builder
  closeButton() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(this.sf(SF_CLOSE_SPAN * 1.414 - SF_CLOSE_STROKE))
        .height(this.sf(SF_CLOSE_STROKE))
        .backgroundColor(SF_TITLE_TEXT)
        .rotate({ angle: 45 })

      Row()
        .width(this.sf(SF_CLOSE_SPAN * 1.414 - SF_CLOSE_STROKE))
        .height(this.sf(SF_CLOSE_STROKE))
        .backgroundColor(SF_TITLE_TEXT)
        .rotate({ angle: -45 })
    }
    .width(this.sf(SF_CLOSE_SPAN + 8))
    .height(this.sf(SF_CLOSE_SPAN + 8))
    .offset({ y: this.sf(SF_CLOSE_OFFSET_Y) })
    .onClick(() => {
      this.pageStack.pop();
    })
  }

  @Builder
  headerBar() {
    Stack({ alignContent: Alignment.Center }) {
      Text('筛选')
        .fontSize(this.sf(SF_TITLE_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(SF_TITLE_TEXT)

      Row() {
        Blank()

        this.closeButton()
      }
      .width('100%')
      .height('100%')
      .padding({ right: this.sf(SF_CLOSE_PAD_RIGHT) })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(this.sf(SF_HEADER_HEIGHT))
  }

  // ------------------------------------------------------------------
  // 左侧分类栏
  // ------------------------------------------------------------------

  /** 灰色面板里的一个分类：有选中选项的分类左侧打橙点 */
  @Builder
  plateTabRow(tab: FlightFilterTab) {
    Row({ space: this.sf(SF_TAB_DOT_GAP) }) {
      if (tab.tabMarked) {
        Row()
          .width(this.sf(SF_TAB_DOT_SIZE))
          .height(this.sf(SF_TAB_DOT_SIZE))
          .backgroundColor(SF_BRAND_ORANGE)
          .borderRadius(this.sf(SF_TAB_DOT_SIZE / 2))
      }

      Text(tab.tabTitle)
        .fontSize(this.sf(SF_TAB_FONT))
        .fontColor(SF_TITLE_TEXT)
    }
    .width('100%')
    .height(this.sf(SF_TAB_ITEM_HEIGHT))
    .padding({ left: this.sf(tab.tabMarked ? SF_TAB_DOT_PAD_LEFT : SF_TAB_PAD_LEFT) })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.selectGroup(tab.tabKey);
    })
  }

  @Builder
  tabColumn() {
    Column() {
      // 当前高亮的分类：落在白色区域，不在灰色面板里
      Row() {
        Text(this.activeGroupTitle())
          .fontSize(this.sf(SF_TAB_FONT))
          .fontColor(SF_BRAND_ORANGE)
          .maxLines(1)
      }
      .width('100%')
      .height(this.sf(SF_TAB_SELECTED_HEIGHT))
      .padding({ left: this.sf(SF_TAB_PAD_LEFT) })
      .alignItems(VerticalAlign.Center)

      Column() {
        ForEach(this.inactiveTabs(), (tab: FlightFilterTab) => {
          this.plateTabRow(tab)
        }, (tab: FlightFilterTab) => tab.tabKey + (tab.tabMarked ? '#dot' : ''))
      }
      .width('100%')
      .height(this.sf(SF_TAB_PLATE_HEIGHT))
      .margin({ top: this.sf(SF_TAB_PLATE_MARGIN_TOP) })
      .backgroundColor(SF_PLATE_BG)
      .borderRadius(this.sf(SF_TAB_PLATE_RADIUS))
      .clip(true)
      .alignItems(HorizontalAlign.Start)
    }
    .width(this.sf(SF_TAB_COLUMN_WIDTH))
    .height(this.sf(SF_BODY_HEIGHT))
  }

  // ------------------------------------------------------------------
  // 右侧选项区
  // ------------------------------------------------------------------

  @Builder
  optionChip(option: FlightFilterOption) {
    Text(option.optionLabel)
      .fontSize(this.sf(SF_OPTION_FONT))
      .fontColor(this.isOptionSelected(option) ? SF_BRAND_ORANGE : SF_OPTION_TEXT)
      .backgroundColor(this.isOptionSelected(option) ? '#FFF1E8' : SF_PLATE_BG)
      .width(this.sf(this.optionColumnWidthVp()))
      .height(this.sf(SF_OPTION_HEIGHT))
      .textAlign(TextAlign.Center)
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .borderRadius(this.sf(SF_OPTION_RADIUS))
      .margin({ bottom: this.sf(SF_OPTION_GAP) })
      .onClick(() => {
        this.toggleOption(option);
      })
  }

  @Builder
  optionGroup(group: FlightFilterGroup) {
    Column() {
      Text(group.groupTitle)
        .fontSize(this.sf(SF_GROUP_TITLE_FONT))
        .fontWeight(FontWeight.Medium)
        .fontColor(SF_TITLE_TEXT)
        .height(this.sf(SF_GROUP_TITLE_HEIGHT))

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
        ForEach(group.groupOptions, (option: FlightFilterOption) => {
          this.optionChip(option)
        }, (option: FlightFilterOption) => option.optionKey + (this.isOptionSelected(option) ? '#on' : '#off'))
      }
      .width('100%')
      .margin({ top: this.sf(SF_GROUP_TITLE_GAP) })
    }
    .width('100%')
    .margin({ bottom: this.sf(SF_GROUP_GAP - SF_OPTION_GAP) })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  optionPane() {
    Scroll(this.contentScroller) {
      Column() {
        ForEach(FLIGHT_FILTER_GROUPS, (group: FlightFilterGroup) => {
          this.optionGroup(group)
        }, (group: FlightFilterGroup) => group.groupKey)
      }
      .width('100%')
      .padding({
        left: this.sf(SF_OPTION_PAD_LEFT),
        right: this.sf(SF_OPTION_PAD_RIGHT),
        top: this.sf(SF_OPTION_PAD_TOP)
      })
      .alignItems(HorizontalAlign.Start)
    }
    .layoutWeight(1)
    .height('100%')
    .scrollBar(BarState.Off)
    .align(Alignment.Top)
  }

  @Builder
  bodyArea() {
    Row() {
      this.tabColumn()

      this.optionPane()
    }
    .width('100%')
    .height(this.sf(SF_BODY_HEIGHT))
    .alignItems(VerticalAlign.Top)
  }

  // ------------------------------------------------------------------
  // 底部操作栏
  // ------------------------------------------------------------------

  @Builder
  actionDivider() {
    Row()
      .width('100%')
      .height(this.sf(SF_DIVIDER_HEIGHT))
      .backgroundColor(SF_DIVIDER_COLOR)
  }

  @Builder
  actionBar() {
    Row({ space: this.sf(SF_ACTION_GAP) }) {
      Text('清空')
        .fontSize(this.sf(SF_ACTION_FONT))
        .fontColor('#3A3A3A')
        .layoutWeight(1)
        .height(this.sf(SF_ACTION_BUTTON_HEIGHT))
        .textAlign(TextAlign.Center)
        .backgroundColor(Color.White)
        .border({ width: 1, color: SF_CLEAR_BORDER })
        .borderRadius(this.sf(SF_ACTION_BUTTON_HEIGHT / 2))
        .onClick(() => {
          this.selectedOptions = [];
        })

      Text('确定')
        .fontSize(this.sf(SF_ACTION_FONT))
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .layoutWeight(1)
        .height(this.sf(SF_ACTION_BUTTON_HEIGHT))
        .textAlign(TextAlign.Center)
        .backgroundColor(SF_BRAND_ORANGE)
        .borderRadius(this.sf(SF_ACTION_BUTTON_HEIGHT / 2))
        .onClick(() => {
          this.pageStack.pop();
        })
    }
    .width('100%')
    .height(this.sf(SF_ACTION_BAR_HEIGHT))
    .padding({
      left: this.sf(SF_ACTION_PAD_SIDE),
      right: this.sf(SF_ACTION_PAD_SIDE),
      top: this.sf(SF_ACTION_PAD_TOP)
    })
    .alignItems(VerticalAlign.Top)
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column() {
          this.headerBar()
          this.bodyArea()
          this.actionDivider()
          this.actionBar()
        }
        .width(this.sf(SF_PANEL_WIDTH))
        .height(this.sf(SF_PANEL_HEIGHT))
        .backgroundColor(Color.White)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.White)
      .onAreaChange((oldArea: Area, newArea: Area) => {
        if (typeof newArea.width === 'number' && newArea.width > 0) {
          this.winWidthVp = newArea.width;
        }
      })
    }
    .hideTitleBar(true)
  }
}
