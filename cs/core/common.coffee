#UserAgent
_ua = do ->
  IE = document.uniqueID
  ltIE6 = typeof window.addEventListener is undefined and typeof document.documentElement.style.maxHeight is undefined
  ltIE7 = typeof window.addEventListener is undefined and typeof document.querySelectorAll is undefined
  ltIE8 = typeof window.addEventListener is undefined and typeof document.getElementsByClassName is undefined
  ltIE9 = IE and typeof window.Worker is undefined
  IE6 = IE and ltIE6
  IE7 = IE and ltIE7 and !ltIE6
  IE8 = IE and ltIE8 and !ltIE7 and !ltIE6
  IE9 = IE and ltIE9 and !ltIE8 and !ltIE7 and !ltIE6
  IE10 = IE and !ltIE9 and !ltIE8 and !ltIE7 and !ltIE6
  Webkit = !document.uniqueID and !window.opera and !window.sidebar and !window.orientation and window.localStorage
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

#URL
url = do ->
  href = location.href.split '/'

  localRegex = /^\d+\.\d+\.\d+\.\d+/
  workRegex = /^.*\/pc\/[^\/]+\/.*$/

  for val , i in href
    if val == '' or i == href.length - 1 and val.indexOf '.'
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

    if j == 0
      path += '//'

    else
      path += '/'

  return path

#スムーススクロール関数モーション定義
jQuery.extend(
  jQuery.easing,
    easeInOutCirc:
      (x, t, b, c, d) ->
        if (t/=d/2) < 1
          return -c/2 * (Math.sqrt(1 - t*t) - 1) + b
        c/2 * (Math.sqrt(1 - (t-=2)*t) + 1) + b
)

$ ->
  $id = $('body').attr('id')
  $class = $('body').attr('class')

  #フッター高さ取得# {{{
  footerHeight =
    ()->
      add = 0
      height = $('#footer').height()
      outerHeight = $('#footer').outerHeight(true)
      diff = height - outerHeight
      if diff > 0
        $('#content').css('padding-bottom',height+add)
        $('#footer').css('height',height)
      else
        $('#content').css('padding-bottom',outerHeight+add)
        $('#footer').css('height',height)
      return

  $(window).on('load resize',
    ->
      footerHeight()
  )
  # }}}

  $('a[href^=#]'+'a[href!=#]').click(
    (e)->
      $(
        if (navigator.userAgent.indexOf('Opera') isnt -1)
        then (
          if document.compatMode is 'BackCompat'
          then 'body'
          else 'html'
        )
        else 'html,body'
      ).animate(
        scrollTop:$($(this).attr('href')).offset().top - 20
      ,
        easing:'easeInOutCirc',
        duration:1000
      )

      e.preventDefault()
      return
  )

