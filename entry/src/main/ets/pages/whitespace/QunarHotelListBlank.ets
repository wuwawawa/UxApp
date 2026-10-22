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
 * 反例：留白过多 / 去哪儿酒店列表挤一侧
 *
 * 复刻对象：去哪儿旅行 App 酒店列表页，双屏横屏。顶部整窗宽的蓝色渐变头：
 *   左返回箭头、白色搜索胶囊（「上海 · 酒店」+ 日期「07-18/07-19」）、右侧「搜索」；
 *   下面整窗宽的筛选条（位置区域 / 星级 / 价格 / 排序 / 筛选）；
 *   再往下是酒店卡片单列——左侧渐变图片占位（上海外滩W酒店 / 上海和平饭店 /
 *   上海苏宁宝丽嘉酒店 / 上海静安昆仑大酒店 / 亚朵S酒店 / 全季酒店 / 汉庭酒店），
 *   卡内是酒店名、橙色评分（4.9 超棒）与点评数、标签（免费取消 / 含早餐）、
 *   地址距离、右侧橙色价格。卡片全部固定在 459.6vp 的单屏内容列里贴左排布，
 *   右侧只剩页面底色，横屏时右半屏全是空白。
 *
 * 设计基准：以单屏折叠态 459.6×672vp 为基准宽度 1:1 还原移动端排版。
 *   所有尺寸 / 字号按 窗口宽度 / 459.6 换算（sceneScale）后把倍率钳制在 1.05
 *   ——宽窗口下卡片列只放大 5%，不重排、不分栏，右侧留白随窗口宽度线性增大。
 *   状态栏占位 36vp；头部高 88vp（蓝渐变 #2577E8 → #5BA3FF）；
 *   搜索胶囊高 36vp；筛选条高 44vp、筛选胶囊高 28vp；
 *   酒店卡图 110×110vp、圆角 8vp；酒店名 15vp、评分 14vp、
 *   标签字 10vp、价格数字 18vp；卡片间距 8vp。
 *
 * 三态实测（内容列宽 = 459.6 × sceneScale，右缘之外全是页面底色的空白）：
 *   单屏态      459.6×672vp   —— 内容列与窗口同宽，无额外留白（正常形态）；
 *   双屏态竖屏  664.7×939.6vp —— 内容列 482.6vp，右侧空出 182.1vp，约占宽度的 27%；
 *   双屏态横屏  939.6×664.7vp —— 内容列 482.6vp，右侧空出 457.0vp，约占宽度的 49%，
 *                                酒店卡片只占左侧一列，右半屏全是空白。
 *
 * 问题表现：
 *   酒店卡片全部锁死在一条手机宽度里贴左排；窗口展开后卡片既不铺满也不分栏，
 *   右半屏从筛选条底边到屏幕底边都是空页面底色；
 *   头部蓝条与筛选条横贯整窗，反而把卡片列右侧的大片留白衬得格外刺眼。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 配色：浅灰页面、白卡片、近黑正文、灰副标题、去哪儿蓝、橙评分 / 价格 */
const WSQNR_PAGE_BG: string = '#F4F5F7';
const WSQNR_CARD_BG: string = '#FFFFFF';
const WSQNR_TEXT_MAIN: string = '#1F1F26';
const WSQNR_TEXT_SUB: string = '#8E8E99';
const WSQNR_BLUE_TOP: string = '#2577E8';
const WSQNR_BLUE_BOTTOM: string = '#5BA3FF';
const WSQNR_ORANGE: string = '#FF6A00';
const WSQNR_TAG_TEXT: string = '#3C6EA5';
const WSQNR_TAG_BG: string = '#EBF2FA';
const WSQNR_FILTER_BG: string = '#F2F3F5';

/** 基准：单屏折叠态窗口宽 459.6vp；宽窗口下缩放倍率钳制在 1.05 */
const WSQNR_BASE_WIDTH: number = 459.6;
const WSQNR_MAX_SCALE: number = 1.05;

/** 头部：状态栏占位 36vp + 内容行 52vp = 88vp */
const WSQNR_STATUS_PAD: number = 36;
const WSQNR_HEADER_HEIGHT: number = 88;
const WSQNR_HEADER_PAD_SIDE: number = 12; const WSQNR_HEADER_GAP: number = 10;
const WSQNR_SEARCH_PILL_HEIGHT: number = 36; const WSQNR_SEARCH_PILL_RADIUS: number = 18;
const WSQNR_SEARCH_PILL_PAD: number = 12; const WSQNR_SEARCH_TEXT_FONT: number = 14;
const WSQNR_SEARCH_SUB_FONT: number = 12; const WSQNR_SEARCH_ICON: number = 16;
const WSQNR_ACTION_FONT: number = 14; const WSQNR_BACK_ICON: number = 22;

/** 筛选条：整窗宽、高 44vp；筛选胶囊高 28vp、字 12vp */
const WSQNR_FILTER_HEIGHT: number = 44; const WSQNR_FILTER_PAD_SIDE: number = 12;
const WSQNR_FILTER_GAP: number = 8; const WSQNR_FILTER_CHIP_H: number = 28;
const WSQNR_FILTER_CHIP_FONT: number = 12; const WSQNR_FILTER_CHIP_PAD_H: number = 10;
const WSQNR_FILTER_CHIP_ICON: number = 10;

/** 酒店卡：图 110×110vp、卡片间距 8vp、圆角 10vp、内边距 10vp */
const WSQNR_HOTEL_IMG: number = 110; const WSQNR_HOTEL_IMG_RADIUS: number = 8;
const WSQNR_HOTEL_INITIAL_FONT: number = 26; const WSQNR_CARD_GAP: number = 8;
const WSQNR_CARD_RADIUS: number = 10; const WSQNR_CARD_PAD: number = 10;
const WSQNR_HOTEL_NAME_FONT: number = 15; const WSQNR_SCORE_FONT: number = 14;
const WSQNR_SCORE_SUB_FONT: number = 11; const WSQNR_TAG_FONT: number = 10;
const WSQNR_TAG_PAD_H: number = 6; const WSQNR_TAG_PAD_V: number = 2;
const WSQNR_TAG_RADIUS: number = 7; const WSQNR_TAG_GAP: number = 4;
const WSQNR_LOC_FONT: number = 11; const WSQNR_PRICE_FONT: number = 18;
const WSQNR_PRICE_YEN_FONT: number = 11; const WSQNR_PRICE_UNIT_FONT: number = 10;
const WSQNR_INFO_GAP: number = 5; const WSQNR_LIST_PAD_SIDE: number = 12;
const WSQNR_LIST_TOP: number = 10; const WSQNR_FOOTER_FONT: number = 12;
const WSQNR_FOOTER_MARGIN: number = 16;

/** 筛选胶囊 */
interface QunarFilterChip {
  chipKey: string;
  chipLabel: string;
}

/** 酒店卡片 */
interface QunarHotelItem {
  hotelKey: string;
  hotelName: string;
  hotelScore: string;
  hotelScoreLabel: string;
  hotelCommentCount: string;
  hotelTags: string[];
  hotelLocation: string;
  hotelDistance: string;
  hotelPrice: string;
  hotelInitial: string;
  imgTopColor: string;
  imgBottomColor: string;
}

const WSQNR_FILTERS: QunarFilterChip[] = [
  { chipKey: 'qnr-filter-area', chipLabel: '位置：人民广场' },
  { chipKey: 'qnr-filter-star', chipLabel: '星级：四星/五星' },
  { chipKey: 'qnr-filter-price', chipLabel: '价格：¥300-900' },
  { chipKey: 'qnr-filter-sort', chipLabel: '排序：推荐' },
  { chipKey: 'qnr-filter-more', chipLabel: '筛选' }
];

const WSQNR_HOTELS: QunarHotelItem[] = [
  {
    hotelKey: 'qnr-hotel-w',
    hotelName: '上海外滩W酒店',
    hotelScore: '4.9',
    hotelScoreLabel: '超棒',
    hotelCommentCount: '1.6万条点评',
    hotelTags: ['含早餐', '免费取消', '江景房'],
    hotelLocation: '外滩/十六铺地区',
    hotelDistance: '距地铁10号线0.3km',
    hotelPrice: '1288',
    hotelInitial: 'W',
    imgTopColor: '#2E2E38',
    imgBottomColor: '#5A5A6E'
  },
  {
    hotelKey: 'qnr-hotel-peace',
    hotelName: '上海和平饭店',
    hotelScore: '4.8',
    hotelScoreLabel: '超棒',
    hotelCommentCount: '2.3万条点评',
    hotelTags: ['免费取消', '历史建筑'],
    hotelLocation: '南京东路地区',
    hotelDistance: '距地铁2号线0.2km',
    hotelPrice: '1688',
    hotelInitial: '和',
    imgTopColor: '#3B2C52',
    imgBottomColor: '#7A5B9E'
  },
  {
    hotelKey: 'qnr-hotel-bellagio',
    hotelName: '上海苏宁宝丽嘉酒店',
    hotelScore: '4.8',
    hotelScoreLabel: '超棒',
    hotelCommentCount: '8600条点评',
    hotelTags: ['立即确认', '含双早'],
    hotelLocation: '苏州河北岸',
    hotelDistance: '距地铁12号线0.4km',
    hotelPrice: '1088',
    hotelInitial: '宝',
    imgTopColor: '#1F3A5F',
    imgBottomColor: '#4872A8'
  },
  {
    hotelKey: 'qnr-hotel-kunlun',
    hotelName: '上海静安昆仑大酒店',
    hotelScore: '4.7',
    hotelScoreLabel: '很棒',
    hotelCommentCount: '1.1万条点评',
    hotelTags: ['免费取消', '含早餐', '可开发票'],
    hotelLocation: '静安寺地区',
    hotelDistance: '距地铁7号线0.3km',
    hotelPrice: '799',
    hotelInitial: '昆',
    imgTopColor: '#0E4C5A',
    imgBottomColor: '#3D8FA3'
  },
  {
    hotelKey: 'qnr-hotel-atour',
    hotelName: '亚朵S酒店(上海外滩金陵东路店)',
    hotelScore: '4.7',
    hotelScoreLabel: '很棒',
    hotelCommentCount: '9800条点评',
    hotelTags: ['几木大床房', '免费取消'],
    hotelLocation: '外滩/豫园地区',
    hotelDistance: '距地铁10号线0.5km',
    hotelPrice: '558',
    hotelInitial: '亚',
    imgTopColor: '#22392B',
    imgBottomColor: '#4E7360'
  },
  {
    hotelKey: 'qnr-hotel-ji',
    hotelName: '全季酒店(上海人民广场福州路店)',
    hotelScore: '4.6',
    hotelScoreLabel: '很棒',
    hotelCommentCount: '1.4万条点评',
    hotelTags: ['立即确认', '行李寄存'],
    hotelLocation: '人民广场地区',
    hotelDistance: '距地铁1号线0.3km',
    hotelPrice: '428',
    hotelInitial: '全',
    imgTopColor: '#37414E',
    imgBottomColor: '#6B7889'
  },
  {
    hotelKey: 'qnr-hotel-hanting',
    hotelName: '汉庭酒店(上海外滩延安东路店)',
    hotelScore: '4.5',
    hotelScoreLabel: '不错',
    hotelCommentCount: '2.1万条点评',
    hotelTags: ['免费取消', '24小时热水'],
    hotelLocation: '外滩/南外滩地区',
    hotelDistance: '距地铁10号线0.4km',
    hotelPrice: '298',
    hotelInitial: '汉',
    imgTopColor: '#8A2333',
    imgBottomColor: '#C25B6A'
  }
];

@Component
export struct QunarHotelListBlankPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽度（vp），随折叠 / 旋转实时更新 */
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
      this.windowToken = WindowModeController.acquire(win, '#FFFFFF');
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  /** 整页缩放比：窗口宽度 / 单屏基准宽度（459.6vp），
   *  放大倍率钳制在 1.05 —— 宽窗口下卡片列只轻微放大、不铺满窗口（留白反例根源） */
  private sceneScale(): number {
    if (this.winWidthVp <= 0) {
      return 1;
    }
    return Math.min(this.winWidthVp / WSQNR_BASE_WIDTH, WSQNR_MAX_SCALE);
  }

  /** 把基准宽度下的设计值换算到当前窗口 */
  private vs(baseVp: number): number {
    return baseVp * this.sceneScale();
  }

  // ------------------------------------------------------------------
  // 顶部：整窗宽蓝色渐变头（返回 + 目的地搜索胶囊 + 搜索）
  // ------------------------------------------------------------------

  @Builder
  searchPill() {
    Row({ space: this.vs(WSQNR_HEADER_GAP) }) {
      SymbolGlyph($r('sys.symbol.magnifyingglass'))
        .fontSize(this.vs(WSQNR_SEARCH_ICON))
        .fontColor([WSQNR_TEXT_SUB])

      Text('上海 · 酒店')
        .fontSize(this.vs(WSQNR_SEARCH_TEXT_FONT))
        .fontWeight(FontWeight.Medium)
        .fontColor(WSQNR_TEXT_MAIN)
        .maxLines(1)

      Blank()

      SymbolGlyph($r('sys.symbol.calendar'))
        .fontSize(this.vs(WSQNR_SEARCH_ICON))
        .fontColor([WSQNR_BLUE_TOP])

      Text('07-18/07-19')
        .fontSize(this.vs(WSQNR_SEARCH_SUB_FONT))
        .fontColor(WSQNR_TEXT_SUB)
        .maxLines(1)
    }
    .height(this.vs(WSQNR_SEARCH_PILL_HEIGHT))
    .layoutWeight(1)
    .padding({
      left: this.vs(WSQNR_SEARCH_PILL_PAD),
      right: this.vs(WSQNR_SEARCH_PILL_PAD)
    })
    .backgroundColor(WSQNR_CARD_BG)
    .borderRadius(this.vs(WSQNR_SEARCH_PILL_RADIUS))
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  headerBand() {
    Row({ space: this.vs(WSQNR_HEADER_GAP) }) {
      SymbolGlyph($r('sys.symbol.chevron_left'))
        .fontSize(this.vs(WSQNR_BACK_ICON))
        .fontColor([Color.White])
        .width(this.vs(40))
        .height(this.vs(40))
        .onClick(() => {
          this.pageStack.pop();
        })

      this.searchPill()

      Text('搜索')
        .fontSize(this.vs(WSQNR_ACTION_FONT))
        .fontColor(Color.White)
        .maxLines(1)
    }
    .width('100%')
    .height(this.vs(WSQNR_HEADER_HEIGHT))
    .padding({
      left: this.vs(WSQNR_HEADER_PAD_SIDE),
      right: this.vs(WSQNR_HEADER_PAD_SIDE),
      top: this.vs(WSQNR_STATUS_PAD)
    })
    .linearGradient({
      angle: 180,
      colors: [[WSQNR_BLUE_TOP, 0.0], [WSQNR_BLUE_BOTTOM, 1.0]]
    })
    .alignItems(VerticalAlign.Center)
  }

  // ------------------------------------------------------------------
  // 筛选条：整窗宽（位置 / 星级 / 价格 / 排序 / 筛选）
  // ------------------------------------------------------------------

  @Builder
  filterBar() {
    Row({ space: this.vs(WSQNR_FILTER_GAP) }) {
      ForEach(WSQNR_FILTERS, (chip: QunarFilterChip) => {
        Row({ space: this.vs(2) }) {
          Text(chip.chipLabel)
            .fontSize(this.vs(WSQNR_FILTER_CHIP_FONT))
            .fontColor(WSQNR_TEXT_MAIN)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontSize(this.vs(WSQNR_FILTER_CHIP_ICON))
            .fontColor([WSQNR_TEXT_SUB])
        }
        .height(this.vs(WSQNR_FILTER_CHIP_H))
        .padding({
          left: this.vs(WSQNR_FILTER_CHIP_PAD_H),
          right: this.vs(WSQNR_FILTER_CHIP_PAD_H)
        })
        .backgroundColor(WSQNR_FILTER_BG)
        .borderRadius(this.vs(WSQNR_FILTER_CHIP_H / 2))
        .alignItems(VerticalAlign.Center)
      }, (chip: QunarFilterChip) => chip.chipKey)
    }
    .width('100%')
    .height(this.vs(WSQNR_FILTER_HEIGHT))
    .padding({ left: this.vs(WSQNR_FILTER_PAD_SIDE), right: this.vs(WSQNR_FILTER_PAD_SIDE) })
    .backgroundColor(WSQNR_CARD_BG)
    .alignItems(VerticalAlign.Center)
  }

  // ------------------------------------------------------------------
  // 酒店卡片
  // ------------------------------------------------------------------

  @Builder
  hotelImage(hotel: QunarHotelItem) {
    Stack({ alignContent: Alignment.Center }) {
      SymbolGlyph($r('sys.symbol.building'))
        .fontSize(this.vs(WSQNR_HOTEL_INITIAL_FONT))
        .fontColor([Color.White])
        .opacity(0.55)

      Text(hotel.hotelInitial)
        .fontSize(this.vs(WSQNR_HOTEL_INITIAL_FONT))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .maxLines(1)
    }
    .width(this.vs(WSQNR_HOTEL_IMG))
    .height(this.vs(WSQNR_HOTEL_IMG))
    .linearGradient({
      angle: 140,
      colors: [[hotel.imgTopColor, 0.0], [hotel.imgBottomColor, 1.0]]
    })
    .borderRadius(this.vs(WSQNR_HOTEL_IMG_RADIUS))
  }

  @Builder
  hotelCard(hotel: QunarHotelItem) {
    Row({ space: this.vs(WSQNR_INFO_GAP + 5) }) {
      this.hotelImage(hotel)

      Column({ space: this.vs(WSQNR_INFO_GAP) }) {
        Text(hotel.hotelName)
          .fontSize(this.vs(WSQNR_HOTEL_NAME_FONT))
          .fontWeight(FontWeight.Medium)
          .fontColor(WSQNR_TEXT_MAIN)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row({ space: this.vs(WSQNR_INFO_GAP) }) {
          Text(hotel.hotelScore)
            .fontSize(this.vs(WSQNR_SCORE_FONT))
            .fontWeight(FontWeight.Bold)
            .fontColor(WSQNR_ORANGE)
            .maxLines(1)

          Text(hotel.hotelScoreLabel)
            .fontSize(this.vs(WSQNR_SCORE_SUB_FONT))
            .fontColor(WSQNR_ORANGE)
            .maxLines(1)

          Text(hotel.hotelCommentCount)
            .fontSize(this.vs(WSQNR_SCORE_SUB_FONT))
            .fontColor(WSQNR_TEXT_SUB)
            .maxLines(1)
        }
        .width('100%')
        .alignItems(VerticalAlign.Bottom)

        Row({ space: this.vs(WSQNR_TAG_GAP) }) {
          ForEach(hotel.hotelTags, (tag: string) => {
            Text(tag)
              .fontSize(this.vs(WSQNR_TAG_FONT))
              .fontColor(WSQNR_TAG_TEXT)
              .maxLines(1)
              .padding({
                left: this.vs(WSQNR_TAG_PAD_H),
                right: this.vs(WSQNR_TAG_PAD_H),
                top: this.vs(WSQNR_TAG_PAD_V),
                bottom: this.vs(WSQNR_TAG_PAD_V)
              })
              .backgroundColor(WSQNR_TAG_BG)
              .borderRadius(this.vs(WSQNR_TAG_RADIUS))
          }, (tag: string) => hotel.hotelKey + '-' + tag)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        Row({ space: this.vs(3) }) {
          SymbolGlyph($r('sys.symbol.pin'))
            .fontSize(this.vs(WSQNR_LOC_FONT))
            .fontColor([WSQNR_TEXT_SUB])

          Text(hotel.hotelLocation + ' · ' + hotel.hotelDistance)
            .fontSize(this.vs(WSQNR_LOC_FONT))
            .fontColor(WSQNR_TEXT_SUB)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Column({ space: this.vs(4) }) {
        Row() {
          Text('¥')
            .fontSize(this.vs(WSQNR_PRICE_YEN_FONT))
            .lineHeight(this.vs(16))
            .fontColor(WSQNR_ORANGE)
            .maxLines(1)
            .margin({ bottom: this.vs(2) })

          Text(hotel.hotelPrice)
            .fontSize(this.vs(WSQNR_PRICE_FONT))
            .lineHeight(this.vs(24))
            .fontWeight(FontWeight.Bold)
            .fontColor(WSQNR_ORANGE)
            .maxLines(1)
        }
        .alignItems(VerticalAlign.Bottom)

        Text('起')
          .fontSize(this.vs(WSQNR_PRICE_UNIT_FONT))
          .fontColor(WSQNR_TEXT_SUB)
          .maxLines(1)
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .padding(this.vs(WSQNR_CARD_PAD))
    .backgroundColor(WSQNR_CARD_BG)
    .borderRadius(this.vs(WSQNR_CARD_RADIUS))
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  hotelList() {
    Column({ space: this.vs(WSQNR_CARD_GAP) }) {
      ForEach(WSQNR_HOTELS, (hotel: QunarHotelItem) => {
        this.hotelCard(hotel)
      }, (hotel: QunarHotelItem) => hotel.hotelKey)

      Text('— 已为你展示 7 家酒店 · 查看更多 —')
        .fontSize(this.vs(WSQNR_FOOTER_FONT)).fontColor(WSQNR_TEXT_SUB).maxLines(1)
        .width('100%').textAlign(TextAlign.Center)
        .margin({ top: this.vs(WSQNR_FOOTER_MARGIN / 2), bottom: this.vs(WSQNR_FOOTER_MARGIN) })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({
      left: this.vs(WSQNR_LIST_PAD_SIDE),
      right: this.vs(WSQNR_LIST_PAD_SIDE),
      top: this.vs(WSQNR_LIST_TOP)
    })
  }

  // ------------------------------------------------------------------
  // 内容列：固定基准宽度、贴窗口左缘，右侧留白
  // ------------------------------------------------------------------

  @Builder
  contentStage() {
    Row() {
      Column() {
        Scroll() {
          Column() {
            this.hotelList()
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.None)
        .align(Alignment.Start)
      }
      .width(this.vs(WSQNR_BASE_WIDTH))
      .height('100%')
      .backgroundColor(WSQNR_PAGE_BG)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .layoutWeight(1)
    .alignItems(VerticalAlign.Top)
    .backgroundColor(WSQNR_PAGE_BG)
  }

  build() {
    NavDestination() {
      Column() {
        this.headerBand()

        this.filterBar()

        this.contentStage()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(WSQNR_PAGE_BG)
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
