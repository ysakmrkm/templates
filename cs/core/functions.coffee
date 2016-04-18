'use strict'

# UserAgent
_ua = do ->
  IE = document.uniqueID
  ltIE6 = typeof window.addEventListener is undefined and typeof document.documentElement.style.maxHeight is undefined
  ltIE7 = typeof window.addEventListener is undefined and typeof document.querySelectorAll is undefined
  ltIE8 = typeof window.addEventListener is undefined and typeof document.getElementsByClassName is undefined
  ltIE9 = IE and typeof window.Worker is undefined
  IE6 = IE and ltIE6
  IE7 = IE and ltIE7 and not ltIE6
  IE8 = IE and ltIE8 and not ltIE7 and not ltIE6
  IE9 = IE and ltIE9 and not ltIE8 and not ltIE7 and not ltIE6
  IE10 = IE and not ltIE9 and not ltIE8 and not ltIE7 and not ltIE6
  Webkit = not document.uniqueID and not window.opera and not window.sidebar and not window.orientation and window.localStorage
  Safari = Webkit and navigator.vendor.search(/apple/i) isnt -1
  Chrome = Webkit and navigator.vendor.search(/google/i) isnt -1

  return {
    IE:IE,
    ltIE6:ltIE6,
    ltIE7:ltIE7,
    ltIE8:ltIE8,
    ltIE9:ltIE9,
    IE6:IE6,
    IE7:IE7,
    IE8:IE8,
    IE9:IE9,
    IE10:IE10,
    Firefox:window.sidebar,
    Opera:window.opera,
    Webkit:Webkit,
    Safari:Safari,
    Chrome:Chrome,
    Mobile:window.orientation
  }

# URL
url = do ->
  href = location.href.split('/')

  localRegex = /^\d+\.\d+\.\d+\.\d+/
  workRegex = /^.*\/pc\/[^\/]+\/.*$/

  for val , i in href
    if val is '' or i is href.length - 1 and val.indexOf('.')
      href.splice(i,1)

  if localRegex.test(location.hostname) is true or location.hostname.indexOf('localhost') isnt -1
    length = 2

  else if workRegex.test(location.href) is true
    length = 3

    for val , i in href
      if val is 'pc' and href[i-1] is 'work'
        length = 4

  else
    length = 1

  path = ''

  for j in [0..(length)]
    path += href[j]

    if j is 0
      path += '//'

    else
      path += '/'

  return path
