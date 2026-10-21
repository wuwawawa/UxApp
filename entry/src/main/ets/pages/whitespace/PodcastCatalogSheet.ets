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
 * 反例：留白过多 / 播客详情页「目录」弹层从「播放」到首集空出一大块（留白过多）
 *
 * 复刻对象：播客（听书类）详情页底部弹出的「目录」面板，双屏横屏截图。屏幕上方是被压暗的
 *   封面区：左上白色返回箭头、右上红色心形与白色分享箭头，左边一张黄色卡通插画方形封面
 *   （下半截被面板压住），封面右侧是白色大标题「听爆笑日常」与半截白色副标题
 *   「每天3分钟 欢乐笑不停」，标题上方还有一行只剩上半截的小字。面板是白色大圆角卡片，
 *   顶边居中一条灰色拖动条；面板内左上「目录」两个大字（下方一小段绿色短横）、下面一个
 *   绿色胶囊「▶ 播放」、右上角一个灰色排序图标；再往下空出一大块白，才到唯一的「第1集」
 *   条目：左边方形缩略图（裁自截图）、右边「第1集 糟糕的家庭作业」+ 灰字
 *   「当老爸写起了小学作业」，条目下方一行灰色小字「04:44」「144.4万」，右侧一个小铃铛。
 *   封面与缩略图裁自截图，存于 media/ws_pc_*。
 *
 * 设计基准：截图 3184×2232px，密度 2.75，vp = px / 2.75，参考窗口 1157.8×811.6vp。
 *   顶部白条 40.7vp（112px）；压暗区底色 #998840（153,136,64）；
 *   面板顶边 224vp（616px，面板以上留 27.6% 的屏幕高度）、顶角圆角 44.4vp（122px）；
 *   拖动条 114.5×12.4vp（315×34px）、圆角 6.2vp、距面板顶 21.1vp（58px）、水平居中；
 *   主封面 291.6×291.6vp（802px）、左缘 50.9vp（140px）、上缘 112.7vp（310px）；
 *   大标题 52vp（5 字宽 734px=267vp）、左缘 390.2vp（1073px）、字顶 128vp（352px）；
 *   副标题 36vp（10 字宽 1063px=386vp）、左缘 388.4vp、字顶 205.5vp（565px）、下沿被面板切掉；
 *   小字行 24vp、左缘 389.1vp、只露出上方约 16vp；返回箭头 9.5×16.7vp（26×46px）、笔画 2.6vp、
 *   左缘 28.4vp（78px）、竖中心 76.6vp；心形 70.9×61.8vp（195×170px），右缘距窗口右 160.5vp；
 *   分享箭头 58.5×59vp（161×162px），右缘距窗口右 47.6vp；
 *   「目录」44vp（2 字宽 228px=83vp）、左缘 96vp（274px）、字顶 82.9vp（844px，面板内坐标）；
 *   绿色短横 38.2×15.6vp（105×43px）、左缘 120.7vp（332px）、顶 125.8vp（962px）；
 *   播放按钮 183.6×81.5vp（505×224px）、左缘 52.4vp（144px）、顶 187.6vp（1132px）、圆角 40.75vp；
 *   按钮内三角形 19.6×33.1vp（54×91px）、「播放」36vp；
 *   排序图标 47×39vp（129×107px）、右缘距窗口右 52.3vp、顶 197.1vp（1158px）；
 *   第 1 集条目顶 392vp（1694px，面板内坐标）：缩略图 83.4×83.4vp（230px）贴窗口左边，
 *   标题 18vp（左缘 117.5vp=323px）、副标题 14vp、数据行 13vp（字顶 480.4vp=1937px）；
 *   面板底到条目底 97.4vp（267px）。
 *   以上数值按 sceneScale = 窗口宽 / 1157.8 等比换算，宽窗口下不拉伸。
 *
 * 三态实测（同一套设计值 × sceneScale，最宽一条内容右缘 278.9vp；面板内条目底 494vp）：
 *   单屏态      459.6×672vp   —— ×0.397：面板顶 88.9vp，内容右缘 110.7vp，
 *                                右侧留白 348.9vp，约占宽度的 76%；面板高 583.1vp，
 *                                条目之下还空 387vp，约占面板高度的 66%
 *   双屏态竖屏  664.7×939.6vp —— ×0.574：面板顶 128.6vp，内容右缘 160.1vp，
 *                                右侧留白 504.6vp，约占宽度的 76%；面板高 811vp，
 *                                条目之下还空 527.4vp，约占面板高度的 65%
 *   双屏态横屏  939.6×664.7vp —— ×0.812：面板顶 181.8vp，内容右缘 226.3vp，
 *                                右侧留白 713.3vp，约占宽度的 76%；面板高 482.9vp，
 *                                「目录」字顶到条目顶 251vp，约占面板高度的 52%
 *
 * 问题表现：
 *   面板里所有内容（目录、播放、排序、第 1 集）都挤在左边四分之一宽的一条里，
 *   从这一条往右直到窗口右缘是整片没有任何内容的白色，横跨窗口七成以上宽度；
 *   「播放」按钮与「第 1 集」之间空出一大块白，约占面板高度的一半，中间没有任何过渡；
 *   第 1 集下面到底边又是一整块白；窗口越宽，右侧与中间的空白面积越大，内容始终不铺开。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 基准窗口宽度（3184px / 密度 2.75）：所有设计值都以它为基准等比换算 */
const WSPC_BASE_WIDTH: number = 1157.8;

/** 配色 */
const WSPC_PAGE_BG: string = '#FFFFFF';
const WSPC_HERO_BG: string = '#998840';
const WSPC_GREEN: string = '#14BD58';
const WSPC_HANDLE_BG: string = '#E3E3E3';
const WSPC_WHITE: string = '#FFFFFF';
const WSPC_HEART_COLOR: string = '#FA2C50';
const WSPC_SORT_COLOR: string = '#8F9090';
const WSPC_DIR_TEXT: string = '#3F3F3F';
const WSPC_EP_TITLE: string = '#2B2B2B';
const WSPC_EP_SUB: string = '#9C9C9C';
const WSPC_META_TEXT: string = '#9C9C9C';
const WSPC_META_ICON: string = '#C9CBD0';
const WSPC_BELL_COLOR: string = '#B8B8B8';

/** 顶部白条 40.7vp；压暗区到面板顶 224vp；面板顶角圆角 44.4vp */
const WSPC_TOP_BAND: number = 40.7;
const WSPC_PANEL_TOP: number = 224;
const WSPC_PANEL_RADIUS: number = 44.4;

/** 主封面：291.6vp 方形、左 50.9vp、上 112.7vp（下半截落在面板背后） */
const WSPC_COVER_LEFT: number = 50.9;
const WSPC_COVER_TOP: number = 112.7;
const WSPC_COVER_SIZE: number = 291.6;

/** 返回箭头：外接 9.5×16.7vp、笔画 2.6vp，笔画长 12.6vp、与水平线夹角 41.3° */
const WSPC_BACK_BOX_W: number = 20;
const WSPC_BACK_BOX_H: number = 26;
const WSPC_BACK_LEFT: number = 23.1;
const WSPC_BACK_TOP: number = 64;
const WSPC_BACK_BAR_W: number = 12.6;
const WSPC_BACK_BAR_H: number = 2.6;
const WSPC_BACK_ANGLE: number = 41.3;
const WSPC_BACK_OFFSET: number = 4.2;

/** 标题上方的小字：24vp、左 389.1vp、只露出上方 16vp */
const WSPC_HINT_LEFT: number = 389.1;
const WSPC_HINT_TOP: number = 100;
const WSPC_HINT_FONT: number = 24;
const WSPC_HINT_WIDTH: number = 560;
const WSPC_HINT_VISIBLE: number = 16;
const WSPC_HINT_LINE: number = 34;

/** 大标题 52vp、左 390.2vp、字顶 128vp；副标题 36vp、左 388.4vp、字顶 205.5vp */
const WSPC_TITLE_LEFT: number = 390.2;
const WSPC_TITLE_TOP: number = 121;
const WSPC_TITLE_FONT: number = 52;
const WSPC_TITLE_BOX: number = 60;
const WSPC_SUB_LEFT: number = 388.4;
const WSPC_SUB_TOP: number = 199;
const WSPC_SUB_FONT: number = 36;
const WSPC_SUB_BOX: number = 44;

/** 心形 70.9×61.8vp、左 927.3vp、上 68.4vp；轮廓点按 70.9×61.8 的设计坐标给出 */
const WSPC_HEART_LEFT: number = 927.3;
const WSPC_HEART_TOP: number = 68.4;
const WSPC_HEART_W: number = 70.9;
const WSPC_HEART_H: number = 61.8;
const WSPC_HEART_PTS: number[] = [
  35.4, 57.5,
  15.6, 44.5, 3.5, 34, 3.5, 21.6,
  3.5, 10.5, 12.8, 4.3, 22.7, 4.3,
  29.1, 4.3, 33.3, 8, 35.4, 12.4,
  37.6, 8, 41.8, 4.3, 48.2, 4.3,
  58.1, 4.3, 67.4, 10.5, 67.4, 21.6,
  67.4, 34, 55.3, 44.5, 35.4, 57.5
];

/** 分享箭头：58.5×59vp、左 1051.6vp、上 68.7vp；圆环 48vp、笔画 5vp */
const WSPC_SHARE_LEFT: number = 1051.6;
const WSPC_SHARE_TOP: number = 68.7;
const WSPC_SHARE_W: number = 58.5;
const WSPC_SHARE_H: number = 59;
const WSPC_SHARE_RING: number = 48;
const WSPC_SHARE_RING_LEFT: number = 3;
const WSPC_SHARE_RING_TOP: number = 11;
const WSPC_SHARE_STROKE: number = 5;

/** 拖动条：114.5×12.4vp、圆角 6.2vp、距面板顶 21.1vp */
const WSPC_HANDLE_TOP: number = 21.1;
const WSPC_HANDLE_W: number = 114.5;
const WSPC_HANDLE_H: number = 12.4;
const WSPC_HANDLE_RADIUS: number = 6.2;

/** 「目录」44vp、左 96vp、字顶 82.9vp；绿色短横 38.2×15.6vp、左 120.7vp */
const WSPC_DIR_TOP: number = 45.5;
const WSPC_DIR_LEFT: number = 96;
const WSPC_DIR_FONT: number = 44;
const WSPC_DIR_BOX: number = 47;
const WSPC_BLOB_LEFT: number = 24.7;
const WSPC_BLOB_W: number = 38.2;
const WSPC_BLOB_H: number = 15.6;
const WSPC_BLOB_RADIUS: number = 7.8;

/** 播放按钮 183.6×81.5vp、左 52.4vp、顶 187.6vp；三角形 19.6×33.1vp、「播放」36vp */
const WSPC_PLAY_TOP: number = 46;
const WSPC_PLAY_LEFT: number = 52.4;
const WSPC_PLAY_W: number = 183.6;
const WSPC_PLAY_H: number = 81.5;
const WSPC_PLAY_FONT: number = 36;
const WSPC_PLAY_GAP: number = 8;
const WSPC_TRI_W: number = 19.6;
const WSPC_TRI_H: number = 33.1;

/** 排序图标 47×39vp、右距 52.3vp、顶 197.1vp；三条线高 4.4vp，短线宽 31vp */
const WSPC_SORT_W: number = 47;
const WSPC_SORT_H: number = 39;
const WSPC_SORT_RIGHT: number = 52.3;
const WSPC_SORT_TOP: number = 9.5;
const WSPC_SORT_LINE: number = 4.4;
const WSPC_SORT_SHORT: number = 31;
const WSPC_SORT_ROW2: number = 12.6;
const WSPC_SORT_ROW3: number = 25.2;

/** 播放按钮下沿（面板内 269.1vp）到第 1 集条目顶（392vp）之间的大块留白 122.9vp */
const WSPC_EMPTY_GAP: number = 122.9;

/** 第 1 集条目：缩略图 83.4vp、文字左 117.5vp、标题 18vp、副标题 14vp、数据 13vp */
const WSPC_EP_THUMB: number = 83.4;
const WSPC_EP_TEXT_LEFT: number = 117.5;
const WSPC_EP_TEXT_GAP: number = 33.9;
const WSPC_EP_TITLE_FONT: number = 18;
const WSPC_EP_TITLE_BOX: number = 22;
const WSPC_EP_SUB_FONT: number = 14;
const WSPC_EP_SUB_BOX: number = 20;
const WSPC_EP_SUB_GAP: number = 6;
const WSPC_EP_META_TOP: number = 2.6;
const WSPC_EP_META_FONT: number = 13;
const WSPC_EP_META_ICON: number = 13;
const WSPC_EP_META_GAP: number = 6;
const WSPC_EP_META_GROUP: number = 30;
const WSPC_EP_META_BOX: number = 16;

/** 条目右侧小铃铛：外接 20vp、右距 52.3vp */
const WSPC_BELL_SIZE: number = 20;
const WSPC_BELL_RIGHT: number = 52.3;
const WSPC_BELL_BAR: number = 1.6;

@Component
export struct PodcastCatalogSheetPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽度（vp），随折叠 / 旋转实时更新；整页缩放比由它算出 */
  @State winWidthVp: number = 939.6;

  /** 窗口高度（vp），随折叠 / 旋转实时更新 */
  @State winHeightVp: number = 664.7;

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

  /** 整页缩放比：窗口宽度 / 参考窗口宽度（1157.8vp） */
  private sceneScale(): number {
    if (this.winWidthVp <= 0) {
      return 1;
    }
    return this.winWidthVp / WSPC_BASE_WIDTH;
  }

  /** 把按参考窗口量出的设计值换算到当前窗口 */
  private ws(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  /** 面板高度：窗口高度减去面板上沿，一直铺到窗口底边 */
  private panelHeightVp(): number {
    const rest: number = this.winHeightVp - this.ws(WSPC_PANEL_TOP);
    return rest > 0 ? rest : 0;
  }

  /** 把设计坐标按当前比例格式化成路径参数 */
  private pt(value: number): string {
    return (value * this.sceneScale()).toFixed(2);
  }

  /** 心形轮廓：起点 + 6 段三次贝塞尔，坐标全部由 WSPC_HEART_PTS 换算 */
  private heartPath(): string {
    const pts: number[] = WSPC_HEART_PTS;
    let path: string = 'M' + this.pt(pts[0]) + ' ' + this.pt(pts[1]);
    let index: number = 2;
    while (index + 5 < pts.length) {
      path += ' C' + this.pt(pts[index]) + ' ' + this.pt(pts[index + 1]) +
        ' ' + this.pt(pts[index + 2]) + ' ' + this.pt(pts[index + 3]) +
        ' ' + this.pt(pts[index + 4]) + ' ' + this.pt(pts[index + 5]);
      index += 6;
    }
    return path + ' Z';
  }

  /** 播放按钮里的三角：左竖边 33.1vp、右尖点 19.6vp */
  private trianglePath(): string {
    return 'M0 0 L' + this.pt(WSPC_TRI_W) + ' ' + this.pt(WSPC_TRI_H / 2) +
      ' L0 ' + this.pt(WSPC_TRI_H) + ' Z';
  }

  /** 小圆图标里的白色三角（数据行播放量前的小圆） */
  private miniTrianglePath(): string {
    return 'M0 0 L' + this.pt(5) + ' ' + this.pt(4) + ' L0 ' + this.pt(8) + ' Z';
  }

  // ------------------------------------------------------------------
  // 上方被压暗的封面区
  // ------------------------------------------------------------------

  @Builder
  heroBackdrop() {
    Column() {
      Row()
        .width('100%')
        .height(this.ws(WSPC_TOP_BAND))
        .backgroundColor(WSPC_PAGE_BG)

      Stack({ alignContent: Alignment.TopStart }) {
        Row()
          .width('100%')
          .height('100%')
          .backgroundColor(WSPC_HERO_BG)

        Image($r('app.media.ws_pc_cover_glow'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .opacity(0.12)
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  coverImage() {
    Image($r('app.media.ws_pc_cover_album'))
      .width(this.ws(WSPC_COVER_SIZE))
      .height(this.ws(WSPC_COVER_SIZE))
      .objectFit(ImageFit.Cover)
      .position({ x: this.ws(WSPC_COVER_LEFT), y: this.ws(WSPC_COVER_TOP) })
  }

  @Builder
  backArrow() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(this.ws(WSPC_BACK_BAR_W))
        .height(this.ws(WSPC_BACK_BAR_H))
        .backgroundColor(WSPC_WHITE)
        .borderRadius(this.ws(WSPC_BACK_BAR_H / 2))
        .rotate({ angle: -WSPC_BACK_ANGLE })
        .offset({ y: -this.ws(WSPC_BACK_OFFSET) })

      Row()
        .width(this.ws(WSPC_BACK_BAR_W))
        .height(this.ws(WSPC_BACK_BAR_H))
        .backgroundColor(WSPC_WHITE)
        .borderRadius(this.ws(WSPC_BACK_BAR_H / 2))
        .rotate({ angle: WSPC_BACK_ANGLE })
        .offset({ y: this.ws(WSPC_BACK_OFFSET) })
    }
    .width(this.ws(WSPC_BACK_BOX_W))
    .height(this.ws(WSPC_BACK_BOX_H))
    .position({ x: this.ws(WSPC_BACK_LEFT), y: this.ws(WSPC_BACK_TOP) })
    .onClick(() => {
      this.pageStack.pop();
    })
  }

  /** 标题上方只剩上半截的小字 */
  @Builder
  hintLine() {
    Column() {
      Text('家庭搞笑小剧场 · 每天更新一集 · 陪你笑不停')
        .fontSize(this.ws(WSPC_HINT_FONT))
        .fontColor(WSPC_WHITE)
        .opacity(0.45)
        .maxLines(1)
        .height(this.ws(WSPC_HINT_LINE))
    }
    .width(this.ws(WSPC_HINT_WIDTH))
    .height(this.ws(WSPC_HINT_VISIBLE))
    .clip(true)
    .alignItems(HorizontalAlign.Start)
    .position({ x: this.ws(WSPC_HINT_LEFT), y: this.ws(WSPC_HINT_TOP) })
  }

  @Builder
  headerTitle() {
    Text('听爆笑日常')
      .fontSize(this.ws(WSPC_TITLE_FONT))
      .fontWeight(FontWeight.Bold)
      .fontColor(WSPC_WHITE)
      .maxLines(1)
      .height(this.ws(WSPC_TITLE_BOX))
      .position({ x: this.ws(WSPC_TITLE_LEFT), y: this.ws(WSPC_TITLE_TOP) })
  }

  @Builder
  headerSubTitle() {
    Text('每天3分钟 欢乐笑不停')
      .fontSize(this.ws(WSPC_SUB_FONT))
      .fontWeight(FontWeight.Medium)
      .fontColor(WSPC_WHITE)
      .maxLines(1)
      .height(this.ws(WSPC_SUB_BOX))
      .position({ x: this.ws(WSPC_SUB_LEFT), y: this.ws(WSPC_SUB_TOP) })
  }

  @Builder
  heartIcon() {
    Path()
      .width(this.ws(WSPC_HEART_W))
      .height(this.ws(WSPC_HEART_H))
      .commands(this.heartPath())
      .fill(WSPC_HEART_COLOR)
      .position({ x: this.ws(WSPC_HEART_LEFT), y: this.ws(WSPC_HEART_TOP) })
  }

  @Builder
  shareIcon() {
    Stack({ alignContent: Alignment.TopStart }) {
      Circle()
        .width(this.ws(WSPC_SHARE_RING))
        .height(this.ws(WSPC_SHARE_RING))
        .fill(Color.Transparent)
        .stroke(WSPC_WHITE)
        .strokeWidth(this.ws(WSPC_SHARE_STROKE))
        .position({ x: this.ws(WSPC_SHARE_RING_LEFT), y: this.ws(WSPC_SHARE_RING_TOP) })

      Row()
        .width(this.ws(24))
        .height(this.ws(5))
        .backgroundColor(WSPC_WHITE)
        .borderRadius(this.ws(2.5))
        .rotate({ angle: -45 })
        .position({ x: this.ws(28), y: this.ws(20) })

      Row()
        .width(this.ws(16))
        .height(this.ws(5))
        .backgroundColor(WSPC_WHITE)
        .borderRadius(this.ws(2.5))
        .position({ x: this.ws(38), y: this.ws(8) })

      Row()
        .width(this.ws(5))
        .height(this.ws(16))
        .backgroundColor(WSPC_WHITE)
        .borderRadius(this.ws(2.5))
        .position({ x: this.ws(49), y: this.ws(8) })
    }
    .width(this.ws(WSPC_SHARE_W))
    .height(this.ws(WSPC_SHARE_H))
    .position({ x: this.ws(WSPC_SHARE_LEFT), y: this.ws(WSPC_SHARE_TOP) })
  }

  // ------------------------------------------------------------------
  // 面板头部：拖动条 / 目录 / 播放 / 排序
  // ------------------------------------------------------------------

  @Builder
  dragHandle() {
    Row() {
      Row()
        .width(this.ws(WSPC_HANDLE_W))
        .height(this.ws(WSPC_HANDLE_H))
        .backgroundColor(WSPC_HANDLE_BG)
        .borderRadius(this.ws(WSPC_HANDLE_RADIUS))
    }
    .width('100%')
    .height(this.ws(WSPC_HANDLE_TOP + WSPC_HANDLE_H))
    .padding({ top: this.ws(WSPC_HANDLE_TOP) })
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  dirBlock() {
    Column() {
      Text('目录')
        .fontSize(this.ws(WSPC_DIR_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(WSPC_DIR_TEXT)
        .maxLines(1)
        .height(this.ws(WSPC_DIR_BOX))

      Row()
        .width(this.ws(WSPC_BLOB_W))
        .height(this.ws(WSPC_BLOB_H))
        .backgroundColor(WSPC_GREEN)
        .borderRadius(this.ws(WSPC_BLOB_RADIUS))
        .margin({ left: this.ws(WSPC_BLOB_LEFT) })
    }
    .width('100%')
    .margin({ top: this.ws(WSPC_DIR_TOP) })
    .padding({ left: this.ws(WSPC_DIR_LEFT) })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  sortIcon() {
    Stack({ alignContent: Alignment.TopStart }) {
      Row()
        .width(this.ws(WSPC_SORT_W))
        .height(this.ws(WSPC_SORT_LINE))
        .backgroundColor(WSPC_SORT_COLOR)
        .borderRadius(this.ws(WSPC_SORT_LINE / 2))
        .position({ x: 0, y: 0 })

      Row()
        .width(this.ws(WSPC_SORT_SHORT))
        .height(this.ws(WSPC_SORT_LINE))
        .backgroundColor(WSPC_SORT_COLOR)
        .borderRadius(this.ws(WSPC_SORT_LINE / 2))
        .position({ x: 0, y: this.ws(WSPC_SORT_ROW2) })

      Row()
        .width(this.ws(WSPC_SORT_SHORT))
        .height(this.ws(WSPC_SORT_LINE))
        .backgroundColor(WSPC_SORT_COLOR)
        .borderRadius(this.ws(WSPC_SORT_LINE / 2))
        .position({ x: 0, y: this.ws(WSPC_SORT_ROW3) })

      Row()
        .width(this.ws(WSPC_SORT_LINE))
        .height(this.ws(24))
        .backgroundColor(WSPC_SORT_COLOR)
        .borderRadius(this.ws(WSPC_SORT_LINE / 2))
        .position({ x: this.ws(42.6), y: this.ws(11) })

      Row()
        .width(this.ws(8.5))
        .height(this.ws(WSPC_SORT_LINE))
        .backgroundColor(WSPC_SORT_COLOR)
        .borderRadius(this.ws(WSPC_SORT_LINE / 2))
        .rotate({ angle: 45 })
        .position({ x: this.ws(34.5), y: this.ws(29) })

      Row()
        .width(this.ws(8.5))
        .height(this.ws(WSPC_SORT_LINE))
        .backgroundColor(WSPC_SORT_COLOR)
        .borderRadius(this.ws(WSPC_SORT_LINE / 2))
        .rotate({ angle: -45 })
        .position({ x: this.ws(43.5), y: this.ws(29) })
    }
    .width(this.ws(WSPC_SORT_W))
    .height(this.ws(WSPC_SORT_H))
  }

  @Builder
  playRow() {
    Row() {
      Row({ space: this.ws(WSPC_PLAY_GAP) }) {
        Path()
          .width(this.ws(WSPC_TRI_W))
          .height(this.ws(WSPC_TRI_H))
          .commands(this.trianglePath())
          .fill(WSPC_WHITE)

        Text('播放')
          .fontSize(this.ws(WSPC_PLAY_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(WSPC_WHITE)
          .maxLines(1)
      }
      .width(this.ws(WSPC_PLAY_W))
      .height(this.ws(WSPC_PLAY_H))
      .backgroundColor(WSPC_GREEN)
      .borderRadius(this.ws(WSPC_PLAY_H / 2))
      .justifyContent(FlexAlign.Center)
      .margin({ left: this.ws(WSPC_PLAY_LEFT) })

      Blank()

      Column() {
        this.sortIcon()
      }
      .margin({ top: this.ws(WSPC_SORT_TOP), right: this.ws(WSPC_SORT_RIGHT) })
    }
    .width('100%')
    .height(this.ws(WSPC_PLAY_H))
    .margin({ top: this.ws(WSPC_PLAY_TOP) })
    .alignItems(VerticalAlign.Top)
  }

  // ------------------------------------------------------------------
  // 第 1 集条目
  // ------------------------------------------------------------------

  @Builder
  metaClockIcon() {
    Stack({ alignContent: Alignment.Center }) {
      Circle()
        .width(this.ws(WSPC_EP_META_ICON))
        .height(this.ws(WSPC_EP_META_ICON))
        .fill(WSPC_META_ICON)

      Row()
        .width(this.ws(1.4))
        .height(this.ws(6))
        .backgroundColor(WSPC_WHITE)
        .offset({ y: -this.ws(0.6) })

      Row()
        .width(this.ws(4))
        .height(this.ws(1.4))
        .backgroundColor(WSPC_WHITE)
        .offset({ x: this.ws(1), y: this.ws(2) })
    }
    .width(this.ws(WSPC_EP_META_ICON))
    .height(this.ws(WSPC_EP_META_ICON))
  }

  @Builder
  metaPlayIcon() {
    Stack({ alignContent: Alignment.Center }) {
      Circle()
        .width(this.ws(WSPC_EP_META_ICON))
        .height(this.ws(WSPC_EP_META_ICON))
        .fill(WSPC_META_ICON)

      Path()
        .width(this.ws(5))
        .height(this.ws(8))
        .commands(this.miniTrianglePath())
        .fill(WSPC_WHITE)
    }
    .width(this.ws(WSPC_EP_META_ICON))
    .height(this.ws(WSPC_EP_META_ICON))
  }

  @Builder
  bellIcon() {
    Column() {
      Row()
        .width(this.ws(12))
        .height(this.ws(11))
        .border({ width: this.ws(WSPC_BELL_BAR), color: WSPC_BELL_COLOR })
        .borderRadius({ topLeft: this.ws(6), topRight: this.ws(6), bottomLeft: this.ws(2), bottomRight: this.ws(2) })

      Row()
        .width(this.ws(16))
        .height(this.ws(WSPC_BELL_BAR))
        .backgroundColor(WSPC_BELL_COLOR)
        .borderRadius(this.ws(WSPC_BELL_BAR / 2))
        .margin({ top: this.ws(0.6) })

      Row()
        .width(this.ws(4))
        .height(this.ws(3))
        .backgroundColor(WSPC_BELL_COLOR)
        .borderRadius(this.ws(1.5))
        .margin({ top: this.ws(1) })
    }
    .width(this.ws(WSPC_BELL_SIZE))
    .height(this.ws(WSPC_BELL_SIZE))
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  metaRow() {
    Row() {
      this.metaClockIcon()

      Text('04:44')
        .fontSize(this.ws(WSPC_EP_META_FONT))
        .fontColor(WSPC_META_TEXT)
        .maxLines(1)
        .margin({ left: this.ws(WSPC_EP_META_GAP) })

      Column() {
        this.metaPlayIcon()
      }
      .margin({ left: this.ws(WSPC_EP_META_GROUP) })

      Text('144.4万')
        .fontSize(this.ws(WSPC_EP_META_FONT))
        .fontColor(WSPC_META_TEXT)
        .maxLines(1)
        .margin({ left: this.ws(WSPC_EP_META_GAP) })
    }
    .height(this.ws(WSPC_EP_META_BOX))
    .margin({ left: this.ws(WSPC_EP_TEXT_LEFT), top: this.ws(WSPC_EP_META_TOP) })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  episodeItem() {
    Column() {
      Row() {
        Image($r('app.media.ws_pc_ep1_thumb'))
          .width(this.ws(WSPC_EP_THUMB))
          .height(this.ws(WSPC_EP_THUMB))
          .objectFit(ImageFit.Cover)

        Column() {
          Text('第1集 糟糕的家庭作业')
            .fontSize(this.ws(WSPC_EP_TITLE_FONT))
            .fontWeight(FontWeight.Bold)
            .fontColor(WSPC_EP_TITLE)
            .maxLines(1)
            .height(this.ws(WSPC_EP_TITLE_BOX))

          Text('当老爸写起了小学作业')
            .fontSize(this.ws(WSPC_EP_SUB_FONT))
            .fontColor(WSPC_EP_SUB)
            .maxLines(1)
            .height(this.ws(WSPC_EP_SUB_BOX))
            .margin({ top: this.ws(WSPC_EP_SUB_GAP) })
        }
        .margin({ left: this.ws(WSPC_EP_TEXT_GAP) })
        .alignItems(HorizontalAlign.Start)

        Blank()

        Column() {
          this.bellIcon()
        }
        .margin({ top: this.ws(22), right: this.ws(WSPC_BELL_RIGHT) })
      }
      .width('100%')
      .height(this.ws(WSPC_EP_THUMB))
      .alignItems(VerticalAlign.Top)

      this.metaRow()
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  // ------------------------------------------------------------------
  // 面板
  // ------------------------------------------------------------------

  @Builder
  catalogSheet() {
    Column() {
      this.dragHandle()

      this.dirBlock()

      this.playRow()

      Row()
        .width('100%')
        .height(this.ws(WSPC_EMPTY_GAP))

      this.episodeItem()
    }
    .width('100%')
    .height(this.panelHeightVp())
    .backgroundColor(WSPC_PAGE_BG)
    .borderRadius({ topLeft: this.ws(WSPC_PANEL_RADIUS), topRight: this.ws(WSPC_PANEL_RADIUS) })
    .clip(true)
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        // 整屏底色：顶部白条 + 往下一直铺到窗口底边的压暗封面区
        this.heroBackdrop()

        // 封面区内容：封面下半截会落到面板背后
        Stack({ alignContent: Alignment.TopStart }) {
          this.coverImage()

          this.hintLine()

          this.headerTitle()

          this.headerSubTitle()

          this.backArrow()

          this.heartIcon()

          this.shareIcon()
        }
        .width('100%')
        .height(this.ws(WSPC_PANEL_TOP))

        // 面板：从封面区下沿贴到窗口底边，压住封面下半截
        Column() {
          this.catalogSheet()
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.End)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(WSPC_PAGE_BG)
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
