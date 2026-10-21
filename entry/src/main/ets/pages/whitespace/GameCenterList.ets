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
 * 反例：留白过多 / 游戏中心列表右侧大片空白
 *
 * 复刻对象：腾讯「游戏中心」列表页，双屏横屏截图。状态栏下方一行：左侧返回箭头、居中标题
 *   「游戏中心」；再往下是单列 10 个游戏条目——左侧裁自截图的方形游戏封面，右侧是游戏名
 *   （王者荣耀 / 和平精英 / 欢乐斗地主 / 腾讯欢乐麻将全集 / 天天象棋 / 乱世王者 / 白荆回廊 /
 *   天龙八部手游 / 新天龙八部手游 / 战地无疆）与一行灰色副标题，每个条目右端一个浅灰胶囊
 *   「进入」；最后一条只露出上半截，被窗口底边裁掉。
 *
 * 设计基准：截图 3184×2232px（这里用的是 991×693 的等比缩小版，比例一致），密度 2.75，
 *   vp = px / 2.75，参考窗口 1157.8×811.6vp。下列括号内是缩小版上量到的 px 值，
 *   换算系数 1.16832（= 3184 / 991 / 2.75）：
 *   标题行：距页顶 47.8vp（箭头顶 59px）、行高 62vp、标题字 17vp（「游戏中心」4 字宽 59px）、
 *           返回箭头 9.4×19.9vp（笔画 2.3vp，左缘 33.9vp，竖高 17px）；
 *   条目：行高 73.4vp（封面顶 113px，下一条 176px，间距 62.8px）、封面 50.2vp（43px，
 *         圆角 8.2vp，左缘 22.2vp）、封面到文字 9.4vp（8px）、游戏名 16vp（8 字宽 112px）、
 *         副标题 12vp（10 字宽 105px）、副标题字顶 141px；
 *         「进入」胶囊 77.1×33.9vp（66×29px）、右缘距窗口右边 22.2vp、字 14vp；
 *   首行距标题行 10.8vp；整列文字最宽的一行（腾讯欢乐麻将全集）右缘在 211.5vp。
 *
 * 三态实测（上表 vp 值固定排版，条目仍是整行宽、胶囊钉右边缘；
 *   留白 = 窗口宽 − 310.8vp，310.8 = 左右边距 22.2 + 内容列 189.3 + 胶囊 77.1 + 右边距 22.2）：
 *   单屏态      459.6×672vp    —— 留白 148.8vp，约占宽度的 32%；内容占左 22.2～211.5vp
 *   双屏态竖屏  664.7×939.6vp  —— 留白 353.9vp，约占宽度的 53%
 *   双屏态横屏  939.6×664.7vp  —— 留白 628.8vp，约占宽度的 67%
 *   参考窗口    1157.8×811.6vp —— 留白 847.0vp，约占宽度的 73%（截图量到的就是这一态）
 *
 * 问题表现：
 *   所有条目都挤在左侧窄窄一条，封面 + 游戏名 + 副标题合起来最宽 189.3vp，只占宽度的
 *   六分之一到五分之二；文字右缘到「进入」胶囊之间是一整片没有任何内容的空白，
 *   截图里这条空白横跨窗口七成以上宽度；标题「游戏中心」仍按整窗居中，
 *   空白被夹在左侧内容和右侧胶囊中间，看不出和内容有任何关系。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 配色：纯白页面、近黑正文、灰色副标题、浅灰胶囊按钮 */
const WSGC_PAGE_BG: string = '#FFFFFF';
const WSGC_TEXT_COLOR: string = '#1A1A1A';
const WSGC_SUBTITLE_COLOR: string = '#999999';
const WSGC_BUTTON_BG: string = '#F1F1F2';

/** 页面左右边距 22.2vp（截图里封面左缘、胶囊右缘各距窗口边 19px） */
const WSGC_PAGE_PAD_SIDE: number = 22.2;

/** 标题行：距页顶 47.8vp、行高 62vp、标题字 17vp */
const WSGC_HEADER_TOP: number = 47.8;
const WSGC_HEADER_HEIGHT: number = 62;
const WSGC_TITLE_FONT: number = 17;

/** 返回箭头：外接 9.4×19.9vp、笔画 2.3vp、左缘 33.9vp；外层 44vp 触摸区，左右内缩 16.6vp */
const WSGC_BACK_TOUCH: number = 44;
const WSGC_BACK_PAD_LEFT: number = 16.6;
const WSGC_BACK_SPAN_W: number = 9.4;
const WSGC_BACK_SPAN_H: number = 19.9;
const WSGC_BACK_STROKE: number = 2.3;
/** 两条斜笔画：长 13.7vp、倾角 46.6°、中心上下各偏 4.98vp */
const WSGC_BACK_BAR_LEN: number = 13.7;
const WSGC_BACK_BAR_ANGLE: number = 46.6;
const WSGC_BACK_BAR_GAP: number = 4.98;

/** 列表：首行距标题行 10.8vp；行高 73.4vp */
const WSGC_LIST_TOP: number = 10.8;
const WSGC_ROW_HEIGHT: number = 73.4;

/** 游戏封面：50.2vp 方形、圆角 8.2vp、到文字 9.4vp */
const WSGC_ICON_SIZE: number = 50.2;
const WSGC_ICON_RADIUS: number = 8.2;
const WSGC_ICON_TEXT_GAP: number = 9.4;

/** 文字：游戏名 16vp、副标题 12vp、行间距 1.5vp */
const WSGC_NAME_FONT: number = 16;
const WSGC_SUB_FONT: number = 12;
const WSGC_SUB_GAP: number = 1.5;

/** 胶囊「进入」：77.1×33.9vp、字 14vp */
const WSGC_BUTTON_WIDTH: number = 77.1;
const WSGC_BUTTON_HEIGHT: number = 33.9;
const WSGC_BUTTON_FONT: number = 14;

interface WSGC_GameEntry {
  /** 条目唯一键 */
  entryKey: string;
  gameName: string;
  gameSubtitle: string;
  /** 从截图裁出的游戏封面 */
  gameIcon: Resource;
}

@Component
export struct GameCenterListPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽度（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = 939.6;

  /** 窗口高度（vp），随折叠 / 旋转实时更新 */
  @State winHeightVp: number = 664.7;

  private contentScroller: Scroller = new Scroller();
  private pageActive: boolean = false;
  private windowToken: number = 0;

  private gameEntries: WSGC_GameEntry[] = [];

  aboutToAppear(): void {
    this.pageActive = true;
    this.buildGameData();
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

  private buildGameData(): void {
    this.gameEntries = [
      {
        entryKey: 'gc-honor-of-kings',
        gameName: '王者荣耀',
        gameSubtitle: 'S41赛季·天元',
        gameIcon: $r('app.media.ws_gc_icon_honor_of_kings')
      },
      {
        entryKey: 'gc-game-for-peace',
        gameName: '和平精英',
        gameSubtitle: '创乐激战·升级回归！',
        gameIcon: $r('app.media.ws_gc_icon_game_for_peace')
      },
      {
        entryKey: 'gc-doudizhu',
        gameName: '欢乐斗地主',
        gameSubtitle: '遇见万千欢乐',
        gameIcon: $r('app.media.ws_gc_icon_doudizhu')
      },
      {
        entryKey: 'gc-mahjong',
        gameName: '腾讯欢乐麻将全集',
        gameSubtitle: '5亿用户实时对战',
        gameIcon: $r('app.media.ws_gc_icon_mahjong')
      },
      {
        entryKey: 'gc-xiangqi',
        gameName: '天天象棋',
        gameSubtitle: '经典象棋游戏',
        gameIcon: $r('app.media.ws_gc_icon_xiangqi')
      },
      {
        entryKey: 'gc-luanshiwangzhe',
        gameName: '乱世王者',
        gameSubtitle: '古龙正版小李飞刀联动',
        gameIcon: $r('app.media.ws_gc_icon_luanshiwangzhe')
      },
      {
        entryKey: 'gc-baijinghuilang',
        gameName: '白荆回廊',
        gameSubtitle: '「今日逸事」主题',
        gameIcon: $r('app.media.ws_gc_icon_baijinghuilang')
      },
      {
        entryKey: 'gc-tianlongbabu',
        gameName: '天龙八部手游',
        gameSubtitle: '轻松不肝，再聚天龙。',
        gameIcon: $r('app.media.ws_gc_icon_tianlongbabu')
      },
      {
        entryKey: 'gc-xintianlong',
        gameName: '新天龙八部手游',
        gameSubtitle: '梦回姑苏',
        gameIcon: $r('app.media.ws_gc_icon_xintianlong')
      },
      {
        entryKey: 'gc-zhandiwujiang',
        gameName: '战地无疆',
        gameSubtitle: '',
        gameIcon: $r('app.media.ws_gc_icon_zhandiwujiang')
      }
    ];
  }

  // ------------------------------------------------------------------
  // 标题行：左返回箭头 + 整窗居中的标题
  // ------------------------------------------------------------------

  /** 返回箭头：两条斜向笔画在左侧交成一个「‹」 */
  @Builder
  backArrow() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(WSGC_BACK_BAR_LEN)
        .height(WSGC_BACK_STROKE)
        .backgroundColor(WSGC_TEXT_COLOR)
        .borderRadius(WSGC_BACK_STROKE / 2)
        .rotate({ angle: -WSGC_BACK_BAR_ANGLE })
        .offset({ y: -WSGC_BACK_BAR_GAP })

      Row()
        .width(WSGC_BACK_BAR_LEN)
        .height(WSGC_BACK_STROKE)
        .backgroundColor(WSGC_TEXT_COLOR)
        .borderRadius(WSGC_BACK_STROKE / 2)
        .rotate({ angle: WSGC_BACK_BAR_ANGLE })
        .offset({ y: WSGC_BACK_BAR_GAP })
    }
    .width(WSGC_BACK_SPAN_W)
    .height(WSGC_BACK_SPAN_H)
  }

  @Builder
  headerBar() {
    Stack({ alignContent: Alignment.Center }) {
      Text('游戏中心')
        .fontSize(WSGC_TITLE_FONT)
        .fontWeight(FontWeight.Bold)
        .fontColor(WSGC_TEXT_COLOR)
        .maxLines(1)

      Row() {
        Stack({ alignContent: Alignment.Center }) {
          this.backArrow()
        }
        .width(WSGC_BACK_TOUCH)
        .height(WSGC_BACK_TOUCH)
        .onClick(() => {
          this.pageStack.pop();
        })

        Blank()
      }
      .width('100%')
      .height('100%')
      .padding({ left: WSGC_BACK_PAD_LEFT })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(WSGC_HEADER_HEIGHT)
    .margin({ top: WSGC_HEADER_TOP })
  }

  // ------------------------------------------------------------------
  // 游戏条目
  // ------------------------------------------------------------------

  @Builder
  gameRow(entry: WSGC_GameEntry) {
    Row() {
      Image(entry.gameIcon)
        .width(WSGC_ICON_SIZE)
        .height(WSGC_ICON_SIZE)
        .borderRadius(WSGC_ICON_RADIUS)
        .objectFit(ImageFit.Cover)
        .clip(true)

      Column({ space: WSGC_SUB_GAP }) {
        Text(entry.gameName)
          .fontSize(WSGC_NAME_FONT)
          .fontWeight(FontWeight.Medium)
          .fontColor(WSGC_TEXT_COLOR)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(entry.gameSubtitle)
          .fontSize(WSGC_SUB_FONT)
          .fontColor(WSGC_SUBTITLE_COLOR)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: WSGC_ICON_TEXT_GAP })

      Blank()

      Text('进入')
        .fontSize(WSGC_BUTTON_FONT)
        .fontColor(WSGC_TEXT_COLOR)
        .maxLines(1)
        .width(WSGC_BUTTON_WIDTH)
        .height(WSGC_BUTTON_HEIGHT)
        .textAlign(TextAlign.Center)
        .backgroundColor(WSGC_BUTTON_BG)
        .borderRadius(WSGC_BUTTON_HEIGHT / 2)
    }
    .width('100%')
    .height(WSGC_ROW_HEIGHT)
    .padding({
      left: WSGC_PAGE_PAD_SIDE,
      right: WSGC_PAGE_PAD_SIDE
    })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  gameList() {
    List({ scroller: this.contentScroller }) {
      ForEach(this.gameEntries, (entry: WSGC_GameEntry) => {
        ListItem() {
          this.gameRow(entry)
        }
      }, (entry: WSGC_GameEntry) => entry.entryKey)
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ top: WSGC_LIST_TOP })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.None)
  }

  build() {
    NavDestination() {
      Column() {
        this.headerBar()

        this.gameList()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(WSGC_PAGE_BG)
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
