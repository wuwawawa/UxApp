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
 * 反例：截断 / 美团登录页「验证码登录」与「其他登录方式」文字重叠（文字重叠）
 *
 * 复刻美团 App 登录页：关闭 + 帮助、欢迎登录美团、手机号 / 密码输入框、
 * 用户协议勾选、登录按钮、验证码登录、其他登录方式 + 三方登录图标（华为 / QQ）。
 *
 * 各段位置都按单屏态截图（459.6×672vp，1264×1848px，密度 2.75）量出的设计值摆放。
 * 顶部表单三态完全一致（截图上三个屏态量出来是同一组坐标）：
 *   单屏态        459.6×672vp   —— 正常
 *   双屏态竖屏    664.7×939.6vp —— 正常
 *   双屏态横屏    939.6×664.7vp —— 文字重叠
 *
 * 问题表现（双屏态横屏）：
 *   「其他登录方式」跳到「验证码登录」上一行，两个文本上下重叠约 2/5 个字高；
 *   两个文本都居中，但一个是 6 个字、一个是 5 个字，居中后字形本身就差半个字宽，
 *   所以看起来是「验证码登录」落在标签的右下方：
 *     水平：「验证码登录」左边比标签右移半个字（6.9vp）
 *     垂直：「验证码登录」上沿比标签下沿低、两行重叠 2/5 字高
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowModeController } from '../../common/WindowModeController';

/** 单屏态窗口宽度（1264px / 密度 2.75），用于把设计稿 vp 对齐到当前窗口 */
const LOGIN_REFERENCE_WIDTH: number = 459.6;

/** 页面左右留白（表单区 / 标题）：量测 29.8vp */
const LOGIN_SIDE_INSET: number = 29.8;

/** 顶部关闭按钮与「帮助」 */
const LOGIN_HEADER_TOP: number = 49.8;
const LOGIN_CLOSE_SIZE: number = 34;
const LOGIN_CLOSE_INSET_LEFT: number = 17.8;
const LOGIN_HELP_INSET_RIGHT: number = 19.6;
const LOGIN_HELP_FONT: number = 13.5;

/** 标题「欢迎登录美团」 */
const LOGIN_TITLE_FONT: number = 24;
const LOGIN_TITLE_BOX_HEIGHT: number = 30;
const LOGIN_TITLE_GAP: number = 48.8;

/** 输入框：量测高度 53.8vp、圆角半高、左右贴到 29.8 留白 */
const LOGIN_FIELD_HEIGHT: number = 53.8;
const LOGIN_FIELD_BG: string = '#F5F6FA';
const LOGIN_FIELD_GAP: number = 48.3;
const LOGIN_FIELD_SPACING: number = 12.4;
const LOGIN_PHONE_FONT: number = 18.2;
const LOGIN_PLACEHOLDER_FONT: number = 16;
const LOGIN_PHONE_TEXT: string = '190 5611 8490';

/** 用户协议行 */
const LOGIN_AGREEMENT_BOX_HEIGHT: number = 18;
const LOGIN_AGREEMENT_GAP: number = 43.3;
const LOGIN_AGREEMENT_FONT: number = 13.5;
const LOGIN_AGREEMENT_CHECK_SIZE: number = 12;
const LOGIN_LINK_BLUE: string = '#4081F7';
const LOGIN_CHECK_YELLOW: string = '#FFCB05';

/** 登录按钮 */
const LOGIN_BUTTON_HEIGHT: number = 44.4;
const LOGIN_BUTTON_GAP: number = 13.6;
const LOGIN_BUTTON_BG: string = '#FFF3AB';
const LOGIN_BUTTON_TEXT_COLOR: string = '#A8A69E';
const LOGIN_BUTTON_FONT: number = 16;

/** 「验证码登录」 */
const LOGIN_LINK_BOX_HEIGHT: number = 18;
const LOGIN_LINK_GAP: number = 15.3;
const LOGIN_LINK_FONT: number = 13;
const LOGIN_LINK_COLOR: string = '#4E4E4E';

/** 三方登录区：「其他登录方式」+ 华为 / QQ 图标，整块贴着页面底部 */
const LOGIN_OTHER_METHOD_FONT: number = 13;
const LOGIN_OTHER_METHOD_LINE_HEIGHT: number = 18;
const LOGIN_OTHER_METHOD_COLOR: string = '#8A8A8A';
const LOGIN_LABEL_ICON_GAP: number = 22.9;
const LOGIN_ICON_SIZE: number = 48;
const LOGIN_ICON_BOTTOM_INSET: number = 77.1;

/**
 * 横屏紧凑态下「其他登录方式」的向上偏移（vp）。
 * 该偏移下横屏时标签落在 460.4 ~ 472.0vp，「验证码登录」落在 467.3 ~ 478.9vp，
 * 两者上下重叠约 4.7vp。
 */
const LOGIN_COMPACT_LABEL_LIFT: number = 41;

/** 华为 / QQ 图标配色 */
const LOGIN_HUAWEI_BG: string = '#F2F2F2';
const LOGIN_HUAWEI_RED: string = '#DA1A28';
const LOGIN_QQ_BLUE: string = '#3399FE';

/** 华为花瓣的 8 个角度（度）：左右两扇，中间留一道竖缝 */
const LOGIN_HUAWEI_PETAL_ANGLES: number[] = [-80, -58, -34, -10, 10, 34, 58, 80];
const LOGIN_HUAWEI_PETAL_RADIUS: number = 6.6;
/** 花瓣排布在纵向上压扁一点，做出「扇面」而不是正圆花的效果 */
const LOGIN_HUAWEI_PETAL_FLATTEN: number = 0.62;
/** 花瓣描边的颜色和圆底一致，用它把相邻花瓣隔开 */
const LOGIN_HUAWEI_PETAL_STROKE: number = 0.6;

@Component
export struct LoginPageOverlapTruncationPage {
  pageStack: NavPathStack = new NavPathStack();

  /** 窗口宽高（vp），随折叠 / 旋转实时更新 */
  @State winWidthVp: number = LOGIN_REFERENCE_WIDTH;
  @State winHeightVp: number = 672;

  /** 协议是否勾选（与截图一致，默认已勾选） */
  @State agreementChecked: boolean = true;
  /** 密码是否可见 */
  @State passwordVisible: boolean = false;
  /** 密码输入内容 */
  @State passwordText: string = '';

  private pageActive: boolean = false;
  private windowToken: number = 0;
  /** 1vp 对应的 px 数：Path 的 commands 用 px 为单位，画图标时要把设计稿的 vp 坐标换算过去 */
  private vpScale: number = 2.75;

  aboutToAppear(): void {
    this.pageActive = true;
    this.vpScale = this.getUIContext().vp2px(1);
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

  /** 把一串 vp 坐标换算成 Path commands 需要的 px 字符串 */
  private pathPoints(values: number[]): string {
    const points: string[] = [];
    for (const pointVp of values) {
      points.push((pointVp * this.vpScale).toFixed(2));
    }
    return points.join(' ');
  }

  /** 密码框右侧的闭眼图标：眼皮弧线 + 三根睫毛 */
  private eyePathCommands(): string {
    return 'M' + this.pathPoints([1, 2.4]) +
      ' C' + this.pathPoints([3.4, 7.6, 12.6, 7.6, 15, 2.4]) +
      ' M' + this.pathPoints([4.6, 5.9]) + ' L' + this.pathPoints([3.6, 9.2]) +
      ' M' + this.pathPoints([8, 7.2]) + ' L' + this.pathPoints([8, 10.6]) +
      ' M' + this.pathPoints([11.4, 5.9]) + ' L' + this.pathPoints([12.4, 9.2]);
  }

  /** 协议勾选里的白色对勾 */
  private checkPathCommands(): string {
    return 'M' + this.pathPoints([1, 4.2]) +
      ' L' + this.pathPoints([3.6, 6.8]) +
      ' L' + this.pathPoints([8, 1.6]);
  }

  /** 手机号前面的实心小三角 */
  private arrowPathCommands(): string {
    return 'M' + this.pathPoints([0, 0]) +
      ' L' + this.pathPoints([9, 0]) +
      ' L' + this.pathPoints([4.5, 5.5]) + ' Z';
  }

  /** 「其他登录方式」的向上偏移：横屏（窗口宽 > 高）才非 0 */
  private otherMethodLiftVp(): number {
    if (this.winWidthVp > this.winHeightVp) {
      return LOGIN_COMPACT_LABEL_LIFT;
    }
    return 0;
  }

  // ------------------------------------------------------------------
  // 头部
  // ------------------------------------------------------------------

  @Builder
  headerRow() {
    Row() {
      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width(LOGIN_CLOSE_SIZE)
          .height(LOGIN_CLOSE_SIZE)
          .borderRadius(LOGIN_CLOSE_SIZE / 2)
          .backgroundColor('#F2F2F2')

        SymbolGlyph($r('sys.symbol.xmark'))
          .fontSize(18.5)
          .fontColor(['#2B2B2B'])
      }
      .width(LOGIN_CLOSE_SIZE)
      .height(LOGIN_CLOSE_SIZE)
      .onClick(() => {
        this.pageStack.pop();
      })

      Blank()

      Text('帮助')
        .fontSize(LOGIN_HELP_FONT)
        .fontColor('#1A1A1A')
    }
    .width('100%')
    .height(LOGIN_CLOSE_SIZE)
    .padding({ left: LOGIN_CLOSE_INSET_LEFT, right: LOGIN_HELP_INSET_RIGHT })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  loginTitle() {
    Row() {
      Text('欢迎登录美团')
        .fontSize(LOGIN_TITLE_FONT)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')
        .maxLines(1)
    }
    .width('100%')
    .height(LOGIN_TITLE_BOX_HEIGHT)
    .padding({ left: LOGIN_SIDE_INSET })
    .alignItems(VerticalAlign.Center)
  }

  // ------------------------------------------------------------------
  // 表单
  // ------------------------------------------------------------------

  @Builder
  phoneField() {
    Row() {
      Text('+86')
        .fontSize(LOGIN_PHONE_FONT)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1A1A')

      Path()
        .width(9)
        .height(5.5)
        .commands(this.arrowPathCommands())
        .fill('#1A1A1A')
        .margin({ left: 8 })

      Text(LOGIN_PHONE_TEXT)
        .fontSize(LOGIN_PHONE_FONT)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1A1A')
        .maxLines(1)
        .margin({ left: 26 })
    }
    .width('100%')
    .height(LOGIN_FIELD_HEIGHT)
    .padding({ left: 20.5, right: 20.5 })
    .backgroundColor(LOGIN_FIELD_BG)
    .borderRadius(LOGIN_FIELD_HEIGHT / 2)
    .alignItems(VerticalAlign.Center)
  }

  /** 闭眼图标：眼皮弧线 + 三根睫毛，用 Path 画，和原图一致 */
  @Builder
  eyeClosedIcon() {
    Path()
      .width(16)
      .height(12)
      .commands(this.eyePathCommands())
      .fill(Color.Transparent)
      .stroke('#1A1A1A')
      .strokeWidth(1.1)
      .strokeLineCap(LineCapStyle.Round)
  }

  @Builder
  passwordField() {
    Row() {
      TextInput({
        text: this.passwordText,
        placeholder: '请输入密码'
      })
        .type(this.passwordVisible ? InputType.Normal : InputType.Password)
        .placeholderColor('#B3B3B5')
        .placeholderFont({ size: LOGIN_PLACEHOLDER_FONT })
        .fontSize(LOGIN_PLACEHOLDER_FONT)
        .fontColor('#1A1A1A')
        .caretColor('#1A1A1A')
        .backgroundColor(Color.Transparent)
        .padding(0)
        .height(LOGIN_FIELD_HEIGHT)
        .layoutWeight(1)
        .maxLength(24)
        .showPasswordIcon(false)
        .onChange((inputText: string) => {
          this.passwordText = inputText;
        })

      Row() {
        if (this.passwordVisible) {
          SymbolGlyph($r('sys.symbol.eye'))
            .fontSize(16)
            .fontColor(['#1A1A1A'])
        } else {
          this.eyeClosedIcon()
        }
      }
      .height(LOGIN_FIELD_HEIGHT)
      .padding({ left: 6, right: 2 })
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        this.passwordVisible = !this.passwordVisible;
      })
    }
    .width('100%')
    .height(LOGIN_FIELD_HEIGHT)
    .padding({ left: 16.7, right: 10 })
    .backgroundColor(LOGIN_FIELD_BG)
    .borderRadius(LOGIN_FIELD_HEIGHT / 2)
    .margin({ top: LOGIN_FIELD_SPACING })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  agreementCheck() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width(LOGIN_AGREEMENT_CHECK_SIZE)
        .height(LOGIN_AGREEMENT_CHECK_SIZE)
        .borderRadius(LOGIN_AGREEMENT_CHECK_SIZE / 2)
        .backgroundColor(this.agreementChecked ? LOGIN_CHECK_YELLOW : '#FFFFFF')
        .border({
          width: this.agreementChecked ? 0 : 1,
          color: '#C9C9C9'
        })

      if (this.agreementChecked) {
        Path()
          .width(9)
          .height(8)
          .commands(this.checkPathCommands())
          .fill(Color.Transparent)
          .stroke('#FFFFFF')
          .strokeWidth(1.2)
          .strokeLineCap(LineCapStyle.Round)
      }
    }
    .width(LOGIN_AGREEMENT_CHECK_SIZE)
    .height(LOGIN_AGREEMENT_CHECK_SIZE)
    .onClick(() => {
      this.agreementChecked = !this.agreementChecked;
    })
  }

  @Builder
  agreementRow() {
    Row({ space: 6.9 }) {
      this.agreementCheck()

      Text() {
        Span('我已阅读并同意')
          .fontColor('#1A1A1A')

        Span('《美团用户协议》')
          .fontColor(LOGIN_LINK_BLUE)

        Span('和')
          .fontColor('#1A1A1A')

        Span('《隐私政策》')
          .fontColor(LOGIN_LINK_BLUE)
      }
      .fontSize(LOGIN_AGREEMENT_FONT)
      .maxLines(2)
    }
    .width('100%')
    .height(LOGIN_AGREEMENT_BOX_HEIGHT)
    .padding({ left: 1.5 })
    .margin({ top: LOGIN_AGREEMENT_GAP })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  loginButton() {
    Row() {
      Text('登录')
        .fontSize(LOGIN_BUTTON_FONT)
        .fontWeight(FontWeight.Medium)
        .fontColor(LOGIN_BUTTON_TEXT_COLOR)
    }
    .width('100%')
    .height(LOGIN_BUTTON_HEIGHT)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(LOGIN_BUTTON_BG)
    .borderRadius(LOGIN_BUTTON_HEIGHT / 2)
    .margin({ top: LOGIN_BUTTON_GAP })
  }

  /** 「验证码登录」：5 个字，居中；重叠时它的字形比 6 个字的标签右移半个字 */
  @Builder
  codeLoginLink() {
    Row() {
      Text('验证码登录')
        .fontSize(LOGIN_LINK_FONT)
        .fontColor(LOGIN_LINK_COLOR)
        .maxLines(1)
    }
    .width('100%')
    .height(LOGIN_LINK_BOX_HEIGHT)
    .justifyContent(FlexAlign.Center)
    .margin({ top: LOGIN_LINK_GAP })
    .alignItems(VerticalAlign.Center)
  }

  // ------------------------------------------------------------------
  // 三方登录区
  // ------------------------------------------------------------------

  /**
   * 「其他登录方式」：横屏紧凑态被向上偏移 LOGIN_COMPACT_LABEL_LIFT，
   * offset 不参与布局，所以标签会直接叠到「验证码登录」那一行上。
   */
  @Builder
  otherMethodLabel() {
    Row() {
      Text('其他登录方式')
        .fontSize(LOGIN_OTHER_METHOD_FONT)
        .fontColor(LOGIN_OTHER_METHOD_COLOR)
        .maxLines(1)
    }
    .width('100%')
    .height(LOGIN_OTHER_METHOD_LINE_HEIGHT)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .offset({ y: -this.otherMethodLiftVp() })
  }

  @Builder
  huaweiPetal(angleDeg: number) {
    Column()
      .width(3.2)
      .height(8.8)
      .borderRadius(1.6)
      .backgroundColor(LOGIN_HUAWEI_RED)
      .border({ width: LOGIN_HUAWEI_PETAL_STROKE, color: LOGIN_HUAWEI_BG })
      .rotate({ angle: angleDeg })
      .offset({
        x: LOGIN_HUAWEI_PETAL_RADIUS * Math.sin(angleDeg * Math.PI / 180),
        y: -LOGIN_HUAWEI_PETAL_RADIUS * LOGIN_HUAWEI_PETAL_FLATTEN * Math.cos(angleDeg * Math.PI / 180)
      })
  }

  /** 华为图标：浅灰圆底 + 红色花瓣 + HUAWEI 字样 */
  @Builder
  huaweiIcon() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width(LOGIN_ICON_SIZE)
        .height(LOGIN_ICON_SIZE)
        .borderRadius(LOGIN_ICON_SIZE / 2)
        .backgroundColor(LOGIN_HUAWEI_BG)

      Column({ space: 1.5 }) {
        Stack({ alignContent: Alignment.Center }) {
          ForEach(LOGIN_HUAWEI_PETAL_ANGLES, (petalAngle: number) => {
            this.huaweiPetal(petalAngle)
          }, (petalAngle: number) => petalAngle.toString())
        }
        .width(23)
        .height(16)

        Text('HUAWEI')
          .fontSize(4.4)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .letterSpacing(0.1)
          .margin({ top: 0.5 })
      }
      .alignItems(HorizontalAlign.Center)
      .offset({ y: -1 })
    }
    .width(LOGIN_ICON_SIZE)
    .height(LOGIN_ICON_SIZE)
  }

  /** QQ 图标：蓝色圆底 + 白色企鹅剪影（头 / 身体 / 两侧翅膀） */
  @Builder
  qqIcon() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width(LOGIN_ICON_SIZE)
        .height(LOGIN_ICON_SIZE)
        .borderRadius(LOGIN_ICON_SIZE / 2)
        .backgroundColor(LOGIN_QQ_BLUE)

      Column()
        .width(21)
        .height(20)
        .borderRadius(10)
        .backgroundColor(Color.White)
        .offset({ x: 0, y: 5 })

      Column()
        .width(4.6)
        .height(12.5)
        .borderRadius(2.3)
        .backgroundColor(Color.White)
        .rotate({ angle: 18 })
        .offset({ x: -9.5, y: 4 })

      Column()
        .width(4.6)
        .height(12.5)
        .borderRadius(2.3)
        .backgroundColor(Color.White)
        .rotate({ angle: -18 })
        .offset({ x: 9.5, y: 4 })

      Column()
        .width(5)
        .height(3)
        .borderRadius(1.5)
        .backgroundColor(Color.White)
        .offset({ x: -5, y: 15 })

      Column()
        .width(5)
        .height(3)
        .borderRadius(1.5)
        .backgroundColor(Color.White)
        .offset({ x: 5, y: 15 })

      Column()
        .width(14.5)
        .height(14)
        .borderRadius(7.25)
        .backgroundColor(Color.White)
        .offset({ x: 0, y: -7 })
    }
    .width(LOGIN_ICON_SIZE)
    .height(LOGIN_ICON_SIZE)
  }

  /** 图标行：整行 SpaceEvenly 平分窗口宽度（三态量测一致） */
  @Builder
  thirdPartyIcons() {
    Row() {
      this.huaweiIcon()
      this.qqIcon()
    }
    .width('100%')
    .height(LOGIN_ICON_SIZE)
    .justifyContent(FlexAlign.SpaceEvenly)
    .alignItems(VerticalAlign.Center)
  }

  /** 三方登录区：贴着页面底部的 77.1vp 摆放 */
  @Builder
  thirdPartyZone() {
    Column() {
      this.otherMethodLabel()

      Column()
        .width('100%')
        .height(LOGIN_LABEL_ICON_GAP)

      this.thirdPartyIcons()
    }
    .width('100%')
    .padding({ bottom: LOGIN_ICON_BOTTOM_INSET })
  }

  build() {
    NavDestination() {
      Column() {
        // ① 顶部：关闭 / 帮助
        Column() {
          this.headerRow()
        }
        .width('100%')
        .margin({ top: LOGIN_HEADER_TOP })

        // ② 标题
        Column() {
          this.loginTitle()
        }
        .width('100%')
        .margin({ top: LOGIN_TITLE_GAP })

        // ③ 表单
        Column() {
          this.phoneField()
          this.passwordField()
          this.agreementRow()
          this.loginButton()
          this.codeLoginLink()
        }
        .width('100%')
        .padding({ left: LOGIN_SIDE_INSET, right: LOGIN_SIDE_INSET })
        .margin({ top: LOGIN_FIELD_GAP })
        .alignItems(HorizontalAlign.Start)

        Blank()

        // ④ 三方登录区（贴底）
        this.thirdPartyZone()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.White)
      .alignItems(HorizontalAlign.Start)
      .onAreaChange((oldArea: Area, newArea: Area) => {
        if (typeof newArea.width === 'number' && newArea.width > 0) {
          this.winWidthVp = newArea.width;
        }
        if (typeof newArea.height === 'number' && newArea.height > 0) {
          this.winHeightVp = newArea.height;
        }
        // 不同屏态的密度可能不同，图标里的 Path 坐标要按新的密度重算
        this.vpScale = this.getUIContext().vp2px(1);
      })
    }
    .hideTitleBar(true)
  }
}
