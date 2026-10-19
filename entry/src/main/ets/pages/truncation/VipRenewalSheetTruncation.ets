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
 * 反例：截断 / 会员续费弹层截断
 *
 * 复刻盒马 X 88VIP 续费页：底部弹层的字号、间距、卡片高度全部按「窗口宽度 / 361vp」
 * 等比放大（H5 rem 适配的典型写法），弹层整体贴底摆放，自身高度不做窗口高度收敛。
 *
 * 当前 Pura X Max 上：
 * 单屏态（459.6vp 宽）弹层约 384vp 高，完整贴在页面底部；
 * 双屏态竖屏（664.7vp 宽）弹层约 544vp 高，仍能完整显示；
 * 双屏态横屏（939.6vp 宽）弹层约 757vp 高，超过 664.7vp 的窗口高度，
 * 顶部约 92vp 被窗口裁掉：说明文案只剩被切掉上半截的第二行，弹层圆角也移出屏幕。
 */

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

/** 缩放基准宽度：弹层设计尺寸按 361vp 宽绘制，实际窗口宽度 / 361 即为缩放比 */
const VIP_RENEWAL_REFERENCE_WIDTH: number = 361;

/** 弹层贴底后固定预留的底部安全区（不参与等比放大） */
const VIP_RENEWAL_BOTTOM_INSET: number = 28;

/** 缩放基准下的弹层内容高度（不含底部安全区） */
const VIP_RENEWAL_CONTENT_HEIGHT: number = 280;

const VIP_RENEWAL_BENEFIT_ICONS: string[] = ['券', '礼', '惠', '卡', '享', '免', '邮', '退'];

@Component
export struct VipRenewalSheetTruncationPage {
  pageStack: NavPathStack = new NavPathStack();

  @State winWidthVp: number = VIP_RENEWAL_REFERENCE_WIDTH;
  @State statusBarHeightVp: number = 34;

  private hostWindow: window.Window | undefined = undefined;

  aboutToAppear(): void {
    this.enableFullScreen();
  }

  aboutToDisappear(): void {
    this.restoreWindowMode();
  }

  private enableFullScreen(): void {
    const hostContext = this.getUIContext().getHostContext();
    if (hostContext === undefined) {
      return;
    }
    window.getLastWindow(hostContext).then((win: window.Window) => {
      this.hostWindow = win;
      const avoidArea: window.AvoidArea = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      const topInset: number = this.getUIContext().px2vp(avoidArea.topRect.height);
      if (topInset > 0) {
        this.statusBarHeightVp = topInset;
      }
      win.setWindowLayoutFullScreen(true).catch((error: BusinessError) => {
        console.error(`setWindowLayoutFullScreen failed, code=${error.code}`);
      });
      win.setWindowSystemBarProperties({
        statusBarContentColor: '#FFFFFF',
        navigationBarContentColor: '#FFFFFF'
      }).catch((error: BusinessError) => {
        console.error(`setWindowSystemBarProperties failed, code=${error.code}`);
      });
    }).catch((error: BusinessError) => {
      console.error(`getLastWindow failed, code=${error.code}`);
    });
  }

  private restoreWindowMode(): void {
    const win: window.Window | undefined = this.hostWindow;
    if (win === undefined) {
      return;
    }
    win.setWindowLayoutFullScreen(false).catch((error: BusinessError) => {
      console.error(`setWindowLayoutFullScreen failed, code=${error.code}`);
    });
    win.setWindowSystemBarProperties({
      statusBarContentColor: '#000000',
      navigationBarContentColor: '#000000'
    }).catch((error: BusinessError) => {
      console.error(`setWindowSystemBarProperties failed, code=${error.code}`);
    });
    this.hostWindow = undefined;
  }

  /** 弹层内容随窗口宽度等比放大，越宽的窗口弹层越高 */
  private uiScale(): number {
    const widthRatio: number = this.winWidthVp / VIP_RENEWAL_REFERENCE_WIDTH;
    return widthRatio < 1 ? 1 : widthRatio;
  }

  private vs(baseVp: number): number {
    return baseVp * this.uiScale();
  }

  private sheetHeightVp(): number {
    return VIP_RENEWAL_CONTENT_HEIGHT * this.uiScale() + VIP_RENEWAL_BOTTOM_INSET;
  }

  @Builder
  posterNavBar() {
    Row() {
      Text('‹')
        .fontSize(this.vs(24))
        .fontColor('#D9C5A8')
        .width(this.vs(34))
        .textAlign(TextAlign.Center)
        .onClick(() => {
          this.pageStack.pop();
        })

      Text('会员已过期 346 天')
        .fontSize(this.vs(12))
        .fontColor('#CDB79A')
        .textAlign(TextAlign.Center)
        .layoutWeight(1)

      Text('规则')
        .fontSize(this.vs(11))
        .fontColor('#B7A184')
        .width(this.vs(34))
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height(this.vs(30))
    .padding({ left: this.vs(6), right: this.vs(6) })
    .margin({ top: this.statusBarHeightVp + this.vs(4) })
  }

  @Builder
  posterMemberCard() {
    Stack({ alignContent: Alignment.End }) {
      Column() {
        Row({ space: this.vs(4) }) {
          Text('盒马X')
            .fontSize(this.vs(13))
            .fontWeight(FontWeight.Bold)
            .fontColor('#D8C0A0')

          Text('88VIP会员')
            .fontSize(this.vs(7.5))
            .fontColor('#C2AA8B')
            .border({ width: this.vs(1), color: '#7A5B3C' })
            .borderRadius(this.vs(2))
            .padding({ left: this.vs(4), right: this.vs(4), top: this.vs(1), bottom: this.vs(1) })
        }
        .alignItems(VerticalAlign.Center)

        Row({ space: this.vs(2) }) {
          Text('预计可省1424元')
            .fontSize(this.vs(20))
            .fontWeight(FontWeight.Bold)
            .fontColor('#C9B08C')

          Text('›')
            .fontSize(this.vs(15))
            .fontColor('#BFA37E')
        }
        .margin({ top: this.vs(8) })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: this.vs(12), right: this.vs(12) })

      Text('✕')
        .fontSize(this.vs(58))
        .fontColor('#8B6A45')
        .opacity(0.28)
        .rotate({ angle: -12 })
        .margin({ right: this.vs(10) })
    }
    .width('92%')
    .height(this.vs(66))
    .margin({ top: this.vs(8) })
    .backgroundColor('#3A2417')
    .border({ width: this.vs(1), color: '#5C4127' })
    .borderRadius(this.vs(10))
    .clip(true)
  }

  @Builder
  posterBenefitPanel() {
    Column() {
      Row() {
        Divider()
          .width(this.vs(26))
          .strokeWidth(1)
          .color('#7A7268')

        Text('开卡享专属 8 大权益')
          .fontSize(this.vs(11))
          .fontColor('#A99D8F')
          .margin({ left: this.vs(8), right: this.vs(8) })

        Divider()
          .width(this.vs(26))
          .strokeWidth(1)
          .color('#7A7268')
      }
      .margin({ top: this.vs(20) })

      Row({ space: this.vs(7) }) {
        ForEach(VIP_RENEWAL_BENEFIT_ICONS, (iconLabel: string) => {
          Text(iconLabel)
            .fontSize(this.vs(13))
            .fontColor('#9C8C79')
            .width(this.vs(32))
            .height(this.vs(32))
            .textAlign(TextAlign.Center)
            .backgroundColor('#4A423B')
            .borderRadius(this.vs(9))
        }, (iconLabel: string) => iconLabel)
      }
      .margin({ top: this.vs(16) })
    }
    .width('100%')
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#524A42')
    .borderRadius({ topLeft: this.vs(14), topRight: this.vs(14) })
    .margin({ top: this.vs(10) })
  }

  @Builder
  posterLayer() {
    Column() {
      this.posterNavBar()
      this.posterMemberCard()
      this.posterBenefitPanel()
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#2A1810')
  }

  @Builder
  sheetDescription() {
    Row() {
      Column()
        .width(this.vs(2))
        .height(this.vs(11))
        .backgroundColor('#E4C3A4')
        .borderRadius(this.vs(1))
        .margin({ top: this.vs(3), right: this.vs(4) })

      Text() {
        Span('88元/年(365天)，该权益为88VIP用户专属的盒马X会员年卡版，')
          .fontColor('#8C8C8C')
        Span('不含88VIP权益。')
          .fontColor('#E5492F')
      }
      .fontSize(this.vs(10.5))
      .lineHeight(this.vs(15))
      .layoutWeight(1)
      .height(this.vs(30))
      .maxLines(2)
      .textOverflow({ overflow: TextOverflow.Ellipsis })

      Row({ space: this.vs(2) }) {
        Text('收起')
          .fontSize(this.vs(10.5))
          .fontColor('#8C8C8C')

        Text('∨')
          .fontSize(this.vs(12))
          .fontColor('#B0B0B0')
      }
      .margin({ left: this.vs(4) })
      .onClick(() => {
        this.pageStack.pop();
      })
    }
    .width('100%')
    .height(this.vs(36))
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  couponCard() {
    Stack({ alignContent: Alignment.End }) {
      Row() {
        Column() {
          Row({ space: this.vs(1) }) {
            Text('¥')
              .fontSize(this.vs(9))
              .fontColor('#F04B2D')
              .margin({ top: this.vs(4) })

            Text('20')
              .fontSize(this.vs(25))
              .fontWeight(FontWeight.Bold)
              .fontColor('#F04B2D')
          }
          .alignItems(VerticalAlign.Top)

          Text('全场通用')
            .fontSize(this.vs(8))
            .fontColor('#D06A45')
        }
        .width('26%')
        .alignItems(HorizontalAlign.Center)

        Divider()
          .vertical(true)
          .height('58%')
          .strokeWidth(this.vs(1))
          .color('#F3C9BB')

        Column() {
          Text('20元红包')
            .fontSize(this.vs(14))
            .fontWeight(FontWeight.Bold)
            .fontColor('#3A2A1E')

          Text('满20.01元可用')
            .fontSize(this.vs(8.5))
            .fontColor('#E8663F')
            .border({ width: this.vs(1), color: '#F6B6A2' })
            .borderRadius(this.vs(3))
            .padding({ left: this.vs(4), right: this.vs(4), top: this.vs(1), bottom: this.vs(1) })
            .margin({ top: this.vs(3) })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .padding({ left: this.vs(12) })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FFF7F3')
      .border({ width: this.vs(2), color: '#FF6647', radius: this.vs(9) })
      .clip(true)

      Row()
        .width('10%')
        .height('100%')
        .backgroundColor('#FF5235')
        .borderRadius({ topRight: this.vs(7), bottomRight: this.vs(7) })

      Row()
        .width(this.vs(22))
        .height(this.vs(22))
        .backgroundColor('#FFE6CF')
        .borderRadius(this.vs(11))
        .margin({ right: this.vs(26) })
    }
    .width('100%')
    .height(this.vs(72))
    .margin({ top: this.vs(6) })
  }

  @Builder
  giftCard() {
    Column() {
      Row({ space: this.vs(4) }) {
        Text('加赠')
          .fontSize(this.vs(8.5))
          .fontColor(Color.White)
          .backgroundColor('#7A4E2A')
          .borderRadius(this.vs(3))
          .padding({ left: this.vs(5), right: this.vs(5), top: this.vs(2), bottom: this.vs(2) })

        Text('续费立得')
          .fontSize(this.vs(15))
          .fontWeight(FontWeight.Bold)
          .fontColor('#3A2A1E')

        Text('20')
          .fontSize(this.vs(16))
          .fontWeight(FontWeight.Bold)
          .fontColor('#F04B2D')

        Text('元红包')
          .fontSize(this.vs(15))
          .fontWeight(FontWeight.Bold)
          .fontColor('#3A2A1E')
      }
      .width('100%')
      .height(this.vs(28))
      .alignItems(VerticalAlign.Center)

      this.couponCard()
    }
    .width('100%')
    .height(this.vs(116))
    .padding(this.vs(5))
    .alignItems(HorizontalAlign.Start)
    .backgroundColor('#FFF8EC')
    .borderRadius(this.vs(9))
    .margin({ top: this.vs(2) })
  }

  @Builder
  priceBar() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Row() {
        Row({ space: this.vs(1) }) {
          Text('¥')
            .fontSize(this.vs(13))
            .fontColor('#F7E9CF')

          Text('88')
            .fontSize(this.vs(25))
            .fontWeight(FontWeight.Bold)
            .fontColor('#F7E9CF')

          Text('/年')
            .fontSize(this.vs(11))
            .fontColor('#F7E9CF')
            .margin({ top: this.vs(6) })
        }
        .width('63%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#3E2A1B')
        .borderRadius(this.vs(22))

        Blank()

        Row() {
          Text('立即续费')
            .fontSize(this.vs(19))
            .fontWeight(FontWeight.Bold)
            .fontColor('#4A2E1A')
        }
        .layoutWeight(1)
        .height('100%')
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F8E6CC')
      .borderRadius(this.vs(22))

      Row() {
        Text('88VIP专属福利价')
          .fontSize(this.vs(9.5))
          .fontColor(Color.White)
      }
      .height(this.vs(19))
      .padding({ left: this.vs(6), right: this.vs(6) })
      .backgroundColor('#F5462E')
      .borderRadius(this.vs(10))
      .offset({ y: -this.vs(9) })
      .margin({ right: this.vs(4) })
    }
    .width('100%')
    .height(this.vs(44))
    .margin({ top: this.vs(22) })
  }

  @Builder
  agreementRow() {
    Column() {
      Row() {
        Row()
          .width(this.vs(10))
          .height(this.vs(10))
          .border({ width: this.vs(1), color: '#D8C7B6' })
          .borderRadius(this.vs(2))
          .margin({ top: this.vs(1), right: this.vs(4) })

        Text() {
          Span('阅读并同意')
            .fontColor('#7A7A7A')
          Span('《盒马X88VIP专属会员服务协议》')
            .fontColor('#2B2B2B')
          Span(' 和')
            .fontColor('#7A7A7A')
        }
        .fontSize(this.vs(9))
        .lineHeight(this.vs(11))
        .layoutWeight(1)
        .maxLines(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Text('《盒马X88VIP专属会员权益细则》')
        .fontSize(this.vs(9))
        .lineHeight(this.vs(11))
        .fontColor('#2B2B2B')
        .maxLines(1)
    }
    .width('72%')
    .height(this.vs(30))
    .alignItems(HorizontalAlign.Center)
    .margin({ top: this.vs(17) })
  }

  @Builder
  renewalSheet() {
    Column() {
      this.sheetDescription()
      this.giftCard()
      this.priceBar()
      this.agreementRow()
    }
    .width('100%')
    .height(this.sheetHeightVp())
    .padding({
      left: this.vs(16),
      right: this.vs(16),
      top: this.vs(13),
      bottom: VIP_RENEWAL_BOTTOM_INSET
    })
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: this.vs(10), topRight: this.vs(10) })
    .shadow({ radius: this.vs(12), color: '#33000000', offsetX: 0, offsetY: -this.vs(2) })
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        this.posterLayer()

        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#000000')
          .opacity(0.35)
          .hitTestBehavior(HitTestMode.None)

        this.renewalSheet()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#2A1810')
      .clip(true)
      .onAreaChange((oldArea: Area, newArea: Area) => {
        if (typeof newArea.width === 'number') {
          this.winWidthVp = newArea.width;
        }
      })
    }
    .hideTitleBar(true)
  }
}
