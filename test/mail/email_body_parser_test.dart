import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/l10n/generated/app_localizations.dart';
import 'package:mailnest_app/mail/body/email_body_parser.dart';
import 'package:mailnest_app/mail/body/email_body_renderer.dart';
import 'package:mailnest_app/mail/body/email_html_sanitizer.dart';
import 'package:mailnest_app/mail/body/email_render_options.dart';
import 'package:mailnest_app/mail/body/inline_image.dart';
import 'package:mailnest_app/mail/body/parsed_email_body.dart';

void main() {
  test(
    'extracts html, plain text, attachments, and remote image state',
    () async {
      const raw = '''
Subject: Test
Content-Type: multipart/mixed; boundary="outer"

--outer
Content-Type: multipart/alternative; boundary="alt"

--alt
Content-Type: text/plain; charset=utf-8

plain body
--alt
Content-Type: text/html; charset=utf-8

<p>Hello</p><img src="https://example.com/a.png">
--alt--
--outer
Content-Type: application/pdf; name="a.pdf"
Content-Disposition: attachment; filename="a.pdf"
Content-Transfer-Encoding: base64

SGVsbG8=
--outer--
''';

      final body = await const SimpleEmailBodyParser().parse(rawMessage: raw);

      expect(body.plainText, contains('plain body'));
      expect(body.html, contains('<p>Hello</p>'));
      expect(body.hasRemoteImages, isTrue);
      expect(body.attachments.single.filename, 'a.pdf');
    },
  );

  test('marks encrypted messages as unsupported', () async {
    const raw = '''
Content-Type: multipart/encrypted; boundary="enc"

--enc
Content-Type: application/octet-stream

encrypted
--enc--
''';

    final body = await const SimpleEmailBodyParser().parse(rawMessage: raw);

    expect(body.isEncrypted, isTrue);
    expect(body.hasUnsupportedParts, isTrue);
  });

  test('sanitizer removes scripts and events but preserves image tags', () {
    final sanitized = const BasicEmailHtmlSanitizer().sanitize(
      html:
          '<style>.x{color:red}</style><p onclick="bad()">Hi</p><script>x()</script><img src="https://x.test/a.png">',
      allowRemoteImages: false,
    );

    expect(sanitized, isNot(contains('onclick')));
    expect(sanitized, isNot(contains('<script')));
    expect(sanitized, isNot(contains('color:red')));
    expect(sanitized, contains('<img src="https://x.test/a.png">'));
  });

  test('plain text conversion removes email CSS blocks', () {
    final text = const BasicEmailHtmlSanitizer().toPlainText(
      '<style>@font-face{font-family:test}.ExternalClass{width:100%}</style><p>你的临时 ChatGPT 登录代码</p>',
    );

    expect(text, '你的临时 ChatGPT 登录代码');
  });

  testWidgets('renderer shows cid and data images', (tester) async {
    const png = <int>[
      137,
      80,
      78,
      71,
      13,
      10,
      26,
      10,
      0,
      0,
      0,
      13,
      73,
      72,
      68,
      82,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      1,
      8,
      6,
      0,
      0,
      0,
      31,
      21,
      196,
      137,
      0,
      0,
      0,
      12,
      73,
      68,
      65,
      84,
      120,
      156,
      99,
      248,
      15,
      4,
      0,
      9,
      251,
      3,
      253,
      167,
      158,
      129,
      123,
      0,
      0,
      0,
      0,
      73,
      69,
      78,
      68,
      174,
      66,
      96,
      130,
    ];
    const body = ParsedEmailBody(
      html:
          '<p>Hello</p><img src="cid:logo@test"><img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGP4DwQACfsD/aeeQXsAAAAASUVORK5CYII=">',
      inlineImages: [
        InlineImage(contentId: 'logo@test', mimeType: 'image/png', bytes: png),
      ],
      hasInlineImages: true,
    );

    await tester.pumpWidget(_RendererHost(body: body));

    expect(find.byType(Image), findsNWidgets(2));
    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('renderer blocks remote images by default', (tester) async {
    const body = ParsedEmailBody(
      html: '<p>Hello</p><img src="https://example.com/logo.png">',
      hasRemoteImages: true,
    );
    var loadRequested = false;

    await tester.pumpWidget(
      _RendererHost(
        body: body,
        options: EmailRenderOptions(
          onLoadRemoteImages: () => loadRequested = true,
        ),
      ),
    );

    expect(find.byType(Image), findsNothing);
    expect(find.textContaining('remote images'), findsWidgets);
    expect(find.text('Load images'), findsOneWidget);

    await tester.tap(find.text('Load images'));
    expect(loadRequested, isTrue);
  });

  testWidgets('renderer loads remote images when allowed', (tester) async {
    const body = ParsedEmailBody(
      html: '<p>Hello</p><img src="https://example.com/logo.png">',
      hasRemoteImages: true,
    );

    await tester.pumpWidget(
      const _RendererHost(
        body: body,
        options: EmailRenderOptions(allowRemoteImages: true),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(find.textContaining('remote images'), findsNothing);
  });

  testWidgets('renderer respects explicit image dimensions', (tester) async {
    const body = ParsedEmailBody(
      html:
          '<img width="120" height="48" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGP4DwQACfsD/aeeQXsAAAAASUVORK5CYII=">',
      hasInlineImages: true,
    );

    await tester.pumpWidget(
      const _RendererHost(
        body: body,
        options: EmailRenderOptions(allowRemoteImages: true),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is SizedBox && widget.width == 120 && widget.height == 48,
      ),
      findsOneWidget,
    );
  });

  testWidgets('renderer preserves centered styled email blocks', (
    tester,
  ) async {
    const body = ParsedEmailBody(
      html:
          '<div style="text-align:center; max-width:480px; margin:0 auto;">'
          '<p>输入此临时验证码以继续:</p>'
          '<div style="background-color:#f4f4f4; border-radius:12px; padding:24px; width:296px;">040253</div>'
          '</div>',
    );

    await tester.pumpWidget(const _RendererHost(body: body));

    expect(find.text('输入此临时验证码以继续:'), findsOneWidget);
    expect(find.text('040253'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.constraints?.minWidth == 296 &&
            widget.constraints?.maxWidth == 296,
      ),
      findsOneWidget,
    );
  });

  testWidgets('renderer keeps simple invoice rows and button links grouped', (
    tester,
  ) async {
    const body = ParsedEmailBody(
      html:
          '<div style="max-width:520px; margin:0 auto;">'
          '<p>你已成功创建 ChatGPT Business 工作空间。</p>'
          '<p style="text-align:center;"><a href="https://example.com" style="background-color:#10a37f; color:#ffffff; border-radius:4px; padding:12px 18px;">管理订阅</a></p>'
          '<table width="520">'
          '<tr><td style="text-align:left;"><b>套餐</b></td><td style="text-align:right;"><b>金额</b></td></tr>'
          '<tr><td style="text-align:left;">ChatGPT Business Subscription</td><td style="text-align:right;">A\$70.00</td></tr>'
          '</table>'
          '</div>',
    );

    await tester.pumpWidget(const _RendererHost(body: body));

    expect(find.text('管理订阅'), findsOneWidget);
    expect(find.text('套餐'), findsOneWidget);
    expect(find.text('金额'), findsOneWidget);
    expect(find.text('ChatGPT Business Subscription'), findsOneWidget);
    expect(find.text('A\$70.00'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration! as BoxDecoration).color ==
                const Color(0xff10a37f),
      ),
      findsOneWidget,
    );
  });

  testWidgets('renderer scales fixed-width email canvas without reflowing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    const body = ParsedEmailBody(
      html:
          '<div style="max-width:600px; margin:0 auto;">'
          '<p>输入此临时验证码以继续:</p>'
          '<table width="600"><tr><td>ChatGPT</td><td>帮助中心</td></tr></table>'
          '</div>',
    );

    await tester.pumpWidget(const _RendererHost(body: body));

    expect(find.byType(FittedBox), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.width == 600,
      ),
      findsOneWidget,
    );
    expect(find.text('ChatGPT'), findsOneWidget);
    expect(find.text('帮助中心'), findsOneWidget);
  });

  testWidgets('renderer makes text and button links clickable', (tester) async {
    const body = ParsedEmailBody(
      html:
          '<p>Visit <a href="https://example.com/help">帮助中心</a></p>'
          '<p><a href="mailto:support@example.com" style="background-color:#10a37f; color:#ffffff; padding:12px;">联系支持</a></p>',
    );

    await tester.pumpWidget(const _RendererHost(body: body));

    expect(find.text('帮助中心'), findsOneWidget);
    expect(find.text('联系支持'), findsOneWidget);
    expect(find.byType(GestureDetector), findsNWidgets(2));
    expect(
      find.descendant(
        of: find.ancestor(
          of: find.text('帮助中心'),
          matching: find.byType(GestureDetector),
        ),
        matching: find.byType(SelectableText),
      ),
      findsNothing,
    );
    expect(
      tester
          .getSize(
            find.ancestor(
              of: find.text('帮助中心'),
              matching: find.byType(GestureDetector),
            ),
          )
          .width,
      lessThan(160),
    );
  });
}

class _RendererHost extends StatelessWidget {
  const _RendererHost({
    required this.body,
    this.options = const EmailRenderOptions(),
  });

  final ParsedEmailBody body;
  final EmailRenderOptions options;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => const BasicEmailBodyRenderer().build(
            context,
            body: body,
            options: options,
          ),
        ),
      ),
    );
  }
}
