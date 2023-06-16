import 'dart:io';

import 'package:dart_webcore/dart_webcore.dart';

// Pipeline is used to gather multiple routes or handlers and you can add a global middleware for the whole pipeline
// Cascade is used to gather multiple pipelines for some use cases which need this approach
void main(List<String> arguments) async {
  // of course you can use other methods like get or post or what ever method you want
  // i am just using get for simplicity so you can test this from your browser
  Router authRouter = Router()
    ..get(
        '/login',
        (request, response, pathArgs) =>
            response.writeHtml('<h1>logging in</h1>'))
    ..get(
        '/register',
        (request, response, pathArgs) =>
            response.writeHtml('please head to /register/(enter your name)'))
    ..get(
        '/register/<name>',
        (request, response, pathArgs) =>
            response.writeHtml('<h1>Registering ${pathArgs['name']}</h1>'));
  Router messagesRouter = Router()
    ..get(
        '/sendMessage',
        (request, response, pathArgs) =>
            response.write('message ${request.context}'))
    ..get('/deleteMessage',
        (request, response, pathArgs) => response.write('message deleted'));
  // you can use either addRouter or addRequestProcessor to add a handler or another pipeline or even a router
  Pipeline appPipeline = Pipeline()
      .addMiddleware(null, HttpMethods.all, (request, response, pathArgs) {
        // you can use this message from any other processor in the whole pipeline
        request.context['message'] =
            'This message is passed from the pipeline middleware';
        return request;
      })
      .addRawProcessor(authRouter)
      .addRouter(messagesRouter);

  Pipeline app2Pipeline = Pipeline().addHandler('/app2', HttpMethods.geT,
      (request, response, pathArgs) => response.write('you are in app 2 now'));
  Cascade cascade = Cascade().add(appPipeline).add(app2Pipeline);

  ServerHolder serverHolder = ServerHolder(
    cascade,
    onPathNotFound: (request, response, pathArgs) {
      return response.writeHtml('path not found 404');
    },
  );
  serverHolder.addGlobalMiddleware(logRequest);
  await serverHolder.bind(InternetAddress.anyIPv4, 3000);
}
