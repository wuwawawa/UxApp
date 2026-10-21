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
 * 反例：截断 / 车站大屏表格行溢出（文字溢出重叠）
 *
 * 复刻对象：北京南站「车站大屏」横屏页 —— 浅蓝渐变底、左上返回「‹」、超大标题「北京南站」+ ▾、
 *   灰色免责小字、白色圆角搜索框（放大镜 + 「请输入车次号」），下面是
 *   车次 / 终到站 / 发车 / 检票口 / 状态 五列表格（白与极浅蓝交替的行），
 *   底部居中浮着一枚白色「候车」胶囊和一行「11:58」小字。
 *
 * 设计基准（vp 量测值）：参考截图 3184×2232px，密度 2.75，vp = px / 2.75 → 1157.8×811.6vp：
 *   返回「‹」墨迹 26.5×16.4vp（左 50.9、上 83.3）；标题「北京南站」墨迹 109.5×26.5vp
 *   （左 50.9、上 136）；▾ 三角 53.1×20vp（左 163.6）；免责小字墨迹高 12.4vp（上 202.5）；
 *   搜索框 左 50.9 / 上 229 / 宽 1056.4 / 高 45.5 / 圆角 22.7vp，占位字 14.5vp；
 *   表头带宽 40.7vp（上 281.5）；列起点 车次 62.5 / 终到站 241.5 / 发车 488.7 / 检票口 692.4，
 *   状态列文字右端 1114.2vp；单元格字 13vp / 行距 19vp；
 *   数据行高 50.2vp（138px），共 11 行，白 / #F2F9FF 交替；
 *   检票口列宽固定 200vp，两行 13vp 字、行距 44vp（量到两行字的墨迹几乎压在一起）；
 *   状态字 40vp（墨迹 35.6vp）、行高 56vp，绿 #2DCA55 / 灰 #8C8C8C；
 *   底部浮动胶囊 宽 251 / 高 50 / 圆角 25vp，下沿距屏底 44.6vp，「候车」14.5vp 蓝字。
 *
 * 三态实测（按本页布局推算）：
 *   单屏态        459.6×672vp   —— 整列按 0.397 缩到 347vp 高，表格只占上半屏；
 *   双屏态竖屏    664.7×939.6vp —— 整列按 0.574 缩到 502vp 高，表格右侧留白；
 *   双屏态横屏    939.6×664.7vp —— 整列按 0.812 缩到 710vp 高，表格下沿被窗口切掉。
 *
 * 问题表现：
 *   检票口一格里塞着两行长字，两行之间只隔 44vp、比 50.2vp 的行还高，
 *   上一行第二行字压到下一行第一行字上，整列看不出哪一行是哪一行的；
 *   状态列 40vp 的大字（正在检票 / 候车）行高 56vp，比 50.2vp 的行还高，
 *   绿字与灰字上下只隔 14.6vp，行界被字顶满，浅蓝条纹整条被字压住；
 *   底部白色「候车」胶囊浮在表格上，把 G303 / C2229 两行的检票口与状态整段盖住。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 参考截图 3184×2232px / 2.75 = 1157.8×811.6vp，页面按它 1:1 复刻 */
const SBO_REFERENCE_WIDTH: number = 1157.8;
const SBO_REFERENCE_HEIGHT: number = 811.6;

/** 状态栏 / 底部手势区兜底高度（vp），拿不到避让区时使用 */
const SBO_STATUS_BAR_FALLBACK: number = 32;
const SBO_BOTTOM_INSET_FALLBACK: number = 8;

const SBO_BG_TOP: string = '#C3ECFF';
const SBO_BG_MID: string = '#DDF0FE';
const SBO_BG_BOTTOM: string = '#F2F5F8';
const SBO_TEXT_MAIN: string = '#333333';
const SBO_TEXT_SUB: string = '#8C8C8C';
const SBO_PLACEHOLDER: string = '#A9B4BF';
const SBO_SEARCH_BG: string = '#EDF6FF';
const SBO_ICON_GRAY: string = '#C2CBD5';
const SBO_HEAD_BG: string = '#F1F5F8';
const SBO_STRIPE: string = '#F2F9FF';
const SBO_GATE_TEXT: string = '#8E8E8E';
const SBO_GREEN: string = '#2DCA55';
const SBO_GRAY: string = '#8C8C8C';
const SBO_PILL_TEXT: string = '#3581CD';
const SBO_TIME_TEXT: string = '#5A6B7C';

/** 头部：返回「‹」墨迹上沿 83.3vp、标题墨迹上沿 136vp、免责小字上沿 202.5vp */
const SBO_BACK_LEFT: number = 46;
const SBO_BACK_TOP: number = 68;
const SBO_BACK_FONT: number = 46;
const SBO_TITLE_LEFT: number = 50.9;
const SBO_TITLE_TOP: number = 131.3;
const SBO_TITLE_FONT: number = 30;
const SBO_TRIANGLE_LEFT: number = 163.6;
const SBO_TRIANGLE_TOP: number = 133;
const SBO_TRIANGLE_FONT: number = 26;
const SBO_SUBTITLE_LEFT: number = 50.9;
const SBO_SUBTITLE_TOP: number = 199;
const SBO_SUBTITLE_FONT: number = 14;
const SBO_SUBTITLE_WIDTH: number = 320;

/** 搜索框：左 50.9 / 宽 1056.4 / 高 45.5 / 圆角 22.7vp；放大镜 18vp；占位字左 164vp */
const SBO_SEARCH_LEFT: number = 50.9;
const SBO_SEARCH_TOP: number = 229;
const SBO_SEARCH_WIDTH: number = 1056.4;
const SBO_SEARCH_HEIGHT: number = 45.5;
const SBO_SEARCH_RADIUS: number = 22.75;
const SBO_SEARCH_ICON_LEFT: number = 105;
const SBO_SEARCH_ICON_SIZE: number = 18;
const SBO_PLACEHOLDER_LEFT: number = 164;
const SBO_PLACEHOLDER_FONT: number = 14.5;

/** 表格：表头上沿 281.5vp、高 40.7vp；数据行高 50.2vp（138px），状态字行高 56vp */
const SBO_HEAD_TOP: number = 281.5;
const SBO_HEAD_HEIGHT: number = 40.7;
const SBO_HEAD_FONT: number = 13;
const SBO_COL_TRAIN: number = 62.5;
const SBO_COL_TERMINUS: number = 241.5;
const SBO_COL_DEPART: number = 488.7;
const SBO_COL_GATE: number = 692.4;
const SBO_COL_STATUS_LEFT: number = 934.2;
const SBO_COL_STATUS_WIDTH: number = 180;
const SBO_STATUS_LABEL_LEFT: number = 1074.2;
const SBO_STATUS_LABEL_WIDTH: number = 40;
const SBO_ROW_HEIGHT: number = 50.2;
const SBO_CELL_FONT: number = 13;
const SBO_CELL_LINE_HEIGHT: number = 19;
const SBO_CELL_TOP: number = 15.6;
const SBO_GATE_WIDTH: number = 200;
const SBO_GATE_LINE_HEIGHT: number = 44;
const SBO_GATE_TOP: number = 4;
const SBO_STATUS_FONT: number = 40;
const SBO_STATUS_LINE_HEIGHT: number = 56;
const SBO_STATUS_TOP: number = -3;

/** 底部浮动胶囊：宽 251 / 高 50vp，下沿距屏底 44.6vp；「11:58」小字在它下面 */
const SBO_PILL_WIDTH: number = 251;
const SBO_PILL_HEIGHT: number = 50;
const SBO_PILL_FONT: number = 14.5;
const SBO_PILL_BOTTOM: number = 44.6;
const SBO_TIME_FONT: number = 11;
const SBO_TIME_LINE_HEIGHT: number = 13;
const SBO_TIME_GAP: number = 8;

/** 大屏上的一行车次信息 */
interface SboBoardRow {
  trainNo: string;
  terminus: string;
  departAt: string;
  gateText: string;
  statusText: string;
  checking: boolean;
}

@Component
export struct StationBoardOverflowPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = SBO_REFERENCE_WIDTH;
  @State winHeightVp: number = SBO_REFERENCE_HEIGHT;
  /** 沉浸式下的状态栏 / 底部手势区高度（vp） */
  @State statusBarHeightVp: number = SBO_STATUS_BAR_FALLBACK;
  @State bottomInsetVp: number = SBO_BOTTOM_INSET_FALLBACK;

  private pageActive: boolean = false;
  private windowToken: number = 0;

  private boardRows: SboBoardRow[] = [
    {
      trainNo: 'G1087', terminus: '烟台', departAt: '11:22',
      gateText: '地下一层2快速进站厅10、11检票口，高架层', statusText: '正在检票', checking: true
    },
    {
      trainNo: 'C2225', terminus: '天津', departAt: '11:26',
      gateText: '地下二层2快速进站厅22、23检票口，高架层', statusText: '正在检票', checking: true
    },
    {
      trainNo: 'G131', terminus: '上海虹桥', departAt: '11:27',
      gateText: '地下二层3快速进站厅18、19检票口，高架层', statusText: '正在检票', checking: true
    },
    {
      trainNo: 'C2011', terminus: '天津', departAt: '11:37',
      gateText: '地下二层4快速进站厅20、21检票口，高架层', statusText: '候车', checking: false
    },
    {
      trainNo: 'C2227', terminus: '天津', departAt: '11:42',
      gateText: '地下二层4快速进站厅20、21检票口，高架层', statusText: '候车', checking: false
    },
    {
      trainNo: 'G1067', terminus: '青岛', departAt: '11:45',
      gateText: '地下二层2快速进站厅8、9检票口，高架层', statusText: '候车', checking: false
    },
    {
      trainNo: 'G133', terminus: '上海', departAt: '11:50',
      gateText: '地下一层2快速进站厅10、11检票口，高架层', statusText: '候车', checking: false
    },
    {
      trainNo: 'C2109', terminus: '天津西', departAt: '11:52',
      gateText: '地下一层2快速进站厅10、11检票口，高架层', statusText: '候车', checking: false
    },
    {
      trainNo: 'G303', terminus: '福州', departAt: '11:55',
      gateText: '到达', statusText: '候车', checking: false
    },
    {
      trainNo: 'C2229', terminus: '天津', departAt: '11:58',
      gateText: '地下一层2快速进站厅22、23检票口，高架层', statusText: '候车', checking: false
    },
    {
      trainNo: 'G1071', terminus: '天津', departAt: '12:00',
      gateText: '地下一层2快速进站厅10、11检票口，高架层', statusText: '候车', checking: false
    }
  ];

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
      this.windowToken = WindowModeController.acquire(win, '#333333');
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  /** 内容列宽度：参考设计宽 1157.8vp，窗口更宽时保持原宽并居中，更窄时整体缩小 */
  private pageWidth(): number {
    return Math.min(this.winWidthVp, SBO_REFERENCE_WIDTH);
  }

  /** 把 1157.8vp 参考宽下的设计值换算到当前内容列宽度 */
  private s(baseVp: number): number {
    return baseVp * this.pageWidth() / SBO_REFERENCE_WIDTH;
  }

  @Builder
  searchIcon() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column()
        .width(this.s(13))
        .height(this.s(13))
        .border({ width: this.s(1.8), color: SBO_ICON_GRAY })
        .borderRadius(this.s(6.5))

      Row()
        .width(this.s(6.5))
        .height(this.s(1.8))
        .backgroundColor(SBO_ICON_GRAY)
        .rotate({ angle: 45 })
        .position({ x: this.s(10.5), y: this.s(13.5) })
    }
    .width(this.s(SBO_SEARCH_ICON_SIZE))
    .height(this.s(SBO_SEARCH_ICON_SIZE))
    .position({ x: this.s(SBO_SEARCH_ICON_LEFT), y: this.s(13.75) })
  }

  @Builder
  pageHeader() {
    Stack({ alignContent: Alignment.TopStart }) {
      Text('‹')
        .fontSize(this.s(SBO_BACK_FONT))
        .fontColor(SBO_TEXT_MAIN)
        .lineHeight(this.s(SBO_BACK_FONT))
        .position({ x: this.s(SBO_BACK_LEFT), y: this.s(SBO_BACK_TOP) })
        .onClick(() => {
          this.pageStack.pop();
        })

      Text('北京南站')
        .fontSize(this.s(SBO_TITLE_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(SBO_TEXT_MAIN)
        .lineHeight(this.s(SBO_TITLE_FONT + 6))
        .position({ x: this.s(SBO_TITLE_LEFT), y: this.s(SBO_TITLE_TOP) })

      Text('▾')
        .fontSize(this.s(SBO_TRIANGLE_FONT))
        .fontColor(SBO_TEXT_MAIN)
        .lineHeight(this.s(SBO_TRIANGLE_FONT + 4))
        .position({ x: this.s(SBO_TRIANGLE_LEFT), y: this.s(SBO_TRIANGLE_TOP) })

      Text('以下信息仅供参考，实际信息以车站公告为准')
        .fontSize(this.s(SBO_SUBTITLE_FONT))
        .fontColor(SBO_TEXT_SUB)
        .lineHeight(this.s(SBO_SUBTITLE_FONT + 5))
        .width(this.s(SBO_SUBTITLE_WIDTH))
        .maxLines(1)
        .position({ x: this.s(SBO_SUBTITLE_LEFT), y: this.s(SBO_SUBTITLE_TOP) })
    }
    .width('100%')
    .height(this.s(SBO_SEARCH_TOP))
  }

  @Builder
  searchBar() {
    Stack({ alignContent: Alignment.TopStart }) {
      Row()
        .width(this.s(SBO_SEARCH_WIDTH))
        .height(this.s(SBO_SEARCH_HEIGHT))
        .backgroundColor(SBO_SEARCH_BG)
        .borderRadius(this.s(SBO_SEARCH_RADIUS))
        .border({ width: this.s(2.2), color: Color.White })
        .position({ x: this.s(SBO_SEARCH_LEFT), y: 0 })

      this.searchIcon()

      Text('请输入车次号')
        .fontSize(this.s(SBO_PLACEHOLDER_FONT))
        .fontColor(SBO_PLACEHOLDER)
        .lineHeight(this.s(SBO_PLACEHOLDER_FONT + 5))
        .position({ x: this.s(SBO_PLACEHOLDER_LEFT), y: this.s(15) })
    }
    .width('100%')
    .height(this.s(SBO_SEARCH_HEIGHT))
  }

  @Builder
  tableHeader() {
    Stack({ alignContent: Alignment.TopStart }) {
      Text('车次')
        .fontSize(this.s(SBO_HEAD_FONT))
        .fontColor(SBO_TEXT_MAIN)
        .lineHeight(this.s(SBO_CELL_LINE_HEIGHT))
        .position({ x: this.s(SBO_COL_TRAIN), y: this.s(10.85) })

      Text('终到站')
        .fontSize(this.s(SBO_HEAD_FONT))
        .fontColor(SBO_TEXT_MAIN)
        .lineHeight(this.s(SBO_CELL_LINE_HEIGHT))
        .position({ x: this.s(SBO_COL_TERMINUS), y: this.s(10.85) })

      Text('发车')
        .fontSize(this.s(SBO_HEAD_FONT))
        .fontColor(SBO_TEXT_MAIN)
        .lineHeight(this.s(SBO_CELL_LINE_HEIGHT))
        .position({ x: this.s(SBO_COL_DEPART), y: this.s(10.85) })

      Text('检票口')
        .fontSize(this.s(SBO_HEAD_FONT))
        .fontColor(SBO_TEXT_MAIN)
        .lineHeight(this.s(SBO_CELL_LINE_HEIGHT))
        .position({ x: this.s(SBO_COL_GATE), y: this.s(10.85) })

      Text('状态')
        .fontSize(this.s(SBO_HEAD_FONT))
        .fontColor(SBO_TEXT_MAIN)
        .lineHeight(this.s(SBO_CELL_LINE_HEIGHT))
        .width(this.s(SBO_STATUS_LABEL_WIDTH))
        .maxLines(1)
        .textAlign(TextAlign.End)
        .position({ x: this.s(SBO_STATUS_LABEL_LEFT), y: this.s(10.85) })
    }
    .width('100%')
    .height(this.s(SBO_HEAD_HEIGHT))
    .backgroundColor(SBO_HEAD_BG)
  }

  @Builder
  boardStripes() {
    Column() {
      ForEach(this.boardRows, (stripeRow: SboBoardRow, stripeIdx: number) => {
        Row()
          .width('100%')
          .height(this.s(SBO_ROW_HEIGHT))
          .backgroundColor(stripeIdx % 2 === 0 ? '#FFFFFF' : SBO_STRIPE)
      }, (stripeRow: SboBoardRow) => 'sbo-stripe-' + stripeRow.trainNo + stripeRow.departAt)
    }
    .width('100%')
  }

  @Builder
  boardRow(rowItem: SboBoardRow) {
    Stack({ alignContent: Alignment.TopStart }) {
      Text(rowItem.trainNo)
        .fontSize(this.s(SBO_CELL_FONT))
        .fontColor(SBO_TEXT_MAIN)
        .lineHeight(this.s(SBO_CELL_LINE_HEIGHT))
        .position({ x: this.s(SBO_COL_TRAIN), y: this.s(SBO_CELL_TOP) })

      Text(rowItem.terminus)
        .fontSize(this.s(SBO_CELL_FONT))
        .fontColor(SBO_TEXT_MAIN)
        .lineHeight(this.s(SBO_CELL_LINE_HEIGHT))
        .position({ x: this.s(SBO_COL_TERMINUS), y: this.s(SBO_CELL_TOP) })

      Text(rowItem.departAt)
        .fontSize(this.s(SBO_CELL_FONT))
        .fontColor(SBO_TEXT_MAIN)
        .lineHeight(this.s(SBO_CELL_LINE_HEIGHT))
        .position({ x: this.s(SBO_COL_DEPART), y: this.s(SBO_CELL_TOP) })

      Text(rowItem.gateText)
        .fontSize(this.s(SBO_CELL_FONT))
        .fontColor(SBO_GATE_TEXT)
        .lineHeight(this.s(SBO_GATE_LINE_HEIGHT))
        .width(this.s(SBO_GATE_WIDTH))
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Clip })
        .position({ x: this.s(SBO_COL_GATE), y: this.s(SBO_GATE_TOP) })

      Text(rowItem.statusText)
        .fontSize(this.s(SBO_STATUS_FONT))
        .fontColor(rowItem.checking ? SBO_GREEN : SBO_GRAY)
        .lineHeight(this.s(SBO_STATUS_LINE_HEIGHT))
        .width(this.s(SBO_COL_STATUS_WIDTH))
        .maxLines(1)
        .textAlign(TextAlign.End)
        .position({ x: this.s(SBO_COL_STATUS_LEFT), y: this.s(SBO_STATUS_TOP) })
    }
    .width('100%')
    .height(this.s(SBO_ROW_HEIGHT))
    .clip(false)
  }

  @Builder
  boardRowsLayer() {
    Column() {
      ForEach(this.boardRows, (rowItem: SboBoardRow) => {
        this.boardRow(rowItem)
      }, (rowItem: SboBoardRow) => 'sbo-row-' + rowItem.trainNo + rowItem.departAt)
    }
    .width('100%')
  }

  @Builder
  boardTable() {
    Column() {
      this.tableHeader()

      Stack({ alignContent: Alignment.TopStart }) {
        this.boardStripes()
        this.boardRowsLayer()
      }
      .width('100%')
      .clip(false)
    }
    .width('100%')
    .margin({ top: this.s(SBO_HEAD_TOP - SBO_SEARCH_TOP - SBO_SEARCH_HEIGHT) })
    .clip(false)
  }

  @Builder
  floatingPill() {
    Column() {
      Row() {
        Text('候车')
          .fontSize(this.s(SBO_PILL_FONT))
          .fontColor(SBO_PILL_TEXT)
      }
      .width(this.s(SBO_PILL_WIDTH))
      .height(this.s(SBO_PILL_HEIGHT))
      .backgroundColor(Color.White)
      .borderRadius(this.s(SBO_PILL_HEIGHT / 2))
      .justifyContent(FlexAlign.Center)
      .shadow({ radius: this.s(12), color: '#14000000', offsetX: 0, offsetY: this.s(5) })

      Text('11:58')
        .fontSize(this.s(SBO_TIME_FONT))
        .fontColor(SBO_TIME_TEXT)
        .lineHeight(this.s(SBO_TIME_LINE_HEIGHT))
        .margin({ top: this.s(SBO_TIME_GAP) })
    }
    .width(this.s(SBO_PILL_WIDTH))
    .alignItems(HorizontalAlign.Center)
    .position({
      x: (this.winWidthVp - this.s(SBO_PILL_WIDTH)) / 2,
      y: this.winHeightVp - this.s(SBO_PILL_BOTTOM) - this.s(SBO_PILL_HEIGHT)
    })
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        // 通栏浅蓝渐变底：顶部偏蓝，往下逐渐接近白
        Row()
          .width('100%')
          .height('100%')
          .linearGradient({
            angle: 180,
            colors: [[SBO_BG_TOP, 0.0], [SBO_BG_MID, 0.42], [SBO_BG_BOTTOM, 1.0]]
          })

        // 通栏右侧压白：参考图里同一高度上右边比左边更白
        Row()
          .width('100%')
          .height('100%')
          .linearGradient({
            angle: 90,
            colors: [['#00FFFFFF', 0.0], ['#B3FFFFFF', 0.58], ['#D9FFFFFF', 1.0]]
          })

        Row() {
          Column() {
            this.pageHeader()
            this.searchBar()
            this.boardTable()
          }
          .width(this.pageWidth())
          .alignItems(HorizontalAlign.Start)
          .clip(false)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Top)

        this.floatingPill()
      }
      .width('100%')
      .height('100%')
      .clip(true)
      .backgroundColor(SBO_BG_BOTTOM)
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
