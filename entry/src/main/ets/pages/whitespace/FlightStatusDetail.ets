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
 * 复刻对象：深圳航空 App 的「航班动态」详情页，双屏横屏截图（原图 3184×2232px，密度 2.75）。
 *   顶部白色区域：左上返回箭头、整窗居中的航班号「ZH9106」、右上房子图标；
 *   下面一行横向日期条：11-30 星期日（红色描边选中框 + 红字），其后 12-01 星期一 … 12-13 星期六、
 *   12-14 星期日（只露半个日期，被最右侧的日历图标压住），日期之间一条浅灰竖直细线，
 *   最右侧一个日历图标；再往下是白色圆角卡片：左上角裁自截图的红色航司标志 +
 *   「ZH9106 | 空客321」，卡内左右两列「实际起飞 17:06 北京首都T3」与「实际到达 20:10 深圳宝安T3」，
 *   中间「3h4m」灰字 + 绿色描边胶囊「到达」，胶囊两侧各一段浅灰点状虚线；
 *   卡片下方直到窗口底边是一整片浅灰，没有任何后续内容。
 *
 * 设计基准：vp = px / 2.75（截图原图 3184×2232px，密度 2.75，参考窗口 1157.8×811.6vp）。
 *   白色头部 156vp：状态栏留白 44vp；标题行 45.4vp（标题字 17vp、字心 y 66.4vp；
 *     返回箭头外接 8.4×14.9vp、笔画 0.9vp、左缘 21.1vp；房子图标 20vp、右缘距窗口右 19.3vp）；
 *   日期条块 66.6vp（行高 45.8vp、距标题行 12.1vp，日期条左缘 12.4vp）：
 *     选中框 66.5×45.8vp、圆角 4vp、描边 1vp；一格 74.77vp（日期字 15.5vp、星期字 10.5vp、
 *     两行间距 4vp），格内文字列宽 66.5vp；格间竖线 0.5×27.4vp；
 *     日历图标 17vp，图标所在的白色块宽 46vp，图标右缘距窗口右 23.6vp；
 *   卡片：左右各 12.4vp、距头部 12vp、高 136.4vp、圆角 8vp；内边距左右 17.1vp、上 18vp；
 *     航司标志 16.4vp 见方、到航班号 4.3vp、航班号字 13vp；
 *     卡内两列标签 11vp（#8C8C8C）、时间 24vp、机场 12vp；中间「3h4m」12.5vp 灰字 +
 *     胶囊 53.8×23vp（描边 1.5vp、字 14vp），两侧虚线各 36.2vp（点 1.8×1.5vp，一侧 8 个点）；
 *   卡片底边落在 y 304.4vp。
 *
 * 三态实测（以上 vp 值原样排版，卡片仍是整宽、虚线仍是窗口居中，头部与卡片高度不随窗口缩放；
 *   内容块一律止于 y 304.4vp，所以留白 = 窗口高 − 304.4vp）：
 *   单屏态      459.6×672vp   —— 内容占上方 304.4vp，留白 367.6vp，约占高度的 55%；
 *                                日期条只放得下 6 格（可见宽度 459.6vp − 12.4vp）
 *   双屏态竖屏  664.7×939.6vp —— 留白 635.2vp，约占高度的 68%
 *   双屏态横屏  939.6×664.7vp —— 留白 360.3vp，约占高度的 54%，
 *                                卡片内两列被拉成左右贴边，中间虚线连同胶囊共占 126.2vp
 *   参考窗口    1157.8×811.6vp —— 留白 507.2vp，约占高度的 62%（截图量到的就是这一态）
 *
 * 问题表现：
 *   整页只有上面不到一半的高度里有内容，卡片底边以下直到窗口底边是一整片浅灰色，
 *   没有任何列表、说明或按钮接在后面；窗口越高，这片灰越大，双屏态竖屏时占到高度近七成。
 *   卡片里的「实际起飞 / 实际到达」两列被撑到窗口左右两端，中间只剩一条 126.2vp 的虚线
 *   和一枚「到达」胶囊，横向越宽、列与列之间空得越开，竖向上却不增加任何一行信息；
 *   头部日期条同样顶在窗口最左边，最右侧那个日历图标孤零零贴着右边界。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 配色：浅灰页面底、白头部与白卡片、近黑正文、灰色标签、红色选中、绿色到达 */
const WSFL_PAGE_BG: string = '#F5F6FA';
const WSFL_HEADER_BG: string = '#FFFFFF';
const WSFL_CARD_BG: string = '#FFFFFF';
const WSFL_TEXT_COLOR: string = '#1A1A1A';
const WSFL_WEEK_COLOR: string = '#666666';
const WSFL_LABEL_COLOR: string = '#8C8C8C';
const WSFL_DURATION_COLOR: string = '#8A8D93';
const WSFL_RED: string = '#F0393F';
const WSFL_GREEN: string = '#39C364';
const WSFL_DASH_COLOR: string = '#DDDCE1';
const WSFL_DIVIDER_COLOR: string = '#CDCDCD';

/** 头部：状态栏留白 44vp、标题行 45.4vp、标题字 17vp */
const WSFL_STATUS_BAR_HEIGHT: number = 44;
const WSFL_TITLE_ROW_HEIGHT: number = 45.4;
const WSFL_TITLE_FONT: number = 17;

/** 返回箭头：外接 8.4×14.9vp、笔画 0.9vp；两条斜笔画长 11.2vp、倾角 41.6°、上下各偏 3.73vp */
const WSFL_BACK_TOUCH_WIDTH: number = 26;
const WSFL_BACK_PAD_LEFT: number = 12.4;
const WSFL_BACK_SPAN_W: number = 8.4;
const WSFL_BACK_SPAN_H: number = 14.9;
const WSFL_BACK_STROKE: number = 0.9;
const WSFL_BACK_BAR_LEN: number = 11.2;
const WSFL_BACK_BAR_ANGLE: number = 41.6;
const WSFL_BACK_BAR_GAP: number = 3.73;

/** 右上房子图标：字号 20vp、右缘距窗口右 19.3vp（图标中心落在 1128.5vp） */
const WSFL_HOME_FONT: number = 20;
const WSFL_HOME_PAD_RIGHT: number = 19.3;

/** 日期条：行高 45.8vp、距标题行 12.1vp、行下留 8.7vp（12.1 + 45.8 + 8.7 = 66.6vp 的日期条块）、左缘 12.4vp */
const WSFL_DATE_ROW_HEIGHT: number = 45.8;
const WSFL_DATE_BLOCK_TOP: number = 12.1;
const WSFL_DATE_BLOCK_BOTTOM: number = 8.7;
const WSFL_DATE_PAD_LEFT: number = 12.4;

/** 日期格：一格 74.77vp，格内文字列宽 66.5vp（选中框同宽） */
const WSFL_CELL_WIDTH: number = 74.77;
const WSFL_CELL_CONTENT_WIDTH: number = 66.5;
const WSFL_SELECT_BORDER: number = 1;
const WSFL_SELECT_RADIUS: number = 4;
const WSFL_DATE_DIVIDER_WIDTH: number = 0.5;
const WSFL_DATE_DIVIDER_HEIGHT: number = 27.4;

/** 日期字 15.5vp、星期字 10.5vp，两行间距 4vp */
const WSFL_DATE_FONT: number = 15.5;
const WSFL_WEEK_FONT: number = 10.5;
const WSFL_DATE_TEXT_HEIGHT: number = 18;
const WSFL_WEEK_TEXT_HEIGHT: number = 14;
const WSFL_WEEK_GAP: number = 4;

/** 日历图标：17vp，所在白色块 46vp，图标右缘距窗口右 23.6vp */
const WSFL_CAL_BLOCK_WIDTH: number = 46;
const WSFL_CAL_PAD_RIGHT: number = 23.6;
const WSFL_CAL_ICON_FONT: number = 17;

/** 卡片：左右各 12.4vp、距头部 12vp、高 136.4vp、圆角 8vp、内边距左右 17.1vp、上 18vp */
const WSFL_CARD_SIDE: number = 12.4;
const WSFL_CARD_TOP: number = 12;
const WSFL_CARD_HEIGHT: number = 136.4;
const WSFL_CARD_RADIUS: number = 8;
const WSFL_CARD_PAD_SIDE: number = 17.1;
const WSFL_CARD_PAD_TOP: number = 18;

/** 航班号行：行高 16vp、标志 16.4vp 见方、到航班号 4.3vp、航班号字 13vp */
const WSFL_FLIGHT_ROW_HEIGHT: number = 16;
const WSFL_PLANE_SIZE: number = 16.4;
const WSFL_PLANE_TEXT_GAP: number = 4.3;
const WSFL_FLIGHT_NO_FONT: number = 13;

/** 两列信息：距航班号行 15vp；标签 11vp/高 16vp、时间 24vp/高 33vp（上距 2vp）、机场 12vp/高 17vp（上距 3vp） */
const WSFL_BLOCK_TOP_GAP: number = 15;
const WSFL_LABEL_FONT: number = 11;
const WSFL_LABEL_HEIGHT: number = 16;
const WSFL_TIME_FONT: number = 24;
const WSFL_TIME_HEIGHT: number = 33;
const WSFL_TIME_GAP: number = 2;
const WSFL_AIRPORT_FONT: number = 12;
const WSFL_AIRPORT_HEIGHT: number = 17;
const WSFL_AIRPORT_GAP: number = 3;

/** 中间列：宽 126.2vp；「3h4m」12.5vp/高 16vp，胶囊行高 23vp（上距 8vp） */
const WSFL_MID_WIDTH: number = 126.2;
const WSFL_DURATION_FONT: number = 12.5;
const WSFL_DURATION_HEIGHT: number = 16;
const WSFL_PILL_GAP_TOP: number = 8;

/** 胶囊「到达」：53.8×23vp、描边 1.5vp、字 14vp */
const WSFL_PILL_WIDTH: number = 53.8;
const WSFL_PILL_HEIGHT: number = 23;
const WSFL_PILL_BORDER: number = 1.5;
const WSFL_PILL_FONT: number = 14;

/** 虚线：点 1.8×1.5vp */
const WSFL_DOT_WIDTH: number = 1.8;
const WSFL_DOT_THICK: number = 1.5;

/** 日期条里的 15 个日期格：11-30 星期日 起连续 15 天 */
interface WSFL_DateCell {
  /** 唯一键 */
  dateKey: string;
  dateLabel: string;
  weekLabel: string;
  /** 该格右端是否画格间竖线（最后一格不画） */
  cellDivided: boolean;
}

const WSFL_DATE_CELLS: WSFL_DateCell[] = [
  { dateKey: 'd1130', dateLabel: '11-30', weekLabel: '星期日', cellDivided: true },
  { dateKey: 'd1201', dateLabel: '12-01', weekLabel: '星期一', cellDivided: true },
  { dateKey: 'd1202', dateLabel: '12-02', weekLabel: '星期二', cellDivided: true },
  { dateKey: 'd1203', dateLabel: '12-03', weekLabel: '星期三', cellDivided: true },
  { dateKey: 'd1204', dateLabel: '12-04', weekLabel: '星期四', cellDivided: true },
  { dateKey: 'd1205', dateLabel: '12-05', weekLabel: '星期五', cellDivided: true },
  { dateKey: 'd1206', dateLabel: '12-06', weekLabel: '星期六', cellDivided: true },
  { dateKey: 'd1207', dateLabel: '12-07', weekLabel: '星期日', cellDivided: true },
  { dateKey: 'd1208', dateLabel: '12-08', weekLabel: '星期一', cellDivided: true },
  { dateKey: 'd1209', dateLabel: '12-09', weekLabel: '星期二', cellDivided: true },
  { dateKey: 'd1210', dateLabel: '12-10', weekLabel: '星期三', cellDivided: true },
  { dateKey: 'd1211', dateLabel: '12-11', weekLabel: '星期四', cellDivided: true },
  { dateKey: 'd1212', dateLabel: '12-12', weekLabel: '星期五', cellDivided: true },
  { dateKey: 'd1213', dateLabel: '12-13', weekLabel: '星期六', cellDivided: true },
  { dateKey: 'd1214', dateLabel: '12-14', weekLabel: '星期日', cellDivided: false }
];

/** 一段虚线里 8 个点的 key */
const WSFL_DOT_KEYS: string[] = ['dot-a', 'dot-b', 'dot-c', 'dot-d', 'dot-e', 'dot-f', 'dot-g', 'dot-h'];

@Component
export struct FlightStatusDetailPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽度（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = 939.6;

  /** 窗口高度（vp），随折叠 / 旋转实时更新 */
  @State winHeightVp: number = 664.7;

  /** 日期条上当前选中的一天（默认 11-30 星期日，画红色描边框） */
  @State selectedDateKey: string = 'd1130';

  private dateScroller: Scroller = new Scroller();
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

  private isSelectedCell(cell: WSFL_DateCell): boolean {
    return cell.dateKey === this.selectedDateKey;
  }

  // ------------------------------------------------------------------
  // 顶部：返回箭头 + 居中航班号 + 房子图标
  // ------------------------------------------------------------------

  /** 返回箭头：两条斜向笔画在左侧交成一个「‹」 */
  @Builder
  backArrow() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(WSFL_BACK_BAR_LEN)
        .height(WSFL_BACK_STROKE)
        .backgroundColor(WSFL_TEXT_COLOR)
        .borderRadius(WSFL_BACK_STROKE / 2)
        .rotate({ angle: -WSFL_BACK_BAR_ANGLE })
        .offset({ y: -WSFL_BACK_BAR_GAP })

      Row()
        .width(WSFL_BACK_BAR_LEN)
        .height(WSFL_BACK_STROKE)
        .backgroundColor(WSFL_TEXT_COLOR)
        .borderRadius(WSFL_BACK_STROKE / 2)
        .rotate({ angle: WSFL_BACK_BAR_ANGLE })
        .offset({ y: WSFL_BACK_BAR_GAP })
    }
    .width(WSFL_BACK_SPAN_W)
    .height(WSFL_BACK_SPAN_H)
  }

  @Builder
  titleRow() {
    Stack({ alignContent: Alignment.Center }) {
      Text('ZH9106')
        .fontSize(WSFL_TITLE_FONT)
        .fontWeight(FontWeight.Medium)
        .fontColor(WSFL_TEXT_COLOR)
        .maxLines(1)

      Row() {
        Stack({ alignContent: Alignment.Center }) {
          this.backArrow()
        }
        .width(WSFL_BACK_TOUCH_WIDTH)
        .height(WSFL_TITLE_ROW_HEIGHT)
        .onClick(() => {
          this.pageStack.pop();
        })

        Blank()

        SymbolGlyph($r('sys.symbol.house'))
          .fontSize(WSFL_HOME_FONT)
          .fontColor([WSFL_TEXT_COLOR])
      }
      .width('100%')
      .height('100%')
      .padding({ left: WSFL_BACK_PAD_LEFT, right: WSFL_HOME_PAD_RIGHT })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(WSFL_TITLE_ROW_HEIGHT)
  }

  // ------------------------------------------------------------------
  // 日期条
  // ------------------------------------------------------------------

  /** 一格日期：选中时后面垫一个红色描边圆角框，格右端画格间竖线 */
  @Builder
  dateCell(cell: WSFL_DateCell) {
    Row() {
      Stack({ alignContent: Alignment.Start }) {
        if (this.isSelectedCell(cell)) {
          Row()
            .width(WSFL_CELL_CONTENT_WIDTH)
            .height(WSFL_DATE_ROW_HEIGHT)
            .border({
              width: WSFL_SELECT_BORDER,
              color: WSFL_RED,
              radius: WSFL_SELECT_RADIUS
            })
        }

        Column() {
          Text(cell.dateLabel)
            .fontSize(WSFL_DATE_FONT)
            .fontWeight(this.isSelectedCell(cell) ? FontWeight.Medium : FontWeight.Normal)
            .fontColor(this.isSelectedCell(cell) ? WSFL_RED : WSFL_TEXT_COLOR)
            .height(WSFL_DATE_TEXT_HEIGHT)
            .maxLines(1)

          Text(cell.weekLabel)
            .fontSize(WSFL_WEEK_FONT)
            .fontColor(this.isSelectedCell(cell) ? WSFL_RED : WSFL_WEEK_COLOR)
            .height(WSFL_WEEK_TEXT_HEIGHT)
            .margin({ top: WSFL_WEEK_GAP })
            .maxLines(1)
        }
        .width(WSFL_CELL_CONTENT_WIDTH)
        .height(WSFL_DATE_ROW_HEIGHT)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
      .width(WSFL_CELL_CONTENT_WIDTH)
      .height(WSFL_DATE_ROW_HEIGHT)

      Blank()

      if (cell.cellDivided) {
        Row()
          .width(WSFL_DATE_DIVIDER_WIDTH)
          .height(WSFL_DATE_DIVIDER_HEIGHT)
          .backgroundColor(WSFL_DIVIDER_COLOR)
      }
    }
    .width(WSFL_CELL_WIDTH)
    .height(WSFL_DATE_ROW_HEIGHT)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.selectedDateKey = cell.dateKey;
    })
  }

  @Builder
  dateStrip() {
    Stack({ alignContent: Alignment.End }) {
      Scroll(this.dateScroller) {
        Row() {
          ForEach(WSFL_DATE_CELLS, (cell: WSFL_DateCell) => {
            this.dateCell(cell)
          }, (cell: WSFL_DateCell) => cell.dateKey + (this.isSelectedCell(cell) ? '#on' : '#off'))
        }
        .height(WSFL_DATE_ROW_HEIGHT)
        .padding({ left: WSFL_DATE_PAD_LEFT, right: WSFL_CAL_BLOCK_WIDTH })
      }
      .width('100%')
      .height(WSFL_DATE_ROW_HEIGHT)
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .align(Alignment.Start)

      Row() {
        SymbolGlyph($r('sys.symbol.calendar'))
          .fontSize(WSFL_CAL_ICON_FONT)
          .fontColor([WSFL_TEXT_COLOR])
      }
      .width(WSFL_CAL_BLOCK_WIDTH)
      .height(WSFL_DATE_ROW_HEIGHT)
      .backgroundColor(WSFL_HEADER_BG)
      .padding({ right: WSFL_CAL_PAD_RIGHT })
      .justifyContent(FlexAlign.End)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(WSFL_DATE_ROW_HEIGHT)
    .margin({ top: WSFL_DATE_BLOCK_TOP })
  }

  @Builder
  pageHeader() {
    Column() {
      Row()
        .width('100%')
        .height(WSFL_STATUS_BAR_HEIGHT)

      this.titleRow()

      this.dateStrip()
    }
    .width('100%')
    .padding({ bottom: WSFL_DATE_BLOCK_BOTTOM })
    .backgroundColor(WSFL_HEADER_BG)
    .alignItems(HorizontalAlign.Start)
  }

  // ------------------------------------------------------------------
  // 航班卡片
  // ------------------------------------------------------------------

  /** 左侧一列：实际起飞 / 17:06 / 北京首都T3 */
  @Builder
  departureBlock() {
    Column() {
      Text('实际起飞')
        .fontSize(WSFL_LABEL_FONT)
        .fontColor(WSFL_LABEL_COLOR)
        .height(WSFL_LABEL_HEIGHT)
        .maxLines(1)

      Text('17:06')
        .fontSize(WSFL_TIME_FONT)
        .fontColor(WSFL_TEXT_COLOR)
        .height(WSFL_TIME_HEIGHT)
        .margin({ top: WSFL_TIME_GAP })
        .maxLines(1)

      Text('北京首都T3')
        .fontSize(WSFL_AIRPORT_FONT)
        .fontColor(WSFL_TEXT_COLOR)
        .height(WSFL_AIRPORT_HEIGHT)
        .margin({ top: WSFL_AIRPORT_GAP })
        .maxLines(1)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }

  /** 右侧一列：实际到达 / 20:10 / 深圳宝安T3，整列钉在卡片右边 */
  @Builder
  arrivalBlock() {
    Column() {
      Text('实际到达')
        .fontSize(WSFL_LABEL_FONT)
        .fontColor(WSFL_LABEL_COLOR)
        .height(WSFL_LABEL_HEIGHT)
        .maxLines(1)

      Text('20:10')
        .fontSize(WSFL_TIME_FONT)
        .fontColor(WSFL_TEXT_COLOR)
        .height(WSFL_TIME_HEIGHT)
        .margin({ top: WSFL_TIME_GAP })
        .maxLines(1)

      Text('深圳宝安T3')
        .fontSize(WSFL_AIRPORT_FONT)
        .fontColor(WSFL_TEXT_COLOR)
        .height(WSFL_AIRPORT_HEIGHT)
        .margin({ top: WSFL_AIRPORT_GAP })
        .maxLines(1)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.End)
  }

  /** 一段点状虚线：8 个浅灰小方点均匀排开 */
  @Builder
  dottedDash() {
    Row() {
      ForEach(WSFL_DOT_KEYS, (dotKey: string) => {
        Row()
          .width(WSFL_DOT_WIDTH)
          .height(WSFL_DOT_THICK)
          .backgroundColor(WSFL_DASH_COLOR)
      }, (dotKey: string) => dotKey)
    }
    .layoutWeight(1)
    .height(WSFL_DOT_THICK)
    .justifyContent(FlexAlign.SpaceBetween)
  }

  /** 中间列：3h4m + 虚线—「到达」胶囊—虚线 */
  @Builder
  durationBlock() {
    Column() {
      Text('3h4m')
        .fontSize(WSFL_DURATION_FONT)
        .fontColor(WSFL_DURATION_COLOR)
        .height(WSFL_DURATION_HEIGHT)
        .maxLines(1)

      Row() {
        this.dottedDash()

        Text('到达')
          .fontSize(WSFL_PILL_FONT)
          .fontColor(WSFL_GREEN)
          .width(WSFL_PILL_WIDTH)
          .height(WSFL_PILL_HEIGHT)
          .textAlign(TextAlign.Center)
          .maxLines(1)
          .border({
            width: WSFL_PILL_BORDER,
            color: WSFL_GREEN,
            radius: WSFL_PILL_HEIGHT / 2
          })

        this.dottedDash()
      }
      .width('100%')
      .height(WSFL_PILL_HEIGHT)
      .margin({ top: WSFL_PILL_GAP_TOP })
      .alignItems(VerticalAlign.Center)
    }
    .width(WSFL_MID_WIDTH)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  flightCard() {
    Column() {
      Row() {
        Image($r('app.media.ws_fl_airline_plane'))
          .width(WSFL_PLANE_SIZE)
          .height(WSFL_PLANE_SIZE)
          .objectFit(ImageFit.Contain)

        Text('ZH9106 | 空客321')
          .fontSize(WSFL_FLIGHT_NO_FONT)
          .fontColor(WSFL_TEXT_COLOR)
          .margin({ left: WSFL_PLANE_TEXT_GAP })
          .maxLines(1)
      }
      .width('100%')
      .height(WSFL_FLIGHT_ROW_HEIGHT)
      .alignItems(VerticalAlign.Center)

      Row() {
        this.departureBlock()

        this.durationBlock()

        this.arrivalBlock()
      }
      .width('100%')
      .margin({ top: WSFL_BLOCK_TOP_GAP })
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .height(WSFL_CARD_HEIGHT)
    .padding({
      left: WSFL_CARD_PAD_SIDE,
      right: WSFL_CARD_PAD_SIDE,
      top: WSFL_CARD_PAD_TOP
    })
    .backgroundColor(WSFL_CARD_BG)
    .borderRadius(WSFL_CARD_RADIUS)
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    NavDestination() {
      Column() {
        this.pageHeader()

        Column() {
          this.flightCard()
        }
        .width('100%')
        .layoutWeight(1)
        .padding({
          left: WSFL_CARD_SIDE,
          right: WSFL_CARD_SIDE,
          top: WSFL_CARD_TOP
        })
        .backgroundColor(WSFL_PAGE_BG)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(WSFL_PAGE_BG)
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
