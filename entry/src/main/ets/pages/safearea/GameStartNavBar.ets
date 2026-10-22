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
 * 反例：未避让安全区 / 游戏登录开始键压导航条（导航条）
 *
 * 复刻手游登录页：深蓝星空渐变背景（满天星点按窗口比例铺开），左上角
 * 「设置 / 公告」与右上角「客服」圆形半透明按钮，居中的游戏 Logo
 * 「星辰幻想」+ 副标题、推荐服选服胶囊（推荐服 · 翡翠之力）、版本公告条、
 * 版本号，以及钉在屏幕底边的金色「开始游戏」大按钮。
 *
 * 设计基准：单屏态 459.6×672vp（1264×1848px，密度 2.75），vp = px / 2.75。
 *   背景：180° 深蓝渐变（#0A1637 → #14275F → #081022），星点 16 颗
 *         （直径 1.2～2.6vp、透明度 0.3～0.9），位置按窗口宽高比例铺满全屏；
 *   顶部按钮行：距顶 44vp 固定留白（不缩放，避开状态栏）+ 圆形按钮 38vp
 *         （图标 18vp、标签 10vp），按钮尺寸随窗口等比放大但只向下生长；
 *   Logo：主标 46vp 加粗、副标 12vp、选服胶囊高 32vp、公告条高 34vp；
 *   底部按钮带：高 96vp 固定（不随窗口宽度变化），按钮顶对齐：
 *         按钮高 52vp（设计值）、宽 72%、圆角 12vp、金字 19vp，
 *         按 sceneScale = 窗口宽 / 459.6 等比放大——
 *         按钮顶边钉在 窗口高-96vp，放大后向下伸出屏幕底边。
 *
 * 三态实测（同一套设计值；系统导航条（小白条）占屏幕底部约 34vp）：
 *   单屏态      459.6×672vp   —— ×1.000：按钮 y (H-96)～(H-44)，下沿在导航条上方
 *   双屏态竖屏  664.7×939.6vp —— ×1.446：按钮高 75.2vp，y (H-96)～(H-20.8)，
 *                                下部 13.2vp 压进导航条
 *   双屏态横屏  939.6×664.7vp —— ×2.044：按钮高 106.3vp，y (H-96)～(H+10.3)，
 *                                伸出屏幕底 10.3vp，加上导航条 34vp，
 *                                「开始游戏」下半截贴着屏幕底边被小白条盖住一半
 *
 * 问题表现（双屏态）：
 *   开始键不避让导航条：按钮顶边钉死在窗口底上方 96vp，窗口变宽后按钮等比放大
 *   只向下生长，双屏竖屏起下沿压进导航条，横屏时按钮底部冲出屏幕，
 *   「开始游戏」被导航条小白条盖住近一半、难以点击。单屏态下按钮完整可点。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 单屏态窗口宽度（1264px / 密度 2.75），整页横向尺寸的基准 */
const GS_BASE_WIDTH: number = 459.6;

/** 配色 */
const GS_GOLD: string = '#F6D693';
const GS_GOLD_DIM: string = '#F2D9A4';
const GS_SUB_BLUE: string = '#9FB2E8';
const GS_TEXT_MUTED: string = '#AFC0E8';
const GS_TEXT_FAINT: string = '#7C89B8';
const GS_BUTTON_TEXT: string = '#5A3A10';
const GS_STAR_COLOR: string = '#F4F7FF';

/** 顶部按钮行：固定顶部留白（避开状态栏），按钮只向下放大 */
const GS_TOP_SPACE: number = 44;
const GS_CORNER_SIZE: number = 38;
const GS_CORNER_ICON: number = 18;
const GS_CORNER_FONT: number = 10;

/** 居中区 */
const GS_LOGO_FONT: number = 46;
const GS_LOGO_SUB_FONT: number = 12;
const GS_SERVER_PILL: number = 32;
const GS_NOTICE_BAR: number = 34;

/** 底部按钮带：高度固定，按钮顶对齐、按窗口宽度等比放大后向下伸出屏幕底 */
const GS_BOTTOM_BAND: number = 96;
const GS_BUTTON_HEIGHT: number = 52;
const GS_BUTTON_RADIUS: number = 12;
const GS_BUTTON_FONT: number = 19;

/** 星点：位置按窗口宽高比例铺满全屏 */
interface GameStarDot {
  dotKey: string;
  /** 横向位置比例（0～1） */
  dotX: number;
  /** 纵向位置比例（0～1） */
  dotY: number;
  /** 直径（vp，设计值） */
  dotSize: number;
  /** 透明度 */
  dotAlpha: number;
}

/** 最近登录的服务器快选胶囊 */
interface GameServerChip {
  chipKey: string;
  chipName: string;
  /** 是否「热门」服 */
  chipHot: boolean;
}

/** 活动预告小卡 */
interface GameActivityCard {
  actKey: string;
  actTitle: string;
  actSub: string;
  actTopColor: string;
  actBottomColor: string;
  actSymbol: Resource;
}

@Component
export struct GameStartNavBarPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽度（vp），随折叠 / 旋转实时更新；整页缩放比由它算出 */
  @State winWidthVp: number = GS_BASE_WIDTH;

  /** 窗口高度（vp）：星点位置与按钮带由它算出 */
  @State winHeightVp: number = 672;

  private pageActive: boolean = false;
  private windowToken: number = 0;

  private starDots: GameStarDot[] = [];
  private recentServers: GameServerChip[] = [];
  private activityCards: GameActivityCard[] = [];

  aboutToAppear(): void {
    this.pageActive = true;
    this.buildPageData();
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
      this.windowToken = WindowModeController.acquire(win, '#FFFFFF');
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  private buildPageData(): void {
    this.starDots = [
      { dotKey: 'gs-star-1', dotX: 0.12, dotY: 0.18, dotSize: 1.6, dotAlpha: 0.8 },
      { dotKey: 'gs-star-2', dotX: 0.3, dotY: 0.09, dotSize: 1.2, dotAlpha: 0.5 },
      { dotKey: 'gs-star-3', dotX: 0.52, dotY: 0.15, dotSize: 2.2, dotAlpha: 0.9 },
      { dotKey: 'gs-star-4', dotX: 0.74, dotY: 0.11, dotSize: 1.4, dotAlpha: 0.6 },
      { dotKey: 'gs-star-5', dotX: 0.9, dotY: 0.2, dotSize: 1.8, dotAlpha: 0.75 },
      { dotKey: 'gs-star-6', dotX: 0.18, dotY: 0.38, dotSize: 1.3, dotAlpha: 0.45 },
      { dotKey: 'gs-star-7', dotX: 0.42, dotY: 0.3, dotSize: 2.6, dotAlpha: 0.9 },
      { dotKey: 'gs-star-8', dotX: 0.66, dotY: 0.35, dotSize: 1.5, dotAlpha: 0.65 },
      { dotKey: 'gs-star-9', dotX: 0.86, dotY: 0.45, dotSize: 1.2, dotAlpha: 0.4 },
      { dotKey: 'gs-star-10', dotX: 0.1, dotY: 0.58, dotSize: 1.7, dotAlpha: 0.7 },
      { dotKey: 'gs-star-11', dotX: 0.32, dotY: 0.52, dotSize: 1.3, dotAlpha: 0.5 },
      { dotKey: 'gs-star-12', dotX: 0.58, dotY: 0.62, dotSize: 2.0, dotAlpha: 0.85 },
      { dotKey: 'gs-star-13', dotX: 0.78, dotY: 0.66, dotSize: 1.4, dotAlpha: 0.55 },
      { dotKey: 'gs-star-14', dotX: 0.22, dotY: 0.78, dotSize: 1.6, dotAlpha: 0.7 },
      { dotKey: 'gs-star-15', dotX: 0.48, dotY: 0.8, dotSize: 1.2, dotAlpha: 0.4 },
      { dotKey: 'gs-star-16', dotX: 0.7, dotY: 0.86, dotSize: 1.8, dotAlpha: 0.75 }
    ];

    this.recentServers = [
      { chipKey: 'gs-srv-emerald', chipName: '翡翠之力', chipHot: true },
      { chipKey: 'gs-srv-skywing', chipName: '苍穹之翼', chipHot: false },
      { chipKey: 'gs-srv-starfall', chipName: '星陨之地', chipHot: false }
    ];

    this.activityCards = [
      {
        actKey: 'gs-act-level',
        actTitle: '新服冲级',
        actSub: '7日领神装',
        actTopColor: '#5C7CE8',
        actBottomColor: '#3D55B0',
        actSymbol: $r('sys.symbol.flame')
      },
      {
        actKey: 'gs-act-discount',
        actTitle: '限时折扣',
        actSub: '礼包6折起',
        actTopColor: '#E8945A',
        actBottomColor: '#C9622E',
        actSymbol: $r('sys.symbol.gift_fill')
      },
      {
        actKey: 'gs-act-team',
        actTitle: '组队福利',
        actSub: '好友同领',
        actTopColor: '#5AB8A0',
        actBottomColor: '#2E8A72',
        actSymbol: $r('sys.symbol.person_2')
      }
    ];
  }

  /** 整页缩放比：窗口宽度 / 单屏态宽度（459.6vp） */
  private sceneScale(): number {
    if (this.winWidthVp <= 0) {
      return 1;
    }
    return this.winWidthVp / GS_BASE_WIDTH;
  }

  /** 把按单屏态量出的设计值换算到当前窗口 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  // ------------------------------------------------------------------
  // 星空背景
  // ------------------------------------------------------------------

  @Builder
  starField() {
    Column() {
      ForEach(this.starDots, (dot: GameStarDot) => {
        Row()
          .width(this.vs(dot.dotSize))
          .height(this.vs(dot.dotSize))
          .borderRadius(this.vs(dot.dotSize / 2))
          .backgroundColor(GS_STAR_COLOR)
          .opacity(dot.dotAlpha)
          .position({ x: dot.dotX * this.winWidthVp, y: dot.dotY * this.winHeightVp })
      }, (dot: GameStarDot) => dot.dotKey)
    }
    .width('100%')
    .height('100%')
  }

  // ------------------------------------------------------------------
  // 顶部角落按钮：设置 / 公告 / 客服
  // ------------------------------------------------------------------

  @Builder
  cornerButton(entryLabel: string, entrySymbol: Resource) {
    Column({ space: this.vs(4) }) {
      Row() {
        SymbolGlyph(entrySymbol)
          .fontSize(this.vs(GS_CORNER_ICON))
          .fontColor(['#E8EDFA'])
      }
      .width(this.vs(GS_CORNER_SIZE))
      .height(this.vs(GS_CORNER_SIZE))
      .borderRadius(this.vs(GS_CORNER_SIZE / 2))
      .backgroundColor('#2EFFFFFF')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)

      Text(entryLabel)
        .fontSize(this.vs(GS_CORNER_FONT))
        .fontColor('#C9D4F2')
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  topButtonRow() {
    Row() {
      Row({ space: this.vs(16) }) {
        this.cornerButton('设置', $r('sys.symbol.gearshape'))
        this.cornerButton('公告', $r('sys.symbol.bell'))
      }
      .alignItems(VerticalAlign.Top)

      Blank()

      this.cornerButton('客服', $r('sys.symbol.headphones'))
    }
    .width('100%')
    .padding({ left: this.vs(18), right: this.vs(18) })
    .margin({ top: GS_TOP_SPACE })
    .alignItems(VerticalAlign.Top)
  }

  // ------------------------------------------------------------------
  // 居中：Logo + 选服 + 公告
  // ------------------------------------------------------------------

  @Builder
  serverPill() {
    Row({ space: this.vs(5) }) {
      Text('推荐服 · 翡翠之力')
        .fontSize(this.vs(13))
        .fontColor(GS_GOLD_DIM)

      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(this.vs(13))
        .fontColor([GS_GOLD_DIM])
    }
    .height(this.vs(GS_SERVER_PILL))
    .padding({ left: this.vs(16), right: this.vs(13) })
    .borderRadius(this.vs(GS_SERVER_PILL / 2))
    .backgroundColor('#3A2C14')
    .border({ width: 1, color: '#8C6B31' })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  noticeBar() {
    Row({ space: this.vs(7) }) {
      SymbolGlyph($r('sys.symbol.bell'))
        .fontSize(this.vs(14))
        .fontColor(['#F2C864'])

      Text('新版本「苍穹之息」上线，登录领限定头像框')
        .fontSize(this.vs(11.5))
        .fontColor(GS_TEXT_MUTED)
        .maxLines(1)
    }
    .height(this.vs(GS_NOTICE_BAR))
    .padding({ left: this.vs(14), right: this.vs(14) })
    .borderRadius(this.vs(GS_NOTICE_BAR / 2))
    .backgroundColor('#1C2444')
    .alignItems(VerticalAlign.Center)
    .margin({ top: this.vs(14) })
  }

  /** 最近登录的服务器快选胶囊 */
  @Builder
  serverChip(chip: GameServerChip) {
    Row({ space: this.vs(4) }) {
      if (chip.chipHot) {
        Row()
          .width(this.vs(4))
          .height(this.vs(4))
          .borderRadius(this.vs(2))
          .backgroundColor('#F2543F')
      }

      Text(chip.chipName)
        .fontSize(this.vs(11.5))
        .fontColor(chip.chipHot ? GS_GOLD_DIM : GS_TEXT_MUTED)
        .maxLines(1)
    }
    .height(this.vs(24))
    .padding({ left: this.vs(11), right: this.vs(11) })
    .borderRadius(this.vs(12))
    .backgroundColor('#1A2440')
    .border({ width: 0.5, color: '#31406B' })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  recentServerRow() {
    Row({ space: this.vs(8) }) {
      ForEach(this.recentServers, (chip: GameServerChip) => {
        this.serverChip(chip)
      }, (chip: GameServerChip) => chip.chipKey + (chip.chipHot ? '#hot' : ''))
    }
    .margin({ top: this.vs(10) })
    .alignItems(VerticalAlign.Center)
  }

  /** 活动预告小卡（三张） */
  @Builder
  activityCard(card: GameActivityCard) {
    Row({ space: this.vs(8) }) {
      SymbolGlyph(card.actSymbol)
        .fontSize(this.vs(17))
        .fontColor(['#FFFFFF'])

      Column({ space: this.vs(2) }) {
        Text(card.actTitle)
          .fontSize(this.vs(12.5))
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .maxLines(1)

        Text(card.actSub)
          .fontSize(this.vs(9.5))
          .fontColor('#D9E4FF')
          .maxLines(1)
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width(this.vs(128))
    .height(this.vs(56))
    .padding({ left: this.vs(11) })
    .borderRadius(this.vs(9))
    .linearGradient({ angle: 135, colors: [[card.actTopColor, 0.0], [card.actBottomColor, 1.0]] })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  activityRow() {
    Row({ space: this.vs(8) }) {
      ForEach(this.activityCards, (card: GameActivityCard) => {
        this.activityCard(card)
      }, (card: GameActivityCard) => card.actKey)
    }
    .margin({ top: this.vs(18) })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  logoBlock() {
    Column() {
      Text('星辰幻想')
        .fontSize(this.vs(GS_LOGO_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(GS_GOLD)

      Text('STARFANTASY · 苍穹之约')
        .fontSize(this.vs(GS_LOGO_SUB_FONT))
        .fontColor(GS_SUB_BLUE)
        .margin({ top: this.vs(8) })

      this.serverPill()

      this.recentServerRow()

      this.noticeBar()

      this.activityRow()

      Text('v2.31.1 · 资源已就绪')
        .fontSize(this.vs(10))
        .fontColor(GS_TEXT_FAINT)
        .margin({ top: this.vs(24) })
    }
    .alignItems(HorizontalAlign.Center)
  }

  // ------------------------------------------------------------------
  // 底部「开始游戏」按钮（顶边钉在窗口底上方 96vp，向下放大）
  // ------------------------------------------------------------------

  @Builder
  bottomBand() {
    Stack({ alignContent: Alignment.Top }) {
      Row() {
        Text('开始游戏')
          .fontSize(this.vs(GS_BUTTON_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(GS_BUTTON_TEXT)
      }
      .width('72%')
      .height(this.vs(GS_BUTTON_HEIGHT))
      .borderRadius(this.vs(GS_BUTTON_RADIUS))
      .linearGradient({ angle: 135, colors: [['#FBE3A2', 0.0], ['#EBAC4E', 1.0]] })
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(GS_BOTTOM_BAND)
  }

  build() {
    NavDestination() {
      Stack() {
        this.starField()

        Column() {
          this.topButtonRow()

          Column() {
            this.logoBlock()
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)

          this.bottomBand()
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height('100%')
      .linearGradient({ angle: 180, colors: [['#0A1637', 0.0], ['#14275F', 0.55], ['#081022', 1.0]] })
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
