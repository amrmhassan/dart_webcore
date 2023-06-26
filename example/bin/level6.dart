// generating docs for your API
import 'dart:io';

import 'package:dart_webcore/dart_webcore.dart';
import 'package:dart_webcore/dart_webcore/documentation/entity_doc.dart';

HandlerDoc helloDocs = HandlerDoc(
  body: [
    BodyField('name', 'Should be a string',
        type: 'String', description: 'This must be a string'),
  ],
);
MiddlewareDoc helloDocsM = MiddlewareDoc(
  body: [
    BodyField(
      'jwt',
      'you must provide the jwt',
    ),
  ],
);
void main(List<String> args) async {
  Router router = Router()
    ..get(
      '/hello',
      (request, response, pathArgs) => response.write('hello'),
      docs: helloDocs,
    )
    ..addUpperMiddleware(
      null,
      HttpMethods.all,
      (request, response, pathArgs) {
        print('here');
        return request;
      },
      docs: helloDocsM,
    );

  ServerHolder serverHolder = ServerHolder(router);
  await serverHolder.bind(InternetAddress.anyIPv4, 3000);
  var docs = DocGenerator(serverHolder.requestProcessor);
  router.setDoc();
  var doc = router.doc;
  print(doc);
  docs.generate();
}
