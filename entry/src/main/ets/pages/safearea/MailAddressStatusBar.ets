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
 * 反例：未避让安全区 / 邮寄地址页拉起键盘压状态栏（状态栏）
 *
 * 复刻中国国航「编辑邮寄地址」页：白色标题栏（返回 + 居中标题）、浅灰分隔条、
 * 五行表单（国家/地区、省/州、城市/县区、详细地址、邮编号码）、淡粉「保存」按钮。
 *
 * 设计基准：单屏态 459.6×672vp（1264×1848px，密度 2.75），vp = px / 2.75。
 *   标题栏顶边 = 状态栏避让区（本机 39vp），标题栏 47.4vp：标题 18vp 居中（六字宽 106.5vp）、
 *           返回 10.9×18.9vp，距左 20.7vp；
 *   分隔条 10.8vp（#F4F5F7，通栏）；
 *   选择行 71.4vp（含 1vp 分隔线）：上留白 20.2vp、标签 12vp（行高 14.6vp）、行距 7.8vp、
 *           取值 15vp（行高 21vp）、下留白 6.8vp；取值右侧 6.2×10.9vp 的箭头，距右 20vp；
 *   输入行 78vp（含 1vp 分隔线）：同上，输入框 30vp，距行顶 47.9vp；
 *   分隔线 1vp（#EDEEF0），左右各缩进 20vp；
 *   保存按钮：距末行 53.8vp、高 45vp、宽 90%、圆角 4vp、#FDEFEF 底 + 白字 15.5vp。
 *   三态都不随窗口缩放，尺寸与单屏态一致。
 *
 * 三态实测（键盘顶 / 整页上移量）：
 *   单屏态      459.6×672vp   —— 键盘顶 357.8vp，整页上移 118.9vp，标题栏整条推出屏幕，
 *                                「国家/地区」落到 y -0.4～10.5vp（上沿被裁 0.4vp），
 *                                「请选择」（y 24.7～37.8vp）压住状态栏时间（15.3～27.3vp）
 *   双屏态竖屏  664.7×939.6vp —— 键盘顶 625.5vp，邮编号码在键盘上方，页面不上移
 *   双屏态横屏  939.6×664.7vp —— 键盘顶 442.5vp，整页上移 34.2vp，标题（y 19.3～37.8vp）
 *                                与返回键落进状态栏行，和时间（17.1～37.5vp）叠在一起
 *
 * 问题表现（单屏态 / 双屏态横屏，点「邮编号码」拉起键盘后）：
 *   整页随键盘一起上移，状态栏不让位；标题栏被推出屏幕（横屏时压在状态栏上），
 *   「国家/地区」顶到屏幕上沿，「请选择」和右侧箭头落在状态栏时间、电量的同一行上。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 状态栏缺省高度（取不到避让区时用；本机实测 39vp） */
const MB_TOP_INSET_FALLBACK: number = 40;

/** 标题栏：高 47.4vp，标题 18vp，返回键外接 10.9×18.9vp */
const MB_TITLE_BAR_HEIGHT: number = 47.4;
const MB_TITLE_FONT: number = 18;
/** 返回键用符号字形绘制：字号 35vp 时字形外接 10.9×18.9vp */
const MB_BACK_SPAN: number = 35;
const MB_BACK_BOX: number = 44;
/** 返回键点击区左边距：命中外接左沿 20.7vp（= 4.15 + (44 - 10.9) / 2） */
const MB_BACK_SIDE: number = 4.15;

/** 标题栏下的通栏分隔条 10.8vp */
const MB_SECTION_GAP: number = 10.8;

/** 行内左右缩进（标签、取值、分隔线都按 20vp） */
const MB_SIDE: number = 20;

/** 选择行：70.4vp（+1vp 分隔线 = 71.4vp 行距） */
const MB_SELECT_PAD_TOP: number = 20.2;
const MB_SELECT_PAD_BOTTOM: number = 6.8;
const MB_SELECT_ROW_HEIGHT: number = 70.4;

/** 输入行：77vp（+1vp 分隔线 = 78vp 行距）；输入框 30vp，字距行顶 47.9vp */
const MB_INPUT_PAD_TOP: number = 20.2;
const MB_INPUT_GAP: number = 5.1;
const MB_INPUT_HEIGHT: number = 30;
const MB_INPUT_PAD_BOTTOM: number = 6.1;
const MB_INPUT_ROW_HEIGHT: number = 77.0;

/** 标签与取值 */
const MB_LABEL_FONT: number = 12;
const MB_LABEL_LINE: number = 14.6;
const MB_VALUE_FONT: number = 15;
const MB_VALUE_LINE: number = 21;
const MB_LABEL_VALUE_GAP: number = 7.8;

/** 行分隔线 */
const MB_DIVIDER_HEIGHT: number = 1;

/** 右侧箭头：外接 6.2×10.9vp（字号 20.5vp）；符号字形自带留白，右移 2.9vp、下移 0.7vp 贴住量出的位置 */
const MB_ARROW_FONT: number = 20.5;
const MB_ARROW_OFFSET_X: number = 2.9;
const MB_ARROW_OFFSET_Y: number = 0.7;

/** 保存按钮 */
const MB_SAVE_MARGIN_TOP: number = 53.8;
const MB_SAVE_HEIGHT: number = 45;
const MB_SAVE_RADIUS: number = 4;
const MB_SAVE_WIDTH_RATIO: number = 0.9;
const MB_SAVE_FONT: number = 15.5;

/** 配色 */
const MB_PAGE_BG: string = '#FFFFFF';
const MB_TITLE_TEXT: string = '#333333';
const MB_BACK_TEXT: string = '#2D303F';
const MB_LABEL_TEXT: string = '#666666';
const MB_VALUE_TEXT: string = '#999999';
const MB_DIVIDER: string = '#EDEEF0';
const MB_SECTION_BAR: string = '#F4F5F7';
const MB_SAVE_BG: string = '#FDEFEF';
const MB_FOCUS_LINE: string = '#333333';

interface MailAddressRow {
  rowKey: string;
  rowLabel: string;
  /** 占位文字（未填写时显示） */
  rowPlaceholder: string;
  /** 是否是输入行（详细地址 / 邮编号码） */
  rowInput: boolean;
  /** 是否显示右侧箭头 */
  rowPickable: boolean;
}

const MB_ROWS: MailAddressRow[] = [
  { rowKey: 'mail-country', rowLabel: '国家/地区', rowPlaceholder: '请选择', rowInput: false, rowPickable: true },
  { rowKey: 'mail-province', rowLabel: '省/州', rowPlaceholder: '请选择', rowInput: false, rowPickable: true },
  { rowKey: 'mail-city', rowLabel: '城市/县区', rowPlaceholder: '请选择', rowInput: false, rowPickable: true },
  { rowKey: 'mail-detail', rowLabel: '详细地址', rowPlaceholder: '街道门牌号信息', rowInput: true, rowPickable: false },
  { rowKey: 'mail-postcode', rowLabel: '邮编号码', rowPlaceholder: '请输入', rowInput: true, rowPickable: false }
];

@Component
export struct MailAddressStatusBarPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽度（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = 459.6;

  /** 窗口高度（vp） */
  @State winHeightVp: number = 672;

  /** 状态栏高度（vp）：标题栏顶边到屏幕上边 */
  @State topInsetVp: number = MB_TOP_INSET_FALLBACK;

  /** 详细地址输入内容 */
  @State detailText: string = '';

  /** 邮编号码输入内容 */
  @State postcodeText: string = '';

  /** 邮编号码是否获得焦点（分隔线变深色） */
  @State postcodeFocused: boolean = false;

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
      const avoidArea: window.AvoidArea = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      const insetVp: number = this.getUIContext().px2vp(avoidArea.topRect.height);
      if (insetVp > 0) {
        this.topInsetVp = insetVp;
      }
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  private saveButtonWidth(): number {
    if (this.winWidthVp <= 0) {
      return 0;
    }
    return this.winWidthVp * MB_SAVE_WIDTH_RATIO;
  }

  // ------------------------------------------------------------------
  // 标题栏：返回 + 居中标题
  // ------------------------------------------------------------------

  @Builder
  titleBar() {
    Stack({ alignContent: Alignment.Center }) {
      Text('编辑邮寄地址')
        .fontSize(MB_TITLE_FONT)
        .fontWeight(FontWeight.Medium)
        .fontColor(MB_TITLE_TEXT)

      Row() {
        Row() {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(MB_BACK_SPAN)
            .fontColor([MB_BACK_TEXT])
        }
        .width(MB_BACK_BOX)
        .height(MB_BACK_BOX)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .onClick(() => {
          this.pageStack.pop();
        })
      }
      .width('100%')
      .height('100%')
      .padding({ left: MB_BACK_SIDE })
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .height(MB_TITLE_BAR_HEIGHT)
    .backgroundColor(MB_PAGE_BG)
  }

  // ------------------------------------------------------------------
  // 表单行
  // ------------------------------------------------------------------

  @Builder
  selectRow(row: MailAddressRow) {
    Column() {
      Text(row.rowLabel)
        .fontSize(MB_LABEL_FONT)
        .fontColor(MB_LABEL_TEXT)
        .lineHeight(MB_LABEL_LINE)
        .maxLines(1)

      Row() {
        Text(row.rowPlaceholder)
          .fontSize(MB_VALUE_FONT)
          .fontColor(MB_VALUE_TEXT)
          .lineHeight(MB_VALUE_LINE)
          .maxLines(1)

        Blank()

        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(MB_ARROW_FONT)
          .fontColor([MB_VALUE_TEXT])
          .offset({ x: MB_ARROW_OFFSET_X, y: MB_ARROW_OFFSET_Y })
      }
      .width('100%')
      .height(MB_VALUE_LINE)
      .margin({ top: MB_LABEL_VALUE_GAP })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(MB_SELECT_ROW_HEIGHT)
    .padding({
      left: MB_SIDE,
      right: MB_SIDE,
      top: MB_SELECT_PAD_TOP,
      bottom: MB_SELECT_PAD_BOTTOM
    })
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(MB_PAGE_BG)
  }

  @Builder
  inputRow(row: MailAddressRow) {
    Column() {
      Text(row.rowLabel)
        .fontSize(MB_LABEL_FONT)
        .fontColor(MB_LABEL_TEXT)
        .lineHeight(MB_LABEL_LINE)
        .maxLines(1)

      if (row.rowKey === 'mail-postcode') {
        TextInput({ text: this.postcodeText, placeholder: row.rowPlaceholder })
          .type(InputType.Number)
          .fontSize(MB_VALUE_FONT)
          .fontColor('#333333')
          .placeholderFont({ size: MB_VALUE_FONT })
          .placeholderColor(MB_VALUE_TEXT)
          .backgroundColor(Color.Transparent)
          .borderRadius(0)
          .padding({ left: 0, right: 0, top: 0, bottom: 0 })
          .height(MB_INPUT_HEIGHT)
          .width('100%')
          .caretColor('#0A59F7')
          .margin({ top: MB_INPUT_GAP })
          .onChange((value: string) => {
            this.postcodeText = value;
          })
          .onFocus(() => {
            this.postcodeFocused = true;
          })
          .onBlur(() => {
            this.postcodeFocused = false;
          })
      } else {
        TextInput({ text: this.detailText, placeholder: row.rowPlaceholder })
          .type(InputType.Normal)
          .fontSize(MB_VALUE_FONT)
          .fontColor('#333333')
          .placeholderFont({ size: MB_VALUE_FONT })
          .placeholderColor(MB_VALUE_TEXT)
          .backgroundColor(Color.Transparent)
          .borderRadius(0)
          .padding({ left: 0, right: 0, top: 0, bottom: 0 })
          .height(MB_INPUT_HEIGHT)
          .width('100%')
          .caretColor('#0A59F7')
          .margin({ top: MB_INPUT_GAP })
          .onChange((value: string) => {
            this.detailText = value;
          })
      }
    }
    .width('100%')
    .height(MB_INPUT_ROW_HEIGHT)
    .padding({
      left: MB_SIDE,
      right: MB_SIDE,
      top: MB_INPUT_PAD_TOP,
      bottom: MB_INPUT_PAD_BOTTOM
    })
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(MB_PAGE_BG)
  }

  @Builder
  rowDivider(row: MailAddressRow) {
    Row()
      .width('100%')
      .height(MB_DIVIDER_HEIGHT)
      .margin({ left: MB_SIDE, right: MB_SIDE })
      .backgroundColor(
        row.rowKey === 'mail-postcode' && this.postcodeFocused ? MB_FOCUS_LINE : MB_DIVIDER
      )
  }

  // ------------------------------------------------------------------
  // 保存按钮
  // ------------------------------------------------------------------

  @Builder
  saveButton() {
    Row() {
      Text('保存')
        .fontSize(MB_SAVE_FONT)
        .fontColor(Color.White)
    }
    .width(this.saveButtonWidth())
    .height(MB_SAVE_HEIGHT)
    .borderRadius(MB_SAVE_RADIUS)
    .backgroundColor(MB_SAVE_BG)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .margin({ top: MB_SAVE_MARGIN_TOP })
  }

  build() {
    NavDestination() {
      Column() {
        Row()
          .width('100%')
          .height(this.topInsetVp)

        this.titleBar()

        Row()
          .width('100%')
          .height(MB_SECTION_GAP)
          .backgroundColor(MB_SECTION_BAR)

        Column() {
          ForEach(MB_ROWS, (row: MailAddressRow) => {
            if (row.rowInput) {
              this.inputRow(row)
            } else {
              this.selectRow(row)
            }
            this.rowDivider(row)
          }, (row: MailAddressRow) => row.rowKey)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        this.saveButton()

        Blank()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(MB_PAGE_BG)
      .alignItems(HorizontalAlign.Center)
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
