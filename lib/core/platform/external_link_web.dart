import 'dart:js_interop';

@JS('window.open')
external JSAny? _openWindow(JSString url, JSString target, JSString features);

void openExternalLinkImpl(String url) {
  _openWindow(url.toJS, '_blank'.toJS, 'noopener,noreferrer'.toJS);
}
