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
 * 反例：留白过多 / 招聘结果卡片右侧大片空白
 *
 * 复刻对象：58同城式招聘搜索结果页，双屏横屏截图。顶部返回箭头 + 胶囊搜索框（框内左侧一个
 *   灰色关键词小标签「华为公司 ×」，标签右边到胶囊右端是一整片空框）；下面一排横向 tab
 *   （全部 / 商铺租售·生意转让 / 全职招聘 / 网络布线·维护 / 手机·电脑·数码回收），「全部」
 *   下方一段红色短下划线。再往下白色卡片：「全职招聘」分组标题（前面红色圆形小图标），
 *   3 条岗位——标题「华为手机招质检月7500包吃住可预支」、红色薪资「7500-8000 元」+ 灰色
 *   职位名「质量检验员/测试员」、灰底小标签「包吃」「包住」「加班补助」、圆形头像 + 联系人 +
 *   公司名；每条右上角灰色「上海·浦东」、右侧贴边红色胶囊按钮「申请」；卡片底部居中
 *   「查看更多服务 ›」。第二张卡片开头是「网络布线/维护」+ 一条标题「全上海安防监控、
 *   网络布线、门禁考勤、无线覆盖、弱电施工」，右下角一块广告图，卡片底部被窗口裁掉。
 *
 * 设计基准：原图 3184×2232px，密度 2.75，vp = px / 2.75，参考窗口 1157.8×811.6vp。
 *   搜索行：胶囊距页顶 40.7（112px）、高 41.5（114px）、圆角 20.7、胶囊左缘 41.8（115px）、
 *           右缘距窗口右边 72.7（200px）；返回箭头 9.5×14.2（26×39px，笔画 2.5，箭头顶 54.2）；
 *           关键词标签高 29.5（81px）、字 12.5、距胶囊左缘 10.2；
 *   tab 行：文字顶 102.2（281px）、字 14.5、左边距 21.8（60px）、tab 间距 28（77px）；
 *           「全部」下划线 16.7×4.4（46×12px）、顶 124.4；白色头部区块底边 128.4（353px）；
 *   卡片：左右外边距 8（22px）、圆角 6（16px）、卡片 1 顶 139.3（383px）、高 561.5（1544px），
 *         卡片间距 12.4（34px）、卡片 2 顶 713.1（1961px）；
 *         卡片 1 内边距 左 18.2（50px）/ 右 16（44px）/ 顶 16.7（46px）/ 底 5.9；
 *   分组头：图标 17.5（48px）、字 16、图标到字 9.5（26px）、分组头到首条 36.7；
 *   岗位条目：首条标题顶 70.9（195px，相对卡片顶）、行距 154.9（426px）；
 *           标题 17（黑）、薪资 18（红 #FF5430）、职位名 13（#A1A1A1，距薪资 8.4）、
 *           标签高 18.9（52px）、字 10.5、标签间距 4.4（12px）；
 *           头像 31.3 / 34.9（86 / 96px）、距姓名 9.5（26px）、姓名 12.5、公司 12（#9A9A9A）；
 *           右侧：地点 10.5（#A5A5A5，右缘 1132.4）、申请按钮 61.8×30.5（170×84px）、
 *           距条目顶 37.1（102px）、按钮右缘 1132.9（3116px）；
 *           左侧文字列宽写死 320（截图里最长一条标题右缘 308.7vp）、条目内容高约 119.3；
 *   底部「查看更多服务 ›」字 14、行高 20、整卡水平居中、距卡片底 5.9；
 *   第二张卡片：内边距 左 13.5 / 顶 14.2、标题 17、右端广告图 93.1×27.6（256×76px）。
 *
 * 三态实测（上表 vp 值固定，条目行仍是整行宽、申请按钮钉右边缘，文字列 320 不随窗口变；
 *   留白 = 窗口宽 − 432.0，
 *   432.0 = 外边距 8 + 内边距 18.2 + 文字列 320 + 按钮 61.8 + 内边距 16 + 外边距 8）：
 *   单屏态      459.6×672vp    —— 留白 27.6vp，约占宽度的 6%（内容几乎撑满）
 *   双屏态竖屏  664.7×939.6vp  —— 留白 232.7vp，约占宽度的 35%
 *   双屏态横屏  939.6×664.7vp  —— 留白 507.6vp，约占宽度的 54%
 *   参考窗口    1157.8×811.6vp —— 留白 725.8vp，约占宽度的 63%（截图量到的就是这一态）
 *   纵向：条目内容高 119.3vp，行距按 154.9vp 排，每条下方空出 35.6vp，约占条目高度的 23%。
 *
 * 问题表现：
 *   三条岗位的标题、薪资、标签、头像全挤在卡片左侧一条窄列里，最长的标题也只写到窗口宽度的
 *   三成；标题右端到右侧红色「申请」按钮之间是一整块没有任何内容的白色，截图里这块空白横跨
 *   窗口六成以上宽度。条目与条目之间还各空出约 36vp 的行距，3 条岗位只占满卡片上半截，
 *   「查看更多服务 ›」被压到卡片最下面。第二条、第三条岗位右侧的空白比第一条更宽。
 *   搜索胶囊里只有一个关键词小标签，标签右边同样是整片空框。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 配色：浅灰页底、白卡片、品牌红按钮、深灰正文、浅灰辅助字 */
const WSJB_PAGE_BG: string = '#F9F9F9';
const WSJB_TEXT_COLOR: string = '#000000';
const WSJB_BRAND_RED: string = '#FF5430';
const WSJB_TAB_TEXT: string = '#383838';
const WSJB_SEARCH_BG: string = '#F9F9F9';
const WSJB_CHIP_BG: string = '#EBEBEB';
const WSJB_CHIP_TEXT: string = '#282828';
const WSJB_TAG_BG: string = '#F5F5F5';
const WSJB_TAG_TEXT: string = '#8B8B8B';
const WSJB_JOBNAME_TEXT: string = '#A1A1A1';
const WSJB_AREA_TEXT: string = '#A5A5A5';
const WSJB_CONTACT_TEXT: string = '#2F2F2F';
const WSJB_COMPANY_TEXT: string = '#9A9A9A';
const WSJB_GROUP_TEXT: string = '#131313';
const WSJB_MORE_TEXT: string = '#444444';

/** 搜索行：胶囊距页顶 40.7vp、高 41.5vp、圆角 20.7vp、右缘距窗口右边 72.7vp */
const WSJB_SEARCH_TOP: number = 40.7;
const WSJB_SEARCH_HEIGHT: number = 41.5;
const WSJB_SEARCH_RADIUS: number = 20.7;
const WSJB_SEARCH_PAD_LEFT: number = 6.4;
const WSJB_SEARCH_PAD_RIGHT: number = 72.7;

/** 返回箭头：外接 9.5×14.2vp、笔画 2.5vp；两条斜笔画长 8.5vp、倾角 56.2°、上下各偏 3.55vp */
const WSJB_BACK_TOUCH: number = 30;
const WSJB_BACK_SPAN_W: number = 9.5;
const WSJB_BACK_SPAN_H: number = 14.2;
const WSJB_BACK_STROKE: number = 2.5;
const WSJB_BACK_BAR_LEN: number = 8.5;
const WSJB_BACK_BAR_ANGLE: number = 56.2;
const WSJB_BACK_BAR_GAP: number = 3.55;
const WSJB_BACK_MARGIN_RIGHT: number = 5.4;

/** 关键词标签：高 29.5vp、圆角 14.8vp、字 12.5vp、左右内边距 9.3 / 8vp */
const WSJB_CHIP_HEIGHT: number = 29.5;
const WSJB_CHIP_RADIUS: number = 14.8;
const WSJB_CHIP_PAD_LEFT: number = 9.3;
const WSJB_CHIP_PAD_RIGHT: number = 8;
const WSJB_CHIP_FONT: number = 12.5;

/** tab 行：文字顶 102.2vp（距胶囊底 20vp）、字 14.5vp、左边距 21.8vp、间距 28vp */
const WSJB_TAB_TOP: number = 20;
const WSJB_TAB_TEXT_H: number = 18;
const WSJB_TAB_FONT: number = 14.5;
const WSJB_TAB_PAD_LEFT: number = 21.8;
const WSJB_TAB_GAP: number = 28;
const WSJB_TAB_UNDERLINE_TOP: number = 4.2;
const WSJB_TAB_UNDERLINE_W: number = 16.7;
const WSJB_TAB_UNDERLINE_H: number = 4.4;

/** 卡片：外边距 8vp、圆角 6vp、卡片间距 12.4vp、卡片 1 顶距头部 10.5vp */
const WSJB_CARD_MARGIN_SIDE: number = 8;
const WSJB_CARD_RADIUS: number = 6;
const WSJB_CARD_TOP_GAP: number = 10.5;
const WSJB_CARD_GAP: number = 12.4;
const WSJB_CARD_PAD_LEFT: number = 18.2;
const WSJB_CARD_PAD_RIGHT: number = 16;
const WSJB_CARD_PAD_TOP: number = 16.7;
const WSJB_CARD_PAD_BOTTOM: number = 5.9;

/** 分组头：图标 17.5vp、字 16vp、图标到字 9.5vp、分组头底到首条标题 36.7vp */
const WSJB_GROUP_ICON: number = 17.5;
const WSJB_GROUP_FONT: number = 16;
const WSJB_GROUP_ICON_GAP: number = 9.5;
const WSJB_GROUP_TO_ITEM: number = 36.7;

/** 岗位条目：行距 154.9vp；左侧文字列固定 320vp（不随窗口变宽） */
const WSJB_ITEM_PITCH: number = 154.9;
const WSJB_TEXT_COLUMN_W: number = 320;
const WSJB_TITLE_FONT: number = 17;
const WSJB_TITLE_BOX: number = 24;
const WSJB_SALARY_FONT: number = 18;
const WSJB_SALARY_BOX: number = 20;
const WSJB_JOBNAME_FONT: number = 13;
const WSJB_JOBNAME_GAP: number = 8.4;
const WSJB_TAG_TOP: number = 8.5;
const WSJB_TAG_HEIGHT: number = 18.9;
const WSJB_TAG_RADIUS: number = 2.5;
const WSJB_TAG_FONT: number = 10.5;
const WSJB_TAG_PAD_SIDE: number = 4.7;
const WSJB_TAG_GAP: number = 4.4;
const WSJB_AVATAR_TOP: number = 13;
const WSJB_AVATAR_GAP: number = 9.5;
const WSJB_NAME_FONT: number = 12.5;
const WSJB_COMPANY_FONT: number = 12;

/** 右侧：地点 10.5vp、申请按钮 61.8×30.5vp、距条目顶 37.1vp */
const WSJB_AREA_FONT: number = 10.5;
const WSJB_AREA_BOX: number = 14;
const WSJB_APPLY_W: number = 61.8;
const WSJB_APPLY_H: number = 30.5;
const WSJB_APPLY_FONT: number = 16;
const WSJB_APPLY_TOP: number = 22;

/** 底部「查看更多服务 ›」：字 14vp、行高 20vp */
const WSJB_MORE_FONT: number = 14;
const WSJB_MORE_HEIGHT: number = 20;

/** 第二张卡片：左内边距 13.5vp、顶内边距 14.2vp、分组头到标题 42.5vp、广告图 93.1×27.6vp */
const WSJB_SECOND_PAD_LEFT: number = 13.5;
const WSJB_SECOND_PAD_TOP: number = 14.2;
const WSJB_SECOND_TO_TITLE: number = 42.5;
const WSJB_SECOND_THUMB_W: number = 93.1;
const WSJB_SECOND_THUMB_H: number = 27.6;

/** 福利标签 */
interface WSJB_JobTag {
  tagKey: string;
  tagLabel: string;
}

/** 一条招聘岗位 */
interface WSJB_JobItem {
  jobKey: string;
  jobTitle: string;
  jobSalary: string;
  jobName: string;
  /** 右上角城市 / 区域 */
  jobArea: string;
  jobTags: WSJB_JobTag[];
  /** 从截图裁出的圆形头像 */
  jobAvatar: Resource;
  /** 头像直径：截图里第一条 86px、第二三条 96px */
  jobAvatarSize: number;
  jobContact: string;
  jobCompany: string;
}

const WSJB_TAB_LABELS: string[] = [
  '全部',
  '商铺租售/生意转让',
  '全职招聘',
  '网络布线/维护',
  '手机/电脑/数码回收'
];

const WSJB_JOB_ITEMS: WSJB_JobItem[] = [
  {
    jobKey: 'jb-huawei-qc',
    jobTitle: '华为手机招质检月7500包吃住可预支',
    jobSalary: '7500-8000 元',
    jobName: '质量检验员/测试员',
    jobArea: '上海·浦东',
    jobTags: [
      { tagKey: 'jb-huawei-qc-meal', tagLabel: '包吃' },
      { tagKey: 'jb-huawei-qc-live', tagLabel: '包住' },
      { tagKey: 'jb-huawei-qc-ot', tagLabel: '加班补助' }
    ],
    jobAvatar: $r('app.media.ws_jb_avatar_li'),
    jobAvatarSize: 31.3,
    jobContact: '李女士',
    jobCompany: '山东恺硕企业管理有限公司'
  },
  {
    jobKey: 'jb-rider-huawei',
    jobTitle: '站点直招骑手送华为手机',
    jobSalary: '9000-15000 元',
    jobName: '送餐员',
    jobArea: '嘉定·马陆',
    jobTags: [
      { tagKey: 'jb-rider-meal', tagLabel: '包吃' },
      { tagKey: 'jb-rider-live', tagLabel: '包住' },
      { tagKey: 'jb-rider-ot', tagLabel: '加班补助' },
      { tagKey: 'jb-rider-food', tagLabel: '饭补' },
      { tagKey: 'jb-rider-call', tagLabel: '话补' },
      { tagKey: 'jb-rider-room', tagLabel: '房补' }
    ],
    jobAvatar: $r('app.media.ws_jb_avatar_wang'),
    jobAvatarSize: 34.9,
    jobContact: '王女士',
    jobCompany: '上海铭创餐饮管理有限公司'
  },
  {
    jobKey: 'jb-qingpu-waiter',
    jobTitle: '青浦练秋湖华为就近分配服务员J10021',
    jobSalary: '3000-5000 元',
    jobName: '服务员',
    jobArea: '上海',
    jobTags: [
      { tagKey: 'jb-waiter-train', tagLabel: '带薪培训' },
      { tagKey: 'jb-waiter-near', tagLabel: '就近分配' }
    ],
    jobAvatar: $r('app.media.ws_jb_avatar_kfc'),
    jobAvatarSize: 34.9,
    jobContact: '戴先生',
    jobCompany: '上海肯德基有限公司'
  }
];

@Component
export struct JobSearchCardsPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽度（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = 939.6;

  /** 窗口高度（vp），随折叠 / 旋转实时更新 */
  @State winHeightVp: number = 664.7;

  /** 搜索框里已选的关键词 */
  @State keyword: string = '华为公司';

  private contentScroller: Scroller = new Scroller();
  private tabScroller: Scroller = new Scroller();
  private pageActive: boolean = false;
  private windowToken: number = 0;

  private jobItems: WSJB_JobItem[] = [];

  aboutToAppear(): void {
    this.pageActive = true;
    this.jobItems = WSJB_JOB_ITEMS;
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

  // ------------------------------------------------------------------
  // 顶部：返回箭头 + 关键词搜索胶囊
  // ------------------------------------------------------------------

  /** 返回箭头：两条斜向笔画在左侧交成一个「‹」 */
  @Builder
  backArrow() {
    Stack({ alignContent: Alignment.Center }) {
      Row()
        .width(WSJB_BACK_BAR_LEN)
        .height(WSJB_BACK_STROKE)
        .backgroundColor(WSJB_TEXT_COLOR)
        .borderRadius(WSJB_BACK_STROKE / 2)
        .rotate({ angle: -WSJB_BACK_BAR_ANGLE })
        .offset({ y: -WSJB_BACK_BAR_GAP })

      Row()
        .width(WSJB_BACK_BAR_LEN)
        .height(WSJB_BACK_STROKE)
        .backgroundColor(WSJB_TEXT_COLOR)
        .borderRadius(WSJB_BACK_STROKE / 2)
        .rotate({ angle: WSJB_BACK_BAR_ANGLE })
        .offset({ y: WSJB_BACK_BAR_GAP })
    }
    .width(WSJB_BACK_SPAN_W)
    .height(WSJB_BACK_SPAN_H)
  }

  /** 搜索框里只剩一个关键词标签，标签右侧整片留白 */
  @Builder
  searchBar() {
    Row() {
      Stack({ alignContent: Alignment.Center }) {
        this.backArrow()
      }
      .width(WSJB_BACK_TOUCH)
      .height(WSJB_BACK_TOUCH)
      .onClick(() => {
        this.pageStack.pop();
      })

      Row() {
        Row({ space: 4.7 }) {
          Text(this.keyword)
            .fontSize(WSJB_CHIP_FONT)
            .fontColor(WSJB_CHIP_TEXT)
            .maxLines(1)

          Text('×')
            .fontSize(WSJB_CHIP_FONT + 1.5)
            .fontColor(WSJB_TAG_TEXT)
            .maxLines(1)
        }
        .height(WSJB_CHIP_HEIGHT)
        .padding({ left: WSJB_CHIP_PAD_LEFT, right: WSJB_CHIP_PAD_RIGHT })
        .backgroundColor(WSJB_CHIP_BG)
        .borderRadius(WSJB_CHIP_RADIUS)
        .alignItems(VerticalAlign.Center)

        Blank()
      }
      .layoutWeight(1)
      .height(WSJB_SEARCH_HEIGHT)
      .margin({ left: WSJB_BACK_MARGIN_RIGHT })
      .padding({ left: WSJB_CHIP_PAD_LEFT, right: WSJB_CHIP_PAD_LEFT })
      .backgroundColor(WSJB_SEARCH_BG)
      .borderRadius(WSJB_SEARCH_RADIUS)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(WSJB_SEARCH_HEIGHT)
    .margin({ top: WSJB_SEARCH_TOP })
    .padding({ left: WSJB_SEARCH_PAD_LEFT, right: WSJB_SEARCH_PAD_RIGHT })
    .alignItems(VerticalAlign.Center)
  }

  // ------------------------------------------------------------------
  // 横向 tab 行
  // ------------------------------------------------------------------

  @Builder
  tabRow() {
    Scroll(this.tabScroller) {
      Row({ space: WSJB_TAB_GAP }) {
        ForEach(WSJB_TAB_LABELS, (label: string, index: number) => {
          Column() {
            Text(label)
              .fontSize(WSJB_TAB_FONT)
              .fontWeight(index === 0 ? FontWeight.Medium : FontWeight.Normal)
              .fontColor(index === 0 ? WSJB_BRAND_RED : WSJB_TAB_TEXT)
              .maxLines(1)
              .height(WSJB_TAB_TEXT_H)

            if (index === 0) {
              Row()
                .width(WSJB_TAB_UNDERLINE_W)
                .height(WSJB_TAB_UNDERLINE_H)
                .backgroundColor(WSJB_BRAND_RED)
                .borderRadius(WSJB_TAB_UNDERLINE_H / 2)
                .margin({ top: WSJB_TAB_UNDERLINE_TOP })
            } else {
              Row()
                .height(WSJB_TAB_UNDERLINE_H)
                .margin({ top: WSJB_TAB_UNDERLINE_TOP })
            }
          }
          .alignItems(HorizontalAlign.Center)
        }, (label: string) => label)
      }
      .padding({ left: WSJB_TAB_PAD_LEFT, right: WSJB_TAB_PAD_LEFT })
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .height(WSJB_TAB_TEXT_H + WSJB_TAB_UNDERLINE_TOP + WSJB_TAB_UNDERLINE_H)
    .margin({ top: WSJB_TAB_TOP })
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.None)
    .align(Alignment.Start)
  }

  @Builder
  headerBlock() {
    Column() {
      this.searchBar()

      this.tabRow()
    }
    .width('100%')
    .backgroundColor(Color.White)
    .alignItems(HorizontalAlign.Start)
  }

  // ------------------------------------------------------------------
  // 福利标签
  // ------------------------------------------------------------------

  @Builder
  tagChip(tag: WSJB_JobTag) {
    Text(tag.tagLabel)
      .fontSize(WSJB_TAG_FONT)
      .fontColor(WSJB_TAG_TEXT)
      .maxLines(1)
      .height(WSJB_TAG_HEIGHT)
      .padding({ left: WSJB_TAG_PAD_SIDE, right: WSJB_TAG_PAD_SIDE })
      .backgroundColor(WSJB_TAG_BG)
      .borderRadius(WSJB_TAG_RADIUS)
      .textAlign(TextAlign.Center)
  }

  // ------------------------------------------------------------------
  // 岗位条目
  // ------------------------------------------------------------------

  @Builder
  jobRow(item: WSJB_JobItem) {
    Row() {
      Column() {
        Text(item.jobTitle)
          .fontSize(WSJB_TITLE_FONT)
          .fontWeight(FontWeight.Medium)
          .fontColor(WSJB_TEXT_COLOR)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .height(WSJB_TITLE_BOX)

        Row() {
          Text(item.jobSalary)
            .fontSize(WSJB_SALARY_FONT)
            .fontWeight(FontWeight.Bold)
            .fontColor(WSJB_BRAND_RED)
            .maxLines(1)

          Text(item.jobName)
            .fontSize(WSJB_JOBNAME_FONT)
            .fontColor(WSJB_JOBNAME_TEXT)
            .maxLines(1)
            .margin({ left: WSJB_JOBNAME_GAP })
        }
        .width('100%')
        .height(WSJB_SALARY_BOX)
        .margin({ top: 2 })
        .alignItems(VerticalAlign.Center)

        Row({ space: WSJB_TAG_GAP }) {
          ForEach(item.jobTags, (tag: WSJB_JobTag) => {
            this.tagChip(tag)
          }, (tag: WSJB_JobTag) => tag.tagKey)
        }
        .height(WSJB_TAG_HEIGHT)
        .margin({ top: WSJB_TAG_TOP })
        .alignItems(VerticalAlign.Center)

        Row() {
          Image(item.jobAvatar)
            .width(item.jobAvatarSize)
            .height(item.jobAvatarSize)
            .borderRadius(item.jobAvatarSize / 2)
            .objectFit(ImageFit.Cover)
            .clip(true)

          Column() {
            Text(item.jobContact)
              .fontSize(WSJB_NAME_FONT)
              .fontColor(WSJB_CONTACT_TEXT)
              .maxLines(1)

            Text(item.jobCompany)
              .fontSize(WSJB_COMPANY_FONT)
              .fontColor(WSJB_COMPANY_TEXT)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ top: 2 })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          .margin({ left: WSJB_AVATAR_GAP })
        }
        .width('100%')
        .height(item.jobAvatarSize)
        .margin({ top: WSJB_AVATAR_TOP })
        .alignItems(VerticalAlign.Top)
      }
      .width(WSJB_TEXT_COLUMN_W)
      .alignItems(HorizontalAlign.Start)

      Blank()

      Column() {
        Text(item.jobArea)
          .fontSize(WSJB_AREA_FONT)
          .fontColor(WSJB_AREA_TEXT)
          .maxLines(1)
          .height(WSJB_AREA_BOX)

        Text('申请')
          .fontSize(WSJB_APPLY_FONT)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
          .maxLines(1)
          .width(WSJB_APPLY_W)
          .height(WSJB_APPLY_H)
          .textAlign(TextAlign.Center)
          .backgroundColor(WSJB_BRAND_RED)
          .borderRadius(WSJB_APPLY_H / 2)
          .margin({ top: WSJB_APPLY_TOP })
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .height(WSJB_ITEM_PITCH)
    .alignItems(VerticalAlign.Top)
  }

  // ------------------------------------------------------------------
  // 招聘结果卡片
  // ------------------------------------------------------------------

  @Builder
  jobCard() {
    Column() {
      Row() {
        Image($r('app.media.ws_jb_icon_fulltime'))
          .width(WSJB_GROUP_ICON)
          .height(WSJB_GROUP_ICON)
          .objectFit(ImageFit.Contain)

        Text('全职招聘')
          .fontSize(WSJB_GROUP_FONT)
          .fontWeight(FontWeight.Medium)
          .fontColor(WSJB_GROUP_TEXT)
          .maxLines(1)
          .margin({ left: WSJB_GROUP_ICON_GAP })
      }
      .width('100%')
      .height(WSJB_GROUP_ICON)
      .alignItems(VerticalAlign.Center)

      Column() {
        ForEach(this.jobItems, (item: WSJB_JobItem) => {
          this.jobRow(item)
        }, (item: WSJB_JobItem) => item.jobKey)
      }
      .width('100%')
      .margin({ top: WSJB_GROUP_TO_ITEM })
      .alignItems(HorizontalAlign.Start)

      Row() {
        Text('查看更多服务 ›')
          .fontSize(WSJB_MORE_FONT)
          .fontColor(WSJB_MORE_TEXT)
          .maxLines(1)
      }
      .width('100%')
      .height(WSJB_MORE_HEIGHT)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding({
      left: WSJB_CARD_PAD_LEFT,
      right: WSJB_CARD_PAD_RIGHT,
      top: WSJB_CARD_PAD_TOP,
      bottom: WSJB_CARD_PAD_BOTTOM
    })
    .backgroundColor(Color.White)
    .borderRadius(WSJB_CARD_RADIUS)
    .alignItems(HorizontalAlign.Start)
  }

  // ------------------------------------------------------------------
  // 第二张卡片（被窗口底边裁掉）
  // ------------------------------------------------------------------

  @Builder
  cablingCard() {
    Column() {
      Row() {
        Image($r('app.media.ws_jb_icon_cabling'))
          .width(WSJB_GROUP_ICON)
          .height(WSJB_GROUP_ICON)
          .objectFit(ImageFit.Contain)

        Text('网络布线/维护')
          .fontSize(WSJB_GROUP_FONT)
          .fontWeight(FontWeight.Medium)
          .fontColor(WSJB_GROUP_TEXT)
          .maxLines(1)
          .margin({ left: WSJB_GROUP_ICON_GAP })
      }
      .width('100%')
      .height(WSJB_GROUP_ICON)
      .alignItems(VerticalAlign.Center)

      Row() {
        Text('全上海安防监控、网络布线、门禁考勤、无线覆盖、弱电施工')
          .fontSize(WSJB_TITLE_FONT)
          .fontWeight(FontWeight.Medium)
          .fontColor(WSJB_TEXT_COLOR)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)

        Image($r('app.media.ws_jb_thumb_cabling'))
          .width(WSJB_SECOND_THUMB_W)
          .height(WSJB_SECOND_THUMB_H)
          .objectFit(ImageFit.Cover)
          .margin({ left: 12 })
      }
      .width('100%')
      .margin({ top: WSJB_SECOND_TO_TITLE })
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .padding({
      left: WSJB_SECOND_PAD_LEFT,
      right: WSJB_CARD_PAD_RIGHT,
      top: WSJB_SECOND_PAD_TOP,
      bottom: 18
    })
    .backgroundColor(Color.White)
    .borderRadius(WSJB_CARD_RADIUS)
    .margin({ top: WSJB_CARD_GAP })
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    NavDestination() {
      Column() {
        this.headerBlock()

        Scroll(this.contentScroller) {
          Column() {
            this.jobCard()

            this.cablingCard()
          }
          .width('100%')
          .padding({ left: WSJB_CARD_MARGIN_SIDE, right: WSJB_CARD_MARGIN_SIDE })
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ top: WSJB_CARD_TOP_GAP })
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.None)
        .align(Alignment.Top)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(WSJB_PAGE_BG)
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
