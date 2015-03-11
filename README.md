#Sample setup project of nginx-luajit-websocket-pubsuber

sample Server - Unity Client implementation of below:  
[sassembla/nginx-luajit-websocket-pubsuber](https://github.com/sassembla/nginx-luajit-websocket-pubsuber)


##running
open Terminal.app

	sh Server/run.sh

then another Terminal window,

	sh Server/reset.sh

you can reset server context with reset.sh.
	
##stop

	sh Server/stop.sh	
	

##3 level context(not good case. Simply complexed...)

this implementation has 3 level context.

###level1: WebSocket serving
Serving WebSocket by nginx will start when nginx is ignited.

Every client application can connect with server. but there are no context yet.

###level2: Running context
Making http access to http://NGINX_HEARING_DOMAIN/controlpoint, then the server context will rise.


###level3: Connect context to WebSocket connections with redis
Startup redis process will start transport messages between WebSocket connections to the server context.

