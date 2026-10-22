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
 * 反例：未避让安全区 / 微博发布按钮压挖孔（挖孔）
 *
 * 复刻对象：微博「首页」横屏 —— 白色顶栏（头像 + 「微博」logo、居中「关注 / 热门 / 视频」
 *   三频道、右侧搜索、消息（带红点）、橙色「+」发布按钮）、下方信息流卡片
 *   （头像 + 昵称 + 时间 + 正文 + 配图九宫格式大图 + 转发/评论/赞操作行）。
 *
 * 设计基准：以单屏折叠态窗口宽 459.6vp 为基准（真机 Pura X Max 双屏横屏截图
 *   2584×1828px、密度 2.75 等比折算，页面所有尺寸按窗口宽度 / 459.6 等比换算）：
 *   顶栏行高 16vp；头像 16vp；频道文字 11~12.5vp；右侧搜索/消息图标 15vp；
 *   发布按钮 16×15vp、距右 3.4vp（截图 x2475~2565、y122~205 量出）；
 *   信息流卡片头像 18vp、正文 11.5vp、配图 340×134vp、操作行 10vp。
 *
 * 挖孔实测（Pura X Max，密度 2.75，hidumper DisplayManagerService BoundingRects）：
 *   单屏态        459.6×672vp   —— 挖孔圆 24vp，顶部正中（x 218~242vp，y 9.5~33.5vp）；
 *   双屏态竖屏    664.7×939.6vp —— 挖孔圆 26.2vp，右下角（距右 10.2vp、距底 15.3vp）；
 *   双屏态横屏    939.6×664.7vp —— 挖孔圆 26.2vp，右上角（距右 15.3vp、距顶 10.2vp）。
 *
 * 三态实测：
 *   单屏态        459.6×672vp   —— 顶栏从窗口顶边铺起（y 0~16vp），居中的「热门」
 *                                 频道字落在 x 205~255vp，顶部正中挖孔圆
 *                                 （x 218~242vp、y 9.5~33.5vp）把「热门」二字下半段
 *                                 削掉，圆孔下缘继续压进首条微博卡片的昵称行；
 *   双屏态竖屏    664.7×939.6vp —— 顶栏放大到 y 0~23vp，发布按钮落在
 *                                 x 637~660vp，状态栏图标压在头像与「微博」logo 上
 *                                 （挖孔在右下角，不与顶栏相交）；
 *   双屏态横屏    939.6×664.7vp —— 顶栏放大到 y 0~33vp，发布按钮放大到
 *                                 x 899.6~932.3vp、y 0~30.7vp，右上角挖孔圆
 *                                 （x 898.1~924.3vp、y 10.2~36.4vp）从按钮中部
 *                                 整块穿透，白色「+」被黑孔盖住一半。
 *
 * 问题表现：
 *   双屏横屏展开态右上角的前置摄像头挖孔正好钉在橙色「发布」按钮上，黑孔盖住加号
 *   图标的一半；单屏态顶部正中的挖孔则削掉居中频道「热门」的下半截，状态栏时间、
 *   电量同时叠在顶栏头像与频道上。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 缩放基准：单屏折叠态窗口宽度（1264px / 2.75） */
const WB_BASE_WIDTH: number = 459.6;

const WB_PAGE_BG: string = '#F2F2F2';
const WB_CARD_BG: string = '#FFFFFF';
const WB_TEXT_MAIN: string = '#262626';
const WB_TEXT_SUB: string = '#8A8A8A';
const WB_TEXT_LIGHT: string = '#B0B0B0';
const WB_ORANGE: string = '#FF8200';
const WB_LOGO_COLOR: string = '#3B3B3B';

/** 顶栏：行高 16vp、头像 16vp、图标 15vp、发布按钮 16×15vp、距右 3.4vp */
const WB_BAR_HEIGHT: number = 16;
const WB_AVATAR_SIZE: number = 16;
const WB_LOGO_FONT: number = 12.5;
const WB_TAB_FONT: number = 11;
const WB_TAB_ACTIVE_FONT: number = 12.5;
const WB_TAB_GAP: number = 10;
const WB_ICON_SIZE: number = 15;
const WB_COMPOSE_SIZE: number = 16;
const WB_COMPOSE_HEIGHT: number = 15;
const WB_COMPOSE_RIGHT_INSET: number = 3.4;

/** 信息流卡片：头像 18vp、正文 11.5vp、配图 340×134vp、操作行 10vp */
const WB_FEED_AVATAR: number = 18;
const WB_FEED_NAME_FONT: number = 11;
const WB_FEED_META_FONT: number = 9;
const WB_FEED_TEXT_FONT: number = 11.5;
const WB_FEED_IMAGE_WIDTH: number = 340;
const WB_FEED_IMAGE_HEIGHT: number = 134;
const WB_FEED_ACTION_FONT: number = 10;

/** 信息流卡片数据 */
interface WeiboFeedItem {
  feedUser: string;
  feedMeta: string;
  feedText: string;
  feedImage: Resource | undefined;
  feedRepostCount: string;
  feedCommentCount: string;
  feedLikeCount: string;
  feedTint: string;
}

const WB_FEED_LIST: WeiboFeedItem[] = [
  {
    feedUser: '阿圆的旅行手记',
    feedMeta: '今天 12:03 · 来自 鸿蒙手机',
    feedText: '这个秋天，你一定要来一次南京！钟山的风、玄武湖的落日、颐和路的梧桐，都是秋天最好的注脚🍂',
    feedImage: $r('app.media.sa_wb_feed'),
    feedRepostCount: '128',
    feedCommentCount: '2.4万',
    feedLikeCount: '8961',
    feedTint: '#5B8DEF'
  },
  {
    feedUser: '数码底层逻辑',
    feedMeta: '13:05 · 来自 微博网页版',
    feedText: '折叠屏展开以后挖孔跑到了屏幕角落，应用的悬浮按钮到底该不该避让？评论区聊聊你的看法。',
    feedImage: undefined,
    feedRepostCount: '356',
    feedCommentCount: '1892',
    feedLikeCount: '5230',
    feedTint: '#E8635A'
  }
];

/** 频道列表 */
interface WeiboTabItem {
  tabLabel: string;
  tabActive: boolean;
}

const WB_TAB_LIST: WeiboTabItem[] = [
  { tabLabel: '关注', tabActive: false },
  { tabLabel: '热门', tabActive: true },
  { tabLabel: '视频', tabActive: false }
];

@Component
export struct WeiboHomeComposeNotchPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = WB_BASE_WIDTH;
  @State winHeightVp: number = 672;

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

  /** 场景缩放比：当前窗口宽 / 单屏折叠态基准宽 */
  private sceneScale(): number {
    return this.winWidthVp / WB_BASE_WIDTH;
  }

  /** 把基准宽下的设计值换算到当前窗口宽度 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  /** 顶栏：头像 + logo + 居中频道 + 搜索/消息/发布 */
  @Builder
  homeTopBar() {
    Stack({ alignContent: Alignment.Center }) {
      Row() {
        ForEach(WB_TAB_LIST, (tab: WeiboTabItem) => {
          Text(tab.tabLabel)
            .fontSize(this.vs(tab.tabActive ? WB_TAB_ACTIVE_FONT : WB_TAB_FONT))
            .fontWeight(tab.tabActive ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(tab.tabActive ? WB_TEXT_MAIN : WB_TEXT_SUB)
            .margin({ left: this.vs(WB_TAB_GAP / 2), right: this.vs(WB_TAB_GAP / 2) })
        }, (tab: WeiboTabItem) => tab.tabLabel)
      }
      .alignItems(VerticalAlign.Center)

      Row() {
        Column() {
          Text('圆')
            .fontSize(this.vs(9))
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
        }
        .width(this.vs(WB_AVATAR_SIZE))
        .height(this.vs(WB_AVATAR_SIZE))
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#7A8BA6')
        .borderRadius(this.vs(WB_AVATAR_SIZE / 2))
        .onClick(() => {
          this.pageStack.pop();
        })

        Text('微博')
          .fontSize(this.vs(WB_LOGO_FONT))
          .fontWeight(FontWeight.Bold)
          .fontColor(WB_LOGO_COLOR)
          .margin({ left: this.vs(6) })

        Blank()

        Stack({ alignContent: Alignment.TopEnd }) {
          SymbolGlyph($r('sys.symbol.magnifyingglass'))
            .fontSize(this.vs(WB_ICON_SIZE))
            .fontColor([WB_TEXT_MAIN])
        }
        .margin({ right: this.vs(14) })

        Stack({ alignContent: Alignment.TopEnd }) {
          SymbolGlyph($r('sys.symbol.envelope'))
            .fontSize(this.vs(WB_ICON_SIZE))
            .fontColor([WB_TEXT_MAIN])

          Circle()
            .width(this.vs(4))
            .height(this.vs(4))
            .fill(WB_ORANGE)
            .offset({ x: this.vs(1), y: this.vs(-1) })
        }
        .margin({ right: this.vs(9) })

        Stack({ alignContent: Alignment.Center }) {
          Text('+')
            .fontSize(this.vs(12))
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
        }
        .width(this.vs(WB_COMPOSE_SIZE))
        .height(this.vs(WB_COMPOSE_HEIGHT))
        .backgroundColor(WB_ORANGE)
        .borderRadius(this.vs(4))
      }
      .width('100%')
      .height('100%')
      .padding({ left: this.vs(5), right: this.vs(WB_COMPOSE_RIGHT_INSET) })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(this.vs(WB_BAR_HEIGHT))
    .backgroundColor(WB_CARD_BG)
  }

  @Builder
  feedCard(feed: WeiboFeedItem) {
    Column() {
      Row() {
        Column() {
          Text(feed.feedUser.substring(0, 1))
            .fontSize(this.vs(10))
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
        }
        .width(this.vs(WB_FEED_AVATAR))
        .height(this.vs(WB_FEED_AVATAR))
        .justifyContent(FlexAlign.Center)
        .backgroundColor(feed.feedTint)
        .borderRadius(this.vs(WB_FEED_AVATAR / 2))

        Column() {
          Text(feed.feedUser)
            .fontSize(this.vs(WB_FEED_NAME_FONT))
            .fontWeight(FontWeight.Bold)
            .fontColor(WB_TEXT_MAIN)

          Text(feed.feedMeta)
            .fontSize(this.vs(WB_FEED_META_FONT))
            .fontColor(WB_TEXT_LIGHT)
            .margin({ top: this.vs(2) })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: this.vs(8) })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Text(feed.feedText)
        .fontSize(this.vs(WB_FEED_TEXT_FONT))
        .fontColor(WB_TEXT_MAIN)
        .lineHeight(this.vs(17))
        .margin({ top: this.vs(7) })

      if (feed.feedImage !== undefined) {
        Image(feed.feedImage)
          .width(this.vs(WB_FEED_IMAGE_WIDTH))
          .height(this.vs(WB_FEED_IMAGE_HEIGHT))
          .objectFit(ImageFit.Cover)
          .borderRadius(this.vs(6))
          .margin({ top: this.vs(8) })
      }

      Row() {
        Column() {
          Row({ space: this.vs(4) }) {
            SymbolGlyph($r('sys.symbol.arrow_right_up_and_square'))
              .fontSize(this.vs(12))
              .fontColor([WB_TEXT_SUB])

            Text(feed.feedRepostCount)
              .fontSize(this.vs(WB_FEED_ACTION_FONT))
              .fontColor(WB_TEXT_SUB)
          }
          .alignItems(VerticalAlign.Center)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Row({ space: this.vs(4) }) {
            SymbolGlyph($r('sys.symbol.message'))
              .fontSize(this.vs(12))
              .fontColor([WB_TEXT_SUB])

            Text(feed.feedCommentCount)
              .fontSize(this.vs(WB_FEED_ACTION_FONT))
              .fontColor(WB_TEXT_SUB)
          }
          .alignItems(VerticalAlign.Center)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Row({ space: this.vs(4) }) {
            SymbolGlyph($r('sys.symbol.hand_thumbsup'))
              .fontSize(this.vs(12))
              .fontColor([WB_TEXT_SUB])

            Text(feed.feedLikeCount)
              .fontSize(this.vs(WB_FEED_ACTION_FONT))
              .fontColor(WB_TEXT_SUB)
          }
          .alignItems(VerticalAlign.Center)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .margin({ top: this.vs(10) })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(this.vs(12))
    .backgroundColor(WB_CARD_BG)
    .margin({ bottom: this.vs(6) })
  }

  build() {
    NavDestination() {
      Column() {
        this.homeTopBar()

        Scroll() {
          Column() {
            ForEach(WB_FEED_LIST, (feed: WeiboFeedItem) => {
              this.feedCard(feed)
            }, (feed: WeiboFeedItem) => feed.feedUser)

            Row()
              .width('100%')
              .height(this.vs(20))
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .backgroundColor(WB_PAGE_BG)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(WB_PAGE_BG)
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
