import std/strutils
import std/mimetypes
import std/httpcore except HttpHeaders # Exclude HttpHeaders since mummy exports webby's HttpHeaders
import mummy
import mummy/routers
from webby import decodeQueryComponent, `[]`

type Details * = ref object
  urlOrg        *:string
  urlHasParams  *:bool

type CallbackHandler * = proc(request :Request; details :Details) :void {.gcsafe.}

proc paramGeneratorValue *(request :Request; backendRoute :string; s :string) :string=
  ## Find and return single param from request.
  ##
  ## Starts in:
  ## - URL path
  ## - URL query
  ## - body data.
  let uriSplit = request.uri.split("?")
  # Path data: /project/@projectID/user/@fileID
  if "@" in backendRoute:
    let urlOrg  = backendRoute.split("/")
    let uriMain = uriSplit[0].split("/")
    for i in 1..urlOrg.high:
      if urlOrg[i][0] == '@' and urlOrg[i].len() > 1:
        if urlOrg[i][1..^1] == s:
          return uriMain[i]
  # URL query: ?name=thomas
  if uriSplit.len() > 1:
    for pairStr in uriSplit[1].split("#")[0].split('&'):
      let pair = pairStr.split('=', 1)
      let kv =
        if pair.len == 2 : (decodeQueryComponent(pair[0]), decodeQueryComponent(pair[1]))
        else             : (decodeQueryComponent(pair[0]), "")
      if kv[0] == s:
        return kv[1]
  # Body data: name=thomas
  if "x-www-form-urlencoded" in request.headers["Content-Type"].toLowerAscii():
    for pairStr in request.body.split('&'):
      let pair = pairStr.split('=', 1)
      let kv =
        if pair.len == 2 : (decodeQueryComponent(pair[0]), decodeQueryComponent(pair[1]))
        else             : (decodeQueryComponent(pair[0]), "")
      if kv[0] == s: return kv[1]

# Callback for routes
proc paramCallback(wrapped: CallbackHandler, details: Details): RequestHandler =
  ## Callback where the `Details` is being generated and params
  ## are being made ready.
  return proc(request :Request) :void= wrapped(request, details)

# Router transformer
template routeSet*(
    router    : Router;
    routeType : HttpMethod;
    route     : string;
    handler   : CallbackHandler;
  ) :untyped=
  ## Transform router with route and handler.
  ## Saving the original route and including the `Details` in the callback.
  # Saving original route
  var rFinal: seq[string]
  var urlParams: bool = false
  for r in route.split("#")[0].split("/"):
    if r.len() == 0  : continue
    elif r[0] == '@' : rFinal.add("*"); urlParams = true  # Got @-path, replace with *
    else             : rFinal.add(r)
  # Generating routes
  case routeType
  of HttpGet     : router.get(     "/" & rFinal.join("/"), handler.paramCallback(Details(urlOrg: route, urlHasParams: urlParams)))
  of HttpDelete  : router.delete(  "/" & rFinal.join("/"), handler.paramCallback(Details(urlOrg: route, urlHasParams: urlParams)))
  of HttpHead    : router.head(    "/" & rFinal.join("/"), handler.paramCallback(Details(urlOrg: route, urlHasParams: urlParams)))
  of HttpPost    : router.post(    "/" & rFinal.join("/"), handler.paramCallback(Details(urlOrg: route, urlHasParams: urlParams)))
  of HttpPut     : router.put(     "/" & rFinal.join("/"), handler.paramCallback(Details(urlOrg: route, urlHasParams: urlParams)))
  of HttpOptions : router.options( "/" & rFinal.join("/"), handler.paramCallback(Details(urlOrg: route, urlHasParams: urlParams)))
  of HttpPatch   : router.patch(   "/" & rFinal.join("/"), handler.paramCallback(Details(urlOrg: route, urlHasParams: urlParams)))
  else: quit("Unknown route type: " & $routeType)


template `@` *(s :string) :untyped =
  ## Get param.
  paramGeneratorValue(request, details.urlOrg, s)

template sendFile*(path: string) =
  ## @from https://github.com/ThomasTJdev/mummy_utils/blob/5ccb0ab7317167107b45b2c449de608d1ecae989/src/mummy_utils.nim#L510
  let r = readFile(path)
  when declared(headers):
    setHeader("Content-Type", newMimetypes().getMimetype(path.split(".")[^1]))
    request.respond(200, headers, r)
  else:
    request.respond(200, @[("Content-Type", newMimetypes().getMimetype(path.split(".")[^1]))], r)
  return

proc serveFiles (request :Request; details :Details)=
  sendFile("./" & @"filename")


when isMainModule:
  echo "Hello, Mummy!"
  var router: Router
  router.routeSet(HttpGet, "/@filename", serveFiles)

  let server = newServer(router)
  echo "Serving on http://localhost:8080"
  server.serve(Port(8080))
