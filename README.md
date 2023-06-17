# The final solution to HttpServers with dart 

<img src="https://github.com/amrmhassan/dart_webcore/blob/master/assets/logo.png?raw=true" alt="Image description" style="width: 400px; height: auto;
  border-radius: 10px;">

`dart_webcore` handles (Advanced Routing, HttpServers, websites hosting, static files hosting and much more...).  
`Most Important is personalized middlewares. where you can set middlewares for a single handler, router or even a whole pipeline`

## Features

1. Allow adding routing system
1. Host of static folders or websites
1. Pre programmed code for some utils like(Html response, json response)

## Tutorial  
<img src="https://github.com/amrmhassan/dart_webcore/blob/master/assets/flowchart.png?raw=true" alt="Image description" style="width: 600px; height: auto;
  border-radius: 10px;">

### - Routing ( Request Processors )
`dart_webcore` consist of different layers which are a type of `RequestProcessor` which mean they can handle incoming requests.

1. Handler: is the final stage in the life of the request in the server, handlers must return a response to the client ( API consumer ), a handler can have a local middleware that will only work for this handler, 
Handler needs a pathTemplate a method and a processor function.

```dart
 Handler handler = Handler('/hello', HttpMethods.geT,
      (request, response, pathArgs) => response.write('Hello world!'));
```

1. Middlewares: is a set of functions that live between the handler and the client to do some authentication or verification on the request, middlewares can return a request to let the request pass to the next middleware or handler or they can return a response to close prevent the request from passing to the next entity in the pipeline, 
middleware can be added to a single handler, router, full pipeline or the every single request that comes to the server which are called global middlewares.

```dart
  Middleware middleware =
      Middleware('/hello', HttpMethods.geT, (request, response, pathArgs) {
    print('new request');
    return request;
  });
```

3. Router: router is the parent of handlers, you can add multiple handlers to the router and the router is responsible for choosing the right handler to execute,  
you can also add middlewares to the router that will be executed only in this router.
```dart
  Router router = Router()
    ..get('/hello',
        (request, response, pathArgs) => response.write('Hello world!'))
    ..post('/register',
        (request, response, pathArgs) => response.write('user registered!'));
```


1. Pipeline: pipelines are the master of all the previous entities, you can add multiple routers, individual handlers to the pipeline and it will chose the right middlewares and the right handler to run for each incoming request.

```dart
  Pipeline pipeline = Pipeline().addRouter(router);
```

1. Cascade: cascade is just a way of adding multiple pipelines to the server if you have different types of apps that running on the same server you can just gather them in a single cascade. 
```dart
  Cascade cascade = Cascade().add(pipeline);

```

## - Server ( the actual server the receive requests )
`ServerHolder` is a class that handles creating servers and closing them 
it needs a request processor from above which will handle running the right handler and the right set of middlewares, 
you can run multiple servers for the same server holder.

```dart
// you can change 'cascade' with any other processor like pipeline, router or even a single handler
  ServerHolder serverHolder = ServerHolder(cascade);
  serverHolder.bind(InternetAddress.anyIPv4, 3000);
```

### - RequestProcessor parameters
1. pathTemplate: is the path template that would be compared with the incoming request path it should be unique for each handler  
and it follows the following formula
```
e.g: /login  
     /register  
     /users/list  
     /users/<user_id>/getData  
     /users/<users_id>/deleteUser  
     /files/*<file_path> 
 ```

- The normal pathTemplate is like `/login` , `/register` or `/users/list`
if any request has the same path it the corresponding handler will be chosen to run.

- The pathTemplate with pathArg like `/users/<user_id>/getData`  , `/users/<user_id>/deleteUser`  
and any request with paths like /users/the_actual_user_id/deleteUser this handler will work
and it will have access to the pathArgs in the form of
`{'user_id':'the_actual_user_id'}`.
```dart
  Handler pathArgHandler = Handler(
      '/getUser/<user_id>',
      HttpMethods.geT,
      (request, response, pathArgs) => response
          .write('you requested the user with id ${pathArgs['user_id']}'));
```

- The final pathTemplate example is for paths that have pathArgs with that contains multiple slashes /
for example, any request with paths like /files/path/to/file will work for be directed to the handler with path template `/files/*<file_path>` and will provide pathArgs map as `{'file_path':'path/to/file'}`  
you can only have one complex key like *<file_path> at the end or it will consider all the following path to be a value of the key.

```dart  
Handler pathArgHandler = Handler(
      '/getFile/*<file_path>',
      HttpMethods.geT,
      (request, response, pathArgs) => response.write(
          'you request the file with the path ${pathArgs['file_path']}'));

```

2. method: is the method for this handler or middleware(get, post, put...)  
for handler you can specify a HttpMethods.all to run this middleware with all methods for a specific pathTemplate,  
it is always preferable to run these kind of handlers(with HttpMethods.all) at the last of a pipeline.  
for middleware you can specify the pathTemplate to be null to run this middleware with all paths, and you can also set the method for a middleware to be HttpMethods.all to be a global middleware for a specific request processor like a router or a pipeline.

3. Processor: is the actual code for the middleware or a handler,  
it will be on the form of 
```  
(RequestHolder, ResponseHolder, Map<String, dynamic>){
    return PassedHttpEntity(either a RequestHolder or ResponseHolder)
  }  
  ```
if the return type is ResponseHolder this means that the response is send and the pipeline is closed,  
otherwise if the return type is RequestHolder this means that it will continue and the response not closed yet and it will pass the returned request to the next entity in the pipeline. 

### - Website Hosting
with dart_webcore you can host a full folder with all of it's content either this folder is a website folder or a normal static files folder.  
you just need to set an alias for that folder path in order to protect your system path to make it hidden from API consumers.
for example
```dart
  Router router = Router()
    ..get(
  /* it's alway better to make the files path template like this to be in the end of    
      the pipeline because it will accept all requested paths and the pathArgs 
      will take the path as the argument {'path':'all the path will be here'}
  */

      '/*<path>',
      (request, response, pathArgs) {
        return response.serveFolders(
          [
            FolderHost(path: './bin/website', alias: 'website'),
          ],
          pathArgs['path'],
          allowServingFoldersContent: true,
          autoViewIndexTextFiles: true,
          allowViewingEntityPath: true,
          viewTextBasedFiles: true,
        );
      },
    );

```

### - single files downloading/streaming
you can stream a file or serve it for downloading as following
```dart
router
..get(
        '/downloadImage',
        (request, response, pathArgs) =>
            response.writeFile('./bin/website/images/img.jpg'))
```
